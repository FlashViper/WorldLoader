extends Node

@onready var collision_map := $CollisionMap
var current_levels : Dictionary


func _ready() -> void:
	collision_map.tileSize = Vector2i.ONE * ProjectManager.tile_size
	var l := preload("res://Testing/Levels/respawn.lvl")
	
	print(inst_to_dict(l))
	loadLevel(l)

func loadLevel(level : LevelFile, position := Vector2i.ZERO) -> void:
	collision_map.load_collision_at_position(level, position)
	print(level.respawn_points)
	for p in level.respawn_points:
		print(level.respawn_points[p])
		var s := Sprite2D.new()
		s.texture = preload("res://GUI/Icons/LevelEditor/icon_level_leveldata.tres")
		s.position = level.respawn_points[p]
		add_child(s)
	
	var target_point := "entrance_nw"
	var default_id : String = level.respawn_points.keys()[0]
	var default_point : Vector2 = level.respawn_points[default_id]
	$TestCharacter.position = level.respawn_points.get(target_point, default_point)
	$TestCharacter.snap_to_ground()


@warning_ignore("unused_parameter")
func unloadLevel(level: LevelFile) -> void:
	collision_map.clear_rect()
