class_name Tilemap


enum Tool{
	PENCIL,
	WRENCH,
	ERASER,
	BUCKET_FILL
}


var _width := 0
var _height := 0
var _tile_set := {}
var _tilemap_layers := []
var _background := Image.new()
var _selected_tile := Tile.new()


func init(canvas_conf: Dictionary, layer_conf: Dictionary):
	_width = canvas_conf.Width
	_height = canvas_conf.Height
	_tile_set = layer_conf.TileSet

	for i in layer_conf.NumberOfLayers:
		var tilemap_layer = TilemapLayer.new()

		tilemap_layer.init(_width, _height, layer_conf.TileSize, _tile_set)

		_tilemap_layers.append(tilemap_layer)

	_create_background(_width, _height, layer_conf.TileSize,
			layer_conf.Background)

	_selected_tile = _tile_set[0]


func get_image() -> Image:
	var image = Image.new()
	var pos = Vector2.ZERO
	var rect = Rect2(pos, _background.get_size())

	image.copy_from(_background)
	for tilemap_layer in _tilemap_layers:
		image.blend_rect(tilemap_layer.get_image(), rect, pos)

	return image


func select_tile(tile_id: int):
	_selected_tile = _tile_set[tile_id]


func place_tile(i: int, j: int):
	var selected_layer = _tilemap_layers[_selected_tile.get_layer()]
	selected_layer.set_tile(i, j, _selected_tile)


func erase_tile(i: int, j: int):
	var selected_layer = _tilemap_layers[_selected_tile.get_layer()]
	selected_layer.set_tile(i, j, _tile_set[Tile.Special_tile.AIR])


func change_tile_state(i: int, j: int):
	var selected_layer = _tilemap_layers[_selected_tile.get_layer()]
	selected_layer.change_tile_state(i, j)


func fill(i: int, j: int):
	if(i >= 0 and i < _height and j >= 0 and j < _width):
		var tile_to_replace = _get_top_tile(i, j)
		var selected_layer = _tilemap_layers[_selected_tile.get_layer()]
		var w = _selected_tile.get_structure_size()[0]
		var h = _selected_tile.get_structure_size()[1]

		if tile_to_replace.get_id() == _selected_tile.get_id():
			return

		var process_now = []

		var can_be_processed = true
		for subtile in _selected_tile.get_subtiles():
			var pos_i = i - subtile[1]
			var pos_j = j + subtile[0]

			if(pos_i >= 0 and pos_i < _height and pos_j >= 0
					and pos_j < _width):
				if (_get_top_tile(pos_i, pos_j).get_id()
						!= tile_to_replace.get_id()):
					can_be_processed = false

		if can_be_processed:
			process_now.append(Vector2(i, j))

		var process_next = []

		var marked = []
		for i in range(_height):
			marked.append([])
			for j in range(_width):
				marked[i].append([])
				marked[i][j] = false

		while process_now.size() != 0:
			process_next = []

			for pos in process_now:
				selected_layer.set_tile(pos.x, pos.y, _selected_tile)

				can_be_processed = true
				for subtile in _selected_tile.get_subtiles():
					var pos_x = pos.x + w - subtile[1]
					var pos_y = pos.y + subtile[0]
		
					if (_get_top_tile(pos_x, pos_y).get_id()
							!= tile_to_replace.get_id()):
						can_be_processed = false

				if can_be_processed:
					if marked[pos.x + w][pos.y] == false:
						process_next.append(Vector2(pos.x + w, pos.y))
						marked[pos.x + w][pos.y] = true

				can_be_processed = true
				for subtile in _selected_tile.get_subtiles():
					var pos_x = pos.x - subtile[1]
					var pos_y = pos.y + h + subtile[0]
		
					if (_get_top_tile(pos_x, pos_y).get_id()
							!= tile_to_replace.get_id()):
						can_be_processed = false

				if can_be_processed:
					if marked[pos.x][pos.y + h] == false:
						process_next.append(Vector2(pos.x, pos.y + h))
						marked[pos.x][pos.y + h] = true

				can_be_processed = true
				for subtile in _selected_tile.get_subtiles():
					var pos_x = pos.x - w - subtile[1]
					var pos_y = pos.y + subtile[0]
		
					if (_get_top_tile(pos_x, pos_y).get_id()
							!= tile_to_replace.get_id()):
						can_be_processed = false

				if can_be_processed:
					if marked[pos.x - w][pos.y] == false:
						process_next.append(Vector2(pos.x - w, pos.y))
						marked[pos.x - w][pos.y] = true

				can_be_processed = true
				for subtile in _selected_tile.get_subtiles():
					var pos_x = pos.x - subtile[1]
					var pos_y = pos.y - h + subtile[0]
		
					if (_get_top_tile(pos_x, pos_y).get_id()
							!= tile_to_replace.get_id()):
						can_be_processed = false

				if can_be_processed:
					if marked[pos.x][pos.y - h] == false:
						process_next.append(Vector2(pos.x, pos.y - h))
						marked[pos.x][pos.y - h] = true

			process_now = process_next


func erase_tile_in_every_layer(i: int, j: int):
	for tilemaplayer in _tilemap_layers:
		tilemaplayer.set_tile(i, j, _tile_set[Tile.Special_tile.AIR])


func retrieve_previous_tilemap():
	var tilemap_layers = []
	for i in range(_tilemap_layers.size()):
		if _tilemap_layers[i].has_been_modified():
			tilemap_layers.append({
				"ID": i,
				"TileMap": _tilemap_layers[i].retrieve_previous_tilemaplayer()
			})

	return tilemap_layers


func load_tilemap(tilemaplayers : Array):
	for tilemaplayer in tilemaplayers:
		_tilemap_layers[tilemaplayer.ID].load_tilemaplayer(tilemaplayer.TileMap)


func _create_background(width: int, height: int, tile_size: int,
		background_tile : Image):
	var background_size = Vector2(tile_size * width, tile_size * height)
	_background = GoostImage.tile(background_tile, background_size)


func _get_top_tile(i: int, j: int) -> Tile:
	for it in range(_tilemap_layers.size() - 1, -1, -1):
		var tile = _tilemap_layers[it].get_tile(i, j)

		if tile.get_id() != Tile.Special_tile.AIR:
			return tile

	return _tile_set[Tile.Special_tile.AIR]
