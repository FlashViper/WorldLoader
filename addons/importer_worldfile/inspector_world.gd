extends EditorInspectorPlugin

const GIZMO : PackedScene = preload("res://addons/importer_worldfile/Inspector/display_world.tscn")

func _can_handle(object) -> bool:
	return object is WorldFile

func _parse_property(object: Object, type: int, name: String, hint_type: int, hint_string: String, usage_flags: int, wide: bool) -> bool:
	return true

func _parse_begin(object: Object) -> void:
	var g := GIZMO.instantiate()
	g.display(object)
	add_custom_control(g)
