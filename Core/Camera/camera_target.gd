extends Node2D

signal activity_changed
signal priority_changed

@export var priority := -1 :
	set(new):
		priority = new
		priority_changed.emit()

@export var active := true :
	set(new):
		active = new
		activity_changed.emit()

var zoom := 1.0

func _ready() -> void:
	CameraManager.register_target(self)
