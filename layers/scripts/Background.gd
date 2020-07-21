extends Control

# Private variables

var _background : Image = Image.new()
var _background_tex : ImageTexture = ImageTexture.new()
var _canvas_context : Dictionary
var _overlay : Control

# Layer public functions

func init(configuration : Dictionary, canvas_context : Dictionary):
	_set_background(configuration.tile, configuration.width, configuration.height, configuration.tile_size)
	_set_canvas_context(canvas_context)
	_create_overlay()
	
func get_image():
	return _background
	
func get_overlay():
	return _overlay

# Layer private functions

func _set_background(tile_path : String, w : int, h : int, s : int):
	var tile = Image.new()
	tile.load(tile_path)
	tile.convert(Image.FORMAT_RGBA8)
	tile.resize(s, s, Image.INTERPOLATE_NEAREST)
	
	_background = GoostImage.tile(tile, Vector2(s*w, s*h))
	_background_tex.create_from_image(_background, 3)

func _set_canvas_context(canvas_context : Dictionary):
	_canvas_context = canvas_context
	
func _create_overlay():
	_overlay = preload("res://overlays/Empty.tscn").instance()

func _draw():
	draw_set_transform(_canvas_context.pos, 0.0, _canvas_context.scale)
	draw_texture(_background_tex, Vector2.ZERO)
