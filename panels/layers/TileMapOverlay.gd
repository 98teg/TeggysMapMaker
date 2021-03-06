extends Control

#####################
# Private variables #
#####################

# Width in number of tiles
var _width : int = 0
# Height in number of tiles
var _height : int = 0
# Size of the tile in pixels
var _tile_size : int = 0

####################
# Public functions #
####################

# Configuration dictionary description
# + grid_visibility: visibility of the grid (bool)
# + width: Width in number of tiles (int)
# + height: Height in number of tiles (int)
# + tile_size: Size of the tile in pixels (int)
func init(canvas_conf : Dictionary, layer_conf : Dictionary) -> void:
	_width = canvas_conf.Width
	_height = canvas_conf.Height
	_tile_size = layer_conf.TileSize

	get_node("Grid").init(_width, _height, _tile_size)
	get_node("Square").init(_tile_size)

# Sets the grid visibility
func set_grid_visibility(visibility : bool) -> void:
	if visibility:
		get_node("Grid").show()
	else:
		get_node("Grid").hide()

# Sets a position on the grid to highlight
func highlight(x : int, y : int) -> void:
	if x >= 0 and x < _width and y >= 0 and y < _height:
		get_node("Square").set_pos(Vector2(x * _tile_size, y * _tile_size))
		get_node("Square").show()
	else:
		get_node("Square").hide()

# Sets the transformation
func set_transform(offset : Vector2, scale : Vector2) -> void:
	for child in get_children():
		child.set_transform(offset, scale)
		child.set_transform(offset, scale)

	update()

#####################
# Private functions #
#####################

# Draws the overlay
func _draw() -> void:
	for child in get_children():
		child.update()
		child.update()
