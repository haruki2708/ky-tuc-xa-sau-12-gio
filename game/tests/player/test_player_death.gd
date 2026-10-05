extends TestCase

const PlayerScript = preload("res://scripts/player/player.gd")
const PLAYER: PackedScene = preload("res://scenes/player/player.tscn")

var world: Node3D
var player: PlayerScript
var completions: Array[bool] = []
var previous_mouse: Input.MouseMode
var settings_existed: bool
var settings_bytes: PackedByteArray


func before_each() -> void:
	previous_mouse = Input.mouse_mode
	settings_existed = FileAccess.file_exists("user://settings.cfg")
	if settings_existed:
		settings_bytes = FileAccess.get_file_as_bytes("user://settings.cfg")
	var config: ConfigFile = ConfigFile.new()
	config.set_value("accessibility", "reduce_scares", false)
	config.save("user://settings.cfg")
	world = Node3D.new()
	tree.root.add_child(world)
	var floor_body: StaticBody3D = StaticBody3D.new()
	var shape: BoxShape3D = BoxShape3D.new()
	shape.size = Vector3(20, 0.2, 20)
	var collision: CollisionShape3D = CollisionShape3D.new()
	collision.shape = shape
	floor_body.add_child(collision)
	floor_body.position.y = -0.1
	world.add_child(floor_body)
	player = PLAYER.instantiate()
	player.position.y = 0.02
	world.add_child(player)
	player.death_animation_finished.connect(func() -> void: completions.append(true))
	await tree.physics_frame
	await tree.process_frame


func after_each() -> void:
	tree.paused = false
	for action: String in ["move_forward", "hold_breath", "interact"]:
		Input.action_release(action)
	world.queue_free()
	await wait_frames(2)
	if settings_existed:
		var file: FileAccess = FileAccess.open("user://settings.cfg", FileAccess.WRITE)
		file.store_buffer(settings_bytes)
		file.close()
	else:
		DirAccess.remove_absolute("user://settings.cfg")
	Input.mouse_mode = previous_mouse
	GameState.reset()


func _finish() -> void:
	player.death_animation.set_physics_process(false)
	for index: int in 181:
		player.death_animation._physics_process(1.0 / 60.0)


func _assert_locked() -> void:
	assert_true(player.controls_locked())
	var start: Transform3D = player.global_transform
	var head_rotation: Vector3 = player.head.rotation
	var mouse: InputEventMouseMotion = InputEventMouseMotion.new()
	mouse.relative = Vector2(1000, 1000)
	player._unhandled_input(mouse)
	Input.action_press("move_forward")
	Input.action_press("interact")
	player._physics_process(1.0)
	assert_eq(player.global_transform, start)
	assert_eq(player.head.rotation, head_rotation)
	assert_eq(player.velocity, Vector3.ZERO)


func test_fall_back_locks_controls_hits_floor_and_looks_up_once() -> void:
	EventBus.player_death_started.emit(&"fall_back")
	_assert_locked()
	assert_true(player.death_animation.blood.emitting)
	_finish()
	assert_eq(completions.size(), 1)
	assert_true(player.camera.global_position.y >= 0.1)
	assert_true(player.camera.global_position.y < 0.2)
	assert_true((-player.camera.global_basis.z).dot(Vector3.UP) > 0.99)
	EventBus.player_death_started.emit(&"manager_kill")
	player.death_animation._physics_process(10)
	assert_eq(player.death_animation.kind, &"fall_back")
	assert_eq(completions.size(), 1)
	assert_true(player.controls_locked(), "death keeps controls locked until scene replacement")


func test_ch2_corpse_faces_nearest_head_then_falls_with_blood() -> void:
	for position: Vector3 in [Vector3(-4, 0, -4), Vector3(1, 0, -2)]:
		var corpse: Node3D = Node3D.new()
		world.add_child(corpse)
		corpse.position = position
		corpse.add_to_group(&"ch2_corpse")
		var head: Marker3D = Marker3D.new()
		head.name = "GazeTarget"
		head.position.y = 1.4
		corpse.add_child(head)
	EventBus.player_death_started.emit(&"corpse_lunge")
	_assert_locked()
	player.death_animation.set_physics_process(false)
	player.death_animation._physics_process(0.4)
	var to_head: Vector3 = (Vector3(1, 1.4, -2) - player.camera.global_position).normalized()
	assert_true((-player.camera.global_basis.z).dot(to_head) > 0.99)
	assert_eq(player.death_animation._bursts, 0)
	player.death_animation._physics_process(0.4)
	assert_true(player.death_animation.blood.emitting)
	_finish()
	assert_eq(completions.size(), 1)
	assert_true(player.camera.global_position.y < 0.2)
	assert_true((-player.camera.global_basis.z).dot(Vector3.UP) > 0.99)


func test_ch2_corpse_reduced_skips_face_and_blood_without_target() -> void:
	player.death_animation.reduced = true
	EventBus.player_death_started.emit(&"corpse_lunge")
	player.death_animation.set_physics_process(false)
	player.death_animation._physics_process(0.4)
	assert_true((-player.camera.global_basis.z).dot(Vector3.UP) > 0.99)
	_finish()
	assert_eq(completions.size(), 1)
	assert_eq(player.death_animation._bursts, 0)
	assert_false(player.death_animation.blood.visible)


func test_ch2_corpse_freed_during_turn_still_completes() -> void:
	var corpse: Node3D = Node3D.new()
	world.add_child(corpse)
	corpse.position = Vector3(1, 1.4, -2)
	corpse.add_to_group(&"ch2_corpse")
	EventBus.player_death_started.emit(&"corpse_lunge")
	player.death_animation.set_physics_process(false)
	player.death_animation._physics_process(0.3)
	corpse.queue_free()
	await wait_frames(2)
	_finish()
	assert_eq(completions.size(), 1)


func test_ch2_scald_looks_down_slumps_without_blood_and_finishes_once() -> void:
	EventBus.player_death_started.emit(&"scald")
	_assert_locked()
	player.death_animation.set_physics_process(false)
	player.death_animation._physics_process(1.0)
	assert_true((-player.camera.global_basis.z).dot(Vector3.DOWN) > 0.7)
	assert_false(player.death_animation.blood.visible)
	assert_eq(player.death_animation._bursts, 0)
	_finish()
	assert_eq(completions.size(), 1)
	assert_true(player.camera.global_position.y < 0.2)
	assert_true((-player.camera.global_basis.z).dot(Vector3.DOWN) > 0.8)
	player.death_animation._physics_process(5)
	assert_eq(completions.size(), 1)


func test_ch2_reduced_scald_pauses_and_has_no_contraction_shake() -> void:
	player.death_animation.reduced = true
	EventBus.player_death_started.emit(&"scald")
	tree.paused = true
	var elapsed: float = player.death_animation.elapsed
	await tree.create_timer(0.08, true).timeout
	assert_eq(player.death_animation.elapsed, elapsed)
	tree.paused = false
	_finish()
	assert_false(player.death_animation.blood.visible)
	assert_eq(player.death_animation._bursts, 0)
	assert_eq(completions.size(), 1)


func test_manager_camera_faces_actor_then_falls_sideways() -> void:
	var manager: Node3D = Node3D.new()
	world.add_child(manager)
	manager.position = Vector3(1, 0, -2)
	manager.add_to_group(&"dorm_manager")
	EventBus.player_death_started.emit(&"manager_kill")
	_assert_locked()
	player.death_animation.set_physics_process(false)
	player.death_animation._physics_process(0.4)
	var to_face: Vector3 = (manager.position + Vector3.UP * 1.7 - player.camera.global_position).normalized()
	assert_true((-player.camera.global_basis.z).dot(to_face) > 0.99)
	assert_false(player.death_animation.blood.emitting)
	player.death_animation._physics_process(0.41)
	assert_true(player.death_animation.blood.emitting)
	_finish()
	assert_eq(completions.size(), 1)
	assert_true(absf(player.camera.global_basis.x.dot(Vector3.DOWN)) > 0.95)
	assert_true(player.camera.global_position.y < 0.2)


func test_bed_burst_cancels_climb_and_finishes_on_bed() -> void:
	var bunk: HideSpot = load("res://scenes/interaction/bunk_spot.tscn").instantiate()
	bunk.set("bed_number", 1)
	world.add_child(bunk)
	player.lie_on(bunk)
	EventBus.player_death_started.emit(&"bed_burst")
	assert_false(player._climb.is_valid())
	_assert_locked()
	var start: Vector3 = player.camera.global_position
	_finish()
	assert_eq(completions.size(), 1)
	assert_true(player.camera.global_position.distance_to(start) < 0.2)
	assert_eq(player.death_animation._bursts, 3)
	assert_false(player.holding_breath)


func test_death_pause_live_reduced_setting_and_new_player_reset() -> void:
	EventBus.player_death_started.emit(&"fall_back")
	tree.paused = true
	var elapsed: float = player.death_animation.elapsed
	var pose: Transform3D = player.camera.global_transform
	await tree.create_timer(0.1, true).timeout
	assert_eq(player.death_animation.elapsed, elapsed)
	assert_eq(player.camera.global_transform, pose)
	var config: ConfigFile = ConfigFile.new()
	config.set_value("accessibility", "reduce_scares", true)
	config.save("user://settings.cfg")
	EventBus.settings_changed.emit("accessibility", "reduce_scares")
	assert_false(player.death_animation.blood.visible)
	assert_false(player.death_animation.blood.emitting)
	tree.paused = false
	_finish()
	player.queue_free()
	await wait_frames(2)
	player = PLAYER.instantiate()
	world.add_child(player)
	assert_false(player.death_animation.active)
	assert_false(player.controls_locked())
	assert_eq(player.camera.transform, Transform3D.IDENTITY)


func test_reduced_manager_skips_face_lock_and_blood_and_none_is_ignored() -> void:
	EventBus.player_death_started.emit(&"none")
	assert_false(player.controls_locked())
	assert_false(player.death_animation.active)
	var config: ConfigFile = ConfigFile.new()
	config.set_value("accessibility", "reduce_scares", true)
	config.save("user://settings.cfg")
	EventBus.settings_changed.emit("accessibility", "reduce_scares")
	EventBus.player_death_started.emit(&"manager_kill")
	player.death_animation.set_physics_process(false)
	player.death_animation._physics_process(0.4)
	assert_true((-player.camera.global_basis.z).dot(Vector3.UP) > 0.99, "looks away before a close face can fill the view")
	_finish()
	assert_false(player.death_animation.blood.visible)
	assert_false(player.death_animation.blood.emitting)
	assert_eq(player.death_animation._bursts, 0)
	assert_eq(completions.size(), 1)


func test_head_bob_settings_and_releasing_other_locks_cannot_reset_death_camera() -> void:
	player.acquire_control_lock(world)
	EventBus.player_death_started.emit(&"fall_back")
	_finish()
	var pose: Transform3D = player.camera.global_transform
	var config: ConfigFile = ConfigFile.new()
	config.set_value("video", "head_bob", false)
	config.save("user://settings.cfg")
	EventBus.settings_changed.emit("video", "head_bob")
	player.release_control_lock(world)
	assert_eq(player.camera.global_transform, pose)
	assert_true(player.controls_locked())


func test_falling_against_wall_reaches_floor_without_camera_clipping() -> void:
	var wall: StaticBody3D = StaticBody3D.new()
	var shape: BoxShape3D = BoxShape3D.new()
	shape.size = Vector3(4, 4, 0.1)
	var collision: CollisionShape3D = CollisionShape3D.new()
	collision.shape = shape
	wall.add_child(collision)
	wall.position = Vector3(0, 2, 0.3)
	world.add_child(wall)
	await tree.physics_frame
	await tree.process_frame
	EventBus.player_death_started.emit(&"fall_back")
	_finish()
	assert_true(player.camera.global_position.z < 0.16, "camera stops before wall")
	assert_true(player.camera.global_position.y < 0.2, "wall does not suspend the fall")
	assert_true(player.camera.global_position.y >= 0.1)
	assert_eq(completions.size(), 1)
