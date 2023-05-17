extends Control

signal added_item(item: DecoObject)

@onready var type: OptionButton = $Type
@onready var root: Control = $AddDialogRoot


func _ready() -> void:
	type.item_selected.connect(on_item_changed)
	type.select(0)
	on_item_changed(0)
	
	$AddDialogRoot/AddImage.palette_created.connect(
		func(obj: DecoObject):
			added_item.emit(obj)
	)


func on_item_changed(index: int) -> void:
	for i in root.get_child_count():
		root.get_child(i).visible = (index == i)
