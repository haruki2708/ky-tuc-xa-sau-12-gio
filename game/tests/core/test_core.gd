extends TestCase
## Smoke tests for the project skeleton.


func test_input_actions_registered() -> void:
	for action in ["move_forward", "move_back", "move_left", "move_right", "interact", "pause"]:
		assert_true(InputMap.has_action(action), "missing input action " + action)


func test_autoloads_present() -> void:
	assert_not_null(tree.root.get_node_or_null("GameInput"), "GameInput autoload")
	assert_not_null(tree.root.get_node_or_null("EventBus"), "EventBus autoload")
	for autoload in ["App", "Settings", "GameState", "RuleSystem"]:
		assert_not_null(tree.root.get_node_or_null(autoload), autoload + " autoload")
	for sig in ["interaction_focus_changed", "interacted", "subtitle_requested", "game_paused", "settings_changed"]:
		assert_true(EventBus.has_signal(sig), "EventBus signal " + sig)


func test_main_scene_loads() -> void:
	var path: String = ProjectSettings.get_setting("application/run/main_scene")
	var scene: PackedScene = load(path)
	assert_not_null(scene, "main scene loads")
	var inst := scene.instantiate()
	tree.root.add_child(inst)
	await wait_frames(2)
	assert_true(inst.is_inside_tree(), "main scene enters tree")
	inst.queue_free()
	await wait_frames(1)


func test_interactable_emits_signal() -> void:
	var item := Interactable.new()
	tree.root.add_child(item)
	var got: Array = []
	var cb := func(target: Node) -> void: got.append(target)
	EventBus.interacted.connect(cb)
	item.interact(null)
	item.enabled = false
	item.interact(null)
	EventBus.interacted.disconnect(cb)
	assert_eq(got.size(), 1, "disabled interactable must not fire;")
	assert_eq(item.collision_layer, Interactable.LAYER_INTERACTABLE, "layer;")
	item.free()


func test_translations_registered() -> void:
	TranslationServer.set_locale("vi")
	assert_eq(tr("PROMPT_INTERACT"), "Tương tác", "vi;")
	TranslationServer.set_locale("en")
	assert_eq(tr("PROMPT_INTERACT"), "Interact", "en;")
	TranslationServer.set_locale("vi")


func test_main_scene_footsteps_and_ambience_wired() -> void:
	var main: Node = load("res://scenes/main/main.tscn").instantiate()
	tree.root.add_child(main)
	var steps: AudioStreamPlayer3D = main.get_node("Player/Footsteps")
	assert_not_null(main.get_node_or_null("PauseMenu"), "pause menu in main scene")
	assert_not_null(main.get_node_or_null("Floor4"), "floor 4 in main scene")
	var ps1 := main.get_node_or_null("PS1Filter") as CanvasLayer
	assert_not_null(ps1, "PS1 filter in main scene")
	if ps1 != null:
		assert_true(ps1.layer < (main.get_node("HUD") as CanvasLayer).layer, "filter below HUD")
	var player: Node3D = main.get_node("Player")
	var spawn: Node3D = main.get_node("Floor4/Anchors/seg1_start")
	assert_true(player.global_position.is_equal_approx(spawn.global_position), "player starts at seg1_start;")
	for i in 30:
		await tree.physics_frame
	# seg1_start faces the closed door of 407; turn west along the corridor.
	player.rotation.y = PI / 2.0
	Input.action_press("move_forward")
	for i in 60:
		await tree.physics_frame
	assert_not_null(steps.stream, "walking on tile floor plays a footstep;")
	assert_true(steps.tile_variants.has(steps.stream), "walking uses the walk bank;")
	Input.action_press("sprint")
	for i in 60:
		await tree.physics_frame
	Input.action_release("sprint")
	Input.action_release("move_forward")
	assert_true(steps.tile_run_variants.has(steps.stream), "sprinting uses the run bank;")
	var light: Light3D = main.get_node("Floor4/Corridor/CorridorLight_407")
	var hum: AudioStreamPlayer3D = light.get_node("LightHum")
	assert_true(hum.playing, "corridor tube hums;")
	assert_eq(hum.bus, &"Ambience", "hum bus;")
	light.visible = false
	assert_false(hum.playing, "hum stops when its tube light turns off;")
	light.visible = true
	assert_true(hum.playing, "hum resumes when its tube light turns on;")
	# Stop audio first: the audio thread releases playbacks a little later.
	for node in main.find_children("*", "AudioStreamPlayer3D", true, false):
		if node.has_method("stop_emitting"):
			node.stop_emitting()
		(node as AudioStreamPlayer3D).stop()
	main.queue_free()
	await tree.create_timer(0.5).timeout


func test_main_scene_escape_pauses_and_resumes_player() -> void:
	var main: Node = load("res://scenes/main/main.tscn").instantiate()
	tree.root.add_child(main)
	await wait_frames(2)
	var player: Node = main.get_node("Player")
	var escape := InputEventAction.new()
	escape.action = &"pause"
	escape.pressed = true
	Input.parse_input_event(escape)
	await wait_frames(2)
	assert_true(tree.paused, "Esc pauses the game")
	assert_false(player._mouse_captured, "Player releases the mouse while paused")
	Input.parse_input_event(escape)
	await wait_frames(2)
	assert_false(tree.paused, "second Esc resumes")
	assert_true(player._mouse_captured, "Player captures the mouse again")
	tree.paused = false
	for node in main.find_children("*", "AudioStreamPlayer3D", true, false):
		if node.has_method("stop_emitting"):
			node.stop_emitting()
		(node as AudioStreamPlayer3D).stop()
	main.queue_free()
	await tree.create_timer(0.5).timeout


func test_footsteps_volume_setting_reaches_footsteps_bus() -> void:
	# Lane D settings (T-116) + lane E bus (T-126), through the main scene menu.
	var path := "user://settings.cfg"
	var had := FileAccess.file_exists(path)
	var backup := FileAccess.get_file_as_bytes(path) if had else PackedByteArray()
	var bus := AudioServer.get_bus_index(&"Footsteps")
	assert_true(bus >= 0, "Footsteps bus exists")
	assert_eq(AudioServer.get_bus_send(bus), &"SFX", "footsteps feed SFX;")
	assert_eq(Settings.set_value("audio", "footsteps_db", -12.0), OK, "save footsteps volume;")
	assert_eq(AudioServer.get_bus_volume_db(bus), -12.0, "bus follows setting;")
	var main: Node = load("res://scenes/main/main.tscn").instantiate()
	tree.root.add_child(main)
	await wait_frames(2)
	var row := main.get_node_or_null("PauseMenu/Root/SettingsCard/SettingsPanel/Scroll/Columns/Audio/footsteps_db") as Control
	assert_not_null(row, "footsteps slider row in main pause menu")
	if row != null:
		assert_true(row.visible, "footsteps slider shown now that the bus exists")
	for node in main.find_children("*", "AudioStreamPlayer3D", true, false):
		if node.has_method("stop_emitting"):
			node.stop_emitting()
		(node as AudioStreamPlayer3D).stop()
	main.queue_free()
	await tree.create_timer(0.5).timeout
	if had:
		var file := FileAccess.open(path, FileAccess.WRITE)
		file.store_buffer(backup)
		file.close()
	else:
		DirAccess.remove_absolute(path)
	Settings.apply_startup()


func _first_pick(main: Node, from: Vector3, to: Vector3) -> Object:
	# Same mask and target kinds as the Player's InteractRay (world + interactable).
	var query := PhysicsRayQueryParameters3D.create(from, to, 5)
	query.collide_with_areas = true
	query.collide_with_bodies = true
	var hit := (main as Node3D).get_world_3d().direct_space_state.intersect_ray(query)
	return null if hit.is_empty() else hit["collider"]


func test_room_407_interactables_are_reachable_from_inside() -> void:
	var main: Node = load("res://scenes/main/main.tscn").instantiate()
	main.get_node("StoryDirector").auto_start = false
	tree.root.add_child(main)
	await tree.physics_frame
	await tree.physics_frame
	var paper := main.get_node("Floor4/Door407/Pivot/RulesPaper/RulesPaper407")
	var latch := main.get_node("Floor4/Door407/Pivot/DoorLatch407")
	var switch := main.get_node("Room407LightSwitch")
	var door := main.get_node("Floor4/Door407")
	assert_eq(_first_pick(main, Vector3(32.0, 1.39, -1.0), Vector3(32.0, 1.39, 0.3)), paper, "paper wins over the door")
	assert_eq(_first_pick(main, Vector3(32.0, 0.8, -1.0), Vector3(32.0, 0.8, 0.3)), door, "rest of the leaf opens the door")
	var latch_at := (latch.get_node("CollisionShape3D") as Node3D).global_position
	assert_eq(_first_pick(main, latch_at + Vector3(0, 0, -0.8), latch_at + Vector3(0, 0, 0.3)), latch, "latch reachable")
	assert_eq(_first_pick(main, Vector3(32.72, 1.36, -1.0), Vector3(32.72, 1.36, 0.3)), switch, "light switch reachable")
	assert_eq(main.get_node("StoryDirector").get_node(main.get_node("StoryDirector").phone_path), main.get_node("PhoneTrung"), "director rings Trung's phone")
	# Latch locks the real door; the paper fills the notebook.
	RuleSystem.load_rule_set(load("res://data/rules/demo.tres"))
	latch.interact(null)
	assert_false(door.enabled, "latched door cannot be opened")
	assert_eq(GameState.get_flag(&"door_locked"), true, "door_locked flag;")
	paper.interact(null)
	assert_true(RuleSystem.is_read(&"slippers_paper"), "paper adds the fake rule 3 to the notebook")
	switch.interact(null)
	assert_false(main.get_node("Floor4/Room407/Room407MainLight").visible, "switch turns the main light off")
	for node in main.find_children("*", "AudioStreamPlayer3D", true, false):
		if node.has_method("stop_emitting"):
			node.stop_emitting()
		(node as AudioStreamPlayer3D).stop()
	main.queue_free()
	await tree.create_timer(0.5).timeout
	GameState.reset()
	RuleSystem.reset()


func _tap(action: StringName) -> void:
	var press := InputEventAction.new()
	press.action = action
	press.pressed = true
	Input.parse_input_event(press)
	# The player reads "just pressed" in _physics_process: hold the key across
	# physics ticks, not just process frames (headless frames outrun physics).
	await wait_frames(2)
	await tree.physics_frame
	await tree.physics_frame
	var release := InputEventAction.new()
	release.action = action
	release.pressed = false
	Input.parse_input_event(release)
	await wait_frames(2)
	await tree.physics_frame


func test_reading_the_door_paper_opens_and_closes_cleanly() -> void:
	# Earlier suites may leave an action held or the tree paused; a held
	# "interact" would hide the press this test simulates.
	tree.paused = false
	for action in ["interact", "pause", "notebook", "move_forward", "sprint"]:
		Input.action_release(action)
	await wait_frames(2)
	var main: Node = load("res://scenes/main/main.tscn").instantiate()
	main.get_node("StoryDirector").auto_start = false
	tree.root.add_child(main)
	RuleSystem.load_rule_set(load("res://data/rules/demo.tres"))
	var player := main.get_node("Player") as Node3D
	player.global_position = Vector3(32.0, 0.03, -0.9)
	player.rotation.y = PI
	player.get_node("Head").rotation.x = -0.28
	# Wait until the interaction ray actually rests on the paper (the busier
	# room 407 of T-153 can take a few more physics ticks to settle).
	var paper := main.find_child("RulesPaper407", true, false)
	for i in 120:
		await tree.physics_frame
		if paper != null and player.get("_target") == paper:
			break
	var view := main.get_node("DocumentView")
	await _tap(&"interact")
	assert_true(view.is_open(), "E on the paper opens the close-up")
	assert_true(tree.paused, "reading pauses the game")
	await _tap(&"interact")
	for i in 10:
		await tree.physics_frame
	assert_false(view.is_open(), "E closes the paper and it stays closed")
	assert_false(tree.paused, "game resumes")
	await _tap(&"notebook")
	assert_true(main.get_node("Notebook").is_open(), "Tab opens the notebook")
	await _tap(&"pause")
	assert_false(main.get_node("Notebook").is_open(), "Esc closes the notebook")
	assert_false(main.get_node("PauseMenu")._open, "Esc did not also open the pause menu")
	tree.paused = false
	for node in main.find_children("*", "AudioStreamPlayer3D", true, false):
		if node.has_method("stop_emitting"):
			node.stop_emitting()
		(node as AudioStreamPlayer3D).stop()
	main.queue_free()
	await tree.create_timer(0.5).timeout
	GameState.reset()
	RuleSystem.reset()


func test_room_407_ceiling_fan_spins() -> void:
	var main: Node = load("res://scenes/main/main.tscn").instantiate()
	main.get_node("StoryDirector").auto_start = false
	tree.root.add_child(main)
	var rotors: Array[Node] = main.get_node("Floor4").find_children("fan_rotor", "", true, false)
	assert_false(rotors.is_empty(), "room 407 has a ceiling fan rotor")
	if not rotors.is_empty():
		var rotor := rotors[0] as Node3D
		var before := rotor.basis
		await wait_frames(5)
		assert_false(rotor.basis.is_equal_approx(before), "fan blades turn")
	for node in main.find_children("*", "AudioStreamPlayer3D", true, false):
		if node.has_method("stop_emitting"):
			node.stop_emitting()
		(node as AudioStreamPlayer3D).stop()
	main.queue_free()
	await tree.create_timer(0.5).timeout


func test_checkpoint_peek_reads_the_id_without_restoring() -> void:
	var path := "user://test_peek_checkpoint.json"
	assert_eq(Checkpoint.peek_id(path), &"", "no save;")
	GameState.reset()
	GameState.add_deviation(2, &"test")
	assert_eq(Checkpoint.save(&"seg3_start", path), OK, "save;")
	GameState.reset()
	assert_eq(Checkpoint.peek_id(path), &"seg3_start", "peeked;")
	assert_eq(GameState.deviation, 0, "state untouched")
	Checkpoint.clear(path)


func test_chapter_contract_inputs_and_signals() -> void:
	for action in ["crouch", "phone", "flashlight", "hold_breath"]:
		assert_true(InputMap.has_action(action), "missing input action " + action)
	for sig in ["chapter_started", "chapter_finished", "noise_emitted", "player_hidden", "breath_held",
			"phone_raised", "flashlight_toggled", "phone_battery_changed", "phone_message_received",
			"puzzle_opened", "puzzle_closed", "puzzle_solved", "entity_state_changed", "watcher_active",
			"player_caught", "phone_call_incoming", "phone_call_answered", "chat_member_changed",
			"chat_choice_requested", "chat_choice_made", "survivor_count_changed"]:
		assert_true(EventBus.has_signal(sig), "EventBus signal " + sig)


func test_progress_unlocks_and_keeps_typed_facts() -> void:
	var path := "user://test_progress.json"
	Progress.clear(path)
	assert_eq(Progress.unlocked_chapter(path), 1, "fresh progress starts at chapter 1;")
	Progress.unlock(3, path)
	Progress.unlock(2, path)
	assert_eq(Progress.unlocked_chapter(path), 3, "unlock never locks;")
	Progress.unlock(9, path)
	assert_eq(Progress.unlocked_chapter(path), Progress.CHAPTER_COUNT, "clamped to chapter count;")
	Progress.set_fact(&"replaced_roommate", "phuc", path)
	Progress.set_fact(&"total_deviation", 4, path)
	var total: Variant = Progress.get_fact(&"total_deviation", 0, path)
	assert_eq(Progress.get_fact(&"replaced_roommate", "", path), "phuc", "string fact;")
	assert_eq(typeof(total), TYPE_INT, "int fact survives JSON;")
	assert_eq(total, 4, "int fact value;")
	assert_eq(Progress.get_fact(&"missing", 7, path), 7, "default;")
	Progress.clear(path)


func test_game_state_checkpoint_keeps_chapter() -> void:
	GameState.reset()
	GameState.chapter = 2
	var snapshot := GameState.to_dict()
	GameState.chapter = 1
	GameState.from_dict(snapshot)
	assert_eq(GameState.chapter, 2, "chapter restored;")
	GameState.from_dict({})
	assert_eq(GameState.chapter, 1, "old saves default to chapter 1;")
	GameState.reset()
	assert_eq(MessageData.load_by_id(&"no_such_message"), null, "missing message is null;")


func test_rule_evidence_pins_and_survives_checkpoint() -> void:
	var errors := RuleSystem.load_rule_set(load("res://data/rules/demo.tres"))
	assert_eq(errors.size(), 0, "demo rules load;")
	RuleSystem.set_evidence(&"knock_genuine", &"hall_board", true)
	RuleSystem.set_evidence(&"knock_genuine", &"duty_log", true)
	RuleSystem.set_evidence(&"knock_genuine", &"hall_board", true)
	assert_eq(RuleSystem.evidence_for(&"knock_genuine"), [&"hall_board", &"duty_log"] as Array[StringName], "pinned once, in order;")
	var snapshot := RuleSystem.to_dict()
	RuleSystem.set_evidence(&"knock_genuine", &"hall_board", false)
	assert_eq(RuleSystem.evidence_for(&"knock_genuine"), [&"duty_log"] as Array[StringName], "unpinned;")
	RuleSystem.from_dict(snapshot)
	assert_eq(RuleSystem.evidence_for(&"knock_genuine").size(), 2, "restored from checkpoint;")
	RuleSystem.reset()


func test_chapter_1_puzzles_load_and_check() -> void:
	var locker := PuzzleData.load_by_id(&"locker_combo_601")
	var fuse := PuzzleData.load_by_id(&"fuse_box_6")
	assert_not_null(locker, "locker puzzle")
	assert_not_null(fuse, "fuse puzzle")
	assert_true(locker.check("304") and not locker.check("403"), "combination check;")
	assert_eq(fuse.label_keys.size(), fuse.solution.length(), "one label per switch;")
	for key in fuse.label_keys + [locker.title_key, fuse.title_key]:
		assert_true(tr(key) != key, "translated " + key)


func test_chapter_1_script_data_loads_and_is_translated() -> void:
	var dir := DirAccess.open(MessageData.DIRECTORY)
	assert_not_null(dir, "messages directory")
	var count := 0
	for file in dir.get_files():
		if not file.ends_with(".tres") or not (file.begins_with("chat_ch1_") or file.begins_with("choice_ch1_")):
			continue
		var msg := MessageData.load_by_id(StringName(file.get_basename()))
		assert_not_null(msg, file)
		assert_true(tr(msg.text_key) != msg.text_key, "translated " + msg.text_key)
		assert_true(tr(msg.sender_name_key) != msg.sender_name_key, "translated " + msg.sender_name_key)
		count += 1
	assert_true(count > 40, "chapter 1 has its group-call lines;")
	for doc_id in [&"ch1_dat_note", &"ch1_dat_card", &"ch1_phuc_schedule", &"ch1_viet_photo"]:
		var doc := DocumentData.load_by_id(doc_id)
		assert_not_null(doc, String(doc_id))
		for key in doc.text_keys + [doc.title_key]:
			assert_true(tr(key) != key, "translated " + key)
	var locker := PuzzleData.load_by_id(&"locker_combo_dat")
	assert_true(locker.check("1407"), "Đạt's locker opens with his birthday;")
	assert_not_null(DocumentData.load_by_id(locker.hint_document), "locker hint document exists;")
