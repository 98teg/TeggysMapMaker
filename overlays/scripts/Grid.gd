extends Control

# Private variables

var _grid_points : Array = []
var _canvas_context : Dictionary

# Overlay public functions

func init(configuration : Dictionary, canvas_context : Dictionary):
	_set_grid_points(configuration.width, configuration.height, configuration.tile_size)
	_set_canvas_context(canvas_context)

# Overlay private functions

func _set_grid_points(w : int, h : int, s : int):
	for i in range(1, w):
		_grid_points.append(Vector2(i * s, 0))
		_grid_points.append(Vector2(i * s, h * s))
	
	for i in range(1, h):
		_grid_points.append(Vector2(0, i * s))
		_grid_points.append(Vector2(h * s, i * s))

func _set_canvas_context(canvas_context : Dictionary):
	_canvas_context = canvas_context

func _draw():
	draw_set_transform(_canvas_context.pos, 0.0, _canvas_context.scale)
	draw_multiline(_grid_points, Color.black)
