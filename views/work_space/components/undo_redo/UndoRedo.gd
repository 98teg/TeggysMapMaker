extends Control

# Custom signals

signal apply_action(data, layer)

# Public variables

export var number_of_actions : int = 20

# Private variables

var _previous_actions : Array = []
var _next_actions : Array = []
var _undo_was_pressed : bool = false
var _redo_was_pressed : bool = false

# Panel private functions

func _input(event):
	if event.is_action_pressed("ui_undo"):
		_undo()
	elif event.is_action_pressed("ui_redo"):
		_redo()

func _register_action(data, layer : int):
	if _undo_was_pressed:
		_next_actions.append({"data": data, "layer": layer})
		_undo_was_pressed = false
	elif _redo_was_pressed:
		_previous_actions.append({"data": data, "layer": layer})
		_redo_was_pressed = false
	else:
		_previous_actions.append({"data": data, "layer": layer})
		if _previous_actions.size() > number_of_actions:
			_previous_actions.pop_front()

		_next_actions.clear()

func _undo():
	if _previous_actions.size() > 0:
		var action = _previous_actions.pop_back()
		_undo_was_pressed = true
		emit_signal("apply_action", action.data, action.layer)

func _redo():
	if _next_actions.size() > 0:
		var action = _next_actions.pop_back()
		_redo_was_pressed = true
		emit_signal("apply_action", action.data, action.layer)
