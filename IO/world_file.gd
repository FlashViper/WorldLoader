class_name WorldFile extends Resource

var name : StringName
#var devNotes : String

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
	pass
