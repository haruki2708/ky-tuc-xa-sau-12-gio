extends "res://scripts/debug/chapter_bot.gd"
## Event-driven chapter 2 observer. No manufactured word/temperature events,
## no invincibility, no writes to story completion flags or real save files.

const CH2_ACTIONS := preload("res://scripts/debug/ch2_actions.gd")
const POLICY := preload("res://scripts/debug/ch2_policy.gd")
const CASES := {
	"ch2_good": {"reason": "", "checkpoint": "", "kind": ""},
	"ch2_chain_timeout": {"reason": "DEATH_CH2_CHAIN_TIMEOUT", "checkpoint": "ch2_r3", "kind": "corpse_lunge"},
	"ch2_chain_wrong": {"reason": "DEATH_CH2_CHAIN_WRONG", "checkpoint": "ch2_r3", "kind": "corpse_lunge"},
	"ch2_scald": {"reason": "DEATH_CH2_SCALDED", "checkpoint": "ch2_r4", "kind": "scald"},
	"ch2_leave_shower": {"reason": "DEATH_CH2_SHOWER_BROKEN", "checkpoint": "ch2_r4", "kind": "fall_back"},
	"ch2_wrong_prediction": {"reason": "DEATH_CH2_LOST_NGU", "checkpoint": "ch2_r4", "kind": "none"},
}
var death_kinds: Array[StringName] = []
var busy: bool = false
var negative_action_done: bool = false
var pickup_index: int = 0
var timeout_started: int = 0
var timeout_limit: float = 0.0
var door_opened: bool = false
var scald_verified: bool = false
var last_wipe_slot: int = -1
var friends_told: bool = false


func valid_scenarios() -> Array[String]:
	var result_list: Array[String] = []
	result_list.assign(CASES.keys())
	return result_list


func _run() -> void:
	started = Time.get_ticks_msec()
	for arg: String in OS.get_cmdline_user_args():
		if arg.begins_with("--report="): report_path = arg.trim_prefix("--report=")
		if arg.begins_with("--chapter-profile="):
			var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(arg.trim_prefix("--chapter-profile=")))
			if parsed is Dictionary: profile = parsed
	if not preload("res://scripts/debug/qa_menu.gd").isolated():
		failure = "chapter 2 requires isolated userdata from tools/playthrough.ps1"
		await _finish()
		return
	var missing := preflight(profile, scenario)
	for reason: String in missing: _skip(reason)
	if not missing.is_empty():
		await _finish()
		return
	if story_scale != 1.0:
		failure = "chapter 2 timing checks require TimeScale=1 (15-second timeout and shower commitment)"
		await _finish()
		return
	main = (load(profile.scene) as PackedScene).instantiate()
	main.process_mode = Node.PROCESS_MODE_PAUSABLE
	director = main.get_node_or_null(profile.director)
	if director == null or not director.has_method("start") or not _has_property(director, &"auto_start"):
		_skip("T-170 director start()/auto_start not integrated")
		main.free()
		await _finish()
		return
	director.auto_start = false
	if _has_property(director, &"time_scale"): director.time_scale = story_scale
	actions = CH2_ACTIONS.new()
	actions.profile = profile
	add_child(actions)
	EventBus.player_failed.connect(_failure_observed)
	EventBus.player_death_started.connect(func(kind: StringName) -> void: death_kinds.append(kind))
	EventBus.checkpoint_loaded.connect(func(id: StringName) -> void: loaded_checkpoints.append(id))
	EventBus.chapter_finished.connect(func(number: int) -> void: completed_chapters.append(number))
	GameState.reset()
	GameState.chapter = 2
	get_tree().root.add_child(main)
	get_tree().current_scene = main
	actions.world = main
	player = actions.player_node()
	original_main_id = main.get_instance_id()
	previous_minutes = GameState.minutes
	EventBus.time_changed.connect(func(value: int) -> void:
		game_minutes += maxi(0, value - previous_minutes)
		previous_minutes = value)
	await get_tree().physics_frame
	director.start()
	while failure.is_empty() and skipped.is_empty():
		if scenario == "ch2_good" and 2 in completed_chapters:
			if Progress.unlocked_chapter() < 3 or not failed_rules.is_empty() or actions.gagged.size() != 3 or not actions.loop_completed or not friends_told or actions.counted_minutes < 25 or not actions.both_predictions_correct() or not actions.trap_confirmed:
				failure = "chapter completion did not verify gags, trap, four-word loop, friends told, shower minutes, both predictions and unlock 3"
			break
		if not failed_rules.is_empty():
			await _verify_death()
			break
		if Time.get_ticks_msec() - started > 3600000:
			failure = "chapter 2 exceeded 60 real minutes"
			break
		if not busy:
			busy = true
			await _tick_actions()
			busy = false
		await get_tree().process_frame
	await _finish()


static func preflight(data: Dictionary, case_name: String) -> Array[String]:
	var missing: Array[String] = []
	if not data.get("scene") is String or not ResourceLoader.exists(str(data.get("scene", ""))):
		missing.append("T-170 chapter2.tscn is not integrated")
	if Ch2Dictionary.shared().spelling.is_empty(): missing.append("T-176 dictionary is unavailable")
	var required := ["round3_segment", "round4_segment", "death_ui_path"]
	if case_name == "ch2_scald": required.append("scald_temperature_flag")
	for key: String in required:
		if data.get("bindings", {}).get(key) == null: missing.append("T-170 binding missing: " + key)
	if case_name not in ["ch2_chain_timeout", "ch2_chain_wrong"]:
		for key in ["pickup_rag", "pickup_towel", "pickup_shirt", "gag_1", "gag_2", "gag_4", "bedroom", "push_door_1", "push_door_2", "push_door_3", "enter_shower", "leave_shower", "wipe"]:
			if data.get("actions", {}).get(key) == null: missing.append("T-171 physical binding missing: " + key)
	return missing


func _process(_delta: float) -> void:
	# Death UI can disappear in the same frame as the game's reload.
	if finishing or not is_instance_valid(main): return
	var path: Variant = profile.get("bindings", {}).get("death_ui_path")
	if path is String:
		var view := main.get_node_or_null(path)
		if view is CanvasItem and view.is_visible_in_tree(): saw_death = true


func _failure_observed(reason: StringName) -> void:
	failed_rules.append(reason)
	if scenario == "ch2_scald":
		var flag := StringName(str(profile.bindings.scald_temperature_flag))
		scald_verified = int(GameState.get_flag(flag, -1)) == 81


func _tick_actions() -> void:
	var bindings: Dictionary = profile.bindings
	if actions.incoming != &"": _record(await actions.execute({"op": "answer_call"}))
	for member: StringName in actions.prediction_pending.keys():
		if actions.prediction_answers.has(member): continue
		var wrong: bool = scenario == "ch2_wrong_prediction" and member == &"ngu"
		var outcome: Dictionary = actions.answer_prediction(member, wrong, member == &"minh_nhat")
		_record(outcome)
		if wrong and outcome.status == "PASS": negative_action_done = true
	if negative_action_done: return
	# D-072: after two loop words the friends ask how to pass; answer 1 (gag all three, repeat the loop).
	if actions.choices.has(&"tell"):
		var told: Dictionary = await actions.execute({"op": "choice", "id": "tell", "index": 0})
		_record(told)
		friends_told = friends_told or told.status == "PASS"
		return
	if actions.chain_pending:
		if actions.chain_submitted: return
		if actions.chain_blocked:
			await _physical("bedroom")
			return
		if scenario == "ch2_chain_timeout":
			if timeout_started == 0:
				timeout_started = actions.chain_requested_at
				timeout_limit = actions.chain_seconds
			return # Deliberately send no answer or synthetic timeout signal.
		var mode := "loop" if actions.gagged.size() == 3 else "legal"
		if scenario == "ch2_chain_wrong": mode = "wrong_tone"
		var answer: Dictionary = actions.recommendation(mode)
		if mode == "wrong_tone" and answer.status == "UNAVAILABLE": mode = "legal"
		if mode == "legal" and pickup_index < 3:
			var trap: Dictionary = actions.recommendation("trap")
			if trap.status == "PASS": mode = "trap"
		answer = actions.recommendation(mode)
		if answer.status == "PASS" and director.has_method("is_valid_word"):
			var valid: bool = director.is_valid_word(answer.word)
			if valid == (mode == "wrong_tone"):
				failure = "independent word policy disagrees with core validity"
				return
		answer = actions.answer_chain(mode)
		if answer.status == "UNAVAILABLE": answer = ACTIONS.result("FAIL", "no legal word/route to the four-word loop")
		_record(answer)
		if mode == "wrong_tone" and answer.status == "PASS": negative_action_done = true
		return
	if str(GameState.segment) == str(bindings.round3_segment) and scenario not in ["ch2_chain_timeout", "ch2_chain_wrong"] and pickup_index < 3 and actions.trap_confirmed:
		var item: String = ["rag", "towel", "shirt"][pickup_index]
		var bed_number: int = [1, 2, 4][pickup_index]
		await _physical("pickup_" + item)
		await _physical("gag_" + str(bed_number))
		await _physical("bedroom")
		pickup_index += 1
	if str(GameState.segment) == str(bindings.round4_segment):
		if not door_opened:
			for n in range(1, 4): await _physical("push_door_" + str(n))
			door_opened = true
		if actions.shower_pending:
			var slot: int = actions.temperatures.size()
			var yes := POLICY.shower_yes(actions.temperatures)
			if scenario == "ch2_scald" and slot == 3: yes = true
			await _physical("enter_shower" if yes else "leave_shower")
			if not skipped.is_empty() or not failure.is_empty(): return
			if scenario == "ch2_scald" and slot == 3: negative_action_done = true
			EventBus.shower_choice_made.emit(yes)
			if scenario == "ch2_leave_shower" and yes:
				await _physical("leave_shower")
				negative_action_done = true
		if negative_action_done or not failed_rules.is_empty(): return
		if actions.temperatures.size() != last_wipe_slot:
			last_wipe_slot = actions.temperatures.size()
			await _physical("wipe")


func _physical(key: String) -> void:
	if not skipped.is_empty() or not failure.is_empty() or not failed_rules.is_empty(): return
	_record(await actions.physical(key))


func _verify_death() -> void:
	var expected: Dictionary = CASES[scenario]
	if scenario == "ch2_good" or expected.reason not in failed_rules or expected.kind not in death_kinds:
		failure = "unexpected death reason/animation: " + str(failed_rules) + " " + str(death_kinds)
		return
	if scenario == "ch2_chain_timeout" and (timeout_started == 0 or timeout_limit < 15.0 or Time.get_ticks_msec() - timeout_started < 15000):
		failure = "chain timeout did not wait 15 real seconds"
		return
	if scenario != "ch2_chain_timeout" and not negative_action_done:
		failure = "death occurred before the intended negative action"
		return
	if scenario == "ch2_scald" and not scald_verified:
		failure = "scald death did not expose 81 degrees through bound temperature flag"
		return
	await _until(func() -> bool: return StringName(expected.checkpoint) in loaded_checkpoints, "real reload " + expected.checkpoint)
	var current := get_tree().current_scene
	if not saw_death or current == null or current.get_instance_id() == original_main_id or GameState.chapter != 2:
		failure = "death UI / fresh scene / chapter 2 reload not verified"
	if current != null: main = current
