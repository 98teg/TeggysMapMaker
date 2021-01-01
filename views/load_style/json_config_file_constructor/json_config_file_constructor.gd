class_name JSONConfigFileConstructor


static func get_json_config_file() -> JSONConfigFile:
	var json_config_file = JSONConfigFile.new()

	json_config_file.add_property("StyleData",
			StyleDataConstructor.get_style_data())
	json_config_file.add_property("Configuration",
			TilemapConfigurationConstructor.get_tilemap_configuration())
	json_config_file.set_postprocessor(
			preload("./processors/postprocessor.gd").new())

	return json_config_file
