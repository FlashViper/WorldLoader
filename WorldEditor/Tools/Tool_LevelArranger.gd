extends Tool

@onready var preview := $LevelSizePreview

@export var levelPlaceholder := preload("../level_placeholder.tscn")

var tile_size : int :
	get: return ProjectManager.tileSize

var levelPreviews : Array[Control]
var selected := -1

var dragRoot : Vector2
var isDragging : bool

func initialize() -> void:
	for l in levelPreviews:
		l.queue_free()
	levelPreviews = []
#
#func save_data(world: WorldFile) -> void:
#	world.levels = levels
#
#func load_data(world: WorldFile) -> void:
#	levels = world.levels

func get_global_mouse_position() -> Vector2:
	var canvas_transform := get_viewport().get_canvas_transform().affine_inverse()
	return canvas_transform * (get_viewport().get_mouse_position())

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			isDragging = event.is_pressed()
			
			if isDragging:
				
				dragRoot = get_global_mouse_position()
				preview.position = dragRoot
				preview.size = Vector2()
			else:
#				select(-1)
				create_level(world_to_grid(dragRoot), world_to_grid(get_global_mouse_position()))
			
			preview.visible = isDragging
	elif event is InputEventMouseMotion:
		if isDragging:
			var previewRect := Rect2i(
					world_to_grid(dragRoot), 
					Vector2()
				).expand(
					world_to_grid(get_global_mouse_position())
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
	
	r.rect_changed.connect(on_rect_changed.bind(levelPreviews.size()))
	r.clicked.connect(on_rect_clicked.bind(levelPreviews.size()))
	
	add_child(r)
	levelPreviews.append(r)
	
	r.tile_size = Vector2i.ONE * ProjectManager.tileSize
	r.initialize(newRect, originalRect)


func on_rect_clicked(index: int) -> void:
#	select(index)
	pass


func on_rect_changed(new: Rect2i, old: Rect2i, index: int) -> void:
	var obj := levelPreviews[index]
#	select(index)
	
	# Validate Rect
	var corrected := new
	corrected.size = Vector2i(
		max(ProjectManager.minimum_screen_size.x, new.size.x),
		max(ProjectManager.minimum_screen_size.y, new.size.y)
	) # clamp rect's size to min screen size
	
	for i in levelPreviews.size():
		if i == index:
			continue
		
		var l := levelPreviews[i]
		if corrected.intersects(l.rect):
			corrected = collideRect(corrected, l.rect, old)
	
	obj.rect = corrected
	obj.updateTransform()


func collideRect(target: Rect2i, collision: Rect2i, original : Rect2i) -> Rect2i:
	if !target.intersects(collision):
		return target
	
	var final := target
	
	var deltaPos := target.get_center() - collision.get_center()
	
	var targetDisplacement := (
		Vector2i((collision.size * 0.5).floor()) + Vector2i((target.size * 0.5).floor())
	) * deltaPos.sign() - deltaPos
	
	targetDisplacement[deltaPos.abs().min_axis_index()] = 0
	final.position += targetDisplacement
	
	# As a last ditch effort, if they still collide, just inch them away from each other until they're separate
	if final.intersects(collision):
		for i in final.size[deltaPos.abs().min_axis_index()]:
			final.position += deltaPos.sign()
			if !final.intersects(collision):
				break
	
	return final

func _process(delta: float) -> void:
	preview.border_width = 5.0 / preview.get_canvas_transform().get_scale().x

func are_level_rects_touching(a: Rect2i, b: Rect2i, margin := 1) -> bool:
	var expanded := a.grow(margin)
	return expanded.intersects(b)

func world_to_grid(world: Vector2) -> Vector2i:
	return Vector2i(world) / tile_size

func world_to_grid_rect(world: Rect2) -> Rect2i:
	return Rect2i(world_to_grid(world.position), world_to_grid(world.size))

func grid_to_world(grid: Vector2i) -> Vector2:
	return Vector2(grid * tile_size)

func grid_to_world_rect(grid: Rect2i) -> Rect2:
	return Rect2(grid_to_world(grid.position), grid_to_world(grid.size))
