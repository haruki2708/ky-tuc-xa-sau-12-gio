extends Node3D
## Planar mirror: local +Z points into the room, +Y is up. Only the body is
## delayed; the reflected eye/frustum stays current so room parallax is correct.

const BODY_LAYER: int = 1 << 19
const SURFACE_LAYER: int = 1 << 18
const MAX_LAG: float = 10.0
@export var follow: Node3D
@export var mirror_size := Vector2(2.8, 0.95)
@export var room_bounds := AABB(Vector3(0.15, -0.1, -4.9), Vector3(5.7, 3.2, 4.8))
## D-105: render only while the glass is on screen (furnished room 407 mirrors).
@export var require_in_view: bool = false
var lag_seconds: float = 0.0
var is_staring: bool = false
var rendering_active: bool = false
var _time: float = 0.0
var _samples: Array[Dictionary] = []
var _source_camera: Camera3D
var _bound_follow: Node3D
var _source_had_body_layer: bool = false
var _material: ShaderMaterial

@onready var reflection_body: Node3D = $ReflectionBody
@onready var reflection_camera: Camera3D = $ReflectionViewport/Camera3D
@onready var viewport: SubViewport = $ReflectionViewport


func _ready() -> void:
	process_priority = 50
	viewport.world_3d = get_world_3d()
	_material = ($Surface as MeshInstance3D).material_override.duplicate() as ShaderMaterial
	$Surface.material_override = _material
	_material.set_shader_parameter("reflection_texture", viewport.get_texture())
	reflection_camera.cull_mask = ((1 << 20) - 1) & ~SURFACE_LAYER
	_set_active(false)


func _exit_tree() -> void:
	_restore_source_camera()


func _restore_source_camera() -> void:
	if is_instance_valid(_source_camera):
		_source_camera.set_cull_mask_value(20, _source_had_body_layer)
	_source_camera = null


func _bind_follow() -> void:
	_restore_source_camera()
	_bound_follow = follow
	_samples.clear()
	if not is_instance_valid(follow):
		return
	_source_camera = follow.get_node_or_null("Head/Camera3D") as Camera3D
	if not _source_camera:
		var cameras := follow.find_children("*", "Camera3D", true, false)
		if not cameras.is_empty():
			_source_camera = cameras[0] as Camera3D
	if _source_camera:
		_source_had_body_layer = _source_camera.get_cull_mask_value(20)
		_source_camera.set_cull_mask_value(20, false)


func set_lag(seconds: float) -> void:
	lag_seconds = clampf(seconds, 0.0, MAX_LAG) if is_finite(seconds) else 0.0


func stare() -> void:
	is_staring = true


func release() -> void:
	is_staring = false
	lag_seconds = 0.0
	_samples.clear()


func step_out() -> Vector3:
	# In front of the sinks, not on top of them. Room origin is at floor level.
	var point := global_position + global_basis.z.normalized() * 1.125
	var room := get_parent() as Node3D
	var local := room.to_local(point)
	local.y = 0.03
	return room.to_global(local)


func _set_active(active: bool) -> void:
	rendering_active = active
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS if active else SubViewport.UPDATE_DISABLED
	reflection_body.visible = active
	_material.set_shader_parameter("active", active)


func _process(delta: float) -> void:
	if not is_instance_valid(follow):
		if _bound_follow != null or is_instance_valid(_source_camera):
			_bind_follow()
		_set_active(false)
		return
	if follow != _bound_follow or not is_instance_valid(_source_camera):
		_bind_follow()
	if not _source_camera:
		_set_active(false)
		return
	_time += delta
	var room := get_parent() as Node3D
	var active := room_bounds.has_point(room.to_local(follow.global_position))
	var eye := _source_camera.global_position
	var normal := global_basis.z.normalized()
	var distance := normal.dot(eye - global_position)
	active = active and distance > 0.05
	if require_in_view:
		active = active and _glass_in_view()
	_set_active(active)
	if not active:
		_samples.clear()
		return
	_samples.append({"time": _time, "body": follow.global_transform,
		"head": _source_camera.global_basis.orthonormalized()})
	# Keep two bracketing samples for interpolation; cap history to the public max.
	while _samples.size() > 2 and float(_samples[1].time) < _time - MAX_LAG:
		_samples.pop_front()
	_update_camera(eye, normal, distance)
	if not is_staring:
		_apply_sample(_time - lag_seconds)
	else:
		var head: Node3D = reflection_body.head
		var target := head.global_transform.looking_at(reflection_camera.global_position, Vector3.UP)
		head.global_basis = head.global_basis.slerp(target.basis, 1.0 - exp(-delta * 14.0)).orthonormalized()


func _glass_in_view() -> bool:
	for corner in [Vector2(-1, -1), Vector2(1, -1), Vector2(-1, 1), Vector2(1, 1), Vector2.ZERO]:
		var point := to_global(Vector3(corner.x * mirror_size.x, corner.y * mirror_size.y, 0.0) * 0.5)
		if _source_camera.is_position_in_frustum(point):
			return true
	return false


func _apply_sample(target_time: float) -> void:
	var first: Dictionary = _samples[0]
	var second: Dictionary = first
	for sample in _samples:
		second = sample
		if float(sample.time) >= target_time:
			break
		first = sample
	var span := float(second.time) - float(first.time)
	var weight := clampf((target_time - float(first.time)) / span, 0.0, 1.0) if span > 0.000001 else 0.0
	var first_body: Transform3D = first.body
	var second_body: Transform3D = second.body
	reflection_body.global_transform = first_body.interpolate_with(second_body, weight)
	var first_head: Basis = first.head
	var second_head: Basis = second.head
	(reflection_body.head as Node3D).global_basis = first_head.slerp(second_head, weight).orthonormalized()


func _update_camera(eye: Vector3, normal: Vector3, distance: float) -> void:
	var reflected_eye := eye - 2.0 * distance * normal
	var up := global_basis.y.normalized()
	var back := -normal
	var right := up.cross(back).normalized()
	reflection_camera.global_transform = Transform3D(Basis(right, up, back), reflected_eye)
	var center := global_position - reflected_eye
	var offset := Vector2(center.dot(right), center.dot(up))
	# Near plane lies on the mirror, clipping the wall behind it. A 1 mm inset
	# avoids z fighting and the viewport aspect matches the physical glass.
	var near_distance := distance + 0.001
	var ratio := near_distance / distance
	reflection_camera.keep_aspect = Camera3D.KEEP_HEIGHT
	reflection_camera.set_frustum(mirror_size.y * ratio, offset * ratio, near_distance, 80.0)
