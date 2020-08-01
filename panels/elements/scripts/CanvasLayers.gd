extends Control

# Private variable

var _number_of_layers : int = 0
var _selected_layer : int = 1

# Element public functions

func init(configuration : Dictionary):
	for layer in configuration.layers:
		_add_layer(layer)

	_set_overlay()

func transform(offset : Vector2, scale : Vector2):
	set_custom_minimum_size(scale * get_size() + (offset * 2))
	get_node("Layers").set_canvas_transform(Transform2D().scaled(scale).translated(offset / scale))
	get_child(1).transform(offset, scale)
	get_child(1).update()

func get_size():
	return _get_layer(_selected_layer).get_image().get_size()

func get_current_tool_box():
	return _get_layer(_selected_layer).get_tool_box()

func connect_with_undo_redo(undo_redo : Control):
	_get_layer(1).connect("register_action", undo_redo, "_register_action", [1])

	undo_redo.connect("apply_action", self, "_apply_action")

# Element private functions

func _gui_input(event):
	_get_layer(_selected_layer)._gui_input(event)

func _add_layer(layer : Dictionary):
	var new_layer
	match layer.type:
		"background":
			new_layer = preload("res://layers/Background.tscn").instance()
		"tilemap":
			new_layer = preload("res://layers/TileMap.tscn").instance()

	get_node("Layers").add_child(new_layer)
	new_layer.init(layer.configuration)

	_number_of_layers = _number_of_layers + 1

func _get_layer(layer_id : int):
	return get_node("Layers").get_child(layer_id)

func _set_overlay():
	add_child(_get_layer(_selected_layer).get_overlay())

func _apply_action(data, layer : int):
	_get_layer(layer).apply_action(data)
