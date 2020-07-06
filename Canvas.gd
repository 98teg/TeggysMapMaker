extends Control

var _background_layer = _BackgroundLayer.new()
var _background_texture = ImageTexture.new()

var _tilemap_layer = _TileMapLayer.new()
var _tilemap_texture = ImageTexture.new()

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
    _tilemap_layer.init(configuration)
    _tilemap_texture.create_from_image(_tilemap_layer.get_image())

func _draw():
    draw_texture(_background_texture, Vector2.ZERO)
    draw_texture(_tilemap_texture, Vector2.ZERO)

func _input(event):
    _tilemap_layer.input(event)
    if _tilemap_layer.needs_update():
        _tilemap_texture.set_data(_tilemap_layer.get_image())
        update()
        _tilemap_layer.has_been_updated()
