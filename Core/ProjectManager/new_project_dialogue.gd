extends PanelContainer

signal created_project(path: String, data: Dictionary)
signal canceled

func _ready() -> void:
	%Create.pressed.connect(create_project)
	%Cancel.pressed.connect(cancel_dialogue)
	%PathDialogue.pressed.connect(open_file_dialogue)


func create_project() -> void:
	var path = %Path.text
	
	var data := {
		"project_name": %Name.text,
		"description": %Description.text,
		"tile_size": int(%TileSize.value),
	}
	
	created_project.emit(path, data)

func cancel_dialogue() -> void:
	canceled.emit()

func on_file_recieved(path: String) -> void:
	%Path.text = path

func open_file_dialogue() -> void:
	var file_dialogue := FileDialog.new()
	file_dialogue.access = FileDialog.ACCESS_FILESYSTEM
	file_dialogue.show_hidden_files = false
	if OS.has_environment("USERNAME"):
		var current_path := "C:/Users/" + OS.get_environment("USERNAME")
		if DirAccess.dir_exists_absolute(current_path + "/Documents"):
			file_dialogue.current_dir = current_path + "/Documents"
		else:
			file_dialogue.current_dir = current_path
	file_dialogue.add_filter("*.project, *.prj", "Project File")
	file_dialogue.file_mode = FileDialog.FILE_MODE_OPEN_FILE
	
	file_dialogue.file_selected.connect(on_file_recieved)
	file_dialogue.file_selected.connect(file_dialogue.queue_free)
	file_dialogue.cancelled.connect(file_dialogue.queue_free)
	
	get_tree().root.add_child(file_dialogue)
	file_dialogue.popup_centered(Vector2i(1920, 1080))
