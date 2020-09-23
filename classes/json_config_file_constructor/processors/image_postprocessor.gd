extends JSONConfigProcessor


func _postprocess(image: Image) -> Image:
	image.convert(Image.FORMAT_RGBA8)

	return image
