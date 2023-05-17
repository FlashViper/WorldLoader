# Stats:
# Max Levels (Saving): ~1,000    --> O(n^2)
# Max Levels (Loading): LOTS     --> O(n)
# Max Levels (Collision): LOTS   --> O(n) [somehow]
extends Node

signal level_edited(path: String, position: Vector2i)

@export var standalone : bool
@export var toolbar_scene : PackedScene

@onready var save_dialog : Node = $SaveDialog
@onready var open_dialog : Node = $OpenDialog
@onready var canvas : ConfigurableCanvas = $Canvas

@onready var level_arranger = $LevelArranger

var current_filepath := ""
var world : WorldFile

var toolbar
var settings_popup : Control


func _enter_tree() -> void:
	if standalone:
		world = WorldFile.new()
		DisplayServer.window_set_size(Vector2i(1920, 1080))

func _ready() -> void:
	CameraManager.activate()
	
	toolbar = toolbar_scene.instantiate()
	toolbar.save_pressed.connect(save_current_world)
	toolbar.settings_pressed.connect(toggle_settings_menu)
	canvas.add_control(toolbar, Control.PRESET_LEFT_WIDE)


func _input(event: InputEvent) -> void:
	if event.is_action("open"):
		open_dialog.request_file()
		var filepath = await open_dialog.file_submitted
		if filepath != "":
			if filepath != "":
				level_arranger.add_level_from_file(filepath, Vector2())


func enable() -> void:
	pass


func disable() -> void:
	pass


func toggle_settings_menu() -> void:
	if settings_popup:
		settings_popup.queue_free()
		settings_popup = null
	else:
		settings_popup = preload("./Panels/world_properties.tscn").instantiate()
		canvas.add_control(settings_popup)


func save_current_world() -> void:
	if current_filepath == "":
		save_dialog.request_file()
		var filepath = await save_dialog.file_submitted
		if filepath != "" and filepath != null:
			current_filepath = filepath
		else:
			return
	
	save_to_disk(current_filepath)


func load_from_disk(path: String) -> void:
	if !FileAccess.file_exists(path):
		printerr("Nonexistant world at path %s" % path)
		return
	
	world = WorldFile.load_from_file(path)


func save_to_disk(path: String) -> void:
#	if !ProjectManager.has_world(path):
#		ProjectManager.add_world_path(path)
#		ProjectManager.update_recent_worlds()
	
	level_arranger.save_levels(world)
	print(ProjectManager.convert_path(path) )
	world.save_to_file(ProjectManager.convert_path(path))
