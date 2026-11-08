extends TestCase
## Exercise action scheduling without adding a bot to the tree or running a chapter.

class ActionState extends Node:
	var incoming: StringName = &""
	var prediction_pending: Dictionary = {}
	var choices: Dictionary = {}
	var chain_pending: bool = false
	var shower_pending: bool = false
	var temperatures: Array = []

class ScheduleProbe extends "res://scripts/debug/ch2_bot.gd":
	var called: Array[String] = []
	var reject_position: bool = false
	func _physical(key: String) -> void:
		called.append(key)
		if reject_position and key == "leave_shower": failure = "position not acknowledged"


func test_round_four_positions_before_first_wipe_without_waiting_for_choice() -> void:
	var saved := GameState.to_dict()
	GameState.segment = &"r4"
	var bot := ScheduleProbe.new()
	var state := ActionState.new()
	bot.actions = state
	bot.profile = {"bindings": {"round3_segment": "r3", "round4_segment": "r4"}}
	await bot._tick_actions()
	assert_eq(bot.called, ["push_door_1", "push_door_2", "push_door_3", "leave_shower", "wipe"] as Array[String])
	assert_true(bot.door_opened)
	bot.called.clear()
	await bot._tick_actions()
	assert_true(bot.called.is_empty(), "do not move or wipe again before a new slot")
	state.free()
	bot.free()
	GameState.from_dict(saved)


func test_failed_initial_position_does_not_wipe_or_mark_door_setup_complete() -> void:
	var saved := GameState.to_dict()
	GameState.segment = &"r4"
	var bot := ScheduleProbe.new()
	var state := ActionState.new()
	bot.actions = state
	bot.profile = {"bindings": {"round3_segment": "r3", "round4_segment": "r4"}}
	bot.reject_position = true
	await bot._tick_actions()
	assert_false("wipe" in bot.called)
	assert_false(bot.door_opened)
	assert_eq(bot.failure, "position not acknowledged")
	state.free()
	bot.free()
	GameState.from_dict(saved)
