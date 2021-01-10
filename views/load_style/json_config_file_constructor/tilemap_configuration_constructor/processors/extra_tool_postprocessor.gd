extends JSONConfigProcessor


func _postprocess(extra_tool: String) -> int:
	match extra_tool:
		"Wrench":
			return TMM_TileMapEnum.Tool.WRENCH
		"BucketFill":
			return TMM_TileMapEnum.Tool.BUCKET_FILL

	return -1
