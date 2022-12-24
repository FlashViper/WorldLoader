extends Node

const LevelLoader := preload("./Loader_Level.gd")

@onready var levelLoader : LevelLoader = %LevelLoader

func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.keycode == KEY_O and event.is_pressed() and event.ctrl_pressed:
			$open_dialogue.request_file()
			var filepath : String = await $open_dialogue.file_submitted
			if FileAccess.file_exists(filepath):
				var f := load(filepath)
				if f is WorldFile:
					loadWorld(f)

func loadWorld(w: WorldFile) -> void:
	pass
