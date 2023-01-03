extends Node

var editors : Array[Node]
var currentEditor := -1

func _ready() -> void:
	editors.append_array([
		$Editors/WorldEditor,
		$Editors/LevelEditor,
	])
	
	for e in editors:
		e.disable()
	
	switch_editors(0)

func switch_editors(new: int) -> void:
	if currentEditor >= 0 and currentEditor < editors.size():
		editors[currentEditor].disable()
	if new >= 0 and new < editors.size():
		editors[new].enable()
	
	currentEditor = new
