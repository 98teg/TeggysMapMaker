extends JSONConfigProcessor


func _preprocess():
	if has_variable("tile_size"):
		var tile_size = get_variable("tile_size")
		get_property().set_size(tile_size, tile_size, true, Image.INTERPOLATE_NEAREST)
