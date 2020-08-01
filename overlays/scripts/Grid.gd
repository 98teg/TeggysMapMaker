extends Control

# Private variables

var _h_grid_lines : Array = []
var _v_grid_lines : Array = []
var _offset : Vector2 = Vector2.ZERO
var _scale : Vector2 = Vector2.ONE

# Overlay public functions

func init(width : int, height : int, tile_size : int):
	_set_grid_lines(width, height, tile_size)

func transform(offset : Vector2, scale : Vector2):
	_offset = offset
	_scale = scale

# Overlay private functions

func _set_grid_lines(w : int, h : int, s : int):
	for i in range(h - 1):
		_h_grid_lines.append([])
		_h_grid_lines[i].append(Vector2(0,     (i + 1) * s))
		_h_grid_lines[i].append(Vector2(h * s, (i + 1) * s))

	for i in range(w - 1):
		_v_grid_lines.append([])
		_v_grid_lines[i].append(Vector2((i + 1) * s, 0))
		_v_grid_lines[i].append(Vector2((i + 1) * s, h * s))

func _draw():
	for line in _h_grid_lines:
		draw_line(line[0] * _scale + _offset, line[1] * _scale + _offset, Color.red, 2)
	for line in _v_grid_lines:
		draw_line(line[0] * _scale + _offset, line[1] * _scale + _offset, Color.green, 2)
