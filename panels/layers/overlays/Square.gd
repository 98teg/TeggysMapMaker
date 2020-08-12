extends Control

#####################
# Private variables #
#####################

# Size of the square
var _size : int = 0
# Position of the square
var _pos : Vector2 = Vector2.ZERO
# Offset of the square
var _offset : Vector2 = Vector2.ZERO
# Scale of the square
var _scale : Vector2 = Vector2.ONE

####################
# Public functions #
####################

# Configuration dictionary description
# + visibility: visibility of the square (bool)
# + size: size of the square (int)
func init(size : int) -> void:
	_size = size

# Sets the position
func set_pos(pos : Vector2) -> void:
	_pos = pos
	update()

# Sets the transformation
func set_transform(offset : Vector2, scale : Vector2) -> void:
	_offset = offset
	_scale = scale

#####################
# Private functions #
#####################

# Draws the square
func _draw() -> void:
	var color_1 = Color(242 / 255.0, 149 / 255.0, 89 / 255.0, 0.75)
	var color_2 = Color(242 / 255.0, 149 / 255.0, 89 / 255.0, 0.25)
	var width = 4

	draw_rect(Rect2(_transform(_pos), Vector2(_size, _size) * _scale), color_2, true)
	draw_rect(Rect2(_transform(_pos), Vector2(_size, _size) * _scale), color_1, false, width, true)

# Transform a point
func _transform(p : Vector2) -> Vector2:
	return p * _scale + _offset
