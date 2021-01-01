extends Control

signal new()

func init(canvas_conf : Dictionary, style_conf : Dictionary):
	_get_canvas().init(canvas_conf, style_conf)

	_get_tool_box_container().add_child(_get_canvas().get_current_tool_box())
	_get_magnifying_glass().connect("magnifying_factor_updated", _get_canvas(), "_update_scale_factor")
	_get_canvas().connect("gui_input", _get_magnifying_glass(), "process_mouse_wheel")

	_get_canvas().connect_with_undo_redo(_get_undo_redo())

func _get_canvas():
	return get_node("VerticalDivision/HorizontalDivision/Canvas")

func _get_tool_box_container():
	return get_node("VerticalDivision/HorizontalDivision/ToolBoxContainer/ToolBoxMargin")

func _get_magnifying_glass():
	return get_node("VerticalDivision/TopBar/Margin/SplitTopBar/Tools/MagnifyingGlass")

func _get_undo_redo():
	return get_node("VerticalDivision/TopBar/Margin/SplitTopBar/Tools/UndoRedo")

func _save():
	get_node("SaveImageDialog").popup_centered()

func _save_ok(path : String):
	get_node("VerticalDivision/HorizontalDivision/Canvas").get_image().save_png(path)

func _about():
	get_node("AboutDialog").popup_centered()

func _new():
	emit_signal("new")
