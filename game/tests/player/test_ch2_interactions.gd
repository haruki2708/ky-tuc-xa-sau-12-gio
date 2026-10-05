extends TestCase

const PlayerScript = preload("res://scripts/player/player.gd")
const PLAYER: PackedScene = preload("res://scenes/player/player.tscn")

class DoorRoom extends Node3D:
	var calls: Array[bool] = []
	func set_bathroom_door_open(value: bool) -> void:
		calls.append(value)

var world: DoorRoom
var player: PlayerScript
var previous_mouse: Input.MouseMode
var noise_listener: Callable
var choice_listener: Callable


func before_each() -> void:
	previous_mouse = Input.mouse_mode
	world = DoorRoom.new()
	tree.root.add_child(world)
	player = PLAYER.instantiate()
	world.add_child(player)
	player.set_physics_process(false)
	await _ticks()


func after_each() -> void:
	tree.paused = false
	Input.action_release("interact")
	if noise_listener.is_valid():
		EventBus.noise_emitted.disconnect(noise_listener)
	if choice_listener.is_valid():
		EventBus.shower_choice_made.disconnect(choice_listener)
	world.queue_free()
	await wait_frames(2)
	Input.mouse_mode = previous_mouse
	GameState.reset()


func _ticks(count: int = 2) -> void:
	for index: int in count:
		await tree.physics_frame
		await tree.process_frame


func _prop(scene: String, at: Vector3 = Vector3(0, 1.6, -1)) -> Node3D:
	var prop: Node3D = load("res://scenes/interaction/" + scene + ".tscn").instantiate()
	prop.position = at
	world.add_child(prop)
	return prop


func test_carry_switch_drop_consume_and_follow_camera() -> void:
	var rag: CarryItem = _prop("carry_item") as CarryItem
	var towel: CarryItem = _prop("carry_item", Vector3(1, 1, -1)) as CarryItem
	towel.item_id = &"towel"
	var home: Transform3D = rag.global_transform
	var picked: Array[StringName] = []
	var dropped: Array[StringName] = []
	rag.picked.connect(func(id: StringName) -> void: picked.append(id))
	rag.dropped.connect(func(id: StringName) -> void: dropped.append(id))
	rag.interact(player)
	rag.interact(player)
	assert_eq(picked, [&"rag"])
	assert_eq(CarryItem.held_by(player), rag)
	assert_eq(rag.collision_layer, 0)
	player.rotation.y = 0.7
	player.head.rotation.x = -0.3
	await _ticks()
	assert_true(rag.global_transform.is_equal_approx(player.camera.global_transform.translated_local(Vector3(0.24, -0.22, -0.55))))
	towel.interact(player)
	assert_eq(CarryItem.held_by(player), towel)
	assert_eq(dropped, [&"rag"])
	assert_true(rag.global_transform.is_equal_approx(home))
	assert_eq(rag.collision_layer, 4)
	towel.drop()
	assert_eq(CarryItem.held_by(player), null)
	rag.interact(player)
	rag.consume()
	rag.consume()
	rag.drop()
	rag.interact(player)
	assert_eq(CarryItem.held_by(player), null)
	assert_true(rag.consumed)
	assert_false(rag.visible)
	assert_eq(dropped.size(), 1, "consumption is not a dropped item")


func test_freed_holder_returns_item_and_locked_or_paused_pickup_is_rejected() -> void:
	var item: CarryItem = _prop("carry_item") as CarryItem
	var home: Transform3D = item.global_transform
	player.acquire_control_lock(world)
	item.interact(player)
	assert_eq(item.holder, null)
	player.release_control_lock(world)
	tree.paused = true
	item.interact(player)
	assert_eq(item.holder, null)
	tree.paused = false
	item.interact(player)
	player.queue_free()
	await _ticks(3)
	assert_eq(item.holder, null)
	assert_true(item.global_transform.is_equal_approx(home))
	assert_eq(item.collision_layer, 4)


func test_gag_focus_requires_item_and_core_controls_acceptance() -> void:
	var spot: GagSpot = _prop("gag_spot") as GagSpot
	spot.bed = 4
	var item: CarryItem = _prop("carry_item", Vector3(1, 1, 0)) as CarryItem
	var requests: Array[Array] = []
	spot.gag_requested.connect(func(bed: int, id: StringName) -> void: requests.append([bed, id]))
	await _ticks()
	player._update_focus()
	assert_eq(player._target, null)
	spot.interact(player)
	assert_true(requests.is_empty())
	item.interact(player)
	player._update_focus()
	assert_eq(player._target, spot)
	assert_eq(player._focus_key, "PROMPT_CH2_GAG")
	spot.interact(player)
	assert_eq(requests, [[4, &"rag"]])
	assert_eq(CarryItem.held_by(player), item, "rejection leaves item in hand")
	assert_false(spot.gagged)
	item.consume()
	spot.set_gagged(true)
	spot.interact(player)
	player._update_focus()
	assert_eq(player._target, null)
	assert_eq(requests.size(), 1)
	spot.set_gagged(false)
	assert_true(spot.enabled)
	assert_false(spot.can_interact(player))


func test_stuck_door_three_bashes_noise_camera_reset_and_reentrant_signal() -> void:
	var door: StuckDoor = _prop("stuck_door") as StuckDoor
	var bashes: Array[int] = []
	var opened: Array[bool] = []
	var noises: Array[Array] = []
	noise_listener = func(at: Vector3, radius: float, source: StringName) -> void: noises.append([at, radius, source])
	EventBus.noise_emitted.connect(noise_listener)
	door.bashed.connect(func(count: int) -> void:
		bashes.append(count)
		door.interact(player))
	door.opened.connect(func() -> void: opened.append(true))
	for index: int in 2:
		door.interact(player)
		assert_true(world.calls.is_empty())
	player._update_door_bash(0.1)
	assert_true(player.camera.rotation.length() > 0.01)
	player._update_door_bash(0.2)
	assert_eq(player.camera.rotation, Vector3.ZERO)
	door.interact(player)
	door.interact(player)
	assert_eq(bashes, [1, 2, 3])
	assert_eq(world.calls, [true])
	assert_eq(opened.size(), 1)
	assert_eq(noises.size(), 3)
	for noise: Array in noises:
		assert_eq(noise, [door.global_position, 6.0, &"door_bash"])
	door.reset()
	assert_eq(world.calls, [true, false])
	assert_eq(door.bash_count, 0)
	assert_true(door.enabled)
	assert_false(door.is_open)
	player.acquire_control_lock(world)
	door.interact(player)
	assert_eq(door.bash_count, 0)


func test_stall_physics_entry_exit_and_freed_player() -> void:
	var stall: ShowerStall = _prop("shower_stall", Vector3(3, 0, 0)) as ShowerStall
	var changes: Array[bool] = []
	stall.player_inside_changed.connect(func(value: bool) -> void: changes.append(value))
	await _ticks(3)
	assert_false(stall.player_inside)
	player.position.x = 3
	await _ticks(3)
	assert_true(stall.player_inside)
	player.position.x = 0
	await _ticks(3)
	assert_false(stall.player_inside)
	player.position.x = 3
	await _ticks(3)
	player.queue_free()
	await _ticks(3)
	assert_false(stall.player_inside)
	assert_eq(changes, [true, false, true, false])


func test_choices_are_disabled_by_default_and_work_inside_stall() -> void:
	var stall: ShowerStall = _prop("shower_stall", Vector3.ZERO) as ShowerStall
	var yes: ShowerChoice = _prop("shower_choice") as ShowerChoice
	var no: ShowerChoice = _prop("shower_choice", Vector3(1, 1.6, -1)) as ShowerChoice
	no.run_water = false
	var choices: Array[bool] = []
	choice_listener = func(value: bool) -> void: choices.append(value)
	EventBus.shower_choice_made.connect(choice_listener)
	await _ticks(3)
	assert_true(stall.player_inside)
	yes.interact(player)
	no.interact(player)
	assert_true(choices.is_empty())
	yes.set_enabled(true)
	no.set_enabled(true)
	player._update_focus()
	assert_eq(player._target, yes, "stall does not block interaction ray")
	yes.interact(player)
	no.interact(player)
	assert_eq(choices, [true, false])
	yes.set_enabled(false)
	yes.interact(player)
	tree.paused = true
	no.interact(player)
	assert_eq(choices.size(), 2)


func test_wipe_needs_continuous_focus_and_one_second_inside_stall() -> void:
	_prop("shower_stall", Vector3.ZERO)
	var screen: ShowerScreen = _prop("shower_screen") as ShowerScreen
	screen.set_physics_process(false)
	var wipes: Array[bool] = []
	screen.wiped.connect(func() -> void: wipes.append(true))
	await _ticks(3)
	Input.action_press("interact")
	screen.interact(player)
	screen._physics_process(0.99)
	assert_true(wipes.is_empty())
	Input.action_release("interact")
	screen._physics_process(0.02)
	assert_eq(screen.progress, 0.0)
	Input.action_press("interact")
	screen.interact(player)
	screen._physics_process(0.6)
	player.rotation.y = PI
	screen._physics_process(0.5)
	assert_true(wipes.is_empty())
	assert_eq(screen.progress, 0.0)
	player.rotation.y = 0
	screen.interact(player)
	screen._physics_process(0.6)
	tree.paused = true
	screen._physics_process(10)
	assert_eq(screen.progress, 0.6)
	tree.paused = false
	screen._physics_process(0.4)
	screen._physics_process(5)
	assert_eq(wipes.size(), 1, "one wipe per continuous hold")
	Input.action_release("interact")
	screen._physics_process(0.1)
	Input.action_press("interact")
	screen.interact(player)
	player.acquire_control_lock(world)
	screen._physics_process(2)
	assert_eq(wipes.size(), 1)
	assert_eq(screen.progress, 0.0)


func test_manual_fixture_loads_all_regions_and_three_items() -> void:
	var fixture: Node3D = load("res://scenes/interaction/ch2_interactions_test.tscn").instantiate()
	world.add_child(fixture)
	await _ticks()
	assert_eq(tree.get_nodes_in_group(&"carry_item").size(), 3)
	assert_eq(tree.get_nodes_in_group(&"ch2_corpse").size(), 3)
	assert_not_null(fixture.get_node_or_null("ShowerYes"))
	assert_not_null(fixture.get_node_or_null("ShowerNo"))
