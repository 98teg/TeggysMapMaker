extends Control

class_name _GridOverlay

var _width
var _height
var _tile_size

var _context

var _grid_points

func init(configuration : Dictionary, context : Dictionary):
	_width = configuration.width
	_height = configuration.height
	_tile_size = configuration.tile_size

	_context = context

	_grid_points = calculate_grid_points()
	
func resize(size : Vector2):
	set_custom_minimum_size(size)

func _draw():
	draw_set_transform(_context.pos, 0.0, _context.scale)
	draw_multiline(_grid_points, Color.black)
	
func calculate_grid_points():
	var points = []
	
	for i in range(1, _width):
		points.append(Vector2(i * _tile_size, 0))
		points.append(Vector2(i * _tile_size, _height * _tile_size))
	
	for i in range(1, _height):
		points.append(Vector2(0, i * _tile_size))
		points.append(Vector2(_height * _tile_size, i * _tile_size))
	
	return points
