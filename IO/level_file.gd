class_name LevelFile extends Resource

const HEADER := &"LevelFile v%s"
const VERSION := &"0.1 development"

enum {
	ID_NULL,
	ID_TILEDATA,
	ID_ENTITIES,
	ID_DECORATION,
}

# METADATA
var name : StringName
#var notes : String

var size : Vector2

# TODO: Compression???
var tileData : PackedByteArray
var entities
var decoration

static func loadFromFile(path: StringName) -> LevelFile:
	if FileAccess.file_exists(path):
		return LevelFile.new()
	
	var l := LevelFile.new()
	return l

func saveToFile(path: StringName) -> void:
	var f := FileAccess.open(path, FileAccess.WRITE)
	
	f.store_line(HEADER % VERSION)
	f.store_line(name)
	
	# Store Tile Data
	f.store_8(ID_TILEDATA)
	f.store_32(tileData.size())
	f.store_buffer(tileData)
	
	# Store Entity Data
	# TODO
	
	# Store Decoration Data
	# TODO
