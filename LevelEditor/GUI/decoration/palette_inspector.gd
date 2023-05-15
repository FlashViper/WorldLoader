extends Control

signal decoration_changed(new: DecoObject)

@onready var drag_handle: TextureRect = %DragHandle
@export var palette_item_scene : PackedScene
@onready var root: HFlowContainer = %PalateRoot
@onready var add_item_dialog: VBoxContainer = %AddItemDialog


func _ready() -> void:
	%DragHandle.add_object(self)
	%AddItemButton.pressed.connect(open_add_dialog)
	%AddItemDialog.added_item.connect(add_item)


func add_item(item: DecoObject) -> void:
	var palette_item := palette_item_scene.instantiate()
	palette_item.decoration = item
	root.add_child(palette_item)


func open_add_dialog() -> void:
	add_item_dialog.show()
