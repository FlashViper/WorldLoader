extends TextureRect

signal dragged(delta: Vector2)

func add_object(obj: Control) -> void:
	dragged.connect(apply_to_obj.bind(obj))


func apply_to_obj(delta: Vector2, obj: Control) -> void:
	obj.position += delta


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		if event.button_mask & MOUSE_BUTTON_MASK_LEFT > 0:
			dragged.emit(event.relative)
