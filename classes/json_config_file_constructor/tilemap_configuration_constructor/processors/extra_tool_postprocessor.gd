extends JSONConfigProcessor


func _postprocess(extra_tool: String) -> int:
	match extra_tool:
		"Wrench":
			return Tilemap.Tool.WRENCH
		"BucketFill":
			return Tilemap.Tool.BUCKET_FILL

	return -1
