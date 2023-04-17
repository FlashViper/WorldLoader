class_name WorldSettings
extends Resource

@export var project_name := &"New Project"
@export_multiline var description : String
@export var world_files : Array[String]
@export var tile_size := 64
@export var screen_size_px : Vector2i

var minimum_screen_size : Vector2i :
	get: return screen_size_px / tile_size


static func create_new(p_tile_size: int, p_screen_size: Vector2i) -> WorldSettings:
	var p := WorldSettings.new()
	p.screen_size_px = p_screen_size
	p.tile_size = p_tile_size
	
#	Vector2i(
#		ProjectSettings.get_setting("display/window/size/viewport_width"),
#		ProjectSettings.get_setting("display/window/size/viewport_height")
#	)
	
	return p
