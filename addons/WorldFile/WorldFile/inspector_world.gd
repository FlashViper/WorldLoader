extends EditorInspectorPlugin

const GIZMO : PackedScene = preload("./Inspector/display_world.tscn")

func _can_handle(object) -> bool:
	return object is WorldFile

func _parse_property(object: Object, type: Variant.Type, name: String, hint_type: PropertyHint, hint_string: String, usage_flags: PropertyUsageFlags, wide: bool) -> bool:
	return true

func _parse_begin(object: Object) -> void:
	var g := GIZMO.instantiate()
	g.display(object)
	add_custom_control(g)
