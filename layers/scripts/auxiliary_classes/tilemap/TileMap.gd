class_name _TileMap

# Private variables

var _width : int = 0
var _height : int = 0
var _tile_size : int = 0
var _layers : Array = []
var _tileset : Array = []
var _selected_tile : int = 0
var _image : Image = Image.new()

# Class public functions

func init(configuration : Dictionary):
	_width = configuration.width
	_height = configuration.height
	
	_tile_size = configuration.tile_size
	
	for tile in configuration.tileset:
		_add_tile(tile)

	_create_image()

func get_image() -> Image:
	var rect = Rect2(Vector2.ZERO, Vector2(_tile_size * _width, _tile_size * _height))
	var pos = Vector2.ZERO

	_image.fill(Color.transparent)
	for layer in _layers:
		_image.blend_rect(layer.tilemap.get_image(), rect, pos)

	return _image

func get_selected_tile_image():
	return _tileset[_selected_tile].get_image()

func get_tile_size() -> int:
	return _tile_size

func get_tileset() -> Array:
	return _tileset

func select_tile(tile_id : int):
	_selected_tile = tile_id

func place_tile(i : int, j : int):
	var selected_layer = _tileset[_selected_tile].get_layer()
	_layers[selected_layer].tilemap.set_tile(i, j, _selected_tile)
	
func change_tile_state(i : int, j : int):
	var selected_layer = _tileset[_selected_tile].get_layer()
	_layers[selected_layer].tilemap.change_tile_state(i, j)

func erase_tile(i : int, j : int):
	var selected_layer = _tileset[_selected_tile].get_layer()
	_layers[selected_layer].tilemap.set_tile(i, j, _Tile.Special_tile.AIR)

func erase_tile_in_every_layer(i : int, j : int):
	for layer in _layers:
		layer.tilemap.set_tile(i, j, _Tile.Special_tile.AIR)

func fill(i : int, j : int):
	var selected_layer = _tileset[_selected_tile].get_layer()
	_layers[selected_layer].tilemap.fill(i, j, _selected_tile)

func retrieve_previous_tilemap():
	var tilemap = []
	for i in range(_layers.size()):
		if _layers[i].tilemap.has_been_modified():
			tilemap.append({"layer": i, "tilemap": _layers[i].tilemap.retrieve_previous_map()})

	return tilemap

func load_tilemap(tilemap : Array):
	for layer in tilemap:
		_layers[layer.layer].tilemap.load_map(layer.tilemap)

# Class private functions
	
func _create_image():
	var w = _tile_size * _width
	var h = _tile_size * _height

	_image.create(w, h, false, Image.FORMAT_RGBA8)

func _add_tile(configuration : Dictionary):
	var layer = configuration.layer if configuration.has("layer") else ""
	if _has_layer(layer) == false:
		_add_layer(layer)

	configuration.id = _tileset.size()
	configuration.layer = _get_layer_id(layer)
	configuration.tile_size = _tile_size
	
	var tile = _Tile.new()
	tile.init(configuration)
	_tileset.append(tile)

func _add_layer(name : String):
	var tilemaplayer = _TileMapLayer.new()
	tilemaplayer.init(_width, _height, _tile_size, _tileset)

	_layers.append({"name": name, "tilemap": tilemaplayer})
	
func _has_layer(name : String) -> bool:
	for layer in _layers:
		if layer.name == name:
			return true
	return false
	
func _get_layer_id(name : String) -> int:
	for i in range(_layers.size()):
		if _layers[i].name == name:
			return i
	return -1
