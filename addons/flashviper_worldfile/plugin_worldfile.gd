@tool
extends EditorPlugin

const Exporter := preload("./exporter_worldfile.gd")
const Importer_Level := preload("./LevelFile/importer_levelfile.gd")
const Inspector_Level := preload("./LevelFile/inspector_levelfile.gd")
const Importer_World := preload("./WorldFile/importer_worldfile.gd")
const Inspector_World := preload("./WorldFile/inspector_world.gd")

var exporter : Exporter

var importer_level : Importer_Level
var inspector_level : Inspector_Level

var importer_world : Importer_World
var inspector_world : Inspector_World


func _enter_tree() -> void:
	exporter = Exporter.new()
	add_export_plugin(exporter)
	
	importer_level = Importer_Level.new()
	add_import_plugin(importer_level)
	importer_world = Importer_World.new()
	add_import_plugin(importer_world)
	
	inspector_level = Inspector_Level.new()
	add_inspector_plugin(inspector_level)
	inspector_world = Inspector_World.new()
	add_inspector_plugin(inspector_world)

func _exit_tree() -> void:
	if exporter:
		remove_export_plugin(exporter)
	
	if importer_level:
		remove_import_plugin(importer_level)
	if importer_world:
		remove_import_plugin(importer_world)
	
	if inspector_level:
		remove_inspector_plugin(inspector_level)
	if inspector_world:
		remove_inspector_plugin(inspector_world)
