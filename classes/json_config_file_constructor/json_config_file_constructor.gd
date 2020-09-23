class_name JSONConfigFileConstructor


static func get_json_config_file() -> JSONConfigFile:
	var json_config_file = JSONConfigFile.new()

	json_config_file.add_property("StyleData", _get_style_data())
	json_config_file.add_property("Configuration", _get_configuration())
	json_config_file.set_postprocessor(
			preload("./processors/postprocessor.gd").new())

	return json_config_file


static func _get_style_data() -> JSONPropertyObject:
	var author = JSONPropertyString.new()
	author.set_min_length(1)
	author.set_max_length(50)

	var name = JSONPropertyString.new()
	name.set_min_length(1)
	name.set_max_length(50)

	var style_data = JSONPropertyObject.new()
	style_data.add_property("Author", author)
	style_data.add_property("Name", name)

	return style_data


static func _get_configuration() -> JSONPropertyObject:
	var tile_size = JSONPropertyInteger.new()
	tile_size.set_min_value(1)
	tile_size.set_max_value(64)
	tile_size.set_postprocessor(
			preload("./processors/tile_size_postprocessor.gd").new())

	var background_color = JSONPropertyColor.new()
	background_color.set_postprocessor(
			preload("./processors/color_postprocessor.gd").new())

	var background_image = JSONPropertyImage.new()
	background_image.set_preprocessor(
			preload("./processors/image_preprocessor.gd").new())
	background_image.set_postprocessor(
			preload("./processors/image_postprocessor.gd").new())

	var tile = _get_tile_property()

	var tile_set = JSONPropertyArray.new()
	tile_set.set_min_size(2)
	tile_set.set_max_size(100)
	tile_set.set_element_property(tile)

	var configuration = JSONPropertyObject.new()
	configuration.add_property("TileSize", tile_size)
	configuration.add_property("BackgroundColor", background_color, false)
	configuration.add_property("BackgroundImage", background_image, false)
	configuration.add_exclusivity(["BackgroundColor", "BackgroundImage"])
	configuration.add_property("Tile", tile, false)
	configuration.add_property("TileSet", tile_set, false)
	configuration.add_exclusivity(["Tile", "TileSet"])
	configuration.set_postprocessor(
			preload("./processors/configuration_postprocessor.gd").new())

	return configuration


static func _get_tile_property() -> JSONPropertyObject:
	var name = JSONPropertyString.new()
	name.set_min_length(1)
	name.set_max_length(50)

	var image = JSONPropertyImage.new()
	image.set_preprocessor(
			preload("./processors/image_preprocessor.gd").new())
	image.set_postprocessor(
			preload("./processors/image_postprocessor.gd").new())

	var layer = JSONPropertyString.new()
	layer.set_min_length(1)
	layer.set_max_length(50)
	layer.set_postprocessor(
		preload("./processors/layer_postprocessor.gd").new())

	var extra_tool_enum = ["Wrench", "BucketFill"]

	var extra_tool = JSONPropertyEnum.new()
	extra_tool.set_enum(extra_tool_enum)
	extra_tool.set_postprocessor(
			preload("./processors/extra_tool_postprocessor.gd").new())

	var extra_tools = JSONPropertyArray.new()
	extra_tools.set_min_size(2)
	extra_tools.set_max_size(extra_tool_enum.size())
	extra_tools.set_element_property(extra_tool)
	extra_tools.set_uniqueness(true)

	var connected_group = JSONPropertyString.new()
	connected_group.set_min_length(1)
	connected_group.set_max_length(50)
	connected_group.set_postprocessor(
		preload("./processors/connected_group_postprocessor.gd").new())

	var variation = _get_variation_property()

	var variations = JSONPropertyArray.new()
	variations.set_min_size(2)
	variations.set_max_size(512)
	variations.set_element_property(variation)

	var tile = JSONPropertyObject.new()
	tile.add_property("Name", name)
	tile.add_property("Image", image)
	tile.add_property("Layer", layer, false)
	tile.add_property("ExtraTool", extra_tool, false)
	tile.add_property("ExtraTools", extra_tools, false)
	tile.add_exclusivity(["ExtraTool", "ExtraTools"])
	tile.add_property("ConnectedGroup", connected_group, false)
	tile.add_property("Variation", variation, false)
	tile.add_property("Variations", variations, false)
	tile.add_exclusivity(["Variation", "Variations"])
	tile.set_postprocessor(
		preload("./processors/tile_postprocessor.gd").new())

	return tile


static func _get_variation_property() -> JSONPropertyObject:
	var image = JSONPropertyImage.new()
	image.set_preprocessor(
			preload("./processors/image_preprocessor.gd").new())
	image.set_postprocessor(
			preload("./processors/image_postprocessor.gd").new())

	var cardinal_direction = JSONPropertyEnum.new()
	cardinal_direction.set_enum(["North", "NorthEast", "East", "SouthEast", "South", "SouthWest", "West", "NorthWest"])

	var connection = JSONPropertyArray.new()
	connection.set_min_size(0)
	connection.set_max_size(8)
	connection.set_element_property(cardinal_direction)
	connection.set_uniqueness(true)

	var connections = JSONPropertyArray.new()
	connections.set_min_size(2)
	connections.set_max_size(512)
	connections.set_element_property(connection)

	var variation = JSONPropertyObject.new()
	variation.add_property("Image", image)
	variation.add_property("Connection", connection, false)
	variation.add_property("Connections", connections, false)
	variation.add_exclusivity(["Connection", "Connections"], true)
	variation.set_postprocessor(
			preload("./processors/variation_postprocessor.gd").new())

	return variation
