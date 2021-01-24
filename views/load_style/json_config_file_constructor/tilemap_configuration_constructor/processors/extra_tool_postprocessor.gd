extends JSONConfigProcessor


func _postprocess(extra_tool: String) -> int:
	match extra_tool:
		"Wrench":
			return TMM_TileMapHelper.Tool.WRENCH
		"BucketFill":
			return TMM_TileMapHelper.Tool.BUCKET_FILL

	return -1
