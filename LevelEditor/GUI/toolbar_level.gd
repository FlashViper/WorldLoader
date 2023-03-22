extends Control

const Button_Texture := preload("res://GUI/button_texture.gd")

signal home_pressed
signal save_pressed
signal settings_pressed
signal back_pressed

signal tool_button_pressed(index: int)

@onready var tool_button_root := %Tools

func _ready() -> void:
	%Home.pressed.connect(func(): home_pressed.emit())
	%Save.pressed.connect(func(): save_pressed.emit())
	%Settings.pressed.connect(func(): settings_pressed.emit())
	%Back.pressed.connect(func(): back_pressed.emit())

func add_tool(icon: Texture, index: int) -> void:
	var button := Button_Texture.new()
	button.texture = icon
	button.pressed.connect(func(): tool_button_pressed.emit(index))
	tool_button_root.add_child(button)
