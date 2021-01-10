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
var connection_type : int = TMM_Tile.ConnectionType.ISOLATED setget set_connection_type
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


func get_tile(autotiling_state := 0, relative_pos := [0,  0]) -> TMM_Tile:
	assert(relative_pos.size() == 2)
	for i in range(2):
		assert(relative_pos[i] is int)
		assert(relative_pos[i] >= 0 - main_tile[i])
		assert(relative_pos[i] < size[i] - main_tile[i])

	var tiles_matrix = _tiles[autotiling_state]
	var tile = tiles_matrix[relative_pos[0]][relative_pos[1]]

	assert(tile.tile_structure_id == id)
	assert(tile.autotiling_state == autotiling_state)
	assert(tile.relative_pos == relative_pos)

	return tile


func get_autotiling_state(connection_id: int) -> int:
	if _connection_id_to_autotiling_state.has(connection_id):
		return _connection_id_to_autotiling_state[connection_id]
	else:
		return 0


func get_tiles(autotiling_state := 0, tile_pos_ref := [0, 0]) -> Array:
	assert(tile_pos_ref.size() == 2)
	for value in tile_pos_ref:
		assert(value is int)

	var tiles_matrix = _tiles[autotiling_state]
	var tiles = []

	for i in tiles_matrix.keys():
		for j in tiles_matrix[i].keys():
			tiles.append(_duplicate(tiles_matrix[i][j], tile_pos_ref))

	return tiles


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
	assert(_is_trimmed(new_colission_mask))

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
		assert(TMM_TileMap.Tool.has(extra_tool))

	extra_tools = new_extra_tools


func set_connection_type(new_connection_type: int) -> void:
	assert(TMM_Tile.ConnectionType.values().has(new_connection_type))

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
				tile.relative_pos = [i, j]

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


func _duplicate(tile: TMM_Tile, pos_ref := [0, 0]) -> TMM_Tile:
	assert(pos_ref.size() == 2)
	for value in pos_ref:
		assert(value is int)

	var new_tile = TMM_Tile.new()

	new_tile.tile_structure_id = tile.tile_structure_id
	new_tile.autotiling_state = tile.autotiling_state
	new_tile.sub_layer = tile.sub_layer
	new_tile.relative_pos = [
		tile.relative_pos[0] - pos_ref[0],
		tile.relative_pos[1] - pos_ref[1]
	]
	new_tile.image = tile.image

	return new_tile


func _is_trimmed(new_colission_mask: Array) -> bool:
	# Check north side
	var at_least_one_true = false

	for north_values in new_colission_mask[0]:
		if north_values:
			at_least_one_true = true

	if not at_least_one_true:
		return false

	# Check east side
	at_least_one_true = false

	for row in new_colission_mask:
		if row[width() - 1]:
			at_least_one_true = true

	if not at_least_one_true:
		return false

	# Check south side
	at_least_one_true = false

	for south_values in new_colission_mask[height() - 1]:
		if south_values:
			at_least_one_true = true

	if not at_least_one_true:
		return false

	# Check west side
	at_least_one_true = false

	for row in new_colission_mask:
		if row[0]:
			at_least_one_true = true

	if not at_least_one_true:
		return false

	return true
