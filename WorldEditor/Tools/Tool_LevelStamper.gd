extends Tool

@export var levelScene : PackedScene
@onready var preview : Control = $Preview

func _ready() -> void:
	preview.hide()

func initialize() -> void:
	pass

func _shortcut_input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.keycode == KEY_O:
			if event.ctrl_pressed and event.shift_pressed:
				$OpenLevel.request_file()
				var filename = await $OpenLevel.file_submitted
				if filename != "":
					if FileAccess.file_exists(filename):
						load_file(filename)

func load_file(filename: String) -> void:
	var level := LevelFile.loadFromFile(filename)
	preview.size = level.size * ProjectManager.tile_size
	preview.show()

func _process(delta: float) -> void:
	var targetPos := preview.get_global_mouse_position()
	targetPos -= preview.size * 0.5
	targetPos = (targetPos / ProjectManager.tile_size).floor()
	targetPos *= ProjectManager.tile_size
	
	preview.position = preview.position.lerp(
		targetPos, 0.5
	)
