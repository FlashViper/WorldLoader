extends Tool

signal stamped_level(level: LevelFile, position: Vector2i)

@export var levelScene : PackedScene
@onready var preview : Control = $Preview

var world : WorldFile
var current_level : LevelFile

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


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.is_pressed():
				stamp()


func load_file(filename: String) -> void:
	current_level = LevelFile.load_from_file(filename)
	preview.size = current_level.size * ProjectManager.tile_size
	preview.show()


func _process(delta: float) -> void:
	var targetPos := preview.get_global_mouse_position()
	targetPos -= preview.size * 0.5
	targetPos = (targetPos / ProjectManager.tile_size).floor()
	targetPos *= ProjectManager.tile_size
	
	preview.position = preview.position.lerp(
		targetPos, 0.5
	)


func stamp() -> void:
	preview.hide()
	
	var mouse_pos := preview.get_global_mouse_position()
	mouse_pos -= preview.size * 0.5
	mouse_pos = (mouse_pos / ProjectManager.tile_size).floor()
	
	var position := Vector2i(mouse_pos)
	stamped_level.emit(current_level, position)
