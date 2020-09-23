extends JSONConfigProcessor


func _preprocess():
	if has_variable("tile_size"):
		var tile_size = get_variable("tile_size")

		if has_variable("size"):
			var size = get_variable("size")
			get_property().set_size(tile_size * size.x, tile_size * size.y, true, Image.INTERPOLATE_NEAREST)
		else:
			get_property().set_size(tile_size, tile_size, true, Image.INTERPOLATE_NEAREST)
