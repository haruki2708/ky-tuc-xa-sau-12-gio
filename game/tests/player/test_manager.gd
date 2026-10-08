extends TestCase

const SCENE: PackedScene = preload("res://scenes/entity/manager.tscn")
const SETTINGS: String = "user://settings.cfg"

class AudioSpy extends Node3D:
	var steps: int = 0
	var dragging: bool = false
	var cuts: int = 0
	var lines: Array[String] = []
	func play_step() -> void:
		steps += 1
	func play_drag(on: bool) -> void:
		dragging = on
	func play_slash(_material: StringName) -> void:
		cuts += 1
	func say(key: String) -> float:
		lines.append(key)
		return 0.1

class TimedDoor extends Node3D:
	var is_open: bool = false
	var received_seconds: float = -1.0
	var tween: Tween
	func set_open(value: bool, seconds: float = 0.0) -> void:
		is_open = value
		received_seconds = seconds
		tween = create_tween()
		tween.tween_property(self, "rotation:y", -PI / 2.0 if value else 0.0, seconds)

class LegacyDoor extends Node:
	var is_open: bool = false
	func set_open(value: bool) -> void:
		is_open = value

var world: Node3D
var manager: DormManager
var audio: AudioSpy
var target: Node3D
var arrivals: int = 0
var answers: Array[bool] = []
var cuts: Array[Node3D] = []
var finished: int = 0
var caught: Array[StringName] = []
var _had_settings: bool
var _settings: PackedByteArray
var _paused: bool
var _mouse: Input.MouseMode


func before_each() -> void:
	_paused = tree.paused
	_mouse = Input.mouse_mode
	tree.paused = false
	_had_settings = FileAccess.file_exists(SETTINGS)
	if _had_settings:
		_settings = FileAccess.get_file_as_bytes(SETTINGS)
	assert_eq(ConfigFile.new().save(SETTINGS), OK)
	world = Node3D.new()
	tree.root.add_child(world)
	_wall(Vector3(40, 0.2, 40), Vector3(0, -0.1, 0))
	target = Node3D.new()
	target.position = Vector3(0, 0.02, -1)
	world.add_child(target)
	audio = AudioSpy.new()
	world.add_child(audio)
	manager = SCENE.instantiate()
	manager.audio_rig = audio
	manager.player = target
	manager.position.y = 0.02
	world.add_child(manager)
	manager.arrived.connect(func() -> void: arrivals += 1)
	manager.answered.connect(func(heard: bool) -> void: answers.append(heard))
	manager.slashed.connect(func(node: Node3D) -> void: cuts.append(node))
	manager.slash_finished.connect(func() -> void: finished += 1)
	EventBus.player_caught.connect(_on_caught)
	await _ticks(2)


func after_each() -> void:
	tree.paused = false
	world.queue_free()
	await wait_frames(2)
	EventBus.player_caught.disconnect(_on_caught)
	if _had_settings:
		var file: FileAccess = FileAccess.open(SETTINGS, FileAccess.WRITE)
		file.store_buffer(_settings)
		file.close()
	elif FileAccess.file_exists(SETTINGS):
		assert_eq(DirAccess.remove_absolute(SETTINGS), OK)
	tree.paused = _paused
	Input.mouse_mode = _mouse


func _on_caught(id: StringName) -> void:
	caught.append(id)


func _ticks(count: int) -> void:
	for index: int in count:
		await tree.physics_frame
		await tree.process_frame


func _wall(size: Vector3, position: Vector3) -> StaticBody3D:
	var body: StaticBody3D = StaticBody3D.new()
	var collision: CollisionShape3D = CollisionShape3D.new()
	var shape: BoxShape3D = BoxShape3D.new()
	shape.size = size
	collision.shape = shape
	body.add_child(collision)
	body.position = position
	world.add_child(body)
	return body


func _listen() -> void:
	manager.ask("MGR_CH1_ASK_BED_3")
	manager._physics_process(0.11)
	assert_eq(manager.state, DormManager.State.LISTENING)


func test_answer_uses_four_meter_radius_only_during_listening() -> void:
	manager.set_physics_process(false)
	manager.listen_seconds = 0.2
	manager.hear()
	manager.ask("MGR_CH1_ASK_BED_3")
	EventBus.noise_emitted.emit(manager.position, 12.0, &"step")
	manager._physics_process(0.11)
	EventBus.noise_emitted.emit(manager.position + Vector3(4.01, 1.6, 0), 100.0, &"step")
	manager._physics_process(0.21)
	assert_eq(answers, [false], "speaking and beyond four metres do not count")
	_listen()
	EventBus.noise_emitted.emit(manager.position + Vector3(4.0, 1.6, 0), 0.01, &"breath")
	manager._physics_process(0.21)
	assert_eq(answers, [false, true])
	_listen()
	manager.hear()
	manager._physics_process(0.21)
	assert_eq(answers, [false, true, true], "director reply API counts")
	manager._physics_process(1.0)
	assert_eq(answers.size(), 3, "one result per ask")
	assert_eq(audio.lines.size(), 3)
	assert_true(caught.is_empty(), "hearing never decides to kill")


func test_subtitle_fallback_faces_bed_and_new_command_cancels_answer() -> void:
	manager.audio_rig = null
	manager.look_target = target
	manager.subtitle_seconds = 0.1
	manager.listen_seconds = 0.1
	var lines: Array[String] = []
	var listener: Callable = func(key: String, _seconds: float) -> void: lines.append(key)
	EventBus.subtitle_requested.connect(listener)
	manager.ask("MGR_CH1_ASK_BED_3")
	assert_eq(lines, ["MGR_CH1_ASK_BED_3"])
	assert_true((-manager.visual.global_basis.z).dot(Vector3.FORWARD) > 0.99)
	manager.walk_to(Vector3(0, 0, -0.2))
	await _ticks(35)
	assert_true(answers.is_empty())
	EventBus.subtitle_requested.disconnect(listener)


func test_slashes_target_six_times_then_finishes_once() -> void:
	manager.slash_interval = 0.05
	manager.slash(target)
	assert_eq(cuts.size(), 0, "signals are asynchronous for director await")
	await _ticks(25)
	assert_eq(cuts.size(), 6)
	for node: Node3D in cuts:
		assert_eq(node, target)
	assert_eq(audio.cuts, 6)
	assert_eq(finished, 1)
	await _ticks(5)
	assert_eq(finished, 1)
	assert_true(caught.is_empty())


func test_slash_reentrant_stop_and_freed_target_cancel_pending_hits() -> void:
	manager.slash_interval = 0.05
	var cancel: Callable = func(_target: Node3D) -> void: manager.stop()
	manager.slashed.connect(cancel, CONNECT_ONE_SHOT)
	manager.slash(target)
	await _ticks(20)
	assert_eq(cuts.size(), 1)
	assert_eq(finished, 0)
	manager.slash(target)
	target.free()
	await _ticks(10)
	assert_eq(cuts.size(), 1)
	assert_eq(manager.state, DormManager.State.IDLE)


func test_kill_lunges_then_emits_caught_once_and_stop_cancels() -> void:
	manager.kill_player()
	manager.kill_player()
	await _ticks(5)
	assert_true(manager.position.z < -0.1)
	await _ticks(55)
	assert_eq(caught, [&"manager"])
	manager.kill_player()
	manager.stop()
	await _ticks(60)
	assert_eq(caught.size(), 1)


func test_reduce_scares_skips_close_slash_and_updates_live_without_writing() -> void:
	var config: ConfigFile = ConfigFile.new()
	config.set_value("accessibility", "reduce_scares", true)
	assert_eq(config.save(SETTINGS), OK)
	var saved: PackedByteArray = FileAccess.get_file_as_bytes(SETTINGS)
	EventBus.settings_changed.emit("accessibility", "reduce_scares")
	manager.lunge_seconds = 0.0
	manager.kill_player()
	await _ticks(2)
	assert_eq(manager.blade.rotation.x, 0.0)
	await _ticks(15)
	assert_eq(caught, [&"manager"])
	assert_eq(FileAccess.get_file_as_bytes(SETTINGS), saved)
	config.set_value("accessibility", "reduce_scares", "true")
	config.save(SETTINGS)
	EventBus.settings_changed.emit("accessibility", "reduce_scares")
	assert_false(manager._reduced, "wrong type defaults to false")
	manager.kill_player()
	await _ticks(5)
	assert_true(absf(manager.blade.rotation.x) > 0.1)
	config.set_value("accessibility", "reduce_scares", true)
	config.save(SETTINGS)
	EventBus.settings_changed.emit("accessibility", "reduce_scares")
	assert_eq(manager.blade.rotation.x, 0.0, "live toggle cancels close slash")


func test_walk_speed_arrival_drag_steps_and_wall_collision() -> void:
	manager.walk_to(Vector3(0, 0, -2))
	assert_eq(arrivals, 0)
	await _ticks(60)
	assert_true(absf(manager.position.z + 0.9) < 0.05)
	assert_true(audio.dragging)
	assert_true(audio.steps > 0)
	await _ticks(90)
	assert_eq(arrivals, 1)
	assert_false(audio.dragging)
	_wall(Vector3(10, 3, 0.2), Vector3(0, 1.5, -3))
	manager.walk_to(Vector3(0, 0, -4))
	await _ticks(150)
	assert_true(manager.position.z > -2.61)
	assert_eq(arrivals, 1, "blocked destination cannot claim arrival")
	assert_false(audio.dragging, "blocked actor does not keep dragging")


func test_route_passes_doorway_and_stand_marker_sets_facing() -> void:
	_wall(Vector3(4, 3, 0.2), Vector3(-1, 1.5, -1))
	_wall(Vector3(4, 3, 0.2), Vector3(4, 1.5, -1))
	manager.speed = 3.0
	manager.enter_room(PackedVector3Array([Vector3(1.5, 0, -0.4), Vector3(1.5, 0, -1.6), Vector3(0, 0, -2)]))
	await _ticks(130)
	assert_eq(arrivals, 1)
	assert_true(manager.position.distance_to(Vector3(0, 0, -2)) < 0.1)
	var marker: Marker3D = Marker3D.new()
	marker.position = manager.position
	marker.rotation.y = PI / 2.0
	world.add_child(marker)
	manager.stand_at(marker)
	await _ticks(2)
	assert_eq(arrivals, 2)
	assert_true((-manager.visual.global_basis.z).dot(-marker.global_basis.z) > 0.99)
	var door: Node = load("res://scenes/levels/floor4/door407.gd").new()
	var pivot: Node3D = Node3D.new()
	pivot.name = "Pivot"
	door.add_child(pivot)
	world.add_child(door)
	manager.open_door(door)
	manager.open_door(door)
	assert_true(door.get("is_open"))


func test_navigation_mesh_routes_around_obstacle() -> void:
	_wall(Vector3(2, 3, 0.2), Vector3(0, 1.5, -2))
	var region: NavigationRegion3D = NavigationRegion3D.new()
	var mesh: NavigationMesh = NavigationMesh.new()
	var vertices: PackedVector3Array = PackedVector3Array()
	for z: float in [1.0, -1.0, -3.0, -5.0]:
		for x: float in [-3.0, -1.5, 1.5, 3.0]:
			vertices.append(Vector3(x, 0, z))
	mesh.vertices = vertices
	for row: int in 3:
		for column: int in 3:
			if row == 1 and column == 1:
				continue
			var top: int = row * 4 + column
			mesh.add_polygon(PackedInt32Array([top, top + 1, top + 5, top + 4]))
	region.navigation_mesh = mesh
	world.add_child(region)
	await _ticks(5)
	manager.speed = 3.0
	manager.walk_to(Vector3(0, 0, -4))
	var detoured: bool = false
	for tick: int in 240:
		await _ticks(1)
		detoured = detoured or absf(manager.position.x) > 1.2
		if arrivals > 0:
			break
	assert_true(detoured)
	assert_eq(arrivals, 1)


func test_pause_freezes_motion_and_listening() -> void:
	manager.walk_to(Vector3(0, 0, -4))
	await _ticks(10)
	tree.paused = true
	var position: Vector3 = manager.position
	await tree.create_timer(0.12, true).timeout
	assert_eq(manager.position, position)
	tree.paused = false
	manager.listen_seconds = 0.1
	manager.ask("MGR_CH1_ASK_BED_3")
	await _ticks(7)
	tree.paused = true
	var remaining: float = manager._remaining
	manager.hear()
	EventBus.noise_emitted.emit(manager.position, 12.0, &"step")
	await tree.create_timer(0.2, true).timeout
	assert_eq(manager._remaining, remaining)
	assert_true(answers.is_empty())
	tree.paused = false
	await _ticks(10)
	assert_eq(answers, [false])


func test_model_animation_blade_tip_and_existing_audio_rig_contract() -> void:
	var model: Node3D = Node3D.new()
	model.name = "Model"
	var tip: Marker3D = Marker3D.new()
	tip.name = "BladeTip"
	model.add_child(tip)
	tip.owner = model
	tip.position = Vector3(0.4, 0.02, 0)
	var animator: AnimationPlayer = AnimationPlayer.new()
	animator.name = "AnimationPlayer"
	model.add_child(animator)
	animator.owner = model
	var library: AnimationLibrary = AnimationLibrary.new()
	for name: StringName in [&"walk", &"stand", &"ask", &"slash", &"lunge", &"kill"]:
		var animation: Animation = Animation.new()
		animation.length = 0.5
		library.add_animation(name, animation)
	animator.add_animation_library(&"", library)
	var packed: PackedScene = PackedScene.new()
	assert_eq(packed.pack(model), OK)
	model.free()
	var real_audio: ManagerAudio = load("res://audio/entities/manager_audio.tscn").instantiate()
	real_audio.voice_directory = ""
	world.add_child(real_audio)
	var custom: DormManager = SCENE.instantiate()
	custom.body_scene = packed
	custom.audio_rig = real_audio
	custom.player = target
	world.add_child(custom)
	assert_false(custom.get_node("Visual/Fallback").visible)
	assert_not_null(custom._blade_tip)
	custom.walk_to(Vector3(0, 0, -2))
	await _ticks(12)
	assert_eq(custom._model_animation.current_animation, &"walk")
	assert_true(real_audio._players["Drag"].playing)
	custom._sync_audio()
	assert_eq(real_audio.get_node("Drag").global_position, custom._blade_tip.global_position)
	tree.paused = true
	await tree.create_timer(0.05, true).timeout
	assert_true(real_audio._players["Drag"].stream_paused)
	tree.paused = false
	custom.ask("MGR_CH1_ASK_BED_3")
	assert_eq(custom._model_animation.current_animation, &"ask")
	assert_false(real_audio._players["Drag"].playing)
	custom.slash(target)
	assert_eq(custom._model_animation.current_animation, &"slash")
	custom.stop()
	for channel: AudioStreamPlayer3D in real_audio._players.values():
		assert_false(channel.playing)


func test_sample_scene_runs_quiet_and_heard_branches_and_leaves_room() -> void:
	var fixture: Node3D = load("res://scenes/entity/manager_test.tscn").instantiate()
	world.add_child(fixture)
	var actor: DormManager = fixture.get_node("Manager")
	var spy: AudioSpy = AudioSpy.new()
	fixture.add_child(spy)
	actor.audio_rig = spy
	actor.speed = 12.0
	actor.listen_seconds = 0.05
	actor.slash_interval = 0.05
	for number: int in range(1, 5):
		assert_eq(fixture.get_node("Bunk%d" % number).bed_id(), number)
	for number: int in [1, 2, 4]:
		assert_not_null(fixture.get_node("Corpse%d/UnseenPoser" % number))
	for heard: bool in [false, true]:
		fixture.start_demo()
		for tick: int in 240:
			await _ticks(1)
			if heard and actor.state == DormManager.State.LISTENING:
				actor.hear()
			if fixture.stage == 0:
				break
		assert_eq(fixture.stage, 0, "sample returns to idle after leaving room")
		assert_false(fixture.door.get("is_open"))
		assert_eq(fixture._cuts, 0 if heard else 6)
	assert_eq(caught, [&"manager"])


func _hunt_region() -> void:
	var region: NavigationRegion3D = NavigationRegion3D.new()
	var mesh: NavigationMesh = NavigationMesh.new()
	var vertices: PackedVector3Array = PackedVector3Array()
	for z: float in [1.0, -1.0, -3.0, -6.0]:
		for x: float in [-3.0, -1.5, 1.5, 3.0]:
			vertices.append(Vector3(x, 0, z))
	mesh.vertices = vertices
	for row: int in 3:
		for column: int in 3:
			if row == 1 and column == 1:
				continue
			var top: int = row * 4 + column
			mesh.add_polygon(PackedInt32Array([top, top + 1, top + 5, top + 4]))
	region.navigation_mesh = mesh
	world.add_child(region)
	await _ticks(5)


func test_hunt_routes_around_wall_tracks_target_and_kills_after_arrival() -> void:
	_wall(Vector3(2, 3, 0.2), Vector3(0, 1.5, -2))
	await _hunt_region()
	target.position = Vector3(0, 0.02, -4)
	manager.speed = 2.0
	manager.hunt(target)
	assert_eq(arrivals, 0)
	var detoured: bool = false
	for tick: int in 400:
		if tick == 50:
			target.position.z = -5.0
		await _ticks(1)
		detoured = detoured or absf(manager.position.x) > 1.2
		if arrivals > 0:
			break
	assert_true(detoured, "hunt follows navigation around the wall")
	assert_eq(arrivals, 1)
	assert_true(manager._flat_offset(target.position).length() <= 1.2)
	assert_true(caught.is_empty(), "kill sequence starts only after arrival")
	await _ticks(90)
	assert_eq(caught, [&"manager"])
	assert_eq(arrivals, 1)


func test_hunt_timeout_stop_freed_target_and_reentrant_arrival() -> void:
	await _hunt_region()
	target.position.z = -30.0
	manager.speed = 0.0
	manager.set_physics_process(false)
	manager.hunt(target)
	manager._physics_process(11.9)
	assert_eq(manager.state, DormManager.State.HUNTING)
	manager._physics_process(0.11)
	assert_eq(manager.state, DormManager.State.LUNGING)
	assert_eq(arrivals, 0, "timeout does not claim arrival")
	manager.stop()
	manager._physics_process(20.0)
	assert_true(caught.is_empty())
	target.position = manager.position + Vector3(0, 0, -0.8)
	manager.arrived.connect(func() -> void: manager.stop(), CONNECT_ONE_SHOT)
	manager.hunt(target)
	manager._physics_process(0.01)
	assert_eq(arrivals, 1)
	assert_eq(manager.state, DormManager.State.IDLE, "arrival callback may cancel kill")
	manager.hunt(target)
	target.free()
	manager._physics_process(0.01)
	assert_eq(manager.state, DormManager.State.IDLE)
	assert_true(caught.is_empty())


func test_open_door_duration_pose_completion_pause_and_legacy_api() -> void:
	var door: TimedDoor = TimedDoor.new()
	world.add_child(door)
	var openings: Array[float] = []
	manager.door_opened.connect(func() -> void: openings.append(door.rotation.y))
	manager.open_door(door, 1.5)
	assert_eq(door.received_seconds, 1.5)
	assert_true(openings.is_empty(), "safe to await immediately after open_door")
	await _ticks(30)
	assert_true(door.rotation.y < -0.2 and door.rotation.y > -1.2, "door opens gradually")
	assert_true(manager._reach_arm.rotation.x > 0.8, "free hand reaches forward")
	assert_eq(manager.velocity, Vector3.ZERO)
	tree.paused = true
	var angle: float = door.rotation.y
	await tree.create_timer(0.2, true).timeout
	assert_eq(door.rotation.y, angle)
	assert_true(openings.is_empty())
	tree.paused = false
	await _ticks(55)
	assert_true(openings.is_empty(), "no signal before the 1.5-second duration")
	await _ticks(15)
	assert_eq(openings.size(), 1)
	assert_true(absf(openings[0] + PI / 2.0) < 0.01, "door is fully open at completion")
	assert_eq(manager.state, DormManager.State.IDLE)
	assert_eq(manager._reach_arm.rotation, manager._arm_rest)
	var legacy: LegacyDoor = LegacyDoor.new()
	world.add_child(legacy)
	manager.open_door(legacy, 1.5)
	assert_true(legacy.is_open)
	await _ticks(3)
	assert_eq(openings.size(), 2, "one-argument door completes asynchronously")


func test_open_door_cancel_free_and_real_model_arm() -> void:
	var model_actor: DormManager = SCENE.instantiate()
	model_actor.body_scene = load("res://scenes/levels/ch1_models/manager_body.tscn")
	model_actor.audio_rig = audio
	world.add_child(model_actor)
	var door: TimedDoor = TimedDoor.new()
	world.add_child(door)
	var openings: Array[bool] = []
	model_actor.door_opened.connect(func() -> void: openings.append(true))
	model_actor.open_door(door, 1.5)
	await _ticks(25)
	assert_eq(model_actor._reach_arm.name, &"LeftArm")
	assert_true(model_actor._reach_arm.rotation.x > 0.8)
	model_actor.stop()
	await _ticks(80)
	assert_true(openings.is_empty(), "stop cancels stale door completion")
	model_actor.open_door(door, 1.5)
	door.queue_free()
	await _ticks(3)
	assert_eq(model_actor.state, DormManager.State.IDLE)
	assert_true(openings.is_empty())


func test_hunt_pause_freezes_deadline_and_position() -> void:
	await _hunt_region()
	target.position.z = -5.0
	manager.hunt(target)
	await _ticks(15)
	tree.paused = true
	var remaining: float = manager._remaining
	var at: Vector3 = manager.position
	await tree.create_timer(0.2, true).timeout
	assert_eq(manager._remaining, remaining)
	assert_eq(manager.position, at)
	tree.paused = false
	manager.stop()


func test_hunt_does_not_arrive_through_a_nearby_wall() -> void:
	await _hunt_region()
	_wall(Vector3(4, 3, 0.1), Vector3(0, 1.5, -0.4))
	target.position = Vector3(0, 0.02, -0.9)
	await _ticks(2)
	manager.hunt(target)
	await _ticks(20)
	assert_eq(arrivals, 0, "near target behind a wall has not been reached")
	assert_eq(manager.state, DormManager.State.HUNTING)
	manager.stop()
