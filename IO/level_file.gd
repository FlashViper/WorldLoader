class_name LevelFile extends Resource

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
	
	var f := FileAccess.open(path, FileAccess.READ)
	var l := LevelFile.new()
	
	f.get_line() # should be header to designate Level File, but I'm too lazy to check so far
	f.get_line() # should be version, but I'm too lazy to check so far
	# TODO: Throw warning when level is of a different version
	l.name = f.get_line()
	
	while f.get_position() < f.get_length():
		var id := f.get_8() # pull one byte from the file to tell us what to parse next
		match id:
			ID_TILEDATA:
				var length := f.get_32()
				l.tileData = PackedByteArray()
				
				for i in length:
					l.tileData.append(i)
	
	return l

func saveToFile(path: StringName) -> void:
	const HEADER := &"FlashViper LevelFile\nVersion %s"
	
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
