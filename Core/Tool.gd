class_name Tool 
extends Node

func set_active(enabled: bool) -> void:
	set_process(enabled)
	set_physics_process(enabled)
	set_process_shortcut_input(enabled)
	set_process_unhandled_input(enabled)
	set_process_unhandled_key_input(enabled)

func enable_tool() -> void:
	set_active(true)
	enabled()

func disable_tool() -> void:
	set_active(false)
	disabled()

func initialize() -> void: pass
func enabled() -> void: pass
func disabled() -> void: pass

func get_icon() -> Texture2D: return preload("res://icon.svg")
