@tool
extends EditorPlugin

const Importer_Level := preload("./importer_levelfile.gd")
const Exporter_Level:= preload("./exporter_levelfile.gd")
const Inspector_Level := preload("./inspector_levelfile.gd")

var importer : Importer_Level
var exporter : Exporter_Level
var inspector : Inspector_Level

func _enable_plugin() -> void:
	importer = Importer_Level.new()
	add_import_plugin(importer)
	
	exporter = Exporter_Level.new()
	add_export_plugin(exporter)
	
	inspector = Inspector_Level.new()
	add_inspector_plugin(inspector)

func _disable_plugin() -> void:
	if importer:
		remove_import_plugin(importer)
	
	if exporter:
		remove_export_plugin(exporter)
	
	if inspector:
		remove_inspector_plugin(inspector)
