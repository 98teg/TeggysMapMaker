class_name _TileMap

var _width : int
var _height : int

var _tile_size : int

var _tilemap = []
var _tileset = []
var _tilemap_image = Image.new()

func init_tilemap(width : int, height : int, tile_size : int):
	_width = width
	_height = height
	
	_tile_size = tile_size
	
	create_tilemap()
	create_tileset()
	create_tilemap_image()
			
func create_tilemap():
	_tilemap = []
	for x in range(_width):
		_tilemap.append([])
		for y in range(_height):
			_tilemap[x].append([])
			_tilemap[x][y] = {"tile_id": 0, "state": 0}
			
func create_tileset():
	_tileset = []
	
	var empty_tile_image = Image.new()
	empty_tile_image.create(_tile_size, _tile_size, false, Image.FORMAT_RGBA8)
	empty_tile_image.fill(Color.transparent)

	create_tile(empty_tile_image)

func create_tilemap_image():
	_tilemap_image = Image.new()
	
	var w = _tile_size * _width
	var h = _tile_size * _height

	_tilemap_image.create(w, h, false, Image.FORMAT_RGBA8)
	
func get_tile_size():
	return _tile_size
	
func create_tile(image : Image, connection_type = _Tile.Connection_type.NONE):
	_tileset.append(_Tile.new())
	
	_tileset.back().create_tile(image, connection_type)
	
func add_variation_to_last_tile(variation : Image, conditions : Array):
	_tileset.back().add_state(variation, conditions)

func set_tile(i : int, j : int, value : int):
	if(i >= 0 and i < _width and j >= 0 and j < _height):
		if get_tile_id(i, j) != value:
			_tilemap[i][j] = {"tile_id": value, "state": 0}
			
			update_tile(i, j)
			
			update_tile(i - 1, j    )
			update_tile(i - 1, j + 1)
			update_tile(i    , j + 1)
			update_tile(i + 1, j + 1)
			update_tile(i + 1, j    )
			update_tile(i + 1, j - 1)
			update_tile(i    , j - 1)
			update_tile(i - 1, j - 1)
		
func update_tile(i : int, j : int):
	if get_tile(i, j) == null:
		pass
	elif get_tile(i, j).get_connection_type() == _Tile.Connection_type.NONE:
		place_tile_image(i, j, get_tile(i, j).get_image())
	else:
		var condition = 0
		
		if get_tile(i, j).get_connection_type() == _Tile.Connection_type.CROSS:
			condition += 1 if are_connected(get_tile_id(i - 1, j), get_tile_id(i, j)) else 0
			condition += 2 if are_connected(get_tile_id(i, j + 1), get_tile_id(i, j)) else 0
			condition += 4 if are_connected(get_tile_id(i + 1, j), get_tile_id(i, j)) else 0
			condition += 8 if are_connected(get_tile_id(i, j - 1), get_tile_id(i, j)) else 0
		else:
			condition += 1   if are_connected(get_tile_id(i - 1, j    ), get_tile_id(i, j)) else 0
			condition += 2   if are_connected(get_tile_id(i - 1, j + 1), get_tile_id(i, j)) else 0
			condition += 4   if are_connected(get_tile_id(i    , j + 1), get_tile_id(i, j)) else 0
			condition += 8   if are_connected(get_tile_id(i + 1, j + 1), get_tile_id(i, j)) else 0
			condition += 16  if are_connected(get_tile_id(i + 1, j    ), get_tile_id(i, j)) else 0
			condition += 32  if are_connected(get_tile_id(i + 1, j - 1), get_tile_id(i, j)) else 0
			condition += 64  if are_connected(get_tile_id(i    , j - 1), get_tile_id(i, j)) else 0
			condition += 128 if are_connected(get_tile_id(i - 1, j - 1), get_tile_id(i, j)) else 0
		  
		var state = get_tile(i, j).get_state(condition)
		_tilemap[i][j].state = state
		place_tile_image(i, j, get_tile(i, j).get_image(state))
		
func change_tile_state(i : int, j : int):
	var state = (_tilemap[i][j].state + 1) % get_tile(i, j).get_n_states()
	_tilemap[i][j].state = state
	place_tile_image(i, j, get_tile(i, j).get_image(state))
		
func are_connected(tile_id_1 : int, tile_id_2 : int):
	return tile_id_1 == tile_id_2 or tile_id_1 == -1 or tile_id_2 == -1

func place_tile_image(i : int, j : int, tile_image : Image):
	var rect = Rect2(Vector2.ZERO, Vector2(_tile_size, _tile_size))
	var pos = Vector2(j * _tile_size, i * _tile_size)

	_tilemap_image.blit_rect(tile_image, rect, pos)

func get_tile_id(i : int, j : int) -> int:
	if(i >= 0 and i < _width and j >= 0 and j < _height):
		return _tilemap[i][j].tile_id
	else:
		return -1

func get_tile(i : int, j : int) -> _Tile:
	if(i >= 0 and i < _width and j >= 0 and j < _height):
		return _tileset[get_tile_id(i, j)]
	else:
		return null
		
func get_tilemap_image() -> Image:
	return _tilemap_image
