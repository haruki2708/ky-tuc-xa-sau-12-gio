extends TestCase

var _nodes: Array[Node] = []
var _had_settings: bool
var _settings_bytes: PackedByteArray
var _buses: int
var _taps: Array[Vector2i] = []
var _finished: int = 0


func before_each() -> void:
	_buses = AudioServer.bus_count
	_had_settings = FileAccess.file_exists("user://settings.cfg")
	if _had_settings:
		_settings_bytes = FileAccess.get_file_as_bytes("user://settings.cfg")
	_settings(false)


func _settings(reduced: bool) -> void:
	var config := ConfigFile.new()
	config.set_value("ui", "locale", "vi")
	config.set_value("accessibility", "reduce_scares", reduced)
	assert_eq(config.save("user://settings.cfg"), OK)
	EventBus.settings_changed.emit("accessibility", "reduce_scares")


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
	assert_eq(AudioServer.bus_count, _buses, "private buses released;")


func _add(node: Node) -> void:
	_nodes.append(node)
	tree.root.add_child(node)


func _new_taps() -> WallTaps:
	var wall := WallTaps.new()
	_add(wall)
	wall.set_process(false)
	wall.tap_played.connect(func(group: int, tap: int) -> void: _taps.append(Vector2i(group, tap)))
	wall.sequence_finished.connect(func() -> void: _finished += 1)
	return wall


func test_v2_assets_decode_hashes_lufs_and_loops() -> void:
	var report: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://../audio_source/ch1v2/build_report.json"))
	assert_eq(report["assets"].size(), Ch1V2AudioBank.NAMES.size())
	var seen: Array[String] = []
	for entry: Dictionary in report["assets"]:
		var name: String = entry["name"]
		seen.append(name)
		var clip := Ch1V2AudioBank.clip(name) as AudioStreamOggVorbis
		assert_not_null(clip, name)
		if clip == null:
			continue
		assert_eq(FileAccess.get_sha256(clip.resource_path), entry["sha256"], name)
		assert_true(absf(float(entry["lufs"]) - float(entry["target_lufs"])) <= 1.0, "LUFS " + name)
		assert_true(float(entry["true_peak_db"]) <= -2.0, "peak " + name)
		assert_eq(clip.loop, Ch1V2AudioBank.LOOPS.has(name), "loop " + name)
		if clip.loop:
			assert_true(float(entry["boundary_delta"]) < 0.01, "seam " + name)
		var playback := clip.instantiate_playback()
		playback.start()
		var peak := 0.0
		for frame: Vector2 in playback.mix_audio(1.0, ceili(clip.get_length() * 48000)):
			peak = maxf(peak, absf(frame.x))
		assert_true(peak > 0.000001, "audible samples " + name)
		playback.stop()
	for name in Ch1V2AudioBank.NAMES:
		assert_true(seen.has(name), "coverage " + name)
	assert_eq(Ch1V2AudioBank.clip("missing"), null)


func test_wall_taps_count_order_digit_and_letter_gaps() -> void:
	var wall := _new_taps()
	var groups: Array[int] = [1, 2, 1, 3]
	assert_true(wall.play_sequence(Vector3(2, 1, 3), groups))
	groups[1] = 5
	assert_eq(_taps, [Vector2i(0, 0)], "first onset immediate;")
	wall._process(0.99)
	assert_eq(_taps.size(), 1, "digit gap not elapsed;")
	wall._process(0.01)
	assert_eq(_taps[-1], Vector2i(1, 0))
	wall._process(0.28)
	assert_eq(_taps[-1], Vector2i(1, 1))
	wall._process(2.49)
	assert_eq(_taps.size(), 3, "letter gap not elapsed;")
	wall._process(0.01)
	assert_eq(_taps[-1], Vector2i(2, 0))
	wall._process(1.0)
	wall._process(0.28)
	wall._process(0.28)
	assert_eq(_taps, [Vector2i(0, 0), Vector2i(1, 0), Vector2i(1, 1), Vector2i(2, 0), Vector2i(3, 0), Vector2i(3, 1), Vector2i(3, 2)], "snapshot and exact order;")
	assert_eq(_finished, 0, "wait for final sound tail;")
	wall._process(0.51)
	wall._process(5.0)
	assert_eq(_finished, 1, "finish once;")
	assert_eq(wall.global_position, Vector3(2, 1, 3))


func test_wall_cancel_restart_reentrancy_invalid_and_missing_bank() -> void:
	var wall := _new_taps()
	wall.play_sequence(Vector3.ZERO, [5, 5])
	wall.stop_emitting()
	wall._process(10.0)
	assert_eq(_finished, 0, "cancel does not finish;")
	assert_eq(_taps.size(), 1)
	assert_false(wall.play_sequence(Vector3.ZERO, [0, 6]))
	assert_false(wall.play_sequence(Vector3.ZERO, [1, 1], NAN, 2.5))
	wall.sound_directory = ""
	wall.play_sequence(Vector3.ZERO, [1, 1], 0.3, 0.5)
	wall._process(1.0)
	assert_eq(_finished, 1, "missing audio preserves schedule;")
	assert_false(wall._source.playing)
	var cancel := func(_group: int, _tap: int) -> void: wall.stop_emitting()
	wall.tap_played.connect(cancel)
	wall.play_sequence(Vector3.ZERO, [5, 5])
	wall._process(100.0)
	assert_eq(_finished, 1, "reentrant cancel suppresses finish;")
	wall.tap_played.disconnect(cancel)
	wall.play_sequence(Vector3.ZERO, [])
	assert_eq(_finished, 2, "empty sequence completes;")


func test_wall_muffling_pause_and_checkpoint_cancel() -> void:
	var wall := _new_taps()
	var index := AudioServer.get_bus_index(wall._source.bus)
	assert_eq(AudioServer.get_bus_send(index), &"SFX")
	assert_eq(wall._muffle._filter.cutoff_hz, 900.0)
	assert_eq(AudioServer.get_bus_volume_db(index), -4.0)
	wall.set_other_side(false)
	assert_false(AudioServer.is_bus_effect_enabled(index, 0))
	wall.play_sequence(Vector3.ZERO, [2, 2])
	wall.set_process(true)
	tree.paused = true
	await tree.create_timer(0.35, true).timeout
	assert_eq(_taps.size(), 1, "sequence freezes in pause;")
	tree.paused = false
	EventBus.checkpoint_loaded.emit(&"fixture")
	assert_false(wall._active)
	assert_false(wall._source.playing)


func test_mission_cues_handle_loop_release_and_missing_streams() -> void:
	var rig := Ch1MissionAudio.new()
	_add(rig)
	for name in [&"router_power_off", &"router_boot", &"router_online", &"power_switch", &"power_short", &"lock_alarm"]:
		rig.play_cue(name)
		assert_true(rig._cue.playing)
		assert_eq(rig._cue.bus, &"SFX")
		assert_eq(rig._cue.stream, Ch1V2AudioBank.clip(String(name)))
	rig.set_handle_rattling(true)
	var playing := rig._handle.get_stream_playback()
	rig.set_handle_rattling(true)
	assert_eq(rig._handle.get_stream_playback(), playing, "true does not restart loop;")
	rig.set_handle_rattling(false)
	assert_false(rig._handle.playing)
	assert_true(rig._tail.playing)
	playing = rig._tail.get_stream_playback()
	rig.set_handle_rattling(false)
	assert_eq(rig._tail.get_stream_playback(), playing, "release once;")
	rig.set_handle_rattling(true)
	assert_false(rig._tail.playing, "new loop cancels release")
	EventBus.checkpoint_loaded.emit(&"fixture")
	assert_false(rig._handle.playing or rig._tail.playing)
	rig.sound_directory = ""
	rig.play_cue(&"power_short")
	rig.set_handle_rattling(true)
	rig.set_handle_rattling(false)
	assert_false(rig._cue.playing or rig._handle.playing or rig._tail.playing)


func test_phone_lost_drops_speech_and_does_not_replay_missed_lines() -> void:
	var phone := PhoneCallAudio.new()
	_add(phone)
	EventBus.phone_call_incoming.emit(&"fixture")
	EventBus.phone_call_answered.emit(&"fixture")
	EventBus.phone_message_received.emit(&"chat_ch1_kiet_306")
	assert_true(phone._speech.playing)
	EventBus.phone_message_received.emit(&"chat_ch1_hung_yes")
	assert_eq(phone._queue.size(), 1)
	phone.play_remote_ring(true)
	assert_true(phone._remote_ring.playing)
	assert_eq(phone._remote_ring.bus, &"PhoneSFX")
	assert_true(phone._remote_ring.stream != Ch1AudioBank.clip("call_ring"))
	EventBus.phone_call_lost.emit(&"wrong_id")
	assert_false(phone._connection_lost)
	EventBus.phone_call_lost.emit(&"fixture")
	assert_false(phone._speech.playing or phone._remote_ring.playing)
	assert_eq(phone._effect.stream, Ch1AudioBank.clip("call_disconnect"))
	EventBus.phone_message_received.emit(&"chat_ch1_hung_yes")
	assert_eq(phone._queue.size(), 0)
	EventBus.chat_member_changed.emit(&"kiet", &"dead")
	assert_eq(phone._effect.stream, Ch1AudioBank.clip("call_disconnect"), "death while disconnected stays unheard;")
	EventBus.phone_call_restored.emit(&"wrong_id")
	assert_true(phone._connection_lost)
	EventBus.phone_call_restored.emit(&"fixture")
	assert_eq(phone._effect.stream, Ch1V2AudioBank.clip("call_reconnect"))
	assert_false(phone._speech.playing)
	EventBus.phone_message_received.emit(&"chat_ch1_hung_yes")
	assert_true(phone._speech.playing, "new connected message speaks")
	phone.play_remote_ring(true)
	assert_false(phone._remote_ring.playing, "dead member cannot ring")
	EventBus.checkpoint_loaded.emit(&"fixture")
	assert_false(phone._in_call)


func test_death_sounds_deduplicate_both_event_orders_and_reset() -> void:
	var player := Ch1PlayerAudio.new()
	_add(player)
	EventBus.player_caught.emit(&"manager")
	var first := player._foley.get_stream_playback()
	assert_not_null(first)
	EventBus.player_death_started.emit(&"manager_kill")
	assert_eq(player._foley.get_stream_playback(), first, "caught then death: base once;")
	assert_eq(player._death.stream, Ch1V2AudioBank.clip("death_flesh"))
	var detail := player._death.get_stream_playback()
	EventBus.player_death_started.emit(&"manager_kill")
	assert_eq(player._death.get_stream_playback(), detail, "duplicate death ignored;")
	EventBus.checkpoint_loaded.emit(&"fixture")
	EventBus.player_death_started.emit(&"manager_kill")
	first = player._foley.get_stream_playback()
	EventBus.player_caught.emit(&"manager")
	assert_eq(player._foley.get_stream_playback(), first, "death then caught: base once;")
	_settings(true)
	assert_eq(player._foley.stream, Ch1AudioBank.clip("kill_soft"))
	assert_false(player._death.playing, "reduced removes flesh layer immediately")
	EventBus.chapter_started.emit(1)
	EventBus.player_death_started.emit(&"none")
	EventBus.player_caught.emit(&"manager")
	assert_false(player._death.playing or player._foley.playing, "none has no player death sound")


func test_fall_bed_reduction_missing_clips_and_shutdown() -> void:
	var player := Ch1PlayerAudio.new()
	_add(player)
	for kind in [&"fall_back", &"bed_burst"]:
		EventBus.chapter_started.emit(1)
		_settings(false)
		EventBus.player_death_started.emit(kind)
		assert_eq(player._death.stream, Ch1V2AudioBank.clip("death_" + String(kind)))
		assert_eq(player._death.bus, &"SFX")
		_settings(true)
		assert_eq(player._death.stream, Ch1V2AudioBank.clip("death_fall_soft" if kind == &"fall_back" else "death_bed_soft"))
	EventBus.chapter_started.emit(1)
	player.mission_directory = ""
	EventBus.player_death_started.emit(&"fall_back")
	assert_false(player._death.playing)
	player.stop_emitting()
	EventBus.chapter_started.emit(1)
	EventBus.player_death_started.emit(&"manager_kill")
	assert_false(player._death.playing or player._foley.playing)


func test_camera_only_plays_when_viewed_and_channel_changes() -> void:
	var camera := CctvAudio.new()
	_add(camera)
	EventBus.cctv_focus_requested.emit(&"102")
	assert_false(camera._background.playing, "notification is not visibility")
	camera.select_channel(&"102")
	assert_false(camera._switch.playing)
	camera.set_viewing(true)
	assert_true(camera._background.playing)
	assert_eq(camera._background.bus, &"SFX")
	camera.select_channel(&"102")
	var playing := camera._switch.get_stream_playback()
	camera.select_channel(&"102")
	assert_eq(camera._switch.get_stream_playback(), playing, "same channel stays quiet;")
	camera.select_channel(&"306")
	assert_true(camera._switch.get_stream_playback() != playing, "new channel tunes")
	EventBus.phone_raised.emit(false)
	assert_false(camera._background.playing or camera._switch.playing)
	camera.sound_directory = ""
	camera.set_viewing(true)
	camera.select_channel(&"209")
	assert_false(camera._background.playing or camera._switch.playing)
	camera.stop_emitting()
	camera.sound_directory = Ch1V2AudioBank.DIRECTORY
	camera.set_viewing(true)
	assert_false(camera._background.playing)


func test_v2_preview_loads_all_assets_and_stops() -> void:
	var scene: Node = load("res://audio/test/ch1v2_audio_test.tscn").instantiate()
	_add(scene)
	for index in Ch1V2AudioBank.NAMES.size():
		scene.audition(index)
		assert_true(scene.preview.playing)
	scene.reset_preview()
	assert_false(scene.preview.playing)
