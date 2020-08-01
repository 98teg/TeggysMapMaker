extends Control

# Private variables

var _image : ImageTexture = ImageTexture.new()
var _pos : Vector2 = Vector2.ZERO
var _visibility : bool = false

# Overlay public functions

func set_image(image : Image):
	_image.create_from_image(image, 3)
	update()

func set_pos(pos : Vector2):
	_pos = pos
	update()

func set_visibility(visibility : bool):
	_visibility = visibility
	update()

func transform(offset : Vector2, scale : Vector2):
	get_material().set_shader_param("offset", offset)
	get_material().set_shader_param("scale", scale)

# Overlay private functions

func _draw():
	if _visibility: draw_texture(_image, _pos)
