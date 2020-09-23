class_name TilemapLayer


var _tilemap_sublayers := [TilemapSubLayer.new()]


func init(width: int, height: int, tile_size: int, tileset: Array,
		special_tileset: Dictionary):
	_tilemap_sublayers[0].init(width, height, tile_size, tileset, special_tileset)


func get_image() -> Image:
	return _tilemap_sublayers[0].get_image()


func get_tile(i: int, j: int) -> Tile:
	return _tilemap_sublayers[0].get_tile(i, j)


func set_tile(i: int, j: int, tile: Tile):
	_tilemap_sublayers[0].set_tile(i, j, tile)


func change_tile_state(i: int, j: int):
	_tilemap_sublayers[0].change_tile_state(i, j)


func has_been_modified():
	return _tilemap_sublayers[0].has_been_modified()


func retrieve_previous_tilemaplayer():
	return _tilemap_sublayers[0].retrieve_previous_tilemapsublayer()


func load_tilemaplayer(map : Array):
	_tilemap_sublayers[0].load_tilemapsublayer(map)
