class_name WorldFile extends Resource

const VERSION := &"0.1 pre"

var name : StringName
var levels : Array[LevelData]

class LevelData:
	var filePath : StringName = &""
	
	var position : Vector2i = Vector2i.ZERO
	var size : Vector2i = Vector2i.ONE * 2
	var connections : PackedInt64Array

static func loadFromFile(path: StringName) -> WorldFile:
	if !FileAccess.file_exists(path):
		return WorldFile.new()
	
	var w := WorldFile.new()
	return w

func saveToFile(path: StringName) -> void:
	const VERSION_TAG := &"FlashViper WorldFile\nVersion %s"
	const PROPERTY_TAG := &"%s: %s"
	const LEVEL_TAG := &"Level %02d"
	
	var f := FileAccess.open(path, FileAccess.WRITE)
	f.store_line(VERSION_TAG % VERSION)
	
	var properties := [
		["name", name],
#		["devNotes", name],
	]
	
	for p in properties:
		f.store_line(PROPERTY_TAG % p)
	
	properties = []
	for i in levels.size():
		var l := levels[i]
		f.store_line(LEVEL_TAG % [i])
		
		properties.append_array([
			["filePath", l.filePath],
			["position", l.position],
			["size", l.size],
			["connections", l.connections],
		])
		
		for p in properties:
			f.store_line("\t" + (PROPERTY_TAG % p))
		
		if i < levels.size() - 1:
			f.store_line(&"")
