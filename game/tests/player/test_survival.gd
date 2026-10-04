extends TestCase

const PlayerScript = preload("res://scripts/player/player.gd")
const PhoneScript = preload("res://scripts/player/phone_item.gd")
const PuzzleScript = preload("res://scripts/interaction/puzzle_station.gd")
const PLAYER: PackedScene = preload("res://scenes/player/player.tscn")
const BUNK: PackedScene = preload("res://scenes/interaction/bunk_spot.tscn")
const HIDE: PackedScene = preload("res://scenes/interaction/hide_spot.tscn")
const PUZZLE: PackedScene = preload("res://scenes/interaction/puzzle_station.tscn")

var world: Node3D
var player: PlayerScript
var phone: PhoneScript
var noises: Array[Dictionary] = []
var hidden_events: Array[bool] = []
var breath_events: Array[bool] = []
var battery_events: Array[float] = []
var _previous_mouse: Input.MouseMode
var _previous_paused: bool


func before_each() -> void:
	_previous_mouse = Input.mouse_mode
	_previous_paused = tree.paused
	tree.paused = false
	GameState.reset()
	world = Node3D.new()
	tree.root.add_child(world)
	_box(Vector3(100, 0.2, 100), Vector3(0, -0.1, 0))
	player = PLAYER.instantiate()
	player.head_bob_enabled = false
	player.position.y = 0.02
	world.add_child(player)
	phone = player.get_node("Head/Camera3D/PhoneItem")
	phone.set_physics_process(false)
	EventBus.noise_emitted.connect(_on_noise)
	EventBus.player_hidden.connect(_on_hidden)
	EventBus.breath_held.connect(_on_breath)
	EventBus.phone_battery_changed.connect(_on_battery)
	await _ticks(3)


func after_each() -> void:
	tree.paused = false
	for action: String in ["move_forward", "sprint", "crouch", "hold_breath", "interact", "phone", "flashlight"]:
		Input.action_release(action)
	world.queue_free()
	await wait_frames(2)
	EventBus.noise_emitted.disconnect(_on_noise)
	EventBus.player_hidden.disconnect(_on_hidden)
	EventBus.breath_held.disconnect(_on_breath)
	EventBus.phone_battery_changed.disconnect(_on_battery)
	GameState.reset()
	Input.mouse_mode = _previous_mouse
	tree.paused = _previous_paused


func _ticks(count: int) -> void:
	for index: int in count:
		await tree.physics_frame
		await tree.process_frame


func _box(size: Vector3, position: Vector3) -> StaticBody3D:
	var body: StaticBody3D = StaticBody3D.new()
	var shape: BoxShape3D = BoxShape3D.new()
	shape.size = size
	var collision: CollisionShape3D = CollisionShape3D.new()
	collision.shape = shape
	body.add_child(collision)
	body.position = position
	world.add_child(body)
	return body


func _bunk(number: int = 3) -> HideSpot:
	var spot: HideSpot = BUNK.instantiate()
	spot.set("bed_number", number)
	spot.position = Vector3(2, 0, -2)
	world.add_child(spot)
	return spot


func _on_noise(position: Vector3, radius: float, source: StringName) -> void:
	noises.append({"position": position, "radius": radius, "source": source})


func _on_hidden(value: bool, _kind: StringName) -> void:
	hidden_events.append(value)


func _on_breath(value: bool) -> void:
	breath_events.append(value)


func _on_battery(value: float) -> void:
	battery_events.append(value)


func test_bunk_entry_exit_flags_occupancy_and_movement_lock() -> void:
	var spot: HideSpot = _bunk()
	var events: Array[String] = []
	spot.entered.connect(func() -> void: events.append("entered"))
	spot.exited.connect(func() -> void: events.append("exited"))
	assert_true(player.lie_on(spot))
	assert_true(spot.is_occupied())
	assert_eq(spot.kind, &"bunk")
	assert_eq(GameState.get_flag(&"player_bed"), 3)
	assert_eq(player.camera.global_position, spot.get_node("View").global_position)
	assert_false(player.lie_on(spot), "cannot enter an occupied spot twice")
	Input.action_press("move_forward")
	Input.action_press("sprint")
	var position: Vector3 = player.position
	await _ticks(10)
	assert_eq(player.position, position)
	assert_eq(player.velocity, Vector3.ZERO)
	Input.action_press("interact")
	await _ticks(1)
	Input.action_release("interact")
	Input.action_release("move_forward")
	Input.action_release("sprint")
	assert_false(spot.is_occupied())
	assert_false(player.is_hidden())
	assert_eq(GameState.get_flag(&"player_bed"), 0)
	assert_eq(hidden_events, [true, false])
	assert_eq(events, ["entered", "exited"])
	assert_true(player.position.distance_to(spot.get_node("Exit").global_position) < 0.05)
	assert_eq(noises.back().source, &"move")
	assert_eq(noises.back().radius, 2.0)


func test_upper_bunks_climb_pause_and_cancel_cleanly() -> void:
	for number: int in [1, 4]:
		var spot: HideSpot = _bunk(number)
		var start: Vector3 = player.position
		assert_true(player.lie_on(spot))
		assert_eq(GameState.get_flag(&"player_bed"), number)
		await _ticks(6)
		assert_true(player.position != start, "short climb progresses")
		assert_true(player.camera.global_position.distance_to(spot.get_node("View").global_position) > 0.01)
		tree.paused = true
		var paused_position: Vector3 = player.position
		await tree.create_timer(0.1, true).timeout
		assert_eq(player.position, paused_position)
		tree.paused = false
		await _ticks(36)
		assert_true(player.camera.global_position.distance_to(spot.get_node("View").global_position) < 0.01)
		spot.pull_out()
	assert_true(player.lie_on(_bunk(1)))
	player.leave_hide_spot()
	var exit_position: Vector3 = player.position
	await _ticks(36)
	assert_true(player.position.distance_to(exit_position) < 0.05, "cancelled tween cannot move the player later")


func test_hidden_head_limits_and_fast_turn_noise() -> void:
	player.lie_on(_bunk())
	player.set_physics_process(false)
	player.mouse_sensitivity = 0.002
	var motion: InputEventMouseMotion = InputEventMouseMotion.new()
	motion.relative = Vector2(2, 0)
	player._unhandled_input(motion)
	player._physics_process(1.0 / 60.0)
	assert_true(noises.is_empty(), "slow look stays quiet")
	motion.relative = Vector2(2000, -2000)
	player._unhandled_input(motion)
	player._physics_process(1.0 / 60.0)
	assert_true(is_equal_approx(rad_to_deg(player.head.rotation.y), -70.0))
	assert_true(is_equal_approx(rad_to_deg(player.head.rotation.x), 40.0))
	assert_eq(noises.size(), 1)
	assert_eq(noises[0].radius, 2.0)
	assert_eq(noises[0].source, &"move")
	motion.relative = Vector2(-4000, 4000)
	player._unhandled_input(motion)
	assert_true(is_equal_approx(rad_to_deg(player.head.rotation.y), 70.0))
	assert_true(is_equal_approx(rad_to_deg(player.head.rotation.x), -10.0))


func test_breath_eight_seconds_forced_gasp_four_second_recovery() -> void:
	player.lie_on(_bunk())
	player.set_physics_process(false)
	Input.action_press("hold_breath")
	player._physics_process(7.99)
	assert_true(player.holding_breath)
	assert_true(noises.is_empty())
	player._physics_process(0.02)
	assert_false(player.holding_breath)
	assert_eq(breath_events, [true, false])
	assert_eq(noises.size(), 1)
	assert_eq(noises[0].radius, 4.0)
	assert_eq(noises[0].source, &"breath")
	player._physics_process(3.9)
	assert_false(player.holding_breath, "held key cannot bypass recovery")
	assert_eq(noises.back().radius, 1.5, "ordinary breath continues during recovery")
	player._physics_process(0.11)
	assert_true(player.holding_breath)
	player.leave_hide_spot()
	assert_false(player.holding_breath)
	assert_eq(breath_events, [true, false, true, false])


func test_regular_breath_and_pause_do_not_advance_survival_timers() -> void:
	player.lie_on(_bunk())
	player.set_physics_process(false)
	player._physics_process(2.9)
	assert_true(noises.is_empty())
	player._physics_process(0.11)
	assert_eq(noises.back().radius, 1.5)
	Input.action_press("hold_breath")
	player._physics_process(1.0)
	player.set_physics_process(true)
	tree.paused = true
	var held: float = player._hold_elapsed
	await tree.create_timer(0.12, true).timeout
	assert_eq(player._hold_elapsed, held)
	tree.paused = false
	Input.action_release("hold_breath")
	await _ticks(2)
	assert_false(player.holding_breath)


func test_generic_hiding_pull_out_and_removed_spot_release_player() -> void:
	for kind: StringName in [&"bed", &"locker", &"stall"]:
		var spot: HideSpot = HIDE.instantiate()
		spot.kind = kind
		world.add_child(spot)
		spot.interact(player)
		assert_true(spot.is_occupied())
		assert_eq(GameState.get_flag(&"player_bed"), 0)
		spot.pull_out()
		assert_false(spot.is_occupied())
		spot.interact(player)
		spot.queue_free()
		await _ticks(2)
		assert_false(player.is_hidden(), "removing a spot cannot trap the player")
		assert_false(player.body_shape.disabled)
	var invalid: HideSpot = HIDE.instantiate()
	invalid.view = ^"Missing"
	world.add_child(invalid)
	assert_false(invalid.enter(player))


func test_crouch_speed_and_headroom_gate() -> void:
	Input.action_press("sprint")
	Input.action_press("move_forward")
	await _ticks(30)
	Input.action_press("crouch")
	await _ticks(1)
	assert_true(Vector2(player.velocity.x, player.velocity.z).length() <= 1.201, "crouching immediately caps sprint speed")
	await _ticks(30)
	assert_true(player.crouched)
	assert_true(is_equal_approx(player.head.position.y, 1.0))
	assert_true(Vector2(player.velocity.x, player.velocity.z).length() <= 1.201)
	Input.action_release("move_forward")
	await _ticks(15)
	var ceiling: StaticBody3D = _box(Vector3(3, 0.2, 3), player.position + Vector3.UP * 1.45)
	await _ticks(2)
	Input.action_release("crouch")
	await _ticks(3)
	assert_true(player.crouched, "low ceiling prevents standing")
	assert_true(is_equal_approx((player.body_shape.shape as CapsuleShape3D).height, 1.15))
	ceiling.queue_free()
	await _ticks(3)
	assert_false(player.crouched)
	assert_true(is_equal_approx(player.head.position.y, 1.6))


func test_step_noise_radii_follow_actual_walk_run_and_crouch_steps() -> void:
	Input.action_press("move_forward")
	for mode: int in 3:
		if mode == 1:
			Input.action_press("sprint")
		elif mode == 2:
			Input.action_press("crouch")
		await _ticks(20)
		noises.clear()
		await _ticks(100)
		assert_false(noises.is_empty())
		var expected: float = [5.0, 12.0, 1.5][mode]
		for noise: Dictionary in noises:
			assert_eq(noise.radius, expected)
			assert_eq(noise.source, &"step")
			assert_true(noise.position is Vector3)
	player.make_noise(6.0, &"drop")
	assert_eq(noises.back().radius, 6.0)
	assert_eq(noises.back().position, player.global_position)


func test_phone_battery_drain_charge_empty_and_integer_notifications() -> void:
	var emptied: Array[bool] = []
	phone.battery_empty.connect(func() -> void: emptied.append(true))
	phone.set_battery(10.0)
	phone.set_flashlight(true)
	phone.set_in_call(true)
	phone._physics_process(4.0)
	assert_true(is_equal_approx(phone.battery, 9.0))
	assert_eq(battery_events, [10.0, 9.0])
	phone.charge(1.0)
	phone._physics_process(4.0)
	assert_true(is_equal_approx(phone.battery, 12.0))
	phone.charge(0.0)
	phone.set_battery(0.1)
	phone._physics_process(1.0)
	assert_eq(phone.battery, 0.0)
	assert_false(phone.flashlight.visible)
	assert_eq(emptied.size(), 1)
	phone.set_flashlight(true)
	phone._physics_process(1.0)
	assert_false(phone.flashlight.visible)
	assert_eq(emptied.size(), 1, "empty edge only fires once")
	phone.charge(2.0)
	phone._physics_process(1.0)
	assert_true(phone.battery > 0.0)
	assert_false(phone.flashlight.visible, "charging does not silently switch light back on")
	phone.set_battery(0.0)
	assert_eq(emptied.size(), 2)
	phone.set_battery(200.0)
	assert_eq(phone.battery, 100.0)
	phone.set_battery(-2.0)
	assert_eq(phone.battery, 0.0)


func test_phone_q_f_model_camera_parent_pause_and_call_only_drain() -> void:
	var raised: Array[bool] = []
	var lights: Array[bool] = []
	var on_raise: Callable = func(value: bool) -> void: raised.append(value)
	var on_light: Callable = func(value: bool) -> void: lights.append(value)
	EventBus.phone_raised.connect(on_raise)
	EventBus.flashlight_toggled.connect(on_light)
	var event: InputEventAction = InputEventAction.new()
	event.pressed = true
	event.action = &"phone"
	phone._unhandled_input(event)
	assert_true(phone.model.visible)
	assert_eq(raised, [true])
	event.action = &"flashlight"
	phone._unhandled_input(event)
	assert_eq(lights, [true])
	assert_eq(phone.get_parent(), player.camera)
	assert_eq(phone.flashlight.spot_range, 12.0)
	phone.set_physics_process(true)
	tree.paused = true
	var battery: float = phone.battery
	await tree.create_timer(0.12, true).timeout
	assert_eq(phone.battery, battery)
	tree.paused = false
	phone.set_physics_process(false)
	phone.set_flashlight(false)
	phone.set_in_call(true)
	phone._physics_process(10.0)
	assert_true(is_equal_approx(phone.battery, battery - 0.5))
	phone.set_in_call(false)
	phone._physics_process(10.0)
	assert_true(is_equal_approx(phone.battery, battery - 0.5))
	EventBus.phone_raised.disconnect(on_raise)
	EventBus.flashlight_toggled.disconnect(on_light)


func test_puzzle_locks_player_matches_id_closes_and_solves_once() -> void:
	var station: PuzzleScript = PUZZLE.instantiate()
	station.puzzle_id = &"locker_combo_601"
	world.add_child(station)
	var opened: Array[StringName] = []
	var solved_events: Array[bool] = []
	var on_open: Callable = func(id: StringName) -> void: opened.append(id)
	EventBus.puzzle_opened.connect(on_open)
	station.solved.connect(func() -> void: solved_events.append(true))
	station.interact(player)
	station.interact(player)
	assert_eq(opened, [&"locker_combo_601"])
	assert_true(player.controls_locked())
	assert_false(player._mouse_captured)
	var event: InputEventAction = InputEventAction.new()
	event.action = &"phone"
	event.pressed = true
	phone._unhandled_input(event)
	assert_false(phone.raised, "puzzle lock also prevents phone shortcuts")
	var motion: InputEventMouseMotion = InputEventMouseMotion.new()
	motion.relative = Vector2(100, 100)
	var rotation: Vector3 = player.rotation
	player._unhandled_input(motion)
	assert_eq(player.rotation, rotation)
	var position: Vector3 = player.position
	Input.action_press("move_forward")
	await _ticks(10)
	assert_eq(player.position, position)
	EventBus.puzzle_closed.emit(&"other")
	assert_true(player.controls_locked())
	EventBus.puzzle_closed.emit(station.puzzle_id)
	assert_false(player.controls_locked())
	assert_true(player._mouse_captured)
	station.interact(player)
	EventBus.puzzle_solved.emit(station.puzzle_id)
	assert_true(station.is_solved)
	assert_false(player.controls_locked())
	station.interact(player)
	EventBus.puzzle_solved.emit(station.puzzle_id)
	assert_eq(opened.size(), 2)
	assert_eq(solved_events.size(), 1)
	EventBus.puzzle_opened.disconnect(on_open)


func test_puzzle_invalid_data_and_freeing_station_preserve_controls() -> void:
	var station: PuzzleScript = PUZZLE.instantiate()
	world.add_child(station)
	station.interact(player)
	assert_false(player.controls_locked())
	station.puzzle_id = &"locker_combo_601"
	station.interact(player)
	tree.paused = true
	EventBus.game_paused.emit(true)
	EventBus.puzzle_closed.emit(station.puzzle_id)
	assert_false(player._mouse_captured, "closing puzzle under pause does not recapture mouse")
	tree.paused = false
	EventBus.game_paused.emit(false)
	station.interact(player)
	station.queue_free()
	await _ticks(2)
	assert_false(player.controls_locked())
	assert_true(player._mouse_captured)


func test_switch_and_latch_emit_noise_at_the_object() -> void:
	var light: OmniLight3D = OmniLight3D.new()
	world.add_child(light)
	var light_switch: Interactable = load("res://scenes/interaction/light_switch.tscn").instantiate()
	light_switch.set("light", light)
	light_switch.position = Vector3(3, 1, 0)
	world.add_child(light_switch)
	light_switch.interact(player)
	assert_eq(noises.back().radius, 2.0)
	assert_eq(noises.back().position, light_switch.global_position)
	var door: Interactable = Interactable.new()
	world.add_child(door)
	var latch: Interactable = load("res://scenes/interaction/door_latch.tscn").instantiate()
	latch.set("door", door)
	latch.position = Vector3(-3, 1, 0)
	world.add_child(latch)
	latch.interact(player)
	assert_eq(noises.back().radius, 3.0)
	assert_eq(noises.back().position, latch.global_position)
	assert_eq(noises.size(), 2)
	latch.enabled = false
	latch.interact(player)
	assert_eq(noises.size(), 2, "disabled objects are quiet")


func test_survival_fixture_has_four_numbered_bunks_and_puzzle() -> void:
	var fixture: Node3D = load("res://scenes/player/survival_test.tscn").instantiate()
	world.add_child(fixture)
	for number: int in range(1, 5):
		var spot: HideSpot = fixture.get_node("Bunk%d" % number)
		assert_eq(spot.bed_id(), number)
		assert_not_null(spot.get_node_or_null(spot.view))
		assert_not_null(spot.get_node_or_null(spot.exit))
	assert_not_null(fixture.get_node("PuzzleStation"))
	assert_not_null(fixture.get_node("LockerHide"))
