extends TextureRect

signal pressed
signal button_down
signal button_up

@export_category("Colors")
@export var color_default := Color.WHITE
@export var color_hover := Color8(200, 200, 200)
@export var color_press := Color8(150, 150, 150)
@export var color_disabled := Color8(255, 255, 255, 150)

@export_category("")
@export var is_disabled := false :
	set(new):
		is_disabled = new
		tween_color(color_disabled if is_disabled else color_default)

func _init() -> void:
	stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	mouse_filter = MOUSE_FILTER_STOP

func _ready() -> void:
	mouse_entered.connect(mouse_state_changed.bind(true))
	mouse_exited.connect(mouse_state_changed.bind(false))

func mouse_state_changed(entered: bool) -> void:
	tween_color(color_hover if entered else color_default)

func _gui_input(event: InputEvent) -> void:
	if is_disabled:
		return
	
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.is_pressed():
				pressed.emit()
				button_down.emit()
			else:
				button_down.emit()
			
			tween_color(color_press if event.is_pressed() else color_default)
			accept_event()

func tween_color(new_color: Color, time := 0.1) -> void:
	create_tween().tween_property(self, "modulate", new_color, time)
