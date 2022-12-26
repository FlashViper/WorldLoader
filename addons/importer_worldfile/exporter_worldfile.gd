extends EditorExportPlugin

const FILEPATH := "C:/Users/ellio/Documents/log.txt"
var args : PackedStringArray

func _get_name() -> String:
	return "ur_fashe"

func _export_begin(features: PackedStringArray, is_debug: bool, p: String, flags: int) -> void:
	var f := FileAccess.open(FILEPATH, FileAccess.WRITE)
	f.store_string("AM I GOING INSANE???")
	args = PackedStringArray()
	
	var results := PackedStringArray()
	var toSearch := ["res://"]
	
	while toSearch.size() > 0:
		var path = toSearch.pop_back()
		var dir := DirAccess.open(path)
		
		if dir:
			dir.list_dir_begin()
			var file_name := dir.get_next()
			print_rich("[color=mediumslateblue]Scanning file %s[/color]" % (path + file_name))
			while file_name != "":
				if dir.current_is_dir():
					toSearch.append(path + file_name + "/")
				elif file_name.get_extension() == "wrld":
					print("Adding file %s%s" % [path, file_name])
					add_file(path + file_name, FileAccess.get_file_as_bytes(path + file_name), false)
				
				results.append(path + file_name)
				file_name = dir.get_next()

#func _export_file(path: String, type: String, features: PackedStringArray) -> void:
#	prints(path, type)

func _export_end() -> void:
	print("EXPORT ENDED")
