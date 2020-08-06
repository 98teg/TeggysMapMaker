extends Control

var initated : bool = false

func _ready():
	OS.set_window_maximized(true)

func _new():
	get_tree().reload_current_scene()

func _resized():
	get_node("SelectStyleDialog").get_close_button().disabled = true
	get_node("SelectStyleDialog").get_cancel().disabled = true
	get_node("SelectStyleDialog").popup_centered()

func _style_selected(path : String):
	var configuration_parser = _MainParser.new() 
	configuration_parser.parse(path)

	print(configuration_parser.get_configuration())
	
	for error in configuration_parser.get_errors():
		print("Error: " + error)

	for warning in configuration_parser.get_warnings():
		print("Warning: " + warning)
	get_tree().quit()
#	get_node("SelectStyleDialog").get_close_button().disabled = false
#	get_node("SelectStyleDialog").get_cancel().disabled = false
#
#	var file = File.new()
#	var dir = get_node("/root/StyleDirectory")
#	dir.open(path.get_base_dir())
#	file.open(path, File.READ)
#	var configuration = JSON.parse(file.get_as_text()).get_result()
#
#	get_node("Canvas").init(configuration)
#
#	get_node("ControlPanel/ToolBox").add_child(get_node("Canvas").get_current_tool_box())
#	get_node("ControlPanel/MagnifyingGlass").connect("magnifying_factor_updated", get_node("Canvas"), "_update_scale_factor")
#	get_node("Canvas").connect("gui_input", get_node("ControlPanel/MagnifyingGlass"), "process_mouse_wheel")
#
#	get_node("Canvas").connect_with_undo_redo(get_node("ControlPanel/TopBar/UndoRedo"))

func _save():
	get_node("SaveImageDialog").popup_centered()

func _save_ok(path : String):
	get_node("Canvas").get_image().save_png(path)


func _about():
	get_node("AboutDialog").popup_centered()
