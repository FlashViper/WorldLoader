@tool
extends EditorPlugin

const Importer_World := preload("./importer_worldfile.gd")
const Exporter_World := preload("./exporter_worldfile.gd")
const Inspector_World := preload("./inspector_world.gd")

var importer : Importer_World
var exporter : Exporter_World
var inspector : Inspector_World

func _enable_plugin() -> void:
	importer = Importer_World.new()
	exporter = Exporter_World.new()
	inspector = Inspector_World.new()
	
	add_import_plugin(importer)
	add_export_plugin(exporter)
	add_inspector_plugin(inspector)

func _disable_plugin() -> void:
	if importer:
		remove_import_plugin(importer)
		importer = null
	
	if exporter:
		remove_export_plugin(exporter)
		exporter = null
	
	if inspector:
		remove_inspector_plugin(inspector)
		inspector = null
