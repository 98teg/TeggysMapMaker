extends Control

var _background = Image.new()
var _background_tex = ImageTexture.new()

var _context

func init(configuration : Dictionary, context : Dictionary):
	var witdh = configuration.width
	var height = configuration.height
	var tile_size = configuration.tile_size

	var tile = Image.new()
	tile.load(configuration.tile)
	tile.convert(Image.FORMAT_RGBA8)
	tile.resize(tile_size, tile_size, Image.INTERPOLATE_NEAREST)
	tile.lock()
	
	_background = GoostImage.tile(tile, Vector2(tile_size*witdh, tile_size*height))
	_background_tex.create_from_image(_background, 3)
	
	_context = context
	
func resize(size : Vector2):
	set_custom_minimum_size(size)

func _draw():
	draw_set_transform(_context.pos, 0.0, _context.scale)
	draw_texture(_background_tex, Vector2.ZERO)
