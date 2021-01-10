extends JSONConfigProcessor


func _postprocess(extra_tool: String) -> int:
	match extra_tool:
		"Wrench":
			return TMM_TileMap.Tool.WRENCH
		"BucketFill":
			return TMM_TileMap.Tool.BUCKET_FILL

	return -1
