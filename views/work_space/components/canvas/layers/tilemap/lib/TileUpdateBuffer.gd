class_name TMM_TileUpdateBuffer


var _tiles_to_update := {}
var _tiles_updated := {}
var _keys := []
var _index := 0


func add_tiles_around(layer: int, sub_layer: int, i: int, j: int) -> void:
	_add(layer, sub_layer, i, j)
	_add(layer, sub_layer, i - 1, j)
	_add(layer, sub_layer, i - 1, j + 1)
	_add(layer, sub_layer, i, j + 1)
	_add(layer, sub_layer, i + 1, j + 1)
	_add(layer, sub_layer, i + 1, j)
	_add(layer, sub_layer, i + 1, j - 1)
	_add(layer, sub_layer, i, j - 1)
	_add(layer, sub_layer, i - 1, j - 1)


func remove_tile(layer: int, sub_layer: int, i: int, j: int) -> void:
	_add_tile_to(_tiles_updated, layer, sub_layer, i, j)


func start_updating() -> void:
	_tiles_updated.clear()
	_keys = _tiles_to_update.keys()
	_index = 0


func has_next() -> bool:
	while _index < _keys.size():
		if not _tiles_updated.has(_keys[_index]):
			return true
		_index += 1
	return false


func next() -> Dictionary:
	assert(has_next())

	var tile = _tiles_to_update[_keys[_index]]
	_index += 1

	return tile


func finish() -> void:
	_tiles_to_update.clear()


func _add(layer: int, sub_layer: int, i: int, j: int) -> void:
	_add_tile_to(_tiles_to_update, layer, sub_layer, i, j) 


func _add_tile_to(buffer: Dictionary, layer: int, sub_layer: int, i: int,
		j: int) -> void:
	var tile = {"layer": layer, "sub_layer": sub_layer, "i": i, "j": j}

	buffer[tile.hash()] = tile
