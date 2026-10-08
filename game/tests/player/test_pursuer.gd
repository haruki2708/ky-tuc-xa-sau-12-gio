extends TestCase

const SCENE: PackedScene = preload("res://scenes/entity/pursuer.tscn")
const SETTINGS_PATH: String = "user://settings.cfg"

var world: Node3D
var target: CharacterBody3D
var pursuer: Pursuer
var catches: int = 0
var escapes: int = 0
var _had_settings: bool
var _settings_backup: PackedByteArray
var _previous_paused: bool
var _previous_mouse_mode: Input.MouseMode


func before_each() -> void:
	_previous_paused = tree.paused
	_previous_mouse_mode = Input.mouse_mode
	tree.paused = false
	_had_settings = FileAccess.file_exists(SETTINGS_PATH)
	if _had_settings:
		_settings_backup = FileAccess.get_file_as_bytes(SETTINGS_PATH)
	assert_eq(ConfigFile.new().save(SETTINGS_PATH), OK)
	world = Node3D.new()
	tree.root.add_child(world)
	_wall(Vector3(200, 0.2, 60), Vector3(0, -0.1, 0))
	target = CharacterBody3D.new()
	target.collision_layer = 2
	target.collision_mask = 1
	var collision: CollisionShape3D = CollisionShape3D.new()
	var capsule: CapsuleShape3D = CapsuleShape3D.new()
	capsule.radius = 0.3
	capsule.height = 1.75
	collision.shape = capsule
	collision.position.y = 0.875
	target.add_child(collision)
	target.position = Vector3(4, 0, 0)
	world.add_child(target)
	pursuer = SCENE.instantiate()
	world.add_child(pursuer)
	pursuer.caught.connect(func() -> void: catches += 1)
	pursuer.escaped.connect(func() -> void: escapes += 1)


func after_each() -> void:
	tree.paused = false
	world.queue_free()
	await wait_frames(2)
	if _had_settings:
		var file: FileAccess = FileAccess.open(SETTINGS_PATH, FileAccess.WRITE)
		assert_not_null(file, "restore original settings")
		if file != null:
			file.store_buffer(_settings_backup)
			file.close()
	elif FileAccess.file_exists(SETTINGS_PATH):
		assert_eq(DirAccess.remove_absolute(SETTINGS_PATH), OK)
	tree.paused = _previous_paused
	Input.mouse_mode = _previous_mouse_mode


func _ticks(count: int) -> void:
	for index: int in count:
		await tree.physics_frame
		await tree.process_frame


func _wall(size: Vector3, position: Vector3) -> StaticBody3D:
	var wall: StaticBody3D = StaticBody3D.new()
	var shape: BoxShape3D = BoxShape3D.new()
	shape.size = size
	var collision: CollisionShape3D = CollisionShape3D.new()
	collision.shape = shape
	wall.add_child(collision)
	wall.position = position
	world.add_child(wall)
	return wall


func _safe_zone(position: Vector3) -> Area3D:
	var area: Area3D = Area3D.new()
	area.collision_layer = 8
	area.collision_mask = 2
	var shape: BoxShape3D = BoxShape3D.new()
	shape.size = Vector3(3, 3, 3)
	var collision: CollisionShape3D = CollisionShape3D.new()
	collision.shape = shape
	area.add_child(collision)
	area.position = position + Vector3.UP * 1.5
	area.add_to_group("safe_zone")
	world.add_child(area)
	return area


func _save_setting(value: Variant) -> void:
	var config: ConfigFile = ConfigFile.new()
	config.set_value("accessibility", "reduce_scares", value)
	assert_eq(config.save(SETTINGS_PATH), OK)


func test_chases_stationary_target_on_floor_and_catches_once() -> void:
	assert_false(pursuer.visible, "inactive until explicitly started")
	pursuer.start_chase(target, Vector3(0, 0.05, 0))
	await _ticks(20)
	assert_true(pursuer.position.x > 0.5, "moves towards target")
	assert_true(absf(pursuer.position.y) < 0.03, "feet stay on floor")
	await _ticks(100)
	assert_eq(catches, 1)
	assert_eq(escapes, 0)
	assert_false(pursuer.visible)
	var stopped: Vector3 = pursuer.position
	await _ticks(10)
	assert_eq(pursuer.position, stopped)
	assert_eq(catches, 1, "caught does not repeat")


func test_wall_prevents_movement_and_catching_through_it() -> void:
	_wall(Vector3(0.1, 3, 20), Vector3(0.5, 1.5, 0))
	target.position.x = 0.7
	pursuer.start_chase(target, Vector3(0, 0.02, 0))
	await _ticks(90)
	assert_eq(catches, 0, "thin wall blocks catch despite radius")
	assert_true(pursuer.position.x < 0.2, "body cannot cross wall")
	assert_eq(pursuer._previous_step, -1, "blocked movement does not play steps")


func test_blocked_direct_path_detours_along_corridor_x() -> void:
	_wall(Vector3(2, 3, 0.15), Vector3(0, 1.5, 0))
	target.position = Vector3(0, 0, -3)
	pursuer.start_chase(target, Vector3(0, 0.02, 1))
	await _ticks(45)
	assert_true(pursuer.position.x > 0.8, "goes along X to skirt obstruction")
	await _ticks(180)
	assert_eq(catches, 1, "can reach target around a finite obstacle")


func test_route_crosses_one_meter_doorway_then_catches_target() -> void:
	# Front wall at z=0, with a 1m opening centered on x=3.1.
	_wall(Vector3(5.6, 3, 0.2), Vector3(-0.2, 1.5, 0))
	_wall(Vector3(3.4, 3, 0.2), Vector3(5.3, 1.5, 0))
	_wall(Vector3(0.2, 3, 5), Vector3(-3, 1.5, -2.5))
	_wall(Vector3(0.2, 3, 5), Vector3(7, 1.5, -2.5))
	_wall(Vector3(10, 3, 0.2), Vector3(2, 1.5, -5))
	target.position = Vector3(-1, 0, 2)
	var route: PackedVector3Array = PackedVector3Array([Vector3(3.1, 0, -0.5), Vector3(3.1, 0, 0.6)])
	pursuer.start_chase(target, Vector3(0, 0.02, -3), route)
	route[0] = Vector3(-50, 0, -3)
	var crossed: bool = false
	for tick: int in 360:
		await _ticks(1)
		if absf(pursuer.position.z) < 0.1:
			crossed = true
			assert_true(absf(pursuer.position.x - 3.1) < 0.21, "capsule clears both door jambs")
		if catches > 0:
			break
	assert_true(crossed, "route passes through the door, not around the room")
	assert_eq(catches, 1, "leaves route and catches stationary target beyond doorway")
	assert_eq(escapes, 0)


func test_route_still_catches_and_prioritizes_safety_before_finishing() -> void:
	var route: PackedVector3Array = PackedVector3Array([Vector3(-20, 0, 0)])
	target.position = Vector3(0.5, 0, 0)
	pursuer.start_chase(target, Vector3.ZERO, route)
	await _ticks(2)
	assert_eq(catches, 1, "catch checked before unfinished route")
	_safe_zone(target.position)
	pursuer.give_up_seconds = 0.05
	await _ticks(2)
	pursuer.start_chase(target, Vector3.ZERO, route)
	await _ticks(10)
	assert_eq(catches, 1, "safe zone still takes priority over catch")
	assert_eq(escapes, 1, "unfinished route cannot defer escape")


func test_route_order_pause_stop_and_legacy_restart() -> void:
	target.position = Vector3(15, 0, 0)
	pursuer.start_chase(target, Vector3.ZERO, PackedVector3Array([
		Vector3.ZERO, Vector3.ZERO, Vector3(0, 10, -3), Vector3(3, 0, -3)]))
	await _ticks(20)
	assert_true(pursuer.position.z < -0.5, "visits first distinct point before second or target")
	assert_true(absf(pursuer.position.x) < 0.01, "route is XZ even if point height differs")
	var position: Vector3 = pursuer.position
	tree.paused = true
	await tree.create_timer(0.1, true).timeout
	assert_eq(pursuer.position, position)
	tree.paused = false
	pursuer.stop_chase()
	pursuer.start_chase(target, Vector3.ZERO)
	await _ticks(20)
	assert_true(pursuer.position.x > 0.5, "legacy restart discards previous waypoints")
	assert_true(absf(pursuer.position.z) < 0.01)


func test_route_does_not_cross_walls_when_waypoint_is_unreachable() -> void:
	_wall(Vector3(0.1, 3, 20), Vector3(0.5, 1.5, 0))
	target.position.x = 5.0
	pursuer.start_chase(target, Vector3.ZERO, PackedVector3Array([Vector3(3, 0, 0)]))
	await _ticks(60)
	assert_true(pursuer.position.x < 0.2)
	assert_eq(catches, 0)


func test_running_target_increases_gap_but_walking_is_caught() -> void:
	target.position = Vector3(3, 0, 0)
	pursuer.start_chase(target, Vector3(0, 0.02, 0))
	for tick: int in 120:
		target.position.x += 3.6 / Engine.physics_ticks_per_second
		await _ticks(1)
	assert_eq(catches, 0)
	assert_true(target.position.x - pursuer.position.x > 4.0, "sprint widens initial 3m gap")
	target.position = Vector3(2, 0, 0)
	pursuer.start_chase(target, Vector3(0, 0.02, 0))
	for tick: int in 180:
		target.position.x += 2.2 / Engine.physics_ticks_per_second
		await _ticks(1)
	assert_eq(catches, 1, "walking is slower than pursuer")


func test_safe_zone_has_priority_then_retreats_and_escapes() -> void:
	_safe_zone(target.position)
	pursuer.give_up_seconds = 0.5
	await _ticks(2)
	pursuer.start_chase(target, target.position - Vector3(0.4, 0, 0))
	await _ticks(3)
	assert_eq(catches, 0, "safe target inside catch radius cannot be caught")
	assert_eq(escapes, 0, "waits for give-up delay")
	var start_x: float = pursuer.position.x
	await _ticks(10)
	assert_true(pursuer.position.x < start_x, "retreats away from safe target")
	await _ticks(30)
	assert_eq(escapes, 1)
	assert_false(pursuer.visible)
	assert_false(pursuer.breath.playing)
	await _ticks(5)
	assert_eq(escapes, 1)


func test_entering_safe_zone_during_chase_and_plain_node_target() -> void:
	_safe_zone(Vector3(8, 0, 0))
	pursuer.give_up_seconds = 0.05
	pursuer.start_chase(target, Vector3.ZERO)
	await _ticks(10)
	target.position.x = 8.0
	await _ticks(10)
	assert_eq(escapes, 1, "entering zone ends existing chase")
	var marker: Node3D = Node3D.new()
	marker.position = Vector3(8, 0, 0)
	world.add_child(marker)
	pursuer.start_chase(marker, Vector3(7.6, 0, 0))
	await _ticks(10)
	assert_eq(escapes, 2, "plain Node3D target also supports safe zones")
	assert_eq(catches, 0)


func test_reduce_scares_changes_speed_live_and_validates_settings() -> void:
	target.position.x = 30.0
	pursuer.start_chase(target, Vector3(0, 0.02, 0))
	var first_frame: int = Engine.get_physics_frames()
	await _ticks(60)
	var normal_distance: float = pursuer.position.x
	# _ticks also yields to rendering; a busy frame can contain several physics
	# steps. Measure simulated time instead of assuming 60 waits mean one second.
	var normal_seconds: float = float(Engine.get_physics_frames() - first_frame) / Engine.physics_ticks_per_second
	var normal_speed: float = normal_distance / normal_seconds
	assert_true(absf(normal_speed - 2.9) < 0.1, "normal speed 2.9m/s, got %.3f over %.3fs" % [normal_speed, normal_seconds])
	_save_setting(true)
	var saved: PackedByteArray = FileAccess.get_file_as_bytes(SETTINGS_PATH)
	EventBus.settings_changed.emit("video", "reduce_scares")
	assert_false(pursuer._reduce_scares, "ignore wrong section")
	EventBus.settings_changed.emit("accessibility", "reduce_scares")
	pursuer.start_chase(target, Vector3(0, 0.02, 0))
	first_frame = Engine.get_physics_frames()
	await _ticks(60)
	var reduced_seconds: float = float(Engine.get_physics_frames() - first_frame) / Engine.physics_ticks_per_second
	var reduced_speed: float = pursuer.position.x / reduced_seconds
	assert_true(absf(reduced_speed / normal_speed - 0.85) < 0.02, "reduced speed multiplier, got %.3f over %.3fs" % [reduced_speed / normal_speed, reduced_seconds])
	assert_eq(FileAccess.get_file_as_bytes(SETTINGS_PATH), saved, "reader never writes settings")
	for value: Variant in ["true", 1, 0.0, []]:
		_save_setting(value)
		EventBus.settings_changed.emit("accessibility", "reduce_scares")
		assert_false(pursuer._reduce_scares, "invalid type defaults to false")
	_save_setting(true)
	var second: Pursuer = SCENE.instantiate()
	world.add_child(second)
	assert_true(second._reduce_scares, "setting loaded at ready")
	assert_eq(DirAccess.remove_absolute(SETTINGS_PATH), OK)
	EventBus.settings_changed.emit("accessibility", "reduce_scares")
	assert_false(second._reduce_scares, "missing file defaults to false")
	assert_false(FileAccess.file_exists(SETTINGS_PATH), "does not create settings")


func test_audio_distance_gain_variants_and_stop() -> void:
	pursuer.speed = 0.0
	target.position.x = 7.0
	pursuer.start_chase(target, Vector3(0, 0.02, 0))
	await _ticks(4)
	assert_false(pursuer.breath.playing, "no breath outside six meters")
	target.position.x = 5.0
	await _ticks(2)
	assert_true(pursuer.breath.playing)
	var distant_db: float = pursuer.breath.volume_db
	target.position.x = 2.0
	await _ticks(2)
	var close_db: float = pursuer.breath.volume_db
	assert_true(close_db > distant_db, "breath grows louder up close")
	_save_setting(true)
	EventBus.settings_changed.emit("accessibility", "reduce_scares")
	assert_true(is_equal_approx(pursuer.breath.volume_db, close_db - 6.0), "reduce_scares subtracts 6dB")
	assert_eq(pursuer.breath.bus, &"SFX")
	assert_true((pursuer.breath.stream as AudioStreamOggVorbis).loop, "breath loops")
	var last: AudioStream
	pursuer._rng.seed = 134
	for index: int in 20:
		pursuer._play_step()
		assert_true(pursuer.footsteps.stream != last, "rush variants never repeat consecutively")
		assert_true(Pursuer.RUSH_STEPS.has(pursuer.footsteps.stream), "uses T-131 bank")
		last = pursuer.footsteps.stream
	assert_eq(pursuer.footsteps.bus, &"SFX")
	pursuer.stop_chase()
	assert_false(pursuer.footsteps.playing)
	assert_false(pursuer.breath.playing)
	assert_false(pursuer.visible)
	assert_false(pursuer.is_physics_processing())


func test_steps_follow_actual_ground_movement() -> void:
	target.position.x = 30.0
	pursuer.start_chase(target, Vector3(0, 0.02, 0))
	await _ticks(10)
	assert_eq(pursuer._previous_step, -1, "less than a stride produces no step")
	await _ticks(25)
	assert_true(pursuer._previous_step >= 0, "moving a stride plays a rush step")
	pursuer.stop_chase()
	pursuer.start_chase(target, Vector3(0, 10, 0))
	pursuer._previous_step = -1
	await _ticks(20)
	assert_eq(pursuer._previous_step, -1, "airborne motion does not create steps")


func test_pause_freezes_chase_audio_and_escape_timer() -> void:
	pursuer.start_chase(target, Vector3.ZERO)
	await _ticks(25)
	var position: Vector3 = pursuer.position
	assert_true(pursuer.breath.playing)
	tree.paused = true
	await tree.create_timer(0.1, true).timeout
	assert_eq(pursuer.position, position, "paused pursuer does not move")
	assert_true(pursuer.breath.stream_paused, "paused breath does not advance")
	assert_true(pursuer.footsteps.stream_paused, "paused steps do not advance")
	tree.paused = false
	await _ticks(2)
	assert_true(pursuer.position.x > position.x, "chase resumes")
	_safe_zone(target.position)
	pursuer.give_up_seconds = 0.2
	await _ticks(3)
	var elapsed: float = pursuer._retreat_elapsed
	tree.paused = true
	await tree.create_timer(0.3, true).timeout
	assert_eq(pursuer._retreat_elapsed, elapsed, "pause freezes give-up timer")
	assert_eq(escapes, 0)
	tree.paused = false
	await _ticks(20)
	assert_eq(escapes, 1)


func test_stop_restart_and_deleted_target_cancel_pending_results() -> void:
	_safe_zone(target.position)
	pursuer.give_up_seconds = 0.1
	pursuer.start_chase(target, Vector3.ZERO)
	await _ticks(3)
	pursuer.stop_chase()
	await _ticks(12)
	assert_eq(escapes, 0, "stop cancels pending escape")
	target.position.x = -4.0
	pursuer.start_chase(target, Vector3(-8, 0.02, 0))
	assert_true(pursuer.visible)
	await _ticks(3)
	target.free()
	await _ticks(3)
	assert_false(pursuer.visible)
	assert_false(pursuer.breath.playing)
	assert_eq(catches, 0)
	assert_eq(escapes, 0)


func test_optional_visual_and_fixture_p_shortcut() -> void:
	var packed: PackedScene = PackedScene.new()
	var model: Node3D = Node3D.new()
	model.name = "TestSilhouette"
	assert_eq(packed.pack(model), OK)
	model.free()
	var custom: Pursuer = SCENE.instantiate()
	custom.body_scene = packed
	world.add_child(custom)
	assert_not_null(custom.visual.get_node_or_null("TestSilhouette"))
	assert_false(custom.visual.get_node("Fallback").visible)
	var fixture: Node3D = load("res://scenes/entity/pursuer_test.tscn").instantiate()
	world.add_child(fixture)
	var key: InputEventKey = InputEventKey.new()
	key.physical_keycode = KEY_P
	key.pressed = true
	fixture.call("_unhandled_key_input", key)
	var demo_pursuer: Pursuer = fixture.get_node("Pursuer")
	var demo_player: Node3D = fixture.get_node("Player")
	assert_true(demo_pursuer.visible)
	assert_true(is_equal_approx(demo_player.position.x - demo_pursuer.position.x, 5.0), "P spawns pursuer behind player")
	assert_true(fixture.get_node("SafeZone").is_in_group("safe_zone"))
