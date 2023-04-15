@tool
class_name DepthScene2D
extends Node

@export var projection : Depth2D

var objects : Array[Node2D] = []
var root_positions : Array[Vector2] = []
var depths : Array[float] = []


func _enter_tree() -> void:
	if !projection:
		projection = Depth2D.new()
		projection.initialize(ProjectManager.screen_size_px)


func add_object(obj: Node2D, depth: float) -> void:
	objects.append(obj)
	root_positions.append(projection.inverseProjection(obj.position, depth))
	depths.append(depth)
	
	if depth < 0:
		obj.z_index = -1
	elif depth > 0:
		obj.z_index = 1
	add_child(obj)


func _process(delta: float) -> void:
	projection.camera_position = CameraManager.get_screen_center_position()
	var final_points := projection.projectPointBulk(root_positions, depths)
	
	for i in objects.size():
		objects[i].position = projection.projectPoint(root_positions[i], depths[i])
		objects[i].position = final_points[i]
