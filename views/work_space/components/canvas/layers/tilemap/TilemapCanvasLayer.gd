extends Control

# Custom signals

signal register_action(data)

# Private variables

var _tile_size : int = 0
var _tilemap := TMM_TileMapController.new()
var _tilemap_tex : ImageTexture = ImageTexture.new()
var _overlay : Control
var _tool_box : Control
var _tool = TMM_TileMapHelper.Tool.PENCIL
var _drawing = false
var _placing_tiles : bool
var _previous_pos
var _has_tiles : bool = false

# Layer public functions

func init(canvas_conf : Dictionary, layer_conf : Dictionary):
	_tile_size = layer_conf.TileSize
	_create_tilemap(canvas_conf, layer_conf)
	_create_overlay(canvas_conf, layer_conf)
	_create_tool_box(layer_conf)
	
	if layer_conf.TileSet.size() > 0: _has_tiles = true

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

# Layer private functions

func _create_tilemap(canvas_conf : Dictionary, layer_conf : Dictionary):
	_tilemap.init(canvas_conf, layer_conf)
	_tilemap_tex.create_from_image(_tilemap.get_image(), 3)
	
func _create_overlay(canvas_conf : Dictionary, layer_conf : Dictionary):
	_overlay = preload("./overlay/TilemapOverlay.tscn").instance()

	_overlay.init(canvas_conf, layer_conf)
	
func _create_tool_box(layer_conf : Dictionary):
	_tool_box = preload("./toolbox/TilemapToolBox.tscn").instance()
	if _tool_box.connect("tile_selected", self, "_select_tile") != OK:
		print("Error connecting ToolBox's 'tile_selected' signal")
	if _tool_box.connect("tool_selected", self, "_select_tool") != OK:
		print("Error connecting ToolBox's 'tool_selected' signal")
	if _tool_box.connect("grid_visibility_changed", _overlay, "set_grid_visibility") != OK:
		print("Error connecting ToolBox's 'grid_visibility_changed' signal")
	if _tool_box.connect("tile_selected", _overlay, "set_squares") != OK:
		print("Error connecting ToolBox's 'set_squares' signal")
	if _tool_box.connect("tool_selected", _overlay, "set_tool") != OK:
		print("Error connecting ToolBox's 'set_squares' signal")

	_tool_box.init(layer_conf)

func _select_tile(tile_id : int):
	_tilemap.select_tile(tile_id)

func _select_tool(tool_id : int):
	_tool = tool_id

func _draw():
	draw_texture(_tilemap_tex, Vector2.ZERO)
	
	_overlay.update()

func _gui_input(event):
	var position = (get_local_mouse_position() / _tile_size).floor()

	if _has_tiles:
		if event is InputEventMouseButton:
			_mouse_button(event.get_button_index(), event.is_pressed(), position)
		elif event is InputEventMouseMotion:
			_mouse_motion(position)

func _mouse_button(button_index : int, is_pressed : bool, position : Vector2):
	match _tool:
		TMM_TileMapHelper.Tool.PENCIL:
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

		TMM_TileMapHelper.Tool.WRENCH:
			if button_index == BUTTON_LEFT:
				if is_pressed:
					_change_tile_state(int(position.y), int(position.x))

		TMM_TileMapHelper.Tool.ERASER:
			if button_index == BUTTON_LEFT:
				if is_pressed:
					_start_drawing(position)
					_draw_line(position)
				else:
					_end_drawing()

		TMM_TileMapHelper.Tool.BUCKET_FILL:
			if button_index == BUTTON_LEFT:
				if is_pressed:
					_fill(int(position.y), int(position.x))

func _mouse_motion(position : Vector2):
	if _drawing:
		_draw_line(position)

	_overlay.highlight(position.x, position.y)

func _start_drawing(position : Vector2):
	_drawing = true
	_previous_pos = position

func _draw_line(position : Vector2):
	var p0 = _previous_pos
	var p1 = position

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

	_previous_pos = position

	_update_layer()

func _end_drawing():
	_register_action()
	_drawing = false

func _set_tile(i : int, j : int):
	match _tool:
		TMM_TileMapHelper.Tool.PENCIL:
			if _placing_tiles:
				_tilemap.place_tile(i, j)
			else:
				_tilemap.erase_tile(i, j)
		TMM_TileMapHelper.Tool.ERASER:
			_tilemap.erase_tile_in_every_layer(i, j)

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

func _mouse_entered():
	match _tool:
		TMM_TileMapHelper.Tool.PENCIL:
			var image = load("res://resources/icons/pencil.png")
			var hotspot = Vector2(0, image.get_size().y)
			Input.set_custom_mouse_cursor(image, 0, hotspot)

		TMM_TileMapHelper.Tool.WRENCH:
			var image = load("res://resources/icons/wrench.png")
			var hotspot = Vector2(image.get_size().x, 0)
			Input.set_custom_mouse_cursor(image, 0, hotspot)

		TMM_TileMapHelper.Tool.ERASER:
			var image = load("res://resources/icons/eraser.png")
			var hotspot = Vector2(0, image.get_size().y)
			Input.set_custom_mouse_cursor(image, 0, hotspot)

		TMM_TileMapHelper.Tool.BUCKET_FILL:
			var image = load("res://resources/icons/bucket_fill.png")
			var hotspot = Vector2(0, image.get_size().y)
			Input.set_custom_mouse_cursor(image, 0, hotspot)

func _mouse_exited():
	_overlay.highlight(-1, -1)
	Input.set_custom_mouse_cursor(null)
