extends Control

var _tile_size = 24
var _width = 20
var _height = 20

var _background = Image.new()
var _background_tex = ImageTexture.new()

var _water_tile = ImageIndexed.new()

var _map = create_matrix(_width, _height)

func _ready():
    _water_tile.load("./resources/Kanto/Water.png")
    _water_tile.convert(Image.FORMAT_RGBA8)

    if not _water_tile.has_palette():
        _water_tile.generate_palette(2)
    
    _water_tile.set_palette_color(0, Color.cyan)
    _water_tile.apply_palette()

    _water_tile.resize(_tile_size, _tile_size, Image.INTERPOLATE_NEAREST)
    _water_tile.lock()
    
    _background = GoostImage.tile(_water_tile, Vector2(_tile_size*_width, _tile_size*_height))
    
    _background_tex.create_from_image(_background, 3)

func _draw():
    draw_texture(_background_tex, Vector2.ZERO)
            
func create_matrix(width : int, height : int):
    var matrix = []
    for x in range(width):
        matrix.append([])
        for y in range(height):
            matrix[x].append([])
            matrix[x][y] = 0
            
    return matrix
