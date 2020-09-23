extends Control

signal style_selected(canvas_conf, style_conf)

enum Result {
	OK = 0,
	WARNING = 1,
	ERROR = 2
}

var _ok_tex : ImageTexture = ImageTexture.new()
var _warning_tex : ImageTexture = ImageTexture.new()
var _error_tex : ImageTexture = ImageTexture.new()
var _style_conf : Dictionary = {}

func _ready():
	var stream_texture
	
	stream_texture = load("res://resources/icons/ok.png")
	_ok_tex.create_from_image(stream_texture.get_data())

	stream_texture = load("res://resources/icons/warning.png")
	_warning_tex.create_from_image(stream_texture.get_data())

	stream_texture = load("res://resources/icons/error.png")
	_error_tex.create_from_image(stream_texture.get_data())

func _set_style_parse_result(result : int):
	get_node("ParseResult").show()
	match result:
		Result.OK:
			get_node("ParseResult/Icon").set_texture(_ok_tex)
			get_node("ParseResult/Icon").get_material().set_shader_param("mode", result)
			get_node("ParseResult/Message").set_text("Successfully Loaded")
		Result.WARNING:
			get_node("ParseResult/Icon").set_texture(_warning_tex)
			get_node("ParseResult/Icon").get_material().set_shader_param("mode", result)
			get_node("ParseResult/Message").set_text("Loaded with Warnings")
		Result.ERROR:
			get_node("ParseResult/Icon").set_texture(_error_tex)
			get_node("ParseResult/Icon").get_material().set_shader_param("mode", result)
			get_node("ParseResult/Message").set_text("Errors Occurred")

func _show_errors(errors : Array):
	if errors.size() != 0:
		get_node("Messages").show()
		get_node("Messages").set_current_tab(0)
		get_node("Messages").set_tab_disabled(0, false)
		for error in errors:
			get_node("Messages/Error(s)/Errors").add_text(error.as_text + "\n")
	else:
		get_node("Messages").set_tab_disabled(0, true)

func _show_warnings(warnings : Array):
	if warnings.size() != 0:
		get_node("Messages").show()
		get_node("Messages").set_current_tab(1)
		get_node("Messages").set_tab_disabled(1, false)
		for warning in warnings:
			get_node("Messages/Warning(s)/Warnings").add_text(warning.as_text + "\n")
	else:
		get_node("Messages").set_tab_disabled(1, true)

func _path_text_clicked(event : InputEvent):
	if event is InputEventMouseButton:
		if event.get_button_index() == BUTTON_LEFT:
			if event.is_pressed():
				_select_style()

func _select_style():
	get_node("SelectStyle").popup_centered()

func _style_selected(path : String):
	get_node("Messages").hide()
	set_size(Vector2(get_size().x, get_minimum_size().y))

	get_node("Messages/Error(s)/Errors").clear()
	get_node("Messages/Warning(s)/Warnings").clear()

	get_node("PathSelection/Path").set_text(path.get_file())

	var json_config_file = JSONConfigFileConstructor.get_json_config_file()
	json_config_file.validate(path)

	_style_conf = json_config_file.get_result()

	if json_config_file.has_errors():
		_set_style_parse_result(Result.ERROR)

		_show_warnings(json_config_file.get_warnings())
		_show_errors(json_config_file.get_errors())

		get_node("StartContainer/StartButton").disabled = true
		get_node("Style").hide()
	elif json_config_file.has_warnings():
		_set_style_parse_result(Result.WARNING)

		_show_warnings(json_config_file.get_warnings())
		_show_errors(json_config_file.get_errors())

		get_node("StartContainer/StartButton").disabled = false
		get_node("Style").show()
		get_node("Style").set_text(_style_conf.StyleData.Name + " by " + _style_conf.StyleData.Author + ":")
	else:
		_set_style_parse_result(Result.OK)
		get_node("StartContainer/StartButton").disabled = false
		get_node("Style").show()
		get_node("Style").set_text(_style_conf.StyleData.Name + " by " + _style_conf.StyleData.Author + ":")

func _create_proyect():
	var width = get_node("SizeContainer/Width").get_value()
	var height = get_node("SizeContainer/Height").get_value()

	var canvas_conf = {
		"Width": width,
		"Height": height
	}

	emit_signal("style_selected", canvas_conf, _style_conf)
