# TODO: Create grid math helper class with macros like <convert_grid_to_tile>
extends ReferenceRect

signal rect_changed(new: Rect2i, old: Rect2i)
signal clicked

const WorldEditor := preload("./WorldEditor.gd")
enum {MOVE_RECT, CHANGE_SIZE, CURSOR}

const HANDLES : Array[Dictionary] = [
	{MOVE_RECT:Vector2(1,1), CHANGE_SIZE: Vector2(0,0), CURSOR: CURSOR_MOVE}, # full rect
	
	# Sides
	{MOVE_RECT:Vector2(0,1), CHANGE_SIZE: Vector2(0,-1), CURSOR: CURSOR_VSIZE},
	{MOVE_RECT:Vector2.ZERO, CHANGE_SIZE: Vector2(0,1), CURSOR: CURSOR_VSIZE},
	{MOVE_RECT:Vector2.ZERO, CHANGE_SIZE: Vector2(1,0), CURSOR: CURSOR_HSIZE},
	{MOVE_RECT:Vector2(1,0), CHANGE_SIZE: Vector2(-1,0), CURSOR: CURSOR_HSIZE},
	
	# Corners
	{MOVE_RECT:Vector2.ZERO, CHANGE_SIZE: Vector2(1,1), CURSOR: CURSOR_FDIAGSIZE}, # bottom-right
	{MOVE_RECT:Vector2(1,1), CHANGE_SIZE: Vector2(-1,-1), CURSOR: CURSOR_FDIAGSIZE},
	{MOVE_RECT:Vector2(1,0), CHANGE_SIZE: Vector2(-1,1), CURSOR: CURSOR_BDIAGSIZE},
	{MOVE_RECT:Vector2(0,1), CHANGE_SIZE: Vector2(1,-1), CURSOR: CURSOR_BDIAGSIZE},
]

@export var anchorSize := 20
@export var anchorPadding := 10
@export var tile_size := Vector2i(7, 7)
# Spawn
@export var debugShapes := false

var rect : Rect2i
var editedRect : Rect2

var dragMode : int
var isDragging : bool
var handleObjects : Array[Control]

func _ready() -> void:
	handleObjects = []
	
	for i in HANDLES.size():
		var handle := ColorRect.new()
		handle.position = get_rect().get_center()
		handle.size = Vector2.ONE * 32
		handle.mouse_filter = Control.MOUSE_FILTER_PASS
		add_child(handle)
		
		var posMod := HANDLES[i][MOVE_RECT] as Vector2
		var sizeMod := HANDLES[i][CHANGE_SIZE] as Vector2
		
		if debugShapes:
			handle.color = Color.BLACK
			handle.color.r = abs(sizeMod.x * sizeMod.y)
			handle.color.g = 0.5 * (abs(sizeMod.x) + abs(sizeMod.y))
			handle.color.b = 1 - handle.color.r
			handle.z_index = handle.color.r
		else:
			handle.color = Color.TRANSPARENT
		
		handle.mouse_default_cursor_shape = HANDLES[i][CURSOR]
		
		var anchorBase := Vector2(
			remap(sizeMod.x, -1, 1, 0, 1),
			remap(sizeMod.y, -1, 1, 0, 1)
		)
		
		const SPACING := 15
		
		handle.set_anchor_and_offset(SIDE_LEFT, max(sizeMod.x, 0), -SPACING, true)
		handle.set_anchor_and_offset(SIDE_TOP, max(sizeMod.y, 0), -SPACING, true)
		handle.set_anchor_and_offset(SIDE_RIGHT, min(1 + sizeMod.x, 1), SPACING)
		handle.set_anchor_and_offset(SIDE_BOTTOM, min(1 + sizeMod.y, 1), SPACING)
		
		handle.gui_input.connect(onHandleInput.bind(i))
		handleObjects.append(handle)

func initialize(newSize: Rect2i, uncorrectedSize: Rect2i) -> void:
	rect = newSize
	editedRect = snapRect(rect)
	
	position = uncorrectedSize.position * tile_size
	size = uncorrectedSize.size * tile_size
	updateTransform(true)

var dragIndex := -1
func onHandleInput(event: InputEvent, index: int) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			dragIndex = (index if event.is_pressed() else -1)
			
			if event.is_pressed():
				clicked.emit()
			
			handleObjects[index].accept_event()
	
	if event is InputEventMouseMotion:
		if dragIndex == index:
			var posMod := HANDLES[index][MOVE_RECT] as Vector2
			var sizeMod := HANDLES[index][CHANGE_SIZE] as Vector2
			
			editedRect.position += event.relative * posMod
			editedRect.size += event.relative * sizeMod
			editedRect = editedRect.abs()
			
			submitRect(editedRect)
			handleObjects[index].accept_event()

func snapRect(to: Rect2i) -> Rect2:
	return Rect2(to.position * tile_size, to.size * tile_size)

func updateTransform(interpolate := false) -> void:
	var new := Rect2(rect.position * tile_size, rect.size * tile_size)
	
	if interpolate:
		var t := create_tween().set_parallel(true)
		t.tween_property(self, "position", new.position, 0.1).set_trans(Tween.TRANS_CUBIC)
		t.tween_property(self, "size", new.size, 0.1).set_trans(Tween.TRANS_CUBIC)
	else:
		position = new.position
		size = new.size

func submitRect(edited: Rect2) -> void:
	var old := rect
	
	rect.position = Vector2i(edited.position) / tile_size
	rect.size = Vector2i(edited.size) / tile_size
	
	rect_changed.emit(rect, old)
