extends TestCase

const PlayerScript = preload("res://scripts/player/player.gd")
const PhoneScript = preload("res://scripts/player/phone_item.gd")
const PLAYER: PackedScene = preload("res://scenes/player/player.tscn")

class Target extends Interactable:
	var uses: int = 0
	func _on_interact(_player: Node) -> void:
		uses += 1

var world: Node3D
var player: PlayerScript
var phone: PhoneScript
var previous_mouse: Input.MouseMode


func before_each() -> void:
	previous_mouse = Input.mouse_mode
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
	phone = player.get_node("Head/Camera3D/PhoneItem")
	await _ticks(3)
	player.set_physics_process(false)


func after_each() -> void:
	tree.paused = false
	EventBus.text_entry_changed.emit(false)
	for action: StringName in PlayerScript.GAMEPLAY_ACTIONS:
		Input.action_release(action)
	world.queue_free()
	await wait_frames(2)
	GameState.reset()
	Input.mouse_mode = previous_mouse


func _ticks(count: int = 2) -> void:
	for index: int in count:
		await tree.physics_frame
		await tree.process_frame


func _mouse() -> InputEventMouseMotion:
	var motion: InputEventMouseMotion = InputEventMouseMotion.new()
	motion.relative = Vector2(30, 15)
	return motion


func _action(name: StringName) -> InputEventAction:
	var event: InputEventAction = InputEventAction.new()
	event.action = name
	event.pressed = true
	return event


func _pick_shape(area: Area3D) -> void:
	var collision: CollisionShape3D = CollisionShape3D.new()
	var shape: BoxShape3D = BoxShape3D.new()
	shape.size = Vector3(0.5, 0.5, 0.1)
	collision.shape = shape
	area.add_child(collision)
	area.position = Vector3(0, 1.6, -1)
	world.add_child(area)


func test_typing_stops_existing_motion_blocks_w_e_then_restores_gameplay() -> void:
	var target: Target = Target.new()
	_pick_shape(target)
	await _ticks()
	Input.action_press("move_forward")
	player._physics_process(0.05)
	assert_true(player.velocity.z < 0)
	var stopped: Vector3 = player.position
	EventBus.text_entry_changed.emit(true)
	assert_eq(player.velocity, Vector3.ZERO, "opening the field stops existing drift immediately")
	Input.action_press("move_forward")
	Input.action_press("interact")
	for index: int in 10:
		player._physics_process(1.0 / 60.0)
	assert_eq(player.position, stopped)
	assert_eq(target.uses, 0)
	assert_false(player.controls_locked(), "typing does not acquire a modal lock")
	EventBus.text_entry_changed.emit(false)
	player._physics_process(1.0 / 60.0)
	# Gravity may finish settling vertically after the keyboard-only freeze.
	assert_true(Vector2(player.position.x, player.position.z).is_equal_approx(Vector2(stopped.x, stopped.z)), "closing does not replay held gameplay actions")
	assert_eq(target.uses, 0, "closing does not replay E in the same frame")
	Input.action_press("move_forward")
	Input.action_press("interact")
	player._physics_process(0.05)
	assert_true(player.position.z < stopped.z)
	assert_eq(target.uses, 1)


func test_action_boundaries_clear_held_keys_and_last_value_wins() -> void:
	for action: StringName in PlayerScript.GAMEPLAY_ACTIONS:
		Input.action_press(action)
	EventBus.text_entry_changed.emit(true)
	for action: StringName in PlayerScript.GAMEPLAY_ACTIONS:
		assert_false(Input.is_action_pressed(action))
		Input.action_press(action)
	player.camera.position.y = 0.018
	player._physics_process(0.05)
	assert_false(player.crouched)
	assert_false(player.holding_breath)
	assert_eq(player.velocity, Vector3.ZERO)
	assert_true(player.camera.position.y > 0.0 and player.camera.position.y < 0.018, "bob settles smoothly")
	EventBus.text_entry_changed.emit(true)
	EventBus.text_entry_changed.emit(false)
	for action: StringName in PlayerScript.GAMEPLAY_ACTIONS:
		assert_false(Input.is_action_pressed(action))
	EventBus.text_entry_changed.emit(true)
	assert_true(player.keyboard_input_blocked())
	EventBus.text_entry_changed.emit(false)
	assert_false(player.keyboard_input_blocked())
	Input.action_press("move_forward")
	EventBus.text_entry_changed.emit(false)
	assert_true(Input.is_action_pressed("move_forward"), "duplicate false must not cancel fresh movement")


func test_mouse_looks_while_phone_and_flashlight_shortcuts_are_blocked() -> void:
	EventBus.text_entry_changed.emit(true)
	var yaw: float = player.rotation.y
	var pitch: float = player.head.rotation.x
	player._unhandled_input(_mouse())
	assert_true(player.rotation.y < yaw)
	assert_true(player.head.rotation.x < pitch)
	assert_true(player._mouse_captured)
	phone._unhandled_input(_action(&"phone"))
	phone._unhandled_input(_action(&"flashlight"))
	assert_false(phone.raised)
	assert_false(phone.flashlight.visible)
	phone.set_raised(true)
	phone._unhandled_input(_action(&"phone"))
	assert_true(phone.raised, "core/UI can raise the prediction phone; typing cannot lower it")
	EventBus.text_entry_changed.emit(false)
	phone._unhandled_input(_action(&"phone"))
	phone._unhandled_input(_action(&"flashlight"))
	assert_false(phone.raised)
	assert_true(phone.flashlight.visible)


func test_typing_keeps_bed_and_hiding_occupancy_and_regular_breathing() -> void:
	for scene: String in ["bunk_spot", "hide_spot"]:
		var spot: HideSpot = load("res://scenes/interaction/" + scene + ".tscn").instantiate()
		world.add_child(spot)
		assert_true(spot.enter(player))
		Input.action_press("hold_breath")
		player._physics_process(0.1)
		assert_true(player.holding_breath)
		EventBus.text_entry_changed.emit(true)
		assert_false(player.holding_breath)
		Input.action_press("hold_breath")
		Input.action_press("interact")
		var pose: Transform3D = player.global_transform
		var pitch: float = player.head.rotation.x
		player._unhandled_input(_mouse())
		player._physics_process(0.5)
		assert_eq(player.global_transform, pose)
		assert_true(spot.is_occupied())
		assert_true(player.is_hidden())
		assert_false(player.holding_breath)
		assert_true(player._breath_elapsed >= 0.5, "automatic breathing keeps advancing")
		assert_true(player.head.rotation.x < pitch)
		EventBus.text_entry_changed.emit(false)
		Input.action_press("interact")
		player._physics_process(0.01)
		assert_false(player.is_hidden())
		assert_false(spot.is_occupied())
		Input.action_release("interact")


func test_pause_and_document_lock_keep_ownership_across_text_transitions() -> void:
	player.acquire_control_lock(world)
	EventBus.text_entry_changed.emit(true)
	EventBus.text_entry_changed.emit(false)
	assert_true(player.controls_locked())
	assert_false(player._mouse_captured)
	var yaw: float = player.rotation.y
	player._unhandled_input(_mouse())
	assert_eq(player.rotation.y, yaw)
	player.release_control_lock(world)
	EventBus.text_entry_changed.emit(true)
	tree.paused = true
	EventBus.game_paused.emit(true)
	EventBus.text_entry_changed.emit(false)
	assert_false(player._mouse_captured, "closing text during pause cannot capture mouse")
	EventBus.text_entry_changed.emit(true)
	tree.paused = false
	EventBus.game_paused.emit(false)
	assert_true(player._mouse_captured)
	assert_true(player.keyboard_input_blocked(), "resume preserves active typing")
	player._unhandled_input(_mouse())
	assert_true(player.rotation.y < yaw)


func test_typing_cancels_partial_wipe_and_cannot_start_a_new_one() -> void:
	var screen: ShowerScreen = ShowerScreen.new()
	_pick_shape(screen)
	screen.set_physics_process(false)
	await _ticks()
	var wipes: Array[bool] = []
	screen.wiped.connect(func() -> void: wipes.append(true))
	Input.action_press("interact")
	screen.interact(player)
	screen._physics_process(0.9)
	assert_true(screen.progress > 0.8)
	EventBus.text_entry_changed.emit(true)
	Input.action_press("interact")
	screen._physics_process(0.2)
	screen.interact(player)
	screen._physics_process(2)
	assert_eq(screen.progress, 0.0)
	assert_true(wipes.is_empty())
	EventBus.text_entry_changed.emit(false)
	Input.action_press("interact")
	screen.interact(player)
	screen._physics_process(1)
	assert_eq(wipes.size(), 1)


func test_text_events_reach_line_edit_without_moving_or_interacting() -> void:
	var field: LineEdit = LineEdit.new()
	world.add_child(field)
	field.grab_focus()
	EventBus.text_entry_changed.emit(true)
	var pose: Transform3D = player.global_transform
	for letter: String in ["w", "e"]:
		var key: InputEventKey = InputEventKey.new()
		key.physical_keycode = KEY_W if letter == "w" else KEY_E
		key.keycode = key.physical_keycode
		key.unicode = letter.unicode_at(0)
		key.pressed = true
		Input.parse_input_event(key)
		await wait_frames(2)
		player._physics_process(1.0 / 60.0)
		key.pressed = false
		Input.parse_input_event(key)
	assert_eq(field.text, "we", "Player must not swallow characters intended for UI")
	assert_eq(player.global_transform, pose)


func test_death_lock_and_signal_lifetime_are_independent_of_typing() -> void:
	var listeners: int = EventBus.text_entry_changed.get_connections().size()
	EventBus.text_entry_changed.emit(true)
	EventBus.player_death_started.emit(&"scald")
	EventBus.text_entry_changed.emit(false)
	assert_true(player.controls_locked())
	assert_false(player._mouse_captured)
	assert_true(player.death_animation.active)
	player.free()
	assert_eq(EventBus.text_entry_changed.get_connections().size(), listeners - 1)
	player = PLAYER.instantiate()
	world.add_child(player)
	player.set_physics_process(false)
	assert_eq(EventBus.text_entry_changed.get_connections().size(), listeners)
	assert_false(player.keyboard_input_blocked())
