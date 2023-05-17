extends Tool

const TileMapSimple := preload("../bitmap_display.gd")

@onready var tilemap : TileMapSimple = $Display
@onready var cursor : Control = $Cursor
@onready var level_size: ReferenceRect = $LevelSize

var root_pos : Vector2i
var canvas : ConfigurableCanvas

var level : LevelFile
var editor : LevelEditorData


var map_id := {
	MOUSE_BUTTON_LEFT: 1,
	MOUSE_BUTTON_RIGHT: 0,
}


func initialize() -> void:
	editor.tilemap = tilemap
	editor.root_pos = Vector2i()
	
	root_pos = Vector2i()
	tilemap.tile_size = level.world_settings.tile_size
	cursor.size = Vector2.ONE * level.world_settings.tile_size
	tilemap.clear()
	
	level_size.rect_changed.connect(update_level_bounds)


func enabled() -> void:
	level_size.show()
	cursor.show()


func disabled() -> void:
	cursor.hide()
#	level_size.hide()


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.is_pressed():
			match event.keycode:
				KEY_F:
					var destination : Vector2 = tilemap.world_to_tile(tilemap.get_global_mouse_position())
					flood_fill(destination, false)
	
	if event is InputEventMouseButton:
		if event.is_pressed():
			var tilePos = tilemap.world_to_tile(tilemap.get_global_mouse_position())
			
			for button in map_id:
				if event.button_index == button:
					place_tile(tilePos, map_id[button])
	
	if event is InputEventMouseMotion:
		var source : Vector2 = tilemap.world_to_tile(tilemap.get_global_mouse_position() - event.relative)
		source = source.clamp(root_pos, root_pos + level.size - Vector2i.ONE)
		var destination : Vector2 = tilemap.world_to_tile(tilemap.get_global_mouse_position())
		destination = destination.clamp(root_pos, root_pos + level.size - Vector2i.ONE)
		
		var vector := destination - source
		var segments := vector.length()
		var inc := vector.normalized()
		
		for mask in map_id:
			if (event.button_mask & mask) > 0:
				for i in ceil(segments + 1):
					place_tile(Vector2i((source + inc * i).floor()), map_id[mask])
#					source += inc
	
#		var tilePos : Vector2 = tilemap.world_to_tile(tilemap.get_global_mouse_position())
#		var rootPos : Vector2 = tilemap.world_to_tile(tilemap.get_global_mouse_position() - event.relative)
#		var relative := tilePos - rootPos
#		if relative.length() > 5:
#			prints(tilePos, rootPos, (tilePos - rootPos).length())
#		var dir := relative.normalized()
#
#		for mask in map_id:
#			if event.button_mask & mask > 0:
#				for i in ceili(relative.length()):
#					place_tile(Vector2i((tilePos).floor()), map_id[mask])
#					tilePos += dir


func update_level_bounds(new_bounds: Rect2i, old_bounds: Rect2i) -> void:
	root_pos = new_bounds.position
	level.size = new_bounds.size
	level_size.update_transform()


func _process(delta: float) -> void:
	var targetPos : Vector2i = tilemap.world_to_tile(tilemap.get_global_mouse_position())
	targetPos = targetPos.clamp(root_pos, root_pos + level.size - Vector2i.ONE)
	cursor.position = cursor.position.lerp(tilemap.tile_to_world(targetPos), 0.5)


func place_tile(position: Vector2i, id: int) -> void:
	position = position.clamp(root_pos, root_pos + level.size - Vector2i.ONE)
	tilemap.place_tile(position, id)


func save_data() -> void:
	level.tileData = tilemap.get_data_in_rect(Rect2i(root_pos, level.size))


func load_data(p_level: LevelFile) -> void:
	if p_level != null:
		level = p_level
	
	tilemap.clear()
	tilemap.set_data_in_rect(Rect2i(root_pos, level.size), level.tileData)
	
	level_size.tile_size = Vector2i.ONE * level.world_settings.tile_size
	level_size.rect.size = level.size
	level_size.edited_rect.size = Vector2(level.size * level.world_settings.tile_size)
	level_size.update_transform()


func get_icon() -> Texture2D:
	return preload("res://GUI/Icons/LevelEditor/icon_level_tilemap.tres")


func flood_fill(from_pos: Vector2i, diagonals := false) -> void:
	from_pos = from_pos.clamp(root_pos, root_pos + level.size - Vector2i.ONE)
	
	var directions : Array[Vector2i] = [Vector2i.UP, Vector2i.DOWN, Vector2i.LEFT, Vector2i.RIGHT]
	if diagonals:
		directions.append_array([Vector2i(1,1), Vector2i(1,-1), Vector2i(-1,1), Vector2i(-1,-1)])
	
	var current_tiles : Array[Vector2i] = [from_pos]
	var to_fill : Array[Vector2i] = []
	var level_rect := Rect2i(root_pos, level.size)
	
	while current_tiles.size() > 0:
		var tile := current_tiles.pop_back() as Vector2i
		for d in directions:
			var pos := tile + d
			
			if !level_rect.has_point(pos):
				continue
			if to_fill.has(pos):
				continue
			if tilemap.tile_data.has(pos):
				continue
			
			current_tiles.append(pos)
			to_fill.append(pos)
	
	for f in to_fill:
		place_tile(f, 1)
