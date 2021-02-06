extends Control

#####################
# Private variables #
#####################

# Size of the square
var _size : int = 0

var _lines := []

var _squares := []

# Position of the square
var _pos : Vector2 = Vector2.ZERO
# Offset of the square
var _offset : Vector2 = Vector2.ZERO
# Scale of the square
var _scale : Vector2 = Vector2.ONE

####################
# Public functions #
####################

# + size: size of the square (int)
func init(size : int) -> void:
	_size = size

# Sets the position
func set_pos(pos : Vector2) -> void:
	_pos = pos
	update()

func set_squares(squares: Array) -> void:
	_squares.clear()
	_lines.clear()

	for square in squares:
		var square_x = square[1] * _size
		var square_y = square[0] * _size

		_squares.append(Vector2(square_x, square_y))

		_lines.append([Vector2(square_x, square_y),
				Vector2(square_x + _size, square_y)])
		_lines.append([Vector2(square_x + _size, square_y),
				Vector2(square_x + _size, square_y + _size)])
		_lines.append([Vector2(square_x + _size, square_y + _size),
				Vector2(square_x, square_y + _size)])
		_lines.append([Vector2(square_x, square_y + _size),
				Vector2(square_x, square_y)])

	var lines_to_remove = []
	for i in range(_lines.size()):
		for j in range(i, _lines.size()):
			if (_lines[i][0].x == _lines[j][1].x and
					_lines[i][0].y == _lines[j][1].y and
					_lines[i][1].x == _lines[j][0].x and
					_lines[i][1].y == _lines[j][0].y):
				lines_to_remove.append(i)
				lines_to_remove.append(j)

	lines_to_remove.sort()

	var lines_removed = 0
	for line in lines_to_remove:
		_lines.remove(line - lines_removed)
		lines_removed += 1

# Sets the transformation
func set_transform(offset : Vector2, scale : Vector2) -> void:
	_offset = offset
	_scale = scale

#####################
# Private functions #
#####################

# Draws the square
func _draw() -> void:
	var color_1 = Color(242 / 255.0, 149 / 255.0, 89 / 255.0, 1)
	var color_2 = Color(242 / 255.0, 149 / 255.0, 89 / 255.0, 0.25)
	var width = 4

	for square in _squares:
		draw_rect(Rect2(_transform(_pos + square),
				Vector2(_size, _size) * _scale), color_2, true)

	for line in _lines:
		draw_line(_transform(_pos + line[0]), _transform(_pos + line[1]),
				color_1, width, true)

# Transform a point
func _transform(p : Vector2) -> Vector2:
	return p * _scale + _offset
