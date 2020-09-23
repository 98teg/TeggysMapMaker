extends JSONConfigProcessor


func _postprocess(tile_size: int) -> int:
	set_variable("tile_size", tile_size)

	return tile_size
