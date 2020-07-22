extends Control

# Element public functions

func set_image(image : Image):
	var icon = Image.new()
	icon.copy_from(image)
	icon.resize(64, 64, Image.INTERPOLATE_NEAREST)

	var icon_texture = ImageTexture.new()
	icon_texture.create_from_image(icon, 3)
	
	get_child(0).set_texture(icon_texture)
