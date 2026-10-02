extends TestCase
## T-136: segments 3–5, losing/resuming and the two endings, at high speed.

var main: Node
var director: Node
var player: CharacterBody3D
var subtitles: Array[String] = []
var restarts: Array[StringName] = []
var _hooks: Array[Callable] = []
const DIRECTOR_SCRIPT := preload("res://scripts/core/story_director.gd")


func before_each() -> void:
	tree.paused = false
	for action in ["interact", "move_forward", "sprint"]:
		Input.action_release(action)
	main = load("res://scenes/main/main.tscn").instantiate()
	director = main.get_node("StoryDirector")
	director.auto_start = false
	director.time_scale = 0.01
	tree.root.add_child(main)
	player = main.get_node("Player")
	EventBus.subtitle_requested.connect(_on_subtitle)
	director.restart_requested.connect(_on_restart)
	RuleSystem.load_rule_set(load("res://data/rules/demo.tres"))
	GameState.reset()
	await wait_frames(2)


func after_each() -> void:
	EventBus.subtitle_requested.disconnect(_on_subtitle)
	for hook in _hooks:
		if EventBus.subtitle_requested.is_connected(hook):
			EventBus.subtitle_requested.disconnect(hook)
	_hooks.clear()
	DIRECTOR_SCRIPT.resume_checkpoint = &""
	DIRECTOR_SCRIPT.carry_deviation = 0
	for node in main.find_children("*", "AudioStreamPlayer3D", true, false):
		if node.has_method("stop_emitting"):
			node.stop_emitting()
		(node as AudioStreamPlayer3D).stop()
	main.queue_free()
	await tree.create_timer(0.5).timeout
	tree.paused = false
	GameState.reset()
	RuleSystem.reset()
	Checkpoint.clear()


func _on_subtitle(text_key: String, _duration: float) -> void:
	subtitles.append(text_key)


func _on_restart(checkpoint_id: StringName) -> void:
	restarts.append(checkpoint_id)


func _place(position: Vector3, yaw: float) -> void:
	player.global_position = position
	player.rotation.y = yaw
	player.velocity = Vector3.ZERO
	player.get_node("Head").rotation.x = 0.0


func _run(segment: StringName) -> void:
	director.stop_after = segment
	director.run_from(segment)
	var deadline := Time.get_ticks_msec() + 30000
	while not director.finished and restarts.is_empty() and Time.get_ticks_msec() < deadline:
		await tree.process_frame


func _hook(callable: Callable) -> void:
	_hooks.append(callable)
	EventBus.subtitle_requested.connect(callable)


func _press_interact() -> void:
	if not is_instance_valid(director):
		return
	var event := InputEventAction.new()
	event.action = &"interact"
	event.pressed = true
	director._input(event)


# --- Segment 3 -----------------------------------------------------------------

func test_seg3_walking_on_to_the_room_is_correct() -> void:
	GameState.set_flag(&"read_duty_log", true)
	_place(Vector3(32, 0.03, -2.0), 0.0)
	await _run(&"seg3")
	assert_eq(RuleSystem.outcome_of(&"footsteps_behind"), RuleSystem.OUTCOME_CORRECT, "rule 3 kept;")
	assert_eq(GameState.deviation, 0, "no deviation;")
	assert_eq(GameState.get_flag(&"signed_log"), true, "log signed;")


func test_seg3_turning_around_and_standing_gets_you_caught() -> void:
	GameState.set_flag(&"read_duty_log", true)
	# In the corridor, facing east: toward the slippers behind.
	_place(Vector3(36, 0.03, 1.2), -PI / 2.0)
	await _run(&"seg3")
	assert_eq(RuleSystem.outcome_of(&"footsteps_behind"), RuleSystem.OUTCOME_FOLLOWED_FAKE, "turned around;")
	assert_eq(GameState.deviation, 2, "fake rule 3 penalty;")
	assert_eq(GameState.get_flag(&"lights_off_behind"), true, "lights behind go out;")
	assert_false(main.get_node("Floor4/Corridor/CorridorLight_Desk").visible, "desk light died behind the chase;")
	assert_eq(restarts, [&"seg3_start"] as Array[StringName], "caught: back to the segment start;")
	assert_eq(DIRECTOR_SCRIPT.carry_deviation, 1, "being caught costs one deviation")


func test_seg3_chase_ends_in_the_lit_corridor() -> void:
	GameState.set_flag(&"read_duty_log", true)
	_place(Vector3(36, 0.03, 1.2), -PI / 2.0)
	var flee := func(consequence: StringName, _rule_id: StringName) -> void:
		if consequence == &"light_off_behind":
			(func() -> void:
				await wait_frames(2)
				_place(Vector3(20, 0.03, 1.2), PI / 2.0)).call()
	EventBus.consequence_triggered.connect(flee)
	await _run(&"seg3")
	EventBus.consequence_triggered.disconnect(flee)
	assert_true(restarts.is_empty(), "not caught;")
	assert_eq(GameState.get_flag(&"chase_escaped"), true, "escaped;")
	assert_true(main.get_node("Floor4/Corridor/CorridorLight_Desk").visible, "lights come back;")
	assert_true(director.finished, "the night goes on")


func test_seg3_standing_still_breaks_the_rule() -> void:
	GameState.set_flag(&"read_duty_log", true)
	_place(Vector3(36, 0.03, 1.2), PI / 2.0)
	await _run(&"seg3")
	assert_eq(RuleSystem.outcome_of(&"footsteps_behind"), RuleSystem.OUTCOME_BROKE_RULE, "stopped and waited;")
	assert_eq(GameState.deviation, 1, "genuine rule 3 penalty;")


# --- Segment 4 -----------------------------------------------------------------

func _answer_on(names: Array[String]) -> void:
	var answer := func(text_key: String, _duration: float) -> void:
		if text_key in names:
			_press_interact()
	_hook(answer)


func test_seg4_answering_only_your_name_is_correct() -> void:
	_place(Vector3(32.9, 0.03, -1.25), 0.0)
	_answer_on(["SPK_NAME_TRUNG"])
	await _run(&"seg4")
	assert_eq(RuleSystem.outcome_of(&"roll_call_self"), RuleSystem.OUTCOME_CORRECT, "own name;")
	assert_eq(RuleSystem.outcome_of(&"roll_call_roommate"), RuleSystem.OUTCOME_CORRECT, "roommates left silent;")
	assert_eq(RuleSystem.outcome_of(&"roll_call_fifth"), RuleSystem.OUTCOME_CORRECT, "Lam left silent;")
	assert_eq(GameState.deviation, 0, "no deviation;")
	assert_true(main.get_node("Floor4/Anchors/HallBoardNote/HallBoardNoteReadable").visible, "note on the board")


func test_seg4_answering_for_a_roommate_stirs_the_net() -> void:
	_place(Vector3(32.9, 0.03, -1.25), 0.0)
	_answer_on(["SPK_NAME_TRUNG", "SPK_NAME_VIET"])
	await _run(&"seg4")
	assert_eq(GameState.deviation, 1, "answered for a roommate;")
	assert_eq(GameState.get_flag(&"net_stirred"), true, "a net stirs")


func test_seg4_silence_on_your_name_gets_a_second_call() -> void:
	_place(Vector3(32.9, 0.03, -1.25), 0.0)
	_answer_on(["SPK_NAME_TRUNG_AGAIN"])
	await _run(&"seg4")
	assert_true("SPK_NAME_TRUNG_AGAIN" in subtitles, "name read again;")
	assert_eq(RuleSystem.outcome_of(&"roll_call_self"), RuleSystem.OUTCOME_CORRECT, "late answer counts;")
	assert_eq(GameState.deviation, 0, "no deviation")


func test_seg4_silence_twice_breaks_the_rule() -> void:
	_place(Vector3(32.9, 0.03, -1.25), 0.0)
	await _run(&"seg4")
	assert_eq(RuleSystem.outcome_of(&"roll_call_self"), RuleSystem.OUTCOME_BROKE_RULE, "never answered;")
	assert_eq(GameState.deviation, 1, "genuine rule 4 penalty")


func test_losing_on_deviation_says_why() -> void:
	GameState.set_segment(&"seg4")
	GameState.add_deviation(5, &"test")
	var deadline := Time.get_ticks_msec() + 10000
	while restarts.is_empty() and Time.get_ticks_msec() < deadline:
		await tree.process_frame
	assert_eq(restarts, [&"seg4_start"] as Array[StringName], "reload;")
	assert_eq(director._overlay_why.text, "SUB_FAIL_WHY_DEVIATION", "the card explains the loss")


func test_seg4_answering_lam_loses_and_resumes_at_seg4() -> void:
	_place(Vector3(32.9, 0.03, -1.25), 0.0)
	_answer_on(["SPK_NAME_TRUNG", "SPK_NAME_LAM"])
	await _run(&"seg4")
	assert_eq(restarts, [&"seg4_start"] as Array[StringName], "reload from the roll call;")
	assert_false(director.finished, "the night does not go on")


# --- Segment 5 -----------------------------------------------------------------

func test_seg5_freezing_at_the_mirror_gets_you_caught() -> void:
	director.mirror_flee_seconds = 0.5
	_place(Vector3(2.0, 0.03, -1.85), PI / 2.0)
	await _run(&"seg5")
	assert_eq(RuleSystem.outcome_of(&"tap_running"), RuleSystem.OUTCOME_FOLLOWED_FAKE, "looked in the mirror;")
	assert_eq(GameState.deviation, 2, "fake rule 6 penalty;")
	assert_eq(restarts, [&"seg5_start"] as Array[StringName], "caught at the mirror;")


func test_seg5_running_to_the_latched_room_escapes() -> void:
	_place(Vector3(2.0, 0.03, -1.85), PI / 2.0)
	var mirror := main.get_node("Floor4/Washroom/Mirror")
	var flee := func(text_key: String, _duration: float) -> void:
		if text_key == "SUB_RUN_TO_ROOM":
			(func() -> void:
				assert_true(mirror.is_staring, "the reflection stares")
				_place(Vector3(9.0, 0.03, 1.2), -PI / 2.0)
				await tree.create_timer(0.6).timeout
				GameState.set_flag(&"door_locked", true)
				_place(Vector3(32.0, 0.03, -2.5), 0.0)).call()
	_hook(flee)
	await _run(&"seg5")
	assert_true(restarts.is_empty(), "not caught;")
	assert_eq(GameState.get_flag(&"chase_escaped"), true, "escaped into room 407;")
	assert_false(mirror.is_staring, "mirror released;")
	assert_true(main.get_node("Floor4/Corridor/CorridorLight_401").visible, "lights come back")


func test_seg5_closing_the_tap_and_leaving_is_correct() -> void:
	# Facing east, away from the mirror.
	_place(Vector3(2.0, 0.03, -2.5), -PI / 2.0)
	var close_and_leave := func(text_key: String, _duration: float) -> void:
		if text_key == "SPK_CHECK_TAPS":
			(func() -> void:
				# The tap starts running once the announcement is over.
				while GameState.get_flag(&"tap_running", false) != true:
					await tree.process_frame
				main.get_node("Floor4/Anchors/WashroomTapRunning/TapTrigger").interact(player)
				await wait_frames(3)
				player.global_position = Vector3(8.0, 0.03, 1.2)).call()
	_hook(close_and_leave)
	await _run(&"seg5")
	assert_eq(RuleSystem.outcome_of(&"tap_running"), RuleSystem.OUTCOME_CORRECT, "closed and left;")
	assert_eq(GameState.deviation, 0, "no deviation;")


func test_seg5_leaving_the_tap_running_breaks_the_rule() -> void:
	_place(Vector3(2.0, 0.03, -2.5), -PI / 2.0)
	var leave := func(text_key: String, _duration: float) -> void:
		if text_key == "SPK_CHECK_TAPS":
			(func() -> void:
				await wait_frames(3)
				player.global_position = Vector3(8.0, 0.03, 1.2)).call()
	_hook(leave)
	await _run(&"seg5")
	assert_eq(RuleSystem.outcome_of(&"tap_running"), RuleSystem.OUTCOME_BROKE_RULE, "left it running;")
	assert_eq(GameState.deviation, 1, "genuine rule 5 penalty;")


# --- Deviation, endings, resuming ------------------------------------------------

func test_deviation_changes_the_floor_and_level_five_loses() -> void:
	GameState.set_segment(&"seg3")
	GameState.add_deviation(2, &"test")
	assert_false(main.get_node("Floor4/Corridor/CorridorLight_403").visible, "level 2: dark section")
	GameState.add_deviation(1, &"test")
	assert_true(main.get_node("Floor4/Anchors/Slippers407").has_node("FifthPair"), "level 3: fifth pair")
	assert_true(main.get_node("Floor4/Anchors/ClotheslineExtraShirt").has_node("ExtraShirt"), "level 3: white shirt")
	GameState.add_deviation(1, &"test")
	assert_eq(GameState.get_flag(&"fan_slow"), true, "level 4: fan labours")
	GameState.add_deviation(1, &"test")
	var deadline := Time.get_ticks_msec() + 10000
	while restarts.is_empty() and Time.get_ticks_msec() < deadline:
		await tree.process_frame
	assert_eq(restarts, [&"seg3_start"] as Array[StringName], "level 5 loses, back to the segment start;")


func test_calm_night_ends_with_one_more_name() -> void:
	_place(Vector3(32, 0.03, -2.0), 0.0)
	await _run(&"end")
	assert_eq(GameState.get_flag(&"ending_variant"), 1, "calm ending;")
	assert_true("SPK_AND_ONE_MORE" in subtitles, "...and one more")
	assert_true(director.finished, "night finished")


func test_deviant_night_calls_lam_in_trungs_place() -> void:
	GameState.add_deviation(3, &"test")
	_place(Vector3(32, 0.03, -2.0), 0.0)
	await _run(&"end")
	assert_eq(GameState.get_flag(&"ending_variant"), 2, "taken ending;")
	assert_true("SPK_NAME_LAM" in subtitles and "SPK_AND_TRUNG" in subtitles, "Lam in the list, Trung called last")


func test_resume_from_checkpoint_after_reload() -> void:
	GameState.set_segment(&"seg4")
	GameState.set_time(25 * 60)
	GameState.add_deviation(1, &"test")
	assert_eq(Checkpoint.save(&"seg4_start"), OK, "save;")
	GameState.reset()
	director.resume_checkpoint = &"seg4_start"
	director.stop_after = &"seg4"
	director.start()
	await wait_frames(3)
	assert_eq(GameState.segment, &"seg4", "resumed at the roll call;")
	assert_eq(GameState.deviation, 1, "deviation restored;")
	assert_true(player.global_position.distance_to(main.get_node("Floor4/Anchors/seg4_start").global_position) < 0.05,
		"player placed at the checkpoint")
	assert_eq(director.resume_checkpoint, &"", "resume consumed")


func test_caught_penalty_survives_the_reload() -> void:
	GameState.set_segment(&"seg3")
	GameState.add_deviation(3, &"test")
	assert_eq(Checkpoint.save(&"seg3_start"), OK, "save;")
	GameState.reset()
	director.resume_checkpoint = &"seg3_start"
	DIRECTOR_SCRIPT.carry_deviation = 2
	director.stop_after = &"seg3"
	director.start()
	await wait_frames(3)
	assert_eq(GameState.deviation, 4, "carried, but never to the losing level;")
	assert_eq(DIRECTOR_SCRIPT.carry_deviation, 0, "carry consumed")


func test_chases_and_scares_are_announced() -> void:
	var events: Array[String] = []
	var on_scare := func(id: StringName) -> void: events.append("scare:" + id)
	var on_start := func(id: StringName) -> void: events.append("start:" + id)
	var on_end := func(id: StringName, caught: bool) -> void: events.append("end:%s:%s" % [id, caught])
	EventBus.scare_triggered.connect(on_scare)
	EventBus.chase_started.connect(on_start)
	EventBus.chase_ended.connect(on_end)
	GameState.set_flag(&"read_duty_log", true)
	_place(Vector3(36, 0.03, 1.2), -PI / 2.0)
	await _run(&"seg3")
	EventBus.scare_triggered.disconnect(on_scare)
	EventBus.chase_started.disconnect(on_start)
	EventBus.chase_ended.disconnect(on_end)
	assert_eq(events, ["scare:corridor_glimpse", "start:corridor", "end:corridor:true"] as Array[String], "music hooks")
