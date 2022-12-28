# TODO: Chunk system if performance requires
extends Node2D

const ID_INVALID := 0

@export var tileSize := Vector2(64, 64)
@export var color := Color8(0,0,0)
#@export var chunkSize := Vector2i(16, 16)

var body : StaticBody2D
var shape : RectangleShape2D

var tiles := {}

func _ready() -> void:
	body = StaticBody2D.new()
	add_child(body)
	shape = RectangleShape2D.new()
	shape.size = tileSize

func _draw() -> void:
	for t in tiles:
		draw_rect(Rect2(Vector2(t) * tileSize, tileSize), color)

func load_collision_at_position(level: LevelFile, pos: Vector2i) -> void:
	var index := 0
	
	for y in level.size.y:
		for x in level.size.x:
			printraw(level.tileData[index])
			
			if level.tileData[index] != ID_INVALID:
				add_tile(x, y, level.tileData[index])
			
			index += 1
		printraw("\n")

func add_tile(x: int, y: int, id: int) -> void:
	var pos := Vector2i(x, y)
	
	if id == ID_INVALID:
		if tiles.has(pos):
			tiles.erase(pos)
		return
	
	PhysicsServer2D.body_add_shape(
		body.get_rid(), 
		shape.get_rid(), 
		Transform2D(
			Vector2(1, 0),
			Vector2(0, 1),
			(Vector2(pos) + Vector2(0.5, 0.5)) * tileSize
		)
	)
	
	tiles[pos] = id
	queue_redraw()
