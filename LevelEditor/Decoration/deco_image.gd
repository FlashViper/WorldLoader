class_name DecoImage
extends DecoObject

var image : Texture2D

static func create_from_texture(p_texture: Texture2D) -> DecoImage:
	var deco := DecoImage.new()
	deco.texture = p_texture
	return deco


func _get_type_id() -> int:
	return LevelFile.DECO_IMAGE


func _place() -> Node:
	var node := Sprite2D.new()
	node.texture = image
	node.transform = transform
	return node


func _get_preview() -> Texture2D:
	return image
