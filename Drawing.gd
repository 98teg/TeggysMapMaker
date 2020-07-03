extends Control

var _pixels = 800

var _previous_point = Vector2()
var _image = Image.new()
var _stroke = Image.new()
var _brush = Image.new()

var _image_tex = ImageTexture.new()
var _stroke_tex = ImageTexture.new()
var _brush_tex = ImageTexture.new()

var _brush_width
var _brush_height

var _drawing_stroke = false

var _color_into_brush = ImageBlender.new()
var _brush_into_stroke = ImageBlender.new()
var _stroke_into_image = ImageBlender.new()

func _ready():
    _image.create(_pixels, _pixels, false, Image.FORMAT_RGBA8)
    _image.fill(Color.white)
    
    _image_tex.create_from_image(_image)
    
    _stroke.create(_pixels, _pixels, false, Image.FORMAT_RGBA8)
    _stroke.fill(Color.transparent)

    _stroke_tex.create_from_image(_stroke)
    
    _color_into_brush.set_rgb_src_factor(ImageBlender.FACTOR_ONE)
    _color_into_brush.set_rgb_dst_factor(ImageBlender.FACTOR_ZERO)
    _color_into_brush.set_alpha_src_factor(ImageBlender.FACTOR_ZERO)
    _color_into_brush.set_alpha_dst_factor(ImageBlender.FACTOR_ONE)

    _brush_into_stroke.set_rgb_src_factor(ImageBlender.FACTOR_ONE)
    _brush_into_stroke.set_rgb_dst_factor(ImageBlender.FACTOR_ZERO)
    _brush_into_stroke.set_alpha_equation(ImageBlender.FUNC_MAX)
   
    create_brush("./brush.png")
    resize_brush(64, 64)
    set_brush_color(Color.red)
    
    _brush_tex.create_from_image(_brush)

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
    
func resize_brush(width : int, height : int):
    _brush_width = width
    _brush_height = height

    _brush.unlock()
    _brush.resize(width, height, Image.INTERPOLATE_NEAREST)
    _brush.lock()
    
func set_brush_color(color : Color):
    var color_image = Image.new()
    color_image.copy_from(_brush)
    color_image.fill(color)
    
    _color_into_brush.blend_rect(color_image, Rect2(Vector2.ZERO, color_image.get_size()), _brush, Vector2.ZERO)
            
func start_stroke(pos : Vector2):
    _stroke.lock()
    
    _previous_point = pos
    _drawing_stroke = true

func draw_stroke(_current_point : Vector2):
    _brush_into_stroke.stamp_rect(_brush, Rect2(Vector2.ZERO,_brush.get_size()), _stroke, _previous_point, _current_point, 6.4)

    _previous_point = _current_point
    update_stroke()
    update()
            
func end_stroke():
    _stroke_into_image.blend_rect(_stroke, Rect2(Vector2.ZERO,_stroke.get_size()), _image, Vector2.ZERO)
    update_image()

    _stroke.fill(Color.transparent)
    update_stroke()

    update()

    _drawing_stroke = false
    
func update_image():
    _image_tex.set_data(_image)
    
func update_stroke():
    _stroke_tex.set_data(_stroke)
