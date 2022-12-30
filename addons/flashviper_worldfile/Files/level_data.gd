class_name LevelData extends Resource

@export var name : StringName = &""
@export var filePath : StringName = &""

@export var position : Vector2i = Vector2i.ZERO
@export var size : Vector2i = Vector2i.ONE * 2
@export var connections : PackedInt64Array

func getRect() -> Rect2i:
	return Rect2i(position, size)
