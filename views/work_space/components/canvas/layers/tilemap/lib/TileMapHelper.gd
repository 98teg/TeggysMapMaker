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
			matrix[i].append([])
			matrix[i][j] = value

	return matrix


static func is_trimmed(mask: Array) -> bool:
	var at_least_one_true = false

	for north_values in mask[0]:
		if north_values:
			at_least_one_true = true

	if not at_least_one_true:
		return false

	at_least_one_true = false

	for row in mask:
		if row.back():
			at_least_one_true = true

	if not at_least_one_true:
		return false

	at_least_one_true = false

	for south_values in mask.back():
		if south_values:
			at_least_one_true = true

	if not at_least_one_true:
		return false

	at_least_one_true = false

	for row in mask:
		if row[0]:
			at_least_one_true = true

	if not at_least_one_true:
		return false

	return true
