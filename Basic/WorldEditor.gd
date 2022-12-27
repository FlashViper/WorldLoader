extends Node

@export var tile_size := Vector2i(7,7)
@export var levelPlaceholder : PackedScene

@onready var preview := $LevelSizePreview
@onready var camera : Camera2D = $Camera2D

var dragRoot : Vector2
var isDragging : bool

var levels : Array[Control] = []
var selected := -1

func _ready() -> void:
	$Grid.sizeX = tile_size.x
	$Grid.sizeY = tile_size.y

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.ctrl_pressed and event.is_pressed() and event.keycode == KEY_S:
			$QuickSave.request_file()
			var filename = await $QuickSave.file_submitted
			if filename != "":
				saveToDisk(filename)
		elif event.keycode == KEY_BACKSPACE or event.keycode == KEY_DELETE:
			if !event.is_pressed():
				deleteLevel(selected)
		
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			isDragging = event.is_pressed()
			
			if isDragging:
				dragRoot = camera.get_global_mouse_position()
				preview.position = dragRoot
				preview.size = Vector2()
			else:
				select(-1)
				create_level(world_to_grid(dragRoot), world_to_grid(camera.get_global_mouse_position()))
			
			preview.visible = isDragging
	elif event is InputEventMouseMotion:
		if isDragging:
			var previewRect := Rect2i(
					world_to_grid(dragRoot), 
					Vector2()
				).expand(
					world_to_grid(camera.get_global_mouse_position())
				)
			preview.position = grid_to_world(previewRect.position)
			preview.size = grid_to_world(previewRect.size)

func create_level(pos1: Vector2i, pos2: Vector2i) -> void:
	var originalRect := Rect2i(pos1, Vector2()).expand(pos2)
	var newRect := originalRect
	
	if (
			originalRect.size.x < ProjectManager.minimum_screen_size.x or
			originalRect.size.y < ProjectManager.minimum_screen_size.y
		):
		if originalRect.get_area() < 2:
			return
		
		var diff := ProjectManager.minimum_screen_size - originalRect.size
		
		newRect.size = Vector2i(
			maxi(ProjectManager.minimum_screen_size.x, newRect.size.x),
			maxi(ProjectManager.minimum_screen_size.y, newRect.size.y)
		) # clamp rect's size to min screen size
		
		newRect.position -= diff * max((pos2 - pos1).sign(), Vector2i.ZERO)
	
	var r := levelPlaceholder.instantiate()
	
	r.rect_changed.connect(onRectChanged.bind(levels.size()))
	r.clicked.connect(onRectClicked.bind(levels.size()))
	
	add_child(r)
	levels.append(r)
	
	r.tile_size = tile_size
	r.initialize(newRect, originalRect)

func onRectClicked(index: int) -> void:
	select(index)

func onRectChanged(new: Rect2i, old: Rect2i, index: int) -> void:
	var obj := levels[index]
	select(index)
	
	# Validate Rect
	var corrected := new
	corrected.size = Vector2i(
		max(ProjectManager.minimum_screen_size.x, new.size.x),
		max(ProjectManager.minimum_screen_size.y, new.size.y)
	) # clamp rect's size to min screen size
	
	for i in levels.size():
		if i == index:
			continue
		
		var l := levels[i]
		if corrected.intersects(l.rect):
			l.modulate = Color.RED
			corrected = collideRect(corrected, l.rect, old)
	
	obj.rect = corrected
	obj.updateTransform()

func select(index: int) -> void:
	selected = index
	for i in levels.size():
		levels[i].modulate = Color.GREEN if selected == i else Color.WHITE

func deleteLevel(index: int) -> void:
	if index < 0 or index >= levels.size():
		return
	
	levels[index].queue_free()
	levels.remove_at(index)
	
	for i in range(index, levels.size()):
		levels[i].rect_changed.disconnect(onRectChanged)
		levels[i].clicked.disconnect(onRectClicked)
		
		levels[i].rect_changed.connect(onRectChanged.bind(i))
		levels[i].clicked.connect(onRectClicked.bind(i))

func collideRect(target: Rect2i, collision: Rect2i, original : Rect2i) -> Rect2i:
	if !target.intersects(collision):
		return target
	
	var final := target
	
	var deltaPos := target.get_center() - collision.get_center()
	var targetDisplacement := (Vector2i((collision.size * 0.5).floor()) + Vector2i((target.size * 0.5).floor())) * deltaPos.sign() - deltaPos
	targetDisplacement[deltaPos.abs().min_axis_index()] = 0
#	deltaPos[deltaPos.min_axis_index()] = 0
	final.position += targetDisplacement
	
	# As a last ditch effort, if they still collide, just inch them away from each other until they're separate
	if final.intersects(collision):
		for i in final.size[deltaPos.abs().min_axis_index()]:
			final.position += deltaPos.sign()
			if !final.intersects(collision):
				break
	
	return final

func saveToDisk(path: StringName) -> void:
	var worldFile := WorldFile.new()
	worldFile.levels = []
	
	for l in levels:
		var data := LevelData.new()
		data.position = l.rect.position
		data.size = l.rect.size
		worldFile.levels.append(data)
	
	worldFile.saveToFile(path)

func world_to_grid(world: Vector2) -> Vector2i:
	return Vector2i(world) / tile_size

func world_to_grid_rect(world: Rect2) -> Rect2i:
	return Rect2i(world_to_grid(world.position), world_to_grid(world.size))

func grid_to_world(grid: Vector2i) -> Vector2:
	return Vector2(grid * tile_size)

func grid_to_world_rect(grid: Rect2i) -> Rect2:
	return Rect2(grid_to_world(grid.position), grid_to_world(grid.size))
