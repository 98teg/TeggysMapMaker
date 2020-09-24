extends JSONConfigProcessor


func _postprocess(structure: Dictionary) -> Dictionary:
	if has_variable("size"):
		if not structure.has("ColissionMask"):
			var size = get_variable("size")
			structure.ColissionMask = []
			for i in range(size[1]):
				structure.ColissionMask.append([])
				for j in range(size[0]):
					structure.ColissionMask[i].append(true)

	return structure
