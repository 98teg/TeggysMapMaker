class_name _MainParser

var _base_parser : _BaseParser = _BaseParser.new()

# Public

func parse(path : String) -> void:
	_base_parser.open_dir_from_file_path(path)

	var file = File.new()
	file.open(path, File.READ)

	var json_parsed_configuration = _parse_json(file.get_as_text())

	if not has_errors():
		_parse_style(json_parsed_configuration)

func get_configuration():
	return _base_parser._configuration

func has_errors() -> bool:
	return _base_parser._errors.size() != 0

func get_errors() -> Array:
	return _base_parser._errors

func has_warnings() -> bool:
	return _base_parser._warnings.size() != 0

func get_warnings() -> Array:
	return _base_parser._warnings

# Private

func _parse_json(configuration : String) -> Dictionary:
	var parsed_configuration = {}

	var result = JSON.parse(configuration)

	if result.error != OK:
		if configuration == "":
			_base_parser._empty_file()
		else:
			_base_parser._json_parse_error(result.error_string, result.error_line)
	elif typeof(result.result) != TYPE_DICTIONARY:
		_base_parser._expected_an_object()
	else:
		parsed_configuration = result.result

	return parsed_configuration

func _parse_style(configuration : Dictionary) -> void:
	var style_data_parser = _StyleDataParser.new()
	_base_parser._configuration.StyleData = style_data_parser.parse(_base_parser, configuration)

	var layer = {}
	layer.Type = "TileMap"
	var tyle_map_parser = _TileMapParser.new()
	layer.Configuration = tyle_map_parser.parse(_base_parser, configuration)

	_base_parser._configuration.Layers = []
	_base_parser._configuration.Layers.append(layer)
