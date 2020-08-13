class_name TilemapParser

var _base_parser : BaseParser
var _tile_size : int = 0
var _n_tiles : int = 0
var _layers : Dictionary = {}
var _connected_groups : Dictionary = {"": 0}
var _correct_variations : bool = true
var _connection_type : int = Tile.Connection_type.ISOLATED
const _max_TileSize : int = 64
const _max_TileSetSize : int = 100
const _max_Tile_Name_length : int = 100
const _max_Tile_Layer_length : int = 100
const _max_Tile_ConnectedGroup_length : int = 100
const _max_Tile_ExtraToolsSize : int = 2
const _max_Tile_VariationsSize : int = 256
const _max_Tile_VariationsConditionsSize : int = 8

func parse(base_parser : BaseParser, configuration : Dictionary) -> Dictionary:
	_base_parser = base_parser
	var tilemap_conf = _base_parser._check_obligatory_object(configuration, "Configuration")

	var parsed_conf = {}
	parsed_conf.TileSize = _base_parser._check_obligatory_int(tilemap_conf, "TileSize", _max_TileSize, "Configuration")
	_tile_size = parsed_conf.TileSize
	parsed_conf.Background = _check_background(tilemap_conf)
	parsed_conf.TileSet = _check_tileset(tilemap_conf)

	return parsed_conf

func _check_background(tilemap_conf : Dictionary) -> Image:
	var background = Image.new()
	background.create(_tile_size, _tile_size, false, Image.FORMAT_RGBA8)

	if tilemap_conf.has("Background"):
		if typeof(tilemap_conf.Background) == TYPE_ARRAY:
			background.fill(_base_parser._check_color(tilemap_conf, "Background", "Configuration"))
		elif typeof(tilemap_conf.Background) == TYPE_STRING:
			var recomended_size =  Vector2(_tile_size, _tile_size)
			var image = _base_parser._check_image(tilemap_conf, "Background", recomended_size, "Configuration")

			background.copy_from(image)
		else:
			_base_parser._incorrect_type("Background", "Color or an Image", "Configuration")
	else:
		background.fill(Color.transparent)

	return background

func _check_tileset(tilemap_conf : Dictionary) -> Array:
	var tileset = []

	tileset = _base_parser._check_array(tilemap_conf, "Tile", "TileSet", _max_TileSetSize, "Configuration")

	if tileset.size() != 0:
		for i in range(tileset.size()):
			var context
			if tileset.size() == 1:
				context = "Configuration/Tile"
			else:
				context = "Configuration/TileSet[" + String(i) + "]"

			if typeof(tileset[i]) == TYPE_DICTIONARY:
				tileset[i] = _check_tile(tileset[i], context)
			else:
				tileset[i] = {}

				if tileset.size() == 1:
					_base_parser._incorrect_type("Tile", "Dictionary", "Configuration")
				else:
					_base_parser._incorrect_type("Tile", "Dictionary", context)

	return tileset

func _check_tile(tile_conf : Dictionary, context : String) -> Dictionary:
	var tile = {}

	tile.ID = _n_tiles
	_n_tiles = _n_tiles + 1

	if tile_conf.has("Name"):
		tile.Name = _base_parser._check_string(tile_conf, "Name", _max_Tile_Name_length, context)
	else:
		tile.Name = ""

	var recomended_size =  Vector2(_tile_size, _tile_size)
	tile.Image = _base_parser._check_obligatory_image(tile_conf, "Image", recomended_size, context)

	var layer
	if tile_conf.has("Layer"):
		layer = _base_parser._check_string(tile_conf, "Layer", _max_Tile_Layer_length, context)
	else:
		layer = ""

	if _layers.has(layer):
		tile.Layer = _layers.get(layer)
	else:
		var layer_id = _layers.size()
		tile.Layer = layer_id
		_layers[layer] = layer_id

	var connected_group
	if tile_conf.has("ConnectedGroup"):
		connected_group = _base_parser._check_string(tile_conf, "ConnectedGroup", _max_Tile_ConnectedGroup_length, context)
	else:
		connected_group = ""

	if _connected_groups.has(layer):
		tile.ConnectedGroup = _connected_groups.get(layer)
	else:
		var connected_group_id = _connected_groups.size()
		tile.ConnectedGroup = connected_group_id
		_connected_groups[connected_group] = connected_group_id

	var extra_tools = []

	extra_tools = _base_parser._check_array(tile_conf, "ExtraTool", "ExtraTools", _max_Tile_ExtraToolsSize, context)

	if extra_tools.size() != 0:
		var extra_tools_flags = [false, false]

		for i in range(extra_tools.size()):
			var extra_tools_context
			if extra_tools.size() == 1:
				extra_tools_context = context + "/ExtraTool"
			else:
				extra_tools_context = context + "/ExtraTools[" + String(i) + "]"

			if typeof(extra_tools[i]) == TYPE_STRING:
				match extra_tools[i]:
					"Wrench":
						if extra_tools_flags[0] == false:
							extra_tools_flags[0] = true
						else:
							_base_parser._two_elements_are_equal("Wrench", context)

						extra_tools[i] = Tilemap.Tool.WRENCH
					"BukectFill":
						if extra_tools_flags[1] == false:
							extra_tools_flags[1] = true
						else:
							_base_parser._two_elements_are_equal("BukectFill", context)

						extra_tools[i] = Tilemap.Tool.BUCKET_FILL
					_:
						extra_tools[i] = Tilemap.Tool.PENCIL

						_base_parser._no_registered_extra_tool(extra_tools_context)
			else:
				extra_tools[i] = Tilemap.Tool.PENCIL

				if extra_tools.size() == 1:
					_base_parser._incorrect_type("ExtraTool", "String", context)
				else:
					_base_parser._incorrect_type("ExtraTool", "String", extra_tools_context)
	
	tile.ExtraTools = extra_tools

	var variations = []

	variations = _base_parser._check_array(tile_conf, "Variation", "Variations", _max_Tile_VariationsSize, context)

	if variations.size() != 0:
		_connection_type = Tile.Connection_type.CROSS
		_correct_variations = true

		for i in range(variations.size()):
			var variation_context
			if variations.size() == 1:
				variation_context = context + "/Variation"
			else:
				variation_context = context + "/Variations[" + String(i) + "]"

			if typeof(variations[i]) == TYPE_DICTIONARY:
				variations[i] = _check_variation(variations[i], variation_context)
			else:
				variations[i] = {}

				if variations.size() == 1:
					_base_parser._incorrect_type("Variation", "Dictionary", context)
				else:
					_base_parser._incorrect_type("Variation", "Dictionary", variation_context)
	else:
		_connection_type = Tile.Connection_type.ISOLATED
		_correct_variations = false
	
	if _connection_type != Tile.Connection_type.ISOLATED:
		_transform_variations(variations)

	tile.ConnectionType = _connection_type
	tile.Variations = variations

	return tile

func _check_variation(variation_conf : Dictionary, context : String) -> Dictionary:
	var variation = {}

	var recomended_size =  Vector2(_tile_size, _tile_size)
	variation.Image = _base_parser._check_obligatory_image(variation_conf, "Image", recomended_size, context)

	var connections = _base_parser._check_obligatory_array(variation_conf, "Connection", "Connections", _max_Tile_VariationsConditionsSize, context)
	if connections.size() != 0:
		for i in range(connections.size()):
			var connection_context
			if connections.size() == 1:
				connection_context = context + "/Connection"
			else:
				connection_context = context + "/Connections[" + String(i) + "]"

			if typeof(connections[i]) == TYPE_ARRAY:
				connections[i] = _check_connection(connections[i], connection_context)
			else:
				_correct_variations = false
				connections[i] = []

				if connections.size() == 1:
					_base_parser._incorrect_type("Connection", "Array", context)
				else:
					_base_parser._incorrect_type("Connection", "Array", connection_context)
	else:
		_correct_variations = false

	variation.Connections = connections

	return variation

func _check_connection(connection_array : Array, context : String) -> Array:
	var bitmask = [false, false, false, false, false, false, false, false]

	for element in connection_array:
		if typeof(element) == TYPE_STRING:
			match element:
				"North":
					if bitmask[0] == false:
						bitmask[0] = true
					else:
						_correct_variations = false
						_base_parser._two_elements_are_equal("North", context)
				"NorthEast":
					if bitmask[1] == false:
						bitmask[1] = true
						_connection_type = Tile.Connection_type.CIRCLE
					else:
						_correct_variations = false
						_base_parser._two_elements_are_equal("NorthEast", context)
				"East":
					if bitmask[2] == false:
						bitmask[2] = true
					else:
						_correct_variations = false
						_base_parser._two_elements_are_equal("East", context)
				"SouthEast":
					if bitmask[3] == false:
						bitmask[3] = true
						_connection_type = Tile.Connection_type.CIRCLE
					else:
						_correct_variations = false
						_base_parser._two_elements_are_equal("SouthEast", context)
				"South":
					if bitmask[4] == false:
						bitmask[4] = true
					else:
						_correct_variations = false
						_base_parser._two_elements_are_equal("South", context)
				"SouthWest":
					if bitmask[5] == false:
						bitmask[5] = true
						_connection_type = Tile.Connection_type.CIRCLE
					else:
						_correct_variations = false
						_base_parser._two_elements_are_equal("SouthWest", context)
				"West":
					if bitmask[6] == false:
						bitmask[6] = true
					else:
						_correct_variations = false
						_base_parser._two_elements_are_equal("West", context)
				"NorthWest":
					if bitmask[7] == false:
						bitmask[7] = true
						_connection_type = Tile.Connection_type.CIRCLE
					else:
						_correct_variations = false
						_base_parser._two_elements_are_equal("NorthWest", context)
				_:
					_correct_variations = false
					_base_parser._no_registered_connection(context)
		else:
			_correct_variations = false
			_base_parser._incorrect_type("Element", "String", context)

	return bitmask

func _transform_variations(variations : Array) -> void:
	for variation in variations:
		var connections = []

		for connection in variation.Connections:
			if _correct_variations:
				var acc = 0
	
				if _connection_type == Tile.Connection_type.CROSS:
					if connection[0]:
						acc += 1
					if connection[2]:
						acc += 2
					if connection[4]:
						acc += 4
					if connection[6]:
						acc += 8 
				else:
					for i in range(connection.size()):
						if connection[i]:
							acc += pow(2, i)

					acc = int(acc)
	
				connections.append(acc)
			else:
				connections.append(0)

		variation.Connections = connections
