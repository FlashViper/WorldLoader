extends Node2D

@export var sizeX := 128 :
	set(new):
		sizeX = new
		queue_redraw()

@export var sizeY := 128 :
	set(new):
		sizeY = new
		queue_redraw()

@export var lineWidth := 4 :
	set(new):
		lineWidth = new
		queue_redraw()

@export var lineColor := Color8(255, 255, 255, 100) :
	set(new):
		lineColor = new
		queue_redraw()

@export var autoUpdate := true

func _ready() -> void:
	set_process(autoUpdate)

func _draw() -> void:
	# set the draw coordinates so that (0,0) is the top right of the screen
	draw_set_transform_matrix(get_viewport_transform().inverse())
	
	var pos := get_viewport_transform().origin
	var size := get_viewport_rect().size
	pos.x = fmod(pos.x, sizeX)
	pos.y = fmod(pos.y, sizeY)
	
	var linesX := ceili(size.x / sizeX) + 1
	var linesY := ceili(size.y / sizeY) + 1
	
	for i in linesX:
		draw_line(Vector2(i * sizeX + pos.x, 0), Vector2(i * sizeX + pos.x, size.y), lineColor, lineWidth)
	for i in linesY:
		draw_line(Vector2(0, i * sizeY + pos.y), Vector2(size.x, i * sizeY + pos.y), lineColor, lineWidth)

func _process(delta: float) -> void:
	queue_redraw()
