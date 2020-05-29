extends Control

var _pixels = 800

var _previous_point = Vector2()
var _image = Image.new()
var _stroke = Image.new()
var _brush = Image.new()
var _color = Color.red

var _image_tex = ImageTexture.new()
var _stroke_tex = ImageTexture.new()

var _brush_width
var _brush_height

var _drawing_stroke = false

func _ready():
    _image.create(_pixels, _pixels, false, Image.FORMAT_RGBA8)
    _image.fill(Color.white)
    
    _image_tex.create_from_image(_image)
    
    _stroke.create(_pixels, _pixels, false, Image.FORMAT_RGBA8)
    _stroke.fill(Color.transparent)

    _stroke_tex.create_from_image(_stroke)
    
    create_brush("./brush.png")

func _draw():
    draw_texture(_image_tex, Vector2.ZERO)
    draw_texture(_stroke_tex, Vector2.ZERO)

func _input(event):
    if event is InputEventMouseButton:
        if event.get_button_index() == BUTTON_LEFT:
            if event.is_pressed():
                start_stroke(event.position)
                draw_stroke(event.position)
            else:
                end_stroke()
    elif event is InputEventMouseMotion:
        if _drawing_stroke:
            draw_stroke(event.position)
            
func create_brush(path : String):
    _brush.load(path)
    _brush.lock()
    
    _brush_width = _brush.get_size().x
    _brush_height = _brush.get_size().y
            
func start_stroke(pos : Vector2):
    _stroke.lock()
    draw_stroke_point(pos)
    
    _previous_point = pos
    _drawing_stroke = true

func draw_stroke(_current_point : Vector2):
    var x_diff = _current_point.x - _previous_point.x
    var y_diff = _current_point.y - _previous_point.y

    if x_diff == 0 && y_diff == 0:
        draw_stroke_point(_current_point)

    elif abs(x_diff) > abs(y_diff):
        var a = y_diff / float(x_diff)
        var b = - a*_previous_point.x + _previous_point.y
        
        var step = 1 if _previous_point.x < _current_point.x else -1
        
        for x in range(_previous_point.x, _current_point.x, step):
            draw_stroke_point(Vector2(x, round(a*x + b)))
            
    else:
        var a = x_diff / float(y_diff)
        var b = - a*_previous_point.y + _previous_point.x
        
        var step = 1 if _previous_point.y < _current_point.y else -1
        
        for y in range(_previous_point.y, _current_point.y, step):
            draw_stroke_point(Vector2(round(a*y + b), y))

    _previous_point = _current_point
    update_stroke()
    update()
    
func draw_stroke_point(_pos : Vector2):
    var init_x = _pos.x - _brush_width / 2
    var init_y = _pos.y - _brush_height / 2
    
    var end_x = init_x + _brush_width
    var end_y = init_y + _brush_height
    
    init_x = init_x if not init_x < 0 else 0
    init_y = init_y if not init_y < 0 else 0
    
    end_x = end_x if not end_x >= _pixels else _pixels - 1
    end_y = end_y if not end_y >= _pixels else _pixels - 1

    for x in range(init_x, end_x):
        for y in range(init_y, end_y):
            var dst_alpha = _stroke.get_pixel(x, y).a
            var src_alpha = _brush.get_pixel(x - init_x, y - init_y).a
                    
            var color = _color
            color.a = dst_alpha if dst_alpha > src_alpha else src_alpha
                        
            _stroke.set_pixel(x, y, color)
            
func end_stroke():
    _image.blend_rect(_stroke, Rect2(Vector2.ZERO,_stroke.get_size()), Vector2.ZERO)
    update_image()
    _stroke.fill(Color.transparent)
    update_stroke()

    update()

    _drawing_stroke = false
    
func update_image():
    _image_tex.set_data(_image)
    
func update_stroke():
    _stroke_tex.set_data(_stroke)
