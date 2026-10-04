extends TestCase

const ACTIONS := preload("res://scripts/debug/ch1v2_actions.gd")
const MENU := preload("res://scripts/debug/qa_menu.gd")


func test_tap_code_timing_has_coordinate_and_letter_boundaries() -> void:
	var times := ACTIONS.tap_schedule("13 34")
	assert_eq(times.size(), 11)
	assert_true(is_equal_approx(times[1] - times[0], 1.0))
	assert_true(is_equal_approx(times[2] - times[1], 0.18))
	assert_true(is_equal_approx(times[4] - times[3], 2.5))
	for invalid in ["", "0", "123", "66", "CO", "1-3"]:
		assert_true(ACTIONS.tap_schedule(invalid).is_empty(), invalid)


func test_missing_v2_actions_skip_and_invalid_commands_fail() -> void:
	var helper := ACTIONS.new()
	tree.root.add_child(helper)
	for command: Dictionary in [{"op": "wall_taps", "code": "13 34"}, {"op": "keypad", "code": "2109"}, {"op": "cable", "color": "blue"}, {"op": "desk_lamp", "on": false}, {"op": "search", "spot": "trash"}, {"op": "camera_tab"}]:
		var outcome: Dictionary = await helper.execute(command)
		assert_eq(outcome.status, "SKIP", str(command))
	for command: Dictionary in [{"op": "power_switch", "index": 4, "on": true}, {"op": "keypad", "code": "-123"}, {"op": "latch", "on": "yes"}]:
		assert_false(ACTIONS.valid_v2(command))
	helper.free()


func test_invincibility_logs_death_without_triggering_core_death() -> void:
	var director := preload("res://scripts/debug/qa_director.gd").new()
	director.invincible = true
	director._die(&"DEATH_SEEN")
	director._die(&"DEATH_SEEN")
	assert_false(director._dying)
	assert_eq(director.suppressed.size(), 1)
	director.free()


func test_unbound_missions_cannot_be_reported_as_complete() -> void:
	var plans: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://scripts/debug/ch1v2_scenarios.json"))
	assert_eq(plans.size(), 5)
	for name: String in plans:
		var missing: Array[String] = []
		preload("res://scripts/debug/chapter_bot.gd").bind_template(plans[name], {}, missing)
		assert_false(missing.is_empty(), name)
	assert_eq(plans.ch1v2_door_late.checkpoint, "$round1_checkpoint")
	assert_eq(plans.ch1v2_lamp_on.checkpoint, "$round2_checkpoint")
	assert_eq(plans.ch1v2_wrong_advice.failure_rule, "DEATH_LOST_NHAT")


func test_menu_preserves_an_existing_pause_and_gates_save_isolation() -> void:
	var menu := MENU.new()
	tree.root.add_child(menu)
	var paused := tree.paused
	tree.paused = true
	menu.set_open(true)
	menu.set_open(false)
	assert_true(tree.paused, "QA must not unpause a document or pause menu")
	tree.paused = paused
	assert_false(MENU.isolated(), "unit runner is not authorized as a QA play session")
	menu.free()
