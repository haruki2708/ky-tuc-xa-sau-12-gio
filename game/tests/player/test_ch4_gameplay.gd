extends TestCase

const PlayerScript = preload("res://scripts/player/player.gd")
const PhoneScript = preload("res://scripts/player/phone_item.gd")
const PLAYER: PackedScene = preload("res://scenes/player/player.tscn")
const SLAT: PackedScene = preload("res://scenes/interaction/bed_slat.tscn")
const FAKE: PackedScene = preload("res://scenes/interaction/fake_search_spot.tscn")

class DoorStub extends Node3D:
	var room: StringName = &"407"
	var is_open: bool = false
	func set_open(value: bool) -> void:
		is_open = value

var world: Node3D
var player: PlayerScript
var phone: PhoneScript
var noises: Array[Array] = []
var thrown: Array[Array] = []
var flipped: Array[int] = []
var damage: Array[Array] = []
var old_chapter: int
var old_mouse: Input.MouseMode
var added_action: bool = false


func before_each() -> void:
	old_chapter = GameState.chapter
	old_mouse = Input.mouse_mode
	GameState.reset()
	GameState.chapter = 4
	for action: StringName in PlayerScript.GAMEPLAY_ACTIONS:
		Input.action_release(action)
	added_action = not InputMap.has_action("throw_phone")
	if added_action:
		InputMap.add_action("throw_phone")
		var key: InputEventKey = InputEventKey.new()
		key.physical_keycode = KEY_G
		InputMap.action_add_event("throw_phone", key)
	world = Node3D.new()
	tree.root.add_child(world)
	_box(Vector3(0, -0.1, 0), Vector3(60, 0.2, 60))
	player = PLAYER.instantiate()
	player.position.y = 0.02
	world.add_child(player)
	player.set_physics_process(false)
	player.death_animation.reduced = false
	phone = player.get_node("Head/Camera3D/PhoneItem")
	phone.set_physics_process(false)
	EventBus.phone_decoy_thrown.connect(_thrown)
	EventBus.noise_emitted.connect(_noise)
	EventBus.bed_slat_flipped.connect(_flipped)
	EventBus.door_damage_changed.connect(_damage)
	await _ticks(3)


func after_each() -> void:
	tree.paused = false
	for action: StringName in PlayerScript.GAMEPLAY_ACTIONS:
		Input.action_release(action)
	Input.action_release("throw_phone")
	if added_action:
		InputMap.erase_action("throw_phone")
	world.queue_free()
	await wait_frames(2)
	EventBus.phone_decoy_thrown.disconnect(_thrown)
	EventBus.noise_emitted.disconnect(_noise)
	EventBus.bed_slat_flipped.disconnect(_flipped)
	EventBus.door_damage_changed.disconnect(_damage)
	GameState.reset()
	GameState.chapter = old_chapter
	Input.mouse_mode = old_mouse


func _ticks(count: int = 2) -> void:
	for index: int in count:
		await tree.physics_frame
		await tree.process_frame


func _box(at: Vector3, size: Vector3) -> StaticBody3D:
	var body: StaticBody3D = StaticBody3D.new()
	var shape: BoxShape3D = BoxShape3D.new()
	shape.size = size
	var collision: CollisionShape3D = CollisionShape3D.new()
	collision.shape = shape
	body.add_child(collision)
	body.position = at
	world.add_child(body)
	return body


func _thrown(at: Vector3, left: int) -> void:
	thrown.append([at, left])


func _noise(at: Vector3, radius: float, source: StringName) -> void:
	if source == &"phone_decoy":
		noises.append([at, radius, source])


func _flipped(bed: int) -> void:
	flipped.append(bed)


func _damage(id: StringName, fraction: float) -> void:
	damage.append([id, fraction])


func _land(decoy: PhoneDecoy) -> void:
	decoy.set_physics_process(false)
	for index: int in 150:
		if decoy.landed or decoy.is_queued_for_deletion():
			break
		decoy._physics_process(0.02)
	assert_true(decoy.landed)


func _slat(bed: int = 1) -> BedSlat:
	var slat: BedSlat = SLAT.instantiate()
	slat.bed = bed
	slat.position = Vector3(0, 0.8, -1)
	world.add_child(slat)
	slat.set_physics_process(false)
	return slat


func test_phone_three_throws_six_seconds_at_actual_landing_and_returns() -> void:
	GameState.set_flag(&"ch4_phone_charges", 3)
	phone.set_raised(true)
	phone.set_flashlight(true)
	for index: int in 3:
		assert_true(phone.throw_decoy())
		var decoy: PhoneDecoy = phone.decoy
		decoy.set_physics_process(false)
		assert_false(phone.throw_decoy(), "only one physical phone")
		assert_false(phone.model.visible)
		assert_false(phone.flashlight.visible)
		assert_eq(thrown.size(), index, "audio starts at landing, not launch")
		_land(decoy)
		assert_eq(thrown[index][1], 2 - index)
		assert_true(player.camera.global_position.distance_to(thrown[index][0]) <= 15.001)
		assert_true(absf(decoy.global_position.y - 0.025) < 0.01)
		decoy._physics_process(5.9)
		assert_true(phone.away)
		assert_eq(noises.size(), (index + 1) * 6)
		for event: Array in noises.slice(index * 6):
			assert_eq(event, [thrown[index][0], 25.0, &"phone_decoy"])
		decoy._physics_process(0.1)
		assert_false(phone.away)
		assert_true(phone.raised and phone.model.visible)
		assert_true(phone.flashlight.visible)
	assert_eq(GameState.get_flag(&"ch4_phone_charges"), 0)
	assert_false(phone.throw_decoy())


func test_phone_g_action_typing_modal_pause_chapter_and_charge_guards() -> void:
	GameState.set_flag(&"ch4_phone_charges", 9)
	var key: InputEventKey = InputEventKey.new()
	key.physical_keycode = KEY_G
	key.pressed = true
	EventBus.text_entry_changed.emit(true)
	phone._unhandled_input(key)
	assert_false(phone.throw_decoy())
	assert_false(phone.away)
	Input.action_press("throw_phone")
	EventBus.text_entry_changed.emit(false)
	assert_false(Input.is_action_pressed("throw_phone"))
	player.acquire_control_lock(world)
	assert_false(phone.throw_decoy())
	player.release_control_lock(world)
	tree.paused = true
	assert_false(phone.throw_decoy())
	tree.paused = false
	GameState.chapter = 3
	assert_false(phone.throw_decoy())
	GameState.chapter = 4
	phone._unhandled_input(key)
	assert_true(phone.away)
	phone.decoy.set_physics_process(false)
	assert_eq(GameState.get_flag(&"ch4_phone_charges"), 2, "clamp to three before spending")
	phone.set_raised(true)
	phone.set_flashlight(true)
	assert_false(phone.raised or phone.flashlight.visible)


func test_phone_arc_hits_new_wall_then_lands_in_front_without_tunnelling() -> void:
	GameState.set_flag(&"ch4_phone_charges", 3)
	assert_true(phone.throw_decoy())
	var decoy: PhoneDecoy = phone.decoy
	decoy.set_physics_process(false)
	_box(Vector3(0, 2, -2), Vector3(8, 4, 0.2))
	await _ticks()
	_land(decoy)
	assert_true(decoy.global_position.z > -2)
	assert_true(decoy.global_position.y < 0.04)


func test_phone_lands_on_steps_and_existing_zombie_hears_it() -> void:
	_box(Vector3(0, 0.5, -5), Vector3(4, 1, 4))
	player.head.rotation.x = -0.18
	var zombie: Zombie = load("res://scenes/entity/zombie.tscn").instantiate()
	zombie.position = Vector3(4, 0, -5)
	world.add_child(zombie)
	zombie.set_target(player)
	zombie.set_physics_process(false)
	await _ticks()
	GameState.set_flag(&"ch4_phone_charges", 3)
	assert_true(phone.throw_decoy())
	_land(phone.decoy)
	assert_true(phone.decoy.global_position.y > 1.0)
	assert_eq(zombie.state, &"hunting")
	assert_eq(zombie._goal, phone.decoy.global_position)


func test_phone_pause_freezes_flight_and_ring() -> void:
	GameState.set_flag(&"ch4_phone_charges", 3)
	phone.throw_decoy()
	var decoy: PhoneDecoy = phone.decoy
	decoy.set_physics_process(false)
	var at: Vector3 = decoy.global_position
	tree.paused = true
	decoy._physics_process(2)
	assert_eq(decoy.global_position, at)
	tree.paused = false
	_land(decoy)
	tree.paused = true
	decoy._physics_process(10)
	assert_true(phone.away)
	assert_eq(decoy.ring_elapsed, 0.0)


func test_bed_five_seconds_once_for_each_valid_bed_and_reentry_safe() -> void:
	for bed: int in [1, 2, 4]:
		var slat: BedSlat = _slat(bed)
		Input.action_press("interact")
		slat.interact(player)
		slat._physics_process(4.9)
		assert_false(slat.completed)
		slat._physics_process(0.1)
		assert_true(slat.completed)
		assert_false(slat.enabled)
		slat.interact(player)
		slat._physics_process(10)
		assert_false(player.movement_locked())
	assert_eq(flipped, [1, 2, 4])
	var invalid: BedSlat = _slat(3)
	invalid.interact(player)
	invalid._physics_process(8)
	assert_false(invalid.completed)


func test_bed_player_ray_and_e_start_hold_with_localized_prompt() -> void:
	var slat: BedSlat = _slat()
	player.head.rotation.x = -0.85
	await _ticks()
	Input.action_press("interact")
	player._physics_process(0.01)
	assert_eq(player._target, slat)
	assert_true(player.movement_locked())
	assert_eq(slat.prompt_key, "PROMPT_CH4_FLIP_SLAT")
	assert_true(TranslationServer.translate(slat.prompt_key) != slat.prompt_key)
	slat._physics_process(5)
	assert_eq(flipped, [1])


func test_phone_is_cleaned_up_with_player_during_flight() -> void:
	GameState.set_flag(&"ch4_phone_charges", 3)
	phone.throw_decoy()
	var decoy: PhoneDecoy = phone.decoy
	player.queue_free()
	await _ticks()
	assert_false(is_instance_valid(decoy))
	assert_true(thrown.is_empty())


func test_fake_ceiling_within_eye_ray_can_be_searched_above_three_meters() -> void:
	var spot: HoldInteractable = FAKE.instantiate()
	spot.position = Vector3(0, 3.3, -0.15)
	world.add_child(spot)
	spot.set_physics_process(false)
	player.head.rotation.x = 1.45
	await _ticks()
	Input.action_press("interact")
	player._physics_process(0.01)
	assert_eq(player._target, spot)
	assert_true(player.movement_locked(), "reachable ceiling must use eye distance")
	spot._physics_process(8)
	assert_true(spot.completed)
	assert_true(flipped.is_empty())


func test_bed_holds_movement_keeps_look_and_release_decays_then_resumes() -> void:
	var slat: BedSlat = _slat()
	Input.action_press("interact")
	slat.interact(player)
	Input.action_press("move_forward")
	var start: Vector3 = player.position
	player._physics_process(0.2)
	assert_eq(player.position, start)
	assert_false(player.controls_locked())
	var mouse: InputEventMouseMotion = InputEventMouseMotion.new()
	mouse.relative = Vector2(50, 20)
	player._unhandled_input(mouse)
	assert_true(absf(player.rotation.y) > 0.01)
	slat._physics_process(2)
	assert_true(slat._bar.visible)
	assert_true(absf(slat._bar.value - 0.4) < 0.001, "fraction must not be rounded to an empty bar")
	Input.action_release("interact")
	slat._physics_process(0.5)
	assert_eq(slat.progress, 1.5)
	assert_false(player.movement_locked())
	Input.action_press("interact")
	slat.interact(player)
	slat._physics_process(3.5)
	assert_eq(flipped, [1])


func test_hold_pause_typing_and_removed_object_do_not_leave_a_movement_lock() -> void:
	var slat: BedSlat = _slat()
	Input.action_press("interact")
	slat.interact(player)
	slat._physics_process(2)
	tree.paused = true
	slat._physics_process(4)
	assert_eq(slat.progress, 2.0)
	tree.paused = false
	EventBus.text_entry_changed.emit(true)
	slat._physics_process(0.2)
	assert_false(player.movement_locked())
	assert_eq(flipped.size(), 0)
	EventBus.text_entry_changed.emit(false)
	Input.action_press("interact")
	slat.interact(player)
	assert_true(player.movement_locked())
	slat.queue_free()
	await _ticks()
	assert_false(player.movement_locked())


func test_three_fake_spots_take_eight_seconds_and_never_emit_mission_result() -> void:
	var results: Array = []
	var documents: Array = []
	var capture: Callable = func(id: StringName) -> void: documents.append(id)
	EventBus.document_opened.connect(capture)
	for label: String in ["FakeLocker", "FakeCeiling", "FakeVent"]:
		var spot: HoldInteractable = FAKE.instantiate()
		spot.name = label
		spot.position.z = -1
		spot.set("document_id", &"must_not_open")
		world.add_child(spot)
		spot.set_physics_process(false)
		spot.connect("searched", func(id: StringName) -> void: results.append(id))
		Input.action_press("interact")
		spot.interact(player)
		spot._physics_process(7.9)
		assert_false(spot.completed)
		spot._physics_process(0.1)
		assert_true(spot.completed)
	assert_true(results.is_empty())
	assert_true(documents.is_empty())
	assert_true(flipped.is_empty())
	EventBus.document_opened.disconnect(capture)


func test_door_damage_threshold_room_id_endpoints_and_ch4_duration_override() -> void:
	var door: DoorStub = DoorStub.new()
	world.add_child(door)
	var adapter: ZombieDoor = ZombieDoor.new()
	adapter.door = door
	adapter.durability_seconds = 75
	world.add_child(adapter)
	adapter.set_physics_process(false)
	assert_eq(damage, [[&"407", 0.0]])
	adapter.bash(75, 10)
	adapter._physics_process(1)
	assert_eq(damage.size(), 1)
	adapter._physics_process(1)
	assert_eq(damage.size(), 2)
	assert_eq(damage.back()[0], &"407")
	assert_true(absf(damage.back()[1] - 2.0 / 75.0) < 0.00001)
	adapter._physics_process(72.9)
	assert_false(door.is_open)
	adapter._physics_process(0.1)
	assert_true(door.is_open)
	assert_eq(damage.back(), [&"407", 1.0])
	var count: int = damage.size()
	adapter._physics_process(2)
	assert_eq(damage.size(), count, "broken door never reports zero again")


func test_door_damage_uses_node_name_and_reports_repaired_open_door_zero() -> void:
	var door: Node3D = Node3D.new()
	door.name = "NamedDoor"
	world.add_child(door)
	var adapter: ZombieDoor = ZombieDoor.new()
	adapter.door = door
	world.add_child(adapter)
	adapter.set_physics_process(false)
	assert_eq(damage.back(), [&"NamedDoor", 0.0])
	adapter.damage_seconds = 5
	adapter._report_damage()
	assert_eq(damage.back(), [&"NamedDoor", 0.5])
	adapter.damage_seconds = 0
	adapter._report_damage()
	assert_eq(damage.back(), [&"NamedDoor", 0.0])


func test_door_burst_opens_door_shows_hand_and_crowd_faces_door_after_fall() -> void:
	var door: DoorStub = DoorStub.new()
	door.position.z = -3
	world.add_child(door)
	door.add_to_group(&"room_doors")
	var other: DoorStub = DoorStub.new()
	other.room = &"406"
	other.position.x = 0.5
	world.add_child(other)
	other.add_to_group(&"room_doors")
	var done: Array = []
	player.death_animation_finished.connect(func() -> void: done.append(true))
	EventBus.player_death_started.emit(&"door_burst")
	var death: PlayerDeath = player.death_animation
	death.set_physics_process(false)
	assert_true(player.controls_locked())
	assert_true(death.door_burst.hand.visible)
	death._physics_process(0.6)
	assert_true(door.is_open)
	assert_false(other.is_open, "door_burst belongs to 407 even beside a closer room")
	assert_true(death.door_burst.crowd[0].visible)
	death._physics_process(2.4)
	death._physics_process(1)
	assert_eq(done.size(), 1)
	assert_true(player.camera.global_position.y < 0.2)
	assert_true((-player.camera.global_basis.z).dot((death.door_burst.focus_point - player.camera.global_position).normalized()) > 0.99)
	assert_false(death.blood.visible, "lane D owns the door-burst blood overlay")


func test_reduced_door_burst_omits_hand_crowd_fragments_and_camera_shake() -> void:
	player.death_animation.reduced = true
	EventBus.player_death_started.emit(&"door_burst")
	var death: PlayerDeath = player.death_animation
	death.set_physics_process(false)
	death._physics_process(0.7)
	assert_false(death.door_burst.hand.visible)
	for body: Node3D in death.door_burst.crowd:
		assert_false(body.visible)
	for chip: Node3D in death.door_burst.chips:
		assert_false(chip.visible)
	assert_true(absf(player.camera.global_rotation.z) < 0.0001)
	death._physics_process(3)
	assert_true(death.finished)


func test_fixture_loads_with_slats_fake_spots_and_a_room_door() -> void:
	var fixture: Node3D = load("res://scenes/player/ch4_gameplay_test.tscn").instantiate()
	fixture.position.x = 100
	world.add_child(fixture)
	await _ticks(3)
	assert_not_null(fixture.get_node("FakeLocker"))
	assert_not_null(fixture.get_node("FakeCeiling"))
	assert_not_null(fixture.get_node("FakeVent"))
	assert_not_null(fixture.get_node("Door407/Blocker"))
