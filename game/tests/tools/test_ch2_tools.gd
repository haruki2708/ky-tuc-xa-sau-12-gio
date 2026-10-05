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


func test_loop_bridge_uses_dictionary_and_avoids_recent_repeat() -> void:
	var lexicon := {
		"a": {"text": "liệu pháp", "valid": true}, "b": {"text": "pháp luật", "valid": true},
		"c": {"text": "luật học", "valid": true}, "d": {"text": "học sinh", "valid": true},
		"bad": {"text": "liệu pháp", "valid": false}}
	assert_eq(POLICY.choose("tài liệu", ["bad", "a"], [], lexicon, "loop"), 1)
	assert_eq(POLICY.choose("tài liệu", ["a"], ["liệu pháp"], lexicon, "loop"), -1)
	lexicon.erase("c")
	assert_eq(POLICY.choose("tài liệu", ["a"], [], lexicon, "loop"), -1)


func test_trap_and_wrong_tone_selection_are_deliberate() -> void:
	var lexicon := {"right": {"text": "đá bóng", "valid": true}, "wrong": {"text": "đà điểu", "valid": true}, "trap": {"text": "đá tảng", "valid": true, "dead_end": true}}
	# Fixture metadata only; no claim that this is the game's dead-end list.
	assert_eq(POLICY.choose("viên đá", ["wrong", "right"], [], lexicon), 1)
	assert_eq(POLICY.choose("viên đá", ["wrong", "right"], [], lexicon, "wrong_tone"), 0)
	assert_eq(POLICY.choose("viên đá", ["right", "trap"], [], lexicon, "trap"), 1)


func test_temperature_oracle_predicts_entire_approved_sequence_without_lookahead() -> void:
	var sequence := [67, 37, 8, 81, 96, 58, 37, 1, 19, 4, 43, 74, 19, 9, 94, 35, 86, 41, 52, 79, 63, 94, 31, 45, 91, 7, 71, 83, 13, 42]
	assert_false(POLICY.shower_yes([]))
	for i in range(1, sequence.size()):
		assert_eq(POLICY.shower_yes(sequence.slice(0, i)), sequence[i] < 50, "slot %d" % (i + 1))
	assert_false(POLICY.shower_yes([8]), "81 degree negative case is intentionally unsafe")
	assert_false(POLICY.shower_yes([96]), "50..59 is unsafe")
	assert_true(POLICY.shower_yes([83]), "10..19 is safe")


func test_action_observer_answers_only_pending_unblocked_turn_and_sees_shower_history() -> void:
	var helper := ACTIONS.new()
	helper.profile = {"lexicon": {"old": {"text": "viên đá", "valid": true}, "wrong": {"text": "đà điểu", "valid": true}, "right": {"text": "đá bóng", "valid": true}, "long": {"text": "đá bóng giỏi", "valid": false}, "other": {"text": "học sinh", "valid": true}}}
	tree.root.add_child(helper)
	var picked: Array[int] = []
	var listen := func(index: int) -> void: picked.append(index)
	EventBus.chain_choice_made.connect(listen)
	EventBus.chain_word_spoken.emit(&"dat", "old")
	EventBus.chain_choice_requested.emit(PackedStringArray(["wrong", "right", "long", "other"]), 15.0)
	EventBus.chain_choice_blocked.emit(true)
	assert_eq(helper.answer_chain().status, "FAIL")
	assert_true(picked.is_empty())
	EventBus.chain_choice_blocked.emit(false)
	assert_eq(helper.answer_chain().status, "PASS")
	assert_eq(picked, [1])
	assert_eq(helper.answer_chain().status, "FAIL", "must not answer twice")
	EventBus.shower_slot_finished.emit(37, true, 2)
	assert_eq(helper.temperatures, [37])
	assert_eq(helper.counted_minutes, 2)
	EventBus.chain_choice_made.disconnect(listen)
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


func test_complete_eight_word_loop_is_observed_not_assumed() -> void:
	var helper := ACTIONS.new()
	var lexicon := {"bad1": {"text": "", "valid": false}, "bad2": {"text": "", "valid": false}, "bad3": {"text": "", "valid": false}}
	for i in 8: lexicon[str(i)] = {"text": POLICY.LOOP[i], "valid": true}
	helper.profile = {"lexicon": lexicon}
	tree.root.add_child(helper)
	EventBus.chain_word_spoken.emit(&"dat", "7")
	for i in 8:
		EventBus.chain_choice_requested.emit(PackedStringArray([str(i), "bad1", "bad2", "bad3"]), 15.0)
		assert_eq(helper.answer_chain("loop").status, "PASS")
		EventBus.chain_word_spoken.emit(&"trung", str(i))
		assert_eq(helper.loop_completed, i == 7)
	helper.free()


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
