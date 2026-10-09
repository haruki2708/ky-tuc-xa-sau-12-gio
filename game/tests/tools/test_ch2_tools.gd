extends TestCase

const POLICY := preload("res://scripts/debug/ch2_policy.gd")
const ACTIONS := preload("res://scripts/debug/ch2_actions.gd")
const BOT := preload("res://scripts/debug/ch2_bot.gd")


func test_chain_requires_exact_tone_two_words_and_last_three_turns() -> void:
	assert_true(POLICY.legal("oan khuất", "khuất phục", []))
	assert_false(POLICY.legal("viên đá", "đà điểu", []))
	assert_true(POLICY.wrong_tone("viên đá", "đà điểu"))
	assert_false(POLICY.wrong_tone("oan khuất", "khuyết điểm"))
	assert_false(POLICY.legal("văn học", "học sinh giỏi", []))
	assert_false(POLICY.legal("văn học", "học sinh", ["học sinh", "sinh viên", "viên phấn"]))
	assert_true(POLICY.legal("văn học", "học sinh", ["học sinh", "sinh viên", "viên phấn", "phấn đấu"]))


func test_dictionary_typing_trap_and_loop_route() -> void:
	var dictionary := Ch2Dictionary.shared()
	var history: Array = ["tài liệu"]
	var previous := "tài liệu"
	var reached := false
	for i in 20:
		var word := POLICY.choose_word(previous, history, "loop")
		assert_true(dictionary.has(VietText.canon_word(word)), word)
		assert_true(POLICY.legal(previous, word, history), word)
		if word in POLICY.LOOP:
			reached = true
			break
		history.append(word)
		previous = word
	assert_true(reached, "independent route reaches loop")
	var trap := POLICY.choose_word("", [], "trap")
	assert_true(dictionary.has(VietText.canon_word(trap)))
	assert_true(POLICY.dead_end(trap))
	assert_true(POLICY.choose_word(trap, [trap], "trap") != trap)
	var wrong := POLICY.choose_word("sách vở", [], "wrong_tone")
	assert_true(POLICY.wrong_tone("sách vở", wrong))
	assert_false(POLICY.legal("sách vở", wrong, []))
	assert_true(POLICY.legal("văn học", "  HỌC   SINH  ", []))
	assert_eq(POLICY.words("hoà bình"), POLICY.words("hòa bình"))


func test_typed_policy_matches_core_and_requires_real_trap_observations() -> void:
	var director := Chapter2Director.new()
	director._dictionary = Ch2Dictionary.shared()
	director._last_word = VietText.canon_word("sách vở")
	director._recent.assign([director._last_word])
	assert_true(director.is_valid_word(POLICY.choose_word("sách vở", ["sách vở"])))
	assert_false(director.is_valid_word(POLICY.choose_word("sách vở", [], "wrong_tone")))
	director._last_word = ""
	director._recent.clear()
	var trap := POLICY.choose_word("", [], "trap")
	assert_true(director.is_valid_word(trap))
	assert_false(director._dictionary.corpse_by_first.has(Ch2Dictionary.last_of(VietText.canon_word(trap))))
	director.free()
	var helper := ACTIONS.new()
	tree.root.add_child(helper)
	helper.recent = [""]
	EventBus.chain_input_requested.emit(15.0)
	assert_eq(helper.answer_chain("trap").status, "PASS")
	EventBus.corpse_state_changed.emit(1, &"fall")
	assert_false(helper.trap_confirmed, "submission is not an accepted trap")
	EventBus.chain_input_closed.emit(&"accepted")
	EventBus.chain_word_spoken.emit(&"trung", trap)
	assert_false(helper.trap_confirmed, "accepted trap still needs corpse stall")
	EventBus.corpse_state_changed.emit(1, &"fall")
	assert_true(helper.trap_confirmed)
	helper.free()


func test_temperature_oracle_predicts_entire_approved_sequence_without_lookahead() -> void:
	var sequence := [67, 37, 8, 81, 96, 58, 37, 1, 19, 4, 43, 74, 19, 9, 94, 35, 86, 41, 52, 79, 63, 94, 31, 45, 91, 7, 71, 83, 13, 42]
	assert_false(POLICY.shower_yes([]))
	for i in range(1, sequence.size()):
		assert_eq(POLICY.shower_yes(sequence.slice(0, i)), sequence[i] < 50, "slot %d" % (i + 1))
	assert_false(POLICY.shower_yes([8]), "81 degree negative case is intentionally unsafe")
	assert_false(POLICY.shower_yes([96]), "50..59 is unsafe")
	assert_true(POLICY.shower_yes([83]), "10..19 is safe")


func test_action_observer_types_once_and_waits_for_core_acknowledgement() -> void:
	var helper := ACTIONS.new()
	tree.root.add_child(helper)
	var typed: Array[String] = []
	var listen := func(text: String) -> void: typed.append(text)
	EventBus.chain_word_typed.connect(listen)
	EventBus.chain_word_spoken.emit(&"dat", "WORD_CH2_HOC_SINH")
	assert_eq(helper.recent, ["học sinh"])
	EventBus.chain_input_requested.emit(15.0)
	EventBus.chain_choice_blocked.emit(true)
	assert_eq(helper.answer_chain().status, "FAIL")
	assert_true(typed.is_empty())
	EventBus.chain_choice_blocked.emit(false)
	assert_eq(helper.answer_chain().status, "PASS")
	assert_eq(typed.size(), 1)
	assert_true(POLICY.legal("học sinh", typed[0], ["học sinh"]))
	assert_true(helper.chain_pending, "submission is not acknowledgement")
	assert_eq(helper.answer_chain().status, "FAIL")
	EventBus.chain_input_closed.emit(&"accepted")
	assert_false(helper.chain_pending)
	EventBus.shower_slot_finished.emit(37, true, 2)
	assert_eq(helper.temperatures, [37])
	assert_eq(helper.counted_minutes, 2)
	EventBus.chain_word_typed.disconnect(listen)
	helper.free()


func test_missing_chapter_and_physical_bindings_skip_instead_of_faking_progress() -> void:
	for name: String in BOT.CASES:
		assert_false(BOT.preflight({}, name).is_empty(), name)
	var helper := ACTIONS.new()
	tree.root.add_child(helper)
	var outcome: Dictionary = await helper.physical("wipe")
	assert_eq(outcome.status, "SKIP")
	helper.free()
	assert_eq(BOT.CASES.ch2_chain_timeout.checkpoint, "ch2_r3")
	assert_eq(BOT.CASES.ch2_scald.checkpoint, "ch2_r4")


func test_four_word_loop_run_is_observed_not_assumed() -> void:
	var helper := ACTIONS.new()
	tree.root.add_child(helper)
	for bed in [1, 2, 4]: EventBus.corpse_state_changed.emit(bed, &"gagged")
	EventBus.chain_word_spoken.emit(&"dat", "văn học")
	for i in 4:
		EventBus.chain_input_requested.emit(15.0)
		assert_eq(helper.answer_chain("loop").word, POLICY.LOOP[i])
		assert_false(helper.loop_completed, "sending is not completing")
		EventBus.chain_input_closed.emit(&"accepted")
		EventBus.chain_word_spoken.emit(&"trung", POLICY.LOOP[i])
		assert_eq(helper.loop_completed, i == 3)
	helper.free()


func test_predictions_use_history_and_require_both_core_results() -> void:
	for sample: Array in [[[38, 16, 75], 23], [[74, 15, 62], 81], [[11, 22, 67], 37]]:
		for ranged in [false, true]:
			assert_true(Chapter2Director.is_right_prediction(POLICY.prediction(sample[0], false, ranged), sample[1]))
		assert_false(Chapter2Director.is_right_prediction(POLICY.prediction(sample[0], true), sample[1]))
	assert_eq(POLICY.prediction([11, 22]), "")
	assert_eq(POLICY.prediction([11, 22, 100]), "")
	assert_eq(POLICY.prediction([11, 22, 67], false, true), "3x")
	var helper := ACTIONS.new()
	tree.root.add_child(helper)
	for member: StringName in [&"minh_nhat", &"ngu"]:
		EventBus.prediction_requested.emit(member, PackedInt32Array([11, 22, 67]), 20.0)
		assert_eq(helper.answer_prediction(member).status, "PASS")
		assert_false(helper.both_predictions_correct())
		assert_eq(helper.answer_prediction(member).status, "FAIL")
		EventBus.prediction_result.emit(member, true)
	assert_true(helper.both_predictions_correct())
	EventBus.chapter_started.emit(2)
	assert_false(helper.both_predictions_correct())
	EventBus.prediction_requested.emit(&"ngu", PackedInt32Array([74, 15, 62]), 20.0)
	assert_eq(helper.answer_prediction(&"ngu", true).status, "PASS")
	assert_eq(helper.prediction_answers[&"ngu"], "có")
	EventBus.prediction_result.emit(&"ngu", false)
	assert_false(helper.both_predictions_correct())
	helper.free()
	assert_true(BOT.CASES.has("ch2_wrong_prediction"))
	assert_false(BOT.CASES.has("ch2_lost_ngu"))
	assert_eq(BOT.CASES.ch2_wrong_prediction.reason, "DEATH_CH2_LOST_NGU")
	assert_eq(BOT.CASES.ch2_wrong_prediction.checkpoint, "ch2_r4")


class AcknowledgementProbe extends Node:
	signal used
	var value: bool = true
	func noop() -> void:
		pass
	func use() -> void:
		value = true
		used.emit()


func test_physical_action_requires_signal_even_when_state_already_matches() -> void:
	var world := Node.new()
	var target := AcknowledgementProbe.new()
	target.name = "Target"
	world.add_child(target)
	tree.root.add_child(world)
	var helper := ACTIONS.new()
	helper.world = world
	helper.profile = {"actions": {"test": {"path": "Target", "method": "noop", "args": [], "verify": {"property": "value", "equals": true, "signal": "used"}}}}
	tree.root.add_child(helper)
	var absent: Dictionary = await helper.physical("test")
	assert_eq(absent.status, "FAIL", "matching old state is not a new action acknowledgement")
	helper.profile.actions.test.method = "use"
	var performed: Dictionary = await helper.physical("test")
	assert_eq(performed.status, "PASS")
	assert_true(helper.acknowledged("test"))
	target.value = false
	assert_false(helper.acknowledged("test"), "performance samples must detect changing state")
	assert_eq(target.get_signal_connection_list("used").size(), 0)
	helper.free()
	world.free()
