extends TestCase

const PLAYER_SCENE: PackedScene = preload("res://scenes/player/player.tscn")
const PlayerController = preload("res://scripts/player/player.gd")

class SpyInteractable extends Interactable:
	var calls: int = 0
	var last_player: Node

	func _on_interact(player: Node) -> void:
		calls += 1
		last_player = player

var world: Node3D
var player: PlayerController
var floor_body: StaticBody3D
var focus_events: Array[String] = []
var steps: Array[StringName] = []
var step_intensities: Array[float] = []
var step_positions: Array[Vector3] = []
var previous_mouse_mode: Input.MouseMode


func before_each() -> void:
	previous_mouse_mode = Input.mouse_mode
	world = Node3D.new()
	tree.root.add_child(world)
	floor_body = _body(Vector3(120, 0.2, 120), Vector3(0, -0.1, 0))
	player = PLAYER_SCENE.instantiate() as PlayerController
	player.position = Vector3(0, 0.5, 0)
	player.head_bob_enabled = false
	player._step_rng.seed = 122
	world.add_child(player)
	EventBus.interaction_focus_changed.connect(_record_focus)
	player.footstep.connect(_record_step)


func after_each() -> void:
	for action: String in ["move_forward", "move_back", "move_left", "move_right", "sprint", "interact", "pause"]:
		Input.action_release(action)
	EventBus.interaction_focus_changed.disconnect(_record_focus)
	world.queue_free()
	await wait_frames(2)
	Input.mouse_mode = previous_mouse_mode


func _record_focus(key: String) -> void:
	focus_events.append(key)


func _record_step(surface: StringName, intensity: float) -> void:
	steps.append(surface)
	step_intensities.append(intensity)
	step_positions.append(player.global_position)


func _ticks(count: int) -> void:
	for index: int in count:
		await tree.physics_frame
		await tree.process_frame


func _body(size: Vector3, position: Vector3) -> StaticBody3D:
	var body: StaticBody3D = StaticBody3D.new()
	var collision: CollisionShape3D = CollisionShape3D.new()
	var shape: BoxShape3D = BoxShape3D.new()
	shape.size = size
	collision.shape = shape
	body.add_child(collision)
	body.position = position
	world.add_child(body)
	return body


func _item(position: Vector3, key: String = "PROMPT_INTERACT") -> SpyInteractable:
	var item: SpyInteractable = SpyInteractable.new()
	var collision: CollisionShape3D = CollisionShape3D.new()
	var shape: BoxShape3D = BoxShape3D.new()
	shape.size = Vector3(0.4, 0.4, 0.4)
	collision.shape = shape
	item.add_child(collision)
	item.position = position
	item.prompt_key = key
	world.add_child(item)
	return item


func test_scene_configuration() -> void:
	assert_eq(player.collision_layer, 2)
	assert_eq(player.collision_mask, 1)
	var capsule: CapsuleShape3D = player.get_node("CollisionShape3D").shape as CapsuleShape3D
	assert_true(is_equal_approx(capsule.height, 1.75), "capsule height")
	assert_true(is_equal_approx(capsule.radius, 0.3), "capsule radius")
	assert_true(is_equal_approx(player.head.position.y, 1.6), "eye height")
	assert_true(is_equal_approx(player.camera.fov, 70.0), "FOV")
	assert_eq(player.interact_ray.target_position, Vector3(0, 0, -2))
	assert_eq(player.interact_ray.collision_mask, 5)
	assert_true(player.interact_ray.collide_with_areas and player.interact_ray.collide_with_bodies)


func test_falls_and_stands_on_floor() -> void:
	await _ticks(60)
	assert_true(player.is_on_floor(), "player must land")
	assert_true(absf(player.position.y) < 0.02, "capsule feet must rest on floor")
	var landed_y: float = player.position.y
	await _ticks(20)
	assert_true(absf(player.position.y - landed_y) < 0.001, "standing height stays stable")
	assert_eq(steps.size(), 0, "falling and standing do not emit steps")


func test_forward_sprint_and_deceleration() -> void:
	await _ticks(60)
	Input.action_press("move_forward")
	await _ticks(1)
	assert_true(player.velocity.z < 0.0 and player.velocity.z > -2.2, "smooth acceleration")
	await _ticks(30)
	assert_true(player.position.z < -0.5, "forward moves toward -Z")
	assert_true(is_equal_approx(player.velocity.z, -2.2), "walk speed")
	Input.action_press("sprint")
	await _ticks(30)
	assert_true(is_equal_approx(player.velocity.z, -3.6), "sprint speed")
	Input.action_release("move_forward")
	await _ticks(1)
	assert_true(player.velocity.z < 0.0 and player.velocity.z > -3.6, "smooth deceleration")
	await _ticks(30)
	assert_true(absf(player.velocity.z) < 0.001, "stops without drift")


func test_diagonal_speed_and_heading() -> void:
	await _ticks(60)
	Input.action_press("move_forward")
	Input.action_press("move_right")
	await _ticks(30)
	assert_true(is_equal_approx(Vector2(player.velocity.x, player.velocity.z).length(), 2.2), "no diagonal speed boost")
	Input.action_release("move_right")
	player.rotation.y = PI / 2.0
	await _ticks(30)
	assert_true(player.velocity.x < -2.19 and absf(player.velocity.z) < 0.01, "movement follows yaw")


func test_focus_changes_only_once_and_clears_on_turn() -> void:
	await _ticks(60)
	_item(Vector3(0, 1.6, -1.5))
	await _ticks(10)
	assert_eq(focus_events, ["PROMPT_INTERACT"], "unchanged focus emits once")
	player.rotation.y = PI
	await _ticks(10)
	assert_eq(focus_events, ["PROMPT_INTERACT", ""], "looking away clears once")


func test_focus_clears_when_target_deleted() -> void:
	await _ticks(60)
	var item: SpyInteractable = _item(Vector3(0, 1.6, -1.5))
	await _ticks(3)
	item.queue_free()
	await _ticks(5)
	Input.action_press("interact")
	await _ticks(2)
	assert_eq(focus_events, ["PROMPT_INTERACT", ""], "deleted target clears safely")


func test_disabled_target_and_range() -> void:
	await _ticks(60)
	var item: SpyInteractable = _item(Vector3(0, 1.6, -1.5))
	item.enabled = false
	await _ticks(3)
	Input.action_press("interact")
	await _ticks(2)
	Input.action_release("interact")
	assert_eq(focus_events.size(), 0, "disabled item has no focus")
	assert_eq(item.calls, 0, "disabled item cannot be used")
	item.enabled = true
	await _ticks(3)
	item.enabled = false
	await _ticks(3)
	assert_eq(focus_events, ["PROMPT_INTERACT", ""], "disabling clears existing focus")
	item.position.z = -2.3
	item.enabled = true
	await _ticks(3)
	assert_eq(focus_events.size(), 2, "item outside two meters has no focus")


func test_switching_targets_with_same_prompt_emits() -> void:
	await _ticks(60)
	var first: SpyInteractable = _item(Vector3(0, 1.6, -1.5))
	var second: SpyInteractable = _item(Vector3(1, 1.6, -1.5))
	await _ticks(3)
	first.position.x = -1.0
	second.position.x = 0.0
	await _ticks(3)
	assert_eq(focus_events, ["PROMPT_INTERACT", "PROMPT_INTERACT"], "identity changes even with same key")


func test_wall_blocks_focus_and_movement() -> void:
	await _ticks(60)
	var item: SpyInteractable = _item(Vector3(0, 1.6, -1.5))
	await _ticks(3)
	_body(Vector3(5, 3, 0.2), Vector3(0, 1.5, -0.8))
	await _ticks(3)
	assert_eq(focus_events, ["PROMPT_INTERACT", ""], "world body occludes interactable")
	Input.action_press("interact")
	Input.action_press("move_forward")
	await _ticks(90)
	assert_eq(item.calls, 0, "cannot interact through wall")
	assert_true(player.position.z > -0.5, "capsule cannot pass through wall")
	assert_eq(steps.size(), 0, "pressing into wall does not create footsteps")


func test_interact_calls_focused_target_once_per_press() -> void:
	await _ticks(60)
	var item: SpyInteractable = _item(Vector3(0, 1.6, -1.5))
	await _ticks(3)
	Input.action_press("interact")
	await _ticks(10)
	assert_eq(item.calls, 1, "holding action must not repeat")
	assert_eq(item.last_player, player, "player passed to interact")
	Input.action_release("interact")
	await _ticks(2)
	Input.action_press("interact")
	await _ticks(3)
	assert_eq(item.calls, 2, "next press interacts again")


func test_footsteps_follow_distance_and_surface() -> void:
	await _ticks(60)
	floor_body.set_meta("surface", &"wood")
	var start: Vector3 = player.position
	Input.action_press("move_forward")
	await _ticks(70)
	var distance: float = Vector2(player.position.x - start.x, player.position.z - start.z).length()
	assert_true(steps.size() >= int(floorf(distance / (1.1 * 1.06))), "walk steps within longest stride bound")
	assert_true(steps.size() <= int(floorf(distance / (1.1 * 0.94))), "walk steps within shortest stride bound")
	assert_true(steps.size() > 0, "walking produces steps")
	for surface: StringName in steps:
		assert_eq(surface, &"wood", "surface metadata")
	floor_body.remove_meta("surface")
	steps.clear()
	await _ticks(40)
	assert_true(steps.size() > 0, "walking continues")
	for surface: StringName in steps:
		assert_eq(surface, &"concrete", "default surface")


func test_no_airborne_footsteps_and_bob_can_be_disabled() -> void:
	await _ticks(60)
	player.head_bob_enabled = true
	Input.action_press("move_forward")
	await _ticks(20)
	assert_true(absf(player.camera.position.y) > 0.0001, "walking bobs camera")
	assert_true(absf(player.camera.position.y) <= player.head_bob_amplitude, "bob amplitude bounded")
	player.head_bob_enabled = false
	await _ticks(2)
	assert_eq(player.camera.position.y, 0.0, "disabling bob restores camera")
	player.position.y = 10.0
	await _ticks(2)
	steps.clear()
	await _ticks(30)
	assert_false(player.is_on_floor(), "still airborne")
	assert_eq(steps.size(), 0, "air movement does not produce steps")


func test_steady_walk_five_seconds_cadence_and_intensity() -> void:
	await _ticks(60)
	Input.action_press("move_forward")
	await _ticks(30)
	steps.clear()
	step_intensities.clear()
	await _ticks(5 * Engine.physics_ticks_per_second)
	assert_true(steps.size() >= 9 and steps.size() <= 11, "five seconds walking: 9-11 steps, got %d" % steps.size())
	for intensity: float in step_intensities:
		assert_true(absf(intensity - 2.2 / 3.6) < 0.001, "walking intensity approximately 0.61, below sprint")
		assert_true(intensity >= 0.0 and intensity <= 1.0, "intensity bounded")


func test_steady_sprint_five_seconds_cadence_and_intensity() -> void:
	await _ticks(60)
	Input.action_press("move_forward")
	Input.action_press("sprint")
	await _ticks(30)
	steps.clear()
	step_intensities.clear()
	await _ticks(5 * Engine.physics_ticks_per_second)
	assert_true(steps.size() >= 12 and steps.size() <= 14, "five seconds sprinting: 12-14 steps, got %d" % steps.size())
	for intensity: float in step_intensities:
		assert_true(is_equal_approx(intensity, 1.0), "sprint intensity is 1, above walking")
		assert_true(intensity >= 0.0 and intensity <= 1.0, "intensity bounded")


func _simulate_ground_distance(speed: float, distance: float) -> void:
	# Fine distance increments remove 60 Hz quantization from stride-bound checks.
	# The existing grounded body supplies the same surface query as normal physics.
	player.velocity = Vector3(speed, 0, 0)
	for index: int in int(roundf(distance / 0.001)):
		var previous: Vector3 = player.global_position
		player.position.x += 0.001
		player._update_steps_and_bob(previous, true, 0.001 / speed)


func test_stride_jitter_stays_within_six_percent_at_walk_and_sprint() -> void:
	await _ticks(60)
	player.set_physics_process(false)
	for speed: float in [2.2, 3.6]:
		player.position.x = 0.0
		player._step_progress = 0.0
		player._step_rng.seed = 122
		player._step_scale = player._next_step_scale()
		step_positions.clear()
		_simulate_ground_distance(speed, 20.0)
		assert_true(step_positions.size() >= 12, "enough strides to measure variation")
		var base_length: float = 1.1 if speed == 2.2 else 1.4
		var previous_x: float = 0.0
		var shortest: float = INF
		var longest: float = 0.0
		for position: Vector3 in step_positions:
			var stride: float = position.x - previous_x
			previous_x = position.x
			assert_true(stride >= base_length * 0.94 - 0.002, "stride lower bound, 2 mm sampling tolerance")
			assert_true(stride <= base_length * 1.06 + 0.002, "stride upper bound, 2 mm sampling tolerance")
			shortest = minf(shortest, stride)
			longest = maxf(longest, stride)
		assert_true(longest - shortest > 0.02, "successive strides are not identical")


func test_stride_interpolates_during_speed_changes_and_honors_exports() -> void:
	await _ticks(60)
	player.set_physics_process(false)
	player.step_length_variation = 0.0
	player._step_scale = 1.0
	for speed: float in [2.2, 2.9, 3.6, 2.9, 2.2]:
		player.position.x = 0.0
		player._step_progress = 0.0
		step_positions.clear()
		_simulate_ground_distance(speed, 3.0)
		var expected: float = 1.25
		if speed == 2.2:
			expected = 1.1
		elif speed == 3.6:
			expected = 1.4
		assert_true(step_positions.size() >= 2, "at least two steps")
		if step_positions.size() >= 2:
			assert_true(absf(step_positions[1].x - step_positions[0].x - expected) < 0.002, "interpolated physical stride")
	player.walk_step_length = 0.8
	player.sprint_step_length = 1.0
	player.position.x = 0.0
	player._step_progress = 0.0
	step_positions.clear()
	_simulate_ground_distance(2.9, 2.0)
	assert_true(step_positions.size() >= 2, "custom exports produce steps")
	if step_positions.size() >= 2:
		assert_true(absf(step_positions[1].x - step_positions[0].x - 0.9) < 0.002, "exported lengths affect intermediate stride")
	step_intensities.clear()
	_simulate_ground_distance(7.2, 2.0)
	assert_true(not step_intensities.is_empty(), "overspeed produces a step")
	for intensity: float in step_intensities:
		assert_eq(intensity, 1.0, "overspeed intensity clamps to 1")


func test_bob_cycles_stay_with_steps_through_speed_changes() -> void:
	await _ticks(60)
	player.set_physics_process(false)
	player.head_bob_enabled = true
	var cycles: int = 0
	var previous_y: float = 0.0
	for speed: float in [2.2, 2.9, 3.6, 2.9, 2.2]:
		player.velocity = Vector3(speed, 0, 0)
		for index: int in 180:
			var before: Vector3 = player.global_position
			var step_count: int = steps.size()
			player.position.x += speed / 60.0
			player._update_steps_and_bob(before, true, 1.0 / 60.0)
			var crossed: bool = previous_y < 0.0 and player.camera.position.y >= 0.0
			if crossed:
				cycles += 1
			assert_eq(steps.size() > step_count, crossed, "each bob wrap coincides with a footstep")
			previous_y = player.camera.position.y
	assert_eq(cycles, steps.size(), "one bob cycle per emitted step")
	assert_true(cycles > 20, "exercise many jittered steps and speed transitions")


func test_mouse_look_clamped_and_pause_toggles_capture() -> void:
	# Headless cannot capture an OS pointer; assert the controller's requested state.
	assert_true(player._mouse_captured, "capture requested on ready")
	if DisplayServer.get_name() != "headless":
		assert_eq(Input.mouse_mode, Input.MOUSE_MODE_CAPTURED, "OS capture on ready")
	var motion: InputEventMouseMotion = InputEventMouseMotion.new()
	motion.relative = Vector2(100, -100000)
	player._unhandled_input(motion)
	assert_true(player.rotation.y < 0.0, "horizontal mouse rotates body")
	assert_true(is_equal_approx(player.head.rotation.x, deg_to_rad(85.0)), "upper pitch clamp")
	motion.relative.y = 100000
	player._unhandled_input(motion)
	assert_true(is_equal_approx(player.head.rotation.x, deg_to_rad(-85.0)), "lower pitch clamp")
	var pause_event: InputEventAction = InputEventAction.new()
	pause_event.action = &"pause"
	pause_event.pressed = true
	player._unhandled_input(pause_event)
	assert_false(player._mouse_captured, "Esc clears capture request")
	assert_eq(Input.mouse_mode, Input.MOUSE_MODE_VISIBLE, "Esc releases mouse")
	var yaw: float = player.rotation.y
	player._unhandled_input(motion)
	assert_eq(player.rotation.y, yaw, "released mouse does not look")
	player._unhandled_input(pause_event)
	assert_true(player._mouse_captured, "Esc requests capture again")
	if DisplayServer.get_name() != "headless":
		assert_eq(Input.mouse_mode, Input.MOUSE_MODE_CAPTURED, "OS recapture")


func test_demo_scene_focus_label_and_light_switch() -> void:
	player.queue_free()
	await _ticks(2)
	var scene: PackedScene = load("res://scenes/player/player_test.tscn")
	var demo: Node3D = scene.instantiate()
	world.add_child(demo)
	var environment: WorldEnvironment = demo.get_node("WorldEnvironment")
	assert_eq(environment.environment.ambient_light_source, Environment.AMBIENT_SOURCE_COLOR, "demo boxes receive ambient color")
	await _ticks(60)
	var label: Label = demo.get_node("Debug/Prompt")
	var lamp: OmniLight3D = demo.get_node("Lamp")
	assert_eq(label.text, "PROMPT_INTERACT", "debug label receives focus key")
	assert_true(lamp.visible, "lamp starts on")
	Input.action_press("interact")
	await _ticks(3)
	assert_false(lamp.visible, "interaction turns lamp off")
	Input.action_release("interact")
	await _ticks(2)
	Input.action_press("interact")
	await _ticks(3)
	assert_true(lamp.visible, "interaction turns lamp back on")
	var disabled: Interactable = demo.get_node("DisabledSwitch")
	disabled.interact(demo.get_node("Player"))
	assert_true(lamp.visible, "disabled sample cannot toggle light")
