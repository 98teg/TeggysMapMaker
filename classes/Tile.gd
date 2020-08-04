extends Node

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

enum Tool{
	PENCIL,
	WRENCH,
	ERASER,
	BUCKET_FILL
}

# Private variables

var _id : int = 0
var _name : String = ""
var _layer : int = 0
var _extra_tools : Array = []
var _tile_size : int = 0
var _images : Array = []
var _conditions_for_each_state : Dictionary = {}
var _connection_type : int
var _material : String = ""
var _can_connect_to_borders : bool = true

# Class public functions

func init(configuration : Dictionary):
	_id = configuration.id
	_name = configuration.name
	_layer = configuration.layer
	_tile_size = configuration.tile_size
	
	if configuration.has("extra_tools"):
		for extra_tool in configuration.extra_tools:
			match extra_tool:
				"Wrench":
					_extra_tools.append(Tool.WRENCH)
				"BucketFill":
					_extra_tools.append(Tool.BUCKET_FILL)

	_add_state(_get_image(configuration.texture))

	if configuration.has("variations"):
		_connection_type = _get_connection_type(configuration.variations)

		for variation in configuration.variations:
			var conditions = []
			for condition in variation.conditions:
				conditions.append(_get_condition_id(_connection_type, condition))

			_add_state(_get_image(variation.texture), conditions)
	else:
		_connection_type = Connection_type.ISOLATED

	if configuration.has("material"):
			_material = configuration.material

func init_special_tile(id : int, tile_size : int):
	_id = id
	_layer = 0
	_tile_size = tile_size
	
	var empty_tile_image = Image.new()
	empty_tile_image.create(_tile_size, _tile_size, false, Image.FORMAT_RGBA8)
	empty_tile_image.fill(Color.transparent)
	
	_add_state(empty_tile_image)

func get_id() -> int:
	return _id

func get_name() -> String:
	return _name

func get_layer() -> int:
	return _layer

func get_extra_tools() -> Array:
	return _extra_tools

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

# Class private functions
	
func _add_state(image : Image, conditions : Array = []):
	_images.append(image)
	var state = _images.size() - 1
	
	for condition in conditions:
		_conditions_for_each_state[condition] = state

func _get_image(path : String):
	var image = Image.new()

	var dir = get_node("/root/StyleDirectory")
	image.load(dir.get_current_dir() + "/" + path)
	image.convert(Image.FORMAT_RGBA8)
	image.resize(_tile_size, _tile_size, Image.INTERPOLATE_NEAREST)
	image.lock()

	return image

func _get_connection_type(variations : Array):
	var connection_type = Connection_type.CROSS

	for variation in variations:
		for condition in variation.conditions:
			for tile_place in condition:
				if (tile_place == "NorthEast" or tile_place == "NorthWest" or
					tile_place == "SouthEast" or tile_place == "SouthWest"):
					connection_type = Connection_type.CIRCLE
				break
		if connection_type == Connection_type.CIRCLE:
			break

	return connection_type

func _get_condition_id(connection_type : int, conditions : Array) -> int:
	var condition_id = 0

	if connection_type == Connection_type.CROSS:
		for tile_place in conditions:
			match tile_place:
				"North":
					condition_id += 1
				"East":
					condition_id += 2
				"South":
					condition_id += 4
				"West":
					condition_id += 8
	else:
		for tile_place in conditions:
			match tile_place:
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
