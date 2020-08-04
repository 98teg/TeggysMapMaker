extends Button

##################
# Custom signals #
##################

# Notifies when this tile item has been selected
signal tile_item_selected(tile_id, extra_tools)

#####################
# Private variables #
#####################

# Tile id
var _id : int = 0
# Tile name
var _name : String = ""
# Tile extra tools available
var _extra_tools : Array = []

####################
# Public functions #
####################

# Configuration dictionary description
# + id: Tile id (int)
# + name: Tile name (String)
# + icon: Tile icon (Image)
# + extra_tools: Tile extra tools available (Array)
#    - Each element is a member of the enum _TileMap.Tool
func init(configuration : Dictionary) -> void:
	_set_id(configuration.id)
	_set_name(configuration.name)
	_set_icon(configuration.icon)

	for extra_tool in configuration.extra_tools:
		_add_extra_tool(extra_tool)

# Selects this tile
func select() -> void:
	_tile_item_pressed()

#####################
# Private functions #
#####################

# Sets tile id
func _set_id(id : int) -> void:
	_id = id

# Sets tile name and updates the tooltip
func _set_name(name : String) -> void:
	_name = name
	set_tooltip(_name)

# Sets tile icon and updates the texture
func _set_icon(icon : Image) -> void:
	var icon_tex = ImageTexture.new()
	icon_tex.create_from_image(icon, 3)
	set_button_icon(icon_tex)

# Adds a tile extra tool
func _add_extra_tool(extra_tool : int) -> void:
	_extra_tools.append(extra_tool)

# It is called when the tile item is pressed
func _tile_item_pressed() -> void:
	emit_signal("tile_item_selected", _id, _extra_tools)
