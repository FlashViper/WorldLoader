extends Popup

signal file_submitted(filename: String)

@export var base_dir := &"res://Worlds/%s.wrld"
var just_submitted : bool

func _ready() -> void:
	%Input_File.text_submitted.connect(self.submit)
	%Input_Submit.pressed.connect(func(): self.submit(%Input_File.text))
	popup_hide.connect(self.rejected)

func request_file() -> void:
	popup_centered()
	%Input_File.grab_focus()

func submit(text: String) -> void:
	if %Input_CreateFolders.button_pressed:
		DirAccess.make_dir_recursive_absolute(base_dir.get_base_dir())
	
	file_submitted.emit(base_dir % text)
	just_submitted = true
	hide()

func rejected() -> void:
	if !just_submitted:
		file_submitted.emit("")
	
	just_submitted = false
