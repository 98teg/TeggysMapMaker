class_name TilemapSubLayer


var _width := 0
var _height := 0
var _tile_size := 0
var _tile_set := {}
var _map := []
var _image := Image.new()
var _previous_tilemap_sublayer := []
var _has_been_modified := false


func init(width: int, height: int, tile_size: int, tile_set: Dictionary) -> void:
	_width = width
	_height = height
	_tile_size = tile_size
	_tile_set = tile_set

	_create_map()
	_create_image()


func get_image() -> Image:
	return _image


func get_tile(i: int, j: int) -> Tile:
	if(i >= 0 and i < _height and j >= 0 and j < _width):
		return _tile_set[_map[i][j].ID]

	return _tile_set[Tile.Special_tile.OUT_OF_BOUNDS]


func set_tile(i: int, j: int, tile: Tile):
	var id = tile.get_id()
	var tiles_to_update = []

	if tile.is_a_multi_title():
		for subtile in tile.get_subtiles():
			var pos_i = i - subtile[1]
			var pos_j = j + subtile[0]

			if(pos_i >= 0 and pos_i < _height and
					pos_j >= 0 and pos_j < _width):
				if (_get_tile_id(pos_i, pos_j) != id or
						_get_tile_subtile(pos_i, pos_j) != subtile):
					_remove_subtiles(pos_i, pos_j)
					_map[pos_i][pos_j] = {"ID": id, "Subtile": subtile}
	
					tiles_to_update.append([pos_i, pos_j])
	
					_has_been_modified = true
	else:
		if(i >= 0 and i < _height and j >= 0 and j < _width):
			if _get_tile_id(i, j) != id:
				_remove_subtiles(i, j)
				_map[i][j] = {"ID": id}

				tiles_to_update.append([i, j])

				_has_been_modified = true

	for tile_to_update in tiles_to_update:
		_update_tile(tile_to_update[0], tile_to_update[1])
		_update_tiles_around(tile_to_update[0], tile_to_update[1])


func change_tile_state(i: int, j: int):
	if(i >= 0 and i < _height and j >= 0 and j < _width):
		if get_tile(i, j).get_n_states() > 1:
			var state = ((_get_tile_state(i, j) + 1) %
						get_tile(i, j).get_n_states())

			for subtile in get_tile(i, j).get_subtiles(_get_tile_subtile(i, j)):
				var pos_i = i - subtile[1]
				var pos_j = j + subtile[0]

				_map[pos_i][pos_j].State = state
	
				_place_tile_image(pos_i, pos_j)
				
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
			_place_tile_image(i, j)


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


func _remove_subtiles(i: int, j: int):
	var tile = get_tile(i, j)
	var tiles_to_update = []

	if tile.is_a_multi_title():
		for subtile in tile.get_subtiles(_map[i][j].Subtile):
			var pos_i = i - subtile[1]
			var pos_j = j + subtile[0]

			if(pos_i >= 0 and pos_i < _height and pos_j >= 0
					and pos_j < _width):
				_map[pos_i][pos_j] = {"ID": Tile.Special_tile.AIR}

				tiles_to_update.append([pos_i, pos_j])

	for tile_to_update in tiles_to_update:
		_update_tile(tile_to_update[0], tile_to_update[1])
		_update_tiles_around(tile_to_update[0], tile_to_update[1])


func _update_tiles_around(i: int, j: int):
	_update_tile(i - 1, j)
	_update_tile(i - 1, j + 1)
	_update_tile(i, j + 1)
	_update_tile(i + 1, j + 1)
	_update_tile(i + 1, j)
	_update_tile(i + 1, j - 1)
	_update_tile(i, j - 1)
	_update_tile(i - 1, j - 1)


func _update_tile(i: int, j: int):
	if _get_tile_id(i, j) == Tile.Special_tile.OUT_OF_BOUNDS:
		pass
	elif get_tile(i, j).get_connection_type() == Tile.Connection_type.ISOLATED:
		_place_tile_image(i, j)
	else:
		var connection = 0
		var tile = get_tile(i, j)

		for subtile in tile.get_subtiles(_get_tile_subtile(i, j)):
			var pos_i = i - subtile[1]
			var pos_j = j + subtile[0]

			if(pos_i >= 0 and pos_i < _height and pos_j >= 0
					and pos_j < _width):
				if tile.get_connection_type() == Tile.Connection_type.CROSS:
					connection = _get_cross_connection(pos_i, pos_j)
				else:
					connection = _get_circle_connection(pos_i, pos_j)
				  
				var state = tile.get_state(connection)
				_map[pos_i][pos_j].State = state
		
				_place_tile_image(pos_i, pos_j)


func _get_cross_connection(i: int, j: int) -> int:
	var connection = 0

	var tile = get_tile(i, j)
	var subtile = _get_tile_subtile(i, j)

	var size = tile.get_structure_size()
	var x = size[0]
	var y = size[1]

	if subtile == _get_tile_subtile(i - x, j):
		connection += 1 if tile.can_connect_to(get_tile(i - x, j)) else 0

	if subtile == _get_tile_subtile(i, j + y):
		connection += 2 if tile.can_connect_to(get_tile(i, j + y)) else 0

	if subtile == _get_tile_subtile(i + x, j):
		connection += 4 if tile.can_connect_to(get_tile(i + x, j)) else 0

	if subtile == _get_tile_subtile(i, j - y):
		connection += 8 if tile.can_connect_to(get_tile(i, j - y)) else 0
	
	return connection


func _get_circle_connection(i: int, j: int) -> int:
	var connection = 0

	var tile = get_tile(i, j)
	var subtile = _get_tile_subtile(i, j)

	var size = tile.get_structure_size()
	var x = size[0]
	var y = size[1]

	if subtile == _get_tile_subtile(i - x, j):
		connection += 1   if tile.can_connect_to(get_tile(i - x, j)) else 0

	if subtile == _get_tile_subtile(i - x, j + y):
		connection += 2   if tile.can_connect_to(get_tile(i - x, j + y)) else 0

	if subtile == _get_tile_subtile(i, j + y):
		connection += 4   if tile.can_connect_to(get_tile(i, j + y)) else 0

	if subtile == _get_tile_subtile(i + x, j + y):
		connection += 8   if tile.can_connect_to(get_tile(i + x, j + y)) else 0

	if subtile == _get_tile_subtile(i + x, j):
		connection += 16  if tile.can_connect_to(get_tile(i + x, j)) else 0

	if subtile == _get_tile_subtile(i + x, j - y):
		connection += 32  if tile.can_connect_to(get_tile(i + x, j - y)) else 0

	if subtile == _get_tile_subtile(i, j - y):
		connection += 64  if tile.can_connect_to(get_tile(i, j - y)) else 0

	if subtile == _get_tile_subtile(i - x, j - y):
		connection += 128 if tile.can_connect_to(get_tile(i - x, j - y)) else 0

	return connection


func _place_tile_image(i: int, j: int):
	var state = _get_tile_state(i, j)
	var subtile = _get_tile_subtile(i, j)
	var tile_image = _tile_set[_get_tile_id(i, j)].get_image(state, subtile)
	var rect = Rect2(Vector2.ZERO, Vector2(_tile_size, _tile_size))
	var pos = Vector2(j * _tile_size, i * _tile_size)

	_image.blit_rect(tile_image, rect, pos)


func _get_tile_id(i: int, j: int) -> int:
	return get_tile(i, j).get_id()


func _get_tile_state(i: int, j: int) -> int:
	if(i >= 0 and i < _height and j >= 0 and j < _width):
		if _map[i][j].has("State"):
			return _map[i][j].State

	return 0


func _get_tile_subtile(i: int, j: int) -> Array:
	if(i >= 0 and i < _height and j >= 0 and j < _width):
		if _map[i][j].has("Subtile"):
			return _map[i][j].Subtile

	return [0, 0]
