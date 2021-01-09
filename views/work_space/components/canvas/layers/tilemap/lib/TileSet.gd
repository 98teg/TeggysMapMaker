class_name TMM_TileSet


var _tile_set := []


func get_tile_structure(tile_structure_id: int) -> TMM_TileStructure:
	assert(_tile_set[tile_structure_id].id == tile_structure_id)

	return _tile_set[tile_structure_id]


func get_tile(tile_description: Dictionary) -> TMM_Tile:
	var tile_structure = get_tile_structure(tile_description.id)

	var autotiling_state
	if tile_description.has("autotiling_state"):
		autotiling_state = tile_description.autotiling_state
	else:
		autotiling_state = 0

	var relative_pos
	if tile_description.has("relative_pos"):
		relative_pos = tile_description.relative_pos
	else:
		relative_pos = [0, 0]

	var tile = tile_structure.get_tile(autotiling_state, relative_pos)
	
	return tile


func init(tile_set_conf: Array) -> void:
	for tile_structure_conf in tile_set_conf:
		_create_tile_structure(tile_structure_conf)


func _create_tile_structure(tile_structure_conf: Dictionary) -> void:
	var tile_structure = TMM_TileStructure.new()
	_set_properties(tile_structure, tile_structure_conf)
	_set_default_state(tile_structure, tile_structure_conf.Image)
	_create_autotiling_states(tile_structure, tile_structure_conf.Variations)

	tile_structure.generate_tiles_relative_pos()


func _set_properties(tile_structure: TMM_TileStructure,
		tile_structure_conf: Dictionary) -> void:
	tile_structure.id = tile_structure_conf.ID
	tile_structure.name = tile_structure_conf.Name
	tile_structure.icon = tile_structure_conf.Icon
	tile_structure.size = tile_structure_conf.Structure.Size
	tile_structure.colission_mask = tile_structure_conf.Structure.ColissionMask
	tile_structure.main_tile = tile_structure_conf.Structure.MainTile
	tile_structure.layer = tile_structure_conf.Layer
	tile_structure.extra_tools = tile_structure_conf.ExtraTools
	tile_structure.connection_type = tile_structure_conf.ConnectionType
	tile_structure.connected_group = tile_structure_conf.ConnectedGroup
	tile_structure.can_connect_to_borders = tile_structure_conf.CanConnectToBorders


func _set_default_state(tile_structure: TMM_TileStructure,
		image: Image) -> void:
	tile_structure.add_autotiling_state(image)


func _create_autotiling_states(tile_structure: TMM_TileStructure,
		variations_conf: Array) -> void:
	for variation_conf in variations_conf:
		tile_structure.add_autotiling_state(variation_conf.Image,
				variation_conf.Connections)
