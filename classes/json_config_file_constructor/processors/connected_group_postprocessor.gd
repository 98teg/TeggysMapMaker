extends JSONConfigProcessor


func _postprocess(connected_group: String) -> int:
	if has_variable("connected_groups"):
		var connected_groups = get_variable("connected_groups")
		if not connected_groups.has(connected_group):
			connected_groups[connected_group] = connected_groups.keys().size() + 1
	else:
		var connected_groups = {}
		connected_groups[connected_group] = 1
		set_variable("connected_groups", connected_groups)

	return get_variable("connected_groups")[connected_group]
