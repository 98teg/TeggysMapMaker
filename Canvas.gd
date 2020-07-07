extends Control

var _background_layer = _BackgroundLayer.new()
var _background_texture = ImageTexture.new()

var _land_layer = _TileMapLayer.new()
var _land_texture = ImageTexture.new()

var _path_layer = _TileMapLayer.new()
var _path_texture = ImageTexture.new()

var _city_layer = _TileMapLayer.new()
var _city_texture = ImageTexture.new()

var _selected_layer = 0

func _ready():
    var configuration = {
        "width": 20,
        "height": 20,
        "tile_size": 8,
        "tile": "./resources/Kanto/Water.png"
    }
    _background_layer.init(configuration)
    _background_texture.create_from_image(_background_layer.get_image())

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
    _land_layer.init(configuration)
    _land_texture.create_from_image(_land_layer.get_image())
    
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
    _path_layer.init(configuration)
    _path_texture.create_from_image(_land_layer.get_image())
    
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
    _city_layer.init(configuration)
    _city_texture.create_from_image(_city_layer.get_image())

func _draw():
    draw_texture(_background_texture, Vector2.ZERO)
    draw_texture(_land_texture, Vector2.ZERO)
    draw_texture(_path_texture, Vector2.ZERO)
    draw_texture(_city_texture, Vector2.ZERO)

func _input(event):
    match _selected_layer:
        0:
            _land_layer.input(event)
            if _land_layer.needs_update():
                _land_texture.set_data(_land_layer.get_image())
                update()
                _land_layer.has_been_updated()
        1:  
            _path_layer.input(event)
            if _path_layer.needs_update():
                _path_texture.set_data(_path_layer.get_image())
                update()
                _path_layer.has_been_updated()
        2:
            _city_layer.input(event)
            if _city_layer.needs_update():
                _city_texture.set_data(_city_layer.get_image())
                update()
                _city_layer.has_been_updated()
        
func select_layer(layer_id : int):
    _selected_layer = layer_id
    
func set_pencil_tile(tile_id : int):
    match _selected_layer:
        0:
            _land_layer.set_pencil_tile(tile_id)
        1:  
            _path_layer.set_pencil_tile(tile_id)
        2:
            _city_layer.set_pencil_tile(tile_id)
