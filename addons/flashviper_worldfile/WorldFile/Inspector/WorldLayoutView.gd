@tool
extends VBoxContainer

@export var min_size_y := 100 :
	set(new):
		min_size_y = new
		custom_minimum_size.y = max(custom_minimum_size.y, new)
@onready var display : Control = $Display

var rects : Array[Rect2] = []
var viewBounds : Rect2

func _ready() -> void:
	display.draw.connect(onDisplayDraw)
	display.gui_input.connect(onDisplayInput)
	$ResizeBar.gui_input.connect(resizeInput)

func resizeInput(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		if event.button_mask & MOUSE_BUTTON_MASK_LEFT > 0:
			custom_minimum_size.y = maxf(custom_minimum_size.y + event.relative.y, min_size_y)

func updateWorld(world: WorldFile) -> void:
	rects = []
	
	if world.levels.size() > 0:
		var minPos := Vector2(INF, INF)
		var maxPos := -Vector2(INF, INF)
		
		for l in world.levels:
			var r := Rect2(l.position, l.size)
			
			minPos = min(minPos, r.position)
			maxPos = max(maxPos, r.end)
			
			rects.append(r)
		
		const PADDING := 10
		minPos -= Vector2.ONE * PADDING
		maxPos += Vector2.ONE * PADDING
		
		viewBounds = Rect2(minPos, maxPos - minPos)
	
	if display:
		queue_sort()
		display.queue_redraw()

func onDisplayInput(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		if event.button_mask & MOUSE_BUTTON_MASK_LEFT > 0:
			viewBounds.position -= event.relative * (viewBounds.size / display.size) * 0.5
			display.queue_redraw()

func onDisplayDraw() -> void:
	display.draw_rect(display.get_rect(), Color.DARK_BLUE)
	display.draw_rect(display.get_rect(), Color.BLACK, false, 5)
	
#	display.draw_rect(viewBounds, Color.PINK, false, 3)
	
	for r in rects:
		display.draw_rect(transformRect(r), Color.WHITE, false, 5)

func transformRect(r: Rect2) -> Rect2:
	var normalized := Rect2(
		inverse_lerp(viewBounds.position.x, viewBounds.end.x, r.position.x),
		inverse_lerp(viewBounds.position.y, viewBounds.end.y, r.position.y),
		inverse_lerp(0, viewBounds.size.x, r.size.x),
		inverse_lerp(0, viewBounds.size.y, r.size.y)
	)
	
	return Rect2(normalized.position * display.size, normalized.size * display.size)
