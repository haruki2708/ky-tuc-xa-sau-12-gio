extends TestCase

var speaker: Speaker
var events: Array[Dictionary] = []
var completed: int = 0
var _had_settings: bool
var _settings_backup: PackedByteArray


func before_each() -> void:
	_had_settings = FileAccess.file_exists("user://settings.cfg")
	if _had_settings:
		_settings_backup = FileAccess.get_file_as_bytes("user://settings.cfg")
	_set_locale("vi")
	speaker = Speaker.new()
	tree.root.add_child(speaker)
	speaker.set_process(false)
	EventBus.subtitle_requested.connect(_on_subtitle)
	speaker.announcement_finished.connect(func() -> void: completed += 1)


func after_each() -> void:
	EventBus.subtitle_requested.disconnect(_on_subtitle)
	speaker.free()
	if _had_settings:
		var file := FileAccess.open("user://settings.cfg", FileAccess.WRITE)
		file.store_buffer(_settings_backup)
		file.close()
	else:
		DirAccess.remove_absolute("user://settings.cfg")
	await tree.create_timer(0.1).timeout


func _set_locale(value: Variant) -> void:
	var config := ConfigFile.new()
	config.set_value("ui", "locale", value)
	assert_eq(config.save("user://settings.cfg"), OK, "locale fixture saved;")


func _on_subtitle(key: String, duration: float) -> void:
	events.append({"key": key, "duration": duration, "clip": speaker._voice.stream,
		"speaking": speaker._voice.playing, "burst": speaker._burst.playing})


func _begin(lines: Array, seconds: float = 0.1) -> void:
	speaker.play_announcement(lines, seconds)
	# Drive actual effect-finished transitions without waiting for the startup jingle.
	for index in 2:
		speaker.stop()
		speaker.finished.emit()


func test_all_34_voice_files_load_decode_and_match_report() -> void:
	var report: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://../audio_source/voice/build_report.json"))
	assert_eq(report["assets"].size(), 34, "all voice measurements;")
	var found: Array[String] = []
	var name_hashes: Dictionary = {}
	for entry: Dictionary in report["assets"]:
		var path: String = "res://" + String(entry["file"]).trim_prefix("game/")
		assert_false(found.has(path), "unique file " + path)
		found.append(path)
		var clip := load(path) as AudioStreamOggVorbis
		assert_not_null(clip, path)
		if clip == null:
			continue
		assert_false(clip.loop, "voice one-shot " + path)
		assert_true(clip.get_length() > 0.5, "nonempty voice " + path)
		assert_eq(FileAccess.get_sha256(path), entry["sha256"], "report matches " + path)
		assert_true(absf(float(entry["lufs"]) + 26.0) <= 1.0, "voice LUFS " + path)
		var playback := clip.instantiate_playback()
		playback.start()
		var frames := playback.mix_audio(1.0, 48000)
		var peak := 0.0
		for frame: Vector2 in frames:
			peak = maxf(peak, absf(frame.x))
		assert_true(peak > 0.00001, "decoded audible signal " + path)
		playback.stop()
		if String(entry["key"]).begins_with("SPK_NAME_"):
			if name_hashes.has(entry["key"]):
				assert_eq(entry["raw_sha256"], name_hashes[entry["key"]], "Vietnamese pronunciation retained in English;")
			name_hashes[entry["key"]] = entry["raw_sha256"]
		if entry["key"] == "RULE_3_GARBLED":
			assert_eq(entry["hidden_speech_gain"], 0, "hidden action removed before static;")
			assert_true(entry["hidden_from_seconds"] > 0.0 and entry["hidden_from_seconds"] < clip.get_length(), "mask covers action suffix")
	for locale in ["vi", "en"]:
		for key: String in SpeakerVoiceBank.KEYS:
			assert_true(found.has("res://audio/voice/%s/%s.ogg" % [locale, key]), "required voice " + key)
	assert_eq(SpeakerVoiceBank.load_clip("res://audio/voice", "vi", "RULE_3"), null, "no unmasked rule 3 voice;")


func test_voice_locale_duration_and_exactly_one_subtitle_per_line() -> void:
	_begin([{"text_key": "SPK_SIGN_LOG"}, {"text_key": "SPK_CHECK_TAPS"}])
	assert_eq(events.size(), 1, "one subtitle at voice start;")
	var clip: AudioStream = events[0]["clip"]
	assert_true(clip.resource_path.contains("/vi/"), "settings selects Vietnamese")
	assert_true(events[0]["speaking"], "voice active before subtitle listener runs")
	assert_true(absf(events[0]["duration"] - clip.get_length() - 0.4) < 0.001, "line extends to voice plus padding")
	assert_eq(speaker._voice.bus, &"Voice", "voice routing;")
	_set_locale("en")
	speaker._process(events[0]["duration"] - 0.01)
	assert_eq(events.size(), 1, "no premature next name;")
	speaker._process(0.02)
	assert_eq(events.size(), 2, "one subtitle for next line;")
	assert_true((events[1]["clip"] as AudioStream).resource_path.contains("/en/"), "next line uses changed locale")
	speaker._process(events[1]["duration"] + 0.01)
	assert_eq(completed, 0, "wait for power-off;")
	assert_false(speaker._voice.playing, "voice stopped before power-off")
	speaker.stop()
	speaker.finished.emit()
	assert_eq(completed, 1, "completion exactly once;")
	speaker.finished.emit()
	assert_eq(completed, 1, "duplicate finished ignored;")


func test_voice_fallback_minimum_duration_spatial_sync_and_cancel() -> void:
	_set_locale(42)
	speaker.unit_size = 7.0
	speaker.volume_db = -3.0
	_begin([{"text_key": "SPK_NAME_TRUNG"}], 8.0)
	assert_eq(events[0]["duration"], 8.0, "caller minimum preserved;")
	assert_true((events[0]["clip"] as AudioStream).resource_path.contains("/vi/"), "invalid locale defaults to vi")
	assert_eq(speaker._voice.unit_size, 7.0, "spatial settings copied;")
	assert_eq(speaker._voice.volume_db, -3.0, "voice follows speaker gain;")
	assert_eq(speaker._voice.position, Vector3.ZERO, "voice originates at speaker;")
	speaker.stop_emitting()
	assert_false(speaker._voice.playing, "stop cancels voice")
	speaker.voice_directory = "res://audio/missing_voice_fixture"
	_begin([{"text_key": "SPK_NAME_TRUNG", "garbled": true}], 0.15)
	assert_eq(events.back()["clip"], null, "missing file falls back;")
	assert_eq(events.back()["duration"], 0.15, "fallback retains timing;")
	assert_true(events.back()["burst"], "fallback retains garble effect")
	speaker.voice_directory = "res://audio/voice"
	_begin([{"text_key": "SUB_TEST_1"}], 0.12)
	assert_eq(events.back()["clip"], null, "unknown key falls back;")
	assert_eq(events.back()["duration"], 0.12, "unknown key keeps subtitle contract;")


func test_garbled_voice_and_reentrant_cancel_stop_all_layers() -> void:
	_begin([{"text_key": "RULE_3_GARBLED", "garbled": true}])
	assert_true(events.back()["burst"] and events.back()["speaking"], "masked voice plus existing burst")
	var cancel := func(_key: String, _duration: float) -> void: speaker.stop_emitting()
	EventBus.subtitle_requested.connect(cancel)
	_begin([{"text_key": "SPK_NAME_PHUC"}, {"text_key": "SPK_NAME_LAM"}])
	EventBus.subtitle_requested.disconnect(cancel)
	speaker._process(60.0)
	assert_eq(events.size(), 2, "cancelled later line never emitted;")
	assert_false(speaker._voice.playing or speaker._burst.playing or speaker._background.playing, "reentrant cancel silences speech too")
	assert_eq(completed, 0, "cancel does not report completion;")


func test_voice_preview_selects_both_languages_without_saving_settings() -> void:
	var before := FileAccess.get_file_as_bytes("user://settings.cfg")
	var fixture := (load("res://audio/test/segment12_test.tscn") as PackedScene).instantiate()
	tree.root.add_child(fixture)
	var event := InputEventKey.new()
	event.pressed = true
	for key in [KEY_V, KEY_B]:
		event.physical_keycode = key
		fixture._unhandled_key_input(event)
		var preview := fixture.get_node("Speaker") as Speaker
		assert_eq(preview.voice_locale, "vi" if key == KEY_V else "en", "audition locale;")
		assert_eq(preview._lines.size(), 17, "all announcements in audition;")
		assert_true(preview.playing, "audition starts")
	assert_eq(FileAccess.get_file_as_bytes("user://settings.cfg"), before, "audition does not change user settings;")
	event.physical_keycode = KEY_0
	fixture._unhandled_key_input(event)
	fixture.free()
