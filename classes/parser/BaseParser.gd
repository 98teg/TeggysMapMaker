class_name _BaseParser

var _directory : Directory = Directory.new()
var _configuration : Dictionary = {}
var _errors : Array = []
var _warnings : Array = []

# Public

func open_dir_from_file_path(path : String) -> void:
	if _directory.open(path.get_base_dir()) != OK:
		print("Error while opening the style directoru")

# Private

func _add_error(error : String) -> void:
	_errors.append(error)

func _add_warning(warning : String) -> void:
	_warnings.append(warning)

# Checkers

func _check_obligatory_object(configuration : Dictionary,
							  parameter : String,
							  context : String = "") -> Dictionary:
	var object = {}

	if configuration.has(parameter):
		object = _check_object(configuration, parameter, context)
	else:
		_missing(parameter, "Object", context)

	return object

func _check_object(configuration : Dictionary,
				   parameter : String,
				   context : String = "") -> Dictionary:
	var object = {}
	var conf_parameter = configuration.get(parameter)

	if typeof(conf_parameter) == TYPE_DICTIONARY:
		object = conf_parameter
	else:
		_incorrect_type(parameter, "Object", context)

	return object

func _check_obligatory_string(configuration : Dictionary,
							  parameter : String,
							  max_length : int,
							  context : String = "") -> String:
	var string = ""

	if configuration.has(parameter):
		string = _check_string(configuration, parameter, max_length, context)
	else:
		_missing(parameter, "String", context)

	return string

func _check_string(configuration : Dictionary,
				   parameter : String,
				   max_length : int,
				   context : String = "") -> String:
	var string = ""
	var conf_parameter = configuration.get(parameter)

	if typeof(conf_parameter) == TYPE_STRING:
		if conf_parameter.length() > max_length:
			_longer_string(parameter, max_length, context)
		else:
			if conf_parameter == "":
				_empty_string(parameter, context)
			else:
				string = conf_parameter
	else:
		_incorrect_type(parameter, "String", context)

	return string

# Error messages

func _empty_file() -> void:
	_add_error("Empty file")

func _json_parse_error(error : String, line : int) -> void:
	_add_error(error + " at line " + String(line))

func _expected_an_object() -> void:
	_add_error("Expected the JSON file to contain an Object")

func _missing(parameter : String, type : String, context : String = "") -> void:
	var error = "Expected '" + parameter + "' " + type

	_add_error(_with_context(error, context))

func _incorrect_type(parameter : String, correct_type : String, context : String = "") -> void:
	var to_be_a = "' to be an " if _is_a_vowel(correct_type[0]) else "' to be a "
	
	var error = "Expected '" + parameter + to_be_a + correct_type
	
	_add_error(_with_context(error, context))

func _longer_string(parameter : String, max_length : int, context : String = "") -> void:
	var error = "'" + parameter + "' String is longer than " + String(max_length) + " characters"

	_add_error(_with_context(error, context))

func _empty_string(parameter : String, context : String = "") -> void:
	var warning = "'" + parameter + "' is an empty String"

	_add_warning(_with_context(warning, context))

static func _with_context(text : String, context : String = "") -> String:
	if context == "":
		return text
	else:
		return text + " in '" + context + "'"

# Auxiliary functions

static func _is_a_vowel(c : String) -> bool:
	c = c.to_upper()

	return c == "A" or c == "E" or c == "I" or c == "O" or c == "U"
