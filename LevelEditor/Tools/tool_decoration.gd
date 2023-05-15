extends Tool

@onready var root: Node2D = $Root

var level : LevelFile
var decoration : Array[DecoObject]


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.is_pressed():
				var mouse_pos := root.get_local_mouse_position()
				var angle := randf() * 2 * PI
				var scale := Vector2.ONE * randf_range(0.5, 1.3)
				var transform := Transform2D(
					angle, scale, 0.0, mouse_pos
				)
				
				var obj := DecoImage.create_from_texture(
					preload("res://icon.svg")
				)
				
				obj.transform = transform
				obj.depth = randf_range(-300, 300)
				place_object(obj)


func place_object(obj: DecoObject) -> void:
	var node := obj._place()
	place_scene(node, obj.depth)


func place_scene(scene: Node2D, depth := 0.0) -> void:
	root.add_object(scene, depth)


func save_data() -> void:
	level.deco_textures = ["res://icon.svg"]
	var decoration_data : Array[Dictionary] = []
	for c in root.get_children():
		decoration_data.append({
			"path_index": 0,
			"transform": c.transform,
		})
	level.decoration = decoration_data


func load_data(p_level: LevelFile) -> void:
	if p_level != null:
		level = p_level
	
	printerr("load_data is not implimented (tool_decoration.gd)")
#
#	for d in level.decoration:
#		var tex := load(level.deco_textures[d["path_index"]]) as Texture2D
#		var transform := d["transform"] as Transform2D
#		place_image(tex, transform)


func get_icon() -> Texture2D:
	return preload("res://GUI/Icons/LevelEditor/icon_level_background.tres")
