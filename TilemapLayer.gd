class_name _TileMapLayer

var _tilemap = _TileMap.new()

var _needs_update = false

enum Tools{
	PENCIL,
	ERASER,
	WRENCH
}

var _tool = Tools.PENCIL

var _drawing = false
var _selected_tile
var _previous_pos

var _pencil_tile = 1
var _has_moved = false

func init(configuration : Dictionary):
	_tilemap.init_tilemap(configuration.width, configuration.height, configuration.tile_size)
	
	for tile in configuration.tileset:
		var default_texture = load_image(tile.texture)
		
		if tile.has("variations"):
			var connection_type = check_connection_type(tile.variations)

			if tile.has("type"):
				_tilemap.create_tile(default_texture, connection_type, tile.type)
			else:
				_tilemap.create_tile(default_texture, connection_type)
			
			for variation in tile.variations:
				var conditions = []
				for condition in variation.conditions:
					conditions.append(get_condition_id(condition, connection_type))

				_tilemap.add_variation_to_last_tile(load_image(variation.texture), conditions)
		else:
			if tile.has("type"):
				_tilemap.create_tile(default_texture, _Tile.Connection_type.NONE, tile.type)
			else:
				_tilemap.create_tile(default_texture, _Tile.Connection_type.NONE)

func needs_update():
	return _needs_update

func get_image():
	return _tilemap.get_tilemap_image()
	
func has_been_updated():
	_needs_update = false
			
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
			_selected_tile = 0
			if is_pressed:
				start_drawing(position)
				draw(position)
			else:
				end_drawing()
	else:
		if button_index == BUTTON_LEFT:
			if is_pressed:
				_has_moved = false
			else:
				if _has_moved == false:
					var current_pos = (position / _tilemap.get_tile_size()).floor()
					
					change_tile_state(current_pos.y, current_pos.x)
			
func mouse_motion(position : Vector2):
	if _drawing:
		draw(position)
	
	_has_moved = true
			
func set_pencil_tile(tile_id : int):
	_pencil_tile = tile_id
	
func set_tool(tool_id : int):
	_tool = tool_id
			
func load_image(path : String):
	var image = Image.new()

	image.load(path)
	image.convert(Image.FORMAT_RGBA8)

	var tile_size = _tilemap.get_tile_size()
	image.resize(tile_size, tile_size, Image.INTERPOLATE_NEAREST)

	image.lock()

	return image
			
func check_connection_type(variations : Array):
	var connection_type = _Tile.Connection_type.CROSS
	
	for variation in variations:
		for condition in variation.conditions:
			for tile in condition:
				if (tile == "NorthEast" or tile == "NorthWest" or
					tile == "SouthEast" or tile == "SouthWest"):
					connection_type = _Tile.Connection_type.FULL
				break
		if connection_type == _Tile.Connection_type.FULL:
			break
	
	return connection_type
			
func get_condition_id(condition : Array, connection_type : int) -> int:
	var condition_id = 0
	
	if connection_type == _Tile.Connection_type.CROSS:
		for tile in condition:
			match tile:
				"North":
					condition_id += 1
				"East":
					condition_id += 2
				"South":
					condition_id += 4
				"West":
					condition_id += 8
	else:
		for tile in condition:
			match tile:
				"North":
					condition_id += 1
				"NorthEast":
					condition_id += 2
				"East":
					condition_id += 4
				"SouthEast":
					condition_id += 8
				"South":
					condition_id += 16
				"SouthWest":
					condition_id += 32
				"West":
					condition_id += 64
				"NorthWest":
					condition_id += 128
					
	return condition_id
			
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
	_tilemap.set_tile(i, j, _selected_tile)
	asks_for_update()
	
func change_tile_state(i : int, j : int):
	_tilemap.change_tile_state(i, j)
	asks_for_update()

func asks_for_update():
	_needs_update = true
