class_name ConfigurableCanvas
extends CanvasLayer

var custom_controls : Array[Control] = []

func add_control(control: Control, anchor : Control.LayoutPreset = -1) -> void:
	custom_controls.append(control)
	add_child(control)
	
	if anchor >= 0:
		control.set_anchors_preset(anchor, true)

func remove_control(control: Control, destroy := false) -> void:
	var index := custom_controls.find(control)
	if index < 0: # Invalid search index
		printerr("Tried to remove a nonexistant custom control")
		return
	
	if destroy:
		custom_controls[index].queue_free()
	custom_controls.remove_at(index)
