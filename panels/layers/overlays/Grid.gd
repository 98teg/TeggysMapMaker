extends Control

#####################
# Private variables #
#####################

# Horizontal lines of the grid
var _grid_h_lines : Array = []
# Vertical lines of the grid
var _grid_v_lines : Array = []
# Offset of the grid
var _offset : Vector2 = Vector2.ZERO
# Scale of the grid
var _scale : Vector2 = Vector2.ONE

####################
# Public functions #
####################

# Configuration dictionary description
# + visibility: visibility of the grid (bool)
# + width: Width in number of tiles (int)
# + height: Height in number of tiles (int)
# + tile_size: Size of the tile in pixels (int)
func init(configuration : Dictionary) -> void:
	if configuration.visibility:
		show()
	else:
		hide()

	_create_grid_lines(configuration.width, configuration.height, configuration.tile_size)

# Sets the transformation
func set_transform(offset : Vector2, scale : Vector2) -> void:
	_offset = offset
	_scale = scale

#####################
# Private functions #
#####################

# Creates the grid lines
func _create_grid_lines(width : int, height : int, tile_size : int) -> void:
	for i in range(height - 1):
		_grid_h_lines.append([])
		_grid_h_lines[i].append(Vector2(0                , (i + 1) * tile_size))
		_grid_h_lines[i].append(Vector2(width * tile_size, (i + 1) * tile_size))

	for i in range(width - 1):
		_grid_v_lines.append([])
		_grid_v_lines[i].append(Vector2((i + 1) * tile_size, 0                 ))
		_grid_v_lines[i].append(Vector2((i + 1) * tile_size, height * tile_size))

# Draws the grid
func _draw() -> void:
	for line in _grid_h_lines:
		draw_line(_transform(line[0]), _transform(line[1]), Color.red, 2)
	for line in _grid_v_lines:
		draw_line(_transform(line[0]), _transform(line[1]), Color.green, 2)

# Transform a point
func _transform(p : Vector2) -> Vector2:
	return p * _scale + _offset
