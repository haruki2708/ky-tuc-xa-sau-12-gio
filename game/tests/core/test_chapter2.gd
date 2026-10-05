extends TestCase
## Chapter 2 flow (T-170): word chain rules, gagging, the loop, the shower.

var scene: Node
var director: Chapter2Director
var restarts: Array[StringName] = []
var failed: Array[StringName] = []


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
	director.restart_requested.connect(func(id: StringName) -> void: restarts.append(id))
	EventBus.player_failed.connect(_on_failed)
	RuleSystem.load_rule_set(load(Chapter2Director.CH2_RULE_SET))
	await wait_frames(2)


func after_each() -> void:
	EventBus.player_failed.disconnect(_on_failed)
	if EventBus.chain_choice_requested.is_connected(_answer_right):
		EventBus.chain_choice_requested.disconnect(_answer_right)
	if EventBus.shower_choice_requested.is_connected(_shower_by_rule):
		EventBus.shower_choice_requested.disconnect(_shower_by_rule)
	if EventBus.chat_choice_requested.is_connected(_answer_ngu):
		EventBus.chat_choice_requested.disconnect(_answer_ngu)
	scene.queue_free()
	await wait_frames(2)


func _on_failed(reason: StringName) -> void:
	failed.append(reason)


func _until(condition: Callable, seconds: float = 20.0) -> void:
	var deadline := Time.get_ticks_msec() + int(seconds * 1000.0)
	while not condition.call() and Time.get_ticks_msec() < deadline:
		await wait_frames(1)


func _answer_right(options: PackedStringArray, _seconds: float) -> void:
	for i in options.size():
		var words: Dictionary = director._bank.words
		if director.is_valid_answer(options[i]) and not (words.has(options[i]) and words[options[i]].dead):
			(func() -> void: EventBus.chain_choice_made.emit(i)).call_deferred()
			return


var _shower_slot := 0


func _shower_by_rule(_seconds: float) -> void:
	var temps: Array = director._shower.player
	var t: int = temps[_shower_slot]
	_shower_slot += 1
	var run := t < 50
	director.set_in_shower(run)
	(func() -> void: EventBus.shower_choice_made.emit(run)).call_deferred()


func _answer_ngu(id: StringName, _keys: PackedStringArray) -> void:
	if id == &"ngu":
		(func() -> void: EventBus.chat_choice_made.emit(id, 0)).call_deferred()


func test_bank_and_shower_data_load() -> void:
	assert_true(director._bank.words.size() > 200, "word bank")
	assert_eq((director._bank.loop as Array).size(), 8, "loop of 8;")
	assert_eq((director._shower.player as Array).size(), 30, "30 shower slots;")
	for key: String in director._bank.words:
		assert_true(tr(key) != key, "translated " + key)
		break


func test_options_always_hold_a_right_word_and_traps() -> void:
	director._reset_chain()
	director._said(String(director._bank.opening[2]))
	for round in 40:
		var options := director._options_for(director._last_syllable())
		assert_eq(options.size(), 4, "four options;")
		var right := 0
		for key in options:
			if director.is_valid_answer(key):
				right += 1
		assert_true(right >= 1 and right <= 2, "one right word (two with a dead end), got %d" % right)
		# Move on with a live right word, as the corpses would.
		var next := director._right_word(director._last_syllable())
		assert_true(not next.is_empty(), "the chain never strands Trung")
		director._said(next)


func test_wrong_tone_and_repeats_are_wrong() -> void:
	director._reset_chain()
	director._said("WORD_CH2_SACH_VO")
	assert_true(director.is_valid_answer("WORD_CH2_VO_KICH"), "vở kịch follows sách vở")
	assert_false(director.is_valid_answer("WORD_CH2_VO_NAT"), "vỡ nát: wrong tone")
	assert_false(director.is_valid_answer("WORD_CH2_SACH_VO"), "repeat within three")


func test_silence_on_your_turn_kills() -> void:
	director.run_from(&"r3")
	await _until(func() -> bool: return not restarts.is_empty(), 30.0)
	assert_eq(failed, [&"DEATH_CH2_CHAIN_TIMEOUT"] as Array[StringName], "no answer in 15 s;")
	assert_eq(restarts, [&"ch2_r3"] as Array[StringName], "reload at round 3;")


func test_a_wrong_word_kills() -> void:
	var wrong := func(options: PackedStringArray, _s: float) -> void:
		for i in options.size():
			if not director.is_valid_answer(options[i]):
				(func() -> void: EventBus.chain_choice_made.emit(i)).call_deferred()
				return
	EventBus.chain_choice_requested.connect(wrong, CONNECT_ONE_SHOT)
	director.run_from(&"r3")
	await _until(func() -> bool: return not restarts.is_empty(), 30.0)
	assert_eq(failed, [&"DEATH_CH2_CHAIN_WRONG"] as Array[StringName], "wrong word;")


func test_gagged_corpses_and_the_loop_end_round_3_early() -> void:
	EventBus.chain_choice_requested.connect(_answer_right)
	director.stop_after = &"r3"
	director.run_from(&"r3")
	await _until(func() -> bool: return director._turns >= 2, 30.0)
	for bed in [1, 2, 4]:
		assert_true(director.gag(bed), "gag %d" % bed)
	await _until(func() -> bool: return director.finished or not restarts.is_empty(), 60.0)
	assert_true(director.finished, "round 3 over;")
	assert_true(restarts.is_empty(), "alive")
	assert_true(director._turns < Chapter2Director.R3_TURNS, "loop ended it early (%d turns)" % director._turns)


func test_shower_by_the_rule_and_ngu_saved_finish_the_chapter() -> void:
	_shower_slot = 0
	EventBus.shower_choice_requested.connect(_shower_by_rule)
	EventBus.chat_choice_requested.connect(_answer_ngu)
	director.run_from(&"r4")
	await _until(func() -> bool: return director.finished or not restarts.is_empty(), 90.0)
	assert_true(director.finished, "chapter 2 done;")
	assert_eq(failed, [] as Array[StringName], "no death;")
	assert_true(director._minutes >= 25, "25 minutes (%d)" % director._minutes)
	assert_eq(Progress.unlocked_chapter(), 3, "chapter 3 unlocked;")


func test_hot_water_scalds() -> void:
	var always_yes := func(_s: float) -> void:
		director.set_in_shower(true)
		(func() -> void: EventBus.shower_choice_made.emit(true)).call_deferred()
	EventBus.shower_choice_requested.connect(always_yes)
	director.run_from(&"r4")
	await _until(func() -> bool: return not restarts.is_empty(), 60.0)
	EventBus.shower_choice_requested.disconnect(always_yes)
	assert_eq(failed, [&"DEATH_CH2_SCALDED"] as Array[StringName], "67 °C on the first slot;")
	assert_eq(restarts, [&"ch2_r4"] as Array[StringName], "reload at round 4;")


func test_stepping_out_after_yes_kills() -> void:
	var yes_but_out := func(_s: float) -> void:
		director.set_in_shower(false)
		(func() -> void: EventBus.shower_choice_made.emit(true)).call_deferred()
	EventBus.shower_choice_requested.connect(yes_but_out)
	director.run_from(&"r4")
	await _until(func() -> bool: return not restarts.is_empty(), 60.0)
	EventBus.shower_choice_requested.disconnect(yes_but_out)
	assert_eq(failed, [&"DEATH_CH2_SHOWER_BROKEN"] as Array[StringName], "broke the choice;")


func test_wrong_advice_loses_ngu() -> void:
	_shower_slot = 0
	EventBus.shower_choice_requested.connect(_shower_by_rule)
	var bad := func(id: StringName, _k: PackedStringArray) -> void:
		if id == &"ngu":
			(func() -> void: EventBus.chat_choice_made.emit(id, 1)).call_deferred()
	EventBus.chat_choice_requested.connect(bad)
	director.run_from(&"r4")
	await _until(func() -> bool: return not restarts.is_empty(), 90.0)
	EventBus.chat_choice_requested.disconnect(bad)
	assert_eq(failed, [&"DEATH_CH2_LOST_NGU"] as Array[StringName], "Ngư lost;")


func test_rule_book_loads_so_the_chapter_can_start() -> void:
	# start() stops on an invalid rule set: the chapter would never run.
	var errors := RuleSystem.load_rule_set(load(Chapter2Director.CH2_RULE_SET))
	assert_true(errors.is_empty(), "chapter 2 rules valid: %s" % ", ".join(errors))
