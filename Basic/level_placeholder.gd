# TODO: Create grid math helper class with macros like <convert_grid_to_tile>
extends ReferenceRect

const WorldEditor := preload("./WorldEditor.gd")

@export var tile_size := Vector2i(7, 7)

var rect : Rect2i :
	set(new):
		rect = new
		if new.size < Vector2i.ONE:
			pass
var editedRect : Rect2
var isDragging : bool

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			isDragging = event.is_pressed()
			
			if event.is_pressed():
				pass
			else:
				editedRect = Rect2(rect.position * tile_size, rect.size * tile_size)
			
			accept_event()
	
	if event is InputEventMouseMotion:
		if isDragging:
			editedRect.position += event.relative
			rect = Rect2i(
				Vector2i(editedRect.position) / tile_size,
				Vector2i(editedRect.size) / tile_size,
			)
			
			updateTransform()
			accept_event()

func initialize(newSize: Rect2i, uncorrectedSize: Rect2i) -> void:
	rect = newSize
	editedRect = Rect2(rect.position * tile_size, rect.size * tile_size)
	
	position = uncorrectedSize.position * tile_size
	size = uncorrectedSize.size * tile_size
	updateTransform()

func updateTransform() -> void:
	var t := create_tween().set_parallel(true)
	t.tween_property(self, "position", Vector2(rect.position * tile_size), 0.1).set_trans(Tween.TRANS_CUBIC)
	t.tween_property(self, "size", Vector2(rect.size * tile_size), 0.1).set_trans(Tween.TRANS_CUBIC)

func editRect() -> void:
	# TODO
	pass
