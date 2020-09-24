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
var _layer := 0
var _extra_tools := []
var _images := []
var _connections_for_each_state := {}
var _connection_type : int
var _connected_group := 0
var _can_connect_to_borders := true


func init(tile_conf : Dictionary):
	_id = tile_conf.ID
	_name = tile_conf.Name
	_icon = tile_conf.Icon
	_layer = tile_conf.Layer
	_extra_tools = tile_conf.ExtraTools

	_add_state(tile_conf.Image)

	_connection_type = tile_conf.ConnectionType

	for variation in tile_conf.Variations:
		_add_state(variation.Image, variation.Connections)

	_connected_group = tile_conf.ConnectedGroup


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


func get_state(connection : int) -> int:
	if _connections_for_each_state.has(connection):
		return _connections_for_each_state[connection]
	else:
		return 0


func get_n_states() -> int:
	return _images.size()


func get_image(state : int = 0) -> Image:
	return _images[state]


func get_connection_type() -> int:
	return _connection_type


func can_connect_to(another_tile : Tile) -> bool:
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


func _add_state(image : Image, connections : Array = []):
	var state = _images.size()
	_images.append(image)
	
	for connection in connections:
		_connections_for_each_state[connection] = state
