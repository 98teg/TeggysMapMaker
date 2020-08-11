class_name BaseParser

var _directory : Directory = Directory.new()
var _configuration : Dictionary = {}
var _errors : Array = []
var _warnings : Array = []
const _error_diff : float = 0.0000001

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
							  max_length : int = -1,
							  context : String = "") -> String:
	var string = ""

	if configuration.has(parameter):
		string = _check_string(configuration, parameter, max_length, context)
	else:
		_missing(parameter, "String", context)

	return string

func _check_string(configuration : Dictionary,
				   parameter : String,
				   max_length : int = -1,
				   context : String = "") -> String:
	var string = ""
	var conf_parameter = configuration.get(parameter)

	if typeof(conf_parameter) == TYPE_STRING:
		if conf_parameter.length() > max_length and max_length != -1:
			_longer_string(parameter, max_length, context)
		else:
			if conf_parameter == "":
				_empty_string(parameter, context)
			else:
				string = conf_parameter
	else:
		_incorrect_type(parameter, "String", context)

	return string

func _check_obligatory_int(configuration : Dictionary,
						   parameter : String,
						   max_value : int = -1,
						   context : String = "") -> int:
	var integer = 1

	if configuration.has(parameter):
		integer = _check_int(configuration, parameter, max_value, context)
	else:
		_missing(parameter, "Integer", context)

	return integer

func _check_int(configuration : Dictionary,
				parameter : String,
				max_value : int = -1,
				context : String = "") -> int:
	var integer = 1
	var conf_parameter = configuration.get(parameter)

	if typeof(conf_parameter) == TYPE_REAL:
		if _is_an_integer(conf_parameter):
			conf_parameter = int(conf_parameter)

			if conf_parameter < 1:
				_smaller_int(parameter, context)
			elif conf_parameter > max_value and max_value != -1:
				_bigger_int(parameter, max_value, context)
			else:
				integer = conf_parameter
		else:
			_incorrect_type(parameter, "Integer", context)
	else:
		_incorrect_type(parameter, "Integer", context)

	return integer

func _check_obligatory_color(configuration : Dictionary,
							 parameter : String,
							 context : String = "") -> Color:
	var color = Color(0, 0, 0, 1)

	if configuration.has(parameter):
		color = _check_color(configuration, parameter, context)
	else:
		_missing(parameter, "Color", context)

	return color

func _check_color(configuration : Dictionary,
				  parameter : String,
				  context : String = "") -> Color:
	var color = Color(0, 0, 0, 1)
	var conf_parameter = configuration.get(parameter)

	if typeof(conf_parameter) == TYPE_ARRAY:
		if conf_parameter.size() == 3 or conf_parameter.size() == 4:
			var success = true

			for element in conf_parameter:
				if typeof(element) == TYPE_REAL and _is_an_integer(element):
					if element < 0 or element >= 256:
						_incorrect_color_element(parameter, context)
						success = false
						break
				else:
					_incorrect_color_element(parameter, context)
					success = false
					break

			if success:
				for i in range(conf_parameter.size()):
					color[i] = conf_parameter[i] / 255.0
		else:
			_incorrect_type(parameter, "Color", context)
	else:
		_incorrect_type(parameter, "Color", context)

	return color

func _check_obligatory_image(configuration : Dictionary,
							 parameter : String,
							 recomended_size : Vector2 = Vector2.ZERO,
							 context : String = "") -> Image:
	var image = Image.new()
	if recomended_size != Vector2.ZERO:
		image.create(recomended_size.x, recomended_size.y, false, Image.FORMAT_RGBA8)
	else:
		image.create(16, 16, false, Image.FORMAT_RGBA8)

	if configuration.has(parameter):
		image = _check_image(configuration, parameter, recomended_size, context)
	else:
		_missing(parameter, "Image", context)

	return image

func _check_image(configuration : Dictionary,
				  parameter : String,
				  recomended_size : Vector2 = Vector2.ZERO,
				  context : String = "") -> Image:
	var image = Image.new()
	if recomended_size != Vector2.ZERO:
		image.create(recomended_size.x, recomended_size.y, false, Image.FORMAT_RGBA8)
	else:
		image.create(16, 16, false, Image.FORMAT_RGBA8)

	var conf_parameter = configuration.get(parameter)

	if typeof(conf_parameter) == TYPE_STRING:
		if _directory.file_exists(conf_parameter):
			var image_path = _directory.get_current_dir().plus_file(conf_parameter) 

			if image.load(image_path) == OK:
				image.convert(Image.FORMAT_RGBA8)
				
				if image.get_size() != recomended_size and recomended_size != Vector2.ZERO:
					image.resize(recomended_size.x, recomended_size.y, Image.INTERPOLATE_NEAREST)
					_image_is_not_the_recommended_size(parameter, recomended_size, context)
			else:
				_error_opening_image(parameter, context)
		else:
			_file_not_found(parameter, context)
	else:
		_incorrect_type(parameter, "Image", context)

	return image

func _check_obligatory_array(configuration : Dictionary,
							 singular_parameter : String,
							 plural_parameter : String,
							 max_size : int = -1,
							 context : String = "") -> Array:
	var array = []

	if not (configuration.has(singular_parameter) or configuration.has(plural_parameter)):
		_missing(plural_parameter, "Array", context)
	else:
		array = _check_array(configuration, singular_parameter, plural_parameter, max_size, context)

	return array

func _check_array(configuration : Dictionary,
				  singular_parameter : String,
				  plural_parameter : String,
				  max_size : int = -1,
				  context : String = "") -> Array:
	var array = []

	if _has_only_one_parameter(configuration, singular_parameter, plural_parameter):
		if configuration.has(singular_parameter):
			var conf_parameter = configuration.get(singular_parameter)

			array.append(conf_parameter)
		else:
			var conf_parameter = configuration.get(plural_parameter)

			if typeof(conf_parameter) == TYPE_ARRAY:
				if conf_parameter.size() == 0:
					_no_empty_array(plural_parameter, context)
				elif conf_parameter.size() == 1:
					_no_single_element_array(singular_parameter, plural_parameter, context)
				elif conf_parameter.size() > max_size and max_size != -1:
					_bigger_array(plural_parameter, max_size, context)
				else:
					array = conf_parameter
			else:
				_incorrect_type(plural_parameter, "Array", context)
	elif _have_both_parameters(configuration, singular_parameter, plural_parameter):
		_cant_have_both(singular_parameter, plural_parameter, context)

	return array

# Error messages

func _empty_file() -> void:
	_add_error("Empty file")

func _json_parse_error(error : String, line : int) -> void:
	_add_error("Error parsing JSON at line " + String(line) + ": " + error)

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

func _smaller_int(parameter : String, context : String = "") -> void:
	var error = "'" + parameter + "' Number is smaller than 1"

	_add_error(_with_context(error, context))

func _bigger_int(parameter : String, max_value : int, context : String = "") -> void:
	var error = "'" + parameter + "' Number is bigger than " + String(max_value)

	_add_error(_with_context(error, context))

func _bigger_array(parameter : String, max_size : int, context : String = "") -> void:
	var error = "'" + parameter + "' Array is bigger than " + String(max_size)

	_add_error(_with_context(error, context))

func _incorrect_color_element(parameter : String, context : String = "") -> void:
	var error = "Expected '" + parameter + "' Color Elements to be Integers in the range [0, 255]"

	_add_error(_with_context(error, context))

func _file_not_found(parameter : String, context : String = "") -> void:
	var error = "'" + parameter + "' contain a path to a file that doesn't exist"

	_add_error(_with_context(error, context))

func _error_opening_image(parameter : String, context : String = "") -> void:
	var error = "An error ocurred opening '" + parameter + "' Image"

	_add_error(_with_context(error, context))

func _cant_have_both(p1 : String, p2 : String, context : String = "") -> void:
	var error = "'" + p1 + "' and '" + p2 + "' can't be declared simultaneously"

	_add_error(_with_context(error, context))

func _no_empty_array(parameter : String, context : String = "") -> void:
	var error = "'" + parameter + "' Array can't be empty"

	_add_error(_with_context(error, context))

func _no_single_element_array(p1 : String, p2 : String, context : String = "") -> void:
	var error = "'" + p2 + "' Array can't have just one element"
	error = error + ", replace the keyword with its singular form '" + p1 + "'"

	_add_error(_with_context(error, context))

func _no_registered_extra_tool(context : String = "") -> void:
	var error = "Incorrect value for an 'ExtraTool'"

	_add_error(_with_context(error, context))

func _two_elements_are_equal(parameter : String, context : String = "") -> void:
	var error = "There are two '" + parameter + "'"

	_add_error(_with_context(error, context))

func _no_registered_connection(context : String = "") -> void:
	var error = "Incorrect value for an 'Connection'"

	_add_error(_with_context(error, context))

func _empty_string(parameter : String, context : String = "") -> void:
	var warning = "'" + parameter + "' is an empty String"

	_add_warning(_with_context(warning, context))

func _image_is_not_the_recommended_size(parameter : String, recomended_size : Vector2, context : String = "") -> void:
	var warning = "'" + parameter + "' Image is not the recomended size ("
	warning = warning + String(recomended_size.x) + "x" + String(recomended_size.y) + ")"

	_add_warning(_with_context(warning, context))

func _no_tiles_detected(context : String = "") -> void:
	var warning = "No tile has been declared"

	_add_warning(_with_context(warning, context))

static func _with_context(text : String, context : String = "") -> String:
	if context == "":
		return text
	else:
		return text + " in '" + context + "'"

# Auxiliary functions

static func _has_only_one_parameter(conf : Dictionary, p1 : String, p2 : String) -> bool:
	return (conf.has(p1) or conf.has(p2)) and not _have_both_parameters(conf, p1, p2)

static func _have_both_parameters(conf : Dictionary, p1 : String, p2 : String) -> bool:
	return conf.has(p1) and conf.has(p2)

static func _is_an_integer(i : float) -> bool:
	return abs(int(i) - i) < _error_diff

static func _is_a_vowel(c : String) -> bool:
	c = c.to_upper()

	return c == "A" or c == "E" or c == "I" or c == "O" or c == "U"
