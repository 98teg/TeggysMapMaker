extends Control

enum StyleState{
	NONE,
	SELECTED,
	SELECT_ANOTHER_ONE
}

var _work_space = preload("res://views/work_space/WorkSpace.tscn")
var _style_state = StyleState.NONE

func _ready():
	OS.set_window_maximized(true)

func _popup_loadstyle():
	if _style_state == StyleState.NONE:
		get_node("LoadStylePopup").popup_centered()
		get_node("LoadStylePopup").get_close_button().disabled = true
		_loadstyle_resized()
	elif _style_state == StyleState.SELECT_ANOTHER_ONE:
		get_node("LoadStylePopup").popup_centered()
		get_node("LoadStylePopup").get_close_button().disabled = false
		_loadstyle_resized()
	else:
		pass

func _resized():
	_popup_loadstyle()

func _loadstyle_resized():
	var height = get_node("LoadStylePopup/LoadStyle").get_size().y + 20
	get_node("LoadStylePopup").set_size(Vector2(700, height))

func _style_selected(canvas_conf : Dictionary, style_conf : Dictionary):
	_style_state = StyleState.SELECTED
	get_node("LoadStylePopup").hide()

	if _style_state == StyleState.SELECT_ANOTHER_ONE:
		get_node("WorkSpace").queue_free()

	var work_space = _work_space.instance()
	work_space.connect("new", self, "_new")
	add_child(work_space)
	work_space.init(canvas_conf, style_conf)

	update()

func _new():
	_style_state = StyleState.SELECT_ANOTHER_ONE

	_popup_loadstyle()
