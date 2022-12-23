extends VBoxContainer

@onready var draw_target : Control = %Viewport
@onready var save_button : Button = %Save
@onready var sizeX : SpinBox = %SizeX
@onready var sizeY : SpinBox = %SizeY

var bitmap : BitMap
var mapSize := Vector2i(10, 10) :
	set(new):
		mapSize = new
		updateBitmap()
		queue_redraw()

func _ready() -> void:
	sizeX.value = mapSize.x
	sizeY.value = mapSize.y
	
	sizeX.value_changed.connect(func(value): mapSize.x = value)
	sizeY.value_changed.connect(func(value): mapSize.y = value)
	
	draw_target.gui_input.connect(onTargetInput)
	
	bitmap = BitMap.new()
	bitmap.create(mapSize)

func onTargetInput(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.is_pressed():
			var mouseTile := Vector2i(event.position) / getTileSize()
			match event.button_index:
				MOUSE_BUTTON_LEFT:
					bitmap.set_bitv(mouseTile, true)
				MOUSE_BUTTON_RIGHT:
					bitmap.set_bitv(mouseTile, false)
			queue_redraw()

func _draw() -> void:
	var tileSize := getTileSize()
	
	draw_set_transform_matrix(draw_target.get_transform())
	draw_rect(Rect2(Vector2(), Vector2.ONE * draw_target.size[draw_target.size.min_axis_index()]), Color.BLACK)
	
	for x in mapSize.x:
		for y in mapSize.y:
			if bitmap.get_bit(x,y):
				draw_rect(Rect2(Vector2i(x, y) * tileSize, tileSize), Color.WHITE)

func getTileSize() -> Vector2i:
	var unadjustedSize := Vector2i(draw_target.size) / mapSize
	return Vector2i.ONE * unadjustedSize[unadjustedSize.min_axis_index()]

func updateBitmap() -> void:
	bitmap.resize(mapSize)
