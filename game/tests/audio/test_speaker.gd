extends TestCase

var _speaker: Speaker
var _events: Array[Dictionary] = []
var _completed: int = 0


func before_each() -> void:
	_speaker = Speaker.new()
	tree.root.add_child(_speaker)
	_speaker.announcement_finished.connect(_on_completed)
	EventBus.subtitle_requested.connect(_on_subtitle)


func after_each() -> void:
	tree.paused = false
	EventBus.subtitle_requested.disconnect(_on_subtitle)
	if is_instance_valid(_speaker):
		_speaker.free()
	await tree.create_timer(0.1).timeout


func test_announcement_orders_effects_subtitles_burst_and_completion() -> void:
	_speaker.play_announcement([
		{"text_key": "RULE_1", "garbled": false},
		{"text_key": "RULE_3_GARBLED", "garbled": true},
		{"text_key": "RULE_2", "garbled": false},
	], 0.12)
	assert_eq(_speaker.stream, Speaker.POWER_ON, "power-on first;")
	assert_true(_events.is_empty(), "no subtitles before opening effects")
	var effects: Array[AudioStream] = []
	var deadline := Time.get_ticks_msec() + 8000
	while _completed == 0 and Time.get_ticks_msec() < deadline:
		if _speaker.playing and (effects.is_empty() or effects.back() != _speaker.stream):
			effects.append(_speaker.stream)
		await tree.create_timer(0.01).timeout
	assert_eq(effects, [Speaker.POWER_ON, Speaker.CHIME, Speaker.POWER_OFF], "effect order;")
	assert_eq(_completed, 1, "completion exactly once;")
	assert_eq(_events.size(), 3, "one subtitle per line;")
	if _events.size() == 3:
		for index in 3:
			assert_eq(_events[index]["key"], ["RULE_1", "RULE_3_GARBLED", "RULE_2"][index], "subtitle order;")
			assert_eq(_events[index]["duration"], 0.12, "subtitle duration;")
			assert_eq(_events[index]["burst"], index == 1, "burst only on garbled line;")
			assert_true(_events[index]["bed"], "static under each line")
			if index > 0:
				assert_true(_events[index]["at"] - _events[index - 1]["at"] >= 90, "line readable for requested interval")
	assert_false(_speaker.playing or _speaker._background.playing or _speaker._burst.playing, "all sources stopped before finished")
	for player in [_speaker, _speaker._background, _speaker._burst]:
		assert_eq(player.bus, &"Voice", "all PA layers use Voice;")


func test_restart_snapshots_input_and_cancels_previous_sequence() -> void:
	_speaker.pitch_scale = 4.0
	_speaker.play_announcement([{"text_key": "RULE_1"}, {"text_key": "RULE_2"}], 0.8)
	await _wait_for_events(1)
	var replacement := [{"text_key": "SUB_TEST_1", "garbled": true}]
	_speaker.play_announcement(replacement, 0.06)
	replacement[0]["text_key"] = "RULE_5"
	replacement.clear()
	await _wait_for_completion()
	assert_eq(_events.size(), 2, "old pending line cancelled;")
	if _events.size() == 2:
		assert_eq(_events[1]["key"], "SUB_TEST_1", "caller edits cannot alter snapshot;")
	assert_eq(_completed, 1, "only replacement completes;")


func test_pause_and_cancel_stop_pending_lines() -> void:
	_speaker.pitch_scale = 4.0
	_speaker.play_announcement([{"text_key": "RULE_1"}, {"text_key": "RULE_2"}], 0.25)
	await _wait_for_events(1)
	tree.paused = true
	await tree.create_timer(0.35, true).timeout
	assert_eq(_events.size(), 1, "pause freezes subtitle scheduling;")
	assert_eq(_completed, 0, "paused announcement has not completed;")
	tree.paused = false
	_speaker.stop_emitting()
	await tree.create_timer(0.35).timeout
	assert_eq(_events.size(), 1, "cancel prevents later subtitles;")
	assert_eq(_completed, 0, "cancel does not report successful completion;")
	assert_false(_speaker.playing or _speaker._background.playing or _speaker._burst.playing, "cancel silences layers")


func test_empty_invalid_and_reentrant_calls() -> void:
	_speaker.play_announcement([])
	assert_eq(_completed, 1, "empty batch completes without sound;")
	_speaker.play_announcement([{"text_key": "RULE_1"}], NAN)
	assert_false(_speaker.playing, "invalid duration ignored")
	_speaker.pitch_scale = 4.0
	_speaker.play_announcement([null, 42, {}, {"text_key": ""}, {"text_key": "RULE_2", "garbled": "yes"}, {"text_key": &"SUB_TEST_2"}], 0.06)
	await _wait_for_events(1)
	assert_eq(_events.size(), 1, "malformed entries skipped;")
	if not _events.is_empty():
		assert_eq(_events[0]["key"], "SUB_TEST_2", "StringName supported;")
	_speaker.stop_emitting()
	var cancel_on_subtitle := func(_key: String, _seconds: float) -> void: _speaker.stop_emitting()
	EventBus.subtitle_requested.connect(cancel_on_subtitle)
	_speaker.play_announcement([{"text_key": "RULE_1", "garbled": true}, {"text_key": "RULE_2"}], 0.06)
	await _wait_for_events(2)
	await tree.create_timer(0.2).timeout
	EventBus.subtitle_requested.disconnect(cancel_on_subtitle)
	assert_eq(_events.size(), 2, "subscriber cancellation prevents next line;")
	assert_false(_speaker._burst.playing or _speaker._background.playing, "subscriber cancellation silences new layers")


func test_segment12_fixture_loads_and_all_preview_keys_work() -> void:
	var scene := load("res://audio/test/segment12_test.tscn") as PackedScene
	var fixture := scene.instantiate()
	tree.root.add_child(fixture)
	var key := InputEventKey.new()
	key.pressed = true
	for index in 11:
		key.physical_keycode = KEY_F1 + index
		fixture._unhandled_key_input(key)
		assert_true(fixture.get_node("Preview").playing, "preview key %d" % index)
		assert_eq(fixture.get_node("Preview").stream, fixture.CLIPS[index], "selected clip;")
	key.physical_keycode = KEY_SPACE
	fixture._unhandled_key_input(key)
	assert_true(fixture.get_node("Speaker").playing, "Space starts announcement")
	key.physical_keycode = KEY_0
	fixture._unhandled_key_input(key)
	assert_false(fixture.get_node("Speaker").playing or fixture.get_node("Preview").playing, "0 stops previews")
	fixture.free()


func _on_subtitle(key: String, seconds: float) -> void:
	_events.append({"key": key, "duration": seconds, "burst": _speaker._burst.playing,
		"bed": _speaker._background.playing, "at": Time.get_ticks_msec()})


func _on_completed() -> void:
	_completed += 1


func _wait_for_events(count: int) -> void:
	var deadline := Time.get_ticks_msec() + 5000
	while _events.size() < count and Time.get_ticks_msec() < deadline:
		await tree.create_timer(0.01).timeout
	assert_true(_events.size() >= count, "subtitle wait deadline")


func _wait_for_completion() -> void:
	var deadline := Time.get_ticks_msec() + 5000
	while _completed == 0 and Time.get_ticks_msec() < deadline:
		await tree.create_timer(0.01).timeout
	assert_true(_completed > 0, "completion wait deadline")
