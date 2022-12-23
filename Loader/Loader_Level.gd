extends Node

var collisionMap
var currentLevels : Dictionary

func loadLevel(id: String, level : LevelFile, position : Vector2i) -> void:
	collisionMap.load_collision_at_position(level.tileData, position)
	currentLevels[id] = {
		"level": level,
	}

func unloadLevel(id: String) -> void:
	collisionMap.clear_rect()
