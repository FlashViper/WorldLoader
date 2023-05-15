extends PanelContainer
const FILE_PATH_DIR := "%s"

@export var project_viewer : PackedScene
@export var thumbnail_scene : PackedScene
@export var create_dialogue_scene : PackedScene

var project_list : Array[String] = []


func _ready() -> void:
	DisplayServer.window_set_size(Vector2i(1080, 1280))
	%Create.pressed.connect(open_create_dialogue)
	%Load.pressed.connect(open_load_dialogue)
	
	if FileAccess.file_exists(ProjectManager.PROJECT_LIST):
		var f := FileAccess.open(ProjectManager.PROJECT_LIST, FileAccess.READ)
		
		while f.get_position() < f.get_length():
			var line := f.get_line()
			if FileAccess.file_exists(line):
				if !project_list.has(line):
					project_list.append(line)
	
	for p in project_list:
		create_thumbnail(p)


func create_project(path: String, data: Dictionary) -> void:
	const POPULATORS := ["project_name", "description", "tile_size"]
	ProjectManager.create_new(path) # Reset all data
	
	for p in POPULATORS:
		if data.has(p):
			ProjectManager.set(p, data[p])
	
	ProjectManager.save_to_file()
	project_list.append(path)
	
	update_project_list()
	get_tree().change_scene_to_file("res://Core/ProjectManager/project_view.tscn")
#	get_tree().change_scene_to_file("res://LevelEditor/level_editor.tscn")


func update_project_list() -> void:
	var f := FileAccess.open(ProjectManager.PROJECT_LIST, FileAccess.WRITE)
	for p in project_list:
		f.store_line(p)


func create_thumbnail(project_path: String) -> void:
	var project = ResourceLoader.load(project_path) as WorldSettings
	if project == null:
		return
	
	# Parse file here
	var thumbnail := thumbnail_scene.instantiate()
	thumbnail.get_node("%Name").text = project.project_name
	thumbnail.get_node("%Description").text = project.description
	thumbnail.gui_input.connect(on_thumbnail_input.bind(project_path))
	%ThumbnailRoot.add_child(thumbnail)


func on_thumbnail_input(event: InputEvent, path: String) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.double_click:
				on_file_recieved(path)


func open_create_dialogue() -> void:
	var popup := Window.new()
	popup.transient = true
	popup.title = "Create Project"
	popup.close_requested.connect(popup.queue_free)
	popup.wrap_controls = true
	
	var dialogue := create_dialogue_scene.instantiate()
	dialogue.created_project.connect(create_project)
	dialogue.created_project.connect(popup.queue_free.unbind(2))
	dialogue.canceled.connect(popup.queue_free)
	popup.add_child(dialogue)
	
	
	get_tree().root.add_child(popup)
	popup.popup_centered()


func open_load_dialogue() -> void:
	var file_dialogue := FileDialog.new()
	
	file_dialogue.access = FileDialog.ACCESS_FILESYSTEM
	file_dialogue.show_hidden_files = false
	
	if OS.has_environment("USERNAME"):
		var current_path := "C:/Users/" + OS.get_environment("USERNAME")
		if DirAccess.dir_exists_absolute(current_path + "/Documents"):
			file_dialogue.current_dir = current_path + "/Documents"
		else:
			file_dialogue.current_dir = current_path
	
	file_dialogue.add_filter("*.tres, *.res", "Project File")
	file_dialogue.file_mode = FileDialog.FILE_MODE_OPEN_FILE
	
	file_dialogue.file_selected.connect(on_file_recieved)
	file_dialogue.canceled.connect(file_dialogue.queue_free)
	file_dialogue.file_selected.connect(file_dialogue.queue_free.unbind(1))
	
	get_tree().root.add_child(file_dialogue)
	file_dialogue.popup_centered(Vector2i(1920, 1080))


func on_file_recieved(path: String) -> void:
	if FileAccess.file_exists(path):
		if !project_list.has(path):
			project_list.append(path)
			update_project_list()
		
		ProjectManager.load_from_file(path)
#		get_tree().change_scene_to_packed(project_viewer)
		get_tree().change_scene_to_packed(preload("res://LevelEditor/level_editor.tscn"))
