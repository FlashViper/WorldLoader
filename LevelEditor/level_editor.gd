extends Node

@onready var tilemap := $TileMap
@onready var save_dialog := $QuickSave
@onready var level_bounds : Control = %LevelBounds

var map_id := {
	MOUSE_BUTTON_MASK_LEFT: 1,
	MOUSE_BUTTON_MASK_RIGHT: 0, # INVALID TILE
}

var editedRoot : Vector2
var level_size : Vector2i

func _ready() -> void:
	level_size = ProjectManager.minimum_screen_size
	
	tilemap.position = editedRoot
	tilemap.tile_size = ProjectManager.tileSize
	
	level_bounds.size = level_size * ProjectManager.tileSize
	
	loadFromDisk("res://Testing/Levels/jefaloosh.lvl")

func onLevelResized(new: Rect2i, old: Rect2i) -> void:
	level_bounds.updateTransform()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.ctrl_pressed and event.is_pressed() and event.keycode == KEY_S:
			$QuickSave.request_file()
			var filename = await $QuickSave.file_submitted
			if filename != "":
				saveToDisk(filename)
	
	if event is InputEventMouseButton:
		if event.is_pressed():
			var tilePos = tilemap.world_to_tile(tilemap.get_global_mouse_position())
			
			for mask in map_id:
				if event.button_mask & mask > 0:
					place_tile(tilePos, map_id[mask])
	
	if event is InputEventMouseMotion:
		var tilePos : Vector2 = tilemap.world_to_tile(tilemap.get_global_mouse_position())
		var rootPos : Vector2 = tilemap.world_to_tile(tilemap.get_global_mouse_position() - event.relative)
		var relative := tilePos - rootPos
		var dir := relative.normalized()
		
		for i in ceili(relative.length()):
			for mask in map_id:
				if event.button_mask & mask > 0:
					place_tile(Vector2i(tilePos + i * dir), map_id[mask])

func place_tile(position: Vector2i, id: int) -> void:
	position = position.clamp(Vector2i.ZERO, level_size - Vector2i(1,1))# + Vector2i.ONE)
	tilemap.place_tile(position, id)

func loadFromDisk(path: StringName) -> void:
	if !FileAccess.file_exists(path):
		printerr("Nonexistant level at path %s" % path)
		return
	
	var l := LevelFile.loadFromFile(&"res://Testing/Levels/jefaloosh.lvl")
	level_size = l.size
	tilemap.set_data_in_rect(Rect2i(Vector2(), level_size), l.tileData)
	level_bounds.size = level_size * ProjectManager.tileSize

func saveToDisk(path: StringName) -> void:
	var level := LevelFile.new()
	level.size = level_size
	level.tileData = tilemap.get_data_in_rect(Rect2i(Vector2(), level_size))
	level.saveToFile(path)
