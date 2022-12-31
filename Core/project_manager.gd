extends Node

const PROJECT_LIST := "user://project_list.txt"

var project_path : StringName
var project_directory : String : 
	get: return get_current_project_path()

var project_name : StringName
var description : String
var world_files : Array[String]
var tile_size := 64

@onready var screen_size_px := Vector2i(
	ProjectSettings.get_setting("display/window/size/viewport_width"),
	ProjectSettings.get_setting("display/window/size/viewport_height")
)

@onready var minimum_screen_size = screen_size_px / tile_size

func initialize() -> void:
	project_path = ""
	
	project_name = "Untitled Project"
	description = ""
	tile_size = 64
	world_files = []

func load_from_file(path: String) -> void:
	var f := FileAccess.open(path, FileAccess.READ)
	var text := f.get_as_text()
	var json_data = JSON.parse_string(text)
	for j in json_data:
		set(j, json_data[j])

func convert_path(path_i: String) -> String:
	return path_i.replace("proj:/", project_directory)

func save_to_file() -> void:
	var data := inst_to_dict(self)
	for s in ["@path", "@subpath"]:
		data.erase(s)
	
	var f := FileAccess.open(project_path, FileAccess.WRITE)
	f.store_string(JSON.stringify(data, "\t"))

func get_current_project_path() -> String:
	return project_path.get_base_dir()
