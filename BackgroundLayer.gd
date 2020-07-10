class_name _BackgroundLayer

var _background = Image.new()

func init(configuration : Dictionary):
	var witdh = configuration.width
	var height = configuration.height
	var tile_size = configuration.tile_size

	var tile = Image.new()
	tile.load(configuration.tile)
	tile.convert(Image.FORMAT_RGBA8)
	tile.resize(tile_size, tile_size, Image.INTERPOLATE_NEAREST)
	tile.lock()
	
	_background = GoostImage.tile(tile, Vector2(tile_size*witdh, tile_size*height))

func get_image():
	return _background
