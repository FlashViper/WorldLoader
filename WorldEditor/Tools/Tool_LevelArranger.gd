extends Tool

@onready var preview := $LevelSizePreview
@export var levelPlaceholder := preload("../level_placeholder.tscn")

var tile_size : int :
	get: return ProjectManager.current_project.tile_size

var level_previews : Array[Control]
var level_metadata : Dictionary
var selected := -1

var dragRoot : Vector2
var is_dragging : bool

func initialize() -> void:
	for l in level_previews:
		l.queue_free()
	level_previews = []


func save_levels(world: WorldFile) -> void:
	var level_data : Array[LevelData] = []
	
	for l in level_previews:
		var data := LevelData.new()
		data.position = l.rect.position
		data.size = l.rect.size
		print(level_metadata.has(l))
		if level_metadata.has(l):
			data.file_path = level_metadata[l].file_path
		level_data.append(data)
	
	# Generate connections
	for l in level_data:
		var source := l.get_rect().grow(1)
		l.connections = []
		for i in level_data.size():
			if l == level_data[i]:
				continue
			var destination := level_data[i].get_rect()
			if source.intersects(destination):
				l.connections.append(i)
	
	world.levels = level_data


func add_level_from_file(path: String, position: Vector2i) -> void:
	var level : LevelFile = LevelFile.load_from_file(
		ProjectManager.convert_path(path)
	)
	
	var r := create_preview(level)
	r.initialize(Rect2i(position, level.size if level != null else Vector2i(30,21)))
	level_metadata[r] = {
		"file_path": path
	}


func get_global_mouse_position() -> Vector2:
	var canvas_transform := get_viewport().get_canvas_transform().affine_inverse()
	return canvas_transform * (get_viewport().get_mouse_position())


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			
			if event.is_pressed():
				dragRoot = get_global_mouse_position()
				preview.position = dragRoot
				preview.size = Vector2()
			elif is_dragging:
				create_level(world_to_grid(dragRoot), world_to_grid(get_global_mouse_position()))
			
			var clicked_rect : bool
			for l in level_previews:
				var r := l.edited_rect as Rect2
				if r.has_point(get_global_mouse_position()):
					clicked_rect = true
					break
			
			if !clicked_rect:
				select(-1)
			
			is_dragging = event.is_pressed()
			preview.visible = is_dragging
	elif event is InputEventMouseMotion:
		if event.button_mask & MOUSE_BUTTON_MASK_LEFT == 0:
			dragRoot = get_global_mouse_position()
		
		if is_dragging:
			var previewRect := Rect2i(
					world_to_grid(dragRoot), 
					Vector2()
				).expand(
					world_to_grid(get_global_mouse_position())
				)
			preview.position = grid_to_world(previewRect.position)
			preview.size = grid_to_world(previewRect.size)
	elif event is InputEventKey:
		if event.is_pressed():
			match event.keycode:
				KEY_BACKSPACE:
					if selected >= 0:
						delete_level(selected)


func create_level(pos1: Vector2i, pos2: Vector2i) -> void:
	var originalRect := Rect2i(pos1, Vector2()).expand(pos2)
	var newRect := originalRect
	
	if (
			originalRect.size.x < ProjectManager.minimum_screen_size.x or
			originalRect.size.y < ProjectManager.minimum_screen_size.y
		):
		if originalRect.get_area() < 2:
			return
		
		var diff := ProjectManager.current_project.minimum_screen_size - originalRect.size
		
		newRect.size = Vector2i(
			maxi(ProjectManager.minimum_screen_size.x, newRect.size.x),
			maxi(ProjectManager.minimum_screen_size.y, newRect.size.y)
		) # clamp rect's size to min screen size
		
		var pos_diff := (pos1 - pos2).sign()
		newRect.position -= diff * Vector2i(
			maxi(pos_diff.x, 0),
			maxi(pos_diff.y, 0),
		)
	
	var r := create_preview(null)
	r.initialize(newRect, originalRect)


func create_preview(level: LevelFile = null) -> Control:
	var r := levelPlaceholder.instantiate()
	r.set_level(level)
	
	r.rect_changed.connect(on_rect_changed.bind(level_previews.size()))
	r.clicked.connect(on_rect_clicked.bind(level_previews.size()))
	
	add_child(r)
	level_previews.append(r)
	
	r.tile_size = Vector2i.ONE * ProjectManager.tile_size
	return r


func on_rect_clicked(index: int) -> void:
	select(index)


func delete_level(index: int) -> void:
	if index < 0 or index >= level_previews.size():
		return
	
	var to_delete := level_previews.pop_at(index) as Control
	to_delete.queue_free()
	
	# now we have to remap all of the signals :(
	for i in range(index, level_previews.size()):
		var r := level_previews[i]
		r.rect_changed.disconnect(on_rect_changed)
		r.clicked.disconnect(on_rect_clicked)
		r.rect_changed.connect(on_rect_changed.bind(i))
		r.clicked.connect(on_rect_clicked.bind(i))


func select(index: int) -> void:
	selected = index
	for i in level_previews.size():
		level_previews[i].modulate = Color.GREEN if i == selected else Color.WHITE


func on_rect_changed(new: Rect2i, old: Rect2i, index: int) -> void:
	# Validate Rect
	var obj := level_previews[index]
	
	# clamp rect's size to min screen size
	var corrected := new
	corrected.size = Vector2i(
		max(ProjectManager.minimum_screen_size.x, new.size.x),
		max(ProjectManager.minimum_screen_size.y, new.size.y)
	)
	
	for i in level_previews.size():
		if i == index:
			continue
		
		var l := level_previews[i]
		if corrected.intersects(l.rect):
			corrected = collideRect(corrected, l.rect, old)
	
	obj.rect = corrected
	obj.update_transform()


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
