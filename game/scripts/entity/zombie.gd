class_name Zombie
extends Ch3Actor

@export var speed: float = 1.5
@export var wake_distance: float = 25.0
@export var catch_distance: float = 1.0
@export var door_bash_seconds: float = 10.0
@export var sparse_interval: float = 0.3
var state: StringName = &"asleep"
var target: Node3D
var horde: Node
var audio_enabled: bool = false
var sparse: bool = true
var update_count: int = 0
var _elapsed: float = 0.0
var _visibility_elapsed: float = 0.0
var _stun_left: float = 0.0
var _goal: Vector3
var _caught: bool = false


func _ready() -> void:
	super._ready()
	add_to_group(&"ch3_zombie")
	EventBus.noise_emitted.connect(_on_noise)
	play_pose(&"idle")
	$HeadHitbox.set_meta(&"zombie", self)


func set_target(node: Node3D) -> void:
	target = node
	if is_instance_valid(target):
		_goal = target.global_position


func sleep_pose(value: StringName) -> void:
	state = &"asleep"
	_caught = false
	velocity = Vector3.ZERO
	play_pose(value if value in [&"idle", &"sit", &"lie"] else &"idle")
	_update_visibility()


func wake() -> void:
	if state != &"asleep":
		return
	if is_instance_valid(horde) and not horde.call("request_activation", self):
		return
	state = &"hunting"
	play_pose(&"wake")
	_update_visibility()
	EventBus.zombie_woke.emit(self)


func stun(seconds: float) -> void:
	if not is_finite(seconds) or seconds <= 0:
		return
	if state == &"asleep":
		if is_instance_valid(horde) and not horde.call("request_activation", self, true):
			return
		state = &"hunting"
		EventBus.zombie_woke.emit(self)
	state = &"stunned"
	_elapsed = 0.0
	_stun_left = maxf(_stun_left, seconds)
	velocity = Vector3.ZERO
	play_pose(&"stunned")
	$HeadHitbox.global_position = head_position()
	_update_visibility()
	EventBus.zombie_stunned.emit(self, seconds)


func is_stunned() -> bool:
	return state == &"stunned"


func _on_noise(at: Vector3, radius: float, _source: StringName) -> void:
	if get_tree().paused or not _valid_target() or is_stunned():
		return
	if global_position.distance_to(at) <= radius and (state != &"asleep" or global_position.distance_to(target.global_position) <= wake_distance):
		_goal = at
		wake()


func _valid_target() -> bool:
	return is_instance_valid(target) and target.is_inside_tree() and target.get_world_3d() == get_world_3d()


func _sees_target() -> bool:
	if not _valid_target() or global_position.distance_to(target.global_position) > wake_distance:
		return false
	var offset: Vector3 = target.global_position - global_position
	offset.y = 0
	return (offset.is_zero_approx() or (-global_basis.z).dot(offset.normalized()) >= 0.5) \
		and clear_line(head_position(), target.global_position + Vector3.UP * 1.4)


func _update_visibility() -> void:
	var camera: Camera3D = target.get_node_or_null("Head/Camera3D") as Camera3D if _valid_target() else null
	sparse = not _valid_target() or global_position.distance_to(target.global_position) > 60.0
	if not sparse and camera != null:
		sparse = not camera.is_position_in_frustum(head_position()) or not clear_line(head_position(), camera.global_position)
	audio_enabled = not sparse and state == &"hunting"
	for audio: Node in find_children("*", "AudioStreamPlayer3D", true, false):
		(audio as AudioStreamPlayer3D).stream_paused = not audio_enabled


func _physics_process(delta: float) -> void:
	if get_tree().paused:
		return
	$HeadHitbox.global_position = head_position()
	_visibility_elapsed -= delta
	if _visibility_elapsed <= 0:
		_visibility_elapsed = sparse_interval
		_update_visibility()
	_elapsed += delta
	if sparse and _elapsed < sparse_interval:
		return
	var tick: float = _elapsed
	_elapsed = 0.0
	update_count += 1
	$HeadHitbox.global_position = head_position()
	if is_stunned():
		_stun_left = maxf(0, _stun_left - tick)
		if _stun_left <= 0:
			state = &"hunting"
			play_pose(&"walk")
			$HeadHitbox.global_position = head_position()
		return
	if not _valid_target() or _caught:
		return
	if _sees_target():
		_goal = target.global_position
		wake()
	if state != &"hunting":
		return
	var to_player: Vector3 = target.global_position - global_position
	if to_player.length() <= catch_distance and (-global_basis.z).dot(to_player.normalized()) >= 0.25 \
			and clear_line(head_position(), target.global_position + Vector3.UP * 1.4):
		_caught = true
		velocity = Vector3.ZERO
		play_pose(&"grab")
		EventBus.player_caught.emit(&"zombie")
		return
	if _bash_door(tick):
		return
	play_pose(&"walk")
	navigate_to(_goal, speed, tick, true)


func _bash_door(delta: float) -> bool:
	var direction: Vector3 = _goal - global_position
	direction.y = 0
	if direction.is_zero_approx():
		return false
	var from: Vector3 = global_position + Vector3.UP * 0.9
	var query: PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.create(from, from + direction.normalized() * 0.9, 1, [get_rid()])
	var hit: Dictionary = get_world_3d().direct_space_state.intersect_ray(query)
	if hit.is_empty():
		return false
	var collider: Node = hit.get("collider") as Node
	var adapter: ZombieDoor = collider.get_meta(&"zombie_door") as ZombieDoor if collider.has_meta(&"zombie_door") else null
	if adapter == null or not adapter.is_closed():
		return false
	face(_goal)
	velocity = Vector3.ZERO
	adapter.bash(delta, door_bash_seconds)
	return true
