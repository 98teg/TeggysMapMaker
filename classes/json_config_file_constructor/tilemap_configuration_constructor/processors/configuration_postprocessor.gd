extends JSONConfigProcessor


func _postprocess(configuration: Dictionary) -> Dictionary:
	if configuration.has("BackgroundColor"):
		configuration.Background = configuration.BackgroundColor
		# warning-ignore:return_value_discarded
		configuration.erase("BackgroundColor")
	elif configuration.has("BackgroundImage"):
		configuration.Background = configuration.BackgroundImage
		# warning-ignore:return_value_discarded
		configuration.erase("BackgroundImage")
	else:
		var image = Image.new()

		image.create(configuration.TileSize, configuration.TileSize, false,
				Image.FORMAT_RGBA8)
		image.fill(Color.transparent)

		configuration.Background = image

	if configuration.has("Tile"):
		configuration.TileSet = [configuration.Tile]
		# warning-ignore:return_value_discarded
		configuration.erase("Tile")
	elif configuration.has("TileSet"):
		pass
	else:
		configuration.TileSet = []

	configuration.TileSet = _get_tile_set_dictionary(configuration.TileSize,
			configuration.TileSet)

	if has_variable("layers"):
		configuration.NumberOfLayers = get_variable("layers").keys().size()
	else:
		configuration.NumberOfLayers = 1

	return configuration



func _get_tile_set_dictionary(tile_size: int, tile_set: Array) -> Dictionary:
	var empty_tile_image = Image.new()
	empty_tile_image.create(tile_size, tile_size, false, Image.FORMAT_RGBA8)
	empty_tile_image.fill(Color.transparent)

	var special_tile_conf = {
		"Layer": 0,
		"Name": "",
		"Icon": empty_tile_image,
		"Structure": {
			"Size": [1, 1],
			"ColissionMask": [[true]]
		},
		"ExtraTools": [],
		"ConnectionType": Tile.Connection_type.ISOLATED,
		"Image": empty_tile_image,
		"Variations": [],
		"CanConnectToBorders": false,
		"ConnectedGroup": 0
	}

	var new_tile_set = {}

	for special_tile_id in Tile.Special_tile.values():
		special_tile_conf.ID = special_tile_id

		var special_tile = Tile.new()
		special_tile.init(special_tile_conf)
		new_tile_set[special_tile_id] = special_tile

	for tile in tile_set:
		new_tile_set[tile.get_id()] = tile

	return new_tile_set
