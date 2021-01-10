extends VSplitContainer

##################
# Custom signals #
##################

# Notifies when a tile has been selected
signal tile_selected(tile_id)
# Notifies when a tool has been selected
signal tool_selected(tool_id)
# Notifies when the grid visibility has changed
signal grid_visibility_changed(visibility)

#####################
# Private variables #
#####################

# If the wrench is present
var _wrench_flag : bool = false
# Wrench item
var _wrench_item : Button = preload("./components/tool_item/ToolItem.tscn").instance()
# If the bucket fill is present
var _bucket_fill_flag : bool = false
# Bucket fill item
var _bucket_fill_item : Button = preload("./components/tool_item/ToolItem.tscn").instance()

####################
# Public functions #
####################

# Configuration dictionary description
# + tileset: Tile set information (Array)
#    - Each element contain the configuration of a TileItem
#       + id: Tile id (int)
#       + name: Tile name (String)
#       + icon: Tile icon (Image)
#       + extra_tools: Tile extra tools available (Array)
#          - Each element is a member of the enum _TileMap.Tool
func init(configuration: Dictionary) -> void:
	var tile_item_group = ButtonGroup.new()

	for tile in configuration.TileSet:
		_add_tile_item(tile_item_group, tile)

	_init_tools()

	if get_node("TilesScroller/TilesGridPanel/Margin/TilesGrid").get_child_count() > 0:
		_get_tile_item(0).select()

#####################
# Private functions #
#####################

# Adds a tile item
# Configuration dictionary description
# + id: Tile id (int)
# + name: Tile name (String)
# + icon: Tile icon (Image)
# + extra_tools: Tile extra tools available (Array)
#    - Each element is a member of the enum _TileMap.Tool
func _add_tile_item(tile_item_group: ButtonGroup, tile: Dictionary) -> void:
	var tile_item = preload("./components/tile_item/TileItem.tscn").instance()
	tile_item.init(tile)
	tile_item.add_to_button_group(tile_item_group)
	
	get_node("TilesScroller/TilesGridPanel/Margin/TilesGrid").add_child(tile_item)
	tile_item.connect("tile_item_selected", self, "_select_tile")

# Returns a tile item
func _get_tile_item(idx : int) -> Node:
	return get_node("TilesScroller/TilesGridPanel/Margin/TilesGrid").get_child(idx)

# It is called when the tile item emits the tile_item_selected signal
func _select_tile(tile_id : int, extra_tools : Array) -> void:
	_update_extra_tools(extra_tools)
	emit_signal("tile_selected", tile_id)

# Updates the extra tools
func _update_extra_tools(extra_tools):
	var wrench_flag = false
	var bucket_fill_flag = false

	for extra_tool in extra_tools:
		match extra_tool:
			TMM_TileMapEnum.Tool.WRENCH:
				wrench_flag = true
				if _wrench_flag == false:
					_wrench_flag = true
					get_node("ToolsPanel/Tools/LeftTools").add_child(_wrench_item)
			TMM_TileMapEnum.Tool.BUCKET_FILL:
				bucket_fill_flag = true
				if _bucket_fill_flag == false:
					_bucket_fill_flag = true
					get_node("ToolsPanel/Tools/LeftTools").add_child(_bucket_fill_item)

	if wrench_flag == false and _wrench_flag:
		_wrench_flag = false
		get_node("ToolsPanel/Tools/LeftTools").remove_child(_wrench_item)

	if bucket_fill_flag == false and _bucket_fill_flag:
		_bucket_fill_flag = false
		get_node("ToolsPanel/Tools/LeftTools").remove_child(_bucket_fill_item)

	get_node("ToolsPanel/Tools/LeftTools/Pencil").select()

# Init tools
func _init_tools():
	var tool_item_group = ButtonGroup.new() 
	_init_default_tools_items(tool_item_group)
	_init_extra_tools_items(tool_item_group)

# Init default tools items
func _init_default_tools_items(tool_item_group : ButtonGroup):
	_init_pencil_item(tool_item_group)
	_init_eraser_item(tool_item_group)
	_init_grid_item()

# Init pencil item
func _init_pencil_item(tool_item_group : ButtonGroup):
	var conf = {"id": TMM_TileMapEnum.Tool.PENCIL, "name": "Pencil", "icon": _get_image("pencil")}
	get_node("ToolsPanel/Tools/LeftTools/Pencil").init(conf)
	get_node("ToolsPanel/Tools/LeftTools/Pencil").add_to_button_group(tool_item_group)
	get_node("ToolsPanel/Tools/LeftTools/Pencil").connect("tool_item_selected", self, "_select_tool")

# Init eraser item
func _init_eraser_item(tool_item_group : ButtonGroup):
	var conf = {"id": TMM_TileMapEnum.Tool.ERASER, "name": "Eraser", "icon": _get_image("eraser")}
	get_node("ToolsPanel/Tools/RightTools/Eraser").init(conf)
	get_node("ToolsPanel/Tools/RightTools/Eraser").add_to_button_group(tool_item_group)
	get_node("ToolsPanel/Tools/RightTools/Eraser").connect("tool_item_selected", self, "_select_tool")

# Init grid item
func _init_grid_item():
	var conf = {"name": "Grid", "toggled": false, "icon": _get_image("grid")}
	get_node("ToolsPanel/Tools/RightTools/Grid").init(conf)
	get_node("ToolsPanel/Tools/RightTools/Grid").connect("toggle_item_updated", self, "_grid_visibility_changed")

# Init extra tools items
func _init_extra_tools_items(tool_item_group : ButtonGroup):
	_init_wrench_item(tool_item_group)
	_init_bucket_fill_item(tool_item_group)

# Init wrench item
func _init_wrench_item(tool_item_group : ButtonGroup):
	var conf = {"id": TMM_TileMapEnum.Tool.WRENCH, "name": "Wrench", "icon": _get_image("wrench")}
	_wrench_item.init(conf)
	_wrench_item.add_to_button_group(tool_item_group)
	_wrench_item.connect("tool_item_selected", self, "_select_tool")

# Init bucket fill item
func _init_bucket_fill_item(tool_item_group : ButtonGroup):
	var conf = {"id": TMM_TileMapEnum.Tool.BUCKET_FILL, "name": "Bucket fill", "icon": _get_image("bucket_fill")}
	_bucket_fill_item.init(conf)
	_bucket_fill_item.add_to_button_group(tool_item_group)
	_bucket_fill_item.connect("tool_item_selected", self, "_select_tool")

# Returns the image from the resources folder
func _get_image(name : String) -> Image:
	return load("res://resources/icons/" + name + ".png").get_data()

# It is called when the tool item emits the tool_item_selected signal
func _select_tool(tool_id : int) -> void:
	emit_signal("tool_selected", tool_id)

# It is called when the toggle item emits the toggle_item_updated signal
func _grid_visibility_changed(visibility : bool) -> void:
	emit_signal("grid_visibility_changed", visibility)


func _grid_resized():
	pass
#	var scroller_size = get_node("TilesScroller").get_size()
#	var grid_size = get_node("TilesScroller/TilesGridPanel/Margin").get_size()
#	get_node("TilesScroller").set_size(Vector2(scroller_size.x, grid_size.y))
