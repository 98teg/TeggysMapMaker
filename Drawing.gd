extends Control

var pixels = 800
var _previous_point = null
var _image = Image.new()
var _texture = ImageTexture.new()
var drawing = false

func _ready():
    _image.create(pixels, pixels, false, Image.FORMAT_RGBA8)
    _texture.create_from_image(_image)
    
    _image.fill(Color(1, 1, 1))

func _draw():
    draw_texture(_texture, Vector2())

func _input(event):
    if event is InputEventMouseButton:
        var pos = event.position

        if event.get_button_index() == BUTTON_LEFT:
            if event.is_pressed():
                draw_on_image(event.position)
                drawing = true
            else:
                _previous_point = null
                drawing = false
    elif event is InputEventMouseMotion:
        if drawing:
            draw_on_image(event.position)
            
        
func draw_on_image(_current_point : Vector2):
    var size = 16

    if _previous_point == null:
        _previous_point = _current_point

    var x_diff = _current_point.x - _previous_point.x
    var y_diff = _current_point.y - _previous_point.y
    
    if x_diff == 0 && y_diff == 0:
        _image.lock()
        for i in range(_current_point.x - size, _current_point.x + size):
            for j in range(_current_point.y - size, _current_point.y + size):
                _image.set_pixel(i, j, Color(1, 0, 0))
        _image.unlock()

    elif abs(x_diff) > abs(y_diff):
        var a = y_diff / float(x_diff)
        var b = - a*_previous_point.x + _previous_point.y
        
        var step
        if _previous_point.x < _current_point.x:
            step = 1
        else:
            step = -1
        
        for x in range(_previous_point.x, _current_point.x, step):
            var pos = Vector2(x, round(a*x + b))

            _image.lock()
            for i in range(pos.x - size, pos.x + size):
                for j in range(pos.y - size, pos.y + size):
                    _image.set_pixel(i, j, Color(1, 0, 0))
            _image.unlock()
            
    else:
        var a = x_diff / y_diff
        var b = - a*_previous_point.y + _previous_point.x
        
        var step
        if _previous_point.y < _current_point.y:
            step = 1
        else:
            step = -1
        
        for y in range(_previous_point.y, _current_point.y, step):
            var pos = Vector2(round(a*y + b), y)

            _image.lock()
            for i in range(pos.x - size, pos.x + size):
                for j in range(pos.y - size, pos.y + size):
                    _image.set_pixel(i, j, Color(1, 0, 0))
            _image.unlock()
    
    _previous_point = _current_point
    _texture.set_data(_image)
    update()
