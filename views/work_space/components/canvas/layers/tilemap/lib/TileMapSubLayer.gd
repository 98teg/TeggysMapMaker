class_name TMM_TileMapSubLayer


const AIR := {"id": TMM_TileMapEnum.SpecialTile.AIR}

var size := [1, 1] setget set_size
var tile_size := 1 setget set_tile_size

var _map := [[]]
var _image := Image.new()
var _empty_tile := Image.new()
var _has_been_modified := false
var _prev_map := [[]]


func width() -> int:
	return size[0]


func height() -> int:
	return size[1]


func image() -> Image:
	return _image


func is_in_bounds(i: int, j: int) -> bool:
	return i >= 0 and i < height() and j >= 0 and j < width()


func has_air(i: int, j: int) -> bool:
	assert(is_in_bounds(i, j))

	return get_tile_description(i, j).hash() == AIR.hash()


func has_tile(i: int, j: int, tile: TMM_Tile) -> bool:
	assert(is_in_bounds(i, j))

	return tile.get_description().hash() == get_tile_description(i, j).hash()


func has_been_modified() -> bool:
	return _has_been_modified


func get_tile_description(i: int, j: int) -> Dictionary:
	assert(is_in_bounds(i, j))

	var tile_description = _map[i][j]

	if not tile_description.has("autotiling_state"):
		tile_description["autotiling_state"] = 0

	if not tile_description.has("relative_coord"):
		tile_description["relative_coord"] = [0, 0]

	return tile_description


func set_size(new_size: Array) -> void:
	assert(new_size.size() == 2)
	for value in new_size:
		assert(value is int)
		assert(value >= 1)

	size = new_size

	_resize_map()


func set_tile_size(new_tile_size: int) -> void:
	assert(new_tile_size > 0)

	tile_size = new_tile_size

	_resize_image()
	_resize_empty_tile()


func set_tile(i: int, j: int, tile: TMM_Tile) -> void:
	assert(is_in_bounds(i, j))

	_map[i][j] = tile.get_description()
	_has_been_modified = true

	_place_tile_image(i, j, tile.image)


func remove_tile(i: int, j: int) -> void:
	assert(is_in_bounds(i, j))

	_map[i][j] = AIR
	_has_been_modified = true

	_place_tile_image(i, j, _empty_tile)


func retrieve_prev_map() -> Array:
	var prev_map = _prev_map
	_prev_map = _map.duplicate(true)

	_has_been_modified = false

	return prev_map


func load_map(tile_set: TMM_TileSet, map: Array) -> void:
	_map = map
	_has_been_modified = true
	
	for i in height():
		for j in width():
			if has_air(i, j):
				_place_tile_image(i, j, _empty_tile)
			else:
				var tile = tile_set.get_tile(get_tile_description(i, j))
				_place_tile_image(i, j, tile.image)


func _resize_map() -> void:
	_map = []
	for i in range(height()):
		_map.append([])
		for j in range(width()):
			_map[i].append([])
			_map[i][j] = AIR

	if _prev_map == [[]]:
		_prev_map = _map.duplicate(true)
	else:
		_has_been_modified = true

	_resize_image()


func _resize_image() -> void:
	_image = Image.new()

	var w = tile_size * width()
	var h = tile_size * height()

	_image.create(w, h, false, Image.FORMAT_RGBA8)


func _resize_empty_tile() -> void:
	_empty_tile = Image.new()

	_empty_tile.create(tile_size, tile_size, false, Image.FORMAT_RGBA8)


func _place_tile_image(i: int, j: int, tile_image: Image) -> void:
	assert(is_in_bounds(i, j))
	assert(tile_image.get_size() == Vector2(tile_size, tile_size))

	var rect = Rect2(Vector2.ZERO, Vector2(tile_size, tile_size))
	var pos = Vector2(j * tile_size, i * tile_size)

	_image.blit_rect(tile_image, rect, pos)
