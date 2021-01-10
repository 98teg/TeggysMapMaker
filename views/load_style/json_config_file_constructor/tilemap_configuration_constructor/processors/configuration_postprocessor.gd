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

	if has_variable("layers"):
		configuration.NumberOfLayers = get_variable("layers").keys().size()
	else:
		configuration.NumberOfLayers = 1

	return configuration
