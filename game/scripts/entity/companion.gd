class_name Companion
extends Ch3Actor

@export var member: StringName = &"minh_nhat"
@export var player: Node3D
@export var speed: float = 2.6
var state: StringName = &"left"
var _points: Array[Node3D] = []
var _index: int = 0
var _far_seconds: float = 0.0
var _called: bool = false


func follow_path(path_root: Node3D) -> void:
	_points.clear()
	_index = 0
	_far_seconds = 0.0
	_called = false
	if not is_instance_valid(path_root):
		_set_state(&"left")
		return
	for node: Node in path_root.get_children():
		if node is Node3D:
			_points.append(node)
	_points.sort_custom(func(a: Node3D, b: Node3D) -> bool: return String(a.name).naturalnocasecmp_to(String(b.name)) < 0)
	_set_state(&"joined")
	_set_state(&"running" if not _points.is_empty() else &"left")


func _set_state(value: StringName) -> void:
	if state == value:
		return
	state = value
	velocity = Vector3.ZERO
	play_pose(&"walk" if value in [&"running", &"calling"] else &"idle")
	EventBus.companion_state_changed.emit(member, state)


func _physics_process(delta: float) -> void:
	if get_tree().paused or state == &"left":
		return
	var distance: float = global_position.distance_to(player.global_position) if is_instance_valid(player) else INF
	_far_seconds = _far_seconds + delta if distance > 25.0 else 0.0
	if distance <= 25.0:
		_called = false
	if _far_seconds >= 8.0 and not _called:
		_called = true
		_set_state(&"calling")
	while _index < _points.size() and not is_instance_valid(_points[_index]):
		_index += 1
	if _index >= _points.size():
		_set_state(&"left")
		return
	var point: Node3D = _points[_index]
	if global_position.distance_to(point.global_position) < 0.35:
		if String(point.name).contains("_Wait_") and distance > 6.0:
			if not _called:
				_set_state(&"waiting")
			return
		_index += 1
		if _index >= _points.size():
			_set_state(&"left")
			return
		point = _points[_index]
	if not _called:
		_set_state(&"running")
	navigate_to(point.global_position, speed, delta)
	# Cosmetic dodge only. Never stun a zombie or consume the player's weapon.
	visual.rotation.z = 0.0
	for node: Node in get_tree().get_nodes_in_group(&"ch3_zombie"):
		if node is Node3D and node.get_world_3d() == get_world_3d() and node.global_position.distance_to(global_position) < 1.4:
			visual.rotation.z = sin(Time.get_ticks_msec() * 0.01) * 0.18
			break
