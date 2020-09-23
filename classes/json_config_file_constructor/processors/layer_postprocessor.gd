extends JSONConfigProcessor


func _postprocess(layer: String) -> int:
	if has_variable("layers"):
		var layers = get_variable("layers")
		if not layers.has(layer):
			layers[layer] = layers.keys().size()
	else:
		var layers = {}
		layers[layer] = 0
		set_variable("layers", layers)

	return get_variable("layers")[layer]
