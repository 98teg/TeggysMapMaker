class_name _Tile

# Custom enums

# Special kinds of tiles
enum Special_tile {
	AIR = -1,
	OUT_OF_BOUNDS = -2,
	UNSELECTED = -3
}

# Connection types
enum Connection_type {
	ISOLATED,
	CROSS,
	CIRCLE
}

# Private variables

var _id : int = 0
var _layer : int = 0
var _images : Array = []
var _connections_for_each_state : Dictionary = {}
var _connection_type : int
var _connected_group : int = 0
var _can_connect_to_borders : bool = true

# Class public functions

func init(tile_conf : Dictionary):
	_id = tile_conf.ID
	_layer = tile_conf.Layer

	_add_state(tile_conf.Image)

	_connection_type = tile_conf.ConnectionType

	for variation in tile_conf.Variations:
		_add_state(variation.Image, variation.Connections)

	_connected_group = tile_conf.ConnectedGroup

func get_id() -> int:
	return _id

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

func can_connect_to(another_tile : _Tile) -> bool:
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

# Class private functions
	
func _add_state(image : Image, connections : Array = []):
	var state = _images.size()
	_images.append(image)
	
	for connection in connections:
		_connections_for_each_state[connection] = state
