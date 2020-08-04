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
func init(configuration : Dictionary) -> void:
	_width = configuration.width
	_height = configuration.height
	_tile_size = configuration.tile_size

	get_node("Grid").init(_generate_grid_configuration(configuration))
	get_node("Highlight/Square").init(_generate_square_configuration(configuration))

# Sets the grid visibility
func set_grid_visibility(visibility : bool) -> void:
	if visibility:
		get_node("Grid").show()
	else:
		get_node("Grid").hide()

# Sets a position on the grid to highlight
func highlight(x : int, y : int) -> void:
	if x >= 0 and x < _width and y >= 0 and y < _height:
		get_node("Highlight/Image").set_pos(Vector2(x * _tile_size, y * _tile_size))
		get_node("Highlight/Square").set_pos(Vector2(x * _tile_size, y * _tile_size))
		get_node("Highlight").show()
	else:
		get_node("Highlight").hide()

# Sets the tile image
func set_tile(image : Image) -> void:
	get_node("Highlight/Image").set_image(image)

# Shows the tile when highlighting
func show_tile() -> void:
	get_node("Highlight/Image").show()

# Hides the tile when highlighting
func hide_tile() -> void:
	get_node("Highlight/Image").hide()

# Sets the transformation
func set_transform(offset : Vector2, scale : Vector2) -> void:
	get_node("Grid").set_transform(offset, scale)
	get_node("Highlight/Image").set_transform(offset, scale)
	get_node("Highlight/Square").set_transform(offset, scale)

#####################
# Private functions #
#####################

# Configuration dictionary description
# + grid_visibility: visibility of the grid (bool)
# + width: Width in number of tiles (int)
# + height: Height in number of tiles (int)
# + tile_size: Size of the tile in pixels (int)
func _generate_grid_configuration(configuration : Dictionary) -> Dictionary:
	var grid_configuration = {
		"visibility": configuration.grid_visibility,
		"width": configuration.width,
		"height": configuration.height,
		"tile_size": configuration.tile_size
	}

	return grid_configuration

# Configuration dictionary description
# + tile_size: Size of the tile in pixels (int)
func _generate_square_configuration(configuration : Dictionary) -> Dictionary:
	var square_configuration = {
		"visibility": true,
		"size": configuration.tile_size
	}

	return square_configuration

# Draws the overlay
func _draw() -> void:
	get_node("Grid").update()
	get_node("Highlight/Image").update()
	get_node("Highlight/Square").update()
