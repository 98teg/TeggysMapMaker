class_name Tilemap

enum Tool{
	PENCIL,
	WRENCH,
	ERASER,
	BUCKET_FILL
}

# Private variables

var _width : int = 0
var _height : int = 0
var _tile_size : int = 0
var _background : Image = Image.new()
var _tilemaplayers : Array = []
var _tileset : Array = []
var _special_tileset : Dictionary = {}
var _selected_tile : Tile = Tile.new()

# Class public functions

func init(canvas_conf : Dictionary, layer_conf : Dictionary):
	_width = canvas_conf.Width
	_height = canvas_conf.Height

	_tile_size = layer_conf.TileSize

	_create_background(layer_conf.Background)

	_create_special_tileset()
	for tile_conf in layer_conf.TileSet:
		_add_tile(tile_conf)

func get_image() -> Image:
	var image = Image.new()
	var rect = Rect2(Vector2.ZERO, Vector2(_tile_size * _width, _tile_size * _height))
	var pos = Vector2.ZERO

	image.copy_from(_background)
	for tilemaplayer in _tilemaplayers:
		image.blend_rect(tilemaplayer.get_image(), rect, pos)

	return image

func select_tile(tile_id : int):
	_selected_tile = _tileset[tile_id]

func place_tile(i : int, j : int):
	var selected_layer = _selected_tile.get_layer()
	_tilemaplayers[selected_layer].set_tile(i, j, _selected_tile)

func erase_tile(i : int, j : int):
	var selected_layer = _selected_tile.get_layer()
	_tilemaplayers[selected_layer].set_tile(i, j, _special_tileset[Tile.Special_tile.AIR])

func change_tile_state(i : int, j : int):
	var selected_layer = _selected_tile.get_layer()
	_tilemaplayers[selected_layer].change_tile_state(i, j)

func fill(i : int, j : int):
	var selected_layer = _selected_tile.get_layer()
	_tilemaplayers[selected_layer].fill(i, j, _selected_tile)

func erase_tile_in_every_layer(i : int, j : int):
	for tilemaplayer in _tilemaplayers:
		tilemaplayer.set_tile(i, j, _special_tileset[Tile.Special_tile.AIR])

func retrieve_previous_tilemap():
	var tilemaplayers = []
	for i in range(_tilemaplayers.size()):
		if _tilemaplayers[i].has_been_modified():
			tilemaplayers.append({
				"ID": i,
				"TileMap": _tilemaplayers[i].retrieve_previous_tilemaplayer()
			})

	return tilemaplayers

func load_tilemap(tilemaplayers : Array):
	for tilemaplayer in tilemaplayers:
		_tilemaplayers[tilemaplayer.ID].load_tilemaplayer(tilemaplayer.TileMap)

# Class private functions

func _create_background(background_tile : Image):
	var background_size = Vector2(_tile_size * _width, _tile_size * _height)
	_background = GoostImage.tile(background_tile, background_size)

func _create_special_tileset():
	var empty_tile_image = Image.new()
	empty_tile_image.create(_tile_size, _tile_size, false, Image.FORMAT_RGBA8)
	empty_tile_image.fill(Color.transparent)

	var special_tile_conf = {
		"Layer": 0,
		"ConnectionType": Tile.Connection_type.ISOLATED,
		"Image": empty_tile_image,
		"Variations": [],
		"ConnectedGroup": 0
	}
	for special_tile_id in Tile.Special_tile.values():
		special_tile_conf.ID = special_tile_id
		
		var special_tile = Tile.new()
		special_tile.init(special_tile_conf)
		_special_tileset[special_tile_id] = special_tile

func _add_tile(tile_conf : Dictionary):
	if tile_conf.Layer == _tilemaplayers.size():
		_add_layer()

	var tile = Tile.new()
	tile.init(tile_conf)
	_tileset.append(tile)

func _add_layer():
	var tilemaplayer = TilemapLayer.new()
	tilemaplayer.init(_width, _height, _tile_size, _tileset, _special_tileset)

	_tilemaplayers.append(tilemaplayer)
