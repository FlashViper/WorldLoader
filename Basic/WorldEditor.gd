extends Node


@export var tile_size := Vector2i(7,7)

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
	
	if originalRect.size < ProjectManager.minimum_screen_size:
		var diff : Vector2i = max(ProjectManager.minimum_screen_size - originalRect.size, Vector2i())
		originalRect = originalRect.expand(originalRect.get_center() + Vector2i(0.5 * (originalRect.size + diff)) * (pos1 - pos2).sign())
		pass
	
	var r := preview.duplicate(0)
	add_child(r)
	r.position = grid_to_world(originalRect.position)
	r.size = grid_to_world(originalRect.size)
	r.border_color = Color.WHITE

func world_to_grid(world: Vector2) -> Vector2i:
	return Vector2i(world) / tile_size

func grid_to_world(grid: Vector2i) -> Vector2:
	return Vector2(grid * tile_size)
