extends Control

# Custom enums

enum Tools{
	PENCIL,
	ERASER,
	WRENCH
}

# Private variables

var _tilemap : _TileMap = _TileMap.new()
var _tilemap_tex : ImageTexture = ImageTexture.new()
var _canvas_context : Dictionary
var _overlay : Control

var _tool = Tools.PENCIL
var _drawing = false
var _selected_tile
var _previous_pos
var _pencil_tile = 1

# Layer public functions

func init(configuration : Dictionary, canvas_context : Dictionary):
	_set_tilemap(configuration)
	_set_canvas_context(canvas_context)
	_create_overlay(configuration, canvas_context)
	
func get_image():
	return _tilemap.get_image()
	
func get_overlay():
	return _overlay
	
# Layer private functions

func _set_tilemap(configuration : Dictionary):
	_tilemap.init(configuration)
	_tilemap_tex.create_from_image(_tilemap.get_image(), 3)

func _set_canvas_context(canvas_context : Dictionary):
	_canvas_context = canvas_context
	
func _create_overlay(configuration : Dictionary, canvas_context : Dictionary):
	_overlay = preload("res://overlays/TileMap.tscn").instance()
	_overlay.init(configuration, canvas_context)
	
func _draw():
	draw_set_transform(_canvas_context.pos, 0.0, _canvas_context.scale)
	draw_texture(_tilemap_tex, Vector2.ZERO)
	
	_overlay.update()
	
func _gui_input(event):
	var pos = ((get_local_mouse_position() - _canvas_context.pos) / _canvas_context.scale).floor()
		
	if event is InputEventMouseButton:
		mouse_button(event.get_button_index(), event.is_pressed(), pos)
	elif event is InputEventMouseMotion:
		mouse_motion(pos)

func mouse_button(button_index : int, is_pressed : bool, position : Vector2):
	if _tool == Tools.PENCIL:
		if button_index == BUTTON_LEFT:
			_selected_tile = _pencil_tile
			if is_pressed:
				start_drawing(position)
				draw(position)
			else:
				end_drawing()
		elif button_index == BUTTON_RIGHT:
			_selected_tile = -1
			if is_pressed:
				start_drawing(position)
				draw(position)
			else:
				end_drawing()
	else:
		if button_index == BUTTON_LEFT:
			if is_pressed:
				var current_pos = (position / _tilemap.get_tile_size()).floor()
					
				change_tile_state(current_pos.y, current_pos.x)
					
			
func mouse_motion(position : Vector2):
	if _drawing:
		draw(position)
			
func set_pencil_tile(tile_id : int):
	_tilemap.select_tile(tile_id)
	_pencil_tile = tile_id
	
func set_tool(tool_id : int):
	_tool = tool_id

func start_drawing(pos : Vector2):
	_drawing = true
	_previous_pos = (pos / _tilemap.get_tile_size()).floor()

func draw(pos : Vector2):
	var current_pos = (pos / _tilemap.get_tile_size()).floor()

	var p0 = _previous_pos
	var p1 = current_pos

	var dx = abs(p1.x - p0.x)
	var sx = 1 if p0.x < p1.x else -1
	var dy = -abs(p1.y - p0.y)
	var sy = 1 if p0.y < p1.y else -1
	var err = dx + dy

	while true:
		set_tile(p0.y, p0.x)

		if p0.x == p1.x and p0.y == p1.y:
			break

		var e2 = 2*err;
		if e2 >= dy:
			err += dy
			p0.x += sx
		if e2 <= dx:
			err += dx
			p0.y += sy

	_previous_pos = current_pos

func end_drawing():
	_drawing = false

func set_tile(i : int, j : int):
	if _selected_tile == -1:
		_tilemap.erase_tile(i, j)
	else:
		_tilemap.place_tile(i, j)
	asks_for_update()

func change_tile_state(i : int, j : int):
	_tilemap.change_tile_state(i, j)
	asks_for_update()

func asks_for_update():
	_tilemap_tex.set_data(_tilemap.get_image())
	update()
