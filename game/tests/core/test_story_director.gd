extends TestCase
## T-117 slice: segments 1–2 run end to end at high speed, both rulings.

var main: Node
var director: Node
var subtitles: Array[String] = []


func before_each() -> void:
	main = load("res://scenes/main/main.tscn").instantiate()
	director = main.get_node("StoryDirector")
	director.auto_start = false
	director.time_scale = 0.01
	# These tests cover segments 1–2; test_story_segments_3_5.gd covers the rest.
	director.stop_after = &"seg2"
	tree.root.add_child(main)
	# Fast fixture: the real voice clips (T-137) do not follow time_scale;
	# lane E tests the voices themselves.
	main.get_node("FloorSpeaker").voice_directory = ""
	EventBus.subtitle_requested.connect(_on_subtitle)
	await wait_frames(2)


func after_each() -> void:
	EventBus.subtitle_requested.disconnect(_on_subtitle)
	for node in main.find_children("*", "AudioStreamPlayer3D", true, false):
		if node.has_method("stop_emitting"):
			node.stop_emitting()
		(node as AudioStreamPlayer3D).stop()
	main.queue_free()
	await tree.create_timer(0.5).timeout
	GameState.reset()
	RuleSystem.reset()
	Checkpoint.clear()


func _on_subtitle(text_key: String, _duration: float) -> void:
	subtitles.append(text_key)


## Walks into room 407 and latches the door (lane A's latch sets this flag).
func _settle_into_room() -> void:
	var player := main.get_node("Player") as Node3D
	player.global_position = Vector3(32, 0.03, -2.0)
	GameState.set_flag(&"door_locked", true)


func _run_slice() -> void:
	director.start()
	# The speaker's power/chime cues play in real time, so wait on the clock.
	var deadline := Time.get_ticks_msec() + 30000
	while not director.finished and Time.get_ticks_msec() < deadline:
		await tree.process_frame
	assert_true(director.finished, "slice reaches its end")


func test_lights_off_and_silence_keep_the_dorm_calm() -> void:
	_settle_into_room()
	main.get_node("Floor4/Room407/Room407MainLight").visible = false
	await _run_slice()
	assert_eq(GameState.deviation, 0, "no deviation;")
	assert_eq(RuleSystem.outcome_of(&"lights_out"), RuleSystem.OUTCOME_CORRECT, "rule 1;")
	assert_eq(RuleSystem.outcome_of(&"knock_at_door"), RuleSystem.OUTCOME_CORRECT, "rule 2;")
	assert_false(main.get_node("Floor4/Anchors/Slippers407").has_node("FifthPair"), "no fifth pair")
	assert_eq(GameState.clock_text(), "00:10", "clock reached 00:10;")
	assert_true("SUB_KNOCK_STOPPED" in subtitles, "knocking stops on its own")
	var speaker := RuleSystem.read_entries().filter(func(entry: Dictionary) -> bool:
		return entry["source"] == &"speaker")
	assert_eq(speaker.size(), 5, "five rules heard on the speaker;")
	var rule3 := speaker.filter(func(entry: Dictionary) -> bool: return entry["rule_id"] == &"slippers_genuine")
	assert_eq(rule3[0]["text_key"], "RULE_3_GARBLED", "rule 3 heard through static;")


func test_light_left_on_and_opened_door_change_the_dorm() -> void:
	_settle_into_room()
	main.get_node("Floor4/Room407/Room407MainLight").visible = true
	var door := main.get_node("Floor4/Door407")
	var open_on_knock := func(text_key: String, _duration: float) -> void:
		if text_key == "SUB_KNOCK" and not door.is_open:
			door.set_open(true)
	EventBus.subtitle_requested.connect(open_on_knock)
	await _run_slice()
	EventBus.subtitle_requested.disconnect(open_on_knock)
	assert_eq(RuleSystem.outcome_of(&"lights_out"), RuleSystem.OUTCOME_BROKE_RULE, "rule 1 broken;")
	assert_eq(RuleSystem.outcome_of(&"knock_at_door"), RuleSystem.OUTCOME_BROKE_RULE, "rule 2 broken;")
	assert_eq(GameState.deviation, 3, "1 + 2 deviation;")
	assert_true(main.get_node("Floor4/Anchors/Slippers407").has_node("FifthPair"), "fifth pair of slippers")
	assert_true(GameState.get_flag(&"corridor_light_flickering", false), "corridor light flickers")
	assert_true(GameState.get_flag(&"room_light_cut", false), "room light cut out after rule 1")
	assert_true(main.get_node("Floor4/Room407/Room407MainLight").visible, "room light comes back")


func test_fifth_pair_waits_for_the_door_to_close() -> void:
	# Rule 2 aftermath: the visitor walks away; the pair is set down only once
	# the door is shut again (or after slippers_max_wait_seconds).
	_settle_into_room()
	# Light off: only rule 2 is broken (deviation 2), so the level-3 world
	# change cannot place the pair early.
	main.get_node("Floor4/Room407/Room407MainLight").visible = false
	director.slippers_max_wait_seconds = 1000.0
	var door := main.get_node("Floor4/Door407")
	var anchor := main.get_node("Floor4/Anchors/Slippers407")
	var open_on_knock := func(text_key: String, _duration: float) -> void:
		if text_key == "SUB_KNOCK" and not door.is_open:
			door.set_open(true)
	EventBus.subtitle_requested.connect(open_on_knock)
	director.start()
	var deadline := Time.get_ticks_msec() + 30000
	while RuleSystem.outcome_of(&"knock_at_door").is_empty() and Time.get_ticks_msec() < deadline:
		await tree.process_frame
	EventBus.subtitle_requested.disconnect(open_on_knock)
	await wait_frames(20)
	assert_false(anchor.has_node("FifthPair"), "no fifth pair while the door stays open")
	assert_true(GameState.get_flag(&"visitor_walked_away", false), "visitor walks away in the corridor")
	door.set_open(false)
	deadline = Time.get_ticks_msec() + 30000
	while not director.finished and Time.get_ticks_msec() < deadline:
		await tree.process_frame
	assert_true(anchor.has_node("FifthPair"), "fifth pair set down after the door closes")


func test_checkpoints_saved_at_segment_starts() -> void:
	_settle_into_room()
	var saved: Array[StringName] = []
	var record := func(checkpoint_id: StringName) -> void: saved.append(checkpoint_id)
	EventBus.checkpoint_saved.connect(record)
	await _run_slice()
	EventBus.checkpoint_saved.disconnect(record)
	assert_eq(saved, [&"seg1_start", &"seg2_start"] as Array[StringName], "segment checkpoints;")


func test_director_follows_reduce_scares_setting() -> void:
	var path := "user://settings.cfg"
	var had := FileAccess.file_exists(path)
	var backup := FileAccess.get_file_as_bytes(path) if had else PackedByteArray()
	assert_false(director.reduce_scares, "off by default")
	assert_eq(Settings.set_value("accessibility", "reduce_scares", true), OK, "toggle on;")
	assert_true(director.reduce_scares, "director follows the setting live")
	assert_eq(Settings.set_value("accessibility", "reduce_scares", false), OK, "toggle off;")
	assert_false(director.reduce_scares, "and back")
	if had:
		var file := FileAccess.open(path, FileAccess.WRITE)
		file.store_buffer(backup)
		file.close()
	else:
		DirAccess.remove_absolute(path)
