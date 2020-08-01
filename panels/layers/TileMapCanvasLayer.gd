extends Control

# Custom signals

signal register_action(data)

# Custom enums

enum Tool{
	PENCIL,
	WRENCH,
	ERASER,
	BUCKET_FILL
}

# Private variables

var _tilemap : _TileMap = _TileMap.new()
var _tilemap_tex : ImageTexture = ImageTexture.new()
var _overlay : Control
var _tool_box : Control

var _tool = Tool.PENCIL
var _drawing = false
var _placing_tiles : bool
var _previous_pos

# Layer public functions

func init(configuration : Dictionary):
	_set_tilemap(configuration)
	_create_overlay(configuration)
	_create_tool_box()
	
func get_image():
	return _tilemap.get_image()
	
func get_overlay():
	return _overlay
	
func get_tool_box():
	return _tool_box

func apply_action(data):
	_tilemap.load_tilemap(data)
	_register_action()
	_update_layer()

func select_tile(tile_id : int):
	_tilemap.select_tile(tile_id)
	_overlay.set_image(_tilemap.get_selected_tile_image())

func select_tool(tool_id : int):
	_tool = tool_id
	
func toggle_grid():
	_overlay.toggle_grid()

# Layer private functions

func _set_tilemap(configuration : Dictionary):
	_tilemap.init(configuration)
	_tilemap_tex.create_from_image(_tilemap.get_image(), 3)
	
func _create_overlay(configuration : Dictionary):
	_overlay = preload("res://panels/layers/TileMapOverlay.tscn").instance()
	_overlay.init(configuration)
	_overlay.set_image(_tilemap.get_selected_tile_image())
	
func _create_tool_box():
	_tool_box = preload("res://panels/layers/TileMapToolBox.tscn").instance()
	_tool_box.init(self, _tilemap.get_tileset())
	
func _draw():
	draw_texture(_tilemap_tex, Vector2.ZERO)
	
	_overlay.update()

func _gui_input(event):
	var pos = get_local_mouse_position()

	if event is InputEventMouseButton:
		_mouse_button(event.get_button_index(), event.is_pressed(), pos)
	elif event is InputEventMouseMotion:
		_mouse_motion(pos)

func _mouse_button(button_index : int, is_pressed : bool, position : Vector2):
	match _tool:
		Tool.PENCIL:
			if button_index == BUTTON_LEFT:
				_placing_tiles = true
				if is_pressed:
					_start_drawing(position)
					_draw_line(position)
				else:
					_end_drawing()
			elif button_index == BUTTON_RIGHT:
				_placing_tiles = false
				if is_pressed:
					_start_drawing(position)
					_draw_line(position)
				else:
					_end_drawing()

		Tool.WRENCH:
			if button_index == BUTTON_LEFT:
				if is_pressed:
					var current_pos = (position / _tilemap.get_tile_size()).floor()
						
					_change_tile_state(current_pos.y, current_pos.x)

		Tool.ERASER:
			if button_index == BUTTON_LEFT:
				if is_pressed:
					_start_drawing(position)
					_draw_line(position)
				else:
					_end_drawing()

		Tool.BUCKET_FILL:
			if button_index == BUTTON_LEFT:
				if is_pressed:
					var current_pos = (position / _tilemap.get_tile_size()).floor()
						
					_fill(current_pos.y, current_pos.x)

func _mouse_motion(position : Vector2):
	if _drawing:
		_draw_line(position)
	else:
		_overlay.set_pos(position)

func _start_drawing(pos : Vector2):
	_drawing = true
	_previous_pos = (pos / _tilemap.get_tile_size()).floor()

func _draw_line(pos : Vector2):
	var current_pos = (pos / _tilemap.get_tile_size()).floor()

	var p0 = _previous_pos
	var p1 = current_pos

	var dx = abs(p1.x - p0.x)
	var sx = 1 if p0.x < p1.x else -1
	var dy = -abs(p1.y - p0.y)
	var sy = 1 if p0.y < p1.y else -1
	var err = dx + dy

	while true:
		_set_tile(p0.y, p0.x)

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

func _end_drawing():
	_register_action()
	_drawing = false

func _set_tile(i : int, j : int):
	match _tool:
		Tool.PENCIL:
			if _placing_tiles:
				_tilemap.place_tile(i, j)
			else:
				_tilemap.erase_tile(i, j)
		Tool.ERASER:
			_tilemap.erase_tile_in_every_layer(i, j)
	_update_layer()

func _change_tile_state(i : int, j : int):
	_tilemap.change_tile_state(i, j)
	_register_action()
	_update_layer()
	
func _fill(i : int, j : int):
	_tilemap.fill(i, j)
	_register_action()
	_update_layer()

func _register_action():
	var tilemap_hist = _tilemap.retrieve_previous_tilemap()
	
	if tilemap_hist.size() > 0:
		emit_signal("register_action", tilemap_hist)

func _update_layer():
	_tilemap_tex.set_data(_tilemap.get_image())
	update()
