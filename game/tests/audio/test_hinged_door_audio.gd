extends TestCase
## T-244: real chapter signals, material selection, moving anchors and silent resets.

var chapter: Node3D
var room: Node3D
var old_mouse: Input.MouseMode
var old_mute: bool
var old_resume: StringName


func before_each() -> void:
	old_mouse = Input.mouse_mode
	old_mute = AudioServer.is_bus_mute(0)
	old_resume = Chapter1Director.resume_checkpoint
	AudioServer.set_bus_mute(0, true)
	Chapter1Director.resume_checkpoint = &""
	chapter = (load("res://scenes/main/chapter1.tscn") as PackedScene).instantiate() as Node3D
	(chapter.get_node("Chapter1Director") as Chapter1Director).auto_start = false
	tree.root.add_child(chapter)
	await wait_frames(3)
	chapter.get_node("Player").set_physics_process(false)
	room = chapter.get_node("Floor4/Room407") as Node3D
	HingedDoorAudio.attach_all(room)


func after_each() -> void:
	tree.paused = false
	chapter.queue_free()
	await wait_frames(2)
	GameState.reset()
	RuleSystem.reset()
	Chapter1Director.resume_checkpoint = old_resume
	Input.mouse_mode = old_mouse
	AudioServer.set_bus_mute(0, old_mute)


func test_material_timing_and_moving_handle_in_chapter1() -> void:
	HingedDoorAudio.attach_all(room)
	for index: int in 2:
		var door := HingedDoor.of(room.get_node(HingedDoorAudio.DOORS[index]))
		var sources: Array[Node] = door.find_children("*", "AudioStreamPlayer3D", true, false)
		assert_eq(sources.size(), 1, "reattaching must not double the sound")
		var source := door.get_node("HingedDoorAudio") as HingedDoorAudio
		assert_false(source.playing, "attachment is silent even on the open balcony")
		assert_eq(source.bus, &"SFX")
		assert_eq(source.volume_db, -6.0)
		assert_eq(source.max_polyphony, 1)
		door.swing(false, 0.0)
		var start: Vector3 = source.global_position
		door.swing(true, 0.9)
		assert_true(source.playing, "opening plays as soon as the leaf starts")
		assert_eq(source.stream, HingedDoorAudio.WOOD_OPEN if index == 0 else HingedDoorAudio.GLASS_OPEN)
		assert_false((source.stream as AudioStreamOggVorbis).loop)
		for frame: int in 12:
			await tree.physics_frame
		assert_true(source.global_position.distance_to(start) > 0.02, "source follows the turning leaf")
		assert_true(source.global_position.distance_to(door.grips[0].global_position) < 0.001, "at the moving handle")
		await door.settled
		assert_false(source.playing, "no opening sound after the leaf settles")
		door.swing(false, 0.9)
		assert_false(source.playing, "no premature frame contact while closing")
		await door.settled
		assert_true(source.playing, "close/latch starts only on contact")
		assert_eq(source.stream, HingedDoorAudio.WOOD_CLOSE if index == 0 else HingedDoorAudio.GLASS_CLOSE)
		assert_false((source.stream as AudioStreamOggVorbis).loop)
		source.stop()


func test_instant_changes_cancel_audio_and_pending_latches() -> void:
	for path: String in HingedDoorAudio.DOORS:
		var door := HingedDoor.of(room.get_node(path))
		var source := door.get_node("HingedDoorAudio") as HingedDoorAudio
		for open: bool in [false, true, false]:
			door.swing(open, 0.0)
			assert_false(source.playing, "instant chapter placement stays silent")
		door.swing(true, 0.5)
		assert_true(source.playing, "manager/hand animated open is audible")
		door.swing(false, 0.0)
		assert_false(source.playing, "reset cancels an opening clip")
		door.swing(true, 0.0)
		door.swing(false, 0.5)
		await tree.physics_frame
		# This is the external set_open route used by chapter and manager.
		door.hinged.call("set_open", true)
		await tree.physics_frame
		await tree.physics_frame
		assert_false(source.playing, "external instant reset is silent")
		await tree.create_timer(1.0).timeout
		assert_false(source.playing, "cancelled close never emits a delayed latch")


func test_reversing_a_close_never_plays_the_old_latch() -> void:
	for path: String in HingedDoorAudio.DOORS:
		var door := HingedDoor.of(room.get_node(path))
		var source := door.get_node("HingedDoorAudio") as HingedDoorAudio
		door.swing(true, 0.0)
		door.swing(false, 0.9)
		await tree.physics_frame
		door.swing(true, 0.5)
		await door.settled
		await tree.create_timer(0.5).timeout
		assert_false(source.playing, "reversal cannot leave a stale close sound")
		assert_eq(source.stream, HingedDoorAudio.WOOD_OPEN if path == HingedDoorAudio.DOORS[0] else HingedDoorAudio.GLASS_OPEN)


func test_unfitted_room_has_no_sources_or_new_door_behavior() -> void:
	var plain := (load("res://scenes/levels/floor4/room_407.tscn") as PackedScene).instantiate() as Node3D
	chapter.add_child(plain)
	HingedDoorAudio.attach_all(plain)
	for path: String in HingedDoorAudio.DOORS:
		assert_true(HingedDoor.of(plain.get_node(path)) == null, "audio never fits a hand door itself")
	assert_true(plain.find_children("HingedDoorAudio", "", true, false).is_empty())


func test_listening_fixture_keys_and_three_listener_positions() -> void:
	var fixture := (load("res://audio/test/hinged_door_audio_test.tscn") as PackedScene).instantiate() as Node3D
	chapter.add_child(fixture)
	await wait_frames(2)
	var preview_room := fixture.get("room") as Node3D
	var preview_camera := fixture.get("camera") as Camera3D
	var previous := Vector3.INF
	for key: Key in [KEY_C, KEY_B, KEY_V]:
		_press(fixture, key)
		assert_false(preview_camera.global_position.is_equal_approx(previous), "each key changes the listening position")
		previous = preview_camera.global_position
	for index: int in 2:
		var door := HingedDoor.of(preview_room.get_node(HingedDoorAudio.DOORS[index]))
		var source := door.get_node("HingedDoorAudio") as HingedDoorAudio
		_press(fixture, KEY_1 if index == 0 else KEY_3)
		assert_true(source.playing, "preview open key plays the correct source")
		await door.settled
		_press(fixture, KEY_2 if index == 0 else KEY_4)
		assert_false(source.playing, "preview closing waits for contact")
		await door.settled
		assert_true(source.playing, "preview close key plays on contact")
		_press(fixture, KEY_SPACE)
		assert_false(source.playing, "space stops playback and pending latches")
	_press(fixture, KEY_R)
	for path: String in HingedDoorAudio.DOORS:
		var source := HingedDoor.of(preview_room.get_node(path)).get_node("HingedDoorAudio") as HingedDoorAudio
		assert_false(source.playing, "reset is silent")


func _press(fixture: Node, key: Key) -> void:
	var event := InputEventKey.new()
	event.physical_keycode = key
	event.pressed = true
	fixture.call("_unhandled_key_input", event)
