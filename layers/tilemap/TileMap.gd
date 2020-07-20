class_name _TileMap

var _width : int
var _height : int

var _tile_size : int

var _layers = []
var _tileset = []
var _selected_tile : int

var _image : Image

func init(width : int, height : int, tile_size : int):
	_width = width
	_height = height
	
	_tile_size = tile_size

	create_image()
	
func create_image():
	_image = Image.new()
	
	var w = _tile_size * _width
	var h = _tile_size * _height

	_image.create(w, h, false, Image.FORMAT_RGBA8)
	
func get_tile_size():
	return _tile_size
	
func create_tile(image : Image, layer : String = "", connection_type : int = _Tile.Connection_type.ISOLATED, material : String = ""):
	if has_layer(layer) == false:
		var tilemaplayer = _TileMapLayer.new()
		tilemaplayer.init(_width, _height, _tile_size, _tileset)

		_layers.append({"name": layer, "tilemap": tilemaplayer})

	_tileset.append(_Tile.new())
	
	var id = _tileset.size() - 1
	_tileset.back().init(id, get_layer_id(layer), image, connection_type, material)
	
func add_variation_to_last_tile(variation : Image, conditions : Array):
	_tileset.back().add_state(variation, conditions)
	
func has_layer(name : String) -> bool:
	for layer in _layers:
		if layer.name == name:
			return true
	return false
	
func get_layer_id(name : String) -> int:
	for i in range(_layers.size()):
		if _layers[i].name == name:
			return i
	return -1
	
func select_tile(tile_id : int):
	_selected_tile = tile_id

func place_tile(i : int, j : int):
	var selected_layer = _tileset[_selected_tile].get_layer()
	_layers[selected_layer].tilemap.set_tile(i, j, _selected_tile)

func erase_tile(i : int, j : int):
	var selected_layer = _tileset[_selected_tile].get_layer()
	_layers[selected_layer].tilemap.set_tile(i, j, _Tile.Special_tile.AIR)
	
func change_tile_state(i : int, j : int):
	var selected_layer = _tileset[_selected_tile].get_layer()
	_layers[selected_layer].tilemap.change_tile_state(i, j)

func get_image() -> Image:
	var rect = Rect2(Vector2.ZERO, Vector2(_tile_size * _width, _tile_size * _height))
	var pos = Vector2.ZERO

	_image.fill(Color.transparent)
	for layer in _layers:
		_image.blend_rect(layer.tilemap.get_image(), rect, pos)

	return _image
