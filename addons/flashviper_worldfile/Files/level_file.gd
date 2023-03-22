@icon("../Icons/icon_levelfile.tres")
class_name LevelFile extends Resource

const VERSION := &"0.1 development"

enum {
	ID_NULL,
	ID_TILEDATA,
	ID_ENTITIES,
	ID_DECORATION,
}

# METADATA
@export var name : StringName

@export var size : Vector2i

# TODO: Compression???
@export var tileData : PackedByteArray
var entities
var decoration

func _init() -> void:
	if !Engine.is_editor_hint():
		size = ProjectManager.minimum_screen_size

static func loadFromFile(path: StringName) -> LevelFile:
	if !FileAccess.file_exists(path):
		return LevelFile.new()
	
	var f := FileAccess.open(path, FileAccess.READ)
	var l := LevelFile.new()
	
	var parser := preload("../StringParser.gd").new()
	var r_property := RegEx.create_from_string(&"\t*(.*):[\t ]*(.*)") # [name]: [thing]
	var r_datablock := RegEx.create_from_string(&"^\\[(.*)\\]")
	
	# TODO: Throw warning when level is of a different version
	f.get_line() # should be header to designate Level File, but I'm too lazy to check so far
	f.get_line() # should be version, but I'm too lazy to check so far
	
	var new_line := f.get_line()
	while f.get_position() < f.get_length():
		var m := r_property.search(new_line)
		if m:
			var parsedValue = str_to_var(m.get_string(2))
			
			if parsedValue == null:
				parsedValue = parser.attemptParse(m.get_string(2))
			
			l.set(m.get_string(1), parsedValue)
		else:
			var match_data := r_datablock.search(new_line)
			if match_data and match_data.get_string(1) == "DATA":
				break
		
		new_line = f.get_line()
	
	while f.get_position() < f.get_length():
		var id := f.get_8() # pull one byte from the file to tell us what to parse next
		match id:
			ID_TILEDATA:
				var length := f.get_32()
				l.tileData = f.get_buffer(length)

	
	return l

func saveToFile(path: StringName) -> void:
	const HEADER := &"FlashViper WorldFile\nVersion %s\n"
	const PROPERTY_TAG := &"%s: %s"
	
	var f := FileAccess.open(path, FileAccess.WRITE)
	
	f.store_line(HEADER % VERSION)
	f.store_line(PROPERTY_TAG % ["name", name])
	f.store_line(PROPERTY_TAG % ["size", var_to_str(size)])
	f.store_line("")
	
	f.store_line("[DATA]")
	# Store Tile Data
	f.store_8(ID_TILEDATA)
	f.store_32(tileData.size())
	f.store_buffer(tileData)
	
	# Store Entity Data
	# TODO
	
	# Store Decoration Data
	# TODO
