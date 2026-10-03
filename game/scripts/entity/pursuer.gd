class_name Pursuer
extends Node3D
## Scene wrapper; Body owns world collision, while this root follows its feet.

signal caught
signal escaped

const SETTINGS_PATH: String = "user://settings.cfg"
const STEP_DISTANCE: float = 0.9
const BREATH_DISTANCE: float = 6.0
const ROUTE_ARRIVAL_RADIUS: float = 0.4
const RUSH_STEPS: Array[AudioStream] = [
	preload("res://audio/sfx/slipper_rush_01.ogg"),
	preload("res://audio/sfx/slipper_rush_02.ogg"),
	preload("res://audio/sfx/slipper_rush_03.ogg"),
	preload("res://audio/sfx/slipper_rush_04.ogg"),
]

enum State { IDLE, CHASING, RETREATING }

@export var body_scene: PackedScene
@export var speed: float = 2.9
@export var catch_radius: float = 0.8
@export var give_up_seconds: float = 2.0

@onready var body: CharacterBody3D = $Body
@onready var visual: Node3D = $Body/Visual
@onready var footsteps: AudioStreamPlayer3D = $Body/Footsteps
@onready var breath: AudioStreamPlayer3D = $Body/Breath

var _state: State = State.IDLE
var _target: Node3D
var _reduce_scares: bool = false
var _retreat_direction: Vector3 = Vector3.ZERO
var _retreat_elapsed: float = 0.0
var _step_distance: float = 0.0
var _previous_step: int = -1
var _detour_sign: float = 0.0
var _route: PackedVector3Array = PackedVector3Array()
var _route_index: int = 0
var _rng: RandomNumberGenerator = RandomNumberGenerator.new()


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_PAUSABLE
	EventBus.settings_changed.connect(_on_settings_changed)
	_read_settings()
	if body_scene != null:
		var instance: Node = body_scene.instantiate()
		if instance is Node3D:
			visual.get_node("Fallback").hide()
			visual.add_child(instance)
		else:
			instance.free()
			push_warning("Pursuer body_scene must have a Node3D root; using fallback capsule.")
	stop_chase()


func start_chase(target: Node3D, spawn: Vector3, route: PackedVector3Array = PackedVector3Array()) -> void:
	stop_chase()
	if not is_instance_valid(target) or not target.is_inside_tree():
		return
	_target = target
	_route = route.duplicate()
	global_position = spawn
	body.position = Vector3.ZERO
	body.reset_physics_interpolation()
	_state = State.CHASING
	visible = true
	set_physics_process(true)


func stop_chase() -> void:
	_state = State.IDLE
	_target = null
	_retreat_elapsed = 0.0
	_step_distance = 0.0
	_detour_sign = 0.0
	_route.clear()
	_route_index = 0
	visible = false
	set_physics_process(false)
	if is_instance_valid(body):
		body.velocity = Vector3.ZERO
	_stop_audio()


func _physics_process(delta: float) -> void:
	if _state == State.IDLE:
		return
	if not is_instance_valid(_target) or not _target.is_inside_tree():
		stop_chase()
		return
	if _state == State.RETREATING:
		_retreat_elapsed += delta
		if _retreat_elapsed >= maxf(0.0, give_up_seconds):
			stop_chase()
			escaped.emit()
			return
		_move(_retreat_direction, _effective_speed() * 0.5, delta)
		return
	# Safety takes priority even when the target is within catch distance.
	if _target_is_safe():
		_state = State.RETREATING
		_retreat_direction = -_horizontal_offset().normalized()
		if _retreat_direction.is_zero_approx():
			_retreat_direction = Vector3.LEFT
		_stop_audio()
		return
	if _can_catch():
		stop_chase()
		caught.emit()
		return
	var offset: Vector3 = _route_offset()
	var direction: Vector3 = offset.normalized()
	var move_speed: float = _effective_speed()
	if _route_index < _route.size():
		# Authored waypoints steer through doorways; collision still prevents crossing walls.
		move_speed = minf(move_speed, offset.length() / maxf(delta, 0.000001))
	else:
		direction = _avoid_wall(direction, move_speed * delta)
	var previous: Vector3 = global_position
	var was_grounded: bool = body.is_on_floor()
	_move(direction, move_speed, delta)
	var distance: float = Vector2(global_position.x - previous.x, global_position.z - previous.z).length()
	if was_grounded and body.is_on_floor():
		_step_distance += distance
		while _step_distance >= STEP_DISTANCE:
			_step_distance -= STEP_DISTANCE
			_play_step()
	_update_breath()


func _route_offset() -> Vector3:
	while _route_index < _route.size():
		var offset: Vector3 = _route[_route_index] - global_position
		offset.y = 0.0
		if offset.length() > ROUTE_ARRIVAL_RADIUS:
			return offset
		# Do not cut a doorway corner just because its approach point is in range.
		var next_point: Vector3 = _route[_route_index + 1] if _route_index + 1 < _route.size() else _target.global_position
		var next_offset: Vector3 = next_point - global_position
		next_offset.y = 0.0
		if offset.length() > 0.01 and body.test_move(body.global_transform, next_offset):
			return offset
		_route_index += 1
	return _horizontal_offset()


func _horizontal_offset() -> Vector3:
	var offset: Vector3 = _target.global_position - global_position
	offset.y = 0.0
	return offset


func _effective_speed() -> float:
	return maxf(0.0, speed) * (0.85 if _reduce_scares else 1.0)


func _avoid_wall(direction: Vector3, frame_distance: float) -> Vector3:
	var probe_distance: float = maxf(0.4, frame_distance)
	# Keep the detour until the complete direct route is clear. A short probe
	# alone oscillates between aiming at the target and following the wall.
	var route_distance: float = maxf(probe_distance, _horizontal_offset().length())
	if not body.test_move(body.global_transform, direction * route_distance):
		_detour_sign = 0.0
		return direction
	if is_zero_approx(_detour_sign):
		_detour_sign = signf(direction.x) if absf(direction.x) > 0.1 else 1.0
	var along_corridor: Vector3 = Vector3(_detour_sign, 0, 0)
	if not body.test_move(body.global_transform, along_corridor * probe_distance):
		return along_corridor
	return Vector3.ZERO


func _move(direction: Vector3, move_speed: float, delta: float) -> void:
	body.velocity.x = direction.x * move_speed
	body.velocity.z = direction.z * move_speed
	if body.is_on_floor():
		body.velocity.y = 0.0
	else:
		body.velocity += body.get_gravity() * delta
	body.move_and_slide()
	var next_position: Vector3 = body.global_position
	body.position = Vector3.ZERO
	global_position = next_position
	if not direction.is_zero_approx():
		visual.rotation.y = atan2(-direction.x, -direction.z)


func _can_catch() -> bool:
	if _horizontal_offset().length() >= maxf(0.0, catch_radius):
		return false
	# A thin wall must prevent catches as well as movement.
	var query: PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.create(
		global_position + Vector3.UP * 0.9, _target.global_position + Vector3.UP * 0.9, 1)
	query.exclude = [body.get_rid()]
	var hit: Dictionary = get_world_3d().direct_space_state.intersect_ray(query)
	return hit.is_empty() or hit.get("collider") == _target


func _target_is_safe() -> bool:
	for node: Node in get_tree().get_nodes_in_group("safe_zone"):
		var area: Area3D = node as Area3D
		if area != null and area.monitoring and area.overlaps_body(_target):
			return true
	# Also support plain Node3D targets and fresh movement before overlap lists update.
	var point: SphereShape3D = SphereShape3D.new()
	point.radius = 0.02
	var query: PhysicsShapeQueryParameters3D = PhysicsShapeQueryParameters3D.new()
	query.shape = point
	query.transform.origin = _target.global_position + Vector3.UP * 0.05
	query.collide_with_areas = true
	query.collide_with_bodies = false
	for hit: Dictionary in get_world_3d().direct_space_state.intersect_shape(query, 64):
		var area: Area3D = hit.get("collider") as Area3D
		if area != null and area.monitoring and area.is_in_group("safe_zone"):
			return true
	return false


func _play_step() -> void:
	# Pick among all other indices, guaranteeing no consecutive repeats.
	var index: int = _rng.randi_range(0, RUSH_STEPS.size() - 2)
	if _previous_step < 0:
		index = _rng.randi_range(0, RUSH_STEPS.size() - 1)
	elif index >= _previous_step:
		index += 1
	_previous_step = index
	footsteps.stream = RUSH_STEPS[index]
	footsteps.play()


func _update_breath() -> void:
	var distance: float = _horizontal_offset().length()
	if distance >= BREATH_DISTANCE:
		breath.stop()
		return
	breath.volume_db = lerpf(-6.0, -24.0, clampf(distance / BREATH_DISTANCE, 0.0, 1.0))
	if _reduce_scares:
		breath.volume_db -= 6.0
	if not breath.playing:
		breath.play()


func _read_settings() -> void:
	var config: ConfigFile = ConfigFile.new()
	_reduce_scares = false
	if config.load(SETTINGS_PATH) == OK:
		var value: Variant = config.get_value("accessibility", "reduce_scares", false)
		_reduce_scares = value if typeof(value) == TYPE_BOOL else false
	if _state == State.CHASING and is_instance_valid(_target):
		_update_breath()


func _on_settings_changed(section: String, key: String) -> void:
	if section == "accessibility" and key == "reduce_scares":
		_read_settings()


func _stop_audio() -> void:
	if is_instance_valid(footsteps):
		footsteps.stop()
	if is_instance_valid(breath):
		breath.stop()


func _exit_tree() -> void:
	_stop_audio()
