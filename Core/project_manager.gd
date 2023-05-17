extends Node

const PROJECT_LIST := "user://project_list.txt"

var current_project : WorldSettings
var project_path : String
var project_directory : String : 
	get: return get_current_project_path()


func _get(property: StringName):
	if current_project:
		if property in current_project:
			return current_project.get(property)


func _get_property_list() -> Array:
	if current_project:
		return current_project.get_property_list()
	
	return []


func _enter_tree() -> void:
	create_new("")
	current_project.screen_size_px = Vector2i(1920, 1080)


func create_new(path: String) -> void:
	project_path = path
	
	current_project = WorldSettings.new()
	current_project.project_name = "Untitled Project"


func load_from_file(path: String) -> void:
	project_path = path
	current_project = ResourceLoader.load(project_path)


func save_to_file() -> void:
	ResourceSaver.save(current_project, convert_path(project_path))


func convert_path(path_in: String) -> String:
	return path_in.replace("proj:/", project_directory)


func get_current_project_path() -> String:
	return project_path.get_base_dir()


func get_previous_projects() -> Array[String]:
	if FileAccess.file_exists(PROJECT_LIST):
		var f := FileAccess.open(PROJECT_LIST, FileAccess.READ)
		var result : Array[String] = []
		
		while f.get_position() < f.get_length():
			var line := f.get_line()
			if FileAccess.file_exists(line):
				if !result.has(line):
					result.append(line)
		
		return result
	
	return []


func has_world() -> bool:
	
	return false


func add_world_path(path: String) -> void:
	pass


func update_recent_projects() -> void:
	pass
