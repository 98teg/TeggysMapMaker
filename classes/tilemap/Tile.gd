class_name Tile


enum Special_tile {
	AIR = -1,
	OUT_OF_BOUNDS = -2,
	UNSELECTED = -3
}


enum Connection_type {
	ISOLATED,
	CROSS,
	CIRCLE
}


var _id := 0
var _name := ""
var _icon : Image
var _structure_size := [1, 1]
var _structure_colission_mask := []
var _structure_main_tile := []
var _layer := 0
var _extra_tools := []
var _subtiles := []
var _images := {}
var _connections_for_each_state := {}
var _connection_type : int
var _connected_group := 0
var _can_connect_to_borders := true


func init(tile_conf: Dictionary):
	_id = tile_conf.ID
	_name = tile_conf.Name
	_icon = tile_conf.Icon
	_structure_size = tile_conf.Structure.Size
	_structure_colission_mask = tile_conf.Structure.ColissionMask
	_structure_main_tile = tile_conf.Structure.MainTile
	_layer = tile_conf.Layer
	_extra_tools = tile_conf.ExtraTools

	_add_state(tile_conf.Image)

	_connection_type = tile_conf.ConnectionType

	for variation in tile_conf.Variations:
		_add_state(variation.Image, variation.Connections)

	_connected_group = tile_conf.ConnectedGroup

	_can_connect_to_borders = tile_conf.CanConnectToBorders


func get_id() -> int:
	return _id


func get_name() -> String:
	return _name


func get_icon() -> Image:
	return _icon


func get_extra_tools() -> Array:
	return _extra_tools


func get_layer() -> int:
	return _layer


func get_state(connection: int) -> int:
	if _connections_for_each_state.has(connection):
		return _connections_for_each_state[connection]
	else:
		return 0


func get_n_states() -> int:
	return _images.size()


func get_image(state := 0, i := 0, j := 0) -> Image:
	return _images[[state, i, j]]


func get_connection_type() -> int:
	return _connection_type


func get_subtiles(i := 0, j := 0) -> Array:
	if i != 0 or j != 0:
		var subtiles = []
	
		for subtile in _subtiles:
			subtiles.append([subtile[0] - i, subtile[1] - j])

		return subtiles
	return _subtiles


func can_connect_to(another_tile: Tile) -> bool:
	if another_tile._id == Special_tile.AIR:
		return false
	elif another_tile._id == Special_tile.OUT_OF_BOUNDS:
		return _can_connect_to_borders
	else:
		if _id == another_tile._id:
			return true
		else:
			var same_group = _connected_group == another_tile._connected_group
			return same_group and _connected_group != 0


func is_a_multi_title() -> bool:
	return _structure_size != [1, 1]


func _add_state(image : Image, connections : Array = []):
	var state = _images.size()
	var size = image.get_size().x / _structure_size[0]
	size = Vector2(size, size)

	for i in range(_structure_size[0]):
		for j in range(_structure_size[1]):
			if _structure_colission_mask[_structure_size[1] - 1 - j][i]:
				_subtiles.append([i - _structure_main_tile[0],
						j - _structure_main_tile[1]])
	
				var x = i * size.x
				var y = image.get_size().y - (size.y * (j + 1))
				var rect = Rect2(Vector2(x, y), size)
	
				_images[[state, i - _structure_main_tile[0],
						j - _structure_main_tile[1]]] = image.get_rect(rect)
	
	for connection in connections:
		_connections_for_each_state[connection] = state
