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
var tile_relative_pos := [0, 0] setget set_tile_relative_pos
var image := Image.new()


func set_autotiling_state(new_autotiling_state: int) -> void:
	assert(new_autotiling_state >= 0)

	autotiling_state = new_autotiling_state

func set_tile_relative_pos(new_tile_relative_pos: Array) -> void:
	assert(new_tile_relative_pos.size() == 2)

	tile_relative_pos = new_tile_relative_pos
