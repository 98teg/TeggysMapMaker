class_name _Tile

var _images = []
var _conditions_for_each_state = {}

enum Connection_type{
    NONE,
    CROSS,
    FULL
}

var _connection_type

func create_tile(image : Image, connection_type : int = Connection_type.NONE):
    add_state(image)
    _connection_type = connection_type
    
func get_connection_type() -> int:
    return _connection_type
    
func add_state(image : Image, conditions : Array = []):
    _images.append(image)
    var state = _images.size() - 1
    
    for condition in conditions:
        _conditions_for_each_state[condition] = state
        
func get_image(state : int = 0) -> Image:
    return _images[state]
    
func get_state(condition : int) -> int:
    if _conditions_for_each_state.has(condition):
        return _conditions_for_each_state[condition]
    else:
        return 0
        
func get_n_states() -> int:
    return _images.size()
