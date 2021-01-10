class_name TMM_TileMapLayer


var size := [1, 1] setget set_size
var tile_size := 1 setget set_tile_size

var _sub_layers := []


func width() -> int:
	return size[0]


func height() -> int:
	return size[1]


func image() -> Image:
	assert(_sub_layers.size() > 0)

	var image = Image.new()
	image.copy_from(get_sub_layer(0).image())

	var pos = Vector2.ZERO
	var rect = Rect2(pos, image.get_size())

	for i in range(1, _sub_layers.size()):
		image.blend_rect(get_sub_layer(i).image(), rect, pos)

	return image


func is_in_bounds(i: int, j: int) -> bool:
	return i >= 0 and i < height() and j >= 0 and j < width()


func has_air(i: int, j: int) -> bool:
	assert(is_in_bounds(i, j))

	for sub_layer in _sub_layers:
		if not sub_layer.has_air(i, j):
			return false

	return true


func get_sub_layer(sub_layer_id: int) -> TMM_TileMapSubLayer:
	assert(sub_layer_id >= 0)
	assert(sub_layer_id < _sub_layers.size())

	return _sub_layers[sub_layer_id]


func get_top_tile_description(i: int, j: int) -> Dictionary:
	assert(is_in_bounds(i, j))

	for sub_layer_id in range(_sub_layers.size() - 1, 0, -1):
		if not get_sub_layer(sub_layer_id).has_air(i, j):
			return get_sub_layer(sub_layer_id).get_tile_description(i, j)

	return get_sub_layer(0).get_tile_description(i, j)


func set_size(new_size: Array) -> void:
	assert(new_size.size() == 2)
	for value in new_size:
		assert(value is int)
		assert(value > 0)

	size = new_size

	for sub_layer in _sub_layers:
		sub_layer.size = new_size


func set_tile_size(new_tile_size: int) -> void:
	assert(new_tile_size > 0)

	tile_size = new_tile_size

	for sub_layer in _sub_layers:
		sub_layer.tile_size = new_tile_size


func add_sub_layer() -> void:
	var sub_layer = TMM_TileMapSubLayer.new()
	sub_layer.size = size
	sub_layer.tile_size = tile_size

	_sub_layers.append(sub_layer)
