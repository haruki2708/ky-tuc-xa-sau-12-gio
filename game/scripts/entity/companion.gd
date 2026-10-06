class_name Companion
extends Ch3Actor

@export var member: StringName = &"minh_nhat"
@export var player: Node3D
@export var speed: float = 2.6
## Follow mode (D-063): distance kept behind the player, side offset, and the
## pace used to catch up once the gap opens.
@export var follow_gap: float = 3.5
@export var follow_side: float = 1.2
@export var catch_up_speed: float = 3.8
var state: StringName = &"left"
var following: bool = false
var _stuck_seconds: float = 0.0
var _last_position: Vector3
var _points: Array[Node3D] = []
var _index: int = 0
var _far_seconds: float = 0.0
var _called: bool = false


func follow_path(path_root: Node3D) -> void:
	following = false
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


## Walk behind the player wherever they go (D-063, Claude làm thay lane A).
func follow_player() -> void:
	following = true
	_points.clear()
	_index = 0
	_far_seconds = 0.0
	_called = false
	_stuck_seconds = 0.0
	_last_position = global_position
	_set_state(&"joined")
	_set_state(&"waiting")


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
	if following:
		_follow(delta, distance)
		return
	while _index < _points.size() and not is_instance_valid(_points[_index]):
		_index += 1
	if _index >= _points.size():
		_set_state(&"left")
		return
	var point: Node3D = _points[_index]
	# A point just off the navmesh counts as reached once the path ends there.
	if global_position.distance_to(point.global_position) < 0.35 or _path_ended_near(point.global_position):
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
	_dodge()


func _path_ended_near(point: Vector3) -> bool:
	return navigation.target_position.distance_to(point) <= 0.2 and navigation.is_navigation_finished() 		and global_position.distance_to(point) < 3.0


func _follow(delta: float, distance: float) -> void:
	if not is_instance_valid(player):
		return
	var spot: Vector3 = _follow_spot()
	if distance <= follow_gap + 1.0 or global_position.distance_to(spot) < 0.5:
		_stuck_seconds = 0.0
		if not _called:
			_set_state(&"waiting")
		face(player.global_position)
		return
	if not _called:
		_set_state(&"running")
	var moved: float = global_position.distance_to(_last_position)
	_last_position = global_position
	_stuck_seconds = _stuck_seconds + delta if moved < 0.2 * delta else 0.0
	# Far behind and out of the player's sight, or stuck: catch up unseen.
	if (distance > 30.0 or _stuck_seconds > 4.0) and _catch_up():
		return
	navigate_to(spot, catch_up_speed if distance > follow_gap * 3.0 else speed, delta)
	_dodge()


## A navmesh point behind the player, to one side.
func _follow_spot() -> Vector3:
	var back: Vector3 = player.global_basis.z
	back.y = 0
	back = back.normalized() if back.length_squared() > 0.001 else Vector3.BACK
	var side: Vector3 = back.cross(Vector3.UP) * follow_side
	var wanted: Vector3 = player.global_position + back * follow_gap + side
	return NavigationServer3D.map_get_closest_point(navigation.get_navigation_map(), wanted)


func _catch_up() -> bool:
	var camera: Camera3D = player.get_node_or_null("Head/Camera3D") as Camera3D
	var back: Vector3 = player.global_basis.z
	back.y = 0
	back = back.normalized() if back.length_squared() > 0.001 else Vector3.BACK
	var map: RID = navigation.get_navigation_map()
	for step: float in [8.0, 6.0, 12.0, 4.0]:
		var spot: Vector3 = NavigationServer3D.map_get_closest_point(map, player.global_position + back * step + back.cross(Vector3.UP) * follow_side)
		if absf(spot.y - player.global_position.y) > 1.5 or spot.distance_to(player.global_position) > step + 3.0:
			continue
		if camera != null and camera.is_position_in_frustum(spot + Vector3.UP):
			continue
		global_position = spot
		velocity = Vector3.ZERO
		_stuck_seconds = 0.0
		_last_position = spot
		return true
	return false


func _dodge() -> void:
	# Cosmetic dodge only. Never stun a zombie or consume the player's weapon.
	visual.rotation.z = 0.0
	for node: Node in get_tree().get_nodes_in_group(&"ch3_zombie"):
		if node is Node3D and node.get_world_3d() == get_world_3d() and node.global_position.distance_to(global_position) < 1.4:
			visual.rotation.z = sin(Time.get_ticks_msec() * 0.01) * 0.18
			break
