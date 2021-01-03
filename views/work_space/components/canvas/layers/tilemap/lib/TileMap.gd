class_name TMM_TileMap


enum Tool{
	PENCIL,
	WRENCH,
	ERASER,
	BUCKET_FILL
}


var size := [1, 1] setget set_size

var _layers := []


func width() -> int:
	return size[0]


func height() -> int:
	return size[1]


func get_layer(layer_id: int) -> TMM_TileMapLayer:
	assert(layer_id >= 0)
	assert(layer_id < _layers.size())

	return _layers[layer_id]


func set_size(new_size: Array) -> void:
	assert(new_size.size() == 2)
	for value in new_size:
		assert(value is int)
		assert(value >= 1)

	size = new_size

	for layer in _layers:
		layer.set_size(new_size)


func add_layer() -> void:
	var layer = TMM_TileMapLayer.new()
	layer.set_size(size)

	_layers.append(layer)
