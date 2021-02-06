extends JSONConfigProcessor


func _postprocess(colission_mask: Array) -> Array:
	if not TMM_TileMapHelper.is_trimmed(colission_mask):
		add_error({"error": "The colission mask is not trimmed"})

	return colission_mask
