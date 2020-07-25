extends Control

var _selected_layer = 1
var _n_layers = 2

var _dimensions
var _base_scale = 1
var _scale_factor = 1

var _allow_action = true

var _context = {}
var _previous_actions = []
var _next_actions = []

func _ready():
	_dimensions = Vector2(160, 160)
	
	var width = get_parent().get_rect().size.x
	var height = get_parent().get_rect().size.y
	
	var width_scale = width / _dimensions.x
	var height_scale = height / _dimensions.y
	
	if width_scale < height_scale:
		_base_scale = Vector2(width_scale, width_scale)
	else:
		_base_scale = Vector2(height_scale, height_scale)
		
	_context.scale = _base_scale

	_update_rect()
	
	var configuration = {
		"width": 20,
		"height": 20,
		"tile_size": 8,
		"tile": "./resources/Kanto/Water.png"
	}
	var layer = preload("res://layers/Background.tscn").instance()
	add_child(layer)
	layer.init(configuration, _context)

	configuration = {
		"width": 20,
		"height": 20,
		"tile_size": 8,
		"tileset": [
			{
				"texture": "./resources/Kanto/Land.png",
				"layer": "land",
				"variations": [
					{
						"conditions": [["North", "East"]],
						"texture": "./resources/Kanto/Land-NE.png"
					},
					{
						"conditions": [["North", "West"]],
						"texture": "./resources/Kanto/Land-NW.png"
					},
					{
						"conditions": [["South", "East"]],
						"texture": "./resources/Kanto/Land-SE.png"
					},
					{
						"conditions": [["South", "West"]],
						"texture": "./resources/Kanto/Land-SW.png"
					}
				]
			},
			{
				"texture": "./resources/Kanto/Path.png",
				"layer": "path",
				"material": "path"
			},
			{
				"texture": "./resources/Kanto/WaterPath.png",
				"layer": "path",
				"material": "path",
				"variations": [
					{
						"conditions": [["East", "West"], ["East"], ["West"]],
						"texture": "./resources/Kanto/WaterPath-H.png"
					},
					{
						"conditions": [["North", "South"], ["North"], ["South"]],
						"texture": "./resources/Kanto/WaterPath-V.png"
					}
				]
			},
			{
				"texture": "./resources/Kanto/City.png",
				"layer": "location"
			},
			{
				"texture": "./resources/Kanto/Town.png",
				"layer": "location"
			}
		]
	}
	layer = preload("res://layers/TileMap.tscn").instance()
	add_child(layer)
	layer.init(configuration, _context)
	layer.connect("register_action", self, "_register_action", [1])
	
	add_child(get_child(_selected_layer).get_overlay())
	
	get_node("../../ToolBox").add_child(get_child(_selected_layer).get_tool_box())

func _draw():
	for i in range(_n_layers):
		get_child(i).update()
			
func _update_rect():
	var width = get_parent().get_rect().size.x
	var height = get_parent().get_rect().size.y

	var x_offset = (width - (_dimensions.x * _context.scale.x)) / 2
	var h_scrollbar = 0
	if x_offset < 0:
		h_scrollbar = -x_offset
		x_offset = 0

	var y_offset = (height - (_dimensions.y * _context.scale.y)) / 2
	var v_scrollbar = 0
	if y_offset < 0:
		v_scrollbar = -y_offset
		y_offset = 0

	y_offset = y_offset if y_offset > 0 else 0

	_context.pos = Vector2(x_offset, y_offset)

	set_custom_minimum_size(_dimensions * _context.scale + _context.pos * 2)
	
	update()

	yield(get_parent().get_v_scrollbar(), "changed")
	get_parent().scroll_vertical = v_scrollbar

	yield(get_parent().get_h_scrollbar(), "changed")
	get_parent().scroll_horizontal = h_scrollbar

func _register_action(data, layer : int):
	_next_actions.clear()
	_previous_actions.append({"layer": layer, "data": data})
	
	if _previous_actions.size() > 20:
		_previous_actions.pop_front()

func _undo():
	if _previous_actions.size() > 0:
		var action = _previous_actions.pop_back()
		var data = get_child(action.layer).apply(action.data)
		_next_actions.append({"layer": action.layer, "data": data})

func _redo():
	if _next_actions.size() > 0:
		var action = _next_actions.pop_back()
		var data = get_child(action.layer).apply(action.data)
		_previous_actions.append({"layer": action.layer, "data": data})

func _update_scale_factor(percentage : float):
	_context.scale = _base_scale * (2.5 * percentage + 0.25)
	_update_rect()
	
func _gui_input(event):
	if event is InputEventMouseButton:
		if event.is_pressed():
			if event.button_index == BUTTON_WHEEL_UP:
				get_node("../../MagnifyingGlass")._add_to_magnifying_factor(5)
			elif event.button_index == BUTTON_WHEEL_DOWN:
				get_node("../../MagnifyingGlass")._add_to_magnifying_factor(-5)
	
func _set_pencil_tile(tile_id : int):
	get_child(1).set_pencil_tile(tile_id)
	
func _set_tool(tool_id : int):
	get_child(1).set_tool(tool_id)

func _save():
	var image = Image.new()
	image.copy_from(get_child(0).get_image())
	
	for i in range(_n_layers):
		image.blend_rect(get_child(i).get_image(), Rect2(Vector2.ZERO, get_child(i).get_image().get_size()), Vector2.ZERO)
		
	image.resize(480, 480, Image.INTERPOLATE_NEAREST)
	image.save_png("./salida_1234.png")
