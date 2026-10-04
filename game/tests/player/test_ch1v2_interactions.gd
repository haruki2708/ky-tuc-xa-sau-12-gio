extends TestCase

const PlayerScript = preload("res://scripts/player/player.gd")
const PLAYER: PackedScene = preload("res://scenes/player/player.tscn")

var world: Node3D
var player: PlayerScript
var noises: Array[Dictionary] = []
var documents: Array[StringName] = []
var taps: Array[StringName] = []
var previous_mouse: Input.MouseMode


func before_each() -> void:
	previous_mouse = Input.mouse_mode
	world = Node3D.new()
	tree.root.add_child(world)
	player = PLAYER.instantiate()
	world.add_child(player)
	player.set_physics_process(false)
	EventBus.noise_emitted.connect(_noise)
	EventBus.document_opened.connect(_document)
	EventBus.wall_tapped.connect(_tap)


func after_each() -> void:
	tree.paused = false
	Input.action_release("hold_breath")
	world.queue_free()
	await wait_frames(2)
	EventBus.noise_emitted.disconnect(_noise)
	EventBus.document_opened.disconnect(_document)
	EventBus.wall_tapped.disconnect(_tap)
	Input.mouse_mode = previous_mouse
	GameState.reset()


func _prop(scene: String) -> Node3D:
	var node: Node3D = load("res://scenes/interaction/" + scene + ".tscn").instantiate()
	world.add_child(node)
	return node


func _noise(position: Vector3, radius: float, source: StringName) -> void:
	noises.append({"position": position, "radius": radius, "source": source})


func _document(id: StringName) -> void:
	documents.append(id)


func _tap(id: StringName) -> void:
	taps.append(id)


func test_wall_knock_has_no_cooldown_and_uses_wall_position() -> void:
	var wall: Interactable = _prop("wall_knock")
	wall.set("wall_id", &"wall_408")
	wall.position = Vector3(3, 1, -2)
	for index: int in 5:
		wall.interact(player)
	assert_eq(taps, [&"wall_408", &"wall_408", &"wall_408", &"wall_408", &"wall_408"])
	assert_eq(noises.size(), 5)
	assert_eq(noises[0], {"position": wall.global_position, "radius": 3.0, "source": &"knock"})
	wall.enabled = false
	wall.interact(player)
	assert_eq(taps.size(), 5)
	assert_eq(wall.prompt_key, "PROMPT_WALL_KNOCK")


func test_search_is_one_shot_including_reentry_and_saved_state() -> void:
	var spot: Interactable = _prop("search_spot")
	spot.set("spot_id", &"bin")
	spot.set("document_id", &"torn_3")
	var found: Array[StringName] = []
	spot.connect("searched", func(id: StringName) -> void:
		found.append(id)
		spot.interact(player))
	spot.interact(player)
	spot.interact(player)
	assert_eq(found, [&"bin"])
	assert_eq(documents, [&"torn_3"])
	assert_true(spot.get("is_searched"))
	assert_false(spot.enabled)
	var restored: Interactable = _prop("search_spot")
	restored.set("is_searched", true)
	restored.enabled = true
	restored.interact(player)
	assert_eq(documents.size(), 1, "saved latch wins even when externally enabled")
	var empty: Interactable = _prop("search_spot")
	empty.interact(player)
	assert_true(empty.get("is_searched"))
	assert_eq(documents.size(), 1, "empty document does not open a panel")


func test_power_strip_independent_regions_trip_and_lock() -> void:
	var strip: PowerStrip = _prop("power_strip")
	strip.set_physics_process(false)
	var events: Array[Vector2i] = []
	strip.switch_toggled.connect(func(index: int, on: bool) -> void: events.append(Vector2i(index, int(on))))
	for index: int in 3:
		var region: Interactable = strip.get_node("Switch%d" % (index + 1))
		assert_eq(region.collision_layer, 4)
		region.interact(player)
	assert_eq(strip.switches, [true, true, true])
	strip.trip()
	assert_eq(strip.switches, [false, false, false])
	assert_eq(events.size(), 6)
	strip.trip()
	assert_eq(events.size(), 6, "trip is idempotent")
	strip.set_locked(20.0)
	strip.get_node("Switch2").interact(player)
	strip._physics_process(19.99)
	strip.toggle(1)
	assert_false(strip.switches[1])
	strip._physics_process(0.02)
	strip.toggle(1)
	assert_true(strip.switches[1])
	strip.set_locked(2.0)
	strip.toggle(1)
	assert_false(strip.switches[1], "lock blocks switching on but allows switching off")
	strip.toggle(-1)
	strip.toggle(3)
	assert_eq(strip.switches, [false, false, false])


func test_power_lock_freezes_with_pause_and_reentrant_trip() -> void:
	var strip: PowerStrip = _prop("power_strip")
	strip.switch_toggled.connect(func(index: int, on: bool) -> void:
		if index == 2 and on:
			strip.trip()
			strip.set_locked(20.0))
	strip.get_node("Switch3").interact(player)
	assert_eq(strip.switches, [false, false, false])
	assert_eq(strip.get_node("Switch3").prompt_key, "PROMPT_POWER_ON")
	tree.paused = true
	await tree.create_timer(0.1, true).timeout
	assert_eq(strip.lock_remaining, 20.0)
	strip.toggle(0)
	assert_false(strip.switches[0])
	tree.paused = false
	await tree.physics_frame
	await tree.process_frame
	assert_true(strip.lock_remaining < 20.0)


func test_cables_plug_and_unplug_both_ids_without_network_decision() -> void:
	var socket: Interactable = _prop("lan_socket")
	var plugged: Array[StringName] = []
	var unplugged: Array[StringName] = []
	socket.connect("plugged", func(id: StringName) -> void: plugged.append(id))
	socket.connect("unplugged", func(id: StringName) -> void: unplugged.append(id))
	for id: StringName in [&"blue", &"gray"]:
		var cable: LanCable = _prop("lan_cable")
		cable.cable_id = id
		cable.interact(player)
		assert_eq(cable.state, LanCable.State.HELD)
		assert_eq(cable.collision_layer, 0, "held connector does not block the focus ray")
		socket.interact(player)
		assert_eq(cable.state, LanCable.State.PLUGGED)
		assert_eq(cable.socket, socket)
		assert_eq(socket.get("cable"), cable)
		cable.interact(player)
		assert_eq(cable.state, LanCable.State.HELD)
		assert_eq(socket.get("cable"), null)
		assert_eq(socket.prompt_key, "PROMPT_CABLE_PLUG")
		cable.drop()
	assert_eq(plugged, [&"blue", &"gray"])
	assert_eq(unplugged, [&"blue", &"gray"])


func test_cable_holder_replacement_locked_controls_and_freed_socket() -> void:
	var blue: LanCable = _prop("lan_cable")
	var gray: LanCable = _prop("lan_cable")
	blue.position = Vector3(2, 0, 0)
	blue.interact(player)
	gray.interact(player)
	assert_eq(blue.state, LanCable.State.LOOSE)
	assert_eq(blue.position, Vector3(2, 0, 0))
	var socket: Interactable = _prop("lan_socket")
	player.acquire_control_lock(world)
	socket.interact(player)
	assert_eq(gray.state, LanCable.State.HELD)
	assert_eq(socket.get("cable"), null)
	player.release_control_lock(world)
	socket.interact(player)
	assert_eq(gray.state, LanCable.State.PLUGGED)
	socket.free()
	gray._physics_process(0.016)
	assert_eq(gray.state, LanCable.State.LOOSE)
	assert_eq(gray.collision_layer, 4)


func test_breath_limit_six_seconds_scales_gasp_and_recovery() -> void:
	assert_eq(player.max_breath_seconds, 8.0)
	player.max_breath_seconds = 6.0
	Input.action_press("hold_breath")
	player._update_breath(5.99)
	assert_true(player.holding_breath)
	player._update_breath(0.02)
	assert_false(player.holding_breath)
	assert_eq(player._breath_cooldown, 3.0)
	assert_eq(noises.size(), 1)
	assert_eq(noises[0].source, &"breath")
	assert_eq(noises[0].radius, 4.0)
	player._breath_cooldown = 0.0
	player._update_breath(0.01)
	assert_true(player.holding_breath)


func test_desk_lamp_reuses_switch_and_sets_own_flag() -> void:
	var light: OmniLight3D = OmniLight3D.new()
	world.add_child(light)
	var control: Interactable = load("res://scenes/interaction/desk_lamp_switch.tscn").instantiate()
	control.set("light", light)
	world.add_child(control)
	assert_eq(GameState.get_flag(&"desk_lamp_on"), true)
	control.interact(player)
	assert_false(light.visible)
	assert_eq(GameState.get_flag(&"desk_lamp_on"), false)
	control.interact(player)
	assert_true(light.visible)


func test_manager_movement_reports_immediately_only_when_enabled_and_near() -> void:
	var manager: DormManager = load("res://scenes/entity/manager.tscn").instantiate()
	manager.audio_rig = Node3D.new()
	world.add_child(manager.audio_rig)
	world.add_child(manager)
	manager.set_physics_process(false)
	var movement: Array[bool] = []
	var answers: Array[bool] = []
	manager.heard_movement.connect(func() -> void: movement.append(true))
	manager.answered.connect(func(heard: bool) -> void: answers.append(heard))
	var ear: Vector3 = manager.global_position + Vector3.UP * 1.6
	EventBus.noise_emitted.emit(ear, 20, &"step")
	assert_true(movement.is_empty())
	manager.hear_movement_while_present = true
	for source: StringName in [&"step", &"move"]:
		EventBus.noise_emitted.emit(ear + Vector3.RIGHT * 4, 0, source)
	EventBus.noise_emitted.emit(ear + Vector3.RIGHT * 4.01, 100, &"move")
	EventBus.noise_emitted.emit(ear, 100, &"breath")
	assert_eq(movement.size(), 2)
	assert_true(answers.is_empty(), "movement signal does not pretend a question finished")
	tree.paused = true
	EventBus.noise_emitted.emit(ear, 3, &"step")
	assert_eq(movement.size(), 2)
	tree.paused = false
	manager.subtitle_seconds = 0.01
	manager.listen_seconds = 0.1
	manager.ask("MGR_CH1_ASK_BED_3")
	EventBus.noise_emitted.emit(ear, 3, &"breath")
	manager._physics_process(0.02)
	manager._physics_process(0.11)
	assert_eq(answers, [false], "breath during speech is ignored")
	manager.ask("MGR_CH1_ASK_BED_3")
	manager._physics_process(0.02)
	EventBus.noise_emitted.emit(ear, 3, &"breath")
	manager._physics_process(0.11)
	assert_eq(answers, [false, true])
	manager.hear_movement_while_present = false
	EventBus.noise_emitted.emit(ear, 3, &"step")
	assert_eq(movement.size(), 2)
	world.remove_child(manager)
	manager.hear_movement_while_present = true
	EventBus.noise_emitted.emit(ear, 3, &"move")
	assert_eq(movement.size(), 2, "teardown noises ignore detached managers")
	manager.free()
