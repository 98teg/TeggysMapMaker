class_name _TileMapLayer

# Private variables

var _width : int = 0
var _height : int = 0
var _tile_size : int = 0
var _map : Array = []
var _image : Image = Image.new()
var _tileset : Array = []
var _air : _Tile = _Tile.new()
var _out_of_bounds : _Tile = _Tile.new()

# Class public functions

func init(width : int, height : int, tile_size : int, tileset : Array):
	_width = width
	_height = height

	_tile_size = tile_size

	_create_map()
	_create_image()

	_tileset = tileset

	_create_special_tiles()

func get_image() -> Image:
	return _image

func set_tile(i : int, j : int, value : int):
	if(i >= 0 and i < _width and j >= 0 and j < _height):
		if _get_tile_id(i, j) != value:
			_map[i][j] = {"id": value, "state": 0}
			
			_update_tile(i, j)
			_update_tiles_around(i, j)
			
func fill(i : int, j : int, value : int, tile_to_replace : int = _Tile.Special_tile.UNSELECTED):
	if(i >= 0 and i < _width and j >= 0 and j < _height):
		if tile_to_replace == _Tile.Special_tile.UNSELECTED:
			tile_to_replace = _get_tile_id(i, j)
			
			if tile_to_replace == value:
				return

		set_tile(i, j, value)

		if _get_tile_id(i + 1, j) == tile_to_replace:
			fill(i + 1, j, value, tile_to_replace)

		if _get_tile_id(i, j + 1) == tile_to_replace:
			fill(i, j + 1, value, tile_to_replace)

		if _get_tile_id(i - 1, j) == tile_to_replace:
			fill(i - 1, j, value, tile_to_replace)

		if _get_tile_id(i, j - 1) == tile_to_replace:
			fill(i, j - 1, value, tile_to_replace)

func change_tile_state(i : int, j : int):
	var state = (_map[i][j].state + 1) % _get_tile(i, j).get_n_states()
	_map[i][j].state = state
	_place_tile_image(i, j, _get_tile(i, j).get_image(state))

# Class private functions

func _create_map():
	_map = []
	for x in range(_width):
		_map.append([])
		for y in range(_height):
			_map[x].append([])
			_map[x][y] = {"id": _Tile.Special_tile.AIR, "state": 0}

func _create_image():
	_image = Image.new()
	
	var w = _tile_size * _width
	var h = _tile_size * _height

	_image.create(w, h, false, Image.FORMAT_RGBA8)
	
func _create_special_tiles():
	_air.init_special_tile(_Tile.Special_tile.AIR, _tile_size)
	_out_of_bounds.init_special_tile(_Tile.Special_tile.OUT_OF_BOUNDS, _tile_size)

func _update_tiles_around(i : int, j : int):
	_update_tile(i - 1, j    )
	_update_tile(i - 1, j + 1)
	_update_tile(i    , j + 1)
	_update_tile(i + 1, j + 1)
	_update_tile(i + 1, j    )
	_update_tile(i + 1, j - 1)
	_update_tile(i    , j - 1)
	_update_tile(i - 1, j - 1)

func _update_tile(i : int, j : int):
	if _get_tile_id(i, j) == _Tile.Special_tile.OUT_OF_BOUNDS:
		pass
	elif _get_tile(i, j).get_connection_type() == _Tile.Connection_type.ISOLATED:
		_place_tile_image(i, j, _get_tile(i, j).get_image())
	else:
		var condition = 0
		var tile = _get_tile(i, j)
		
		if tile.get_connection_type() == _Tile.Connection_type.CROSS:
			condition = _get_cross_condition_id_of_tile(i, j)
		else:
			condition = _get_circle_condition_id_of_tile(i, j)
		  
		var state = tile.get_state(condition)
		_map[i][j].state = state
		_place_tile_image(i, j, tile.get_image(state))

func _get_cross_condition_id_of_tile(i : int, j : int) -> int:
	var condition = 0
	var tile = _get_tile(i, j)
	
	condition += 1 if tile.can_connect_to(_get_tile(i - 1, j)) else 0
	condition += 2 if tile.can_connect_to(_get_tile(i, j + 1)) else 0
	condition += 4 if tile.can_connect_to(_get_tile(i + 1, j)) else 0
	condition += 8 if tile.can_connect_to(_get_tile(i, j - 1)) else 0
	
	return condition

func _get_circle_condition_id_of_tile(i : int, j : int) -> int:
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

func _place_tile_image(i : int, j : int, tile_image : Image):
	var rect = Rect2(Vector2.ZERO, Vector2(_tile_size, _tile_size))
	var pos = Vector2(j * _tile_size, i * _tile_size)

	_image.blit_rect(tile_image, rect, pos)

func _get_tile_id(i : int, j : int) -> int:
	if(i >= 0 and i < _width and j >= 0 and j < _height):
		return _map[i][j].id
	
	return _Tile.Special_tile.OUT_OF_BOUNDS

func _get_tile(i : int, j : int) -> _Tile:
	var tile_id = _get_tile_id(i, j)
	
	match tile_id:
		_Tile.Special_tile.AIR:
			return _air
		_Tile.Special_tile.OUT_OF_BOUNDS:
			return _out_of_bounds

	return _tileset[tile_id]
