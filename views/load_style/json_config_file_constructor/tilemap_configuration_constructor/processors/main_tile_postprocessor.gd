extends JSONConfigProcessor


func _postprocess(main_tile: Array):
	if has_variable("size"):
		var size = get_variable("size")

		if main_tile[0] >= size[0]:
			print(main_tile)
			print(size)
			add_error({
				"error": JSONProperty.Errors.NUMBER_VALUE_MORE_THAN_MAX,
				"max": size[0] - 1,
				"value": main_tile[0],
				"context": "[0]"
			})

			return null

		if main_tile[1] >= size[1]:
			add_error({
				"error": JSONProperty.Errors.NUMBER_VALUE_MORE_THAN_MAX,
				"max": size[1] - 1,
				"value": main_tile[1],
				"context": "[1]"
			})

			return null

	return main_tile
