extends Node

@onready var save_dialogue := $SaveLevel
@onready var canvas : ConfigurableCanvas = $GUI

var shortcuts := []

var current_filepath := ""
var tools : Array
var currentTool : int

var toolbar : Control
#var level_inspector [TODO]

func _ready() -> void:
	var save_input := InputEventKey.new()
	save_input.keycode = KEY_S
	save_input.ctrl_pressed = true
	add_shortcut(save_input, save_current_level)
	
	tools.append($Tools/Tilemap)
	create_toolbar()
	create_new_level()
	select_tool(0)
	show_gui()

func create_toolbar() -> void:
	if toolbar:
		toolbar.queue_free()
	
	toolbar = preload("res://LevelEditor/GUI/tool_selector.tscn").instantiate()
	toolbar.save_pressed.connect(save_current_level)
	toolbar.tool_button_pressed.connect(select_tool)
	canvas.add_control(toolbar, Control.PRESET_LEFT_WIDE)
	
	for i in tools.size():
		toolbar.add_tool(tools[i].get_icon(), i)

func show_gui() -> void:
	pass

func create_new_level() -> void:
	current_filepath = ""
	for t in tools:
		t.initialize()

func add_shortcut(input: InputEvent, event: Callable) -> void:
	var s := Shortcut.new()
	s.events.append(input)
	shortcuts.append({
		"shortcut": s,
		"action": event
	})

func _shortcut_input(event: InputEvent) -> void:
	for s in shortcuts:
		if s.shortcut.matches_event(event):
			s.action.call()
			get_tree().root.set_input_as_handled()

func select_tool(index: int) -> void:
	if index == currentTool:
		return
	
	if index >= 0:
		tools[index].enable_tool()
	if currentTool >= 0:
		tools[currentTool].disable_tool()
	
	currentTool = index

func save_current_level() -> void:
	if current_filepath != "":
		save_to_disk(current_filepath)
	else:
		save_dialogue.request_file()
		var filepath = await save_dialogue.file_submitted
		if filepath != "" and filepath != null:
			save_to_disk(filepath)

func load_from_disk(path: StringName) -> void:
	if !FileAccess.file_exists(path):
		printerr("Nonexistant level at path %s" % path)
		return
	
	current_filepath = path
	
	var level := LevelFile.loadFromFile(path)
	for t in tools:
		t.load_data(level)

func save_to_disk(path: StringName) -> void:
	var level := LevelFile.new()
	for t in tools:
		t.save_data(level)
	level.saveToFile(path)
