extends TestCase
## T-150: chapter 1 flow at high speed with core stubs (no lane pieces needed).

var scene: Node
var director: Chapter1Director
var player: Node3D
var subtitles: Array[String] = []
var restarts: Array[StringName] = []


func before_each() -> void:
	scene = load("res://scenes/main/chapter1.tscn").instantiate()
	director = scene.get_node("Chapter1Director")
	director.auto_start = false
	director.time_scale = 0.002
	Chapter1Director.resume_checkpoint = &""
	tree.root.add_child(scene)
	# Fast fixture: real voice clips do not follow time_scale.
	scene.get_node("FloorSpeaker").voice_directory = ""
	player = scene.get_node("Player")
	director.restart_requested.connect(func(id: StringName) -> void: restarts.append(id))
	EventBus.subtitle_requested.connect(_on_subtitle)
	await wait_frames(2)


func after_each() -> void:
	EventBus.subtitle_requested.disconnect(_on_subtitle)
	if EventBus.segment_changed.is_connected(_latch_in_round_1):
		EventBus.segment_changed.disconnect(_latch_in_round_1)
	if EventBus.chat_choice_requested.is_connected(_answer_choices):
		EventBus.chat_choice_requested.disconnect(_answer_choices)
	for node in scene.find_children("*", "AudioStreamPlayer3D", true, false):
		if node.has_method("stop_emitting"):
			node.stop_emitting()
		(node as AudioStreamPlayer3D).stop()
	scene.queue_free()
	await tree.create_timer(0.3).timeout
	subtitles.clear()
	restarts.clear()
	GameState.reset()
	RuleSystem.reset()
	Checkpoint.clear()
	Chapter1Director.manager_deaths = 0


func _on_subtitle(text_key: String, _duration: float) -> void:
	subtitles.append(text_key)


func _until(condition: Callable, seconds: float = 20.0) -> void:
	var deadline := Time.get_ticks_msec() + int(seconds * 1000.0)
	while not condition.call() and Time.get_ticks_msec() < deadline:
		await tree.process_frame


## Holds the door (N4) as soon as round 1 starts, and gives the right advice
## to Minh Nhật (N7) when asked: the good path of chapter 1 v2.
func _play_well() -> void:
	EventBus.segment_changed.connect(_latch_in_round_1)
	EventBus.chat_choice_requested.connect(_answer_choices)


func _latch_in_round_1(segment: StringName) -> void:
	if segment == &"r1":
		(func() -> void: GameState.set_flag(&"door_locked", true)).call_deferred()
	# N6: the desk lamp goes off before the manager comes (D-039).
	if segment in [&"r2", &"r2_manager"]:
		(func() -> void:
			var room := scene.get_node_or_null("Floor4/Room407")
			if room != null and room.has_method("set_desk_lamp"):
				room.set_desk_lamp(false)
			GameState.set_flag(&"desk_lamp_on", false)).call_deferred()


func _answer_choices(choice_id: StringName, _keys: PackedStringArray) -> void:
	(func() -> void: EventBus.chat_choice_made.emit(choice_id, 0)).call_deferred()


func _start(stage: StringName, stop: StringName) -> void:
	director.stop_after = stop
	var errors := RuleSystem.load_rule_set(load(Chapter1Director.RULE_SET_PATH))
	assert_eq(errors.size(), 0, "chapter 1 rules valid;")
	director.run_from(stage)


func test_staying_in_bed_at_four_kills() -> void:
	_start(&"prologue", &"prologue")
	await _until(func() -> bool: return not restarts.is_empty())
	assert_eq(restarts, [&"ch1_prologue"] as Array[StringName], "reload at the prologue;")
	assert_true(subtitles.has("SPK_CH1_WARN"), "the speaker warned first;")


func test_getting_up_survives_and_hears_the_general_rules() -> void:
	_start(&"prologue", &"prologue")
	await _until(func() -> bool: return GameState.get_flag(&"player_bed", 0) == 3)
	director.get_up()
	assert_eq(GameState.get_flag(&"player_bed", -1), 0, "out of bed;")
	await _until(func() -> bool: return director.finished)
	assert_true(director.finished, "prologue ends;")
	assert_true(restarts.is_empty(), "nobody died;")
	assert_eq(GameState.get_flag(&"roommates_dead", false), true, "the roommates died;")
	for n in range(1, 6):
		assert_true(RuleSystem.is_read(StringName("ch1_general_%d" % n)), "rule book has General Rule %d;" % n)


func test_stepping_out_of_407_in_round_1_kills() -> void:
	_start(&"r1", &"r1")
	await _until(func() -> bool: return GameState.segment == &"r1")
	await wait_frames(3)
	player.global_position = Vector3(32.0, 0.05, 1.2)
	await _until(func() -> bool: return not restarts.is_empty())
	assert_eq(restarts, [&"ch1_r1"] as Array[StringName], "reload at round 1;")


func test_round_1_group_call_and_survivor_count() -> void:
	var counts: Array[int] = []
	var members: Array[StringName] = []
	var on_count := func(n: int) -> void: counts.append(n)
	var on_member := func(id: StringName, state: StringName) -> void:
		if state == &"dead":
			members.append(id)
	EventBus.survivor_count_changed.connect(on_count)
	EventBus.chat_member_changed.connect(on_member)
	_play_well()
	_start(&"r1", &"r1")
	await _until(func() -> bool: return director.finished, 40.0)
	EventBus.survivor_count_changed.disconnect(on_count)
	EventBus.chat_member_changed.disconnect(on_member)
	assert_true(director.finished, "round 1 ends;")
	assert_eq(counts, [Chapter1Director.SURVIVORS_R1] as Array[int], "352 after round 1;")
	assert_eq(members, [&"tung"] as Array[StringName], "Tùng dies for leaving his room;")


func test_solving_dats_locker_enables_the_charger() -> void:
	var socket := director.get_node("ChargerSocket") as StoryTrigger
	assert_false(socket.enabled, "no charger yet;")
	EventBus.puzzle_solved.emit(&"locker_combo_dat")
	assert_true(socket.enabled, "the socket takes the charger;")
	socket.interact(player)
	assert_eq(GameState.get_flag(&"charging", false), true, "charging;")


func _manager_scene(bed: int) -> void:
	_start(&"r2_manager", &"r2_manager")
	await _until(func() -> bool: return GameState.segment == &"r2_manager")
	if bed > 0:
		director.lie_on(bed)


func test_manager_kills_on_your_own_bed() -> void:
	await _manager_scene(3)
	await _until(func() -> bool: return not restarts.is_empty(), 40.0)
	assert_eq(restarts, [&"ch1_r2"] as Array[StringName], "Insane: reload at the start of round 2;")
	assert_eq(Chapter1Director.manager_deaths, 1, "death counted for hints;")


func test_manager_kills_when_not_in_bed() -> void:
	await _manager_scene(0)
	await _until(func() -> bool: return not restarts.is_empty(), 20.0)
	assert_eq(restarts, [&"ch1_r2"] as Array[StringName], "standing up dies;")


func test_manager_hears_a_breath() -> void:
	await _manager_scene(4)
	await _until(func() -> bool: return GameState.segment == &"r2_listen", 40.0)
	EventBus.noise_emitted.emit(Vector3(33.35, 1.2, -3.0), 1.5, &"breath")
	await _until(func() -> bool: return not restarts.is_empty(), 20.0)
	assert_eq(restarts, [&"ch1_r2"] as Array[StringName], "a breath near him kills;")


func test_breathing_on_any_bed_is_heard_in_the_silence() -> void:
	await _manager_scene(2)
	await _until(func() -> bool: return GameState.segment == &"r2_listen", 40.0)
	EventBus.noise_emitted.emit(Vector3(30.65, 0.43, -3.0), 1.5, &"breath")
	await _until(func() -> bool: return not restarts.is_empty(), 20.0)
	assert_eq(restarts, [&"ch1_r2"] as Array[StringName], "within four metres of his head;")


func test_dead_roommates_bed_and_silence_survive() -> void:
	_play_well()
	await _manager_scene(2)
	_latch_in_round_1(&"r2_manager")
	await _until(func() -> bool: return GameState.segment == &"r2_listen", 40.0)
	Input.action_press("hold_breath")
	await _until(func() -> bool: return GameState.segment != &"r2_listen", 20.0)
	Input.action_release("hold_breath")
	await _until(func() -> bool: return director.finished or not restarts.is_empty(), 60.0)
	assert_true(director.finished, "the manager leaves;")
	assert_true(restarts.is_empty(), "alive;")
	assert_eq(GameState.get_flag(&"ch1_choice_tell", -1), 0, "Trung tells Minh Nhật the trick;")
	var room := scene.get_node("Floor4/Room407")
	assert_true(scene.get_node_or_null("Chapter1Director/Manager") == null, "he walked out;")
	assert_not_null(room, "room;")


func test_ending_unlocks_chapter_2() -> void:
	var path := Progress.DEFAULT_PATH
	Progress.clear(path)
	var done: Array[int] = []
	var on_done := func(chapter: int) -> void: done.append(chapter)
	EventBus.chapter_finished.connect(on_done)
	_start(&"end", &"end")
	await _until(func() -> bool: return director.finished, 30.0)
	EventBus.chapter_finished.disconnect(on_done)
	assert_eq(done, [1] as Array[int], "chapter 1 finished;")
	assert_eq(Progress.unlocked_chapter(path), 2, "chapter 2 unlocked;")
	assert_eq(GameState.get_flag(&"survivors", 0), Chapter1Director.SURVIVORS_R2, "28 left;")
	Progress.clear(path)


func test_resume_from_checkpoint_places_player_in_room() -> void:
	GameState.reset()
	GameState.set_segment(&"r2")
	Checkpoint.save(&"ch1_r2")
	Chapter1Director.resume_checkpoint = &"ch1_r2"
	director.stop_after = &"r2"
	player.global_position = Vector3(10, 0.05, 1.0)
	director.start()
	await wait_frames(3)
	assert_eq(GameState.segment, &"r2", "resumed at round 2;")
	assert_true(director._player_in_room(), "back inside 407;")
	assert_eq(Chapter1Director.resume_checkpoint, &"", "resume consumed;")


func test_whole_chapter_runs_to_the_end() -> void:
	Progress.clear()
	_play_well()
	director.start()
	await _until(func() -> bool: return GameState.get_flag(&"player_bed", 0) == 3)
	director.get_up()
	await _until(func() -> bool: return GameState.segment == &"r2_manager", 90.0)
	director.lie_on(2)
	await _until(func() -> bool: return GameState.segment == &"r2_listen", 60.0)
	Input.action_press("hold_breath")
	await _until(func() -> bool: return GameState.segment != &"r2_listen", 20.0)
	Input.action_release("hold_breath")
	await _until(func() -> bool: return director.finished, 90.0)
	assert_true(director.finished, "chapter 1 plays to its end;")
	assert_true(restarts.is_empty(), "no death on the good path;")
	assert_eq(Progress.unlocked_chapter(), 2, "chapter 2 unlocked;")
	Progress.clear()


func test_every_chapter_1_line_has_a_voice() -> void:
	var missing: Array[String] = []
	for line in FileAccess.get_file_as_string("res://localization/strings.csv").split("\n"):
		var key := line.get_slice(",", 0)
		if key.begins_with("CHAT_CH1_") or key.begins_with("MGR_CH1_") or key.begins_with("ROOM_CH1_"):
			var prefix := key.substr(0, key.find("_CH1_") + 5)
			if Ch1AudioBank.voice(key, prefix) == null:
				missing.append(key)
		elif key.begins_with("SPK_CH1_") or key.begins_with("RULE_CH1_"):
			for locale in ["vi", "en"]:
				if SpeakerVoiceBank.load_clip("res://audio/voice", locale, key) == null:
					missing.append(locale + "/" + key)
	assert_eq(missing, [] as Array[String], "voiced lines;")


func test_tap_code_round_trip() -> void:
	var groups := Chapter1Director.encode_taps("CO")
	assert_eq(groups, [[1, 3], [3, 4]], "C = row 1 col 3, O = row 3 col 4;")
	var times: Array[float] = []
	var t := 0.0
	for pair: Array in groups:
		for digit: int in pair:
			for knock in digit:
				times.append(t)
				t += 0.3
			t += 1.0
		t += 1.5
	assert_eq(Chapter1Director.decode_taps(times), "CO", "decodes the reply;")
	assert_eq(Chapter1Director.decode_taps([] as Array[float]), "", "no taps;")


func test_late_latch_drags_you_out() -> void:
	var kinds: Array[StringName] = []
	var on_kind := func(kind: StringName) -> void: kinds.append(kind)
	EventBus.player_death_started.connect(on_kind)
	_start(&"r1", &"r1")
	await _until(func() -> bool: return not restarts.is_empty(), 40.0)
	EventBus.player_death_started.disconnect(on_kind)
	assert_eq(restarts, [&"ch1_r1"] as Array[StringName], "back to the start of round 1;")
	assert_eq(kinds, [&"fall_back"] as Array[StringName], "falls back with blood (D-042);")


func test_wrong_advice_loses_minh_nhat() -> void:
	var on_choice := func(choice_id: StringName, _keys: PackedStringArray) -> void:
		(func() -> void: EventBus.chat_choice_made.emit(choice_id, 2 if choice_id == &"tell" else 0)).call_deferred()
	EventBus.chat_choice_requested.connect(on_choice)
	await _manager_scene(2)
	await _until(func() -> bool: return GameState.segment == &"r2_listen", 40.0)
	Input.action_press("hold_breath")
	await _until(func() -> bool: return GameState.segment != &"r2_listen", 20.0)
	Input.action_release("hold_breath")
	await _until(func() -> bool: return not restarts.is_empty(), 60.0)
	EventBus.chat_choice_requested.disconnect(on_choice)
	assert_eq(restarts, [&"ch1_r2"] as Array[StringName], "Minh Nhật dies, round 2 again;")


func test_desk_lamp_gives_you_away() -> void:
	GameState.set_flag(&"desk_lamp_on", true)
	await _manager_scene(2)
	await _until(func() -> bool: return not restarts.is_empty(), 30.0)
	assert_eq(restarts, [&"ch1_r2"] as Array[StringName], "the manager sees the light;")


func test_network_fix_needs_switch_two_and_the_blue_cable() -> void:
	director._network_down()
	assert_false(director._network_up, "down;")
	director._on_strip_switch(3, true)
	await wait_frames(2)
	assert_false(director._network_up, "the kettle trips the strip;")
	director._on_strip_switch(2, true)
	await _until(func() -> bool: return not director._router_booting, 5.0)
	assert_false(director._network_up, "router up but the cable is out;")
	director._on_cable_plugged(&"gray")
	assert_false(director._network_up, "the gray cable is Việt's laptop;")
	director._on_cable_plugged(&"blue")
	await wait_frames(2)
	assert_true(director._network_up, "back online;")


func test_three_scraps_make_the_form() -> void:
	var opened: Array[StringName] = []
	var on_open := func(id: StringName) -> void: opened.append(id)
	EventBus.document_opened.connect(on_open)
	for n in range(1, 4):
		EventBus.document_opened.emit(StringName("ch1_form_piece_%d" % n))
		EventBus.document_closed.emit(StringName("ch1_form_piece_%d" % n))
	await wait_frames(2)
	EventBus.document_opened.disconnect(on_open)
	assert_true(opened.has(&"ch1_inspection_form"), "the whole form opens;")
	assert_eq(GameState.get_flag(&"form_assembled", false), true, "assembled;")


func test_idle_waits_are_cut_when_the_round_is_done() -> void:
	director._missions.clear()
	director._missions[&"locker"] = false
	assert_false(director._round_done(), "locker still shut;")
	GameState.set_flag(&"has_charger", true)
	assert_true(director._round_done(), "every active mission done;")
	var started := Time.get_ticks_msec()
	director.time_scale = 1.0
	await director._gap(30.0)
	assert_true(Time.get_ticks_msec() - started < 2000, "the 30 s gap is skipped (D-040);")


func test_door_flicker_keeps_the_desk_lamp_off() -> void:
	# N6: the manager's flicker must not relight the lamp the player switched off.
	var room := scene.get_node("Floor4/Room407")
	var lamp := room.get_node("Room407DeskLamp") as Node3D
	lamp.visible = false
	await wait_frames(2)
	assert_eq(GameState.get_flag(&"desk_lamp_on", null), false, "lamp off;")
	director._set_flicker(true)
	await wait_frames(3)
	assert_eq(GameState.get_flag(&"desk_lamp_on", null), false, "still off while the ceiling light flickers;")
	director._set_flicker(false)
