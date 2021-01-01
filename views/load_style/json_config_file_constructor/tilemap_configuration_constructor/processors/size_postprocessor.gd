extends JSONConfigProcessor


func _postprocess(size: Array) -> Array:
	set_variable("size", size)

	return  size
