extends Control

# Private variables

var _layer : Control
var _tileset : Array

# Toolbox public functions

func init(layer : Control, tileset : Array):
	_layer = layer
	_tileset = tileset
	
	create_tool_box()

# Toolbox private functions

func create_tool_box():
	connect_tools()
	create_tile_items()

func connect_tools():
	get_node("Tools/LeftTools/Pencil").connect("pressed", _layer, "select_tool", [_layer.Tools.PENCIL])
	get_node("Tools/LeftTools/Wrench").connect("pressed", _layer, "select_tool", [_layer.Tools.WRENCH])
	
	get_node("Tools/RightTools/Grid").connect("pressed", _layer, "toggle_grid")

func create_tile_items():
	var tile_item
	
	for tile in _tileset:
		tile_item = preload("res://toolboxes/elements/tile_item.tscn").instance()
		tile_item.set_image(tile.get_image())
		
		tile_item.connect("pressed", _layer, "select_tile", [tile.get_id()])
		
		get_node("TilesScroller/TilesGrid").add_child(tile_item)
