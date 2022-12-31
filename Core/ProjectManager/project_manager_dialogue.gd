extends PanelContainer

@export var thumbnail_scene : PackedScene
@export var create_dialogue_scene : PackedScene

func _ready() -> void:
	%Create.pressed.connect(open_create_dialogue)
	%Load.pressed.connect(open_load_dialogue)
	
#	var currentSize := DisplayServer.window_get_size()
#	DisplayServer.window_set_size(
#		Vector2i(currentSize.y * 0.8, currentSize.y
#	))
	
	if FileAccess.file_exists(ProjectManager.PROJECT_LIST):
		var f := FileAccess.open(ProjectManager.PROJECT_LIST, FileAccess.READ)
		
		while f.get_position() < f.get_length():
			var line := f.get_line()
			if FileAccess.file_exists(line):
				create_thumbnail(line)

func create_thumbnail(project_path: String) -> void:
	var f := FileAccess.open(project_path, FileAccess.READ)
	var data := JSON.parse_string(f.get_as_text()) as Dictionary
	# Parse file here
	var thumbnail := thumbnail_scene.instantiate()
	thumbnail.get_node("%Name").text = data.get("name", "Untitled Project")
	thumbnail.get_node("%Description").text = data.get("description", "No Description")
	%ThumbnailRoot.add_child(thumbnail)


func open_create_dialogue() -> void:
	print("Creating")

func open_load_dialogue() -> void:
	print("Loading")
