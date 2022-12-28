extends Node

@onready var collisionMap := $CollisionMap
var currentLevels : Dictionary


func _ready() -> void:
	collisionMap.tileSize = Vector2i.ONE * ProjectManager.tileSize
	var l := preload("res://Testing/Levels/jefaloosh.lvl")
	loadLevel(l)

func loadLevel(level : LevelFile, position := Vector2i.ZERO) -> void:
	collisionMap.load_collision_at_position(level, position)

@warning_ignore(unused_parameter)
func unloadLevel(level: LevelFile) -> void:
	collisionMap.clear_rect()
