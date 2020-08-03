extends ScrollContainer

# Private variables

var _has_initiate : bool = false
var _base_scale : Vector2 = Vector2.ONE
var _scale_factor : float = 1.0
var _default_scrollbar : Vector2 = Vector2.ZERO
var _current_scrollbar : Vector2 = Vector2.ZERO
var _number_of_layers : int = 0
var _selected_layer : int = 1

# Panel public functions
func init(configuration : Dictionary):
	for layer in configuration.layers:
		_add_layer(layer)

	_set_overlay()

	get_h_scrollbar().connect("scrolling", self, "_h_scrollbar_scrolling")
	get_v_scrollbar().connect("scrolling", self, "_v_scrollbar_scrolling")
	
	get_node("CanvasViewport").connect("gui_input", self, "_gui_input")

func transform(offset : Vector2, scale : Vector2):
	get_node("CanvasViewport").set_custom_minimum_size(scale * get_size() + (offset * 2))
	get_node("CanvasViewport/Layers").set_canvas_transform(Transform2D().scaled(scale).translated(offset / scale))
	get_node("CanvasViewport").get_child(1).set_transform(offset, scale)
	get_node("CanvasViewport").get_child(1).update()

func get_size():
	return _get_layer(_selected_layer).get_image().get_size()

func get_current_tool_box():
	return _get_layer(_selected_layer).get_tool_box()

func connect_with_undo_redo(undo_redo : Control):
	_get_layer(1).connect("register_action", undo_redo, "_register_action", [1])

	undo_redo.connect("apply_action", self, "_apply_action")

# Panel private functions
func _gui_input(event):
	emit_signal("gui_input", event)
	_get_layer(_selected_layer)._gui_input(event)

func _add_layer(layer : Dictionary):
	var new_layer
	match layer.type:
		"background":
			new_layer = preload("res://panels/layers/Background.tscn").instance()
		"tilemap":
			new_layer = preload("res://panels/layers/TileMapCanvasLayer.tscn").instance()

	get_node("CanvasViewport/Layers").add_child(new_layer)
	new_layer.init(layer.configuration)

	_number_of_layers = _number_of_layers + 1

func _get_layer(layer_id : int):
	return get_node("CanvasViewport/Layers").get_child(layer_id)

func _set_overlay():
	get_node("CanvasViewport").add_child(_get_layer(_selected_layer).get_overlay())

func _apply_action(data, layer : int):
	_get_layer(layer).apply_action(data)

func _h_scrollbar_scrolling():
	_current_scrollbar.x = scroll_horizontal

func _v_scrollbar_scrolling():
	_current_scrollbar.y = scroll_vertical

func _get_size():
	return get_size()

func _get_size_scaled(scale):
	return _get_size() * scale

func _update_rect():
	if _has_initiate == false:
		_calculte_base_scale()
		_update_canvas(_base_scale)
		_has_initiate = true
	else:
		var scale = _base_scale * _scale_factor
		_update_canvas(scale)

func _calculte_base_scale():
	var scale = get_rect().size / _get_size()

	if scale.x < scale.y:
		_base_scale = Vector2(scale.x, scale.x)
	else:
		_base_scale = Vector2(scale.y, scale.y)

func _update_canvas(scale : Vector2):
	var canvas_size = get_rect().size
	var size_scaled = _get_size_scaled(scale)

	var pos = (canvas_size - size_scaled) / 2.0
	
	var offset = Vector2(0,0)
	offset.x = pos.x if pos.x > 0 else 0
	offset.y = pos.y if pos.y > 0 else 0

	var scrollbar = Vector2(0,0)
	scrollbar.x = -pos.x if pos.x < 0 else 0
	scrollbar.y = -pos.y if pos.y < 0 else 0

	var scrolled = Vector2(0,0)
	scrolled.x = _current_scrollbar.x / _default_scrollbar.x if _default_scrollbar.x > 0 else 1.0
	scrolled.y = _current_scrollbar.y / _default_scrollbar.y if _default_scrollbar.y > 0 else 1.0

	_default_scrollbar = scrollbar
	scrollbar = scrollbar * scrolled
	_current_scrollbar = scrollbar

	transform(offset, scale)

	if scrollbar.x != 0:
		yield(get_h_scrollbar(), "changed")
		scroll_horizontal = scrollbar.x

	if scrollbar.y != 0:
		yield(get_v_scrollbar(), "changed")
		scroll_vertical = scrollbar.y

func _update_scale_factor(percentage : float):
	_scale_factor = 3.75 * percentage + 0.25
	_update_rect()
