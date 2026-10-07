extends TestCase
## Chapter 4 flow (T-194) in the real scene: the split, the library underline,
## back up to 407, the slats, the name in blood, both endings, death reasons.
## Lane pieces (library, 407 door, hospital, UI) are not merged yet: the
## director runs on its fallbacks, and these tests drive the EventBus contract
## the lanes will use (T-195…T-198).

var scene: Node
var director: Chapter4Director
var player: Node3D
var restarts: Array[StringName] = []
var failed: Array[StringName] = []
var events: Array[String] = []


func before_each() -> void:
	scene = load("res://scenes/main/chapter4.tscn").instantiate()
	director = scene.get_node("Chapter4Director")
	director.auto_start = false
	director.time_scale = 0.002
	Chapter1Director.resume_checkpoint = &""
	GameState.reset()
	tree.root.add_child(scene)
	scene.get_node("FloorSpeaker").voice_directory = ""
	player = scene.get_node("Player")
	restarts.clear()
	failed.clear()
	events.clear()
	director.restart_requested.connect(func(id: StringName) -> void: restarts.append(id))
	EventBus.player_failed.connect(_on_failed)
	EventBus.ch4_compare_result.connect(_on_compare)
	EventBus.survivor_form_assembled.connect(_on_form)
	EventBus.blood_name_requested.connect(_on_name_requested)
	EventBus.blood_name_closed.connect(_on_name_closed)
	EventBus.fade_message_requested.connect(_on_message_requested)
	EventBus.fade_message_closed.connect(_on_message_closed)
	EventBus.ch4_ending.connect(_on_ending)
	EventBus.chapter_finished.connect(_on_chapter_finished)
	RuleSystem.load_rule_set(load(Chapter4Director.CH4_RULE_SET))
	await wait_frames(3)


func after_each() -> void:
	EventBus.player_failed.disconnect(_on_failed)
	EventBus.ch4_compare_result.disconnect(_on_compare)
	EventBus.survivor_form_assembled.disconnect(_on_form)
	EventBus.blood_name_requested.disconnect(_on_name_requested)
	EventBus.blood_name_closed.disconnect(_on_name_closed)
	EventBus.fade_message_requested.disconnect(_on_message_requested)
	EventBus.fade_message_closed.disconnect(_on_message_closed)
	EventBus.ch4_ending.disconnect(_on_ending)
	EventBus.chapter_finished.disconnect(_on_chapter_finished)
	scene.queue_free()
	await wait_frames(3)


func _on_failed(reason: StringName) -> void: failed.append(reason)
func _on_compare(rule_key: StringName, matched: bool) -> void: events.append("compare:%s:%s" % [rule_key, matched])
func _on_form() -> void: events.append("form")
func _on_name_requested(seconds: float) -> void: events.append("name_requested:%d" % int(seconds))
func _on_name_closed(result: StringName) -> void: events.append("name:" + String(result))
func _on_message_requested(seconds: float) -> void: events.append("message_requested:%d" % int(seconds))
func _on_message_closed(result: StringName) -> void: events.append("message:" + String(result))
func _on_ending(kind: StringName) -> void: events.append("ending:" + String(kind))
func _on_chapter_finished(chapter: int) -> void: events.append("finished:%d" % chapter)


func _until(condition: Callable, seconds: float = 20.0) -> void:
	var deadline := Time.get_ticks_msec() + int(seconds * 1000.0)
	while not condition.call() and Time.get_ticks_msec() < deadline:
		await wait_frames(1)


func _put(where: Vector3) -> void:
	player.global_position = where
	player.velocity = Vector3.ZERO


func test_the_split_starts_outside_the_canteen_and_ends_in_the_library() -> void:
	director.stop_after = &"split"
	director.run_from(&"split")
	await wait_frames(5)
	assert_true(player.global_position.distance_to(Chapter4Director.FALLBACK_STARTS[&"split"]) < 1.5, "starts by the canteen: %s" % player.global_position)
	assert_eq(int(GameState.get_flag(&"ch4_phone_charges", 0)), 3, "three decoy rings;")
	assert_eq(player.bar_weapon.hits_left, 8, "a fresh bar;")
	assert_true(GameState.get_flag(&"ch3_fire_door_open", false), "the fire door stays open")
	# The library is still lane B's solid shell (T-196 builds the inside): hold
	# the player still so physics does not push them back out.
	player.set_physics_process(false)
	_put(Vector3(65.0, -9.85, 210.0))
	await _until(func() -> bool: return director.finished, 10.0)
	assert_true(director.finished, "inside the library: zone 1 done")


func test_the_library_only_accepts_the_redundant_line() -> void:
	director.stop_after = &"library"
	director.run_from(&"library")
	await wait_frames(5)
	EventBus.ch4_sentence_marked.emit(&"ch3_r5_1")
	EventBus.ch4_sentence_marked.emit(&"ch3_r5_3")
	assert_false(director._compare_done, "a wrong line does nothing")
	EventBus.ch4_sentence_marked.emit(&"ch3_r5_2")
	assert_true(director._compare_done, "the redundant line")
	assert_eq(events, ["compare:ch3_r5_1:false", "compare:ch3_r5_3:false", "compare:ch3_r5_2:true"] as Array[String], "answers;")
	assert_true(GameState.get_flag(&"ch4_compare_done", false), "flag")
	_put(Vector3(60.0, -9.85, 185.0))
	await _until(func() -> bool: return director.finished, 10.0)
	assert_true(director.finished, "leaving the library after the underline")
	assert_eq(failed, [] as Array[StringName], "alive;")


func test_the_way_back_up_to_room_407() -> void:
	director.stop_after = &"return"
	director.run_from(&"return")
	await wait_frames(5)
	assert_true(player.global_position.distance_to(Chapter4Director.FALLBACK_STARTS[&"return"]) < 1.5, "starts in the lobby")
	_put(Vector3(30.0, -6.55, 2.0))
	await _until(func() -> bool: return not director._network_up, 10.0)
	assert_false(director._network_up, "the call drops on the way up")
	_put(Vector3(36.0, 0.05, 2.0))
	await _until(func() -> bool: return director._scared.get(&"hall_lights", false), 10.0)
	assert_true(director._scared.get(&"hall_lights", false), "floor 4: the lights go out one by one")
	_put(Vector3(32.0, 0.05, -2.2))
	await _until(func() -> bool: return director.finished, 10.0)
	assert_true(director.finished, "inside 407")


func test_slats_form_name_and_the_true_ending() -> void:
	director.run_from(&"room407")
	await wait_frames(5)
	EventBus.bed_slat_flipped.emit(1)
	EventBus.bed_slat_flipped.emit(2)
	EventBus.bed_slat_flipped.emit(3)
	assert_false(director._form_ready, "bed 3 is Trung's: no scrap there")
	EventBus.bed_slat_flipped.emit(4)
	assert_true(director._form_ready, "three scraps make the form")
	EventBus.blood_name_typed.emit("Trần Tùng")
	EventBus.blood_name_typed.emit("tran trung")
	assert_true(director._signed, "the name, tone marks or not")
	await _until(func() -> bool: return events.has("message_requested:12"), 10.0)
	EventBus.fade_message_typed.emit("Lật vạt giường ký túc xá")
	await _until(func() -> bool: return events.has("finished:4"), 20.0)
	assert_eq(events, ["form", "name_requested:90", "name:wrong", "name:accepted", "message_requested:12",
		"message:sent", "ending:all", "finished:4"] as Array[String], "the whole ending;")
	assert_eq(String(GameState.get_flag(&"ch4_ending", "")), "all", "both friends saved")
	assert_eq(failed, [] as Array[StringName], "alive;")


func test_no_message_in_time_is_the_lonely_ending() -> void:
	director.run_from(&"end4")
	await _until(func() -> bool: return events.has("finished:4"), 20.0)
	assert_true(events.has("message:timeout"), "the box closes on time")
	assert_true(events.has("ending:alone"), "alone in the hospital")


func test_a_wrong_last_message_is_the_lonely_ending() -> void:
	director.run_from(&"end4")
	await _until(func() -> bool: return events.has("message_requested:12"), 10.0)
	EventBus.fade_message_typed.emit("dưới gầm giường")
	await _until(func() -> bool: return events.has("finished:4"), 20.0)
	assert_true(events.has("ending:alone"), "not the bed slats: alone")


func test_lane_e_audio_rig_follows_the_stages() -> void:
	director.run_from(&"split")
	await wait_frames(6)
	var rig := scene.get_node_or_null("Ch4AudioRig") as Ch4AudioRig
	assert_not_null(rig, "lane E's rig is in the scene")
	if rig == null:
		return
	assert_eq(rig.listener, player, "listens from Trung;")
	assert_eq(director._scare_position(&"neck_hand"), player.global_position, "a scare without a place sounds at Trung;")
	assert_true(not rig.doors.has(&"407"), "no door registered before the 407 stage")


func test_deaths_name_the_place() -> void:
	director.run_from(&"library")
	await wait_frames(5)
	EventBus.player_caught.emit(&"zombie")
	await _until(func() -> bool: return not restarts.is_empty(), 20.0)
	assert_eq(failed, [&"DEATH_CH4_LIBRARY"] as Array[StringName], "the library;")
	assert_eq(restarts, [&"ch4_library"] as Array[StringName], "back to the library checkpoint;")
