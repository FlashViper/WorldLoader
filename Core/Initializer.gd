extends Node

@export var project_selector : PackedScene
@export var project_overview : PackedScene

func _ready() -> void:
	var args := OS.get_cmdline_user_args()
	match args as Array:
		["-p", ..]:
			get_tree().change_scene_to_packed(project_selector)
		["-o", var path, ..]:
			if !(path is String):
				continue
			if !FileAccess.file_exists(path):
				continue
			
			ProjectManager.load_from_file(path)
			get_tree().change_scene_to_packed(project_overview)
#	get_tree().change_scene_to_packed(project_selector)
