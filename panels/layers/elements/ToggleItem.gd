extends ToolButton

##################
# Custom signals #
##################

# Notifies when this tool item has been selected
signal toggle_item_updated(is_toggled)

#####################
# Private variables #
#####################

# Toggle name
var _name : String = ""
# Toggle id
var _toggled : bool = false

####################
# Public functions #
####################

# Configuration dictionary description
# + name: Toggle name (String)
# + toggled: Toggle is toggled (bool)
# + icon: Toggle icon (Image)
func init(configuration : Dictionary) -> void:
	_set_name(configuration.name)
	_set_toggled(configuration.toggled)
	_set_icon(configuration.icon)

#####################
# Private functions #
#####################

# Sets toggle name and updates the tooltip
func _set_name(name : String) -> void:
	_name = name
	set_tooltip(_name)

# Sets toggle toggled
func _set_toggled(toggled : bool) -> void:
	_toggled = toggled

# Sets toggle icon and updates the texture
func _set_icon(icon : Image) -> void:
	var icon_tex = ImageTexture.new()
	icon_tex.create_from_image(icon)
	set_button_icon(icon_tex)

# It is called when the toggle item is pressed
func _toggle_item_pressed() -> void:
	_toggled = not _toggled
	emit_signal("toggle_item_updated", _toggled)
