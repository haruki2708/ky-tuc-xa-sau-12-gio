extends TestCase

var world: Node3D
var camera: Camera3D
var subject: Node3D
var poser: UnseenPoser
var changes: Array[StringName] = []
var _paused: bool


func before_each() -> void:
	_paused = tree.paused
	tree.paused = false
	world = Node3D.new()
	tree.root.add_child(world)
	camera = Camera3D.new()
	camera.position = Vector3(0, 1, 0)
	world.add_child(camera)
	subject = Node3D.new()
	subject.position = Vector3(0, 1, -3)
	world.add_child(subject)
	for name: String in ["rest", "turn"]:
		var pose: MeshInstance3D = MeshInstance3D.new()
		pose.name = name
		var mesh: BoxMesh = BoxMesh.new()
		mesh.size = Vector3(0.5, 0.5, 0.5)
		pose.mesh = mesh
		subject.add_child(pose)
	poser = UnseenPoser.new()
	poser.camera = camera
	poser.poses = [&"rest", &"turn"]
	poser.rng_seed = 152
	poser.chance = 1.0
	poser.min_unseen_seconds = 0.1
	subject.add_child(poser)
	poser.set_physics_process(false)
	poser.pose_changed.connect(func(name: StringName) -> void: changes.append(name))
	await tree.physics_frame
	await tree.process_frame


func after_each() -> void:
	tree.paused = false
	world.queue_free()
	await wait_frames(2)
	tree.paused = _paused


func _wall() -> StaticBody3D:
	var wall: StaticBody3D = StaticBody3D.new()
	var collision: CollisionShape3D = CollisionShape3D.new()
	var shape: BoxShape3D = BoxShape3D.new()
	shape.size = Vector3(20, 20, 0.2)
	collision.shape = shape
	wall.add_child(collision)
	wall.position = Vector3(0, 1, -1.5)
	world.add_child(wall)
	return wall


func test_seen_pose_never_changes_and_unseen_delay_resets_on_look() -> void:
	assert_true(UnseenPoser.is_seen_by(camera, subject, 15.0))
	poser._physics_process(10.0)
	assert_true(changes.is_empty())
	camera.rotation.y = PI
	poser._physics_process(0.09)
	assert_true(changes.is_empty())
	camera.rotation.y = 0.0
	poser._physics_process(0.1)
	camera.rotation.y = PI
	poser._physics_process(0.09)
	assert_true(changes.is_empty(), "looking back restarts the unseen interval")
	poser._physics_process(0.02)
	assert_eq(changes, [&"turn"])
	assert_false(subject.get_node("rest").visible)
	assert_true(subject.get_node("turn").visible)
	camera.rotation.y = 0.0
	poser._physics_process(10.0)
	assert_eq(changes.size(), 1)


func test_visibility_checks_wall_distance_frustum_and_partial_mesh() -> void:
	var wall: StaticBody3D = _wall()
	await tree.physics_frame
	await tree.process_frame
	assert_false(EntityVisibility.is_seen_by(camera, subject, 15.0))
	poser._physics_process(0.11)
	assert_eq(changes.size(), 1)
	wall.queue_free()
	await wait_frames(2)
	subject.position.z = -15.0
	assert_false(EntityVisibility.is_seen_by(camera, subject, 15.0), "distance is strictly below 15m")
	subject.position = Vector3(0, 1, 3)
	assert_false(EntityVisibility.is_seen_by(camera, subject, 15.0), "behind camera")
	subject.position = Vector3(10, 1, -3)
	(subject.get_node("turn").mesh as BoxMesh).size = Vector3(20, 1, 1)
	assert_true(EntityVisibility.is_seen_by(camera, subject, 15.0), "visible edge protects a partially visible corpse")
	subject.hide()
	assert_false(EntityVisibility.is_seen_by(camera, subject, 15.0))


func test_seeded_chance_rolls_once_per_interval_and_disabled_resets() -> void:
	camera.rotation.y = PI
	poser.chance = 0.35
	var expected: RandomNumberGenerator = RandomNumberGenerator.new()
	expected.seed = 152
	var count: int = 0
	for index: int in 20:
		if expected.randf() < 0.35:
			count += 1
		poser._physics_process(0.1)
	assert_eq(changes.size(), count)
	assert_true(count > 0 and count < 20)
	poser.chance = 1.0
	poser._physics_process(0.09)
	poser.enabled = false
	poser._physics_process(2.0)
	poser.enabled = true
	poser._physics_process(0.09)
	assert_eq(changes.size(), count)
	poser._physics_process(0.02)
	assert_eq(changes.size(), count + 1)


func test_animation_pose_is_sampled_and_frozen_even_after_becoming_seen() -> void:
	var head: Node3D = Node3D.new()
	head.name = "Head"
	subject.add_child(head)
	var animator: AnimationPlayer = AnimationPlayer.new()
	subject.add_child(animator)
	var library: AnimationLibrary = AnimationLibrary.new()
	for name: StringName in [&"rest", &"turn"]:
		var animation: Animation = Animation.new()
		animation.length = 1.0
		var track: int = animation.add_track(Animation.TYPE_VALUE)
		animation.track_set_path(track, ^"Head:rotation")
		animation.track_insert_key(track, 0.0, Vector3.ZERO)
		animation.track_insert_key(track, 1.0, Vector3(0, 0.7 if name == &"turn" else 0.0, 0))
		library.add_animation(name, animation)
	animator.add_animation_library(&"", library)
	poser.animation_player = animator
	camera.rotation.y = PI
	poser._physics_process(0.11)
	assert_true(is_equal_approx(head.rotation.y, 0.7))
	assert_false(animator.is_playing())
	camera.rotation.y = 0.0
	await tree.create_timer(0.15).timeout
	poser._physics_process(0.2)
	assert_true(is_equal_approx(head.rotation.y, 0.7), "pose must not keep animating in view")
	assert_eq(changes, [&"turn"])


func test_pause_and_missing_references_do_not_change_pose() -> void:
	camera.rotation.y = PI
	poser.set_physics_process(true)
	tree.paused = true
	await tree.create_timer(0.2, true).timeout
	assert_true(changes.is_empty())
	tree.paused = false
	poser.set_physics_process(false)
	camera.free()
	poser._physics_process(10.0)
	assert_true(changes.is_empty())
	assert_false(EntityVisibility.is_seen_by(null, subject))


func test_camera_body_does_not_occlude_its_own_view() -> void:
	var body: StaticBody3D = StaticBody3D.new()
	var shape: SphereShape3D = SphereShape3D.new()
	shape.radius = 0.5
	var collision: CollisionShape3D = CollisionShape3D.new()
	collision.shape = shape
	body.add_child(collision)
	body.position = camera.position
	world.add_child(body)
	camera.reparent(body)
	await tree.physics_frame
	await tree.process_frame
	assert_true(EntityVisibility.is_seen_by(camera, subject))
