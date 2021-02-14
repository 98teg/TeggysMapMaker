class_name TMM_TileMapHelper


enum SpecialTile {
	AIR = -1
}

enum ConnectionType {
	ISOLATED,
	CROSS,
	CIRCLE
}

enum Tool{
	PENCIL,
	WRENCH,
	ERASER,
	BUCKET_FILL
}


static func get_connection_id(connection_type: int,
		connected_at: Dictionary) -> int:
	assert(ConnectionType.values().has(connection_type))
	assert(connected_at.has("North"))
	assert(connected_at.has("NorthEast"))
	assert(connected_at.has("East"))
	assert(connected_at.has("SouthEast"))
	assert(connected_at.has("South"))
	assert(connected_at.has("SouthWest"))
	assert(connected_at.has("West"))
	assert(connected_at.has("NorthWest"))

	var connection_id = 0

	if connection_type == ConnectionType.ISOLATED:

		return connection_id

	if connection_type == ConnectionType.CROSS:
		connection_id += 1 if connected_at.North else 0
		connection_id += 2 if connected_at.East else 0
		connection_id += 4 if connected_at.South else 0
		connection_id += 8 if connected_at.West else 0

		return connection_id

	connection_id += 1 if connected_at.North else 0
	connection_id += 2 if connected_at.NorthEast else 0
	connection_id += 4 if connected_at.East else 0
	connection_id += 8 if connected_at.SouthEast else 0
	connection_id += 16 if connected_at.South else 0
	connection_id += 32 if connected_at.SouthWest else 0
	connection_id += 64 if connected_at.West else 0
	connection_id += 128 if connected_at.NorthWest else 0

	return connection_id


static func create_matrix(w: int, h: int, value) -> Array:
	var matrix = []

	for i in h:
		matrix.append([])
		for j in w:
			matrix[i].append(value)

	return matrix


static func is_trimmed(mask: Array) -> bool:
	return (
		get_top_row(mask).has(true) and
		get_right_column(mask).has(true) and
		get_bottom_row(mask).has(true) and
		get_left_column(mask).has(true)
	)


static func get_top_row(matrix: Array) -> Array:
	return matrix.front()


static func get_top_right_corner(matrix: Array) -> Array:
	return [matrix.front().back()]


static func get_right_column(matrix: Array) -> Array:
	var array = []

	for row in matrix:
		array.append(row.back())

	return array


static func get_bottom_right_corner(matrix: Array) -> Array:
	return [matrix.back().back()]


static func get_bottom_row(matrix: Array) -> Array:
	return matrix.back()


static func get_bottom_left_corner(matrix: Array) -> Array:
	return [matrix.back().front()]


static func get_left_column(matrix: Array) -> Array:
	var array = []

	for row in matrix:
		array.append(row.front())

	return array


static func get_top_left_corner(matrix: Array) -> Array:
	return [matrix.front().front()]
