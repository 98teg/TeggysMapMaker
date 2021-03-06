extends Control

#####################
# Private variables #
#####################

# Texture of the image to show
var _image : ImageTexture = ImageTexture.new()
# Position to show the image
var _pos : Vector2 = Vector2.ZERO

####################
# Public functions #
####################

# + image: Image (Image)
# + pos: Position to show the image (Vector2)
func init(image : Image, pos : Vector2) -> void:
	set_image(image)
	set_pos(pos)

# Sets the image
func set_image(image : Image) -> void:
	_image.create_from_image(image, 3)
	update()

# Sets the position
func set_pos(pos : Vector2) -> void:
	_pos = pos
	update()

# Sets the transformation
func set_transform(offset : Vector2, scale : Vector2) -> void:
	get_material().set_shader_param("offset", offset)
	get_material().set_shader_param("scale", scale)

#####################
# Private functions #
#####################

# Draws the image
func _draw() -> void:
	draw_texture(_image, _pos)
