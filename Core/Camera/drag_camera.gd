## Basic pan to move camera system
##
## Good website to check out for zooming math: [br]
## https://webglfundamentals.org/webgl/lessons/
## webgl-qna-how-to-implement-zoom-from-mouse-in-2d-webgl.html
extends "./camera_target.gd"

# InputEventMouseMotion.button_mask:
# UP: 4
# DOWN: 5
# LEFT: 6
# RIGHT: 7

const DIR_TABLE := {
	4: Vector2.UP,
	5: Vector2.DOWN,
	6: Vector2.LEFT,
	7: Vector2.RIGHT,
}

## The minimum camera scale of the object
@export var min_zoom := 0.1
## The maximum camera scale of the object
@export var max_zoom := 10.0
@export_range(0.1, 10) var currentZoom := 1.0 

#@onready var cameraScale := 1 / zoom :
#	set(new):
#		cameraScale = clampf(new, min_zoom, max_zoom)
#		zoom = 1 / cameraScale

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var dir := DIR_TABLE.get(event.button_index, Vector2()) as Vector2
		if dir.length_squared() > 0:
			if event.ctrl_pressed:
				position += dir * get_process_delta_time() * 600
			else:
#				cameraScale += dir.y * get_process_delta_time()
#				camera.zoom * Math.pow(2, e.deltaY * -0.01)
				var new_zoom := zoom * (2 ** (-dir.y * 0.01))
				new_zoom = clampf(new_zoom, min_zoom, max_zoom)
				
#				var deltaPos := get_local_mouse_position()
#				position += deltaPos / zoom - deltaPos / new_zoom
#				zoom = new_zoom
		else:
			if event.button_index == MOUSE_BUTTON_LEFT and Input.is_key_pressed(KEY_SPACE):
				get_tree().root.set_input_as_handled()
	
	if event is InputEventMouseMotion:
		if (
			event.button_mask & MOUSE_BUTTON_MASK_MIDDLE > 0 or
			event.button_mask & MOUSE_BUTTON_MASK_LEFT > 0 and Input.is_key_pressed(KEY_SPACE)
		):
			position -= event.relative
			get_tree().root.set_input_as_handled()
