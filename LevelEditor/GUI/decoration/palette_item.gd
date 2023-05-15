extends Control

signal selected(new: DecoObject)
@onready var highlight: Panel = $Highlight

var decoration : DecoObject :
	get = get_decoration, 
	set = set_decoration


func get_decoration() -> DecoObject:
	return decoration


func set_decoration(new: DecoObject) -> void:
	decoration = new
	update_visuals()


func _ready() -> void:
	mouse_entered.connect(on_mouse_enter)
	mouse_exited.connect(on_mouse_exit)
	highlight.modulate.a = 0


func update_visuals() -> void:
	%Name.text = decoration.name
	%Preview.texture = decoration._get_preview()


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.is_pressed():
				selected.emit(decoration)
				var t := create_tween()
				t.tween_property(highlight, "modulate:a", 1, 0.1)


func on_mouse_enter() -> void:
	var t := create_tween()
	t.tween_property(highlight, "modulate:a", 0.5, 0.1)


func on_mouse_exit() -> void:
	var t := create_tween()
	t.tween_property(highlight, "modulate:a", 0, 0.1)
