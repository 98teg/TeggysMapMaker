class_name TMM_Tile


var tile_structure_id := 0
var autotiling_state := 0 setget set_autotiling_state
var sub_layer := 0 setget set_sub_layer
var relative_pos := [0, 0] setget set_relative_pos
var image := Image.new()


func get_description() -> Dictionary:
	var description = {}

	description.id = tile_structure_id

	if autotiling_state != 0:
		description.autotiling_state = autotiling_state

	if relative_pos != [0, 0]:
		description.relative_pos = relative_pos

	return description


func set_autotiling_state(new_autotiling_state: int) -> void:
	assert(new_autotiling_state >= 0)

	autotiling_state = new_autotiling_state


func set_sub_layer(new_sub_layer: int) -> void:
	assert(new_sub_layer >= 0)

	sub_layer = new_sub_layer


func set_relative_pos(new_relative_pos: Array) -> void:
	assert(new_relative_pos.size() == 2)
	for value in new_relative_pos:
		assert(value is int)

	relative_pos = new_relative_pos
