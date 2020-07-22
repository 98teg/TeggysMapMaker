extends Control

# Custom signals

signal magnifying_factor_updated(value)

# Private variables

var _magnifying_factor : int = 30

# Toolbox private functions

func _input(event):
	if event.is_action_pressed("ui_zoom_plus"):
		_add_to_magnifying_factor(10)
	elif event.is_action_pressed("ui_zoom_minus"):
		_add_to_magnifying_factor(-10)

func _add_to_magnifying_factor(value : int):
	var magnifying_factor = _magnifying_factor + value

	if magnifying_factor >= 0 and magnifying_factor <= 100:
		get_node("SliderContainer/Slider").set_value(magnifying_factor)
	elif magnifying_factor > 100 and _magnifying_factor < 100:
		get_node("SliderContainer/Slider").set_value(100)
	elif magnifying_factor < 0 and _magnifying_factor > 0:
		get_node("SliderContainer/Slider").set_value(0)

func _set_magnifying_factor(value : int):
	_magnifying_factor = value
	emit_signal("magnifying_factor_updated", _magnifying_factor / 100.0)
