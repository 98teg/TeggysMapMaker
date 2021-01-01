extends JSONConfigProcessor


func _postprocess(tile: Dictionary) -> Tile:
	if has_variable("last_id"):
		tile.ID = get_variable("last_id") + 1
		set_variable("last_id", tile.ID)
	else:
		tile.ID = 0
		set_variable("last_id", tile.ID)

	if not tile.has("Icon"):
		tile.Icon = tile.Image

	if not tile.has("Layer"):
		tile.Layer = 0

	if tile.has("ExtraTool"):
		tile.ExtraTools = [tile.ExtraTool]
		# warning-ignore:return_value_discarded
		tile.erase("ExtraTool")
	elif tile.has("ExtraTools"):
		pass
	else:
		tile.ExtraTools = []

	if not tile.has("ConnectedGroup"):
		tile.ConnectedGroup = 0

	if tile.has("Variation"):
		tile.Variations = [tile.Variation]
		# warning-ignore:return_value_discarded
		tile.erase("Variation")
	elif tile.has("Variations"):
		pass
	else:
		tile.Variations = []

	tile.ConnectionType = _get_connection_type(tile.Variations)

	_transform_variations(tile.Variations, tile.ConnectionType)

	var new_tile = Tile.new()
	new_tile.init(tile)

	return new_tile


func _get_connection_type(variations: Array) -> int:
	if variations.empty():
		return Tile.Connection_type.ISOLATED

	for variation in variations:
		for connection in variation.Connections:
			for cardinal_coordinate in connection:
				match cardinal_coordinate:
					"NorthEast":
						return Tile.Connection_type.CIRCLE
					"SouthEast":
						return Tile.Connection_type.CIRCLE
					"SouthWest":
						return Tile.Connection_type.CIRCLE
					"NorthWest":
						return Tile.Connection_type.CIRCLE

	return Tile.Connection_type.CROSS


func _transform_variations(variations: Array, connection_type: int) -> void:
	if connection_type == Tile.Connection_type.ISOLATED:
		return

	for variation in variations:
		for i in range(variation.Connections.size()):
			var acc = 0

			if connection_type == Tile.Connection_type.CROSS:
				for cardinal_coordinate in variation.Connections[i]:
					match cardinal_coordinate:
						"North":
							acc += 1
						"East":
							acc += 2
						"South":
							acc += 4
						"West":
							acc += 8
			else:
				for cardinal_coordinate in variation.Connections[i]:
					match cardinal_coordinate:
						"North":
							acc += 1
						"NorthEast":
							acc += 2
						"East":
							acc += 4
						"SouthEast":
							acc += 8
						"South":
							acc += 16
						"SouthWest":
							acc += 32
						"West":
							acc += 64
						"NorthWest":
							acc += 128
	
			variation.Connections[i] = acc
