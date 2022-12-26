@tool
extends EditorPlugin

const WorldImporter := preload("./importer_worldfile.gd")
const WorldExporter := preload("./exporter_worldfile.gd")

var importer : WorldImporter
var exporter : WorldExporter

func _enable_plugin() -> void:
	importer = WorldImporter.new()
	exporter = WorldExporter.new()
	
	add_import_plugin(importer)
	add_export_plugin(exporter)

func _disable_plugin() -> void:
	if importer:
		remove_import_plugin(importer)
		importer = null
	
	if exporter:
		remove_export_plugin(exporter)
		exporter = null
