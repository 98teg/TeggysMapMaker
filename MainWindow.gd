extends Control

func _ready():
	OS.set_window_maximized(true)

	var configuration = {
		"layers": [
			{
				"type": "background",
				"configuration": {
					"width": 20,
					"height": 20,
					"tile_size": 8,
					"tile": "./resources/Kanto/Water.png",
				}
			},
			{
				"type": "tilemap",
				"configuration": {
					"width": 20,
					"height": 20,
					"tile_size": 8,
					"tileset": [
						{
							"texture": "./resources/Kanto/Land.png",
							"layer": "land",
							"variations": [
								{
									"conditions": [["North", "East"]],
									"texture": "./resources/Kanto/Land-NE.png"
								},
								{
									"conditions": [["North", "West"]],
									"texture": "./resources/Kanto/Land-NW.png"
								},
								{
									"conditions": [["South", "East"]],
									"texture": "./resources/Kanto/Land-SE.png"
								},
								{
									"conditions": [["South", "West"]],
									"texture": "./resources/Kanto/Land-SW.png"
								}
							]
						},
						{
							"texture": "./resources/Kanto/Path.png",
							"layer": "path",
							"material": "path"
						},
						{
							"texture": "./resources/Kanto/WaterPath.png",
							"layer": "path",
							"material": "path",
							"variations": [
								{
									"conditions": [["East", "West"], ["East"], ["West"]],
									"texture": "./resources/Kanto/WaterPath-H.png"
								},
								{
									"conditions": [["North", "South"], ["North"], ["South"]],
									"texture": "./resources/Kanto/WaterPath-V.png"
								}
							]
						},
						{
							"texture": "./resources/Kanto/City.png",
							"layer": "location"
						},
						{
							"texture": "./resources/Kanto/Town.png",
							"layer": "location"
						}
					]
				}
			}
		]
	}
	
	get_node("Canvas").init(configuration)

	get_node("ControlPanel/ToolBox").add_child(get_node("Canvas/CanvasLayers").get_current_tool_box())
	get_node("ControlPanel/MagnifyingGlass").connect("magnifying_factor_updated", get_node("Canvas"), "_update_scale_factor")
	get_node("Canvas/CanvasLayers").connect("gui_input", get_node("ControlPanel/MagnifyingGlass"), "process_mouse_wheel")
	
	get_node("Canvas/CanvasLayers").connect_with_undo_redo(get_node("ControlPanel/TopBar/UndoRedo"))


#func _gui_input(event):
#	get_node("MagnifyingGlass").process_mouse_wheel(event)
#
#func _save():
#	var image = Image.new()
#	image.copy_from(get_child(0).get_child(0).get_image())
#
#	for i in range(4):
#		image.blend_rect(get_child(0).get_child(i).get_image(), Rect2(Vector2.ZERO, get_child(0).get_child(i).get_image().get_size()), Vector2.ZERO)
#
#	image.resize(480, 480, Image.INTERPOLATE_NEAREST)
#	image.save_png("./salida_1234.png")
