extends PanelContainer

@export var editor_scene : PackedScene
@onready var world_tree : Tree = %Worlds

func _ready() -> void:
	%ProjectName.text = ProjectManager.project_name
	setup_tree()

func setup_tree() -> void:
	var root := world_tree.create_item()
	
	for filepath in ProjectManager.world_files:
		var w := world_tree.create_item(root)
		w.set_text(0, filepath)
	
	var add := world_tree.create_item(root)
	add.set_text(0, "Create New World")
	add.set_icon(0, preload("res://GUI/Icons/ProjectManager/icon_projectmanager_create.tres"))
	
	
	world_tree.item_activated.connect(on_double_click)
	world_tree.item_double_clicked.connect(on_double_click)


func on_double_click() -> void:
	var selected := world_tree.get_selected()
	world_tree.accept_event()
	if selected.get_index() == ProjectManager.world_files.size():
		create_world()

func create_world() -> void:
	get_tree().change_scene_to_packed(editor_scene)