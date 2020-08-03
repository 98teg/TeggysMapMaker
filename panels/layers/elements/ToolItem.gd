extends ToolButton

##################
# Custom signals #
##################

# Notifies when this tool item has been selected
signal tool_item_selected(tool_id)

#####################
# Private variables #
#####################

# Tool id
var _id : int = 0
# Tool name
var _name : String = ""

####################
# Public functions #
####################

# Configuration dictionary description
# + id: Tool id (int)
# + name: Tool name (String)
# + icon: Tool icon (Image)
func init(configuration : Dictionary) -> void:
	_set_id(configuration.id)
	_set_name(configuration.name)
	_set_icon(configuration.icon)
	
	update()

#####################
# Private functions #
#####################

# Sets tool id
func _set_id(id : int) -> void:
	_id = id

# Sets tool name
func _set_name(name : String) -> void:
	_name = name

# Sets tool icon and updates the texture
func _set_icon(icon : Image) -> void:
	var icon_tex = ImageTexture.new()
	icon_tex.create_from_image(icon)
	set_button_icon(icon_tex)

# It is called when the tool item is pressed
func _tool_item_pressed() -> void:
	emit_signal("tool_item_selected", _id)
