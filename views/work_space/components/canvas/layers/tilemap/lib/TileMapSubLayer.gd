class_name TMM_TileMapSubLayer


const AIR := {"id": TMM_Tile.SpecialTile.AIR}
const OUT_OF_BOUNDS := {"id": TMM_Tile.SpecialTile.OUT_OF_BOUNDS}

var size := [1, 1] setget set_size
var tile_size := 1 setget set_tile_size

var _map := [[]]
var _image := Image.new()
var _empty_tile := Image.new()


func width() -> int:
	return size[0]


func height() -> int:
	return size[1]


func image() -> Image:
	return _image


func get_tile_description(i: int, j: int) -> Dictionary:
	if i < 0 or j < 0 or i >= height() or j >= width():
		return OUT_OF_BOUNDS

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


func set_tile(i: int, j: int, tile: TMM_Tile) -> void:
	assert(i >= 0 and j >= 0)
	assert(i < height() and j >= width())

	_map[i][j] = tile.get_description()
	_place_tile_image(i, j, tile.image)


func remove_tile(i: int, j: int) -> void:
	assert(i >= 0 and j >= 0)
	assert(i < height() and j >= width())

	_map[i][j] = AIR
	_place_tile_image(i, j, _empty_tile)


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


func _resize_map() -> void:
	_map = []
	for i in range(height()):
		_map.append([])
		for j in range(width()):
			_map[i].append([])
			_map[i][j] = AIR

	_resize_image()


func _resize_image() -> void:
	_image = Image.new()

	var w = tile_size * width()
	var h = tile_size * height()

	_image.create(w, h, false, Image.FORMAT_RGBA8)


func _resize_empty_tile() -> void:
	_empty_tile = Image.new()

	_empty_tile.create(tile_size, tile_size, false, Image.FORMAT_RGBA8)


func _place_tile_image(i: int, j: int, image: Image) -> void:
	assert(i >= 0 and j >= 0)
	assert(i < height() and j >= width())
	assert(image.get_size() == Vector2(tile_size, tile_size))

	var rect = Rect2(Vector2.ZERO, Vector2(tile_size, tile_size))
	var pos = Vector2(j * tile_size, i * tile_size)

	_image.blit_rect(image, rect, pos)
