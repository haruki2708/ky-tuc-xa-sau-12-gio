class_name Ch3Actor
extends CharacterBody3D
## Shared navmesh locomotion; explicit motion deltas also support sparse AI ticks.

@export var body_scene: PackedScene
@export var step_height: float = 0.3
@onready var navigation: NavigationAgent3D = $NavigationAgent3D
@onready var visual: Node3D = $Visual
var model: Node3D
var pose: StringName = &"idle"
var _played_pose: StringName
var last_collision: KinematicCollision3D


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_PAUSABLE
	if body_scene != null:
		set_body(body_scene)


func set_body(scene: PackedScene) -> void:
	body_scene = scene
	if not is_instance_valid(visual):
		return
	if is_instance_valid(model):
		model.queue_free()
		model = null
	$Visual/Fallback.visible = true
	if scene == null:
		return
	var instance: Node = scene.instantiate()
	if instance is not Node3D:
		instance.free()
		return
	model = instance
	visual.add_child(model)
	$Visual/Fallback.hide()
	_played_pose = &""
	play_pose(pose)


func play_pose(value: StringName) -> void:
	pose = value
	if not is_instance_valid(visual) or _played_pose == value:
		return
	_played_pose = value
	if is_instance_valid(model):
		if model.has_method("set_pose"):
			model.call("set_pose", value)
		elif model.has_method("set_state"):
			model.call("set_state", value)
		else:
			var animator: AnimationPlayer = model.find_child("AnimationPlayer", true, false) as AnimationPlayer
			if animator != null and animator.has_animation(value):
				animator.play(value)
	$Visual/Fallback.rotation.x = PI * 0.5 if value in [&"lie", &"stunned"] else 0.0
	$Visual/Fallback.position.y = 0.2 if value in [&"lie", &"stunned"] else (-0.5 if value == &"sit" else 0.0)


func head_position() -> Vector3:
	if is_instance_valid(model):
		var head: Node3D = model.find_child("Head", true, false) as Node3D
		if head != null:
			return head.global_position
	return $Visual/Fallback/Head.global_position


func face(point: Vector3) -> void:
	var direction: Vector3 = point - global_position
	direction.y = 0
	if direction.length_squared() > 0.0001:
		rotation.y = atan2(-direction.x, -direction.z)


func clear_line(from: Vector3, to: Vector3) -> bool:
	var query: PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.create(from, to, 1, [get_rid()])
	return get_world_3d().direct_space_state.intersect_ray(query).is_empty()


func navigate_to(point: Vector3, speed: float, delta: float, avoid_guards: bool = false) -> void:
	last_collision = null
	if NavigationServer3D.map_get_iteration_id(navigation.get_navigation_map()) == 0:
		velocity = Vector3.ZERO
		return
	if navigation.get_current_navigation_path().is_empty() or navigation.target_position.distance_to(point) > 0.2:
		navigation.target_position = point
	var start: Vector3 = global_position
	var next: Vector3 = navigation.get_next_path_position()
	var direction: Vector3 = next - global_position
	var climbing: bool = absf(direction.y) > 0.12
	direction.y = 0
	var distance: float = direction.length()
	var motion: Vector3 = direction.normalized() * minf(distance, speed * (0.7 if climbing else 1.0) * delta)
	if avoid_guards:
		motion = _guard_motion(motion)
	if not motion.is_zero_approx():
		face(global_position + motion)
		var contact: KinematicCollision3D = KinematicCollision3D.new()
		# Step up only onto the world, never onto another actor (a bumped
		# zombie used to wedge itself into the floor and stop for good).
		if test_move(global_transform, motion, contact) and absf(contact.get_normal().y) < 0.7 \
				and not (contact.get_collider() is Ch3Actor):
			var raised: Transform3D = global_transform.translated(Vector3.UP * step_height)
			if not test_move(global_transform, Vector3.UP * step_height) and not test_move(raised, motion):
				move_and_collide(Vector3.UP * step_height)
		last_collision = move_and_collide(motion)
		if last_collision != null:
			move_and_collide(last_collision.get_remainder().slide(last_collision.get_normal()))
	velocity = motion / maxf(delta, 0.00001)
	# Snap down after steps; world collision prevents falling through stairs/floors.
	move_and_collide(Vector3.DOWN * maxf(step_height + 0.04, 9.8 * delta * delta))
	if motion.length_squared() > 0.0001 and global_position.distance_squared_to(start) < motion.length_squared() * 0.0625:
		_lift_out_of_floor()


## Back onto the floor if a shove left the feet inside it. Only called when a
## step barely moved, and probes with one short ray (navmesh queries on the
## outdoor mesh cost too much per zombie per tick).
func _lift_out_of_floor() -> void:
	var query: PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.create(
			global_position + Vector3.UP * 0.5, global_position + Vector3.DOWN * 0.05, 1, [get_rid()])
	var hit: Dictionary = get_world_3d().direct_space_state.intersect_ray(query)
	if hit.is_empty() or hit.get("collider") is Ch3Actor:
		return
	var sunk: float = (hit["position"] as Vector3).y - global_position.y
	if sunk > 0.02 and sunk < 0.3:
		global_position.y += sunk


func _guard_motion(motion: Vector3) -> Vector3:
	for guard: Node in get_tree().get_nodes_in_group(&"ch3_guard"):
		if guard is not Node3D or guard.get_world_3d() != get_world_3d() or absf(guard.global_position.y - global_position.y) > 2.0:
			continue
		var away: Vector3 = global_position - guard.global_position
		away.y = 0
		var radius: float = float(guard.get("warning_radius")) + 0.35
		if (away + motion).length() < radius:
			if away.is_zero_approx():
				away = Vector3.RIGHT
			if away.length() < radius:
				motion = away.normalized() * minf(radius - away.length(), motion.length())
			else:
				var tangent: Vector3 = Vector3.UP.cross(away).normalized()
				if tangent.dot(motion) < 0:
					tangent = -tangent
				motion = tangent * motion.length()
	return motion
