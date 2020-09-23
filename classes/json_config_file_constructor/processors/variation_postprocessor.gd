extends JSONConfigProcessor


func _postprocess(variation: Dictionary) -> Dictionary:
	if variation.has("Connection"):
		variation.Connections = [variation.Connection]
		# warning-ignore:return_value_discarded
		variation.erase("Connection")

	return variation
