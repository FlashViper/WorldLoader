extends Node

const PROJECT_LIST := "user://project_list.txt"

var projectName : StringName
var notes : StringName

var tileSize := 64

@onready var minimum_screen_size = Vector2i(
	ProjectSettings.get_setting("display/window/size/viewport_width"),
	ProjectSettings.get_setting("display/window/size/viewport_height")
) / tileSize
