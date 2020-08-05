extends Control

func _ready():
	OS.set_window_maximized(true)

	var file = File.new()
	var dir = get_node("/root/StyleDirectory")
	dir.open("./resources/Kanto/")
	file.open(dir.get_current_dir() + "/" + "Kanto.json", File.READ)
	var configuration = JSON.parse(file.get_as_text()).get_result()
	
	get_node("Canvas").init(configuration)

	get_node("ControlPanel/ToolBox").add_child(get_node("Canvas").get_current_tool_box())
	get_node("ControlPanel/MagnifyingGlass").connect("magnifying_factor_updated", get_node("Canvas"), "_update_scale_factor")
	get_node("Canvas").connect("gui_input", get_node("ControlPanel/MagnifyingGlass"), "process_mouse_wheel")
	
	get_node("Canvas").connect_with_undo_redo(get_node("ControlPanel/TopBar/UndoRedo"))

func _save():
	get_node("SaveImageDialog").popup_centered()
	

func _save_ok(path : String):
	get_node("Canvas").get_image().save_png(path)
