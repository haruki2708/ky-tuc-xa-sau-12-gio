class_name PhoneDecoy
extends Node3D
## Swept short arc, then six seconds of ringing at the actual landing point.

signal returned

const RANGE: float = 15.0
const RING_SECONDS: float = 6.0
const FLIGHT_SECONDS: float = 0.7
var charges_left: int = 0
var landed: bool = false
var ring_elapsed: float = 0.0
var _start: Vector3
var _end: Vector3
var _elapsed: float = 0.0
var _falling: bool = false
var _fall_speed: float = 0.0
var _next_noise: float = 1.0
var _finished: bool = false


static func landing_point(camera: Camera3D) -> Dictionary:
	var space: PhysicsDirectSpaceState3D = camera.get_world_3d().direct_space_state
	var origin: Vector3 = camera.global_position
	var aim: Vector3 = origin - camera.global_basis.z * RANGE
	var ray: Dictionary = space.intersect_ray(PhysicsRayQueryParameters3D.create(origin, aim, 1))
	if not ray.is_empty():
		aim = ray.position + ray.normal * 0.06
	# Shorten the throw if the floor below the aim point is outside the range.
	for index: int in 10:
		var probe: Vector3 = origin.lerp(aim, 1.0 - index * 0.1)
		var floor_hit: Dictionary = space.intersect_ray(PhysicsRayQueryParameters3D.create(probe, probe + Vector3.DOWN * 30, 1))
		if not floor_hit.is_empty() and floor_hit.normal.y > 0.45:
			var at: Vector3 = floor_hit.position + floor_hit.normal * 0.025
			if at.distance_to(origin) <= RANGE:
				return {"position": at}
	return {}


func launch(from: Vector3, to: Vector3, appearance: Node3D) -> void:
	process_mode = Node.PROCESS_MODE_PAUSABLE
	top_level = true
	global_position = from
	_start = from
	_end = to
	var visual: Node3D = appearance.duplicate() as Node3D
	visual.transform = Transform3D.IDENTITY
	visual.show()
	add_child(visual)


func _physics_process(delta: float) -> void:
	if _finished or get_tree().paused:
		return
	if landed:
		ring_elapsed = minf(RING_SECONDS, ring_elapsed + delta)
		while _next_noise < RING_SECONDS and ring_elapsed >= _next_noise:
			EventBus.noise_emitted.emit(global_position, 25.0, &"phone_decoy")
			_next_noise += 1.0
		if ring_elapsed >= RING_SECONDS:
			_finish()
		return
	_elapsed += delta
	var progress: float = minf(1, _elapsed / FLIGHT_SECONDS)
	var next: Vector3 = _start.lerp(_end, progress) + Vector3.UP * sin(progress * PI) * 0.75
	if _falling:
		_fall_speed += 9.8 * delta
		next = global_position + Vector3.DOWN * _fall_speed * delta
	var hit: Dictionary = get_world_3d().direct_space_state.intersect_ray(
		PhysicsRayQueryParameters3D.create(global_position, next, 1))
	if not hit.is_empty():
		global_position = hit.position + hit.normal * 0.025
		if hit.normal.y > 0.45:
			_land()
		else:
			_falling = true
	elif not _falling and progress >= 1:
		global_position = next
		_land()
	else:
		global_position = next
		rotation.x = progress * TAU
	if not landed and (_elapsed > 3.0 or global_position.distance_to(_start) > RANGE):
		_finish()


func _land() -> void:
	landed = true
	rotation.x = -PI * 0.5
	EventBus.phone_decoy_thrown.emit(global_position, charges_left)
	EventBus.noise_emitted.emit(global_position, 25.0, &"phone_decoy")


func _finish() -> void:
	_finished = true
	returned.emit()
	queue_free()
