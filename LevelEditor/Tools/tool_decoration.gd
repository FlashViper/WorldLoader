extends Tool

var level : LevelFile


func save_data() -> void:
	pass


func load_data(p_level: LevelFile) -> void:
	if p_level != null:
		level = p_level
