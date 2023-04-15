# A static class with a bunch of commands for parsing strings
# Thanks to regexr.com for helping test the regular expressions!!!
extends RefCounted

# 2 capture groups: [1]: x, [2]: y
const REGEX_VEC2 := &"\\( *(-?[\\d. ]+) *, *(-?[\\d. ]*) *\\)$"
# 1 capture group: [1]: number
const REGEX_NUMBER := &"^ *(-?[\\d. ]*)"
const REGEX_STRING := &"""['"](.*?)['"]"""

var regexes := {
	REGEX_VEC2: parse_vector2,
	REGEX_NUMBER: parse_float,
	REGEX_STRING: parse_string,
}

func attempt_parse(value: String) -> Variant:
	for pattern in regexes:
		var r := RegEx.create_from_string(pattern)
		var m := r.search(value)
		if m:
			return (regexes[pattern] as Callable).call(m)
	
	printerr("StringParser.gd: Couldn't find a parser for value %s" % value)
	return null

func parse_vector2(m: RegExMatch) -> Vector2:
	return Vector2(float(m.get_string(1)), float(m.get_string(2)))

func parse_float(m: RegExMatch) -> float:
	return float(m.get_string(1))

func parse_string(m: RegExMatch) -> String:
	return m.get_string(1)
