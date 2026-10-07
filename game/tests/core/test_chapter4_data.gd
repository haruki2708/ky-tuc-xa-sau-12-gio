extends TestCase
## Chapter 4 script data (T-194): the rule book holds every round for the
## library's "Đối chiếu" tab and is valid, call lines and the nurses' lines are
## translated, and the map and night log open as documents.


func test_rule_book_holds_all_rounds_and_is_valid() -> void:
	var rules: RuleSet = load("res://data/rules/ch4.tres")
	assert_not_null(rules, "ch4.tres loads")
	var errors := rules.validate()
	assert_true(errors.is_empty(), "chapter 4 rules valid: %s" % ", ".join(errors))
	var ids: Array[StringName] = []
	for rule in rules.rules:
		ids.append(rule.id)
	for id in [&"ch1_general_3", &"ch1_r2", &"ch2_r3_1", &"ch2_r4_1", &"ch3_r5_1", &"ch3_r5_2", &"ch3_r5_3"]:
		assert_true(id in ids, "rule %s in the book" % id)


func test_call_lines_load_and_are_translated() -> void:
	for id in ["ngu_go", "n_go", "ngu_lecture", "n_gym", "ngu_no_exit", "n_line", "ngu_trung", "n_where", "n_lost", "n_got"]:
		var data := MessageData.load_by_id(StringName("chat_ch4_" + id))
		assert_not_null(data, id)
		if data != null:
			assert_true(tr(data.text_key) != data.text_key, "translated " + data.text_key)


func test_script_keys_exist() -> void:
	for key in ["SPK_CH4_REGISTERED", "NEAR_CH4_NURSE1_AWAKE", "NEAR_CH4_NURSE2_QUAKE", "NEAR_CH4_NURSE2_ALL",
			"NEAR_CH4_NURSE2_ALONE", "SAY_CH4_TRUNG_ASK", "DOC_CH4_MAP_TITLE", "DOC_CH4_DIARY_2", "UI_CH4_SOLVED_R2",
			"UI_CH4_SOLVED_R3", "UI_CH4_SOLVED_R4", "DEATH_CH4_GRABBED", "DEATH_CH4_STAIRS", "DEATH_CH4_LIBRARY",
			"DEATH_CH4_DOOR", "PROMPT_CH4_DESK", "NAME_CH4_MINH_NHAT", "NAME_CH4_NGU"]:
		assert_true(tr(key) != key, key)


func test_papers_open_as_documents() -> void:
	for id in [&"ch4_map", &"ch4_diary"]:
		var document := DocumentData.load_by_id(id)
		assert_not_null(document, String(id))
		if document != null:
			assert_true(tr(document.title_key) != document.title_key, "title " + document.title_key)
			assert_false(document.text_keys.is_empty(), "lines " + String(id))
			for key in document.text_keys:
				assert_true(tr(key) != key, key)
