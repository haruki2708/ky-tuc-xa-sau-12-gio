extends TestCase
## Chapter 2 flow (T-170, T-176): typed word chain on the dictionary, gagging,
## the loop, the shower and the texted predictions (D-049…D-051).

var scene: Node
var director: Chapter2Director
var restarts: Array[StringName] = []
var failed: Array[StringName] = []
var predictions: Dictionary = {}


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
	predictions = {"minh_nhat": "có", "ngu": "không"}
	director.restart_requested.connect(func(id: StringName) -> void: restarts.append(id))
	EventBus.player_failed.connect(_on_failed)
	RuleSystem.load_rule_set(load(Chapter2Director.CH2_RULE_SET))
	await wait_frames(2)


func after_each() -> void:
	EventBus.player_failed.disconnect(_on_failed)
	for pair: Array in [[EventBus.chain_input_requested, _type_right], [EventBus.shower_choice_requested, _shower_by_rule],
			[EventBus.prediction_requested, _predict]]:
		if (pair[0] as Signal).is_connected(pair[1]):
			(pair[0] as Signal).disconnect(pair[1])
	scene.queue_free()
	await wait_frames(2)


func _on_failed(reason: StringName) -> void:
	failed.append(reason)


func _until(condition: Callable, seconds: float = 20.0) -> void:
	var deadline := Time.get_ticks_msec() + int(seconds * 1000.0)
	while not condition.call() and Time.get_ticks_msec() < deadline:
		await wait_frames(1)


func _type(text: String) -> void:
	(func() -> void: EventBus.chain_word_typed.emit(text)).call_deferred()


func _type_right(_seconds: float) -> void:
	_type(director.suggest_word())


var _shower_slot := 0


func _shower_by_rule(_seconds: float) -> void:
	var temps: Array = director._shower.player
	var t: int = temps[_shower_slot]
	_shower_slot += 1
	var run := t < 50
	director.set_in_shower(run)
	(func() -> void: EventBus.shower_choice_made.emit(run)).call_deferred()


func _predict(member: StringName, _history: PackedInt32Array, _seconds: float) -> void:
	(func() -> void: EventBus.prediction_sent.emit(member, String(predictions[String(member)]))).call_deferred()


func test_bank_dictionary_and_shower_data_load() -> void:
	assert_true(director._bank.words.size() > 200, "word bank")
	assert_eq((director._bank.loop as Array).size(), 8, "loop of 8;")
	assert_eq((director._shower.player as Array).size(), 30, "30 shower slots;")
	assert_true(director._dictionary.spelling.size() > 25000, "large dictionary (%d)" % director._dictionary.spelling.size())
	assert_true(director._dictionary.corpse_count > 8000, "corpses know thousands (%d)" % director._dictionary.corpse_count)
	for key: String in director._bank.words:
		assert_true(tr(key) != key, "translated " + key)
		assert_true(director._dictionary.has(VietText.canon_word(String(director._bank.words[key].text))), "bank word in dictionary " + key)


func test_canon_matches_the_dictionary_builder() -> void:
	var samples: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://tests/core/canon_samples.json"))
	assert_true(samples.size() >= 10, "samples")
	for text: String in samples:
		assert_eq(VietText.canon_word(text), String(samples[text]), "canon of '%s';" % text)


func test_typed_words_follow_the_rule() -> void:
	director._reset_chain()
	director._said(VietText.canon_word("sách vở"))
	assert_true(director.is_valid_word("vở kịch"), "vở kịch follows sách vở")
	assert_true(director.is_valid_word("  Vở   Kịch "), "case and spaces do not matter")
	assert_false(director.is_valid_word("vỡ nát"), "vỡ nát: wrong tone")
	assert_false(director.is_valid_word("vo kich"), "no tone marks: a different syllable")
	assert_false(director.is_valid_word("sách vở"), "repeat within three")
	assert_false(director.is_valid_word("vở"), "one syllable")
	assert_false(director.is_valid_word("vở kịch hay"), "three syllables")
	assert_false(director.is_valid_word("vở xyz"), "not in the dictionary")
	director._said(VietText.canon_word("thủy thủ"))
	assert_true(director.is_valid_word("thủ tục"), "thủ…")
	director._said(VietText.canon_word("hòa bình"))
	assert_true(director.is_valid_word("bình yên"), "bình…")
	director._said(VietText.canon_word("kỹ thuật"))
	assert_true(director.is_valid_word("thuật ngữ"), "thuật…")
	director._reset_chain()
	director._said(VietText.canon_word("khoa học"))
	assert_true(director.is_valid_word("học kì"), "kì = kỳ")


func test_the_first_turn_accepts_common_vo_words() -> void:
	director._reset_chain()
	director._said(VietText.canon_word("sách vở"))
	for word in ["vở kịch", "vở ghi", "vở nháp", "vở tuồng"]:
		assert_true(director.is_valid_word(word), word)


func test_every_corpse_word_leaves_five_ways_on() -> void:
	var dictionary := director._dictionary
	for word in director._bank_keys:
		if director._bank_word_lives(word):
			var ways: int = dictionary.by_first.get(Ch2Dictionary.last_of(word), PackedStringArray()).size()
			assert_true(ways >= 5, "%s leaves %d ways" % [dictionary.spelling[word], ways])
	for first: String in dictionary.corpse_by_first:
		for word in dictionary.corpse_by_first[first]:
			if dictionary.by_first.get(Ch2Dictionary.last_of(word), PackedStringArray()).size() < 5:
				assert_true(false, "%s strands the player" % dictionary.spelling[word])


func test_a_dictionary_word_the_corpses_do_not_know_makes_them_stall() -> void:
	director._reset_chain()
	director._said(VietText.canon_word("sách vở"))
	var dead := director.suggest_dead_end()
	if dead.is_empty():
		director._reset_chain()
		director._said(VietText.canon_word("khoa học"))
		dead = director.suggest_dead_end()
	assert_true(not dead.is_empty(), "a dead end exists")
	director._said(VietText.canon_word(dead))
	assert_eq(director._corpse_pick(director._last_syllable()), "", "corpse knows nothing after '%s';" % dead)


func test_the_chain_never_strands_trung() -> void:
	director._reset_chain()
	director._said(VietText.canon_word("sách vở"))
	for turn in 60:
		var mine := director.suggest_word()
		assert_true(not mine.is_empty(), "Trung has a word after %s" % director._last_word)
		director._said(VietText.canon_word(mine))
		var theirs := director._corpse_pick(director._last_syllable())
		if theirs.is_empty():
			# Trung's word stumped it (N2): it starts a new chain.
			theirs = director._corpse_pick("")
		assert_true(not theirs.is_empty(), "corpse says something after %s" % mine)
		director._said(theirs)
		assert_true(director._dictionary.has(theirs), "corpse word in dictionary")


func test_silence_on_your_turn_kills() -> void:
	director.run_from(&"r3")
	await _until(func() -> bool: return not restarts.is_empty(), 30.0)
	assert_eq(failed, [&"DEATH_CH2_CHAIN_TIMEOUT"] as Array[StringName], "no answer in 15 s;")
	assert_eq(restarts, [&"ch2_r3"] as Array[StringName], "reload at round 3;")


func test_a_wrong_word_kills() -> void:
	var closed: Array[StringName] = []
	var on_closed := func(result: StringName) -> void: closed.append(result)
	EventBus.chain_input_closed.connect(on_closed)
	var wrong := func(_s: float) -> void: _type("vỡ nát")
	EventBus.chain_input_requested.connect(wrong, CONNECT_ONE_SHOT)
	director.run_from(&"r3")
	await _until(func() -> bool: return not restarts.is_empty(), 30.0)
	EventBus.chain_input_closed.disconnect(on_closed)
	assert_eq(failed, [&"DEATH_CH2_CHAIN_WRONG"] as Array[StringName], "wrong word;")
	assert_eq(closed, [&"wrong"] as Array[StringName], "the panel is told;")


func test_gagged_corpses_and_the_loop_end_round_3_early() -> void:
	EventBus.chain_input_requested.connect(_type_right)
	director.stop_after = &"r3"
	director.run_from(&"r3")
	await _until(func() -> bool: return director._turns >= 2, 30.0)
	for bed in [1, 2, 4]:
		assert_true(director.gag(bed), "gag %d" % bed)
	await _until(func() -> bool: return director.finished or not restarts.is_empty(), 60.0)
	assert_true(director.finished, "round 3 over;")
	assert_true(restarts.is_empty(), "alive")
	assert_true(director._turns < Chapter2Director.R3_TURNS, "loop ended it early (%d turns)" % director._turns)


func test_shower_by_the_rule_and_right_predictions_finish_the_chapter() -> void:
	_shower_slot = 0
	var asked: Array[StringName] = []
	var on_ask := func(member: StringName, history: PackedInt32Array, _s: float) -> void:
		asked.append(member)
		assert_eq(history.size(), 3, "three temperatures;")
	EventBus.prediction_requested.connect(on_ask)
	EventBus.shower_choice_requested.connect(_shower_by_rule)
	EventBus.prediction_requested.connect(_predict)
	director.run_from(&"r4")
	await _until(func() -> bool: return director.finished or not restarts.is_empty(), 90.0)
	EventBus.prediction_requested.disconnect(on_ask)
	assert_true(director.finished, "chapter 2 done;")
	assert_eq(failed, [] as Array[StringName], "no death;")
	assert_eq(asked, [&"minh_nhat", &"ngu"] as Array[StringName], "asked once each;")
	assert_eq(_shower_slot, 24, "24 slots to 26 minutes;")
	assert_true(director._minutes >= 25, "25 minutes (%d)" % director._minutes)
	assert_eq(Progress.unlocked_chapter(), 3, "chapter 3 unlocked;")


func test_predictions_come_after_three_safe_showers_in_a_row() -> void:
	_shower_slot = 0
	var at := [-1]
	var on_ask := func(_m: StringName, _h: PackedInt32Array, _s: float) -> void:
		if at[0] == -1:
			at[0] = _shower_slot
	EventBus.prediction_requested.connect(on_ask)
	EventBus.shower_choice_requested.connect(_shower_by_rule)
	EventBus.prediction_requested.connect(_predict)
	director.stop_after = &"r4"
	director.run_from(&"r4")
	await _until(func() -> bool: return at[0] != -1 or not restarts.is_empty(), 60.0)
	EventBus.prediction_requested.disconnect(on_ask)
	# Slots 2-3 are safe, 4 is not; 7, 8, 9 are the first three in a row.
	assert_eq(at[0], 9, "asked after slot 9 (7:18);")


func test_predictions_come_at_7_40_at_the_latest() -> void:
	_shower_slot = 0
	var at := [-1]
	var on_ask := func(_m: StringName, _h: PackedInt32Array, _s: float) -> void:
		if at[0] == -1:
			at[0] = _shower_slot
	# Skip every other safe slot: never three in a row, still alive.
	var skipper := func(_s: float) -> void:
		var t: int = director._shower.player[_shower_slot]
		var run := t < 50 and _shower_slot % 2 == 0
		_shower_slot += 1
		director.set_in_shower(run)
		(func() -> void: EventBus.shower_choice_made.emit(run)).call_deferred()
	EventBus.prediction_requested.connect(on_ask)
	EventBus.shower_choice_requested.connect(skipper)
	EventBus.prediction_requested.connect(_predict)
	director.run_from(&"r4")
	await _until(func() -> bool: return at[0] != -1 or not restarts.is_empty(), 90.0)
	EventBus.prediction_requested.disconnect(on_ask)
	EventBus.shower_choice_requested.disconnect(skipper)
	assert_eq(at[0], 20, "asked before slot 21 (7:40);")


func _wrong_prediction_loses(member: String, wrong: String, reason: StringName) -> void:
	_shower_slot = 0
	predictions[member] = wrong
	EventBus.shower_choice_requested.connect(_shower_by_rule)
	EventBus.prediction_requested.connect(_predict)
	director.run_from(&"r4")
	await _until(func() -> bool: return not restarts.is_empty(), 90.0)
	assert_eq(failed, [reason] as Array[StringName], "%s lost;" % member)
	assert_eq(restarts, [&"ch2_r4"] as Array[StringName], "reload at round 4;")


func test_a_wrong_prediction_for_minh_nhat_loses_round_4() -> void:
	await _wrong_prediction_loses("minh_nhat", "không", &"DEATH_CH2_LOST_NHAT")


func test_a_wrong_prediction_for_ngu_loses_round_4() -> void:
	await _wrong_prediction_loses("ngu", "8", &"DEATH_CH2_LOST_NGU")


func test_no_prediction_in_time_loses_round_4() -> void:
	_shower_slot = 0
	EventBus.shower_choice_requested.connect(_shower_by_rule)
	director.run_from(&"r4")
	await _until(func() -> bool: return not restarts.is_empty(), 90.0)
	assert_eq(failed, [&"DEATH_CH2_LOST_NHAT"] as Array[StringName], "Minh Nhật waited in vain;")


func test_prediction_answers() -> void:
	for case: Array in [["có", 23, true], ["Có", 23, true], ["co", 23, true], ["không", 23, false], ["2x", 23, true],
			["2X", 23, true], ["3x", 23, false], ["không", 81, true], ["khong", 81, true], ["ko", 81, true],
			["8x", 81, true], ["có", 81, false], ["8", 81, false], ["", 81, false], ["chịu", 81, false]]:
		assert_eq(Chapter2Director.is_right_prediction(String(case[0]), int(case[1])), bool(case[2]),
			"'%s' for %d;" % [case[0], case[1]])


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


func test_rule_book_loads_so_the_chapter_can_start() -> void:
	# start() stops on an invalid rule set: the chapter would never run.
	var errors := RuleSystem.load_rule_set(load(Chapter2Director.CH2_RULE_SET))
	assert_true(errors.is_empty(), "chapter 2 rules valid: %s" % ", ".join(errors))
