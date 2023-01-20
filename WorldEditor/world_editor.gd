# Stats:
# Max Levels (Saving): ~1,000    --> O(n^2)
# Max Levels (Loading): LOTS     --> O(n)
# Max Levels (Collision): LOTS   --> O(n) [somehow]
extends Node

signal level_edited(path: String, position: Vector2i)

@export var toolbar_scene : PackedScene
@onready var save_dialogue := $Dialogue_World
@onready var canvas : ConfigurableCanvas = $Canvas

var tools : Array[Tool] = []
var current_filepath := ""

var toolbar
var settings_popup : Control

func _ready() -> void:
	CameraManager.activate()
	tools.append($Tools/LevelArranger)
	
	for t in tools:
		t.initialize()
	tools[0].enable_tool()
	
	toolbar = toolbar_scene.instantiate()
	canvas.add_control(toolbar, Control.PRESET_LEFT_WIDE)
	toolbar.save_pressed.connect(save_current_world)
	toolbar.settings_pressed.connect(toggle_settings_menu)

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
		save_dialogue.request_file()
		var filepath = await save_dialogue.file_submitted
		if filepath != "" and filepath != null:
			current_filepath = filepath
		else:
			return
		
	save_to_disk(current_filepath)


func load_from_disk(path: StringName) -> void:
	if !FileAccess.file_exists(path):
		printerr("Nonexistant world at path %s" % path)
		return
	
	current_filepath = path
	
	var world := WorldFile.loadFromFile(path)
	for t in tools:
		t.load_data(world)


func save_to_disk(path: StringName) -> void:
	if !ProjectManager.has_world(path):
		ProjectManager.add_world_path(path)
		ProjectManager.save_to_file()
	
	var world := WorldFile.new()
	for t in tools:
		if t.has_method("save_data"):
			world.save_data(world)
	world.saveToFile(ProjectManager.convert_path(path))
