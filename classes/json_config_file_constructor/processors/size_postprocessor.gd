extends JSONConfigProcessor


func _postprocess(size: Array) -> Vector2:
	set_variable("size", Vector2(size[0], size[1]))

	return  Vector2(size[0], size[1])
