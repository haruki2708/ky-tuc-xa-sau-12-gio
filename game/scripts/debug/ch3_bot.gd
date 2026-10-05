extends "res://scripts/debug/chapter_bot.gd"
## Chapter 3 observer: full runs require explicit integration authorization.

const POLICY := preload("res://scripts/debug/ch3_policy.gd")
const CH3_ACTIONS := preload("res://scripts/debug/ch3_actions.gd")
var kinds: Array[StringName] = []
var death_stage: String = ""
var negative_started: bool = false


func valid_scenarios() -> Array[String]:
	var names: Array[String] = []
	names.assign(POLICY.CASES)
	return names


func _run() -> void:
	started = Time.get_ticks_msec()
	for arg: String in OS.get_cmdline_user_args():
		if arg.begins_with("--report="): report_path = arg.trim_prefix("--report=")
		if arg.begins_with("--chapter-profile="):
			var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(arg.trim_prefix("--chapter-profile=")))
			if parsed is Dictionary: profile = parsed
	for reason: String in POLICY.preflight(profile): _skip(reason)
	if not skipped.is_empty():
		await _finish()
		return
	if story_scale != 1.0:
		failure = "chapter 3 requires TimeScale=1"
		await _finish()
		return
	if not preload("res://scripts/debug/qa_menu.gd").isolated():
		failure = "chapter 3 requires isolated userdata"
		await _finish()
		return
	main = (load(profile.scene) as PackedScene).instantiate()
	director = main.get_node_or_null(str(profile.director))
	if director == null or not director.has_method("run_from") or not _has_property(director, &"auto_start"):
		_skip("T-181 run_from/auto_start unavailable")
		main.free()
		await _finish()
		return
	director.auto_start = false
	main.process_mode = Node.PROCESS_MODE_PAUSABLE
	actions = CH3_ACTIONS.new()
	actions.profile = profile
	actions.world = main
	add_child(actions)
	EventBus.player_failed.connect(func(reason: StringName) -> void:
		failed_rules.append(reason)
		death_stage = str(GameState.segment))
	EventBus.player_death_started.connect(func(kind: StringName) -> void: kinds.append(kind))
	EventBus.checkpoint_loaded.connect(func(id: StringName) -> void: loaded_checkpoints.append(id))
	EventBus.chapter_finished.connect(func(chapter: int) -> void: completed_chapters.append(chapter))
	EventBus.segment_changed.connect(func(id: StringName) -> void:
		if id not in visited: visited.append(id))
	GameState.reset()
	GameState.chapter = 3
	get_tree().root.add_child(main)
	get_tree().current_scene = main
	player = actions.player_node()
	original_main_id = main.get_instance_id()
	var first := "gate" if scenario == "ch3_guard" else str(profile.bindings.grab_stage) if scenario == "ch3_grabbed" else "b"
	negative_started = scenario != "ch3_good"
	director.run_from(StringName(first))
	await get_tree().physics_frame
	if scenario == "ch3_good":
		for stage: String in POLICY.STAGES:
			if not await _until(func() -> bool: return str(GameState.segment) == stage or not failed_rules.is_empty(), stage): break
			for point: Dictionary in profile.routes[stage]:
				if not failed_rules.is_empty() or not failure.is_empty() or not skipped.is_empty(): break
				_record(await actions.walk(point))
				if point.has("action") and failure.is_empty(): _record(await actions.perform(point.action))
		await _until(func() -> bool: return 3 in completed_chapters or not failed_rules.is_empty(), "chapter 3 completion")
		if not failed_rules.is_empty(): failure = "unexpected death " + str(failed_rules)
		for key in ["key_taken", "noise_203", "stadium_survived"]:
			if not CH3_ACTIONS.acknowledged(profile.bindings[key]): failure = "missing milestone: " + key
		if Progress.unlocked_chapter() < 4 or not actions.bar_received or actions.companions.size() < 2 or visited.size() < 4:
			failure = "chapter 4 unlock / bar / companions / four stages not verified"
	else:
		if scenario == "ch3_guard":
			var point: Variant = profile.get("guard_target")
			if not point is Dictionary: _skip("guard target not bound")
			else:
				var outcome: Dictionary = await actions.walk(point, true)
				if failed_rules.is_empty(): _record(outcome)
		if skipped.is_empty() and failure.is_empty():
			await _until(func() -> bool: return not failed_rules.is_empty(), "real death")
			await _verify_ch3_death()
	await _finish()


func _process(_delta: float) -> void:
	if finishing or not is_instance_valid(main): return
	var path: Variant = profile.get("bindings", {}).get("death_ui")
	if path is String:
		var view := main.get_node_or_null(path)
		if view is CanvasItem and view.is_visible_in_tree(): saw_death = true
	if started > 0 and Time.get_ticks_msec() - started > 4500000: failure = "chapter 3 exceeded 75 minutes"


func _verify_ch3_death() -> void:
	var reason := &"DEATH_CH3_GUARD" if scenario == "ch3_guard" else &"DEATH_CH3_GRABBED"
	var kind := &"guard_shock" if scenario == "ch3_guard" else &"zombie_grab"
	var stage := "gate" if scenario == "ch3_guard" else str(profile.bindings.grab_stage)
	if not negative_started or reason not in failed_rules or death_stage != stage:
		failure = "wrong death reason/stage: " + str(failed_rules) + " " + death_stage
		return
	await _until(func() -> bool: return kind in kinds and StringName("ch3_" + stage) in loaded_checkpoints, "death animation and real checkpoint reload")
	var current := get_tree().current_scene
	if not saw_death or current == null or current.get_instance_id() == original_main_id or GameState.chapter != 3:
		failure = "death UI / fresh chapter 3 reload not verified"
	if current != null: main = current
