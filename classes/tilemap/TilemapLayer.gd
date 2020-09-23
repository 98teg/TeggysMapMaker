class_name TilemapLayer


var _width := 0
var _height := 0
var _tile_size := 0
var _tilemap_sublayers := [TilemapSubLayer.new()]
var _tileset := []
var _special_tileset := {}
var _previous_tilemaplayer := []


func init(width: int, height: int, tile_size: int, tileset: Array,
		special_tileset: Dictionary):
	_tilemap_sublayers[0].init(width, height, tile_size, tileset, special_tileset)


func get_image() -> Image:
	return _tilemap_sublayers[0].get_image()


func set_tile(i: int, j: int, tile: Tile):
	_tilemap_sublayers[0].set_tile(i, j, tile)


func fill(i: int, j: int, tile: Tile):
	if(i >= 0 and i < _height and j >= 0 and j < _width):
		var tile_to_replace_id = _get_tile_id(i, j)

		if tile_to_replace_id == tile.get_id():
			return

		var process_now = []
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
				set_tile(pos.x, pos.y, tile)

				if _get_tile_id(pos.x + 1, pos.y) == tile_to_replace_id:
					if marked[pos.x + 1][pos.y] == false:
						process_next.append(Vector2(pos.x + 1, pos.y))
						marked[pos.x + 1][pos.y] = true

				if _get_tile_id(pos.x, pos.y + 1) == tile_to_replace_id:
					if marked[pos.x][pos.y + 1] == false:
						process_next.append(Vector2(pos.x, pos.y + 1))
						marked[pos.x][pos.y + 1] = true

				if _get_tile_id(pos.x - 1, pos.y) == tile_to_replace_id:
					if marked[pos.x - 1][pos.y] == false:
						process_next.append(Vector2(pos.x - 1, pos.y))
						marked[pos.x - 1][pos.y] = true

				if _get_tile_id(pos.x, pos.y - 1) == tile_to_replace_id:
					if marked[pos.x][pos.y - 1] == false:
						process_next.append(Vector2(pos.x, pos.y - 1))
						marked[pos.x][pos.y - 1] = true

			process_now = process_next


func change_tile_state(i: int, j: int):
	_tilemap_sublayers[0].change_tile_state(i, j)


func has_been_modified():
	return _tilemap_sublayers[0].has_been_modified()


func retrieve_previous_tilemaplayer():
	return _tilemap_sublayers[0].retrieve_previous_tilemapsublayer()


func load_tilemaplayer(map : Array):
	_tilemap_sublayers[0].load_tilemapsublayer(map)


func _get_tile_id(i: int, j: int) -> int:
	return _tilemap_sublayers[0]._get_tile_id(i, j)
