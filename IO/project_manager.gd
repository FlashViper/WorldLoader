extends Node

var projectName : StringName
var notes : StringName

var tileSize := Vector2i(64, 64)

@onready var minimum_screen_size = Vector2i(
	ProjectSettings.get_setting("display/window/size/viewport_width"),
	ProjectSettings.get_setting("display/window/size/viewport_height")
) / tileSize
