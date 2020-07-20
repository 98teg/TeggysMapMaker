extends Control

var _selected_layer = 1

var _dimensions
var _base_scale = 1
var _scale_factor = 1

var _allow_action = true

var _context = {}

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

	update_rect()
	
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
	
	layer = preload("res://overlays/Grid.tscn").instance()
	add_child(layer)
	layer.init(configuration, _context)

func _draw():
	for child in get_children():
		child.update()

func _input(event):
	if _allow_action:
		var pos = ((get_local_mouse_position() - _context.pos) / _context.scale).floor()
		var i = _selected_layer
		
		if event is InputEventMouseButton:
			get_child(1).mouse_button(event.get_button_index(), event.is_pressed(), pos)
		elif event is InputEventMouseMotion:
			get_child(1).mouse_motion(pos)
			
func update_rect():
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

func add_to_scale_factor(delta : float):
	if delta > 0:
		if _scale_factor < 2.5:
			_scale_factor += delta
	else:
		if _scale_factor > 0.25:
			_scale_factor += delta

	_context.scale = _base_scale * _scale_factor
	update_rect()
	
func set_pencil_tile(tile_id : int):
	var i = _selected_layer
	
	get_child(1).set_pencil_tile(tile_id)
	
func set_tool(tool_id : int):
	var i = _selected_layer

	get_child(1).set_tool(tool_id)

func _on_Canvas_focus_entered():
	_allow_action = true

func _on_Canvas_focus_exited():
	_allow_action = true

func save():
	var image = Image.new()
	image.copy_from(get_child(0).get_image())
	
	for child in get_children():
		image.blend_rect(child.get_image(), Rect2(Vector2.ZERO, child.get_image().get_size()), Vector2.ZERO)
		
	image.resize(480, 480, Image.INTERPOLATE_NEAREST)
	image.save_png("./salida_1234.png")


func _on_Canvas_resized():
	for child in get_children():
		child.resize(_dimensions * _context.scale + _context.pos * 2)
