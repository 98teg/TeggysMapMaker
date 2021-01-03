class_name TMM_TileMapLayer


var size := [1, 1] setget set_size

var _sub_layers := []


func width() -> int:
	return size[0]


func height() -> int:
	return size[1]


func get_sub_layer(sub_layer_id: int) -> TMM_TileMapSubLayer:
	assert(sub_layer_id >= 0)
	assert(sub_layer_id < _sub_layers.size())

	return _sub_layers[sub_layer_id]


func set_size(new_size: Array) -> void:
	assert(new_size.size() == 2)
	for value in new_size:
		assert(value is int)
		assert(value >= 1)

	size = new_size

	for sub_layer in _sub_layers:
		sub_layer.set_size(new_size)


func add_sub_layer() -> void:
	var sub_layer = TMM_TileMapSubLayer.new()
	sub_layer.set_size(size)

	_sub_layers.append(sub_layer)
