extends PanelContainer

signal name_changed(new: String)
signal position_changed(new: Vector2)

@onready var name_edit: LineEdit = %NameEdit
@onready var pos_x: SpinBox = %PosX
@onready var pos_y: SpinBox = %PosY

var current_pos: Vector2


func _ready() -> void:
	%DragHandle.add_object(self)
	
	name_edit.text_changed.connect(
		func(new: String):
			name_changed.emit(new)
	)
	
	name_edit.text_submitted.connect(
		func():
			name_edit.release_focus()
	)
	
	pos_x.value_changed.connect(
		func(new: int):
			current_pos.x = new
			position_changed.emit(current_pos)
	)
	
	pos_y.value_changed.connect(
		func(new: int):
			current_pos.y = new
			position_changed.emit(current_pos)
	)


func initialize(p_name: String, p_position: Vector2) -> void:
	name_edit.text = p_name
	pos_x.value = p_position.x
	pos_y.value = p_position.y


func deselect() -> void:
	name_edit.release_focus()
