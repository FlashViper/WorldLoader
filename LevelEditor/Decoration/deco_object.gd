class_name DecoObject
extends Resource

var name : StringName
var transform: Transform2D
var depth : float


func _get_type_id() -> int: return -1
func _get_bounding_box() -> Rect2: return Rect2()
func _place() -> Node: return null
func _get_preview() -> Texture2D: return null


## Overridable function that outputs a
## dictionary containing any information that would
## persist between multiple versions of this object
## so that it can be saved to a file. This can be decoded with
## _decode_preset() 
func _encode_preset() -> Dictionary: return {}
func _decode_preset(preset: Dictionary) -> DecoObject: return null


func place_from_preset(preset: Dictionary) -> Node:
	var obj := _decode_preset(preset)
	if obj:
		return obj._place()
	return null


func parse_data(data: Dictionary) -> void:
	transform = data.get("transform", Transform2D())
	depth = data.get("depth", 0.0)


func get_data() -> Dictionary:
	return {
		"type": _get_type_id(),
		"transform": transform,
		"depth": depth,
	}

