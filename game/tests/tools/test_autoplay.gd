extends TestCase

const AUTOPLAY = preload("res://scripts/debug/autoplay.gd")
var player: Node


func before_each() -> void:
	player = AUTOPLAY.new()
	player.quit_on_finish = false
	tree.root.add_child(player)
	player.set_process(false)


func after_each() -> void:
	player.free()


func test_press_release_mouse_and_finish() -> void:
	var motions: Array[Vector2] = []
	var listener := MotionListener.new()
	listener.motions = motions
	tree.root.add_child(listener)
	await wait_frames()
	var finished: Array[bool] = []
	player.playback_finished.connect(func() -> void: finished.append(true))
	assert_true(player.load_recording("res://tests/tools/autoplay_example.json"))
	player._process(0.0)
	assert_true(Input.is_action_pressed("move_forward"), "frame zero press")
	for frame in range(1, 7):
		player._process(0.0)
	assert_false(Input.is_action_pressed("move_forward"), "release movement")
	assert_false(Input.is_action_pressed("interact"), "release interact")
	Input.flush_buffered_events()
	await wait_frames()
	assert_true(Vector2(200, 0) in motions, "mouse motion delivered through input: %s" % str(motions))
	for frame in range(7, 36):
		player._process(0.0)
	assert_true(finished.is_empty(), "must wait 30 frames after final event")
	player._process(0.0)
	assert_eq(finished.size(), 1, "finish on frame 36")
	listener.free()


func test_stop_releases_held_actions() -> void:
	assert_true(player.load_recording("res://tests/tools/autoplay_example.json"))
	player._process(0.0)
	player.stop()
	assert_false(Input.is_action_pressed("move_forward"))


func test_reject_invalid_recordings() -> void:
	var path := "user://qa_invalid_autoplay.json"
	for content: String in ["{", "{}", '[{"frame":-1,"press":"interact"}]', '[{"frame":0,"press":"missing_action"}]', '[{"frame":2,"press":"interact"},{"frame":1,"release":"interact"}]', '[{"frame":0,"mouse_dx":"bad"}]']:
		var file := FileAccess.open(path, FileAccess.WRITE)
		file.store_string(content)
		file.close()
		assert_false(player.load_recording(path), "reject " + content)
	DirAccess.remove_absolute(path)


class MotionListener extends Node:
	var motions: Array[Vector2] = []

	func _input(event: InputEvent) -> void:
		if event is InputEventMouseMotion:
			motions.append(event.relative)
