extends JSONConfigProcessor


func _postprocess(color: Color) -> Image:
	var image = Image.new()

	if has_variable("tile_size"):
		var tile_size = get_variable("tile_size")
		image.create(tile_size, tile_size, false, Image.FORMAT_RGBA8)
		image.fill(color)

	return image
