class_name TMM_TileStructure


var id := 0
var name := ""
var icon := Image.new()
var tile_size := 1 setget set_tile_size
var layer := 0 setget set_layer
var size := [1, 1] setget set_size
var colission_mask := [[true]] setget set_colission_mask
var main_tile := [0, 0] setget set_main_tile
var extra_tools := [] setget set_extra_tools
var connection_type : int = TMM_TileMapHelper.ConnectionType.ISOLATED setget set_connection_type
var connected_group := 0
var can_connect_to_borders := true

var _tiles := []
var _connection_id_to_autotiling_state := {}


func width() -> int:
	return size[0]


func height() -> int:
	return size[1]


func n_autotiling_states() -> int:
	return _tiles.size()


func has_multiple_tiles() -> bool:
	return size != [1, 1]


func get_tile(autotiling_state := 0, relative_coord := [0,  0]) -> TMM_Tile:
	assert(relative_coord.size() == 2)
	assert(relative_coord[0] is int)
	assert(relative_coord[0] > 0 - height())
	assert(relative_coord[0] < height() - main_tile[1])
	assert(relative_coord[1] is int)
	assert(relative_coord[1] > 0 - width())
	assert(relative_coord[1] < width() - main_tile[0])

	var tiles_matrix = _tiles[autotiling_state]
	var tile = tiles_matrix[relative_coord[0]][relative_coord[1]]

	assert(tile.tile_structure_id == id)
	assert(tile.autotiling_state == autotiling_state)
	assert(tile.relative_coord == relative_coord)

	return tile


func get_autotiling_state(connected_at: Dictionary) -> int:
	var connection_id = TMM_TileMapHelper.get_connection_id(connection_type,
		connected_at)

	if _connection_id_to_autotiling_state.has(connection_id):
		return _connection_id_to_autotiling_state[connection_id]
	else:
		return 0


func get_tiles(autotiling_state := 0) -> Array:
	var tiles_matrix = _tiles[autotiling_state]
	var tiles = []

	for i in tiles_matrix.keys():
		for j in tiles_matrix[i].keys():
			tiles.append(tiles_matrix[i][j])

	return tiles


func coords_to_check_n(relative_coord: Array, i: int, j: int) -> Array:
	return _coords_to_check(_colission_mask_n(),
		_get_nw_i(relative_coord[0], i), _get_nw_j(relative_coord[1], j),
		-1, 0, 0, 1)


func coords_to_check_ne(relative_coord: Array, i: int, j: int) -> Array:
	return _coords_to_check(_colission_mask_ne(),
		_get_nw_i(relative_coord[0], i), _get_nw_j(relative_coord[1], j),
		-1, 0, width(), 0)


func coords_to_check_e(relative_coord: Array, i: int, j: int) -> Array:
	return _coords_to_check(_colission_mask_e(),
		_get_nw_i(relative_coord[0], i), _get_nw_j(relative_coord[1], j),
		0, 1, width(), 0)


func coords_to_check_se(relative_coord: Array, i: int, j: int) -> Array:
	return _coords_to_check(_colission_mask_se(),
		_get_nw_i(relative_coord[0], i), _get_nw_j(relative_coord[1], j),
		height(), 0, width(), 0)


func coords_to_check_s(relative_coord: Array, i: int, j: int) -> Array:
	return _coords_to_check(_colission_mask_s(),
		_get_nw_i(relative_coord[0], i), _get_nw_j(relative_coord[1], j),
		height(), 0, 0, 1)


func coords_to_check_sw(relative_coord: Array, i: int, j: int) -> Array:
	return _coords_to_check(_colission_mask_sw(),
		_get_nw_i(relative_coord[0], i), _get_nw_j(relative_coord[1], j),
		height(), 0, -1, 0)


func coords_to_check_w(relative_coord: Array, i: int, j: int) -> Array:
	return _coords_to_check(_colission_mask_w(),
		_get_nw_i(relative_coord[0], i), _get_nw_j(relative_coord[1], j),
		0, 1, -1, 0)


func coords_to_check_nw(relative_coord: Array, i: int, j: int) -> Array:
	return _coords_to_check(_colission_mask_nw(),
		_get_nw_i(relative_coord[0], i), _get_nw_j(relative_coord[1], j),
		-1, 0, -1, 0)


func set_tile_size(new_tile_size: int) -> void:
	assert(new_tile_size > 0)

	tile_size = new_tile_size


func set_layer(new_layer: int) -> void:
	assert(new_layer >= 0)

	layer = new_layer


func set_size(new_size: Array) -> void:
	assert(new_size.size() == 2)
	for value in new_size:
		assert(value is int)
		assert(value > 0)

	size = new_size


func set_colission_mask(new_colission_mask: Array) -> void:
	assert(new_colission_mask.size() == height())
	for row in new_colission_mask:
		assert(row is Array)
		assert(row.size() == width())
		for value in row:
			assert(value is bool)
	assert(TMM_TileMapHelper.is_trimmed(new_colission_mask))

	colission_mask = new_colission_mask


func set_main_tile(new_main_tile: Array) -> void:
	assert(new_main_tile.size() == 2)
	for i in range(2):
		assert(new_main_tile[i] is int)
		assert(new_main_tile[i] >= 0)
		assert(new_main_tile[i] < size[i])

	main_tile = new_main_tile


func set_extra_tools(new_extra_tools: Array) -> void:
	for extra_tool in new_extra_tools:
		assert(TMM_TileMapHelper.Tool.values().has(extra_tool))

	extra_tools = new_extra_tools


func set_connection_type(new_connection_type: int) -> void:
	assert(TMM_TileMapHelper.ConnectionType.values().has(new_connection_type))

	connection_type = new_connection_type


func add_autotiling_state(image: Image, connection_ids: Array = []) -> void:
	var autotiling_state = n_autotiling_states()

	var tiles_matrix = {}

	for x in range(width()):
		for y in range(height()):
			if colission_mask[height() - 1 - y][x]:
				var tile = TMM_Tile.new()
				tile.tile_structure_id = id
				tile.autotiling_state = autotiling_state
				tile.sub_layer = 0

				var i = - y - main_tile[1]
				var j = x - main_tile[0]
				tile.relative_coord = [i, j]

				var pos_x = x * tile_size
				var pos_y = image.get_size().y - (tile_size * (y + 1))
				var pos = Vector2(pos_x, pos_y)
				var rect = Rect2(pos, Vector2(tile_size, tile_size))
				tile.image = image.get_rect(rect)

				if not tiles_matrix.has(i):
					tiles_matrix[i] = {}

				tiles_matrix[i][j] = tile

	for connection_id in connection_ids:
		_connection_id_to_autotiling_state[connection_id] = autotiling_state
	
	_tiles.append(tiles_matrix)


func _coords_to_check(colission_mask: Array, nw_i: int, nw_j: int,
		i_offset: int, i_index_factor: int,
		j_offset: int, j_index_factor: int) -> Array:
	var coords_to_check = []

	var i_0 = main_tile[1] - (height() - 1)
	i_0 += height() - 1 if i_offset == height() else 0
	var j_0 = - main_tile[0]
	j_0 += width() - 1 if j_offset == width() else 0

	for index in colission_mask.size():
		var coords = {}

		if colission_mask[index]:
			coords["i"] = nw_i + i_offset + index * i_index_factor
			coords["j"] = nw_j + j_offset + index * j_index_factor
			coords["sub_layer"] = get_tile(0, [
				i_0 + index * i_index_factor,
				j_0 + index * j_index_factor
			]).sub_layer

			coords_to_check.append(coords)

	return coords_to_check


func _get_nw_i(relative_coord_i: int, i: int) -> int:
	var main_tile_i = i - relative_coord_i
	var nw_i = main_tile_i + main_tile[1] - (height() - 1)
	return nw_i


func _get_nw_j(relative_coord_j: int, j: int) -> int:
	var main_tile_j = j - relative_coord_j
	var nw_j = main_tile_j - main_tile[0]
	return nw_j 


func _colission_mask_n() -> Array:
	return colission_mask[0]


func _colission_mask_ne() -> Array:
	return [colission_mask[0][width() - 1]]


func _colission_mask_e() -> Array:
	var east_colission_mask = []

	for row in colission_mask:
		east_colission_mask.append(row[width() - 1])

	return east_colission_mask


func _colission_mask_se() -> Array:
	return [colission_mask[height() - 1][width() - 1]]


func _colission_mask_s() -> Array:
	return colission_mask[height() - 1]


func _colission_mask_sw() -> Array:
	return [colission_mask[height() - 1][0]]


func _colission_mask_w() -> Array:
	var west_colission_mask = []

	for row in colission_mask:
		west_colission_mask.append(row[0])

	return west_colission_mask


func _colission_mask_nw() -> Array:
	return [colission_mask[0][0]]
