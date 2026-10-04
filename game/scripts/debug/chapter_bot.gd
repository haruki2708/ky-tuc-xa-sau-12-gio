extends "res://scripts/debug/playthrough_bot.gd"
## Chapter flow bindings come from an explicit QA profile after T-150 merges.
## Never infer segment/checkpoint ids or chat answers from the retired demo.

const ACTIONS := preload("res://scripts/debug/chapter_actions.gd")
var actions: Node
var profile: Dictionary = {}
var skipped: Array[String] = []
var observations: Array[Dictionary] = []
var report_path: String = ""
var failed_rules: Array[StringName] = []
var loaded_checkpoints: Array[StringName] = []
var completed_chapters: Array[int] = []
var saw_death: bool = false
var game_minutes: int = 0
var previous_minutes: int = 0
var original_main_id: int = 0
var missing_bindings: Array[String] = []
var plan_incomplete: bool = false
var chapter_started_at: int = 0


func valid_scenarios() -> Array[String]:
	return ["ch1_good", "ch1_stay_in_bed", "ch1_leave_room", "ch1_own_bed"]


func template_path() -> String:
	return "res://scripts/debug/ch1_scenarios.json"


func create_actions() -> Node:
	return ACTIONS.new()


func _run() -> void:
	started = Time.get_ticks_msec()
	for arg: String in OS.get_cmdline_user_args():
		if arg.begins_with("--report="):
			report_path = arg.trim_prefix("--report=")
		if arg.begins_with("--chapter-profile="):
			var path := arg.trim_prefix("--chapter-profile=")
			var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
			if not parsed is Dictionary:
				failure = "chapter profile must be a JSON object"
				await _finish()
				return
			profile = parsed
	var isolated_root := OS.get_environment("QA_PLAYTHROUGH_ROOT").replace("\\", "/")
	if isolated_root.is_empty() or not OS.get_user_data_dir().replace("\\", "/").begins_with(isolated_root + "/"):
		failure = "chapter bot requires isolated user data from tools/playthrough.ps1"
		await _finish()
		return
	if not profile.get("bindings", {}) is Dictionary:
		failure = "chapter profile bindings must be an object"
		await _finish()
		return
	var templates: Variant = JSON.parse_string(FileAccess.get_file_as_string(template_path()))
	if not templates is Dictionary or not templates.has(scenario):
		failure = "chapter scenario template missing or invalid"
		await _finish()
		return
	var bound_plan: Variant = bind_template(templates[scenario], profile.get("bindings", {}), missing_bindings)
	if missing_bindings.is_empty():
		profile["scenarios"] = {scenario: bound_plan}
	actions = create_actions()
	add_child(actions)
	EventBus.player_failed.connect(func(id: StringName) -> void: failed_rules.append(id))
	EventBus.checkpoint_loaded.connect(func(id: StringName) -> void: loaded_checkpoints.append(id))
	EventBus.chapter_finished.connect(func(number: int) -> void: completed_chapters.append(number))
	previous_minutes = GameState.minutes
	EventBus.time_changed.connect(func(value: int) -> void:
		game_minutes += maxi(0, value - previous_minutes)
		previous_minutes = value)
	var packed := load(str(profile.get("scene", "res://scenes/main/main.tscn"))) as PackedScene
	if packed == null:
		failure = "chapter scene could not load"
		await _finish()
		return
	main = packed.instantiate()
	main.process_mode = Node.PROCESS_MODE_PAUSABLE
	director = main.get_node_or_null(str(profile.get("director", "StoryDirector")))
	if director != null:
		if _has_property(director, &"auto_start"):
			director.set("auto_start", false)
		if _has_property(director, &"time_scale"):
			director.set("time_scale", story_scale)
	get_tree().root.add_child(main)
	actions.world = main
	player = actions.player_node()
	original_main_id = main.get_instance_id()
	await get_tree().process_frame
	await get_tree().physics_frame
	await get_tree().physics_frame
	_check_checkpoint_contract()
	await _check_locked_selection()
	var plans: Variant = profile.get("scenarios", {})
	if not plans is Dictionary or not plans.has(scenario):
		# Capability probes are not a substitute for a chapter playthrough.
		for command: Dictionary in [{"op": "bed", "number": 3}, {"op": "leave_bed"}, {"op": "breath", "seconds": 0.1}, {"op": "phone", "raised": true}, {"op": "answer_call"}]:
			if actions.component("bunk_spot.gd") == null and command.op in ["bed", "leave_bed", "breath"] or actions.component("phone_item.gd") == null and command.op == "phone" or actions.component("phone_screen.gd") == null and command.op == "answer_call":
				_record(await actions.execute(command))
		_skip("chapter flow bindings unavailable (T-150/T-160): scenario=" + scenario)
		_skip("missing bindings: " + ", ".join(missing_bindings))
		if actions.component("puzzle_station.gd") == null:
			_skip("T-151 puzzle_station is not integrated")
		if actions.component("phone_screen.gd") == null:
			_skip("T-155 chat_choice_made receiver is not integrated")
		_skip("bound chapter scenario not executed; no completion claimed")
		await _finish()
		return
	var plan: Variant = plans[scenario]
	if not plan is Dictionary or not plan.get("steps") is Array or plan.steps.is_empty():
		failure = "configured scenario requires nonempty steps"
		await _finish()
		return
	if director == null or not director.has_method("start"):
		failure = "configured chapter director has no start()"
		await _finish()
		return
	# SceneTree.current_scene must be a direct child of root. The observer is
	# a sibling, so it survives the game's real scene replacement.
	get_tree().current_scene = main
	chapter_started_at = Time.get_ticks_msec()
	director.start()
	for step: Variant in plan.steps:
		if not failure.is_empty() or plan_incomplete:
			break
		if not step is Dictionary:
			failure = "scenario step must be an object"
			break
		await _step(step)
	if failure.is_empty() and not plan_incomplete:
		if plan.get("outcome", "complete" if scenario == "ch1_good" else "death") == "complete":
			if not await _until(func() -> bool: return 1 in completed_chapters, "chapter_finished(1)"):
				await _finish()
				return
			if Progress.unlocked_chapter() < 2 or not failed_rules.is_empty():
				failure = "good path did not unlock chapter 2 cleanly"
		else:
			var expected := StringName(str(plan.get("checkpoint", "")))
			var rule := StringName(str(plan.get("failure_rule", "")))
			if expected.is_empty() or rule.is_empty():
				failure = "death scenario requires checkpoint and failure_rule bindings"
			elif not await _until(func() -> bool: return expected in loaded_checkpoints, "reload checkpoint " + expected):
				pass
			else:
				await get_tree().process_frame
				var resumed := get_tree().current_scene
				if rule not in failed_rules or not saw_death or GameState.chapter != 1 or resumed == null or resumed.get_instance_id() == original_main_id:
					failure = "death UI, cause or real scene reload was not verified"
	await _finish()


func _step(step: Dictionary) -> void:
	var op: String = str(step.get("op", ""))
	match op:
		"opening_deadline":
			if Time.get_ticks_msec() - chapter_started_at > 60000 or GameState.get_flag(&"player_bed", 0) != 0:
				failure = "did not leave the opening bed within 60 real seconds"
		"save_reload":
			await _verify_save_reload()
		"wait_segment":
			var id: String = str(step.get("id", ""))
			if id.is_empty():
				failure = "wait_segment needs an actual segment id"
			else:
				await _until(func() -> bool: return str(GameState.segment) == id, "segment " + id)
		"wait_call":
			await _until(func() -> bool: return not actions.incoming.is_empty(), "incoming call")
		"wait_choice":
			var id := StringName(str(step.get("id", "")))
			await _until(func() -> bool: return actions.choices.has(id), "chat choice " + id)
		"death_ui":
			var path: String = str(step.get("path", ""))
			await _until(func() -> bool:
				var view := main.get_node_or_null(path) if is_instance_valid(main) else null
				return view != null and bool(view.get("visible")), "visible death UI " + path)
			saw_death = failure.is_empty()
		_:
			var outcome: Dictionary = await actions.execute(step)
			_record(outcome)
			plan_incomplete = outcome.status == "SKIP"
	_mark("chapter action " + op)


static func bind_template(value: Variant, bindings: Dictionary, missing: Array[String]) -> Variant:
	if value is String and value.begins_with("$"):
		var key: String = value.substr(1)
		if not bindings.has(key) or bindings[key] == null or bindings[key] is String and bindings[key].is_empty():
			if key not in missing:
				missing.append(key)
			return null
		return bindings[key]
	if value is Array:
		var items: Array = []
		for item: Variant in value:
			items.append(bind_template(item, bindings, missing))
		return items
	if value is Dictionary:
		var object: Dictionary = {}
		for key: Variant in value:
			object[key] = bind_template(value[key], bindings, missing)
		return object
	return value


func _check_locked_selection() -> void:
	var scene_path: Variant = profile.get("chapter_select_scene")
	var button_path: Variant = profile.get("chapter2_button_path")
	if not scene_path is String or not button_path is String:
		_skip("T-155 chapter selector scene/button binding unavailable; lock UI not tested")
		return
	if Progress.unlocked_chapter() != 1:
		failure = "chapter probe requires fresh isolated progress"
		return
	var packed := load(scene_path) as PackedScene
	if packed == null:
		failure = "configured chapter selector scene missing"
		return
	var menu := packed.instantiate()
	add_child(menu)
	await get_tree().process_frame
	var button := menu.get_node_or_null(button_path) as BaseButton
	if button == null or not button.disabled:
		failure = "locked chapter 2 selection is not disabled"
	else:
		_record(ACTIONS.result("PASS", "chapter 2 selection disabled with fresh progress"))
	menu.queue_free()


func _verify_save_reload() -> void:
	var phone: Node = actions.component("phone_item.gd")
	var screen: Node = actions.component("phone_screen.gd")
	if phone == null or screen == null or not screen.has_method("snapshot") or not screen.has_method("restore"):
		_skip("T-151/T-155 phone and snapshot/restore are not integrated; reload persistence not tested")
		return
	if not phone.has_method("set_battery") or not _has_property(phone, &"battery"):
		failure = "integrated phone is missing battery contract"
		return
	var id := Checkpoint.peek_id()
	if id.is_empty():
		failure = "mid-chapter checkpoint does not exist"
		return
	phone.set_battery(37.0)
	var battery: float = phone.get("battery")
	var history: Dictionary = screen.snapshot().duplicate(true)
	var chapter := GameState.chapter
	var before := main.get_instance_id()
	loaded_checkpoints.clear()
	if Checkpoint.save(id) != OK:
		failure = "mid-chapter checkpoint save failed"
		return
	App.start_game(true)
	if not await _until(func() -> bool:
		var current := get_tree().current_scene
		return current != null and current.get_instance_id() != before and id in loaded_checkpoints, "real mid-chapter reload"):
		return
	main = get_tree().current_scene
	actions.world = main
	director = main.get_node_or_null(str(profile.get("director", "StoryDirector")))
	player = actions.player_node()
	if director != null and _has_property(director, &"time_scale"):
		director.set("time_scale", story_scale)
	phone = actions.component("phone_item.gd")
	screen = actions.component("phone_screen.gd")
	if phone == null or screen == null or GameState.chapter != chapter or absf(float(phone.get("battery")) - battery) > 0.5 or screen.snapshot() != history:
		failure = "real checkpoint reload lost chapter, phone battery or call history"
	else:
		_record(ACTIONS.result("PASS", "real checkpoint reload preserved chapter, battery and call history"))


func _process(delta: float) -> void:
	super._process(delta)
	if not finishing and started > 0 and Time.get_ticks_msec() - started > total_timeout() * 1000.0 and failure.is_empty():
		failure = "chapter observer timeout"


func total_timeout() -> float:
	return segment_timeout * 6.0


func _until(condition: Callable, label: String) -> bool:
	var deadline := Time.get_ticks_msec() + int(segment_timeout * 1000.0)
	while failure.is_empty() and not condition.call():
		if Time.get_ticks_msec() >= deadline:
			failure = "timeout waiting for " + label
			break
		await get_tree().process_frame
	return failure.is_empty()


func _check_checkpoint_contract() -> void:
	var state := GameState.to_dict()
	var rules := RuleSystem.to_dict()
	var path := "user://qa_chapter_contract.json"
	GameState.chapter = 1
	if Checkpoint.save(&"qa_mid_chapter", path) != OK:
		failure = "checkpoint write failed"
	else:
		GameState.chapter = 4
		if Checkpoint.restore(path) != &"qa_mid_chapter" or GameState.chapter != 1:
			failure = "checkpoint failed to preserve chapter"
		else:
			_record(ACTIONS.result("PASS", "chapter round-trip through temporary checkpoint (not scene reload)"))
	Checkpoint.clear(path)
	GameState.from_dict(state)
	RuleSystem.from_dict(rules)
	loaded_checkpoints.clear()
	game_minutes = 0
	previous_minutes = GameState.minutes


func _has_property(node: Node, key: StringName) -> bool:
	for property: Dictionary in node.get_property_list():
		if property.name == key:
			return true
	return false


func _record(outcome: Dictionary) -> void:
	observations.append(outcome)
	print("CHAPTER_CHECK: %s %s" % [outcome.status, outcome.reason])
	if outcome.status == "FAIL":
		failure = outcome.reason
	elif outcome.status == "SKIP":
		skipped.append(outcome.reason)


func _skip(reason: String) -> void:
	_record(ACTIONS.result("SKIP", reason))


func _finish() -> void:
	finishing = true
	if is_instance_valid(actions):
		actions.cancel()
	var capture_deadline := Time.get_ticks_msec() + 3000
	while captures_pending > 0 and Time.get_ticks_msec() < capture_deadline:
		await get_tree().process_frame
	if captures_pending > 0:
		failure = "milestone capture timed out"
	var status := "FAIL" if not failure.is_empty() else ("SKIP" if not skipped.is_empty() else "PASS")
	var report := {"scenario": scenario, "status": status, "reason": failure, "skipped": skipped,
		"real_seconds": (Time.get_ticks_msec() - started) / 1000.0, "game_minutes": game_minutes, "checks": observations}
	if not report_path.is_empty():
		var file := FileAccess.open(report_path, FileAccess.WRITE)
		if file == null:
			status = "FAIL"
			failure = "cannot write chapter report"
		else:
			file.store_string(JSON.stringify(report, "\t") + "\n")
	print("PLAYTHROUGH_RESULT: %s scenario=%s real_seconds=%.2f game_minutes=%d %s" % [status, scenario, report.real_seconds, game_minutes, failure if status == "FAIL" else "; ".join(skipped)])
	# A capability-only run may quit before the first spatial audio mix.
	# Release its scene and drain the mixer, as in the smoke fixture cleanup.
	if is_instance_valid(main):
		main.process_mode = Node.PROCESS_MODE_DISABLED
		for node: Node in main.find_children("*", "", true, false):
			if node.has_method("stop_emitting"):
				node.stop_emitting()
			if node is AudioStreamPlayer or node is AudioStreamPlayer2D or node is AudioStreamPlayer3D:
				node.stop()
		main.queue_free()
		await get_tree().create_timer(0.3, true, false, true).timeout
	App.quit(1 if status == "FAIL" else 0)
