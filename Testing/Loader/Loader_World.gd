extends Node

const LevelLoader := preload("./Loader_Level.gd")

@onready var levelLoader : LevelLoader = %LevelLoader
@onready var player : CharacterBody2D = $TestCharacter

var world : WorldFile
var currentLevel := -1
var loaded : Dictionary
var levelObjs : Array[Node]

func _physics_process(delta: float) -> void:
	if !world or is_zero_approx(player.velocity.length()):
		return
	
	for l in loaded:
		if l == currentLevel:
			continue
		
		if loaded.has(l):
			if (loaded[l] as Rect2).has_point(player.position):
				loadScreen(l)

func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.keycode == KEY_O and event.is_pressed() and event.ctrl_pressed:
			$open_dialogue.request_file()
			var filepath : String = await $open_dialogue.file_submitted
			var f := ResourceLoader.load(filepath, "WorldFile")
			
			if f != null and f is WorldFile:
				loadWorld(f)

func loadWorld(w: WorldFile, level := 0) -> void:
	if w.levels.size() < 1:
		printerr("Tried to load a World File with 0 levels")
		return
	
	world = w
	
	if level < 0 or level >= w.levels.size():
		level = 0
	
	loadScreen(level)

func loadScreen(level: int) -> void:
	if !world:
		printerr("Tried to load a screen on a null world")
		return
	
	for l in levelObjs:
		l.queue_free()
	levelObjs = []
	
	currentLevel = level
	createLevelRect(world.levels[currentLevel]) # replace with LevelLoader.load_level() in the future
	
	loaded = {currentLevel: rectToWorld(world.levels[currentLevel].getRect())}
	
	for c in world.levels[level].connections:
		if c < 0 or c >= world.levels.size() or c == currentLevel:
			continue
		
		loaded[c] = rectToWorld(world.levels[c].getRect())
		createLevelRect(world.levels[c])
	
	# load the player in at the default position
	player.position = world.levels[level].getRect().get_center() * ProjectManager.tileSize

func rectToWorld(a: Rect2i) -> Rect2:
	return Rect2(a.position * ProjectManager.tileSize, a.size * ProjectManager.tileSize)

func createLevelRect(l: LevelData) -> void:
	var r := ReferenceRect.new()
	
	r.border_color = Color.WHITE
	r.border_width = 5
	r.editor_only = false
	
	r.position = l.position * ProjectManager.tileSize
	r.size = l.size * ProjectManager.tileSize
	
	levelObjs.append(r)
	add_child(r)
