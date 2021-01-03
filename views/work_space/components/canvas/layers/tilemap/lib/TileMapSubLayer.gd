class_name TMM_TileMapSubLayer


var size := [1, 1] setget set_size

var _map := [[]]


func width() -> int:
	return size[0]


func height() -> int:
	return size[1]


func get_tile_description(i: int, j: int) -> Dictionary:
	if i < 0 or j < 0 or i >= height() or j >= width():
		return {"id": TMM_Tile.SpecialTile.OUT_OF_BOUNDS}

	return _map[i][j]


func get_tile_structure_id(i: int, j: int) -> int:
	var tile_description = get_tile_description(i, j)

	assert(tile_description.has("id"))

	return tile_description.id


func get_autotiling_state(i: int, j: int) -> int:
	var tile_description = get_tile_description(i, j)

	if tile_description.has("autotiling_state"):
		return tile_description.autotiling_state

	return 0


func get_relative_pos(i: int, j: int) -> Array:
	var tile_description = get_tile_description(i, j)

	if tile_description.has("relative_pos"):
		return tile_description.relative_pos

	return [0, 0]


func set_size(new_size: Array) -> void:
	assert(new_size.size() == 2)
	for value in new_size:
		assert(value is int)
		assert(value >= 1)

	size = new_size

	_resize_map()


func _resize_map() -> void:
	_map = []
	for i in range(height()):
		_map.append([])
		for j in range(width()):
			_map[i].append([])
			_map[i][j] = {"id": TMM_Tile.SpecialTile.AIR}
