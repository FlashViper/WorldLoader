# TODO: Create grid math helper class with macros like <convert_grid_to_tile>
extends ReferenceRect

signal rect_changed(new: Rect2i, old: Rect2i)
signal clicked

const WorldEditor := preload("./world_editor.gd")
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

@export var padding := 25
@export var tile_size := Vector2i(7, 7)

@export_group("Handles")
@export var handles_single_axis := true
@export var handles_multi_axis := true
@export var handle_drag_rect := true

@export_group("")
@export var debug_shapes := false

var rect : Rect2i :
	set(new):
		rect = new
#		edited_rect = Rect2(new.position * tile_size, new.size * tile_size)
var edited_rect : Rect2

var drag_mode : int
var is_dragging : bool
var handle_objects : Array[Control]
var drag_index := -1

func _ready() -> void:	
	var exclude : Array[int] = []
	if !handle_drag_rect:
		exclude.append(0)
	if !handles_single_axis:
		exclude.append_array(range(1,5))
	if !handles_multi_axis:
		exclude.append_array(range(5, 9))
	
	handle_objects = []
	
	for i in HANDLES.size():
		if exclude.has(i):
			continue
		
		var handle := ColorRect.new()
		handle.position = get_rect().get_center()
		handle.size = Vector2.ONE * 32
		handle.mouse_filter = Control.MOUSE_FILTER_PASS
		add_child(handle)
		
		var pos_mod := HANDLES[i][MOVE_RECT] as Vector2
		var size_mod := HANDLES[i][CHANGE_SIZE] as Vector2
		
		if debug_shapes:
			handle.color = Color.BLACK
			handle.color.r = abs(size_mod.x * size_mod.y)
			handle.color.g = 0.5 * (abs(size_mod.x) + abs(size_mod.y))
			handle.color.b = 1 - handle.color.r
			handle.z_index = handle.color.r
		else:
			handle.color = Color.TRANSPARENT
		
		handle.mouse_default_cursor_shape = HANDLES[i][CURSOR]
		
		var anchorBase := Vector2(
			remap(size_mod.x, -1, 1, 0, 1),
			remap(size_mod.y, -1, 1, 0, 1)
		)
		
		handle.set_anchor_and_offset(SIDE_LEFT, max(size_mod.x, 0), -padding, true)
		handle.set_anchor_and_offset(SIDE_TOP, max(size_mod.y, 0), -padding, true)
		handle.set_anchor_and_offset(SIDE_RIGHT, min(1 + size_mod.x, 1), padding)
		handle.set_anchor_and_offset(SIDE_BOTTOM, min(1 + size_mod.y, 1), padding)
		
		handle.gui_input.connect(on_handle_input.bind(i))
		handle_objects.append(handle)


func initialize(new_size: Rect2i, uncorrected_size := Rect2i()) -> void:
	rect = new_size
	edited_rect = snap_rect(rect)
	
	if !uncorrected_size.has_area():
		uncorrected_size = new_size
	
	position = uncorrected_size.position * tile_size
	size = uncorrected_size.size * tile_size
	update_transform(true)


func on_handle_input(event: InputEvent, index: int) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			drag_index = (index if event.is_pressed() else -1)
			
			if event.is_pressed():
				clicked.emit()
			else:
				edited_rect = snap_rect(rect)
			
			handle_objects[index].accept_event()
	
	if event is InputEventMouseMotion:
		if drag_index == index:
			var pos_mod := HANDLES[index][MOVE_RECT] as Vector2
			var size_mod := HANDLES[index][CHANGE_SIZE] as Vector2
			
			edited_rect.position += event.relative * pos_mod
			edited_rect.size += event.relative * size_mod
			edited_rect = edited_rect.abs()
			
			submit_rect(edited_rect)
			handle_objects[index].accept_event()


func snap_rect(to: Rect2i) -> Rect2:
	return Rect2(to.position * tile_size, to.size * tile_size)


func update_transform(interpolate := false) -> void:
	var new := Rect2(rect.position * tile_size, rect.size * tile_size)
	
	if interpolate:
		var t := create_tween().set_parallel(true)
		t.tween_property(self, "position", new.position, 0.1).set_trans(Tween.TRANS_CUBIC)
		t.tween_property(self, "size", new.size, 0.1).set_trans(Tween.TRANS_CUBIC)
	else:
		position = new.position
		size = new.size


func submit_rect(edited: Rect2) -> void:
	var old := rect
	
	rect.position = Vector2i(edited.position) / tile_size
	rect.size = Vector2i(edited.size) / tile_size
	
	rect_changed.emit(rect, old)


func _process(delta: float) -> void:
	border_width = 5.0 / get_canvas_transform().get_scale().x


func set_level(new: LevelFile) -> void:
#	level = new
	$Preview.level = new
	$Preview.update_texture()
