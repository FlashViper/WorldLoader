@tool
class_name WorldFile extends Resource

const VERSION := &"0.1 pre"
const StringParser := preload("./StringParser.gd")

@export var name : StringName
@export var levels : Array[LevelData]


static func loadFromFile(path: StringName) -> WorldFile:
	if !FileAccess.file_exists(path):
		return WorldFile.new()
	
	var f := FileAccess.open(path, FileAccess.READ)
	var w := WorldFile.new()
	var parser := StringParser.new()
	
	var r_property := RegEx.create_from_string(&"\t*(.*):[\t ]*(.*)")
	var r_level := RegEx.create_from_string(&"Level[ \t]*(\\d*)")
	
	f.get_line() # TODO: Check against header to verify the correct file type
	f.get_line() # TODO: Check against version number and warn if different
	
	# Parse initial values
	var newLine : String
	while f.get_position() < f.get_length():
		newLine = f.get_line()
		if r_level.search(newLine):
			break
		
		var p := r_property.search(newLine)
		if p:
			w.set(p.get_string(1), str_to_var(p.get_string(2)))
	
	w.levels = []
	var levelCount := -1
	var currentLevel : LevelData
	
	while f.get_position() < f.get_length():
		if newLine.begins_with("\t"):
			var p := r_property.search(newLine)
			if p:
				var propertyValue := p.get_string(1)
				var strValue := p.get_string(2)
				
				var potentialValue = str_to_var(strValue)
				
				if potentialValue == null:
					potentialValue = parser.attemptParse(strValue)
				
				currentLevel.set(propertyValue, potentialValue)
		else:
			if r_level.search(newLine):
				levelCount += 1
				if currentLevel:
					w.levels.append(currentLevel)
				currentLevel = LevelData.new()
		newLine = f.get_line()
	
	return w

func saveToFile(path: StringName) -> void:
	const VERSION_TAG := &"FlashViper WorldFile\nVersion %s"
	const PROPERTY_TAG := &"%s: %s"
	const LEVEL_TAG := &"Level %02d:"
	
	var f := FileAccess.open(path, FileAccess.WRITE)
	
	if !f:
		printerr("File '%s' could not be opened" % path)
		return
		
	f.store_line(VERSION_TAG % VERSION)
	f.store_line("")
	
	var properties := [
		["name", name],
#		["devNotes", name],
	]
	
	for p in properties:
		f.store_line(PROPERTY_TAG % p)
	
	for i in levels.size():
		f.store_line("")
		
		var l := levels[i]
		f.store_line(LEVEL_TAG % [i])
		
		properties = [
			["name", l.name],
			["filePath", l.filePath],
			["position", l.position],
			["size", l.size],
			["connections", l.connections],
		]
		
		for p in properties:
			f.store_line("\t" + (PROPERTY_TAG % [p[0], var_to_str(p[1])]))
