extends TestCase

var world: Node3D
var camera: Camera3D
var target: Node3D
var detector: GazeDetector
var gazes: int = 0
var previous_paused: bool


func before_each() -> void:
	previous_paused = tree.paused
	tree.paused = false
	world = Node3D.new()
	tree.root.add_child(world)
	camera = Camera3D.new()
	world.add_child(camera)
	target = Node3D.new()
	target.position = Vector3(0, 0, -5)
	world.add_child(target)
	detector = GazeDetector.new()
	detector.camera = camera
	detector.target = target
	detector.hold_seconds = 0.1
	detector.gazed.connect(func() -> void: gazes += 1)
	world.add_child(detector)


func after_each() -> void:
	tree.paused = false
	world.queue_free()
	await wait_frames(2)
	tree.paused = previous_paused


func _ticks(count: int) -> void:
	for index: int in count:
		await tree.physics_frame
		await tree.process_frame


func test_continuous_hold_fires_once_and_reset_rearms() -> void:
	await _ticks(3)
	assert_eq(gazes, 0, "short glance does not fire")
	await _ticks(5)
	assert_eq(gazes, 1)
	await _ticks(15)
	assert_eq(gazes, 1, "held gaze emits only once")
	detector.reset()
	await _ticks(3)
	assert_eq(gazes, 1, "reset needs a fresh hold")
	await _ticks(5)
	assert_eq(gazes, 2)


func test_looking_away_breaks_continuity_and_angles_are_three_dimensional() -> void:
	await _ticks(3)
	camera.rotation.y = PI
	await _ticks(10)
	assert_eq(gazes, 0, "target behind camera does not fire")
	camera.rotation = Vector3.ZERO
	await _ticks(3)
	assert_eq(gazes, 0, "short glances do not accumulate across interruptions")
	camera.rotation.x = deg_to_rad(40.0)
	await _ticks(8)
	assert_eq(gazes, 0, "pitch outside 35 degrees excluded")
	camera.rotation = Vector3(0, deg_to_rad(36.0), 0)
	await _ticks(8)
	assert_eq(gazes, 0, "yaw outside threshold excluded")
	camera.rotation.y = deg_to_rad(34.0)
	await _ticks(8)
	assert_eq(gazes, 1, "inside threshold accepted")


func test_optional_line_of_sight_world_occlusion_and_target_collider() -> void:
	var wall: StaticBody3D = StaticBody3D.new()
	var collision: CollisionShape3D = CollisionShape3D.new()
	var shape: BoxShape3D = BoxShape3D.new()
	shape.size = Vector3(3, 3, 0.2)
	collision.shape = shape
	wall.add_child(collision)
	wall.position.z = -2.5
	world.add_child(wall)
	detector.require_line_of_sight = true
	await _ticks(12)
	assert_eq(gazes, 0, "world wall blocks gaze")
	detector.require_line_of_sight = false
	await _ticks(8)
	assert_eq(gazes, 1, "optional LOS disabled allows sound-source gaze")
	detector.reset()
	detector.require_line_of_sight = true
	wall.queue_free()
	await _ticks(8)
	assert_eq(gazes, 2, "removing occluder allows gaze")
	var target_body: StaticBody3D = StaticBody3D.new()
	var target_shape: CollisionShape3D = CollisionShape3D.new()
	target_shape.shape = BoxShape3D.new()
	target_body.add_child(target_shape)
	target.add_child(target_body)
	detector.reset()
	await _ticks(8)
	assert_eq(gazes, 3, "target's own geometry is visible, not an occluder")


func test_target_change_and_invalid_references_clear_partial_hold() -> void:
	await _ticks(3)
	var replacement: Node3D = Node3D.new()
	replacement.position = target.position
	world.add_child(replacement)
	detector.target = replacement
	await _ticks(3)
	assert_eq(gazes, 0, "new target requires continuous hold from scratch")
	replacement.free()
	await _ticks(8)
	assert_eq(gazes, 0, "freed target cannot trigger")
	detector.target = target
	detector.camera = null
	await _ticks(8)
	assert_eq(gazes, 0, "missing camera cannot trigger")
	detector.camera = camera
	await _ticks(8)
	assert_eq(gazes, 1)


func test_paused_time_does_not_count_and_zero_distance_is_not_gaze() -> void:
	await _ticks(3)
	tree.paused = true
	await tree.create_timer(0.2, true).timeout
	assert_eq(gazes, 0, "pause does not complete the hold")
	tree.paused = false
	await _ticks(5)
	assert_eq(gazes, 1)
	detector.reset()
	target.position = camera.position
	await _ticks(10)
	assert_eq(gazes, 1, "undefined direction at zero distance does not count")


func test_story_angle_and_duration_presets() -> void:
	detector.max_angle_degrees = 50.0
	detector.hold_seconds = 0.3
	camera.rotation.y = deg_to_rad(45.0)
	await _ticks(10)
	assert_eq(gazes, 0)
	await _ticks(10)
	assert_eq(gazes, 1, "corridor preset 50 degrees / 0.3 seconds")
	detector.reset()
	detector.max_angle_degrees = 25.0
	detector.hold_seconds = 1.0
	camera.rotation.y = deg_to_rad(20.0)
	await _ticks(30)
	assert_eq(gazes, 1)
	await _ticks(32)
	assert_eq(gazes, 2, "mirror preset 25 degrees / 1 second")
