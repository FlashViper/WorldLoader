# Stats:
# Max Levels (Saving): ~1,000    --> O(n^2)
# Max Levels (Loading): LOTS     --> O(n)
# Max Levels (Collision): LOTS   --> O(n) [somehow]
extends Node

@onready var save_dialogue := $Dialogue_World

var tools : Array[Tool] = []
var current_filepath := ""

func _ready() -> void:
	tools.append($Tools/LevelArranger)
	
	for t in tools:
		t.initialize()
	tools[0].enable_tool()

func save_current_world() -> void:
	if current_filepath != "":
		save_to_disk(current_filepath)
	else:
		save_dialogue.request_file()
		var filepath = await save_dialogue.file_submitted
		if filepath != "" and filepath != null:
			save_to_disk(filepath)

func load_from_disk(path: StringName) -> void:
	if !FileAccess.file_exists(path):
		printerr("Nonexistant world at path %s" % path)
		return
	
	current_filepath = path
	
	var world := WorldFile.loadFromFile(path)
	for t in tools:
		t.load_data(world)

func save_to_disk(path: StringName) -> void:
	var world := WorldFile.new()
	for t in tools:
		world.save_data(world)
	world.saveToFile(path)
