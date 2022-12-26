extends Node

@export var tile_size := Vector2i(7,7)
@export var levelPlaceholder : PackedScene

@onready var preview := $LevelSizePreview
@onready var camera : Camera2D = $Camera2D

var dragRoot : Vector2
var isDragging : bool

var levels : Array[Control] = []

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
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			isDragging = event.is_pressed()
			
			if isDragging:
				dragRoot = camera.get_global_mouse_position()
				preview.position = dragRoot
				preview.size = Vector2()
			else:
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
	
	if originalRect.size < ProjectManager.minimum_screen_size:
		if originalRect.get_area() < 2:
			return
		
		var diff := ProjectManager.minimum_screen_size - originalRect.size
		
		newRect.size = Vector2i(
			maxi(ProjectManager.minimum_screen_size.x, newRect.size.x),
			maxi(ProjectManager.minimum_screen_size.y, newRect.size.y)
		) # clamp rect's size to min screen size
		
		newRect.position -= diff * max(pos2 - pos1, Vector2i.ZERO).sign()
	
	var r := levelPlaceholder.instantiate()
	r.rect_changed.connect(onRectChanged.bind(levels.size()))
	add_child(r)
	levels.append(r)
	
	r.tile_size = tile_size
	r.initialize(newRect, originalRect)

func onRectChanged(new: Rect2i, index: int) -> void:
	var obj := levels[index]
	
	# Validate Rect
	var corrected := new
	corrected.size = Vector2i(
		max(ProjectManager.minimum_screen_size.x, new.size.x),
		max(ProjectManager.minimum_screen_size.y, new.size.y)
	) # clamp rect's size to min screen size
	
	obj.rect = corrected
	obj.updateTransform()

func collideRect(target: Rect2i, collision: Rect2i, original : Rect2i) -> Rect2i:
	if !target.intersects(collision):
		return target
	
	var final := target
	
	var intersection := target.intersection(collision)
	var isSizeChanged := target.size != original.size
	var isPositionChanged := target.position != original.position
	
	if isSizeChanged:
		var dir := intersection.size - target.size
		final = final.grow_individual(
			-abs(dir.x if dir.x < 0 else 0),
			-abs(dir.x if dir.x > 0 else 0),
			-abs(dir.y if dir.y < 0 else 0),
			-abs(dir.y if dir.y > 0 else 0)
		)
	
	if isPositionChanged:
		var dir := (intersection.position - target.position).sign()
		final.position -= dir * intersection.size
	
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
