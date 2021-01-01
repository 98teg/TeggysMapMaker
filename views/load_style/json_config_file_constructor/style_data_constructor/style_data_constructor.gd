class_name StyleDataConstructor


static func get_style_data() -> JSONPropertyObject:
	var author = JSONPropertyString.new()
	author.set_min_length(1)
	author.set_max_length(50)

	var name = JSONPropertyString.new()
	name.set_min_length(1)
	name.set_max_length(50)

	var style_data = JSONPropertyObject.new()
	style_data.add_property("Author", author)
	style_data.add_property("Name", name)

	return style_data
