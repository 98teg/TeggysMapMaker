class_name _Tile

# Special kinds of tiles
enum Special_tile {
	AIR = -1,
	OUT_OF_BOUNDS = -2
}

# Connection types
enum Connection_type {
	ISOLATED,
	CROSS,
	CIRCLE
}

# Local variables
var _id : int
var _layer : int
var _images : Array = []
var _conditions_for_each_state : Dictionary = {}
var _connection_type : int
var _material : String = ""
var _can_connect_to_borders : bool = true

func init(id : int, layer : int, image : Image, connection_type : int = Connection_type.ISOLATED, material : String = ""):
	_id = id
	_layer = layer
	add_state(image)
	_connection_type = connection_type
	_material = material
	
func add_state(image : Image, conditions : Array = []):
	_images.append(image)
	var state = _images.size() - 1
	
	for condition in conditions:
		_conditions_for_each_state[condition] = state
	
func get_layer() -> int:
	return _layer
	
func get_state(condition : int) -> int:
	if _conditions_for_each_state.has(condition):
		return _conditions_for_each_state[condition]
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
		if self._id == another_tile._id:
			return true
		else:
			return self._material == another_tile._material and self._material != ""
			
static func is_a_special_tile(tile_id : int) -> bool:
	return tile_id < 0
