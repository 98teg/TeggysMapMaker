extends Control

# Overlay public functions

func init(configuration : Dictionary):
	var layer
	
	layer = preload("res://overlays/Grid.tscn").instance()
	add_child(layer)
	layer.init(configuration)

# Overlay private functions

func _draw():
	for child in get_children():
		child.update()
