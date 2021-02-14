class_name TMM_TileMapController


var _tile_map := TMM_TileMap.new()
var _tile_set := TMM_TileSet.new()
var _selected_tile_structure : TMM_TileStructure
var _has_been_modified := false
var _update_buffer := TMM_TileUpdateBuffer.new()
var _placed_tiles := {}


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


func get_tile_set() -> TMM_TileSet:
	return _tile_set


func select_tile(tile_structure_id: int) -> void:
	assert(tile_structure_id >= 0)
	assert(tile_structure_id < _tile_set.n_of_tiles())

	_selected_tile_structure = _tile_set.get_tile_structure(tile_structure_id)


func place_tile(i: int, j: int) -> void:
	_set_tile_structure(_selected_tile_structure, i, j)

	_update_tiles()


func reset_placed_tiles() -> void:
	_placed_tiles = {}


func collide_with_last_paced_tile(i: int, j: int) -> bool:
	for tile in _selected_tile_structure.get_tiles():
		var tile_hash = {
			"sub_layer": tile.sub_layer,
			"i": i + tile.relative_coord[0],
			"j": j + tile.relative_coord[1]
		}.hash()
		
		if _placed_tiles.has(tile_hash):
			return true
	return false


func erase_tile(i: int, j: int) -> void:
	var selected_layer = _tile_map.get_layer(_selected_tile_structure.layer)
	_remove_tile_structure(selected_layer, i, j)

	_update_tiles()


func fill(i: int, j: int) -> void:
	_fill_with_tile_structure(_selected_tile_structure, i, j)

	_update_tiles()


func change_tile_state(i: int, j: int) -> void:
	_change_tile_structure_autotiling_state(_selected_tile_structure, i, j)


func erase_tile_in_every_layer(i: int, j: int) -> void:
	for layer in _tile_map.n_of_layers():
		_remove_tile_structure(_tile_map.get_layer(layer), i, j)

	_update_tiles()


func retrieve_previous_tilemap() -> Dictionary:
	return _tile_map.retrieve_prev_map()


func load_tilemap(tilemaplayers: Dictionary) -> void:
	_tile_map.load_map(_tile_set, tilemaplayers)


func _set_tile_structure(tile_structure: TMM_TileStructure, i: int, j: int,
		autotiling_enabled := true, autotiling_state := 0,
		coord_ref := [0, 0]) -> void:
	var layer = _tile_map.get_layer(tile_structure.layer)

	for tile in tile_structure.get_tiles(autotiling_state):
		var relative_i = i - coord_ref[0] + tile.relative_coord[0]
		var relative_j = j - coord_ref[1] + tile.relative_coord[1]

		_set_tile(layer, tile, relative_i, relative_j, autotiling_enabled)


func _set_tile(layer: TMM_TileMapLayer, tile: TMM_Tile, i: int, j: int,
		autotiling_enabled := true) -> void:
	if layer.is_in_bounds(i, j):
		var sub_layer = layer.get_sub_layer(tile.sub_layer)
	
		if not sub_layer.has_tile(i, j, tile):
			_remove_tile_structure(layer, i, j, autotiling_enabled)
			sub_layer.set_tile(i, j, tile)
			_add_placed_tile(tile.sub_layer, i, j)
			_has_been_modified = true

			if autotiling_enabled:
				_update_buffer.add_tiles_around(layer.id, tile.sub_layer, i, j)

		if not autotiling_enabled:
			_update_buffer.remove_tile(layer.id, tile.sub_layer, i, j)


func _add_placed_tile(sub_layer: int, i: int, j: int) -> void:
	var placed_tile = {"sub_layer": sub_layer, "i": i, "j": j}
	if not _placed_tiles.has(placed_tile.hash()):
		_placed_tiles[placed_tile.hash()] = true


func _remove_tile_structure(layer: TMM_TileMapLayer, i: int, j: int,
		autotiling_enabled := true) -> void:
	if not layer.is_in_bounds(i, j):
		return

	if layer.has_air(i, j):
		return

	var tile_description = layer.get_sub_layer(0).get_tile_description(i, j)
	var tile_structure = _tile_set.get_tile_structure(tile_description.id)

	var coord_ref = tile_description.relative_coord

	for tile in tile_structure.get_tiles():
		var relative_i = i - coord_ref[0] + tile.relative_coord[0]
		var relative_j = j - coord_ref[1] + tile.relative_coord[1]

		_remove_tile(layer, tile, relative_i, relative_j, autotiling_enabled)


func _remove_tile(layer: TMM_TileMapLayer, tile: TMM_Tile, i: int, j: int,
		autotiling_enabled := true) -> void:
	if layer.is_in_bounds(i, j):
		var sub_layer = layer.get_sub_layer(tile.sub_layer)

		if not sub_layer.has_air(i, j):
			sub_layer.remove_tile(i, j)
			_has_been_modified = true
			
			if autotiling_enabled:
				_update_buffer.add_tiles_around(layer.id, tile.sub_layer, i, j)


func _fill_with_tile_structure(tile_structure: TMM_TileStructure, i: int,
		j: int) -> void:
	if not _tile_map.is_in_bounds(i, j):
		return

	var layer = _tile_map.get_layer(tile_structure.layer)
	var tile_structure_to_replace_id = layer.get_top_tile_description(i, j).id

	if tile_structure_to_replace_id == tile_structure.id:
		return

	var place_now = []

	if _can_tile_structure_be_placed(layer, tile_structure_to_replace_id, i, j):
		place_now.append([i, j])
	else:
		return

	var w = tile_structure.width()
	var h = tile_structure.height()

	var marked = TMM_TileMapHelper.create_matrix(
		_tile_map.width(), _tile_map.height(), false
	)

	while place_now.size() != 0:
		var place_next = []

		for coord in place_now:
			_set_tile_structure(tile_structure, coord[0], coord[1])

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
		var relative_i = i + tile.relative_coord[0]
		var relative_j = j + tile.relative_coord[1]

		if _tile_map.is_in_bounds(relative_i, relative_j):
			var sub_layer = layer.get_sub_layer(tile.sub_layer)
			var top_tile_structure = sub_layer.get_tile_description(relative_i,
				relative_j)
			if top_tile_structure.id != tile_structure_to_replace_id:
				return false
	return true


func _change_tile_structure_autotiling_state(tile_structure: TMM_TileStructure, 
		i: int, j: int) -> void:
	var layer = _tile_map.get_layer(tile_structure.layer)

	if not layer.is_in_bounds(i, j) or layer.has_air(i, j):
		return

	var tile_description = layer.get_top_tile_description(i, j)

	if tile_description.id != tile_structure.id:
		return

	var new_autotiling_state = tile_description.autotiling_state + 1
	new_autotiling_state %= tile_structure.n_autotiling_states()

	_set_tile_structure(
		tile_structure, i, j, false, new_autotiling_state,
		tile_description.relative_coord
	)


func _update_tiles() -> void:
	_update_buffer.start_updating()

	while _update_buffer.has_next():
		_update_tile(_update_buffer.next())

	_update_buffer.finish()


func _update_tile(tile: Dictionary) -> void:
	var layer = _tile_map.get_layer(tile.layer)
	var sub_layer = layer.get_sub_layer(tile.sub_layer)
	var i = tile.i
	var j = tile.j

	if not sub_layer.is_in_bounds(i, j) or sub_layer.has_air(i, j):
		return

	var tile_description = sub_layer.get_tile_description(i, j)
	var tile_structure = _tile_set.get_tile_structure(tile_description.id)

	var relative_coord = tile_description.relative_coord
	var autotiling_state = tile_structure.get_autotiling_state(
		_get_connections(layer, tile_structure, relative_coord, i, j)
	)

	_set_tile_structure(
		tile_structure, i, j, false, autotiling_state, relative_coord
	)


func _get_connections(layer: TMM_TileMapLayer, tile_structure: TMM_TileStructure,
		relative_coord: Array, i: int, j: int) -> Dictionary:
	var connected_at = {}

	var coords_to_check = tile_structure.coords_to_check(relative_coord, i, j)
	for key in coords_to_check.keys():
		var value = _connected_at(layer, coords_to_check[key], tile_structure)
		connected_at[key] = value

	return connected_at


func _connected_at(layer: TMM_TileMapLayer, coords_array: Array,
		tile_structure: TMM_TileStructure) -> bool:
	for coords in coords_array:
		var sub_layer = layer.get_sub_layer(coords.sub_layer)
		if not _can_connect_at(sub_layer, coords.i, coords.j, tile_structure):
			return false

	return true


func _can_connect_at(sub_layer: TMM_TileMapSubLayer, i: int, j: int,
		tile_structure: TMM_TileStructure) -> bool:	
	if not sub_layer.is_in_bounds(i, j):
		return tile_structure.can_connect_to_borders

	if sub_layer.has_air(i, j):
		return false

	var id = sub_layer.get_tile_description(i, j).id
	var another = _tile_set.get_tile_structure(id)

	return tile_structure.can_connect_to(another)
