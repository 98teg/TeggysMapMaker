extends JSONConfigProcessor


func _preprocess():
	if has_variable("size"):
		var size = get_variable("size")
		get_property().set_min_size(size[0])
