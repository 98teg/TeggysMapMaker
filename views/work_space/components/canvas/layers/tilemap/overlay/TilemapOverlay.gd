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

var _selected_tile : int

var _tile_set := TMM_TileSet.new()

####################
# Public functions #
####################

# Configuration dictionary description
# + grid_visibility: visibility of the grid (bool)
# + width: Width in number of tiles (int)
# + height: Height in number of tiles (int)
# + tile_size: Size of the tile in pixels (int)
func init(canvas_conf : Dictionary, layer_conf : Dictionary, tile_set: TMM_TileSet) -> void:
	_width = canvas_conf.Width
	_height = canvas_conf.Height
	_tile_size = layer_conf.TileSize
	_tile_set = tile_set

	get_node("Grid").init(_width, _height, _tile_size)
	get_node("Squares").init(_tile_size)

# Sets the grid visibility
func set_grid_visibility(visibility: bool) -> void:
	if visibility:
		get_node("Grid").show()
	else:
		get_node("Grid").hide()

# Sets the squares
func set_squares(tile_id: int) -> void:
	var squares = []

	for tile in _tile_set.get_tile_structure(tile_id).get_tiles():
		squares.append(tile.relative_coord)

	get_node("Squares").set_squares(squares)
	_selected_tile = tile_id


func set_tool(tool_id: int) -> void:
	if tool_id != TMM_TileMapHelper.Tool.PENCIL and tool_id != TMM_TileMapHelper.Tool.BUCKET_FILL:
		get_node("Squares").set_squares([[0, 0]])
	else:
		set_squares(_selected_tile)

# Sets a position on the grid to highlight
func highlight(x: int, y: int) -> void:
	if x >= 0 and x < _width and y >= 0 and y < _height:
		get_node("Squares").set_pos(Vector2(x * _tile_size, y * _tile_size))
		get_node("Squares").show()
	else:
		get_node("Squares").hide()

# Sets the transformation
func set_transform(offset: Vector2, scale: Vector2) -> void:
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
