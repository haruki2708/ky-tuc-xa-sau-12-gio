extends TestCase
## RuleSystem + GameState + Checkpoint. The rule set below is a test fixture,
## not the demo's rules (those are decided in T-113).

const SAVE_PATH := "user://test_checkpoint.json"

var events: Array = []


func before_each() -> void:
	GameState.reset()
	RuleSystem.reset()
	events.clear()
	for sig in ["rule_resolved", "consequence_triggered", "player_failed", "deviation_changed",
			"rule_read", "rule_suspicion_changed", "checkpoint_loaded", "time_changed", "flag_changed"]:
		EventBus.connect(sig, _record.bind(sig))


func after_each() -> void:
	for sig in ["rule_resolved", "consequence_triggered", "player_failed", "deviation_changed",
			"rule_read", "rule_suspicion_changed", "checkpoint_loaded", "time_changed", "flag_changed"]:
		for connection in EventBus.get_signal_connection_list(sig):
			if connection["callable"].get_object() == self:
				EventBus.disconnect(sig, connection["callable"])
	GameState.reset()
	RuleSystem.reset()
	Checkpoint.clear(SAVE_PATH)


func _record(a: Variant = null, b: Variant = null, c: Variant = null, d: Variant = null, sig: String = "") -> void:
	# bind() appends the signal name after the emitted arguments.
	var args := [a, b, c, d].filter(func(value: Variant) -> bool: return value != null)
	var name: String = args.pop_back() if sig.is_empty() else sig
	events.append([name, args])


func _events(name: String) -> Array:
	return events.filter(func(event: Array) -> bool: return event[0] == name)


func _rule(id: StringName, situation: StringName, action: StringName, fake: bool = false,
		penalty: int = 1, consequence: StringName = &"", fatal: bool = false) -> RuleData:
	var rule := RuleData.new()
	rule.id = id
	rule.text_key = "RULE_" + String(id).to_upper()
	rule.is_fake = fake
	rule.source = &"hall_board"
	rule.situation = situation
	rule.action = action
	rule.penalty = penalty
	rule.consequence = consequence
	rule.fatal = fatal
	return rule


func _fixture() -> RuleSet:
	var rule_set := RuleSet.new()
	rule_set.rules = [
		_rule(&"knock_genuine", &"knock_at_door", &"stay_silent", false, 2, &"lights_off_corridor"),
		_rule(&"knock_paper", &"knock_at_door", &"open_door", true, 3, &"room_number_swap"),
		_rule(&"call_genuine", &"roll_call", &"answer_own_name"),
		_rule(&"call_board", &"roll_call", &"answer_fifth_name", true, 1, &"", true),
		_rule(&"water_fake", &"tap_water", &"drink", true, 1, &"water_turns_rusty"),
	]
	return rule_set


func _load_fixture() -> void:
	assert_eq(RuleSystem.load_rule_set(_fixture(), false), PackedStringArray(), "fixture loads;")


func test_validate_reports_authoring_mistakes() -> void:
	assert_eq(_fixture().validate(false), PackedStringArray(), "fixture is valid;")
	var broken := RuleSet.new()
	var bad_key := _rule(&"bad_key", &"s", &"a")
	bad_key.text_key = "SUB_NOT_A_RULE"
	broken.rules = [
		_rule(&"dup", &"s1", &"a"),
		_rule(&"dup", &"s2", &"a"),
		bad_key,
		_rule(&"no_situation", &"", &"a"),
		_rule(&"no_action", &"s3", &""),
		_rule(&"second_genuine", &"s1", &"b"),
		_rule(&"useless_fake", &"s1", &"a", true),
	]
	var errors := " | ".join(broken.validate(false))
	for expected in ["duplicate id", "must start with RULE_", "empty situation", "empty action",
			"second genuine line", "same action as the genuine one"]:
		assert_true(errors.contains(expected), "validate reports '%s': %s" % [expected, errors])
	var untranslated := RuleSet.new()
	untranslated.rules = [_rule(&"missing_text", &"s", &"a")]
	assert_true(" ".join(untranslated.validate(true)).contains("missing from strings.csv"),
		"translation check finds missing key")


func test_invalid_set_does_not_replace_loaded_rules() -> void:
	_load_fixture()
	var broken := RuleSet.new()
	broken.rules = [_rule(&"", &"s", &"a")]
	assert_false(RuleSystem.load_rule_set(broken, false).is_empty(), "errors returned")
	assert_not_null(RuleSystem.get_rule(&"knock_genuine"), "previous rules kept")
	assert_eq(RuleSystem.all_rule_ids().size(), 5, "rule count unchanged;")


func test_following_genuine_line_is_correct_and_costs_nothing() -> void:
	_load_fixture()
	var result := RuleSystem.resolve(&"knock_at_door", &"stay_silent")
	assert_eq(result["outcome"], RuleSystem.OUTCOME_CORRECT, "outcome;")
	assert_eq(result["rule_id"], &"knock_genuine", "rule;")
	assert_eq(GameState.deviation, 0, "no deviation;")
	assert_eq(_events("consequence_triggered").size(), 0, "no consequence;")
	assert_eq(_events("rule_resolved").size(), 1, "resolution announced;")
	assert_eq(RuleSystem.outcome_of(&"knock_at_door"), RuleSystem.OUTCOME_CORRECT, "outcome remembered;")


func test_following_fake_line_applies_its_penalty_and_consequence() -> void:
	_load_fixture()
	var result := RuleSystem.resolve(&"knock_at_door", &"open_door")
	assert_eq(result["outcome"], RuleSystem.OUTCOME_FOLLOWED_FAKE, "outcome;")
	assert_eq(result["rule_id"], &"knock_paper", "the fake line is blamed;")
	assert_eq(GameState.deviation, 3, "fake line penalty;")
	assert_eq(_events("consequence_triggered"), [["consequence_triggered", [&"room_number_swap", &"knock_paper"]]], "consequence;")
	assert_eq(_events("deviation_changed"), [["deviation_changed", [3, &"knock_paper"]]], "deviation reason;")


func test_ignoring_genuine_line_applies_genuine_penalty() -> void:
	_load_fixture()
	var result := RuleSystem.resolve(&"knock_at_door", &"shout")
	assert_eq(result["outcome"], RuleSystem.OUTCOME_BROKE_RULE, "outcome;")
	assert_eq(result["consequence"], &"lights_off_corridor", "genuine consequence;")
	assert_eq(GameState.deviation, 2, "genuine penalty;")


func test_fatal_line_reports_failure() -> void:
	_load_fixture()
	var result := RuleSystem.resolve(&"roll_call", &"answer_fifth_name")
	assert_true(result["fatal"], "fatal flag")
	assert_eq(_events("player_failed"), [["player_failed", [&"call_board"]]], "failure announced;")
	RuleSystem.resolve(&"roll_call", &"answer_own_name")
	assert_eq(_events("player_failed").size(), 1, "correct answer is not a failure;")


func test_unruled_and_fake_only_situations() -> void:
	_load_fixture()
	assert_eq(RuleSystem.resolve(&"open_window", &"anything")["outcome"], RuleSystem.OUTCOME_UNRULED, "no line;")
	assert_eq(RuleSystem.resolve(&"tap_water", &"pour_out")["outcome"], RuleSystem.OUTCOME_CORRECT, "ignored fake;")
	assert_eq(GameState.deviation, 0, "nothing wrong yet;")
	assert_eq(RuleSystem.resolve(&"tap_water", &"drink")["outcome"], RuleSystem.OUTCOME_FOLLOWED_FAKE, "followed fake;")
	assert_eq(GameState.deviation, 1, "fake-only penalty;")


func test_deviation_is_clamped() -> void:
	GameState.add_deviation(99, &"test")
	assert_eq(GameState.deviation, GameState.MAX_DEVIATION, "upper clamp;")
	GameState.add_deviation(-99, &"test")
	assert_eq(GameState.deviation, 0, "lower clamp;")
	events.clear()
	GameState.add_deviation(-1, &"test")
	assert_eq(_events("deviation_changed").size(), 0, "no signal without change;")


func test_notebook_read_order_and_suspicion() -> void:
	_load_fixture()
	RuleSystem.mark_read(&"knock_paper")
	RuleSystem.mark_read(&"knock_genuine")
	RuleSystem.mark_read(&"knock_paper")
	assert_eq(RuleSystem.read_rules(), [&"knock_paper", &"knock_genuine"] as Array[StringName], "first-read order;")
	assert_eq(_events("rule_read").size(), 2, "read announced once per rule;")
	RuleSystem.set_suspected(&"knock_paper", true)
	RuleSystem.set_suspected(&"knock_paper", true)
	assert_true(RuleSystem.is_suspected(&"knock_paper"), "suspected")
	RuleSystem.set_suspected(&"knock_paper", false)
	assert_false(RuleSystem.is_suspected(&"knock_paper"), "unsuspected")
	assert_eq(_events("rule_suspicion_changed").size(), 2, "only real changes announced;")


func test_clock_text_and_progression() -> void:
	assert_eq(GameState.clock_text(), "23:50", "demo starts at 23:50;")
	GameState.advance_minutes(40)
	assert_eq(GameState.clock_text(), "00:30", "past midnight;")
	assert_eq(GameState.minutes, 23 * 60 + 90, "minutes keep growing;")
	GameState.minutes_per_second = 2.0
	GameState._process(0.75)
	assert_eq(GameState.clock_text(), "00:31", "real-time clock, whole minutes only;")
	GameState._process(0.25)
	assert_eq(GameState.clock_text(), "00:32", "accumulated remainder;")
	GameState.minutes_per_second = 0.0
	GameState._process(10.0)
	assert_eq(GameState.clock_text(), "00:32", "frozen clock;")


func test_flags_accept_simple_types_only() -> void:
	GameState.set_flag(&"door_locked", true)
	GameState.set_flag(&"door_locked", true)
	assert_eq(_events("flag_changed").size(), 1, "same value not re-announced;")
	GameState.set_flag(&"knocks", 3)
	GameState.set_flag(&"bad", Vector3.ONE)
	assert_false(GameState.has_flag(&"bad"), "unsupported type rejected")
	assert_eq(GameState.get_flag(&"missing", "fallback"), "fallback", "default value;")


func test_checkpoint_round_trip_restores_state_and_types() -> void:
	_load_fixture()
	GameState.set_time(1470)
	GameState.set_segment(&"roll_call")
	GameState.set_flag(&"knocks", 3)
	GameState.set_flag(&"door_locked", true)
	GameState.set_flag(&"room_label", "412")
	RuleSystem.mark_read(&"call_board")
	RuleSystem.set_suspected(&"call_board", true)
	RuleSystem.resolve(&"knock_at_door", &"open_door")
	assert_eq(Checkpoint.save(&"before_roll_call", SAVE_PATH), OK, "save;")
	GameState.reset()
	RuleSystem.from_dict({})
	events.clear()
	assert_eq(Checkpoint.restore(SAVE_PATH), &"before_roll_call", "restore id;")
	assert_eq(GameState.clock_text(), "00:30", "time;")
	assert_eq(GameState.segment, &"roll_call", "segment;")
	assert_eq(GameState.deviation, 3, "deviation;")
	assert_eq(typeof(GameState.get_flag(&"knocks")), TYPE_INT, "int flag stays int;")
	assert_eq(GameState.get_flag(&"door_locked"), true, "bool flag;")
	assert_eq(GameState.get_flag(&"room_label"), "412", "string flag;")
	assert_true(RuleSystem.is_read(&"call_board"), "read restored")
	assert_true(RuleSystem.is_suspected(&"call_board"), "suspicion restored")
	assert_eq(RuleSystem.outcome_of(&"knock_at_door"), RuleSystem.OUTCOME_FOLLOWED_FAKE, "outcome restored;")
	assert_eq(_events("checkpoint_loaded"), [["checkpoint_loaded", [&"before_roll_call"]]], "load announced;")
	assert_eq(_events("time_changed").size(), 1, "views told to rebuild;")


func test_restore_without_or_with_bad_save() -> void:
	Checkpoint.clear(SAVE_PATH)
	assert_eq(Checkpoint.restore(SAVE_PATH), &"", "no save;")
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	file.store_string("{\"version\": 999}")
	file.close()
	assert_eq(Checkpoint.restore(SAVE_PATH), &"", "unknown version rejected;")
	_load_fixture()
	RuleSystem.from_dict({"read": ["ghost_rule", "knock_genuine"], "suspected": ["ghost_rule"]})
	assert_eq(RuleSystem.read_rules(), [&"knock_genuine"] as Array[StringName], "unknown ids dropped;")


func test_demo_rule_set_matches_design() -> void:
	# docs/design/RULES.md §7 (D-020).
	var demo := load("res://data/rules/demo.tres") as RuleSet
	assert_not_null(demo, "demo rule set loads")
	if demo == null:
		return
	assert_eq(demo.validate(true), PackedStringArray(), "demo rules valid, with translations;")
	assert_eq(RuleSystem.load_rule_set(demo), PackedStringArray(), "demo rules load;")
	assert_eq(demo.rules.size(), 11, "rule line count;")
	var fatal: Array[StringName] = []
	for rule in demo.rules:
		if rule.fatal:
			fatal.append(rule.id)
		for locale in ["vi", "en"]:
			TranslationServer.set_locale(locale)
			assert_true(tr(rule.text_key) != rule.text_key, "%s has %s text" % [rule.text_key, locale])
	TranslationServer.set_locale("vi")
	assert_eq(fatal, [&"rollcall_fifth_note"] as Array[StringName], "only answering the fifth name is fatal;")
	for situation in [&"lights_out", &"knock_at_door", &"footsteps_behind", &"roll_call_self",
			&"roll_call_roommate", &"roll_call_fifth", &"tap_running"]:
		var genuine := RuleSystem.rules_for(situation).filter(func(rule: RuleData) -> bool: return not rule.is_fake)
		assert_eq(genuine.size(), 1, "one genuine line for %s;" % situation)
	assert_true(RuleSystem.resolve(&"roll_call_fifth", &"answer")["fatal"], "answering Lam fails the night")
	assert_eq(RuleSystem.resolve(&"tap_running", &"look_in_mirror")["outcome"], RuleSystem.OUTCOME_FOLLOWED_FAKE, "mirror notice is fake;")
