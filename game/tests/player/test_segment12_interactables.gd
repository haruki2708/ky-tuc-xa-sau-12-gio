extends TestCase

const SWITCH: PackedScene = preload("res://scenes/interaction/light_switch.tscn")
const LATCH: PackedScene = preload("res://scenes/interaction/door_latch.tscn")
const PAPER: PackedScene = preload("res://scenes/interaction/readable.tscn")
const PHONE: PackedScene = preload("res://scenes/interaction/phone.tscn")
const ROOM: PackedScene = preload("res://scenes/interaction/interaction_test.tscn")
const SwitchScript = preload("res://scripts/interaction/light_switch.gd")
const LatchScript = preload("res://scripts/interaction/door_latch.gd")
const PaperScript = preload("res://scripts/interaction/readable.gd")
const PhoneScript = preload("res://scripts/interaction/phone.gd")

var world: Node3D
var documents: Array[StringName] = []
var subtitles: Array[Dictionary] = []
var answered_count: int = 0
var interacted_count: int = 0
var previous_mouse_mode: Input.MouseMode


func before_each() -> void:
	GameState.reset()
	RuleSystem.reset()
	previous_mouse_mode = Input.mouse_mode
	world = Node3D.new()
	tree.root.add_child(world)
	EventBus.document_opened.connect(_document_opened)
	EventBus.subtitle_requested.connect(_subtitle_requested)
	EventBus.interacted.connect(_interacted)


func after_each() -> void:
	EventBus.document_opened.disconnect(_document_opened)
	EventBus.subtitle_requested.disconnect(_subtitle_requested)
	EventBus.interacted.disconnect(_interacted)
	world.queue_free()
	await wait_frames(2)
	GameState.reset()
	RuleSystem.reset()
	Input.mouse_mode = previous_mouse_mode


func _document_opened(id: StringName) -> void:
	documents.append(id)
	assert_eq(RuleSystem.read_entries().size(), 4, "notebook populated before opening room paper")


func _subtitle_requested(key: String, duration: float) -> void:
	subtitles.append({"key": key, "duration": duration})


func _interacted(_target: Node) -> void:
	interacted_count += 1


func _answered() -> void:
	answered_count += 1
	assert_eq(GameState.get_flag(&"phone_checked"), true, "flag precedes answered signal")


func test_light_switch_initial_state_toggle_and_external_visibility() -> void:
	var light: OmniLight3D = OmniLight3D.new()
	world.add_child(light)
	var light_switch: SwitchScript = SWITCH.instantiate()
	light_switch.light = light
	world.add_child(light_switch)
	assert_eq(GameState.get_flag(&"main_light_on"), true, "initial light flag")
	assert_eq(light_switch.prompt_key, "PROMPT_LIGHT_OFF")
	light_switch.interact(null)
	assert_false(light.visible)
	assert_eq(GameState.get_flag(&"main_light_on"), false)
	assert_eq(light_switch.prompt_key, "PROMPT_LIGHT_ON")
	light_switch.interact(null)
	assert_true(light.visible)
	assert_eq(GameState.get_flag(&"main_light_on"), true)
	light.visible = false
	assert_eq(light_switch.prompt_key, "PROMPT_LIGHT_ON", "external change stays in sync")
	assert_eq(GameState.get_flag(&"main_light_on"), false)


func test_initially_dark_switch_custom_flag_and_disabled_guard() -> void:
	var light: OmniLight3D = OmniLight3D.new()
	light.visible = false
	world.add_child(light)
	var light_switch: SwitchScript = SWITCH.instantiate()
	light_switch.light = light
	light_switch.flag = &"test_light"
	world.add_child(light_switch)
	assert_eq(GameState.get_flag(&"test_light"), false)
	assert_false(GameState.has_flag(&"main_light_on"))
	assert_eq(light_switch.prompt_key, "PROMPT_LIGHT_ON")
	light_switch.enabled = false
	light_switch.interact(null)
	assert_false(light.visible)
	assert_eq(interacted_count, 0)


func test_latch_blocks_real_door407_until_unlocked() -> void:
	# Use the unchanged lane B script with its required pivot, not a test-only API.
	var door: Interactable = load("res://scenes/levels/floor4/door407.gd").new()
	var pivot: Node3D = Node3D.new()
	pivot.name = "Pivot"
	door.add_child(pivot)
	world.add_child(door)
	var latch: LatchScript = LATCH.instantiate()
	latch.door = door
	world.add_child(latch)
	door.interact(null)
	assert_eq(door.get("is_open"), true)
	latch.interact(null)
	assert_true(door.enabled, "open door cannot be latched")
	assert_eq(GameState.get_flag(&"door_locked"), false)
	assert_eq(latch.prompt_key, "PROMPT_LOCK_DOOR")
	door.interact(null)
	latch.interact(null)
	assert_false(door.enabled)
	assert_eq(GameState.get_flag(&"door_locked"), true)
	assert_eq(latch.prompt_key, "PROMPT_UNLOCK_DOOR")
	door.interact(null)
	assert_eq(door.get("is_open"), false, "locked door cannot open")
	latch.interact(null)
	assert_true(door.enabled)
	assert_eq(GameState.get_flag(&"door_locked"), false)
	assert_eq(latch.prompt_key, "PROMPT_LOCK_DOOR")
	door.interact(null)
	assert_eq(door.get("is_open"), true, "unlocked door can open")


func test_latch_handles_optional_open_property_and_missing_door() -> void:
	var latch: LatchScript = LATCH.instantiate()
	latch.flag = &"test_lock"
	world.add_child(latch)
	latch.interact(null)
	assert_eq(GameState.get_flag(&"test_lock"), false, "unassigned latch cannot lock")
	var door: Interactable = Interactable.new()
	world.add_child(door)
	latch.door = door
	latch.interact(null)
	assert_false(door.enabled, "door without is_open is supported")
	assert_eq(GameState.get_flag(&"test_lock"), true)
	door.free()
	latch.interact(null)
	assert_eq(GameState.get_flag(&"test_lock"), true, "freed door handled safely")


func test_readable_marks_document_rules_then_emits_id_without_duplicates() -> void:
	assert_true(RuleSystem.load_rule_set(load("res://data/rules/demo.tres")).is_empty())
	var paper: PaperScript = PAPER.instantiate()
	paper.document_id = &"room_paper_407"
	world.add_child(paper)
	paper.interact(null)
	assert_eq(documents, [&"room_paper_407"])
	var document: DocumentData = DocumentData.load_by_id(&"room_paper_407")
	assert_eq(RuleSystem.read_rules(), document.rule_ids)
	for entry: Dictionary in RuleSystem.read_entries():
		assert_eq(entry["source"], &"room_paper")
		assert_eq(entry["text_key"], RuleSystem.get_rule(entry["rule_id"]).text_key)
	paper.interact(null)
	assert_eq(RuleSystem.read_entries().size(), 4, "reading again does not duplicate notebook")
	assert_eq(documents.size(), 2, "document can be reopened")
	paper.enabled = false
	paper.interact(null)
	assert_eq(documents.size(), 2, "disabled paper does not open")


func test_invalid_document_does_not_emit_or_change_notebook() -> void:
	var paper: PaperScript = PAPER.instantiate()
	paper.document_id = &"missing_t129_document"
	world.add_child(paper)
	paper.interact(null)
	assert_true(documents.is_empty())
	assert_true(RuleSystem.read_entries().is_empty())
	assert_eq(interacted_count, 0, "invalid document is a no-op apart from warning")


func test_readable_size_updates_mesh_and_collision_per_instance() -> void:
	var paper: PaperScript = PAPER.instantiate()
	var board: PaperScript = PAPER.instantiate()
	board.size = Vector2(0.8, 1.2)
	world.add_child(paper)
	world.add_child(board)
	assert_eq(paper.get_node("Mesh").mesh.size, Vector3(0.21, 0.297, 0.004))
	assert_eq(board.get_node("Mesh").mesh.size, Vector3(0.8, 1.2, 0.004))
	board.size = Vector2(1, 1.5)
	assert_eq(board.get_node("CollisionShape3D").shape.size, Vector3(1, 1.5, 0.004))
	assert_eq(paper.get_node("CollisionShape3D").shape.size, Vector3(0.21, 0.297, 0.004))


func test_phone_ring_answer_and_repeat_cycle() -> void:
	var phone: PhoneScript = PHONE.instantiate()
	world.add_child(phone)
	phone.answered.connect(_answered)
	assert_false(phone.enabled)
	phone.interact(null)
	assert_eq(answered_count, 0)
	assert_false(GameState.has_flag(&"phone_checked"))
	assert_true(subtitles.is_empty())
	var rest: Vector3 = phone.mesh.position
	phone.ring()
	phone.ring()
	assert_true(phone.enabled)
	phone._process(0.01)
	assert_true(phone.mesh.position.distance_to(rest) > 0.0, "mesh vibrates")
	assert_true(phone.mesh.position.distance_to(rest) <= 0.0021, "vibration stays subtle")
	phone.interact(null)
	assert_false(phone.enabled)
	assert_false(phone.is_processing())
	assert_eq(phone.mesh.position, rest)
	assert_eq(answered_count, 1)
	assert_eq(subtitles, [{"key": "SUB_PHONE_MIDNIGHT", "duration": 4.0}])
	phone.interact(null)
	assert_eq(answered_count, 1, "answer only once per ring")
	phone.ring()
	phone.interact(null)
	assert_eq(answered_count, 2, "a later ring can be answered")


func test_phone_plays_assigned_stream_and_stops_on_answer() -> void:
	var phone: PhoneScript = PHONE.instantiate()
	var stream: AudioStreamWAV = AudioStreamWAV.new()
	stream.mix_rate = 22050
	stream.format = AudioStreamWAV.FORMAT_8_BITS
	var silence: PackedByteArray = PackedByteArray()
	silence.resize(11025)
	silence.fill(128)
	stream.data = silence
	phone.vibrate_stream = stream
	world.add_child(phone)
	phone.ring()
	assert_eq(phone.vibration.stream, stream)
	assert_true(phone.vibration.playing)
	phone.vibration.stop()
	phone.vibration.finished.emit()
	assert_true(phone.vibration.playing, "non-looping clips repeat while ringing")
	phone.interact(null)
	assert_false(phone.vibration.playing)
	phone.vibration.finished.emit()
	assert_false(phone.vibration.playing, "finished cannot restart an answered phone")


func test_all_props_have_interactable_collision_and_translated_prompts() -> void:
	for scene: PackedScene in [SWITCH, LATCH, PAPER, PHONE]:
		var item: Interactable = scene.instantiate()
		assert_eq(item.collision_layer, 4)
		assert_eq(item.collision_mask, 0)
		assert_not_null(item.get_node("CollisionShape3D").shape)
		assert_not_null(item.get_node("Mesh").mesh)
		for locale: String in ["vi", "en"]:
			var translation: Translation = TranslationServer.get_translation_object(locale)
			assert_false(translation.get_message(item.prompt_key).is_empty(), "prompt translated: " + item.prompt_key)
		item.free()


func test_test_room_wiring_and_r_key() -> void:
	var room: Node3D = ROOM.instantiate()
	world.add_child(room)
	assert_eq(room.get_node("LightSwitch").light, room.get_node("Lamp"))
	assert_eq(room.get_node("Door/Pivot/Latch").door, room.get_node("Door"))
	assert_eq(room.get_node("Paper").document_id, &"room_paper_407")
	assert_false(RuleSystem.all_rule_ids().is_empty(), "fixture loads demo rules")
	var key: InputEventKey = InputEventKey.new()
	key.physical_keycode = KEY_R
	key.pressed = true
	room.call("_unhandled_key_input", key)
	assert_true(room.get_node("Phone").enabled, "R rings phone in standalone fixture")


func test_test_room_props_are_reachable_by_player_collision_mask() -> void:
	var room: Node3D = ROOM.instantiate()
	world.add_child(room)
	await tree.physics_frame
	await tree.process_frame
	var targets: Array[Dictionary] = [
		{"path": "LightSwitch", "from": Vector3(0, 1.35, -1.5), "to": Vector3(0, 1.35, -2.84)},
		{"path": "Door/Pivot/Latch", "from": Vector3(-1.78, 1.05, -1.5), "to": Vector3(-1.78, 1.05, -2.84)},
		{"path": "Paper", "from": Vector3(1, 1.4, -1.5), "to": Vector3(1, 1.4, -2.84)},
		{"path": "Phone", "from": Vector3(2, 1.6, -0.5), "to": Vector3(2, 0.806, -1.6)},
	]
	for target: Dictionary in targets:
		var query: PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.create(target["from"], target["to"], 5)
		query.collide_with_areas = true
		var hit: Dictionary = world.get_world_3d().direct_space_state.intersect_ray(query)
		assert_eq(hit.get("collider"), room.get_node(target["path"]), "reachable prop: " + target["path"])
