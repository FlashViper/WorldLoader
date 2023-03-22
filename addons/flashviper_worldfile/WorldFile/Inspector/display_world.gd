@tool
extends PanelContainer

const LEVEL_DATA_DISPLAY := preload("./display_level_data.tscn")

@onready var levelSearch : LineEdit = %LevelFilter

var world : WorldFile
var dataDisplays : Array[Control]

func _ready() -> void:
	levelSearch.text_changed.connect(updateSearch)

func display(new : WorldFile = null) -> void:
	if new:
		world = new
	
	if !world:
		printerr("Tried to display a null worldfile")
		return
	
	%WorldName.text = world.name if world.name != "" else "Untitled World"
	
	if dataDisplays.size() > 0:
		for i in dataDisplays.size():
			dataDisplays[-1 - i].queue_free()
	
	var root := getLevelRoot()
	dataDisplays = []
	
	for i in world.levels.size():
		var d := LEVEL_DATA_DISPLAY.instantiate()
		d.displayData(world.levels[i], i)
		root.add_child(d)
	
	%LayoutView.updateWorld(world)

func getLevelRoot() -> Control:
	return %LevelRoot

# TODO
func updateSearch(text: String) -> void:
	pass
#	if text == "":
#		return
#
#	for i in dataDisplays.size():
#		if text == "":
#			dataDisplays[i].show()
#		else:
#			dataDisplays[i].visible = world.levels[i].name.begins_with(text)
