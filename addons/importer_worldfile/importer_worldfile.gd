@tool
extends EditorImportPlugin

func _get_priority() -> float:
	return 1.0

func _get_importer_name() -> String:
	return "flashviper.worldeditor.importer_world"

func _get_visible_name() -> String:
	return "World Importer"

func _get_recognized_extensions() -> PackedStringArray:
	return PackedStringArray(["world", "wrld"])

func _get_save_extension() -> String:
	return "res"

func _get_resource_type() -> String:
	return "Resource"

func _get_option_visibility(path: String, option_name: StringName, options: Dictionary) -> bool:
	return true

func _get_preset_count() -> int:
	return 1

func _get_preset_name(i) -> String:
	return "Default"

func _get_import_options(path: String, preset_index: int) -> Array[Dictionary]:
	return [{"name": "my_option", "default_value": false}]

func _import(source_file, save_path, options, platform_variants, gen_files) -> int:
	if !FileAccess.file_exists(source_file):
		return FAILED
		
	var world := WorldFile.loadFromFile(source_file)
	var filename = save_path + "." + _get_save_extension()
	
	var err := ResourceSaver.save(world, filename)
	
	if err != OK:
		printerr("Error code %04d while importing file %s: %s" % [err, source_file, error_string(err)])
		
	return err
