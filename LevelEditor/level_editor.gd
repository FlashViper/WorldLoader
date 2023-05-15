extends Node

@onready var save_dialogue := $SaveLevel
@onready var canvas : ConfigurableCanvas = $GUI

var shortcuts : Array[Dictionary] = []

var current_level : LevelFile
var current_filepath := ""
var tools : Array
var current_tool := -1

var toolbar : Control
var is_standalone := true
#var level_inspector [TODO]

func _enter_tree() -> void:
	if is_standalone:
		current_level = LevelFile.new()
		current_level.world_settings = ProjectManager.current_project
		current_level.size = ProjectManager.current_project.minimum_screen_size
		
		DisplayServer.window_set_size(Vector2i(1920, 1080))
		
		CameraManager.activate()
		CameraManager.position = $Camera.position

func _ready() -> void:
	var save_input := InputEventKey.new()
	save_input.keycode = KEY_S
	save_input.ctrl_pressed = true
	add_shortcut(save_input, save_current_level)
	
	var open_input := InputEventKey.new()
	open_input.keycode = KEY_O
	open_input.ctrl_pressed = true
	add_shortcut(open_input, on_load_pressed)
	
	tools.append($Tools/Tilemap)
	tools.append($Tools/Decoration)
	tools.append($Tools/Respawn)
	
	print(current_level.size)
	init_tools()
	create_toolbar()
	create_new_level()
	select_tool(0)
	show_gui()


func init_tools() -> void:
	for t in tools:
		t.level = current_level
		t.set_active(false)


func enable() -> void:
	canvas.visible = true
	if current_tool >= 0 and current_tool < tools.size():
		tools[current_tool].enable_tool()
	
	create_tween().tween_property(
		%BackgroundColor, "modulate:a", 0, 0.15
	)


func disable() -> void:
	canvas.visible = false
	if current_tool >= 0 and current_tool < tools.size():
		tools[current_tool].disable_tool()
	
	create_tween().tween_property(
		%BackgroundColor, "modulate:a", 0, 0.15
	)


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
	if index == current_tool:
		return
	
	if index >= 0:
		tools[index].enable_tool()
	if current_tool >= 0:
		tools[current_tool].disable_tool()
	
	current_tool = index


func on_load_pressed() -> void:
	save_dialogue.request_file()
	var filepath = await save_dialogue.file_submitted
	if filepath != "" and filepath != null:
		load_from_disk(filepath)


func save_current_level() -> void:
	if current_filepath != "":
		save_to_disk(current_filepath)
	else:
		save_dialogue.request_file()
		var filepath = await save_dialogue.file_submitted
		if filepath != "" and filepath != null:
			save_to_disk(filepath)

func load_from_disk(path_raw: String) -> void:
	var path := ProjectManager.convert_path(path_raw)
	
	if !FileAccess.file_exists(path):
		printerr("Nonexistant level at path %s" % path)
		return
	
	current_filepath = path
	current_level = LevelFile.load_from_file(ProjectManager.convert_path(current_filepath))
	
	for t in tools:
		t.load_data(current_level)

	
func save_to_disk(path: String) -> void:
	for t in tools:
		t.save_data()#current_level)
	
	current_level.save_to_file(ProjectManager.convert_path(path))
