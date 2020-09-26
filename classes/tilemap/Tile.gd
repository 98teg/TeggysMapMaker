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
var _n_states := 0
var _connections_for_each_state := {}
var _connection_type : int = Connection_type.ISOLATED
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
	_connection_type = tile_conf.ConnectionType
	_connected_group = tile_conf.ConnectedGroup
	_can_connect_to_borders = tile_conf.CanConnectToBorders

	_add_state(tile_conf.Image)

	for variation in tile_conf.Variations:
		_add_state(variation.Image, variation.Connections)

	_create_subtiles()


func get_id() -> int:
	return _id


func get_name() -> String:
	return _name


func get_icon() -> Image:
	return _icon


func get_structure_size() -> Array:
	return _structure_size


func get_layer() -> int:
	return _layer


func get_extra_tools() -> Array:
	return _extra_tools


func get_state(connection: int) -> int:
	if _connections_for_each_state.has(connection):
		return _connections_for_each_state[connection]
	else:
		return 0


func get_n_states() -> int:
	return _n_states


func get_image(state := 0, subtile := [0, 0]) -> Image:
	return _images[[state, subtile]]


func get_connection_type() -> int:
	return _connection_type


func get_subtiles(subtile_of_reference := [0, 0]) -> Array:
	if subtile_of_reference != [0, 0]:
		var subtiles = []

		for subtile in _subtiles:
			var new_subtile = [subtile[0] - subtile_of_reference[0],
					subtile[1] - subtile_of_reference[1]]
			subtiles.append(new_subtile)

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
	var state = _n_states
	_n_states += 1
	var subtile_size = image.get_size().x / _structure_size[0]
	subtile_size = Vector2(subtile_size, subtile_size)

	for i in range(_structure_size[0]):
		for j in range(_structure_size[1]):
			if _structure_colission_mask[_structure_size[1] - 1 - j][i]:
				var subtile = [i - _structure_main_tile[0],
						j - _structure_main_tile[1]]

				var pos_x = i * subtile_size.x
				var pos_y = image.get_size().y - (subtile_size.y * (j + 1))
				var rect = Rect2(Vector2(pos_x, pos_y), subtile_size)

				_images[[state, subtile]] = image.get_rect(rect)

	for connection in connections:
		_connections_for_each_state[connection] = state


func _create_subtiles():
	for i in range(_structure_size[0]):
		for j in range(_structure_size[1]):
			if _structure_colission_mask[_structure_size[1] - 1 - j][i]:
				var subtile = [i - _structure_main_tile[0],
						j - _structure_main_tile[1]]

				_subtiles.append(subtile)
