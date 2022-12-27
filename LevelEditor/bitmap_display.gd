extends Node2D

const DEBUG_FONT := preload("res://GUI/Fonts/cascadia_mono.tres")
const TILE_INVALID := 0

@export var tile_size := 32
@export var tile_color := Color.BLACK

@export_category("Debug")
@export var debug_display_ids := false :
	set(new):
		debug_display_ids = new
		queue_redraw()

# {Vector2i --> byte}
var tile_data : Dictionary

func _draw() -> void:
	for tile in tile_data:
		var tileRect := Rect2(tile * tile_size, Vector2.ONE * tile_size)
		draw_rect(tileRect, tile_color)
		
		if debug_display_ids and tile_data[tile] != TILE_INVALID:
			draw_rect(tileRect, Color(Color.RED, 0.8))
			draw_rect(tileRect, Color.RED, false, 10)
			draw_string(
				DEBUG_FONT, 
				tileRect.get_center() - Vector2(1, -1) * tile_size * 0.2, 
				str(tile_data[tile]),
				HORIZONTAL_ALIGNMENT_CENTER, 
				-1,
				tile_size * 0.8,
				Color.GRAY
			)

func _ready() -> void:
	tile_data = {}

func place_tile(pos: Vector2i, id: int) -> void:
	if id == TILE_INVALID:
		tile_data.erase(pos)
	else:
		tile_data[pos] = id
	
	queue_redraw()

func get_data_in_rect(rect: Rect2i) -> PackedByteArray:
	var data := PackedByteArray()
	data.resize(rect.get_area())
	
	var index := 0
	
	for y in range(rect.position.y, rect.end.y + 1):
		for x in range(rect.position.x, rect.end.x + 1):
			data[index] = tile_data.get(Vector2i(x,y), TILE_INVALID)
			index += 1 # much easier than some function of x and y
	
	return data

func tile_to_world(tile: Vector2i) -> Vector2:
	return global_transform * Vector2(tile * tile_size)

func world_to_tile(world: Vector2) -> Vector2i:
	return Vector2i(global_transform.inverse() * world) / tile_size
