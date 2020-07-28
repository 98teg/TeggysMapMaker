extends ScrollContainer

# Private variables

var _dimensions
var _base_scale = 1
var _scale = 1
var _has_initiate = false

# Panel public functions

func init(configuration : Dictionary):
	get_node("CanvasLayers").init(configuration)

# Panel private functions

func _update_rect():
	if _has_initiate == false:
		_dimensions = Vector2(160, 160)

		var width = get_rect().size.x
		var height = get_rect().size.y
		
		var width_scale = width / _dimensions.x
		var height_scale = height / _dimensions.y
		
		if width_scale < height_scale:
			_base_scale = Vector2(width_scale, width_scale)
		else:
			_base_scale = Vector2(height_scale, height_scale)
	
		_scale = _base_scale
		_has_initiate = true

	var width = get_rect().size.x
	var height = get_rect().size.y
	
	var x_offset = (width - (_dimensions.x * _scale.x)) / 2
	var h_scrollbar = 0
	if x_offset < 0:
		h_scrollbar = -x_offset
		x_offset = 0
	
	var y_offset = (height - (_dimensions.y * _scale.y)) / 2
	var v_scrollbar = 0
	if y_offset < 0:
		v_scrollbar = -y_offset
		y_offset = 0
	
	y_offset = y_offset if y_offset > 0 else 0
	
	var pos = Vector2(x_offset, y_offset)
	
	get_node("CanvasLayers").set_custom_minimum_size(_dimensions * _scale + pos * 2)
	get_node("CanvasLayers/Viewport").set_canvas_transform(Transform2D().scaled(_scale).translated(pos / _scale))
	
	yield(get_v_scrollbar(), "changed")
	scroll_vertical = v_scrollbar
	
	yield(get_h_scrollbar(), "changed")
	scroll_horizontal = h_scrollbar

func _update_scale_factor(percentage : float):
	_scale = _base_scale * (2.5 * percentage + 0.25)
	_update_rect()
