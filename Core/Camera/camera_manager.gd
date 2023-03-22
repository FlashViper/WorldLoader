extends Camera2D

const CameraTarget := preload("./camera_target.gd")

var targets : Array = [] #CameraTarget] = []
var currentTarget := -1

func _init() -> void:
	deactivate()


func _process(delta: float) -> void:
	if currentTarget < 0 or currentTarget >= targets.size():
		set_process_mode(PROCESS_MODE_PAUSABLE)
		return
	
	position = targets[currentTarget].position
	zoom = Vector2.ONE * targets[currentTarget].zoom


func activate() -> void:
	enabled = true


func deactivate() -> void:
	enabled = false


func register_target(t: CameraTarget) -> void:
	t.activity_changed.connect(sort_targets)
	t.priority_changed.connect(sort_targets)
	targets.append(t)
	sort_targets()


func sort_targets() -> void:
	if targets.size() < 1:
		currentTarget = -1
		return
	
	var highest_index = targets[0].priority
	
	for i in targets.size():
		if targets[i].active:
			if targets[i].priority >= targets[highest_index].priority:
				highest_index = i
	
	if highest_index >= 0:
		if highest_index != currentTarget:
			if currentTarget >= 0:
				targets[currentTarget].set_process_mode(false)
			currentTarget = highest_index
			transition_to_target(currentTarget)

func transition_to_target(target: int) -> void:
	var t = targets[target]
	set_process(false)
	
	var tween := create_tween().set_parallel(true).set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_property(self, "position", t.position, 0.35).set_trans(Tween.TRANS_QUART)
	tween.tween_property(self, "zoom", Vector2.ONE * t.zoom, 0.2).set_trans(Tween.TRANS_QUAD)
	
	await tween.finished
	set_process(true)
	targets[currentTarget].set_process_mode(true)
