class_name TMM_TileMapController


var _tile_map := TMM_TileMap.new()
var _tile_set := TMM_TileSet.new()
var _selected_tile_structure : TMM_TileStructure
var _has_been_modified := false
var _tiles_to_update := []


func init(canvas_conf: Dictionary, layer_conf: Dictionary) -> void:
	_tile_map.size = [canvas_conf.Width, canvas_conf.Height]
	_tile_map.tile_size = layer_conf.TileSize
	_tile_map.background_tile_image = layer_conf.Background

	for i in layer_conf.NumberOfLayers:
		_tile_map.add_layer()

	for i in _tile_map.n_of_layers():
		_tile_map.get_layer(i).add_sub_layer()

	_tile_set.tile_size = layer_conf.TileSize
	_tile_set.init(layer_conf.TileSet)
	if _tile_set.n_of_tiles() != 0:
		_selected_tile_structure = _tile_set.get_tile_structure(0)


func get_image() -> Image:
	return _tile_map.image()


func select_tile(tile_structure_id: int) -> void:
	assert(tile_structure_id >= 0)
	assert(tile_structure_id < _tile_set.n_of_tiles())

	_selected_tile_structure = _tile_set.get_tile_structure(tile_structure_id)


func place_tile(i: int, j: int) -> void:
	var current_layer = _selected_tile_structure.layer
	_set_tile_structure(_tile_map.get_layer(current_layer), i, j)


func erase_tile(i: int, j: int) -> void:
	var current_layer = _selected_tile_structure.layer
	_remove_tile_structure(_tile_map.get_layer(current_layer), i, j)


func fill(i: int, j: int) -> void:
	var current_layer = _selected_tile_structure.layer
	_fill_with_tile_structure(_tile_map.get_layer(current_layer), i, j)


func change_tile_state(i: int, j: int) -> void:
	var current_layer = _selected_tile_structure.layer
	var layer = _tile_map.get_layer(current_layer)
	_change_tile_structure_autotiling_state(layer, i, j)


func erase_tile_in_every_layer(i: int, j: int) -> void:
	for layer in _tile_map.n_of_layers():
		_remove_tile_structure(_tile_map.get_layer(layer), i, j)


func retrieve_previous_tilemap() -> Dictionary:
	return _tile_map.retrieve_prev_map()


func load_tilemap(tilemaplayers: Dictionary) -> void:
	_tile_map.load_map(_tile_set, tilemaplayers)


func _set_tile_structure(layer: TMM_TileMapLayer, i: int, j: int) -> void:
	if _selected_tile_structure.has_multiple_tiles():
		for tile in _selected_tile_structure.get_tiles():
			var relative_i = i + tile.relative_pos[0]
			var relative_j = j + tile.relative_pos[1]

			if _set_tile(layer, relative_i, relative_j, tile):
				_tiles_to_update.append([i, j])
	else:
		var tile = _selected_tile_structure.get_tile()
		if _set_tile(layer, i, j, tile):
			_tiles_to_update.append([i, j])

	_update_tiles()


func _set_tile(layer: TMM_TileMapLayer, i: int, j: int, tile: TMM_Tile) -> bool:
	if layer.is_in_bounds(i, j):
		var sub_layer = layer.get_sub_layer(tile.sub_layer)
	
		if not sub_layer.has_tile(i, j, tile):
			_remove_tile_structure(layer, i, j)
			sub_layer.set_tile(i, j, tile)
			_has_been_modified = true

			return true
	return false


func _remove_tile_structure(layer: TMM_TileMapLayer, i: int, j: int) -> void:
	if layer.has_air(i, j):
		return

	var tile_description = layer.get_top_tile_description(i, j)
	var tile_structure = _tile_set.get_tile_structure(tile_description.id)

	if tile_structure.has_multiple_tiles():
		var pos_ref = tile_description.relative_pos

		for tile in tile_structure.get_tiles(0, pos_ref):
			var relative_i = i + tile.relative_pos[0]
			var relative_j = j + tile.relative_pos[1]

			if _remove_tile(layer, relative_i, relative_j, tile):
				_tiles_to_update.append([i, j])
	else:
		var tile = tile_structure.get_tile()
		if _remove_tile(layer, i, j, tile):
			_tiles_to_update.append([i, j])

	_update_tiles()


func _remove_tile(layer: TMM_TileMapLayer, i: int, j: int,
		tile: TMM_Tile) -> bool:
	if layer.is_in_bounds(i, j):
		layer.get_sub_layer(tile.sub_layer).remove_tile(i, j)
		_has_been_modified = true

		return true
	return false


func _fill_with_tile_structure(layer: TMM_TileMapLayer, i: int, j: int) -> void:
	if not _tile_map.is_in_bounds(i, j):
		return

	var sub_layer = layer.get_sub_layer(0)
	var tile_structure_to_replace_id = sub_layer.get_tile_description(i, j).id

	if tile_structure_to_replace_id == _selected_tile_structure.id:
		return

	var place_now = []

	if _can_tile_structure_be_placed(layer, tile_structure_to_replace_id, i, j):
		place_now.append([i, j])
	else:
		return

	var marked = _create_tile_map_bitmap()

	var w = _selected_tile_structure.width()
	var h = _selected_tile_structure.height()

	while place_now.size() != 0:
		var place_next = []

		for coord in place_now:
			_set_tile_structure(layer, coord[0], coord[1])

			_add_to_place_next(layer, tile_structure_to_replace_id,
				coord[0] + h, coord[1], place_next, marked)
			_add_to_place_next(layer, tile_structure_to_replace_id,
				coord[0], coord[1] + w, place_next, marked)
			_add_to_place_next(layer, tile_structure_to_replace_id,
				coord[0] - h, coord[1], place_next, marked)
			_add_to_place_next(layer, tile_structure_to_replace_id,
				coord[0], coord[1] - w, place_next, marked)

		place_now = place_next


func _add_to_place_next(layer: TMM_TileMapLayer,
		tile_structure_to_replace_id: int, i: int, j: int, place_next: Array,
		marked: Array) -> void:
	if not _tile_map.is_in_bounds(i, j):
		return

	if _can_tile_structure_be_placed(layer, tile_structure_to_replace_id, i, j):
		if not marked[i][j]:
			place_next.append([i, j])
			marked[i][j] = true


func _can_tile_structure_be_placed(layer: TMM_TileMapLayer,
		tile_structure_to_replace_id: int, i: int, j: int) -> bool:
	for tile in _selected_tile_structure.get_tiles():
		var relative_i = i + tile.relative_pos[0]
		var relative_j = j + tile.relative_pos[1]

		if _tile_map.is_in_bounds(relative_i, relative_j):
			var sub_layer = layer.get_sub_layer(tile.sub_layer)
			var top_tile_structure = sub_layer.get_tile_description(relative_i,
				relative_j)
			if top_tile_structure.id != tile_structure_to_replace_id:
				return false
	return true


func _create_tile_map_bitmap() -> Array:
	var bitmap = []

	for i in _tile_map.height():
		bitmap.append([])
		for j in _tile_map.width():
			bitmap[i].append([])
			bitmap[i][j] = false

	return bitmap


func _change_tile_structure_autotiling_state(layer: TMM_TileMapLayer, i: int,
		j: int) -> void:
	if layer.has_air(i, j):
		return

	var tile_description = layer.get_top_tile_description(i, j)

	if tile_description.id != _selected_tile_structure.id:
		return

	var tile_structure = _tile_set.get_tile_structure(tile_description.id)

	if tile_structure.has_multiple_tiles():
		var pos_ref = tile_description.relative_pos

		for tile in tile_structure.get_tiles(pos_ref):
			var relative_i = i + tile.relative_pos[0]
			var relative_j = j + tile.relative_pos[1]

			_change_tile_autotiling_state(layer, i, j, tile_structure,
				tile_description.autotiling_state, tile.relative_pos)
	else:
		_change_tile_autotiling_state(layer, i, j, tile_structure,
			tile_description.autotiling_state)


func _change_tile_autotiling_state(layer: TMM_TileMapLayer, i: int, j: int,
		tile_structure: TMM_TileStructure,
		prev_autotiling_state: int, relative_pos := [0, 0]) -> void:
	var new_autotiling_state = prev_autotiling_state + 1
	new_autotiling_state %= tile_structure.n_autotiling_states()

	var tile = tile_structure.get_tile(new_autotiling_state, relative_pos)

	_set_tile(layer, i, j, tile)


func _update_tiles() -> void:
	for tile_to_update in _tiles_to_update:
		_update_tiles_around(tile_to_update[0], tile_to_update[1])

	_tiles_to_update.clear()


func _update_tiles_around(i: int, j: int) -> void:
	_update_tile(i, j)
	_update_tile(i - 1, j)
	_update_tile(i - 1, j + 1)
	_update_tile(i, j + 1)
	_update_tile(i + 1, j + 1)
	_update_tile(i + 1, j)
	_update_tile(i + 1, j - 1)
	_update_tile(i, j - 1)
	_update_tile(i - 1, j - 1)


func _update_tile(i: int, j: int) -> void:
	pass
#	if _get_tile_id(i, j) == Tile.SpecialTile.OUT_OF_BOUNDS:
#		pass
#	elif get_tile(i, j).get_connection_type() == Tile.ConnectionType.ISOLATED:
#		_place_tile_image(i, j)
#	else:
#		var connection = 0
#		var tile = get_tile(i, j)
#
#		for subtile in tile.get_subtiles(_get_tile_subtile(i, j)):
#			var pos_i = i - subtile[1]
#			var pos_j = j + subtile[0]
#
#			if(pos_i >= 0 and pos_i < _height and pos_j >= 0
#					and pos_j < _width):
#				if tile.get_connection_type() == Tile.ConnectionType.CROSS:
#					connection = _get_cross_connection(pos_i, pos_j)
#				else:
#					connection = _get_circle_connection(pos_i, pos_j)
#
#				var state = tile.get_state(connection)
#				_map[pos_i][pos_j].State = state
#
#				_place_tile_image(pos_i, pos_j)


### TileMapSubLayer

func _get_cross_connection(i: int, j: int) -> int:
	var connection = 0

#	var tile = get_tile(i, j)
#	var subtile = _get_tile_subtile(i, j)
#
#	var size = tile.get_structure_size()
#	var x = size[0]
#	var y = size[1]
#
#	if subtile == _get_tile_subtile(i - x, j):
#		connection += 1 if tile.can_connect_to(get_tile(i - x, j)) else 0
#
#	if subtile == _get_tile_subtile(i, j + y):
#		connection += 2 if tile.can_connect_to(get_tile(i, j + y)) else 0
#
#	if subtile == _get_tile_subtile(i + x, j):
#		connection += 4 if tile.can_connect_to(get_tile(i + x, j)) else 0
#
#	if subtile == _get_tile_subtile(i, j - y):
#		connection += 8 if tile.can_connect_to(get_tile(i, j - y)) else 0
	
	return connection


func _get_circle_connection(i: int, j: int) -> int:
	var connection = 0
#
#	var tile = get_tile(i, j)
#	var subtile = _get_tile_subtile(i, j)
#
#	var size = tile.get_structure_size()
#	var x = size[0]
#	var y = size[1]
#
#	if subtile == _get_tile_subtile(i - x, j):
#		connection += 1   if tile.can_connect_to(get_tile(i - x, j)) else 0
#
#	if subtile == _get_tile_subtile(i - x, j + y):
#		connection += 2   if tile.can_connect_to(get_tile(i - x, j + y)) else 0
#
#	if subtile == _get_tile_subtile(i, j + y):
#		connection += 4   if tile.can_connect_to(get_tile(i, j + y)) else 0
#
#	if subtile == _get_tile_subtile(i + x, j + y):
#		connection += 8   if tile.can_connect_to(get_tile(i + x, j + y)) else 0
#
#	if subtile == _get_tile_subtile(i + x, j):
#		connection += 16  if tile.can_connect_to(get_tile(i + x, j)) else 0
#
#	if subtile == _get_tile_subtile(i + x, j - y):
#		connection += 32  if tile.can_connect_to(get_tile(i + x, j - y)) else 0
#
#	if subtile == _get_tile_subtile(i, j - y):
#		connection += 64  if tile.can_connect_to(get_tile(i, j - y)) else 0
#
#	if subtile == _get_tile_subtile(i - x, j - y):
#		connection += 128 if tile.can_connect_to(get_tile(i - x, j - y)) else 0

	return connection
