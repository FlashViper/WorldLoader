extends Tool

const TileMapSimple := preload("../bitmap_display.gd")

@onready var tilemap : TileMapSimple = $Display
@onready var cursor : Control = $Cursor

var edited_root : Vector2i :
	set(new):
		tilemap.position = new * ProjectManager.tile_size
var level_size : Vector2i
var canvas : ConfigurableCanvas

var map_id := {
	MOUSE_BUTTON_LEFT: 1,
	MOUSE_BUTTON_RIGHT: 0,
}

func _ready() -> void:
	tilemap.tile_size = ProjectManager.tile_size
	cursor.size = Vector2.ONE * ProjectManager.tile_size

func initialize() -> void:
	level_size = ProjectManager.minimum_screen_size
	tilemap.clear()

func enabled() -> void:
	cursor.show()

func disabled() -> void:
	cursor.hide()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.is_pressed():
			var tilePos = tilemap.world_to_tile(tilemap.get_global_mouse_position())
			
			for button in map_id:
				if event.button_index == button:
					place_tile(tilePos, map_id[button])
	
	if event is InputEventMouseMotion:
		var tilePos : Vector2 = tilemap.world_to_tile(tilemap.get_global_mouse_position())
		var rootPos : Vector2 = tilemap.world_to_tile(tilemap.get_global_mouse_position() - event.relative)
		var relative := tilePos - rootPos
		var dir := relative.normalized()
		
		for i in ceili(relative.length()):
			for mask in map_id:
				if event.button_mask & mask > 0:
					place_tile(Vector2i(tilePos + i * dir), map_id[mask])

func _process(delta: float) -> void:
	var targetPos : Vector2i = tilemap.world_to_tile(tilemap.get_global_mouse_position())
	targetPos = targetPos.clamp(Vector2i.ZERO, level_size - Vector2i.ONE)
	cursor.position = cursor.position.lerp(tilemap.tile_to_world(targetPos), 0.5)

func place_tile(position: Vector2i, id: int) -> void:
	position = position.clamp(Vector2i.ZERO, level_size - Vector2i.ONE)
	tilemap.place_tile(position, id)

func save_data(level: LevelFile) -> void:
	level.size = level_size
	level.tileData = tilemap.get_data_in_rect(Rect2i(Vector2i(), level_size))

func load_data(level: LevelFile) -> void:
	level_size = level.size
	tilemap.set_data_in_rect(Rect2i(Vector2i(), level_size), level.tileData)

func get_icon() -> Texture2D:
	return preload("res://GUI/Icons/LevelEditor/icon_level_tilemap.tres")
