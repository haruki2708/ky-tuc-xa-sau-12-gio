extends Node
## API-driven integration check. Never writes story flags or resolves rules itself.

const MAIN := preload("res://scenes/main/main.tscn")
var scenario: String = "correct"
var story_scale: float = 0.05
var segment_timeout: float = 45.0
var main: Node
var director: Node
var player: CharacterBody3D
var failure: String = ""
var segment: StringName = &""
var segment_started: int = 0
var started: int = 0
var visited: Array[StringName] = []
var subtitles: Array[String] = []
var chases_started: Array[StringName] = []
var chases_escaped: Array[StringName] = []
var capture_dir: String = ""
var capture_index: int = 0
var captures_pending: int = 0
var finishing: bool = false


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	for arg: String in OS.get_cmdline_user_args():
		if arg.begins_with("--scenario="):
			scenario = arg.trim_prefix("--scenario=")
		elif arg.begins_with("--story-scale="):
			story_scale = float(arg.trim_prefix("--story-scale="))
		elif arg.begins_with("--segment-timeout="):
			segment_timeout = float(arg.trim_prefix("--segment-timeout="))
		elif arg.begins_with("--capture-dir="):
			capture_dir = arg.trim_prefix("--capture-dir=")
	if scenario not in ["correct", "deviant", "mirror"] or story_scale <= 0.0 or segment_timeout <= 0.0:
		failure = "invalid bot arguments"
		_finish.call_deferred()
		return
	_run.call_deferred()


func _run() -> void:
	started = Time.get_ticks_msec()
	main = MAIN.instantiate()
	# The bot must run while documents pause the tree, but gameplay must not
	# inherit ALWAYS: LightHum would restart audio during App.quit's drain.
	main.process_mode = Node.PROCESS_MODE_PAUSABLE
	director = main.get_node("StoryDirector")
	director.auto_start = false
	director.time_scale = story_scale
	add_child(main)
	player = main.get_node("Player")
	director.restart_requested.connect(_on_restart)
	EventBus.subtitle_requested.connect(_on_subtitle)
	EventBus.chase_started.connect(_on_chase_started)
	EventBus.chase_ended.connect(_on_chase_ended)
	await get_tree().process_frame
	director.start()
	await _play()
	await _finish()


func _play() -> void:
	if not await _until(func() -> bool: return GameState.segment == &"seg1", "segment 1"):
		return
	_place(Vector3(32, 0.03, -2.0), 0.0)
	_set_door(false)
	await _read("Floor4/Door407/Pivot/RulesPaper/RulesPaper407")
	_use("Room407LightSwitch")
	_set_latched(true)
	if not await _until(func() -> bool: return main.get_node("PhoneTrung").enabled, "phone rings"):
		return
	_use("PhoneTrung")
	_mark("phone answered")
	if not await _until(func() -> bool: return GameState.segment == &"seg2", "segment 2"):
		return
	if scenario == "deviant":
		if not await _until(func() -> bool: return "SUB_KNOCK" in subtitles, "knocking"):
			return
		_set_latched(false)
		_set_door(true)
	if not await _until(func() -> bool: return not RuleSystem.outcome_of(&"knock_at_door").is_empty(), "knock judgement"):
		return
	_set_door(false)
	if not await _until(func() -> bool: return GameState.segment == &"seg3", "segment 3"):
		return
	_set_latched(false)
	_set_door(true)
	_place_anchor("HallBoard")
	await _read("Floor4/Anchors/HallBoard/HallBoard")
	_place_anchor("DutyLog")
	await _read("Floor4/Anchors/DutyLog/DutyLog")
	_place(Vector3(36, 0.03, 1.2), -PI / 2.0 if scenario == "deviant" else PI / 2.0)
	if not await _until(func() -> bool: return main.get_node("Floor4").has_node("FollowerSteps"), "following footsteps"):
		return
	if scenario != "deviant":
		_place(Vector3(32, 0.03, -2.0), 0.0)
	else:
		if not await _until(func() -> bool: return &"corridor" in chases_started, "corridor chase"):
			return
		_place(Vector3(20, 0.03, 1.2), PI / 2.0)
		if not await _until(func() -> bool: return &"corridor" in chases_escaped, "escape to light"):
			return
		_mark("corridor escaped")
		_place(Vector3(32, 0.03, -2.0), 0.0)
	_set_door(false)
	_set_latched(true)
	if not await _until(func() -> bool: return GameState.segment == &"seg4", "segment 4"):
		return
	await _read("Floor4/Anchors/Locker_Trung/RoomRecord407")
	if not await _until(func() -> bool: return GameState.segment == &"seg5", "roll call finishes without restart"):
		return
	if RuleSystem.outcome_of(&"roll_call_self") != RuleSystem.OUTCOME_CORRECT:
		failure = "own name was not answered correctly"
		return
	_set_latched(false)
	_set_door(true)
	if not await _until(func() -> bool: return GameState.get_flag(&"tap_running", false) == true, "tap starts"):
		return
	_place(Vector3(2.0, 0.03, -2.5), -PI / 2.0)
	await _read("Floor4/Anchors/WashroomNotice/WashroomNotice")
	if scenario != "mirror":
		_use("Floor4/Anchors/WashroomTapRunning/TapTrigger")
		await get_tree().physics_frame
		await get_tree().physics_frame
		_place(Vector3(8, 0.03, 1.2), -PI / 2.0)
	else:
		_place(Vector3(2, 0.03, -1.85), PI / 2.0)
		if not await _until(func() -> bool: return "SUB_RUN_TO_ROOM" in subtitles, "mirror looks back"):
			return
		_place(Vector3(9, 0.03, 1.2), -PI / 2.0)
		if not await _until(func() -> bool: return &"mirror" in chases_started, "mirror chase"):
			return
	_place(Vector3(32, 0.03, -2.5), 0.0)
	_set_door(false)
	_set_latched(true)
	if scenario == "mirror":
		if not await _until(func() -> bool: return &"mirror" in chases_escaped, "escape to latched room"):
			return
		_mark("mirror escaped")
	if not await _until(func() -> bool: return director.finished, "ending completes"):
		return
	var expected: int = 2 if scenario == "deviant" else 1
	var expected_deviation: int = {"correct": 0, "deviant": 4, "mirror": 2}[scenario]
	if GameState.get_flag(&"ending_variant", 0) != expected:
		failure = "wrong ending: expected %d, got %s" % [expected, GameState.get_flag(&"ending_variant", 0)]
	elif GameState.deviation != expected_deviation:
		failure = "wrong deviation: expected %d, got %d" % [expected_deviation, GameState.deviation]
	elif visited != [&"seg1", &"seg2", &"seg3", &"seg4", &"seg5", &"end"]:
		failure = "missing or repeated segment: %s" % str(visited)
	else:
		_mark("ending variant %d" % expected)


func _process(_delta: float) -> void:
	if not is_instance_valid(director) or finishing:
		return
	if GameState.segment != segment:
		segment = GameState.segment
		segment_started = Time.get_ticks_msec()
		visited.append(segment)
		_mark("%s start" % segment)
	if Time.get_ticks_msec() - segment_started > segment_timeout * 1000.0 and failure.is_empty():
		failure = "segment timeout: %s after %.1fs" % [segment, segment_timeout]


func _until(condition: Callable, label: String) -> bool:
	while failure.is_empty() and not condition.call():
		await get_tree().process_frame
	if not failure.is_empty():
		failure += " (waiting for %s)" % label
		return false
	return true


func _use(path: String) -> void:
	if not failure.is_empty():
		return
	var target := main.get_node_or_null(path)
	if target == null or not target.has_method("interact") or not target.get("enabled"):
		failure = "missing or disabled interactable: " + path
		return
	target.interact(player)


func _read(path: String) -> void:
	_use(path)
	await get_tree().process_frame
	main.get_node("DocumentView").close_view()
	_mark("read " + path.get_file())


func _set_latched(locked: bool) -> void:
	if GameState.get_flag(&"door_locked", false) != locked:
		_use("Floor4/Door407/Pivot/DoorLatch407")


func _set_door(opened: bool) -> void:
	if main.get_node("Floor4/Door407").is_open != opened:
		_use("Floor4/Door407")


func _place(position: Vector3, yaw: float) -> void:
	player.global_position = position
	player.rotation.y = yaw
	player.get_node("Head").rotation.x = 0.0
	player.velocity = Vector3.ZERO


func _place_anchor(anchor_name: String) -> void:
	var anchor := main.get_node("Floor4/Anchors/" + anchor_name) as Node3D
	_place(Vector3(anchor.global_position.x, 0.03, 1.2), 0.0)


func _on_subtitle(key: String, _duration: float) -> void:
	subtitles.append(key)
	if GameState.segment == &"seg4" and key in ["SPK_NAME_TRUNG", "SPK_NAME_TRUNG_AGAIN"]:
		var event := InputEventAction.new()
		event.action = &"interact"
		event.pressed = true
		director._input(event)
		_mark("answer Trung")


func _on_restart(checkpoint: StringName) -> void:
	failure = "unexpected restart_requested: %s deviation %d" % [checkpoint, GameState.deviation]


func _on_chase_started(id: StringName) -> void:
	chases_started.append(id)
	_mark("chase " + id)


func _on_chase_ended(id: StringName, caught: bool) -> void:
	if caught:
		failure = "caught in chase " + id
	else:
		chases_escaped.append(id)


func _mark(label: String) -> void:
	print("PLAYTHROUGH: %s %s deviation %d" % [label, GameState.clock_text(), GameState.deviation])
	if not capture_dir.is_empty():
		capture_index += 1
		captures_pending += 1
		_capture.call_deferred("%02d_%s" % [capture_index, label.validate_filename()])


func _capture(label: String) -> void:
	await RenderingServer.frame_post_draw
	var picture := get_viewport().get_texture().get_image()
	if picture == null or picture.is_empty() or picture.save_png(capture_dir.path_join(label + ".png")) != OK:
		failure = "could not capture milestone " + label
	captures_pending -= 1


func _finish() -> void:
	finishing = true
	var deadline := Time.get_ticks_msec() + 3000
	while captures_pending > 0 and Time.get_ticks_msec() < deadline:
		await get_tree().process_frame
	if captures_pending > 0:
		failure = "milestone capture timed out"
	var passed := failure.is_empty()
	print("PLAYTHROUGH_RESULT: %s scenario=%s elapsed=%.2fs %s" % ["PASS" if passed else "FAIL", scenario,
		(Time.get_ticks_msec() - started) / 1000.0, "ending=%s deviation=%d" % [GameState.get_flag(&"ending_variant", 0), GameState.deviation] if passed else failure])
	App.quit(0 if passed else 1)
