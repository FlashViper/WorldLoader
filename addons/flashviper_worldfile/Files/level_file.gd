@icon("../Icons/icon_levelfile.tres")
class_name LevelFile
extends Resource

const VERSION := &"0.1 development"

enum {
	ID_NULL,
	ID_TILEDATA,
	ID_ENTITIES,
	ID_DECORATION,
}

enum {
	DECO_IMAGE,
	DECO_SCENE,
	DECO_IMAGE_COLOR,
}

# METADATA
@export var name : StringName

@export var size : Vector2i

# TODO: Compression???
@export var tileData : PackedByteArray

# {String -> Vector2}
@export var respawn_points : Dictionary
@export var entities : Dictionary
@export var deco_textures : Array[String]
@export var decoration : Array[Dictionary]


func _init() -> void:
	deco_textures = []
	decoration = []
	
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
	var properties := {"":[]}
	var current_property := ""
	
	while f.get_position() < f.get_length():
		var match_data := r_datablock.search(new_line)
		if match_data:
			if match_data.get_string(1) == "DATA":
				break
			else:
				current_property = match_data.get_string(1)
				properties[current_property] = []
		else:
			properties[current_property].append(new_line)
		
		new_line = f.get_line()
	
	
	for category in properties:
		match category:
			"":
				for line in properties[category]:
					var m := r_property.search(line)
					if m:
						var parsed_value = str_to_var(m.get_string(2))
						if parsed_value == null:
							parsed_value = parser.attempt_parse(m.get_string(2))
						l.set(m.get_string(1), parsed_value)
			"TEXTURES":
				for prop in properties[category]:
					l.deco_textures.append(prop)
			"RESPAWN":
				l.respawn_points = {}
				for line in properties[category]:
					var m := r_property.search(line)
					if m:
						var position = parser.attempt_parse(m.get_string(2))
						
						prints(m.get_string(2), position)
						if position is Vector2:
							l.respawn_points[m.get_string(1)] = position
				
	while f.get_position() < f.get_length():
		var id := f.get_8() # pull one byte from the file to tell us what to parse next
		match id:
			ID_TILEDATA:
				var length := f.get_32()
				l.tileData = f.get_buffer(length)
			ID_DECORATION:
				var length := f.get_32()
				for i in length:
					var deco_type := f.get_16()
					var path_id := f.get_32()
					var transform := f.get_var() as Transform2D
					l.decoration.append({
						"path_index": path_id,
						"transform": transform,
					})
	
	return l


func save_to_file(path: StringName) -> void:
	const HEADER := &"FlashViper WorldFile\nVersion %s\n"
	const PROPERTY_TAG := &"%s: %s"
	
	var f := FileAccess.open(path, FileAccess.WRITE)
	
	f.store_line(HEADER % VERSION)
	f.store_line(PROPERTY_TAG % ["name", name])
	f.store_line(PROPERTY_TAG % ["size", var_to_str(size)])
	
	if deco_textures.size() > 0:
		f.store_line("[TEXTURES]")
		for d in deco_textures:
			f.store_line(d)
	
	if respawn_points.size() > 0:
		f.store_line("[RESPAWN]")
		for r in respawn_points:
			f.store_line(PROPERTY_TAG % [r, respawn_points[r]])
	
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
	if decoration.size() > 0:
		f.store_8(ID_DECORATION)
		f.store_32(decoration.size())
		for d in decoration:
			var path_index := d["path_index"] as int
			var transform_packed := d["transform"] as Transform2D
			
			f.store_16(DECO_IMAGE) # Sprite based decoration by default
			f.store_32(path_index)
			f.store_var(transform_packed)
