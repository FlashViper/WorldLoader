@tool
extends EditorPlugin

const WorldImporter := preload("./importer_worldfile.gd")
var importer : WorldImporter

func _enable_plugin() -> void:
	importer = WorldImporter.new()
	add_import_plugin(importer)

func _disable_plugin() -> void:
	if importer:
		remove_import_plugin(importer)
		importer = null
