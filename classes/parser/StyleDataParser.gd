class_name _StyleDataParser

var _base_parser : _BaseParser
const _max_StyleData_Author_length : int = 20
const _max_StyleData_Name_length : int = 20

func parse(base_parser : _BaseParser, configuration : Dictionary) -> Dictionary:
	_base_parser = base_parser
	var style_data = _base_parser._check_obligatory_object(configuration, "StyleData")

	var parsed_conf = {}
	parsed_conf.Author = _base_parser._check_obligatory_string(style_data, "Author", _max_StyleData_Author_length, "StyleData")
	parsed_conf.Name = _base_parser._check_obligatory_string(style_data, "Name", _max_StyleData_Name_length, "StyleData")

	return parsed_conf
