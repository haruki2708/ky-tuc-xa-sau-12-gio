class_name PlayerDeath
extends Node
## Camera choreography only. Core owns the verdict/reload; D/E own overlays/audio.

const DURATION: float = 3.0

var active: bool = false
var finished: bool = false
var elapsed: float = 0.0
var kind: StringName
var blood: GPUParticles3D
var reduced: bool = false
var _player: CharacterBody3D
var _camera: Camera3D
var _start: Transform3D
var _end: Transform3D
var _manager: Node3D
var _bursts: int = 0
var _look_basis: Basis


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_PAUSABLE
	refresh_settings()


func start(player: CharacterBody3D, camera: Camera3D, death_kind: StringName) -> void:
	if active:
		return
	active = true
	_player = player
	_camera = camera
	kind = death_kind
	_start = camera.global_transform.orthonormalized()
	_look_basis = _start.basis
	_end = _start
	var yaw: float = player.global_rotation.y
	if kind == &"manager_kill":
		for node: Node in get_tree().get_nodes_in_group(&"dorm_manager"):
			if node is Node3D and node.get_world_3d() == camera.get_world_3d():
				if _manager == null or node.global_position.distance_squared_to(camera.global_position) < _manager.global_position.distance_squared_to(camera.global_position):
					_manager = node
		_end.origin += _start.basis.x * 0.25
		_end.basis = Basis.from_euler(Vector3(0.15, yaw, -PI * 0.5))
	elif kind == &"fall_back":
		_end.origin += player.global_basis.z * 0.35
		_end.basis = Basis.from_euler(Vector3(PI * 0.5, yaw, 0))
	else:
		_end.origin.y -= 0.1
		_end.basis = _start.basis * Basis(Vector3.RIGHT, 0.12)
	if kind != &"bed_burst":
		var query: PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.create(
			_end.origin, _end.origin + Vector3.DOWN * 6.0, 1, [player.get_rid()])
		var hit: Dictionary = camera.get_world_3d().direct_space_state.intersect_ray(query)
		_end.origin.y = float(hit.position.y) + 0.15 if not hit.is_empty() else player.global_position.y + 0.15
	_create_blood()
	if not reduced and kind != &"manager_kill":
		_burst()


func _physics_process(delta: float) -> void:
	if not active or finished:
		return
	elapsed = minf(DURATION, elapsed + delta)
	var desired: Transform3D = _start
	if kind == &"manager_kill":
		if reduced:
			# Look away before the lunge reaches the camera, even if initially facing him.
			desired = _start.interpolate_with(_end, smoothstep(0.0, 2.7, elapsed))
			var ceiling: Basis = Basis.from_euler(Vector3(PI * 0.5, _player.global_rotation.y, 0))
			desired.basis = _start.basis.slerp(ceiling, smoothstep(0.0, 0.3, elapsed))
			_move_camera(desired)
			_finish_if_due()
			return
		if elapsed <= 0.8 and not reduced and is_instance_valid(_manager):
			var target: Vector3 = _manager.global_position + Vector3.UP * 1.7
			var direction: Vector3 = target - _start.origin
			if direction.length() > 0.01 and absf(direction.normalized().dot(Vector3.UP)) < 0.999:
				desired.basis = _start.basis.slerp(Basis.looking_at(direction), smoothstep(0.0, 0.25, elapsed))
				_camera.global_transform = desired
				_look_basis = desired.basis
			return
		if _bursts == 0 and elapsed >= 0.8 and not reduced:
			_burst()
		var progress: float = smoothstep(0.8, 2.7, elapsed)
		desired = _start.interpolate_with(_end, progress)
		desired.basis = _look_basis.slerp(_end.basis, progress)
	elif kind == &"bed_burst":
		var remaining: float = 1.0 - elapsed / DURATION
		desired = _start.interpolate_with(_end, elapsed / DURATION)
		if not reduced:
			desired.origin += _start.basis.y * sin(elapsed * 35.0) * 0.025 * remaining
			desired.basis *= Basis(Vector3.FORWARD, sin(elapsed * 27.0) * 0.045 * remaining)
			if (_bursts == 1 and elapsed > 0.7) or (_bursts == 2 and elapsed > 1.3):
				_burst()
	else:
		desired = _start.interpolate_with(_end, smoothstep(0.15, 2.5, elapsed))
		# A small chest movement slows and fades after impact; sound is lane E's.
		if elapsed > 2.5 and elapsed < DURATION:
			desired.origin.y += sin((elapsed - 2.5) * 6.0) * 0.015 * (DURATION - elapsed)
	_move_camera(desired)
	_finish_if_due()


func _finish_if_due() -> void:
	if elapsed >= DURATION:
		finished = true
		blood.emitting = false
		_player.emit_signal("death_animation_finished")


func _move_camera(desired: Transform3D) -> void:
	# Sweep a small camera volume to avoid cutting through a wall or mattress.
	# Separate lateral and vertical motion so a wall cannot suspend the fall.
	var from: Vector3 = _camera.global_position
	var lateral: Vector3 = desired.origin - from
	lateral.y = 0.0
	from = _sweep_camera(from, lateral)
	desired.origin = _sweep_camera(from, Vector3(0, desired.origin.y - from.y, 0))
	_camera.global_transform = desired


func _sweep_camera(from: Vector3, motion: Vector3) -> Vector3:
	var sphere: SphereShape3D = SphereShape3D.new()
	sphere.radius = 0.1
	var query: PhysicsShapeQueryParameters3D = PhysicsShapeQueryParameters3D.new()
	query.shape = sphere
	query.transform = Transform3D(Basis.IDENTITY, from)
	query.motion = motion
	query.collision_mask = 1
	query.exclude = [_player.get_rid()]
	var travel: PackedFloat32Array = _camera.get_world_3d().direct_space_state.cast_motion(query)
	return from + motion * (travel[0] if not travel.is_empty() else 1.0)


func _create_blood() -> void:
	blood = GPUParticles3D.new()
	blood.name = "DeathBlood"
	blood.emitting = false
	blood.amount = 36
	blood.lifetime = 0.75
	blood.one_shot = true
	blood.explosiveness = 0.9
	blood.fixed_fps = 15
	blood.local_coords = false
	blood.visibility_aabb = AABB(Vector3(-3, -3, -3), Vector3(6, 6, 6))
	var mesh: BoxMesh = BoxMesh.new()
	mesh.size = Vector3(0.025, 0.04, 0.025)
	var material: StandardMaterial3D = StandardMaterial3D.new()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.albedo_color = Color(0.3, 0.006, 0.012)
	mesh.material = material
	blood.draw_pass_1 = mesh
	var particles: ParticleProcessMaterial = ParticleProcessMaterial.new()
	particles.direction = Vector3(0, 1, 0.35)
	particles.spread = 32.0
	particles.initial_velocity_min = 1.2
	particles.initial_velocity_max = 2.4
	particles.gravity = Vector3(0, -3, 0)
	particles.scale_min = 0.7
	particles.scale_max = 2.0
	blood.process_material = particles
	_camera.add_child(blood)
	blood.position = Vector3(0, -0.3, -0.45)
	blood.visible = not reduced


func _burst() -> void:
	_bursts += 1
	blood.restart()
	blood.emitting = true


func refresh_settings() -> void:
	var config: ConfigFile = ConfigFile.new()
	reduced = false
	if config.load("user://settings.cfg") == OK:
		var value: Variant = config.get_value("accessibility", "reduce_scares", false)
		reduced = value if value is bool else false
	if is_instance_valid(blood) and reduced:
		blood.emitting = false
		blood.hide()
