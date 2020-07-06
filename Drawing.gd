extends Control

var _tile_size = 24
var _width = 20
var _height = 20

var _background = Image.new()
var _background_tex = ImageTexture.new()
var _water_tile = ImageIndexed.new()

var _land = Image.new()
var _land_tex = ImageTexture.new()
var _land_tile = ImageIndexed.new()
var _land_empty_tile = ImageIndexed.new()
var _land_ne_tile = ImageIndexed.new()
var _land_nw_tile = ImageIndexed.new()
var _land_se_tile = ImageIndexed.new()
var _land_sw_tile = ImageIndexed.new()

var _map = create_matrix(_width, _height)

var _creating_land = false
var _deleting_land = false

var _previous_pos

func _ready():
    # Background

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
    
    # Land
    
    _land_tile = load_land_tile("./resources/Kanto/Land.png")
    _land_empty_tile.create(_tile_size, _tile_size, false, Image.FORMAT_RGBA8)
    _land_empty_tile.fill(Color.transparent)
    _land_ne_tile = load_land_tile("./resources/Kanto/Land-NE.png")
    _land_nw_tile = load_land_tile("./resources/Kanto/Land-NW.png")
    _land_se_tile = load_land_tile("./resources/Kanto/Land-SE.png")
    _land_sw_tile = load_land_tile("./resources/Kanto/Land-SW.png")
    
    _land.create(_tile_size*_width, _tile_size*_height, false, Image.FORMAT_RGBA8)
    
    _land_tex.create_from_image(_land, 3)
    
func load_land_tile(path : String):
    var tile = ImageIndexed.new()

    tile.load(path)
    tile.convert(Image.FORMAT_RGBA8)
    
    if not tile.has_palette():
        tile.generate_palette(2)

    for i in range(2):
        if tile.get_palette_color(i) == Color.black:
            tile.set_palette_color(i, Color.green)
    tile.apply_palette()
    
    tile.resize(_tile_size, _tile_size, Image.INTERPOLATE_NEAREST)
    tile.lock()

    return tile

func _draw():
    draw_texture(_background_tex, Vector2.ZERO)
    draw_texture(_land_tex, Vector2.ZERO)
            
func create_matrix(width : int, height : int):
    var matrix = []
    for x in range(width):
        matrix.append([])
        for y in range(height):
            matrix[x].append([])
            matrix[x][y] = 0
            
    return matrix

func _input(event):
    if event is InputEventMouseButton:
        if event.get_button_index() == BUTTON_LEFT:
            if event.is_pressed():
                start_creating_land(event.position)
                creating_land(event.position)
            else:
                end_creating_land()
        elif event.get_button_index() == BUTTON_RIGHT:
            if event.is_pressed():
                start_deleting_land(event.position)
                deleting_land(event.position)
            else:
                end_deleting_land()
    elif event is InputEventMouseMotion:
        if _creating_land:
            creating_land(event.position)
        elif _deleting_land:
            deleting_land(event.position)
            
func start_creating_land(pos : Vector2):
    _creating_land = true
    _previous_pos = (pos / _tile_size).floor()

func creating_land(pos : Vector2):
    var current_pos = (pos / _tile_size).floor()
    
    var p0 = _previous_pos
    var p1 = current_pos
    
    var dx = abs(p1.x - p0.x)
    var sx = 1 if p0.x < p1.x else -1
    var dy = -abs(p1.y - p0.y)
    var sy = 1 if p0.y < p1.y else -1
    var err = dx + dy

    while true:
        set_land(p0.y, p0.x)

        if p0.x == p1.x and p0.y == p1.y:
            break
            
        var e2 = 2*err;
        if e2 >= dy:
            err += dy
            p0.x += sx
        if e2 <= dx:
            err += dx
            p0.y += sy
    
    _previous_pos = current_pos
            
func end_creating_land():
    _creating_land = false
    
func start_deleting_land(pos : Vector2):
    _deleting_land = true
    _previous_pos = (pos / _tile_size).floor()

func deleting_land(pos : Vector2):
    var current_pos = (pos / _tile_size).floor()
    
    var p0 = _previous_pos
    var p1 = current_pos
    
    var dx = abs(p1.x - p0.x)
    var sx = 1 if p0.x < p1.x else -1
    var dy = -abs(p1.y - p0.y)
    var sy = 1 if p0.y < p1.y else -1
    var err = dx + dy

    while true:
        delete_land(p0.y, p0.x)

        if p0.x == p1.x and p0.y == p1.y:
            break
            
        var e2 = 2*err;
        if e2 >= dy:
            err += dy
            p0.x += sx
        if e2 <= dx:
            err += dx
            p0.y += sy
    
    _previous_pos = current_pos
            
func end_deleting_land():
    _deleting_land = false
    
func set_land(i : int, j : int):
    if get_tile(i, j) == 0:
        set_tile(i, j, 1)
            
        update_tile(i, j)
            
        update_tile(i - 1, j)
        update_tile(i, j + 1)
        update_tile(i + 1, j)
        update_tile(i, j - 1)
            
        update_land()
        
func delete_land(i : int, j : int):
    if get_tile(i, j) == 1:
        set_tile(i, j, 0)
            
        update_tile(i, j)
            
        update_tile(i - 1, j)
        update_tile(i, j + 1)
        update_tile(i + 1, j)
        update_tile(i, j - 1)
            
        update_land()

func set_tile(i : int, j : int, value : int):
    if(i >= 0 and i < _width and j >= 0 and j < _height):
        _map[i][j] = value
            
func get_tile(i : int, j : int):
    if(i >= 0 and i < _width and j >= 0 and j < _height):
        return _map[i][j]
    else:
        return -1
            
func update_tile(i : int, j : int):
    if get_tile(i, j) == -1: return
    if get_tile(i, j) ==  0:
        _land.blit_rect(_land_empty_tile, Rect2(Vector2.ZERO, _land_empty_tile.get_size()), Vector2(j*_tile_size, i*_tile_size))
        return

    var water_count = 0

    water_count += 1 if get_tile(i - 1, j) == 0 else 0
    water_count += 1 if get_tile(i, j + 1) == 0 else 0
    water_count += 1 if get_tile(i + 1, j) == 0 else 0
    water_count += 1 if get_tile(i, j - 1) == 0 else 0

    var land_tile
    
    if water_count != 2:
        land_tile = _land_tile
    else:
        if get_tile(i - 1, j) == 1:
            if get_tile(i, j + 1) == 1:
                land_tile = _land_ne_tile
            elif get_tile(i, j - 1) == 1:
                land_tile = _land_nw_tile
            else:
                land_tile = _land_tile
        elif get_tile(i + 1, j) == 1:
            if get_tile(i, j + 1) == 1:
                land_tile = _land_se_tile
            elif get_tile(i, j - 1) == 1:
                land_tile = _land_sw_tile
            else:
                land_tile = _land_tile
        else:
            land_tile = _land_tile
    
    _land.blit_rect(land_tile, Rect2(Vector2.ZERO, land_tile.get_size()), Vector2(j*_tile_size, i*_tile_size))

func update_land():
    _land_tex.set_data(_land)
    update()
