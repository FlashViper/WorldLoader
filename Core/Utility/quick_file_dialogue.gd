@tool
extends Popup

signal file_submitted(filename: String)

@export var base_dir := &"res://Worlds/%s.wrld" :
	set(new):
		base_dir = new
		if input_text:
			input_text.placeholder_text = base_dir % "<FILE_NAME>"

@export var input_default_line := "" :
	set(new):
		input_default_line = new
		if input_text:
			input_text.text = input_default_line


@export_group("Create Folders")
@export var allow_option_create_folders := true :
	set(new):
		allow_option_create_folders = new
		
		if input_create_folders:
			input_create_folders.visible = new
			
@export var default_value_create_folders := true :
	set(new):
		default_value_create_folders = new
		if input_create_folders:
			input_create_folders.button_pressed = new

@onready var input_text : LineEdit = %Input_File
@onready var input_create_folders : Button = %Input_CreateFolders

var just_submitted : bool


func _ready() -> void:
	input_text.text = input_default_line
	input_text.placeholder_text = base_dir % "<FILE_NAME>"
	input_create_folders.button_pressed = default_value_create_folders
	input_create_folders.visible = allow_option_create_folders
	
	if Engine.is_editor_hint():
		return
	
	%Input_Submit.pressed.connect(func(): self.submit(input_text.text))
	input_text.text_submitted.connect(self.submit)
	popup_hide.connect(self.rejected)


func request_file() -> void:
	if Engine.is_editor_hint():
		return
		
	popup_centered()
	input_text.grab_focus()


func submit(text: String) -> void:
	if Engine.is_editor_hint():
		return
	
	if input_create_folders.button_pressed:
		var dir_full := ProjectManager.convert_path(base_dir.get_base_dir())
		DirAccess.make_dir_recursive_absolute(dir_full)
	
	file_submitted.emit(base_dir % text)
	just_submitted = true
	hide()


func rejected() -> void:
	if Engine.is_editor_hint():
		return
	
	if !just_submitted:
		file_submitted.emit("")
	
	just_submitted = false
