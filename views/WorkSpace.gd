extends Control

signal new()

func init(canvas_conf : Dictionary, style_conf : Dictionary):
	get_node("Canvas").init(canvas_conf, style_conf)

	get_node("ControlPanel/ToolBox").add_child(get_node("Canvas").get_current_tool_box())
	get_node("ControlPanel/MagnifyingGlass").connect("magnifying_factor_updated", get_node("Canvas"), "_update_scale_factor")
	get_node("Canvas").connect("gui_input", get_node("ControlPanel/MagnifyingGlass"), "process_mouse_wheel")

	get_node("Canvas").connect_with_undo_redo(get_node("ControlPanel/TopBar/UndoRedo"))

func _save():
	get_node("SaveImageDialog").popup_centered()

func _save_ok(path : String):
	get_node("Canvas").get_image().save_png(path)

func _about():
	get_node("AboutDialog").popup_centered()

func _new():
	emit_signal("new")
