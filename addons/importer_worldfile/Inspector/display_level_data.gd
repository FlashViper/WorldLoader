@tool
extends MarginContainer

func displayData(l: LevelData, index := -1) -> void:
	%LevelName.text = l.name if l.name != "" else "Untitled"
	%LevelData.text = "%s, %s" % [l.position, l.size]
	
	if index >= 0:
		%LevelID.text = "%03d" % index
