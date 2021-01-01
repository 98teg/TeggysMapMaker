extends JSONConfigProcessor


func _postprocess(configuration: Dictionary) -> Dictionary:
	configuration.Layers = [{}]
	configuration.Layers[0].Type = "TileMap"
	configuration.Layers[0].Configuration = configuration.Configuration

	# warning-ignore:return_value_discarded
	configuration.erase("Configuration")

	return configuration
