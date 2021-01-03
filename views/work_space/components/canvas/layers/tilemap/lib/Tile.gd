class_name TMM_Tile


enum SpecialTile {
	AIR = -1,
	OUT_OF_BOUNDS = -2
}


enum ConnectionType {
	ISOLATED,
	CROSS,
	CIRCLE
}


var tile_structure_id := 0
var autotiling_state := 0 setget set_autotiling_state
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


func set_relative_pos(new_relative_pos: Array) -> void:
	assert(new_relative_pos.size() == 2)
	for value in new_relative_pos:
		assert(value is int)

	relative_pos = new_relative_pos
