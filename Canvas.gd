extends Control

var _layers = []
var _textures = []

var _selected_layer = 0

var _dimensions
var _pos
var _scale
var _scale_factor = 1

var _allow_action = false

func _ready():
    _dimensions = Vector2(160, 160)
    
    var width = get_parent().get_rect().size.x
    var height = get_parent().get_rect().size.y
    
    var width_scale = width / _dimensions.x
    var height_scale = height / _dimensions.y
    
    if width_scale < height_scale:
        _scale = Vector2(width_scale, width_scale)
    else:
        _scale = Vector2(height_scale, height_scale)

    update_rect()
    
    _layers.append(_BackgroundLayer.new())
    _textures.append(ImageTexture.new())
    
    var configuration = {
        "width": 20,
        "height": 20,
        "tile_size": 8,
        "tile": "./resources/Kanto/Water.png"
    }
    _layers[0].init(configuration)
    _textures[0].create_from_image(_layers[0].get_image(), 3)

    _layers.append(_TileMapLayer.new())
    _textures.append(ImageTexture.new())

    configuration = {
        "width": 20,
        "height": 20,
        "tile_size": 8,
        "tileset": [
            {
                "texture": "./resources/Kanto/Land.png",
                "variations": [
                    {
                        "conditions": [["North", "East"]],
                        "texture": "./resources/Kanto/Land-NE.png"
                    },
                    {
                        "conditions": [["North", "West"]],
                        "texture": "./resources/Kanto/Land-NW.png"
                    },
                    {
                        "conditions": [["South", "East"]],
                        "texture": "./resources/Kanto/Land-SE.png"
                    },
                    {
                        "conditions": [["South", "West"]],
                        "texture": "./resources/Kanto/Land-SW.png"
                    }
                ]
            }
        ]
    }
    _layers[1].init(configuration)
    _textures[1].create_from_image(_layers[1].get_image(), 3)
    
    _layers.append(_TileMapLayer.new())
    _textures.append(ImageTexture.new())
    
    configuration = {
        "width": 20,
        "height": 20,
        "tile_size": 8,
        "tileset": [
            {
                "texture": "./resources/Kanto/Path.png"
            },
            {
                "texture": "./resources/Kanto/WaterPath.png",
                "variations": [
                    {
                        "conditions": [["East", "West"]],
                        "texture": "./resources/Kanto/WaterPath-H.png"
                    },
                    {
                        "conditions": [["North", "South"]],
                        "texture": "./resources/Kanto/WaterPath-V.png"
                    }
                ]
            }
        ]
    }
    _layers[2].init(configuration)
    _textures[2].create_from_image(_layers[2].get_image(), 3)
    
    _layers.append(_TileMapLayer.new())
    _textures.append(ImageTexture.new())
    
    configuration = {
        "width": 20,
        "height": 20,
        "tile_size": 8,
        "tileset": [
            {
                "texture": "./resources/Kanto/City.png"
            },
            {
                "texture": "./resources/Kanto/Town.png"
            }
        ]
    }
    _layers[3].init(configuration)
    _textures[3].create_from_image(_layers[3].get_image(), 3)

func _draw():
    draw_set_transform(_pos, 0.0, get_scale())

    for texture in _textures:
        draw_texture(texture, Vector2.ZERO)

func _input(event):
    if _allow_action:
        var pos = ((get_local_mouse_position() - _pos) / get_scale()).floor()
        var i = _selected_layer + 1
        
        if event is InputEventMouseButton:
            _layers[i].mouse_button(event.get_button_index(), event.is_pressed(), pos)
        elif event is InputEventMouseMotion:
            _layers[i].mouse_motion(pos)
            
        if _layers[i].needs_update():
            _textures[i].set_data(_layers[i].get_image())
            update()
            _layers[i].has_been_updated()
            
func update_rect():
    var width = get_parent().get_rect().size.x
    var height = get_parent().get_rect().size.y

    var x_offset = (width - (_dimensions.x * get_scale().x)) / 2
    var h_scrollbar = 0
    if x_offset < 0:
        h_scrollbar = -x_offset
        x_offset = 0

    var y_offset = (height - (_dimensions.y * get_scale().y)) / 2
    var v_scrollbar = 0
    if y_offset < 0:
        v_scrollbar = -y_offset
        y_offset = 0

    y_offset = y_offset if y_offset > 0 else 0

    _pos = Vector2(x_offset, y_offset)

    set_custom_minimum_size(_dimensions * get_scale() + _pos * 2)
    
    update()

    yield(get_parent().get_v_scrollbar(), "changed")
    get_parent().scroll_vertical = v_scrollbar

    yield(get_parent().get_h_scrollbar(), "changed")
    get_parent().scroll_horizontal = h_scrollbar

func get_scale():
    return _scale * _scale_factor
    
func add_to_scale_factor(delta : float):
    if delta > 0:
        if _scale_factor < 2.5:
            _scale_factor += delta
            update_rect()
    else:
        if _scale_factor > 0.25:
            _scale_factor += delta
            update_rect()
        
func select_layer(layer_id : int):
    _selected_layer = layer_id
    
func set_pencil_tile(tile_id : int):
    var i = _selected_layer + 1
    
    _layers[i].set_pencil_tile(tile_id)

func _on_Canvas_focus_entered():
    _allow_action = true

func _on_Canvas_focus_exited():
    _allow_action = false

func save():
    var image = Image.new()
    image.copy_from(_layers[0].get_image())
    
    for layer in _layers:
        image.blend_rect(layer.get_image(), Rect2(Vector2.ZERO, layer.get_image().get_size()), Vector2.ZERO)
        
    image.resize(480, 480, Image.INTERPOLATE_NEAREST)
    image.save_png("./salida_1234.png")
