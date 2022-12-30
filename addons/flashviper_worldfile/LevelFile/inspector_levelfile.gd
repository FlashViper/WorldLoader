extends EditorInspectorPlugin

var GIZMO := preload("./Inspector/display_levelfile.tscn")

func _can_handle(object) -> bool:
	return object is LevelFile

func _parse_property(object: Object, type: int, name: String, hint_type: int, hint_string: String, usage_flags: int, wide: bool) -> bool:
	return true

func _parse_begin(object: Object) -> void:
	var gizmo := GIZMO.instantiate()
	gizmo.display(object)
	add_custom_control(gizmo)
