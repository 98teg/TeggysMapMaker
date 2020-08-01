extends ScrollContainer

# Private variables

var _has_initiate : bool = false
var _base_scale : Vector2 = Vector2.ONE
var _scale_factor : float = 1.0
var _default_scrollbar : Vector2 = Vector2.ZERO
var _current_scrollbar : Vector2 = Vector2.ZERO

# Panel public functions

func init(configuration : Dictionary):
	get_node("CanvasLayers").init(configuration)

	get_h_scrollbar().connect("scrolling", self, "_h_scrollbar_scrolling")
	get_v_scrollbar().connect("scrolling", self, "_v_scrollbar_scrolling")

# Panel private functions

func _h_scrollbar_scrolling():
	_current_scrollbar.x = scroll_horizontal

func _v_scrollbar_scrolling():
	_current_scrollbar.y = scroll_vertical

func _get_size():
	return get_node("CanvasLayers").get_size()

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

	get_node("CanvasLayers").transform(offset, scale)

	if scrollbar.x != 0:
		yield(get_h_scrollbar(), "changed")
		scroll_horizontal = scrollbar.x

	if scrollbar.y != 0:
		yield(get_v_scrollbar(), "changed")
		scroll_vertical = scrollbar.y

func _update_scale_factor(percentage : float):
	_scale_factor = 3.75 * percentage + 0.25
	_update_rect()
