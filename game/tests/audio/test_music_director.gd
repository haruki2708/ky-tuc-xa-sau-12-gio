extends TestCase

var director: MusicDirector
var _had_settings: bool
var _saved_settings: PackedByteArray
var _was_paused: bool


func before_each() -> void:
	_was_paused = tree.paused
	_had_settings = FileAccess.file_exists("user://settings.cfg")
	if _had_settings:
		_saved_settings = FileAccess.get_file_as_bytes("user://settings.cfg")
		DirAccess.remove_absolute("user://settings.cfg")
	director = MusicDirector.new()
	tree.root.add_child(director)
	# Advance envelopes deterministically without making the suite wait 25 seconds.
	director.set_process(false)


func after_each() -> void:
	director.free()
	tree.paused = _was_paused
	if _had_settings:
		var file := FileAccess.open("user://settings.cfg", FileAccess.WRITE)
		file.store_buffer(_saved_settings)
		file.close()
	elif FileAccess.file_exists("user://settings.cfg"):
		DirAccess.remove_absolute("user://settings.cfg")
	await tree.create_timer(0.1, true).timeout


func _advance(seconds: float) -> void:
	var remaining := seconds
	while remaining > 0.00001:
		var delta := minf(remaining, 0.025)
		director._process(delta)
		for tween: Tween in director._tweens.values():
			if tween.is_valid():
				tween.custom_step(delta)
		remaining -= delta


func _gain(layer: StringName) -> float:
	return (director._players[layer] as AudioStreamPlayer).volume_linear


func _setting(value: Variant) -> void:
	var config := ConfigFile.new()
	config.set_value("accessibility", "reduce_scares", value)
	assert_eq(config.save("user://settings.cfg"), OK, "save fixture settings;")
	EventBus.settings_changed.emit("accessibility", "reduce_scares")


func test_music_assets_and_measured_loudness() -> void:
	var targets := {"drone_base": -42.0, "drone_tension": -36.0, "chase_pulse": -30.0, "end_tone": -32.0}
	var report: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://../audio_source/build_report.json"))
	var seen: Array[String] = []
	for entry: Dictionary in report["assets"]:
		var file: String = entry["file"]
		var clip := file.get_file().get_basename()
		if not targets.has(clip):
			continue
		seen.append(clip)
		assert_true(is_finite(entry["lufs"]) and absf(entry["lufs"] - targets[clip]) <= 1.0, "LUFS " + clip)
		assert_eq(FileAccess.get_sha256("res://" + file.trim_prefix("game/")), entry["sha256"], "report hash " + clip)
		assert_eq(entry["loop"], clip != "end_tone", "loop " + clip)
		if entry["loop"]:
			assert_true(entry["boundary_delta"] < 0.02, "codec loop seam " + clip)
		if clip == "drone_base":
			assert_true(entry["seconds"] >= 30.0 and entry["seconds"] <= 60.0, "base duration")
		if clip == "end_tone":
			assert_true(entry["seconds"] >= 8.0 and entry["seconds"] <= 12.0, "ending duration")
	assert_eq(seen.size(), 4, "all music measured;")
	for player: AudioStreamPlayer in director._players.values():
		assert_eq(player.bus, &"Music", "music routing;")
		assert_false(player.playing, "silent before seg2")


func test_music_segments_tension_hold_and_deviation_ceiling() -> void:
	EventBus.segment_changed.emit(&"seg1")
	EventBus.consequence_triggered.emit(&"extra_slippers", &"test")
	_advance(3.0)
	assert_eq(_gain(&"base"), 0.0, "no music during tutorial;")
	EventBus.segment_changed.emit(&"seg2")
	_advance(2.1)
	assert_eq(_gain(&"base"), 1.0, "base fully faded in;")
	assert_eq(_gain(&"tension"), 0.0, "level zero bed silent;")
	EventBus.consequence_triggered.emit(&"extra_slippers", &"test")
	_advance(2.1)
	var burst := _gain(&"tension")
	assert_true(absf(linear_to_db(burst) + 8.0) < 0.01, "level zero burst is -8 dB")
	_advance(14.8)
	assert_true(absf(_gain(&"tension") - burst) < 0.00001, "hold lasts 15 seconds after attack")
	_advance(4.0)
	assert_true(_gain(&"tension") > 0.0 and _gain(&"tension") < burst, "eight-second release in progress")
	_advance(4.2)
	assert_eq(_gain(&"tension"), 0.0, "release ends at silent level-zero bed;")
	var previous := 0.0
	for level in range(1, 5):
		EventBus.deviation_changed.emit(level, &"test")
		_advance(2.1)
		assert_true(_gain(&"tension") > previous, "bed increases at level %d" % level)
		previous = _gain(&"tension")
	EventBus.deviation_changed.emit(99, &"test")
	EventBus.consequence_triggered.emit(&"extra_slippers", &"test")
	_advance(2.1)
	assert_eq(_gain(&"tension"), 1.0, "burst capped at asset LUFS;")


func test_music_overlapping_silence_restores_latest_chase_state() -> void:
	EventBus.segment_changed.emit(&"seg3")
	_advance(2.1)
	EventBus.consequence_triggered.emit(&"corridor_light_flicker", &"test")
	_advance(0.05)
	assert_eq(_gain(&"base"), 0.0, "lights cut all music;")
	EventBus.chase_started.emit(&"corridor")
	EventBus.scare_triggered.emit(&"corridor_glimpse")
	_advance(1.8)
	assert_eq(_gain(&"chase"), 0.0, "scare expiration does not override longer lights silence;")
	EventBus.chase_ended.emit(&"corridor", true)
	_advance(1.3)
	assert_true(_gain(&"base") > 0.0, "base returns after three seconds")
	assert_eq(_gain(&"chase"), 0.0, "caught chase never revives after silence;")
	_advance(2.1)
	assert_true(_gain(&"tension") > 0.0, "tension rises after lights silence")
	EventBus.scare_triggered.emit(&"lost")
	_advance(0.05)
	assert_eq(_gain(&"tension"), 0.0, "scare cuts tension;")
	_advance(1.2)
	assert_eq(_gain(&"base"), 0.0, "scare silence still active;")
	_advance(0.6)
	assert_true(_gain(&"base") > 0.99, "scare returns mix")


func test_music_chase_settings_and_pause_duck_are_independent() -> void:
	EventBus.segment_changed.emit(&"seg3")
	EventBus.chase_started.emit(&"corridor")
	_advance(2.1)
	assert_eq(_gain(&"chase"), 1.0, "chase full gain;")
	_setting(true)
	_advance(0.3)
	assert_true(absf(linear_to_db(_gain(&"chase")) + 6.0) < 0.01, "reduce scares subtracts 6 dB")
	EventBus.scare_triggered.emit(&"test")
	_advance(0.1)
	assert_eq(_gain(&"base"), 1.0, "reduce scares skips silence;")
	tree.paused = true
	EventBus.game_paused.emit(true)
	await tree.create_timer(0.3, true).timeout
	assert_true(absf(linear_to_db(_gain(&"chase")) + 16.0) < 0.1, "pause plus reduction while tree paused")
	assert_true(absf(linear_to_db(_gain(&"base")) + 10.0) < 0.1, "pause duck independent of layer")
	tree.paused = false
	EventBus.game_paused.emit(false)
	_setting("true")
	_advance(0.3)
	assert_eq(_gain(&"chase"), 1.0, "invalid setting falls back false;")
	EventBus.chase_ended.emit(&"other", true)
	_advance(0.1)
	assert_eq(_gain(&"chase"), 1.0, "unrelated chase end ignored;")
	EventBus.chase_ended.emit(&"corridor", false)
	_advance(0.7)
	assert_true(_gain(&"chase") > 0.0 and _gain(&"chase") < 1.0, "escape fades smoothly")
	_advance(0.9)
	assert_eq(_gain(&"chase"), 0.0, "escape finishes;")


func test_music_end_checkpoint_reset_and_shutdown_cancel_pending_audio() -> void:
	EventBus.segment_changed.emit(&"seg5")
	_advance(2.1)
	EventBus.segment_changed.emit(&"end")
	_advance(0.4)
	assert_false((director._players[&"ending"] as AudioStreamPlayer).playing, "end waits for fade")
	_advance(0.5)
	assert_true((director._players[&"ending"] as AudioStreamPlayer).playing, "end tone starts")
	assert_false((director._players[&"base"] as AudioStreamPlayer).playing, "loop stopped at end")
	EventBus.segment_changed.emit(&"seg2")
	_advance(2.1)
	assert_eq(_gain(&"ending"), 0.0, "restarting cancels ending;")
	EventBus.segment_changed.emit(&"end")
	_advance(0.2)
	EventBus.segment_changed.emit(&"seg1")
	_advance(1.0)
	assert_eq(_gain(&"ending"), 0.0, "stale ending cannot become audible;")
	EventBus.segment_changed.emit(&"seg3")
	EventBus.scare_triggered.emit(&"test")
	director.stop_emitting()
	EventBus.segment_changed.emit(&"seg2")
	EventBus.chase_started.emit(&"test")
	_advance(4.0)
	for player: AudioStreamPlayer in director._players.values():
		assert_false(player.playing, "shutdown never restarts playback")
		assert_eq(player.volume_linear, 0.0, "shutdown silent;")


func test_music_settings_at_startup_and_live_scare_cancellation() -> void:
	_setting(true)
	director.free()
	director = MusicDirector.new()
	tree.root.add_child(director)
	director.set_process(false)
	EventBus.segment_changed.emit(&"seg3")
	EventBus.chase_started.emit(&"test")
	_advance(2.1)
	assert_true(absf(linear_to_db(_gain(&"chase")) + 6.0) < 0.01, "saved setting applied on ready")
	_setting(false)
	EventBus.scare_triggered.emit(&"test")
	_advance(0.05)
	assert_eq(_gain(&"base"), 0.0, "scare begins;")
	_setting(true)
	_advance(0.3)
	assert_eq(_gain(&"base"), 1.0, "enabling reduction releases active scare;")
	EventBus.consequence_triggered.emit(&"corridor_light_flicker", &"test")
	_advance(0.05)
	_setting(true)
	_advance(0.3)
	assert_eq(_gain(&"base"), 0.0, "reduction preserves lights-out consequence;")
	var remaining := director._light_remaining
	EventBus.game_paused.emit(true)
	_advance(5.0)
	assert_eq(director._light_remaining, remaining, "pause freezes musical hold deadlines;")
	EventBus.game_paused.emit(false)


func test_music_preview_solos_and_demo_sequence() -> void:
	var room := (load("res://audio/test/scare_test.tscn") as PackedScene).instantiate()
	tree.root.add_child(room)
	var preview := room.get_node("Preview") as AudioStreamPlayer
	for index in 4:
		var event := InputEventKey.new()
		event.physical_keycode = KEY_1 + index
		event.pressed = true
		room._unhandled_key_input(event)
		assert_eq(preview.stream, MusicDirector.CLIPS[index], "solo music key;")
		assert_eq(preview.bus, &"Music", "solo music bus;")
		assert_true(preview.playing, "solo starts")
	var demo := InputEventKey.new()
	demo.physical_keycode = KEY_M
	demo.pressed = true
	room._unhandled_key_input(demo)
	assert_false(preview.playing, "demo stops solo")
	assert_true(director._active, "demo starts seg2")
	var sequence: Tween = room._demo
	sequence.custom_step(3.1)
	assert_true(director._tension_remaining > 0.0, "demo triggers consequence")
	sequence.custom_step(4.1)
	assert_eq(director._chase_id, &"preview", "demo starts chase;")
	sequence.custom_step(5.1)
	assert_eq(director._chase_id, &"", "demo escapes;")
	demo.physical_keycode = KEY_0
	room._unhandled_key_input(demo)
	assert_false(director._active, "0 resets director")
	room.free()
