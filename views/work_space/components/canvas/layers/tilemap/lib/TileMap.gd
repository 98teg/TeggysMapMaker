class_name TMM_TileMap


var size := [1, 1] setget set_size
var tile_size := 1 setget set_tile_size
var background_tile_image := Image.new() setget set_background_tile_image

var _layers := []
var _background := Image.new()


func width() -> int:
	return size[0]


func height() -> int:
	return size[1]


func image() -> Image:
	var image = Image.new()
	image.copy_from(_background)

	if _layers.size() == 0:
		return image

	var pos = Vector2.ZERO
	var rect = Rect2(pos, image.get_size())

	for i in range(_layers.size()):
		image.blend_rect(get_layer(i).image(), rect, pos)

	return image


func is_in_bounds(i: int, j: int) -> bool:
	return i >= 0 and i < height() and j >= 0 and j < width()


func n_of_layers() -> int:
	return _layers.size()


func get_layer(layer_id: int) -> TMM_TileMapLayer:
	assert(layer_id >= 0)
	assert(layer_id < _layers.size())

	return _layers[layer_id]


func set_size(new_size: Array) -> void:
	assert(new_size.size() == 2)
	for value in new_size:
		assert(value is int)
		assert(value > 0)

	size = new_size

	for layer in _layers:
		layer.size = new_size

	_resize_background()


func set_tile_size(new_tile_size: int) -> void:
	assert(new_tile_size > 0)

	tile_size = new_tile_size

	for layer in _layers:
		layer.tile_size = new_tile_size

	_resize_background()


func set_background_tile_image(new_background_tile_image: Image) -> void:
	assert(new_background_tile_image.get_size() == Vector2(tile_size,
			tile_size))

	background_tile_image = new_background_tile_image

	_fill_background()


func add_layer() -> void:
	var layer = TMM_TileMapLayer.new()
	layer.size = size
	layer.tile_size = tile_size

	_layers.append(layer)


func _resize_background() -> void:
	_background = Image.new()

	var w = tile_size * width()
	var h = tile_size * height()

	_background.create(w, h, false, Image.FORMAT_RGBA8)

	if not background_tile_image.is_empty():
		_fill_background()


func _fill_background() -> void:
	var rect = Rect2(Vector2.ZERO, Vector2(tile_size, tile_size))

	var pos
	for x in range(width()):
		for y in range(height()):
			pos = Vector2(x * tile_size, y * tile_size)
			_background.blend_rect(background_tile_image, rect, pos)
