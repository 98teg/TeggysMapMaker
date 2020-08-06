class_name _StyleDataParser

const _max_StyleData_Author_length : int = 20
const _max_StyleData_Name_length : int = 20

static func parse(base_parser : _BaseParser, configuration : Dictionary) -> Dictionary:
	var StyleData = base_parser._check_obligatory_object(configuration, "StyleData")

	StyleData.Author = base_parser._check_obligatory_string(StyleData, "Author", _max_StyleData_Author_length, "StyleData")
	StyleData.Name = base_parser._check_obligatory_string(StyleData, "Name", _max_StyleData_Name_length, "StyleData")

	return StyleData
