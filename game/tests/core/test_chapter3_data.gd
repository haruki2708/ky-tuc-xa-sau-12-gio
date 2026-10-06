extends TestCase
## Chapter 3 script data (T-181): the rule book is valid (RuleSystem refuses
## an invalid one and the chapter would not start), call lines and in-person
## lines are translated.


func test_rule_book_is_valid() -> void:
	var rules: RuleSet = load("res://data/rules/ch3.tres")
	assert_not_null(rules, "ch3.tres loads")
	var errors := rules.validate()
	assert_true(errors.is_empty(), "chapter 3 rules valid: %s" % ", ".join(errors))


func test_call_lines_load_and_are_translated() -> void:
	for id in ["n_all_up", "n_out", "ngu_garden", "n_trapped", "n_sound"]:
		var data := MessageData.load_by_id(StringName("chat_ch3_" + id))
		assert_not_null(data, id)
		if data != null:
			assert_true(tr(data.text_key) != data.text_key, "translated " + data.text_key)


func test_script_keys_exist() -> void:
	for key in ["SPK_CH3_R5_INTRO", "RULE_CH3_R5_2", "NEAR_CH3_NGU_BARS", "NEAR_CH3_N_SPLIT", "ROOM_CH3_TV_NEWS",
			"THINK_CH3_RUN", "DEATH_CH3_GRABBED", "DEATH_CH3_GUARD", "DEATH_CH3_SURROUNDED", "PROMPT_CH3_EXTINGUISHER"]:
		assert_true(tr(key) != key, key)
