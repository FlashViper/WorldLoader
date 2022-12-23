extends Node


@export var tile_size := Vector2i(7,7)
@export var levelPlaceholder : PackedScene

@onready var preview := $LevelSizePreview
@onready var camera : Camera2D = $Camera2D

var dragRoot : Vector2
var isDragging : bool

func _input(event: InputEvent) -> void:
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
		
		var diff : Vector2i = max(ProjectManager.minimum_screen_size - originalRect.size, Vector2i())
		newRect = originalRect.expand(originalRect.get_center() + Vector2i(0.5 * (originalRect.size + diff)) * (pos1 - pos2).sign())

	
	var r := levelPlaceholder.instantiate()
	add_child(r)
	
	r.tile_size = tile_size
	r.initialize(newRect, originalRect)

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

func world_to_grid(world: Vector2) -> Vector2i:
	return Vector2i(world) / tile_size

func world_to_grid_rect(world: Rect2) -> Rect2i:
	return Rect2i(world_to_grid(world.position), world_to_grid(world.size))

func grid_to_world(grid: Vector2i) -> Vector2:
	return Vector2(grid * tile_size)

func grid_to_world_rect(grid: Rect2i) -> Rect2:
	return Rect2(grid_to_world(grid.position), grid_to_world(grid.size))
