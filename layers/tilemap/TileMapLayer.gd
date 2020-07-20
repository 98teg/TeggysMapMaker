class_name _TileMapLayer

var _width : int
var _height : int

var _tile_size : int

var _map = []
var _image : Image = Image.new()
var _tileset : Array
var _air : _Tile = _Tile.new()
var _out_of_bounds : _Tile = _Tile.new()

func init(width : int, height : int, tile_size : int, tileset : Array):
	_width = width
	_height = height
	
	_tile_size = tile_size
	
	create_map()
	create_image()
	
	_tileset = tileset
	
	create_special_tiles()

func create_map():
	_map = []
	for x in range(_width):
		_map.append([])
		for y in range(_height):
			_map[x].append([])
			_map[x][y] = {"id": _Tile.Special_tile.AIR, "state": 0}

func create_image():
	_image = Image.new()
	
	var w = _tile_size * _width
	var h = _tile_size * _height

	_image.create(w, h, false, Image.FORMAT_RGBA8)
	
func create_special_tiles():
	var empty_tile_image = Image.new()
	empty_tile_image.create(_tile_size, _tile_size, false, Image.FORMAT_RGBA8)
	empty_tile_image.fill(Color.transparent)
	
	_air.init(_Tile.Special_tile.AIR, 0, empty_tile_image)
	_out_of_bounds.init(_Tile.Special_tile.OUT_OF_BOUNDS, 0, empty_tile_image)

func set_tile(i : int, j : int, value : int):
	if(i >= 0 and i < _width and j >= 0 and j < _height):
		if get_tile_id(i, j) != value:
			_map[i][j] = {"id": value, "state": 0}
			
			update_tile(i, j)
			update_tiles_around(i, j)
		
func update_tiles_around(i : int, j : int):
	update_tile(i - 1, j    )
	update_tile(i - 1, j + 1)
	update_tile(i    , j + 1)
	update_tile(i + 1, j + 1)
	update_tile(i + 1, j    )
	update_tile(i + 1, j - 1)
	update_tile(i    , j - 1)
	update_tile(i - 1, j - 1)
		
func update_tile(i : int, j : int):
	if get_tile_id(i, j) == _Tile.Special_tile.OUT_OF_BOUNDS:
		pass
	elif get_tile(i, j).get_connection_type() == _Tile.Connection_type.ISOLATED:
		place_tile_image(i, j, get_tile(i, j).get_image())
	else:
		var condition = 0
		var tile = get_tile(i, j)
		
		if tile.get_connection_type() == _Tile.Connection_type.CROSS:
			condition = get_cross_condition_of_tile(i, j)
		else:
			condition = get_circle_condition_of_tile(i, j)
		  
		var state = tile.get_state(condition)
		_map[i][j].state = state
		place_tile_image(i, j, tile.get_image(state))
		
func get_cross_condition_of_tile(i : int, j : int) -> int:
	var condition = 0
	var tile = get_tile(i, j)
	
	condition += 1 if tile.can_connect_to(get_tile(i - 1, j)) else 0
	condition += 2 if tile.can_connect_to(get_tile(i, j + 1)) else 0
	condition += 4 if tile.can_connect_to(get_tile(i + 1, j)) else 0
	condition += 8 if tile.can_connect_to(get_tile(i, j - 1)) else 0
	
	return condition

func get_circle_condition_of_tile(i : int, j : int) -> int:
	var condition = 0
	var tile = get_tile(i, j)
	
	condition += 1   if tile.can_connect_to(get_tile(i - 1, j    )) else 0
	condition += 2   if tile.can_connect_to(get_tile(i - 1, j + 1)) else 0
	condition += 4   if tile.can_connect_to(get_tile(i    , j + 1)) else 0
	condition += 8   if tile.can_connect_to(get_tile(i + 1, j + 1)) else 0
	condition += 16  if tile.can_connect_to(get_tile(i + 1, j    )) else 0
	condition += 32  if tile.can_connect_to(get_tile(i + 1, j - 1)) else 0
	condition += 64  if tile.can_connect_to(get_tile(i    , j - 1)) else 0
	condition += 128 if tile.can_connect_to(get_tile(i - 1, j - 1)) else 0
	
	return condition
		
func change_tile_state(i : int, j : int):
	var state = (_map[i][j].state + 1) % get_tile(i, j).get_n_states()
	_map[i][j].state = state
	place_tile_image(i, j, get_tile(i, j).get_image(state))

func place_tile_image(i : int, j : int, tile_image : Image):
	var rect = Rect2(Vector2.ZERO, Vector2(_tile_size, _tile_size))
	var pos = Vector2(j * _tile_size, i * _tile_size)

	_image.blit_rect(tile_image, rect, pos)

func get_tile_id(i : int, j : int) -> int:
	if(i >= 0 and i < _width and j >= 0 and j < _height):
		return _map[i][j].id
	
	return _Tile.Special_tile.OUT_OF_BOUNDS

func get_tile(i : int, j : int) -> _Tile:
	var tile_id = get_tile_id(i, j)
	
	match tile_id:
		_Tile.Special_tile.AIR:
			return _air
		_Tile.Special_tile.OUT_OF_BOUNDS:
			return _out_of_bounds

	return _tileset[tile_id]

func get_image() -> Image:
	return _image
