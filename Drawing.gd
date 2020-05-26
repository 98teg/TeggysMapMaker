extends Control

var pixels = 400
var img = Image.new()
var tex = ImageTexture.new()
var drawing = false

func _ready():
    img.create(pixels, pixels, false, Image.FORMAT_RGBA8)
    tex.create_from_image(img)
    
    img.fill(Color(1, 1, 1))

func _draw():
    tex.set_data(img)

    draw_texture(tex, Vector2())

func _input(event):
    if event is InputEventMouseButton:
        var pos = event.position

        if event.get_button_index() == BUTTON_LEFT:
            if event.is_pressed():
                img.lock()
                img.set_pixel(pos.x, pos.y, Color(1, 0, 0))
                img.unlock()
                drawing = true
                update()
            else:
                drawing = false
    elif event is InputEventMouseMotion:
        if drawing:
            var pos = event.position
            img.lock()
            img.set_pixel(pos.x, pos.y, Color(1, 0, 0))
            img.unlock()
            update()
        
