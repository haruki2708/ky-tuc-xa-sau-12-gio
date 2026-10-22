extends TestCase
## T-201 (D-069): chapter 1's manager scene on the real scene chapter1.tscn:
## survival on beds 1, 2 and 4 with no light, the manager coming from the
## corridor, hunting anyone outside a bed, and Khoa's rhythm on the wall.

const BALCONY_SPOT := Vector3(32.8, 0.05, -7.4)

var scene: Node
var director: Chapter1Director
var player: Node3D
var restarts: Array[StringName] = []
var reasons: Array[StringName] = []


func before_each() -> void:
	scene = load("res://scenes/main/chapter1.tscn").instantiate()
	director = scene.get_node("Chapter1Director")
	director.auto_start = false
	director.time_scale = 0.002
	Chapter1Director.resume_checkpoint = &""
	tree.root.add_child(scene)
	scene.get_node("FloorSpeaker").voice_directory = ""
	player = scene.get_node("Player")
	director.restart_requested.connect(func(id: StringName) -> void: restarts.append(id))
	EventBus.player_failed.connect(_on_failed)
	await wait_frames(2)


func after_each() -> void:
	EventBus.player_failed.disconnect(_on_failed)
	if EventBus.segment_changed.is_connected(_lamp_off):
		EventBus.segment_changed.disconnect(_lamp_off)
	if EventBus.chat_choice_requested.is_connected(_answer_choices):
		EventBus.chat_choice_requested.disconnect(_answer_choices)
	for node in scene.find_children("*", "AudioStreamPlayer3D", true, false):
		if node.has_method("stop_emitting"):
			node.stop_emitting()
		(node as AudioStreamPlayer3D).stop()
	scene.queue_free()
	await tree.create_timer(0.3).timeout
	restarts.clear()
	reasons.clear()
	GameState.reset()
	RuleSystem.reset()
	Checkpoint.clear()
	Chapter1Director.manager_deaths = 0


func _on_failed(reason: StringName) -> void:
	reasons.append(reason)


func _until(condition: Callable, seconds: float = 20.0) -> void:
	var deadline := Time.get_ticks_msec() + int(seconds * 1000.0)
	while not condition.call() and Time.get_ticks_msec() < deadline:
		await tree.process_frame


func _lamp_off(segment: StringName) -> void:
	if segment in [&"r2", &"r2_manager"]:
		(func() -> void:
			var room := scene.get_node_or_null("Floor4/Room407")
			if room != null and room.has_method("set_desk_lamp"):
				room.set_desk_lamp(false)
			GameState.set_flag(&"desk_lamp_on", false)).call_deferred()


func _answer_choices(choice_id: StringName, _keys: PackedStringArray) -> void:
	(func() -> void: EventBus.chat_choice_made.emit(choice_id, 0)).call_deferred()


## Starts the manager stage, with the lights off and Minh Nhật's advice answered
## correctly, and puts Trung on `bed` (0: stays out of every bed).
func _manager_scene(bed: int) -> void:
	EventBus.segment_changed.connect(_lamp_off)
	EventBus.chat_choice_requested.connect(_answer_choices)
	director.stop_after = &"r2_manager"
	assert_eq(RuleSystem.load_rule_set(load(Chapter1Director.RULE_SET_PATH)).size(), 0, "chapter 1 rules valid;")
	director.run_from(&"r2_manager")
	await _until(func() -> bool: return GameState.segment == &"r2_manager")
	if bed > 0:
		director.lie_on(bed)


func _manager() -> Node3D:
	return scene.get_node_or_null("Chapter1Director/Manager") as Node3D


func _door() -> Node:
	return scene.get_node("Floor4/Door407")


## The manager's scene is over: he left (freed) after cutting bed 3.
func _manager_done() -> bool:
	return director._slash_cuts > 0 and _manager() == null


## Beds 1, 2 and 4: no light, head turning all the time and noises that the old
## manager would have heard. Alive, and bed 3 is cut.
func _survive_on(bed: int) -> void:
	await _manager_scene(bed)
	var turned := 0
	var deadline := Time.get_ticks_msec() + 120000
	while not _manager_done() and restarts.is_empty() and Time.get_ticks_msec() < deadline:
		player.rotate_y(0.07)
		turned += 1
		var manager := _manager()
		if manager != null and turned % 5 == 0:
			EventBus.noise_emitted.emit(manager.global_position + Vector3(0.0, 1.6, 0.6), 3.0, &"move")
			EventBus.noise_emitted.emit(manager.global_position + Vector3(0.0, 1.6, 0.6), 3.0, &"breath")
		await tree.process_frame
	assert_true(restarts.is_empty(), "bed %d: alive (%s);" % [bed, reasons])
	assert_true(_manager_done(), "bed %d: the manager cut bed 3 and left;" % bed)
	assert_true(turned > 100, "the head kept turning (%d frames);" % turned)


func test_bed_1_survives_with_lights_off_and_turning() -> void:
	await _survive_on(1)


func test_bed_2_survives_with_lights_off_and_turning() -> void:
	await _survive_on(2)


func test_bed_4_survives_with_lights_off_and_turning() -> void:
	await _survive_on(4)


## D-134: lying on bed 2, Trung sees him look bunk A over (beds 1 and 2) and then bunk B (bed 4),
## bending right down over bed 2, before he asks about bed 3 and cuts it.
func test_he_checks_beds_1_2_4_then_cuts_3() -> void:
	await _manager_scene(2)
	await _until(func() -> bool: return _manager() != null, 30.0)
	var manager := _manager()
	assert_not_null(manager, "he comes;")
	if manager == null:
		return
	var leans: Array = []
	manager.leaned.connect(func(degrees: float) -> void:
		if degrees > 0.0:
			leans.append([degrees, manager.global_position.x]))
	await _until(func() -> bool: return _manager_done() or not restarts.is_empty(), 120.0)
	assert_true(restarts.is_empty(), "alive on bed 2 (%s);" % [reasons])
	assert_eq(leans.size(), 3, "three beds looked over before bed 3: %s;" % [leans])
	if leans.size() == 3:
		assert_true(leans[0][1] < 33.0 and leans[1][1] < 33.0, "beds 1 and 2 from bunk A;")
		assert_true(leans[2][1] > 34.0, "bed 4 from bunk B;")
		assert_eq(leans[0][0], Chapter1Director.BED_LEAN[1][0], "a look at bed 1;")
		assert_eq(leans[1][0], Chapter1Director.BED_LEAN[2][1], "right down over Trung on bed 2;")
		assert_eq(leans[2][0], Chapter1Director.BED_LEAN[4][0], "a look at bed 4;")
	assert_true(director._slash_cuts > 0, "bed 3 cut;")


func test_own_bed_3_is_still_death() -> void:
	await _manager_scene(3)
	await _until(func() -> bool: return not restarts.is_empty(), 90.0)
	assert_eq(reasons, [&"DEATH_OWN_BED"] as Array[StringName], "bed 3 is Trung's own;")


func test_desk_lamp_seen_from_the_threshold() -> void:
	await _manager_scene(2)
	var lamp := scene.get_node("Floor4/Room407/Room407DeskLamp") as Light3D
	var on := func() -> void:
		lamp.visible = true
		lamp.light_energy = 0.5
		GameState.set_flag(&"desk_lamp_on", true)
	# The lamp is lit after the stage's own "lamp off" and stays lit.
	on.call()
	await wait_frames(3)
	on.call()
	await _until(func() -> bool: return not restarts.is_empty(), 90.0)
	assert_eq(reasons, [&"DEATH_SEEN"] as Array[StringName], "the light gives the room away;")


func test_raised_phone_seen_from_the_threshold() -> void:
	await _manager_scene(4)
	var phone := player.find_child("PhoneItem", true, false)
	assert_not_null(phone, "the player carries the phone;")
	if phone == null:
		return
	phone.set("raised", true)
	await _until(func() -> bool: return not restarts.is_empty(), 90.0)
	assert_eq(reasons, [&"DEATH_SEEN"] as Array[StringName], "a raised phone is a light;")


func test_getting_up_while_he_is_in_the_room_kills() -> void:
	await _manager_scene(2)
	await _until(func() -> bool: return _manager() != null and _manager().global_position.z < -0.8 and restarts.is_empty(), 90.0)
	assert_not_null(_manager(), "he is in the room;")
	director.get_up()
	await _until(func() -> bool: return not restarts.is_empty(), 30.0)
	assert_eq(reasons, [&"DEATH_NOT_IN_BED"] as Array[StringName], "getting up gives Trung away;")


## Where the manager stood when the kill began (the lunge starts at that moment).
func _distance_at_kill() -> float:
	var result := [INF]
	var on_started := func(_kind: StringName) -> void:
		var manager := _manager()
		if manager != null:
			result[0] = manager.global_position.distance_to(player.global_position)
	EventBus.player_death_started.connect(on_started, CONNECT_ONE_SHOT)
	await _until(func() -> bool: return not restarts.is_empty(), 120.0)
	if EventBus.player_death_started.is_connected(on_started):
		EventBus.player_death_started.disconnect(on_started)
	return result[0]


## With lane A's `hunt` (T-202) he must end within 1.5 m of Trung. Without it
## the core stand-in follows the room's navigation mesh and then walks straight, so
## until lane B's mesh reaches the balcony and the bathroom (T-203) it only has to
## come well into the room, nearer than the 6.5 m of the doorway.
func _assert_walked_up(distance: float, place: String) -> void:
	var probe := (load(Chapter1Director.MANAGER_SCENE) as PackedScene).instantiate()
	var strict := probe.has_method("hunt")
	probe.free()
	print("T201 HUNT: ", place, " distance at the kill = %.2f m, lane A hunt() present = %s" % [distance, strict])
	if strict:
		assert_true(distance < 1.5, "he walked up to %s (%.2f m away when the kill began);" % [place, distance])
	else:
		assert_true(distance < 6.0, "he came into the room toward %s (%.2f m away);" % [place, distance])


func test_hiding_on_the_balcony_is_hunted() -> void:
	await _manager_scene(0)
	player.global_position = BALCONY_SPOT
	var distance := await _distance_at_kill()
	assert_eq(reasons, [&"DEATH_NOT_IN_BED"] as Array[StringName], "no bed, no safety;")
	_assert_walked_up(distance, "the balcony")


func test_hiding_in_the_bathroom_is_hunted() -> void:
	await _manager_scene(0)
	var entry := scene.get_node("Floor4/Room407/Anchors/BathroomEntry") as Node3D
	player.global_position = entry.global_position + Vector3(0.6, 0.02, -0.6)
	var distance := await _distance_at_kill()
	assert_eq(reasons, [&"DEATH_NOT_IN_BED"] as Array[StringName], "no bed, no safety;")
	_assert_walked_up(distance, "the bathroom")


func test_lying_down_while_hunted_does_not_save_him() -> void:
	await _manager_scene(0)
	# Once he has looked in from the threshold and set off after Trung.
	await _until(func() -> bool: return _manager() != null and director._pending_death == &"DEATH_NOT_IN_BED", 90.0)
	await wait_frames(5)
	director.lie_on(2)
	await _until(func() -> bool: return not restarts.is_empty(), 90.0)
	assert_eq(reasons, [&"DEATH_NOT_IN_BED"] as Array[StringName], "he had already seen Trung out of bed;")


func test_he_comes_down_the_corridor_and_opens_the_door_slowly() -> void:
	await _manager_scene(2)
	var door := _door()
	await _until(func() -> bool: return _manager() != null, 30.0)
	var manager := _manager()
	assert_not_null(manager, "he exists;")
	if manager == null:
		return
	assert_false(bool(door.get("is_open")), "the door is still shut when he appears;")
	assert_true(manager.global_position.x < 27.0 and manager.global_position.z > 1.0, "in the corridor, toward 406 (%s);" % manager.global_position)
	assert_true(manager.global_position.distance_to(Vector3(32.0, 0.05, 0.0)) > 5.5, "6 to 8 m from the door;")
	# He walks to the door, then the door opens: sample the leaf while it swings.
	var pivot := door.get_node("Pivot") as Node3D
	var angles: Array[float] = []
	var at_open := [Vector3.ZERO]
	var deadline := Time.get_ticks_msec() + 60000
	while not bool(door.get("is_open")) and restarts.is_empty() and Time.get_ticks_msec() < deadline:
		await tree.process_frame
	at_open[0] = _manager().global_position if _manager() != null else Vector3.INF
	# Lane B's door reports is_open as soon as the swing starts (T-203): sample the
	# leaf through the swing itself.
	var swing_end := Time.get_ticks_msec() + 2500
	while Time.get_ticks_msec() < swing_end and restarts.is_empty():
		await tree.process_frame
		if absf(pivot.rotation.y) > 0.02:
			angles.append(pivot.rotation.y)
	assert_true(bool(door.get("is_open")), "the door opens;")
	assert_true(Vector2(at_open[0].x - 32.0, at_open[0].z - 0.6).length() < 1.5, "he stands at the door when it opens (%s);" % at_open[0])
	var slow := manager.has_method("open_door") and director._arg_count(manager, &"open_door") >= 2 \
			or director._arg_count(door, &"set_open") >= 2
	if slow:
		var mid := angles.filter(func(a: float) -> bool: return a < -0.1 and a > -1.45)
		assert_true(mid.size() >= 5, "the leaf swings through the middle (%d samples);" % mid.size())
	print("T201 DOOR: slow API present=", slow, " leaf samples=", angles.size())


# --- N3: Khoa's rhythm -------------------------------------------------------------

## Taps wall_406 as a player would: `groups` sizes, 0.2 s inside a group, 1.2 s between.
func _knock(groups: Array[int]) -> void:
	for group in groups.size():
		for tap in groups[group]:
			EventBus.wall_tapped.emit(&"wall_406")
			await tree.create_timer(0.2).timeout
		await tree.create_timer(1.0).timeout


func _listen_and_knock(groups: Array[int]) -> Array[int]:
	director.time_scale = 1.0
	var heard: Array = [[] as Array[int]]
	var run := func() -> void: heard[0] = await director._listen_for_rhythm()
	run.call()
	await wait_frames(3)
	await _knock(groups)
	await _until(func() -> bool: return not director._tap_listening, 8.0)
	await wait_frames(2)
	return heard[0]


func test_rhythm_listener_hears_the_groups() -> void:
	var rhythm := await _listen_and_knock([3, 1] as Array[int])
	assert_eq(rhythm, [3, 1] as Array[int], "3, pause, 1;")


## D-070: a wrong turn does not end the wait; the right rhythm after it still counts.
func test_a_wrong_turn_can_be_knocked_again() -> void:
	director.time_scale = 1.0
	var heard: Array = [[] as Array[int]]
	var run := func() -> void: heard[0] = await director._listen_for_rhythm()
	run.call()
	await wait_frames(3)
	await _knock([2] as Array[int])
	await tree.create_timer(Chapter1Director.TAP_TURN_END + 0.6).timeout
	assert_true(director._tap_listening, "still listening after a wrong turn;")
	await _knock([3, 1] as Array[int])
	await _until(func() -> bool: return not director._tap_listening, 8.0)
	await wait_frames(2)
	assert_eq(heard[0], [3, 1] as Array[int], "the second, right turn counts;")


func test_wrong_rhythms_get_no_answer_and_no_note() -> void:
	var wall := scene.get_node("Floor4/Room407/Anchors/WallKnock406") as Node3D
	for wrong: Array[int] in [[2, 1] as Array[int], [3, 2] as Array[int], [4] as Array[int], [] as Array[int]]:
		await director._answer_rhythm(wrong, wall.global_position, wall)
		assert_true(scene.get_node_or_null("Ch1KhoaNote") == null, "no note for %s;" % [wrong])
		assert_true(GameState.get_flag(&"khoa_hint", false) != true, "Khoa stays silent for %s;" % [wrong])


func test_the_right_rhythm_brings_the_note() -> void:
	director.time_scale = 0.002
	var wall := scene.get_node("Floor4/Room407/Anchors/WallKnock406") as Node3D
	await director._answer_rhythm([3, 1] as Array[int], wall.global_position, wall)
	var paper := scene.get_node_or_null("Ch1KhoaNote") as Node3D
	assert_not_null(paper, "the note is on the floor;")
	if paper == null:
		return
	assert_eq(paper.get("document_id"), &"ch1_khoa_note", "Khoa's note;")
	assert_eq(GameState.get_flag(&"khoa_hint", false), true, "the hint flag (bot profile);")
	var slot := scene.get_node_or_null("Floor4/Room407/Anchors/KhoaNoteSlot") as Node3D
	var expect := slot.global_position if slot != null else wall.global_position + Vector3(0.45, -1.25, 0.0)
	assert_true(paper.global_position.distance_to(expect) < 0.2, "at the socket (%s vs %s);" % [paper.global_position, expect])
	var opened: Array[StringName] = []
	var on_open := func(id: StringName) -> void: opened.append(id)
	EventBus.document_opened.connect(on_open)
	paper.call("interact", player)
	EventBus.document_opened.disconnect(on_open)
	assert_eq(opened, [&"ch1_khoa_note"] as Array[StringName], "reading it opens the note;")


func test_wall_mission_end_to_end() -> void:
	# The whole mission at real speed: Khoa knocks twice, Trung answers, the note appears.
	director.time_scale = 1.0
	var done := [false]
	var run := func() -> void:
		await director._wall_taps()
		done[0] = true
	run.call()
	await _until(func() -> bool: return director._tap_listening, 40.0)
	assert_true(director._tap_listening, "Khoa finished his two rounds and listens;")
	assert_eq(GameState.get_flag(&"wall_prompt", false), true, "the prompt flag (bot profile);")
	await _knock([3, 1] as Array[int])
	await _until(func() -> bool: return done[0], 30.0)
	assert_true(done[0], "mission finished;")
	assert_not_null(scene.get_node_or_null("Ch1KhoaNote"), "the note came through the wall;")
	assert_eq(GameState.get_flag(&"khoa_hint", false), true, "khoa_hint;")


# --- Lane A and B APIs (T-202, T-203), checked with stand-ins ---------------------

class FakeDoor extends Node3D:
	var is_open: bool = false
	var calls: Array = []

	func set_open(value: bool, seconds: float = 0.0) -> void:
		calls.append([value, seconds])
		is_open = value


class FakeDoorOld extends Node3D:
	var is_open: bool = false
	var calls: Array = []

	func set_open(value: bool) -> void:
		calls.append([value])
		is_open = value


class FakeManager extends Node3D:
	signal door_opened
	signal arrived
	var asked_seconds: float = -1.0
	var hunted: Node3D
	var killed: bool = false

	func open_door(door: Node, seconds: float = 0.0) -> void:
		asked_seconds = seconds
		door.call("set_open", true, seconds)
		get_tree().create_timer(0.2).timeout.connect(func() -> void: door_opened.emit())

	func hunt(target: Node3D) -> void:
		hunted = target
		get_tree().create_timer(0.1).timeout.connect(func() -> void: arrived.emit())

	func kill_player() -> void:
		killed = true


class FakeManagerOld extends Node3D:
	func open_door(door: Node) -> void:
		door.call("set_open", true)


func _fake_floor(door: Node3D) -> void:
	var floor_root := Node3D.new()
	door.name = "Door407"
	floor_root.add_child(door)
	scene.add_child(floor_root)
	director._floor = floor_root


func test_slow_door_through_the_manager_api() -> void:
	var door := FakeDoor.new()
	var manager := FakeManager.new()
	scene.add_child(manager)
	_fake_floor(door)
	await director._open_door_slowly(manager)
	assert_eq(manager.asked_seconds, Chapter1Director.DOOR_OPEN_SECONDS, "manager.open_door(door, 1.5);")
	assert_true(door.is_open, "door_opened came and the door is open;")


func test_slow_door_through_the_door_api_alone() -> void:
	var door := FakeDoor.new()
	var manager := FakeManagerOld.new()
	scene.add_child(manager)
	_fake_floor(door)
	await director._open_door_slowly(manager)
	assert_eq(door.calls, [[true, Chapter1Director.DOOR_OPEN_SECONDS]], "door.set_open(true, 1.5);")


func test_instant_door_when_neither_api_exists() -> void:
	var door := FakeDoorOld.new()
	var manager := FakeManagerOld.new()
	scene.add_child(manager)
	_fake_floor(door)
	await director._open_door_slowly(manager)
	assert_eq(door.calls, [[true]], "old set_open(true);")
	director._close_door_slowly()
	assert_eq(door.calls, [[true], [false]], "closing falls back too;")


func test_hunt_goes_through_the_manager_api() -> void:
	var manager := FakeManager.new()
	scene.add_child(manager)
	manager.add_child(Node3D.new())
	await director._manager_hunts(manager)
	assert_eq(manager.hunted, player, "manager.hunt(player);")
	assert_true(manager.killed, "then the kill;")
	assert_eq(director._pending_death, &"DEATH_NOT_IN_BED", "the reason;")
