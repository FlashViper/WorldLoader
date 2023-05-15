extends Control

signal palette_created(new: DecoObject)

func _ready() -> void:
	%ChooseFile.pressed.connect(select_file)
	%Add.pressed.connect(load_file)


func select_file() -> void:
	$FileDialog.request_file()
	
	var filepath := await $FileDialog.file_submitted as String
	if filepath == "":
		return
	
	%Filepath.text = filepath


func load_file() -> void:
	var filepath = ProjectManager.convert_path(%Filepath.text)
	
	# Oh boy this fix took a whole hour of my life
	const STRIP_CHARS := " \t"
	filepath = filepath.lstrip(STRIP_CHARS)
	filepath = filepath.rstrip(STRIP_CHARS)
	
	var img := Image.load_from_file(filepath)
	var tex := ImageTexture.create_from_image(img)
	
	var decoration := DecoImage.new()
	decoration.image = tex
	palette_created.emit(decoration)
