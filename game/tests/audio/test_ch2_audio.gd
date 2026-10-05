extends TestCase

var _nodes: Array[Node] = []
var _buses: int
var _settings_bytes: PackedByteArray
var _had_settings: bool
var _ticks: Array[float] = []


func before_each() -> void:
	_buses = AudioServer.bus_count
	_had_settings = FileAccess.file_exists("user://settings.cfg")
	if _had_settings:
		_settings_bytes = FileAccess.get_file_as_bytes("user://settings.cfg")
	_settings(false)


func _settings(reduced: bool) -> void:
	var config := ConfigFile.new()
	config.set_value("accessibility", "reduce_scares", reduced)
	assert_eq(config.save("user://settings.cfg"), OK)
	EventBus.settings_changed.emit("accessibility", "reduce_scares")


func _add(node: Node) -> void:
	_nodes.append(node)
	tree.root.add_child(node)


func after_each() -> void:
	tree.paused = false
	for node in _nodes:
		if node.has_method("stop_emitting"):
			node.stop_emitting()
		node.free()
	if _had_settings:
		var file := FileAccess.open("user://settings.cfg", FileAccess.WRITE)
		file.store_buffer(_settings_bytes)
		file.close()
	else:
		DirAccess.remove_absolute("user://settings.cfg")
	await tree.create_timer(0.1).timeout
	assert_eq(AudioServer.bus_count, _buses, "private buses released")


func test_ch2_assets_decode_and_match_measured_report() -> void:
	var report: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://../audio_source/ch2/build_report.json"))
	assert_eq(report["assets"].size(), Ch2AudioBank.NAMES.size())
	var seen: Array[String] = []
	for entry: Dictionary in report["assets"]:
		var clip := Ch2AudioBank.clip(entry["name"]) as AudioStreamOggVorbis
		seen.append(entry["name"])
		assert_not_null(clip)
		if clip == null:
			continue
		assert_eq(FileAccess.get_sha256(clip.resource_path), entry["sha256"])
		assert_eq(FileAccess.get_sha256("res://../audio_source/ch2/raw/%s.wav" % entry["name"]), entry["raw_sha256"])
		assert_true(absf(float(entry["lufs"]) - float(entry["target_lufs"])) <= 1.0)
		assert_true(float(entry["true_peak_db"]) <= -2.0)
		assert_eq(clip.loop, Ch2AudioBank.LOOPS.has(entry["name"]))
		if clip.loop:
			assert_true(float(entry["boundary_delta"]) < 0.01)
		var playback := clip.instantiate_playback()
		playback.start()
		var peak := 0.0
		for frame in playback.mix_audio(1.0, ceili(clip.get_length() * 48000)):
			peak = maxf(peak, absf(frame.x))
		assert_true(peak > 0.000001 and peak < 0.8, entry["name"])
		playback.stop()
	for clip_name in Ch2AudioBank.NAMES:
		assert_true(seen.has(clip_name))
	assert_eq(Ch2AudioBank.clip("../missing"), null)
	assert_eq(Ch2AudioBank.clip("chain_tick", ""), null)


func test_three_corpse_profiles_are_spatial_private_and_route_to_voice() -> void:
	var pitches: Array[float] = []
	for id in ["phuc", "viet", "dat"]:
		var corpse := CorpseVoice.new()
		corpse.speaker = id
		_add(corpse)
		pitches.append(corpse._voice.pitch_scale)
		assert_true(corpse._voice is AudioStreamPlayer3D)
		assert_eq(corpse._foley.bus, &"SFX")
		var index := AudioServer.get_bus_index(corpse._voice.bus)
		assert_eq(AudioServer.get_bus_send(index), &"Voice")
		assert_true(AudioServer.get_bus_effect(index, 0) is AudioEffectDistortion)
		assert_true(AudioServer.get_bus_effect(index, 1) is AudioEffectLowPassFilter)
	assert_true(pitches[0] != pitches[1] and pitches[1] != pitches[2] and pitches[0] != pitches[2])
	assert_true(pitches.all(func(value: float) -> bool: return value < 1.0))


func test_word_keys_safe_missing_bank_and_cached_voice_duration() -> void:
	var corpse := CorpseVoice.new()
	_add(corpse)
	assert_eq(corpse.play_word("WORD_CH2_MISSING"), 0.0)
	assert_eq(corpse.play_word("WORD_CH2_../../bad"), 0.0)
	assert_eq(corpse.play_word("CHAT_CH1_WRONG"), 0.0)
	# Exercise the real resource lookup without inventing or committing spoken words.
	var clip := Ch2AudioBank.clip("corpse_gag").duplicate() as AudioStream
	clip.take_over_path("res://audio/voice/vi/WORD_CH2_AUDIO_TEST.ogg")
	EventBus.chain_word_spoken.emit(&"viet", "WORD_CH2_AUDIO_TEST")
	assert_false(corpse._voice.playing)
	var duration := corpse.play_word("WORD_CH2_AUDIO_TEST")
	assert_true(is_equal_approx(duration, clip.get_length() / corpse._voice.pitch_scale))
	assert_true(corpse._voice.playing)
	EventBus.chain_turn_started.emit(&"viet", 15.0)
	assert_false(corpse._voice.playing)
	corpse.voice_directory = ""
	assert_eq(corpse.play_word("WORD_CH2_AUDIO_TEST"), 0.0)


func test_gag_latches_across_fall_revive_and_mumble_stops_on_reset() -> void:
	var corpse := CorpseVoice.new()
	_add(corpse)
	EventBus.corpse_state_changed.emit(2, &"gagged")
	assert_false(corpse._gagged)
	EventBus.corpse_state_changed.emit(1, &"gagged")
	assert_eq(corpse._foley.stream, Ch2AudioBank.clip("corpse_gag"))
	EventBus.corpse_state_changed.emit(1, &"mumble")
	assert_eq(corpse._filter.cutoff_hz, 650.0)
	assert_true(corpse._voice.playing)
	var playback := corpse._voice.get_stream_playback()
	corpse.set_mumbling(true)
	assert_eq(corpse._voice.get_stream_playback(), playback)
	EventBus.corpse_state_changed.emit(1, &"fall")
	assert_false(corpse._voice.playing)
	assert_eq(corpse._foley.stream, Ch2AudioBank.clip("corpse_fall"))
	EventBus.corpse_state_changed.emit(1, &"revive")
	EventBus.corpse_state_changed.emit(1, &"talk")
	corpse.play_word("WORD_CH2_ABSENT")
	assert_eq(corpse._voice.stream, Ch2AudioBank.clip("corpse_mumble"))
	EventBus.checkpoint_loaded.emit(&"ch2_r3")
	assert_false(corpse._gagged)
	assert_false(corpse._voice.playing)
	corpse.stop_emitting()
	corpse.set_mumbling(true)
	assert_false(corpse._voice.playing)


func test_chain_clock_fifteen_seconds_last_five_accelerate_and_cancel() -> void:
	var clock := Ch2Countdown.new()
	_add(clock)
	clock.set_process(false)
	clock.ticked.connect(func(remaining: float) -> void: _ticks.append(remaining))
	EventBus.chain_turn_started.emit(&"trung", 15.0)
	for i in 30:
		clock._process(0.5)
	assert_eq(_ticks.size(), 19)
	assert_eq(_ticks[0], 14.0)
	assert_eq(_ticks[9], 5.0)
	assert_eq(_ticks[10], 4.5)
	assert_eq(_ticks[-1], 0.5)
	assert_eq(clock.remaining, 0.0)
	assert_false(clock._player.playing)
	EventBus.chain_turn_started.emit(&"phuc", 15.0)
	EventBus.chain_word_spoken.emit(&"viet", "WORD_CH2_TEST")
	assert_eq(clock.remaining, 15.0)
	EventBus.chain_word_spoken.emit(&"phuc", "")
	assert_eq(clock.remaining, 15.0)
	EventBus.chain_word_spoken.emit(&"phuc", "WORD_CH2_TEST")
	assert_eq(clock.remaining, 0.0)
	clock.start(15.0)
	EventBus.chain_choice_made.emit(0)
	assert_eq(clock.remaining, 0.0)
	clock.start(NAN)
	assert_eq(clock.remaining, 0.0)
	clock.start(15.0)
	clock.set_process(true)
	tree.paused = true
	await wait_frames(3)
	assert_eq(clock.remaining, 15.0)
	tree.paused = false


func test_shower_temperature_changes_immediately_without_predicting_slot() -> void:
	var shower := ShowerAudio.new()
	_add(shower)
	assert_eq(shower._water.bus, &"Ambience")
	assert_eq(shower._steam.bus, &"Ambience")
	assert_eq(shower._clock._player.bus, &"SFX")
	for temperature in [1.0, 37.0, 81.0, 9.0, 10.0, 49.0, 50.0]:
		shower.set_water(temperature, true)
		var name := "water_cold" if temperature < 10 else ("water_warm" if temperature < 50 else "water_boiling")
		assert_eq(shower._water.stream, Ch2AudioBank.clip(name))
		assert_true(shower._water.playing)
	var playback := shower._water.get_stream_playback()
	shower.set_water(60.0, true)
	assert_eq(shower._water.get_stream_playback(), playback)
	EventBus.shower_slot_finished.emit(81, true, 2)
	assert_false(shower._water.playing)
	EventBus.shower_choice_requested.emit(8.0)
	assert_eq(shower._clock.remaining, 8.0)
	EventBus.shower_choice_made.emit(true)
	assert_eq(shower._clock.remaining, 0.0)
	assert_false(shower._water.playing, "await revealed temperature from core")
	shower.set_water(NAN, true)
	assert_false(shower._water.playing)
	shower.set_water(37.0, true)
	EventBus.shower_choice_made.emit(false)
	assert_false(shower._water.playing)


func test_shower_steam_door_mirror_reset_and_missing_bank() -> void:
	var shower := ShowerAudio.new()
	_add(shower)
	EventBus.shower_steam_changed.emit(0.5)
	assert_true(shower._steam.playing)
	assert_true(is_equal_approx(shower._steam.volume_linear, 0.5))
	EventBus.shower_steam_changed.emit(0.0)
	assert_false(shower._steam.playing)
	for level in [1, 2, 3]:
		shower.play_door_push(level)
		assert_eq(shower._cue.stream, Ch2AudioBank.clip("door_push_%02d" % level))
	shower.play_cue("door_burst")
	assert_eq(shower._cue.stream, Ch2AudioBank.clip("door_burst"))
	shower.play_cue("mirror_shiver")
	assert_eq(shower._cue.stream, Ch2AudioBank.clip("mirror_shiver"))
	EventBus.player_death_started.emit(&"scald")
	assert_false(shower._cue.playing)
	shower.sound_directory = ""
	shower.set_water(90.0, true)
	assert_false(shower._water.playing)
	shower.stop_emitting()
	shower.play_cue("door_burst")
	assert_false(shower._cue.playing)


func test_ch2_death_once_reduction_live_and_no_legacy_kill() -> void:
	var player := Ch1PlayerAudio.new()
	_add(player)
	for kind in [&"corpse_lunge", &"scald"]:
		_settings(false)
		EventBus.checkpoint_loaded.emit(&"ch2_r3")
		EventBus.player_death_started.emit(kind)
		var playback := player._death.get_stream_playback()
		assert_not_null(playback)
		assert_eq(player._death.bus, &"SFX")
		EventBus.player_death_started.emit(kind)
		assert_eq(player._death.get_stream_playback(), playback)
		EventBus.player_caught.emit(&"manager")
		assert_false(player._foley.playing)
		_settings(true)
		assert_eq(player._death.stream, Ch2AudioBank.clip("death_corpse_soft" if kind == &"corpse_lunge" else "death_scald_soft"))
	EventBus.checkpoint_loaded.emit(&"ch2_r4")
	player.chapter2_directory = ""
	EventBus.player_death_started.emit(&"scald")
	assert_false(player._death.playing)


func test_camera_room_loss_visible_matching_channel_only_and_no_replay() -> void:
	var cctv := CctvAudio.new()
	_add(cctv)
	assert_false(cctv.play_room_loss(&"room102"))
	cctv.set_viewing(true)
	cctv.select_channel(&"room310")
	assert_false(cctv.play_room_loss(&"room102"))
	cctv.select_channel(&"room102")
	assert_true(cctv.play_room_loss(&"room102"))
	assert_false(cctv.play_room_loss(&"room102"))
	assert_eq(cctv._room_loss.bus, &"SFX")
	cctv.select_channel(&"room310")
	assert_false(cctv._room_loss.playing)
	cctv.select_channel(&"room102")
	assert_false(cctv._room_loss.playing)
	assert_true(cctv.play_room_loss(&"room102"))
	EventBus.phone_raised.emit(false)
	assert_false(cctv._room_loss.playing)
	cctv.set_viewing(true)
	assert_false(cctv._room_loss.playing)


func test_ch2_music_turn_pulse_round_crossfade_pause_and_reset() -> void:
	var music := Ch2Music.new()
	_add(music)
	music.set_process(false)
	EventBus.chapter_started.emit(1)
	assert_false(music._beds[0].playing)
	EventBus.chapter_started.emit(2)
	music._process(1.5)
	assert_eq(music._beds[0].bus, &"Music")
	assert_true(music._beds[0].playing)
	EventBus.chain_turn_started.emit(&"trung", 15.0)
	assert_true(music._turn.playing)
	EventBus.shower_choice_requested.emit(8.0)
	assert_false(music._turn.playing)
	music._process(1.5)
	assert_false(music._beds[0].playing)
	assert_true(music._beds[1].playing)
	music.set_process(true)
	tree.paused = true
	var gain := music._gains[1]
	await wait_frames(3)
	assert_eq(music._gains[1], gain)
	tree.paused = false
	EventBus.player_death_started.emit(&"scald")
	assert_false(music._beds[1].playing)
	EventBus.chain_turn_started.emit(&"trung", 15.0)
	assert_false(music._turn.playing)


func test_ch2_audition_all_clips_and_clean_reset() -> void:
	var scene := load("res://audio/test/ch2_audio_test.tscn") as PackedScene
	assert_not_null(scene)
	var fixture := scene.instantiate()
	_add(fixture)
	for i in Ch2AudioBank.NAMES.size():
		fixture.audition(i)
		assert_true(fixture.preview.playing)
		assert_eq(fixture.preview.stream, Ch2AudioBank.clip(Ch2AudioBank.NAMES[i]))
	fixture.reset_preview()
	assert_false(fixture.preview.playing)
