extends Control

# Private variables

var _layer : Control
var _tileset : Array

# Panel public functions

func init(layer : Control, tileset : Array):
	_layer = layer
	_tileset = tileset
	
	create_tool_box()

# Panel private functions

func create_tool_box():
	connect_tools()
	create_tile_items()

func connect_tools():
	get_node("Tools/LeftTools/Pencil").connect("pressed", _layer, "select_tool", [_layer.Tool.PENCIL])
	get_node("Tools/LeftTools/Wrench").connect("pressed", _layer, "select_tool", [_layer.Tool.WRENCH])
	get_node("Tools/LeftTools/Eraser").connect("pressed", _layer, "select_tool", [_layer.Tool.ERASER])
	get_node("Tools/LeftTools/BucketFill").connect("pressed", _layer, "select_tool", [_layer.Tool.BUCKET_FILL])
	
	get_node("Tools/RightTools/Grid").connect("pressed", _layer, "toggle_grid")

func create_tile_items():
	var tile_item
	
	for tile in _tileset:
		tile_item = preload("res://panels/elements/TileItem.tscn").instance()
		tile_item.set_image(tile.get_image())
		
		tile_item.connect("pressed", _layer, "select_tile", [tile.get_id()])
		
		get_node("TilesScroller/TilesGrid").add_child(tile_item)
