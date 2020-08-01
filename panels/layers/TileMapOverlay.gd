extends Control

# Private variables

var _width
var _height
var _tile_size

# Overlay public functions

func init(configuration : Dictionary):
	_width = configuration.width
	_height = configuration.height
	_tile_size = configuration.tile_size

	var layer

	layer = preload("res://panels/layers/overlays/Image.tscn").instance()
	add_child(layer)

	layer = preload("res://panels/layers/overlays/Grid.tscn").instance()
	add_child(layer)
	layer.init(_width, _height, _tile_size)
	get_node("Grid").hide()

func set_image(image):
	get_node("Image").set_image(image)

func set_pos(pos : Vector2):
	pos = (pos / _tile_size).floor()

	if pos.x < 0 or pos.x >= _width or pos.y < 0 or pos.y >= _height:
		get_node("Image").set_visibility(false)
	else:
		get_node("Image").set_visibility(true)

	get_node("Image").set_pos(pos * _tile_size)

func toggle_grid():
	if get_node("Grid").is_visible_in_tree():
		get_node("Grid").hide()
	else:
		get_node("Grid").show()

func transform(offset : Vector2, scale : Vector2):
	for child in get_children():
		child.transform(offset, scale)

# Overlay private functions

func _draw():
	for child in get_children():
		child.update()
