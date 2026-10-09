extends TestCase
## D-072, chapter 2 round 3: with all three corpses gagged and two loop words
## typed, Minh Nhật and Ngư ask how to pass and Trung texts them (choice 1 is
## right); the round ends at the fourth loop word. Runs on the real scene.

var scene: Node
var director: Chapter2Director
var restarts: Array[StringName] = []
var failed: Array[StringName] = []
var lines: Array[StringName] = []
var dead: Array[StringName] = []
var raised: Array[bool] = []
var choices: Array[Dictionary] = []
var requests := 0
## Index sent for the tell choice; -1 sends nothing (the 10 seconds run out).
var answer := 0
## Hold the answer back and check that the chain waits meanwhile.
var hold_seconds := 0.0
var chain_waited := true


func before_each() -> void:
	scene = load("res://scenes/main/chapter2.tscn").instantiate()
	director = scene.get_node("Chapter2Director")
	director.auto_start = false
	director.time_scale = 0.002
	Chapter1Director.resume_checkpoint = &""
	tree.root.add_child(scene)
	scene.get_node("FloorSpeaker").voice_directory = ""
	restarts.clear()
	failed.clear()
	lines.clear()
	dead.clear()
	raised.clear()
	choices.clear()
	requests = 0
	answer = 0
	hold_seconds = 0.0
	chain_waited = true
	director.restart_requested.connect(func(id: StringName) -> void: restarts.append(id))
	EventBus.player_failed.connect(_on_failed)
	EventBus.phone_message_received.connect(_on_message)
	EventBus.chat_member_changed.connect(_on_member)
	EventBus.phone_raised.connect(_on_raised)
	EventBus.chain_input_requested.connect(_on_request)
	EventBus.chat_choice_requested.connect(_on_choice)
	RuleSystem.load_rule_set(load(Chapter2Director.CH2_RULE_SET))
	await wait_frames(2)


func after_each() -> void:
	EventBus.player_failed.disconnect(_on_failed)
	EventBus.phone_message_received.disconnect(_on_message)
	EventBus.chat_member_changed.disconnect(_on_member)
	EventBus.phone_raised.disconnect(_on_raised)
	EventBus.chain_input_requested.disconnect(_on_request)
	EventBus.chat_choice_requested.disconnect(_on_choice)
	scene.queue_free()
	await wait_frames(2)


func _on_failed(reason: StringName) -> void:
	failed.append(reason)


func _on_message(id: StringName) -> void:
	lines.append(id)


func _on_member(member: StringName, state: StringName) -> void:
	if state == &"dead":
		dead.append(member)


func _on_raised(value: bool) -> void:
	raised.append(value)


## Trung always has a legal word: the loop once everyone is gagged.
func _on_request(_seconds: float) -> void:
	requests += 1
	var word := director.suggest_word()
	(func() -> void: EventBus.chain_word_typed.emit(word)).call_deferred()


func _on_choice(id: StringName, keys: PackedStringArray) -> void:
	choices.append({"id": id, "keys": keys, "turns": director._turns, "requests": requests})
	if hold_seconds > 0.0:
		await tree.create_timer(hold_seconds).timeout
		# No turn opened and the choice is still waiting for Trung.
		chain_waited = requests == choices[0].requests and director._choice_index == -2
	if answer >= 0:
		EventBus.chat_choice_made.emit(id, answer)


func _until(condition: Callable, seconds: float = 30.0) -> void:
	var deadline := Time.get_ticks_msec() + int(seconds * 1000.0)
	while not condition.call() and Time.get_ticks_msec() < deadline:
		await wait_frames(1)


## Plays round 3 up to the point where every corpse is gagged.
func _gag_all(beds: Array = [1, 2, 4]) -> void:
	director.run_from(&"r3")
	await _until(func() -> bool: return director._turns >= 2)
	for bed: int in beds:
		assert_true(director.gag(bed), "gag %d" % bed)


func _has_line(id: String) -> bool:
	return StringName("chat_ch2_" + id) in lines


func test_two_loop_words_open_the_tell_choice_and_the_chain_waits() -> void:
	director.time_scale = 0.05
	hold_seconds = 0.2
	await _gag_all()
	await _until(func() -> bool: return not choices.is_empty() or not restarts.is_empty())
	assert_eq(choices.size(), 1, "one choice;")
	assert_eq(choices[0].id, &"tell")
	assert_eq(choices[0].keys, PackedStringArray(["CHOICE_CH2_TELL_1", "CHOICE_CH2_TELL_2", "CHOICE_CH2_TELL_3", "CHOICE_CH2_TELL_4"]))
	assert_eq(director._loop_run, 2, "after two loop words;")
	assert_true(_has_line("n_how") and _has_line("ngu_how"), "the friends ask first")
	assert_false(_has_line("n_told"), "not answered yet")
	await _until(func() -> bool: return _has_line("ngu_told") or not restarts.is_empty())
	assert_true(chain_waited, "the chain waited for the choice (no turn opened);")
	assert_true(raised.has(true), "the phone is raised for the choice;")


func test_choice_one_plays_on_and_the_fourth_loop_word_ends_round_3() -> void:
	await _gag_all()
	await _until(func() -> bool: return str(GameState.segment) == "r4" or not restarts.is_empty(), 60.0)
	assert_eq(str(GameState.segment), "r4", "on to 7:00;")
	assert_eq(director._loop_run, Chapter2Director.R3_LOOP_PASS, "ended on the fourth loop word;")
	assert_eq(choices.size(), 1, "asked once in this run;")
	assert_true(director._tell_done)
	assert_true(_has_line("n_told") and _has_line("ngu_told"), "the friends do as told")
	assert_false(_has_line("n_caught"))
	assert_eq(GameState.get_flag(&"ch2_choice_tell", -9), 0, "choice 1;")
	assert_eq(failed, [] as Array[StringName], "alive;")
	assert_eq(dead, [] as Array[StringName], "friends alive;")
	assert_true(restarts.is_empty(), "no reload")
	assert_true(director._turns < Chapter2Director.R3_TURNS, "ended early (%d turns)" % director._turns)


func _wrong_tell(index: int) -> void:
	answer = index
	await _gag_all()
	await _until(func() -> bool: return not restarts.is_empty(), 60.0)
	assert_eq(choices.size(), 1, "asked once;")
	assert_eq(failed, [&"DEATH_CH2_LOST_FRIENDS"] as Array[StringName], "lost the friends;")
	assert_eq(restarts, [&"ch2_r3"] as Array[StringName], "round 3 again;")
	assert_true(dead.has(&"minh_nhat") and dead.has(&"ngu"), "both friends die in the call;")
	assert_true(_has_line("n_caught"), "Minh Nhật is caught")
	assert_false(_has_line("n_told") or _has_line("ngu_told"), "they were not told")


func test_choice_two_loses_the_friends() -> void:
	await _wrong_tell(1)


func test_choice_three_loses_the_friends() -> void:
	await _wrong_tell(2)


func test_choice_four_loses_the_friends() -> void:
	await _wrong_tell(3)


func test_no_answer_in_ten_seconds_loses_the_friends() -> void:
	await _wrong_tell(-1)
	assert_eq(GameState.get_flag(&"ch2_choice_tell", -9), -1, "timed out;")


func test_two_corpses_gagged_never_open_the_choice() -> void:
	await _gag_all([1, 2])
	await _until(func() -> bool: return director._turns >= 8 or not restarts.is_empty())
	assert_true(choices.is_empty(), "no choice;")
	assert_eq(director._loop_run, 0, "no loop run;")
	assert_true(restarts.is_empty(), "alive;")
	assert_false(director._tell_done)


func test_loop_words_count_only_with_all_three_gagged() -> void:
	director._place_player(Vector3(32.6, 0.05, -1.4))
	director._reset_chain()
	director._said(VietText.canon_word("văn học"))
	director._gagged[1] = true
	director._gagged[2] = true
	var typer := func(word: String) -> void:
		EventBus.chain_input_requested.connect(func(_s: float) -> void:
			(func() -> void: EventBus.chain_word_typed.emit(word)).call_deferred(), CONNECT_ONE_SHOT)
	# _on_request would type too: this test drives its own words.
	EventBus.chain_input_requested.disconnect(_on_request)
	typer.call("học sinh")
	assert_true(await director._trung_turn(), "accepted")
	assert_eq(director._loop_run, 0, "two of three gagged: no run;")
	director._gagged[4] = true
	typer.call("sinh viên")
	assert_true(await director._trung_turn(), "accepted")
	assert_eq(director._loop_run, 1, "all gagged: the run starts;")
	typer.call("viên phấn")
	assert_true(await director._trung_turn(), "accepted")
	assert_eq(director._loop_run, 2, "second loop word;")
	EventBus.chain_input_requested.connect(_on_request)
	director._tell_done = true
	director._reset_chain()
	assert_false(director._tell_done, "a new attempt asks again;")
	assert_eq(director._loop_run, 0)


func test_the_pass_mark_and_the_death_kind() -> void:
	assert_eq(Chapter2Director.R3_TELL_LOOP_RUN, 2)
	assert_eq(Chapter2Director.R3_LOOP_PASS, 4)
	assert_true(Chapter2Director.CH2_DEATH_KINDS.has(&"DEATH_CH2_LOST_FRIENDS"), "death kind")
	assert_true(tr("DEATH_CH2_LOST_FRIENDS") != "DEATH_CH2_LOST_FRIENDS", "death text translated")
	for n in range(1, 5):
		assert_true(tr("CHOICE_CH2_TELL_%d" % n) != "CHOICE_CH2_TELL_%d" % n, "choice %d translated" % n)
