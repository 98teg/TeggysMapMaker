class_name TilemapSubLayer

# Private variables

var _width : int = 0
var _height : int = 0
var _tile_size : int = 0
var _map : Array = []
var _image : Image = Image.new()
var _tileset : Array = []
var _special_tileset : Dictionary = {}
var _previous_tilemap_sublayer : Array = []
var _has_been_modified : bool = false

# Class public functions

func init(width: int, height: int, tile_size: int, tileset: Array,
		special_tileset: Dictionary):
	_width = width
	_height = height

	_tile_size = tile_size

	_create_map()
	_create_image()

	_tileset = tileset
	_special_tileset = special_tileset


func get_image() -> Image:
	return _image


func set_tile(i: int, j: int, tile: Tile):
	var id = tile.get_id()
	if(i >= 0 and i < _height and j >= 0 and j < _width):
		if _get_tile_id(i, j) != id:
			_map[i][j] = {"ID": id}
			
			_update_tile(i, j)
			_update_tiles_around(i, j)
			
			_has_been_modified = true


func change_tile_state(i: int, j: int):
	if(i >= 0 and i < _height and j >= 0 and j < _width):
		if _get_tile(i, j).get_n_states() > 1:
			var state = (_get_tile_state(i, j) + 1) % _get_tile(i, j).get_n_states()
			_map[i][j].State = state
			_place_tile_image(i, j, _get_tile(i, j).get_image(state))
			
			_has_been_modified = true


func has_been_modified():
	return _has_been_modified


func retrieve_previous_tilemapsublayer():
	var previous_tilemap_sublayer = _previous_tilemap_sublayer
	_previous_tilemap_sublayer = _map.duplicate(true)

	_has_been_modified = false

	return previous_tilemap_sublayer


func load_tilemapsublayer(map: Array):
	_map = map
	_has_been_modified = true
	
	for i in range(_height):
		for j in range(_width):
			_place_tile_image(i, j, _get_tile(i, j).get_image(_get_tile_state(i, j)))

# Class private functions

func _create_map():
	_map = []
	for i in range(_height):
		_map.append([])
		for j in range(_width):
			_map[i].append([])
			_map[i][j] = {"ID": Tile.Special_tile.AIR}

	_previous_tilemap_sublayer = _map.duplicate(true)


func _create_image():
	_image = Image.new()
	
	var w = _tile_size * _width
	var h = _tile_size * _height

	_image.create(w, h, false, Image.FORMAT_RGBA8)


func _update_tiles_around(i: int, j: int):
	_update_tile(i - 1, j    )
	_update_tile(i - 1, j + 1)
	_update_tile(i    , j + 1)
	_update_tile(i + 1, j + 1)
	_update_tile(i + 1, j    )
	_update_tile(i + 1, j - 1)
	_update_tile(i    , j - 1)
	_update_tile(i - 1, j - 1)


func _update_tile(i: int, j: int):
	if _get_tile_id(i, j) == Tile.Special_tile.OUT_OF_BOUNDS:
		pass
	elif _get_tile(i, j).get_connection_type() == Tile.Connection_type.ISOLATED:
		_place_tile_image(i, j, _get_tile(i, j).get_image())
	else:
		var condition = 0
		var tile = _get_tile(i, j)
		
		if tile.get_connection_type() == Tile.Connection_type.CROSS:
			condition = _get_cross_condition_id_of_tile(i, j)
		else:
			condition = _get_circle_condition_id_of_tile(i, j)
		  
		var state = tile.get_state(condition)
		_map[i][j].State = state
		_place_tile_image(i, j, tile.get_image(state))


func _get_cross_condition_id_of_tile(i: int, j: int) -> int:
	var condition = 0
	var tile = _get_tile(i, j)
	
	condition += 1 if tile.can_connect_to(_get_tile(i - 1, j)) else 0
	condition += 2 if tile.can_connect_to(_get_tile(i, j + 1)) else 0
	condition += 4 if tile.can_connect_to(_get_tile(i + 1, j)) else 0
	condition += 8 if tile.can_connect_to(_get_tile(i, j - 1)) else 0
	
	return condition


func _get_circle_condition_id_of_tile(i: int, j: int) -> int:
	var condition = 0
	var tile = _get_tile(i, j)

	condition += 1   if tile.can_connect_to(_get_tile(i - 1, j    )) else 0
	condition += 2   if tile.can_connect_to(_get_tile(i - 1, j + 1)) else 0
	condition += 4   if tile.can_connect_to(_get_tile(i    , j + 1)) else 0
	condition += 8   if tile.can_connect_to(_get_tile(i + 1, j + 1)) else 0
	condition += 16  if tile.can_connect_to(_get_tile(i + 1, j    )) else 0
	condition += 32  if tile.can_connect_to(_get_tile(i + 1, j - 1)) else 0
	condition += 64  if tile.can_connect_to(_get_tile(i    , j - 1)) else 0
	condition += 128 if tile.can_connect_to(_get_tile(i - 1, j - 1)) else 0

	return condition


func _place_tile_image(i: int, j: int, tile_image: Image):
	var rect = Rect2(Vector2.ZERO, Vector2(_tile_size, _tile_size))
	var pos = Vector2(j * _tile_size, i * _tile_size)

	_image.blit_rect(tile_image, rect, pos)


func _get_tile_id(i: int, j: int) -> int:
	if(i >= 0 and i < _height and j >= 0 and j < _width):
		return _map[i][j].ID

	return Tile.Special_tile.OUT_OF_BOUNDS


func _get_tile_state(i: int, j: int) -> int:
	if(i >= 0 and i < _height and j >= 0 and j < _width):
		if _map[i][j].has("State"):
			return _map[i][j].State

	return 0


func _get_tile(i: int, j: int) -> Tile:
	var tile_id = _get_tile_id(i, j)
	
	if tile_id >= 0:
		return _tileset[tile_id]
	else:
		return _special_tileset[tile_id]
