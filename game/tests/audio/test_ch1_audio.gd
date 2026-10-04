extends TestCase

class PoseFixture extends Node:
	signal pose_changed(pose_name: StringName)

var _nodes: Array[Node] = []
var _had_settings: bool
var _settings_backup: PackedByteArray
var _initial_buses: int
var _cached_clips: Array[AudioStream] = []


func before_each() -> void:
	_initial_buses = AudioServer.bus_count
	_had_settings = FileAccess.file_exists("user://settings.cfg")
	if _had_settings:
		_settings_backup = FileAccess.get_file_as_bytes("user://settings.cfg")
	_settings(false)


func after_each() -> void:
	tree.paused = false
	for node in _nodes:
		if is_instance_valid(node):
			if node.has_method("stop_emitting"):
				node.stop_emitting()
			node.free()
	_nodes.clear()
	_cached_clips.clear()
	if _had_settings:
		var file := FileAccess.open("user://settings.cfg", FileAccess.WRITE)
		file.store_buffer(_settings_backup)
		file.close()
	else:
		DirAccess.remove_absolute("user://settings.cfg")
	await wait_frames(2)
	assert_eq(AudioServer.bus_count, _initial_buses, "private buses released;")
	await tree.create_timer(0.1).timeout


func _settings(reduced: bool) -> void:
	var config := ConfigFile.new()
	config.set_value("ui", "locale", "vi")
	config.set_value("accessibility", "reduce_scares", reduced)
	assert_eq(config.save("user://settings.cfg"), OK, "fixture settings;")
	EventBus.settings_changed.emit("accessibility", "reduce_scares")


func _add(node: Node) -> void:
	_nodes.append(node)
	tree.root.add_child(node)


func _cache_voice(key: String, source: String = "manager_knock") -> AudioStream:
	# Register a real decoded OGG in memory; no production voice/files invented.
	var clip := Ch1AudioBank.clip(source).duplicate() as AudioStream
	clip.take_over_path("res://audio/voice/vi/" + key + ".ogg")
	_cached_clips.append(clip)
	return clip


func test_ch1_assets_decode_loudness_loops_and_hashes() -> void:
	var report: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://../audio_source/ch1/build_report.json"))
	assert_eq(report["assets"].size(), 29, "complete chapter bank;")
	var seen: Array[String] = []
	for entry: Dictionary in report["assets"]:
		var clip_name: String = entry["name"]
		seen.append(clip_name)
		var clip := Ch1AudioBank.clip(clip_name) as AudioStreamOggVorbis
		assert_not_null(clip, clip_name)
		if clip == null:
			continue
		assert_eq(clip.loop, Ch1AudioBank.LOOPS.has(clip_name), "loop " + clip_name)
		assert_true(clip.get_length() >= 0.6, "duration " + clip_name)
		assert_eq(FileAccess.get_sha256(clip.resource_path), entry["sha256"], "measured file " + clip_name)
		assert_true(absf(float(entry["lufs"]) - float(entry["target_lufs"])) <= 1.0, "LUFS " + clip_name)
		assert_true(float(entry["true_peak_db"]) <= -2.0, "peak " + clip_name)
		if clip.loop:
			assert_true(float(entry["boundary_delta"]) < 0.01, "loop seam " + clip_name)
		var playback := clip.instantiate_playback()
		playback.start()
		var peak := 0.0
		for frame: Vector2 in playback.mix_audio(1.0, ceili(clip.get_length() * 48000.0)):
			peak = maxf(peak, absf(frame.x))
		assert_true(peak > 0.00001, "decoded signal " + clip_name)
		playback.stop()
	for clip_name in Ch1AudioBank.NAMES:
		assert_true(seen.has(clip_name), "manifest coverage " + clip_name)
	assert_eq(Ch1AudioBank.clip("../../unknown"), null, "invalid name safe;")


func test_phone_filters_route_to_existing_sliders() -> void:
	for bus_name in [&"PhoneVoice", &"PhoneSFX"]:
		var index := AudioServer.get_bus_index(bus_name)
		assert_true(index >= 0, "phone bus exists")
		assert_eq(AudioServer.get_bus_send(index), &"Voice" if bus_name == &"PhoneVoice" else &"SFX", "parent slider;")
		assert_eq(AudioServer.get_bus_effect_count(index), 3, "bandpass and grit;")
		var high := AudioServer.get_bus_effect(index, 0) as AudioEffectHighPassFilter
		var grit := AudioServer.get_bus_effect(index, 1) as AudioEffectDistortion
		var low := AudioServer.get_bus_effect(index, 2) as AudioEffectLowPassFilter
		assert_not_null(high)
		assert_not_null(grit)
		assert_not_null(low)
		assert_eq(high.cutoff_hz, 300.0)
		assert_eq(low.cutoff_hz, 3400.0)
		assert_true(grit.drive > 0.0 and grit.drive < 0.2, "mild distortion")


func test_floor_filter_is_per_source_and_restores_routing() -> void:
	var source := AudioStreamPlayer3D.new()
	source.bus = &"Voice"
	source.volume_db = -3.0
	_add(source)
	var second := AudioStreamPlayer3D.new()
	second.bus = &"Voice"
	_add(second)
	var muffle := FloorMuffle.new()
	source.add_child(muffle)
	muffle.set_process(false)
	source.global_position = Vector3(3, 6.7, 0)
	muffle.update_listener_position(Vector3(0, 1.5, 0))
	var bus_index := AudioServer.get_bus_index(source.bus)
	assert_eq(muffle.floor_gap, 2, "6 to 4;")
	assert_true(AudioServer.is_bus_effect_enabled(bus_index, 0), "filtered across floors")
	assert_eq(AudioServer.get_bus_volume_db(bus_index), -16.0, "two slabs;")
	assert_eq(muffle._filter.cutoff_hz, 1100.0, "bass through slabs;")
	assert_eq(AudioServer.get_bus_send(bus_index), &"Voice", "voice slider retained;")
	assert_eq(source.volume_db, -3.0, "source gain untouched;")
	assert_eq(second.bus, &"Voice", "other sources unaffected;")
	source.global_position.y = 0.2
	muffle.update_listener_position(Vector3(0, 1.5, 0))
	assert_false(AudioServer.is_bus_effect_enabled(bus_index, 0), "same floor dry")
	assert_eq(AudioServer.get_bus_volume_db(bus_index), 0.0)
	source.global_position.y = -3.2
	muffle.update_listener_position(Vector3(0, 1.5, 0))
	assert_eq(muffle.floor_gap, 1, "negative floor;")
	muffle.floor_height = 0.0
	muffle.update_listener_position(Vector3(0, 1.5, 0))
	assert_eq(muffle.floor_gap, 1, "invalid height fallback;")
	muffle.free()
	assert_eq(source.bus, &"Voice", "original bus restored;")


func test_manager_spatial_api_missing_streams_and_voice_duration() -> void:
	var manager := load("res://audio/entities/manager_audio.tscn").instantiate() as ManagerAudio
	manager.play_step()
	assert_eq(manager.say("MGR_AUDIO_FIXTURE"), 0.0, "safe before ready;")
	_add(manager)
	manager.place_at(Vector3(2, 6.6, -3))
	assert_eq(manager.global_position, Vector3(2, 6.6, -3))
	manager.play_step()
	var first: AudioStream = manager._players["Step"].stream
	manager.play_step()
	assert_true(first != manager._players["Step"].stream, "step variants alternate")
	manager.play_drag(true)
	assert_true(manager._players["Drag"].playing, "loop started")
	manager.play_drag(false)
	assert_false(manager._players["Drag"].playing, "loop stopped")
	manager.play_knock()
	manager.play_slash(&"wood")
	assert_true(String(manager._players["Slash"].stream.resource_path).contains("slash_wood"))
	var clip := _cache_voice("MGR_AUDIO_FIXTURE")
	assert_eq(manager.say("MGR_AUDIO_FIXTURE"), clip.get_length() + 0.4, "real duration;")
	assert_true(manager._players["Speech"].playing)
	for channel: String in manager._players:
		var source: AudioStreamPlayer3D = manager._players[channel]
		assert_eq(AudioServer.get_bus_send(AudioServer.get_bus_index(source.bus)), &"Voice" if channel == "Speech" else &"SFX", "manager bus " + channel)
	manager.sound_directory = ""
	manager.voice_directory = ""
	manager.play_step()
	manager.play_drag(true)
	manager.play_knock()
	manager.play_slash()
	manager.play_kill()
	assert_eq(manager.say("MGR_MISSING"), 2.5, "subtitle fallback duration;")
	for source: AudioStreamPlayer3D in manager._players.values():
		assert_false(source.playing, "missing stream safe")
	manager.stop_emitting()
	manager.sound_directory = Ch1AudioBank.DIRECTORY
	manager.play_drag(true)
	assert_false(manager._players["Drag"].playing, "shutdown cannot restart")


func test_reduced_scares_uses_less_detailed_clips_including_live_change() -> void:
	var manager := ManagerAudio.new()
	_add(manager)
	manager.play_slash()
	manager.play_kill()
	_settings(true)
	assert_eq(manager._players["Slash"].stream, Ch1AudioBank.clip("slash_soft"), "live slash replacement;")
	assert_eq(manager._players["Kill"].stream, Ch1AudioBank.clip("kill_soft"), "live kill replacement;")
	manager.play_slash(&"wood")
	manager.play_kill()
	assert_eq(manager._players["Slash"].stream, Ch1AudioBank.clip("slash_soft"))
	assert_eq(manager._players["Kill"].stream, Ch1AudioBank.clip("kill_soft"))


func test_scream_wave_staggers_positions_floors_and_cancels() -> void:
	var screams := BuildingScreams.new()
	_add(screams)
	screams.set_process(false)
	screams._rng.seed = 158
	screams.play_wave(Vector3(0, 0.2, 0), 4, 3.0)
	assert_eq(screams._voices.size(), 1, "first scream immediate;")
	assert_eq(screams._pending.size(), 3, "remaining delayed;")
	screams._process(1.01)
	assert_eq(screams._voices.size(), 2)
	assert_true(screams._voices[0].global_position != screams._voices[1].global_position, "separate rooms")
	assert_true(screams._voices[0].global_position.y != screams._voices[1].global_position.y, "separate floors")
	assert_true(screams._voices[0].stream != screams._voices[1].stream, "different screams")
	screams.stop_emitting()
	screams._process(50.0)
	assert_eq(screams._voices.size(), 0, "no delayed restart;")
	assert_eq(screams._pending.size(), 0)
	screams.sound_directory = ""
	screams.play_wave(Vector3.ZERO, 20, 0.0)
	assert_eq(screams._voices.size(), 0, "missing clips safe;")


func test_phone_call_queue_spoken_filter_member_death_and_shutdown() -> void:
	var phone := PhoneCallAudio.new()
	_add(phone)
	EventBus.phone_call_incoming.emit(&"fixture")
	assert_true(phone._ring.playing)
	EventBus.phone_call_answered.emit(&"different")
	assert_false(phone._in_call)
	EventBus.phone_call_answered.emit(&"fixture")
	assert_false(phone._ring.playing)
	var clip := _cache_voice("CHAT_CH1_AUDIO_FIXTURE")
	var message := MessageData.new()
	message.sender = &"member_a"
	message.text_key = "CHAT_CH1_AUDIO_FIXTURE"
	assert_eq(phone.play_message(message), 0.0, "text is silent;")
	message.spoken = true
	assert_eq(phone.play_message(message), clip.get_length())
	assert_eq(phone._speech.bus, &"PhoneVoice")
	phone.play_message(message)
	message.sender = &"member_b"
	phone.play_message(message)
	assert_eq(phone._queue.size(), 2, "serialized speech;")
	EventBus.chat_member_changed.emit(&"member_a", &"dead")
	assert_eq(phone._speaking_member, &"member_b", "dead voice/queued lines removed;")
	assert_eq(phone._effect.stream, Ch1AudioBank.clip("call_drop"))
	assert_eq(phone._effect.bus, &"PhoneSFX")
	EventBus.chat_member_changed.emit(&"member_b", &"left")
	assert_eq(phone._effect.stream, Ch1AudioBank.clip("call_disconnect"))
	phone.end_call()
	assert_false(phone._speech.playing)
	assert_false(phone._in_call)
	phone.stop_emitting()
	EventBus.phone_call_incoming.emit(&"later")
	assert_false(phone._ring.playing, "shutdown cannot restart")


func test_phone_missing_voice_keeps_transcript_and_missing_sfx_is_safe() -> void:
	var phone := PhoneCallAudio.new()
	phone.sound_directory = ""
	phone.voice_directory = ""
	_add(phone)
	EventBus.phone_call_incoming.emit(&"fixture")
	EventBus.phone_call_answered.emit(&"fixture")
	var message := MessageData.new()
	message.spoken = true
	message.text_key = "CHAT_CH1_NOT_RECORDED"
	assert_eq(phone.play_message(message), 0.0)
	assert_eq(message.text_key, "CHAT_CH1_NOT_RECORDED", "transcript data unchanged;")
	EventBus.phone_message_received.emit(&"nonexistent_audio_fixture")
	EventBus.chat_member_changed.emit(&"missing", &"dead")
	phone.end_call()
	assert_false(phone._speech.playing)
	assert_false(phone._effect.playing)


func test_player_heartbeat_accelerates_and_only_exhaustion_gasps() -> void:
	var player := Ch1PlayerAudio.new()
	_add(player)
	player.set_process(false)
	EventBus.breath_held.emit(true)
	player._process(0.01)
	var initial := player.heartbeat_interval()
	assert_true(player._heart.playing)
	player._process(7.9)
	assert_true(player.heartbeat_interval() < initial, "accelerates")
	assert_eq(player._heart.bus, &"SFX")
	EventBus.breath_held.emit(false)
	assert_false(player._heart.playing)
	assert_false(player._foley.playing, "voluntary release does not gasp")
	EventBus.noise_emitted.emit(Vector3.ZERO, 1.5, &"breath")
	assert_false(player._foley.playing, "ordinary breath not exhaustion")
	EventBus.noise_emitted.emit(Vector3.ZERO, 4.0, &"breath")
	assert_eq(player._foley.stream, Ch1AudioBank.clip("breath_gasp"))
	for action in [&"bunk_climb", &"bunk_creak", &"wall_knock", &"locker_unlock", &"charger_plug"]:
		player.play_action(action)
		assert_eq(player._foley.stream, Ch1AudioBank.clip(String(action)))
	_settings(true)
	EventBus.player_caught.emit(&"manager")
	assert_eq(player._foley.stream, Ch1AudioBank.clip("kill_soft"))
	player.sound_directory = ""
	player.play_action(&"bunk_climb")
	assert_false(player._foley.playing)


func test_corpse_pose_signal_drip_control_and_pause() -> void:
	var poser := PoseFixture.new()
	_add(poser)
	var corpse := CorpseAudio.new()
	corpse.poser = poser
	_add(corpse)
	assert_false(corpse._drip.playing, "story starts the blood")
	corpse.play_drips(true)
	assert_true(corpse._drip.playing)
	poser.pose_changed.emit(&"turned")
	assert_true(corpse._rustle.playing)
	assert_eq(AudioServer.get_bus_send(AudioServer.get_bus_index(corpse._drip.bus)), &"Ambience")
	assert_eq(AudioServer.get_bus_send(AudioServer.get_bus_index(corpse._rustle.bus)), &"SFX")
	await wait_frames(3)
	tree.paused = true
	var paused_position := corpse._drip.get_playback_position()
	await tree.create_timer(0.05, true).timeout
	assert_false(corpse._drip.can_process(), "tree pauses spatial source")
	assert_true(absf(corpse._drip.get_playback_position() - paused_position) < 0.04, "paused playback does not advance")
	tree.paused = false
	corpse.play_drips(false)
	assert_false(corpse._drip.playing)
	corpse.sound_directory = ""
	corpse.play_pose()
	corpse.play_drips(true)
	assert_false(corpse._rustle.playing)
	assert_false(corpse._drip.playing)


func test_chapter_music_silence_is_latched_and_missing_streams_safe() -> void:
	var music := Ch1Music.new()
	_add(music)
	EventBus.chapter_started.emit(1)
	music.set_tension(1.0)
	for tween: Tween in music._tweens.values():
		tween.custom_step(3.0)
	music._process(0.0)
	assert_true(music._base.playing and music._tension.playing)
	assert_eq(music._base.bus, &"Music")
	assert_true(music._base.volume_linear <= 0.65, "quiet baseline")
	assert_true(music._tension.volume_linear > 0.0)
	music.silence_before_door()
	(music._tweens["_silence"] as Tween).custom_step(0.02)
	music.set_tension(0.8)
	(music._tweens["_tension_gain"] as Tween).custom_step(2.0)
	music._process(0.0)
	assert_eq(music._base.volume_linear, 0.0, "door silence;")
	assert_eq(music._tension.volume_linear, 0.0, "proximity cannot unmute;")
	EventBus.game_paused.emit(true)
	(music._tweens["_duck"] as Tween).custom_step(0.3)
	music.silence_before_door(false)
	(music._tweens["_silence"] as Tween).custom_step(2.0)
	music._process(0.0)
	assert_true(music._base.volume_linear < 0.3, "pause duck remains")
	music.stop_emitting()
	EventBus.chapter_started.emit(1)
	assert_false(music._base.playing)
	var missing := Ch1Music.new()
	missing.base_stream = null
	missing.tension_stream = null
	_add(missing)
	missing.set_active(true)
	assert_false(missing._base.playing)


func test_chapter_speaker_keeps_contract_with_new_start_and_line_noise() -> void:
	var speaker := Speaker.new()
	speaker.chapter_profile = true
	_add(speaker)
	speaker.set_process(false)
	speaker.play_announcement([{"text_key": "SPK_CH1_AUDIO_MISSING"}], 0.2)
	assert_eq(speaker.stream, Ch1AudioBank.clip("pa_on"))
	speaker.stop()
	speaker.finished.emit()
	assert_eq(speaker.stage, Speaker.Stage.LINES, "no friendly demo chime;")
	assert_eq(speaker._burst.stream, Ch1AudioBank.clip("pa_burst"))
	assert_true(speaker._burst.playing)
	assert_false(speaker._voice.playing, "missing voice subtitle fallback")
	speaker._process(0.3)
	assert_eq(speaker.stage, Speaker.Stage.POWER_OFF)
	assert_eq(SpeakerVoiceBank.load_clip("res://audio/voice", "vi", "SPK_CH1_../../RULE_3"), null)


func test_ch1_audition_all_clips_and_floor_travel_load() -> void:
	var scene: Node = load("res://audio/test/ch1_audio_test.tscn").instantiate()
	_add(scene)
	for index in Ch1AudioBank.NAMES.size():
		scene.audition(index)
		assert_true(scene.preview.playing, "audition index %d" % index)
	scene.start_travel()
	assert_true(is_equal_approx(scene.manager.global_position.y, 6.6), "starts floor 6")
	assert_true(scene.manager._players["Drag"].playing)
	(scene._travel as Tween).custom_step(14.0)
	assert_eq(scene.manager.global_position.y, 0.0, "arrives floor 4;")
	scene.reset_preview()
	assert_false(scene.preview.playing)
	assert_false(scene.manager._players["Drag"].playing)
