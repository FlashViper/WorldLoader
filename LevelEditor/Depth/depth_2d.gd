@tool
class_name Depth2D 
extends Resource

var screen_size : Vector2
var camera_position : Vector2


func initialize(p_screen_size: Vector2) -> void:
	screen_size = p_screen_size


func projectPoint(pos: Vector2, depth: float) -> Vector2:
	return (
		(camera_position - pos) * 
		(4 / PI * atan((depth + screen_size.y) / screen_size.y) + 1) + 
		pos
	)


func projectPointBulk(points: PackedVector2Array, depths : PackedFloat32Array) -> PackedVector2Array:
	var data := points.duplicate()
	
	for i in data.size():
		data[i] = (
			(camera_position - points[i]) * 
			(-4 / PI * atan((depths[i] + screen_size.y) / screen_size.y) + 1) 
			+ points[i]
		)
	
	return data


func inverseProjection(final: Vector2, depth: float) -> Vector2:
	var depth_factor := (-4 / PI * atan((depth + screen_size.y) / screen_size.y) + 1)
	return (final - camera_position * depth_factor) / (1 - depth_factor)


func reproject(root_pos: Vector2, depth_initial: float, depth_final: float) -> Vector2:
	return inverseProjection(projectPoint(root_pos, depth_initial), depth_final)
