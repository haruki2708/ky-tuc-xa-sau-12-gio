extends TestCase

var _nodes: Array[Node] = []
var _buses: int
var _settings_bytes: PackedByteArray
var _had_settings: bool


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


func _add(node: Node) -> void:
	_nodes.append(node)
	tree.root.add_child(node)


func _rig() -> Ch4AudioRig:
	var rig := Ch4AudioRig.new()
	_add(rig)
	_no_process(rig)
	return rig


func _no_process(node: Node) -> void:
	node.set_process(false)
	for child in node.get_children():
		_no_process(child)


func after_each() -> void:
	tree.paused = false
	for node in _nodes:
		if is_instance_valid(node) and node.has_method("stop_emitting"):
			node.stop_emitting()
	await tree.create_timer(0.1).timeout
	for node in _nodes:
		if is_instance_valid(node):
			node.free()
	if _had_settings:
		var file := FileAccess.open("user://settings.cfg", FileAccess.WRITE)
		file.store_buffer(_settings_bytes)
		file.close()
	else:
		DirAccess.remove_absolute("user://settings.cfg")
	await tree.create_timer(0.1).timeout
	assert_eq(AudioServer.bus_count, _buses)


func test_ch4_banks_decode_match_hashes_lufs_loops_and_approved_voices() -> void:
	var report: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://../audio_source/ch4/build_report.json"))
	assert_eq(report.assets.size(), Ch4AudioBank.NAMES.size())
	for entry: Dictionary in report.assets:
		var clip := Ch4AudioBank.clip(entry.name) as AudioStreamOggVorbis
		assert_not_null(clip)
		if clip == null:
			continue
		assert_eq(FileAccess.get_sha256(clip.resource_path), entry.sha256)
		assert_eq(FileAccess.get_sha256("res://../audio_source/ch4/raw/%s.wav" % entry.name), entry.raw_sha256)
		assert_true(absf(entry.lufs - entry.target_lufs) <= 1.0)
		assert_true(entry.lufs <= -32.0 and entry.true_peak_db <= -2.0)
		assert_eq(clip.loop, Ch4AudioBank.LOOPS.has(entry.name))
		if clip.loop:
			assert_true(entry.boundary_delta < 0.01)
		_decode(clip)
	var voices: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://../audio_source/voice_ch4/build_report.json"))
	var texts: Dictionary[String, String] = {}
	var csv := FileAccess.open("res://localization/strings.csv", FileAccess.READ)
	while not csv.eof_reached():
		var row := csv.get_csv_line()
		if row.size() >= 2:
			texts[row[0]] = row[1]
	csv.close()
	assert_eq(voices.assets.size(), 16)
	assert_true(voices.voices.nurse1[0] != voices.voices.nurse2[0])
	for entry: Dictionary in voices.assets:
		var clip := Ch4AudioBank.voice(entry.key) as AudioStreamOggVorbis
		assert_not_null(clip)
		assert_eq(FileAccess.get_sha256(clip.resource_path), entry.sha256)
		assert_eq(FileAccess.get_sha256("res://../audio_source/voice_ch4/raw/%s.wav" % entry.key), entry.raw_sha256)
		assert_eq(entry.text, texts[entry.key], "verbatim Vietnamese CSV, including ellipses")
		assert_true(Ch4AudioBank.VOICES.has(entry.key))
		assert_true(absf(entry.lufs - entry.target_lufs) <= 1.0)
		assert_true(entry.lufs <= -25 and entry.true_peak_db <= -2)
		assert_false(clip.loop)
		_decode(clip)
	assert_eq(Ch4AudioBank.clip("../door_burst"), null)
	assert_eq(Ch4AudioBank.clip("monitor", ""), null)
	assert_eq(Ch4AudioBank.voice("../pa_signed"), null)


func _decode(clip: AudioStream) -> void:
	var playback := clip.instantiate_playback()
	playback.start()
	var peak := 0.0
	for frame in playback.mix_audio(1.0, ceili(clip.get_length() * 48000)):
		peak = maxf(peak, absf(frame.x))
	assert_true(peak > 0.000001 and peak < 0.8)
	playback.stop()


func test_decoy_exact_six_seconds_spatial_empty_beep_no_duplicate_or_noise() -> void:
	var rig := _rig()
	var noise_count: Array[int] = [0]
	var on_noise := func(_at: Vector3, _radius: float, _source: StringName) -> void: noise_count[0] += 1
	EventBus.noise_emitted.connect(on_noise)
	var at := Vector3(7, 2, -9)
	EventBus.phone_decoy_thrown.emit(at, 0)
	assert_eq(rig.decoy._ring.global_position, at)
	assert_eq(rig.decoy._ring.max_distance, 30.0)
	assert_eq(rig.decoy._ring.bus, &"SFX")
	assert_eq(rig.decoy._foley.stream, Ch4AudioBank.clip("phone_land"))
	rig.decoy._process(5.999)
	EventBus.phone_decoy_thrown.emit(at, 0)
	assert_true(rig.decoy.remaining < 0.002, "duplicate cannot extend timer")
	assert_true(rig.decoy._ring.playing)
	rig.decoy._process(0.001)
	assert_false(rig.decoy._ring.playing)
	assert_eq(rig.decoy._foley.stream, Ch4AudioBank.clip("battery_empty"))
	rig.decoy._process(6.0)
	EventBus.phone_decoy_thrown.emit(at, 0)
	assert_false(rig.decoy._ring.playing, "late duplicate ignored")
	assert_eq(noise_count[0], 0)
	EventBus.noise_emitted.disconnect(on_noise)
	EventBus.checkpoint_loaded.emit(&"ch4_library")
	EventBus.phone_decoy_thrown.emit(at, 1)
	rig.decoy._process(6.0)
	assert_true(rig.decoy._foley.stream != Ch4AudioBank.clip("battery_empty"))


func test_decoy_real_scene_clock_stops_and_pause_does_not_spend_duration() -> void:
	var rig := _rig()
	rig.decoy.set_process(true)
	EventBus.phone_decoy_thrown.emit(Vector3.ZERO, 0)
	tree.paused = true
	await wait_frames(3)
	assert_eq(rig.decoy.remaining, 6.0)
	tree.paused = false
	await tree.create_timer(6.15).timeout
	assert_false(rig.decoy._ring.playing)
	assert_eq(rig.decoy.remaining, 0.0)


func test_door_ids_cadence_thresholds_and_single_burst_across_three_triggers() -> void:
	var rig := _rig()
	var anchor := Node3D.new()
	_add(anchor)
	anchor.position = Vector3(5, 0, -3)
	for id: StringName in [&"407", &"library_back", &"401"]:
		var door := rig.register_door(id, anchor)
		door.set_process(false)
		assert_eq(rig.register_door(id, anchor), door)
		EventBus.door_damage_changed.emit(id, 0.1)
		assert_eq(door.hit_count, 1)
		var quiet := door._pound.volume_db
		for index in 20:
			EventBus.door_damage_changed.emit(id, 0.4)
		door._process(0.699)
		assert_eq(door.hit_count, 1)
		door._process(0.001)
		assert_eq(door.hit_count, 2)
		assert_eq(door._crack.stream, Ch4AudioBank.clip("wood_crack"))
		assert_true(door._pound.volume_db > quiet and door._pound.volume_db <= 0)
		EventBus.door_damage_changed.emit(id, 0.6)
		door._process(0.7)
		assert_eq(door._splinters.stream, Ch4AudioBank.clip("wood_splinters"))
		EventBus.door_damage_changed.emit(id, 0.8)
		assert_eq(door._growl.stream, Ch3AudioBank.clip("zombie_growl"))
		EventBus.door_damage_changed.emit(id, NAN)
		assert_eq(door.fraction, 0.8)
		EventBus.door_damage_changed.emit(id, 1.0)
		rig.play_door_burst(id)
		assert_eq(door.burst_count, 1)
		assert_eq(door._pound.stream, Ch4AudioBank.clip("door_burst"))
		assert_false(door._growl.playing)
		assert_eq(door._pound.bus, &"SFX")
		assert_eq(door._pound.global_position, anchor.global_position)
	EventBus.player_death_started.emit(&"door_burst")
	assert_eq(rig.doors[&"401"].burst_count, 1)
	assert_true(rig.doors[&"401"]._pound.playing)
	assert_false(rig._scare.playing)
	assert_false(rig.doors[&"407"].enabled)


func test_all_ten_scares_route_dedupe_neck_hush_and_monitor_skips_once() -> void:
	var rig := _rig()
	for id in Ch4AudioBank.SCARES:
		if id in [&"neck_hand", &"monitor_skip"]:
			continue
		rig.scare_positions[id] = Vector3(3, 2, -1)
		EventBus.scare_triggered.emit(id)
		assert_eq(rig._scare.stream, Ch4AudioBank.clip(String(id)))
		assert_eq(rig._scare.bus, &"SFX")
		assert_true(rig._scare.volume_db <= 0.0)
		assert_eq(rig._scare.global_position, Vector3(3, 2, -1))
		rig._scare.stop()
		EventBus.scare_triggered.emit(id)
		assert_false(rig._scare.playing)
	rig.set_area(&"library")
	EventBus.phone_decoy_thrown.emit(Vector3.ZERO, 0)
	EventBus.scare_triggered.emit(&"neck_hand")
	assert_false(rig.music._music.playing)
	assert_false(rig.decoy._ring.playing)
	assert_false(rig._scare.playing)
	rig._process(0.79)
	EventBus.scare_triggered.emit(&"neck_hand")
	assert_false(rig._scare.playing)
	rig._process(0.01)
	assert_eq(rig._scare.stream, Ch4AudioBank.clip("neck_hand"))
	assert_true(rig._scare.playing)
	rig.hospital.enter_hospital(Vector3(1, 1, 0))
	rig.hospital._process(1.0)
	assert_eq(rig.hospital.monitor_beats, 1)
	EventBus.scare_triggered.emit(&"monitor_skip")
	EventBus.scare_triggered.emit(&"monitor_skip")
	rig.hospital._process(1.0)
	assert_eq(rig.hospital.monitor_beats, 1)
	assert_eq(rig.hospital.skipped_beats, 1)
	rig.hospital._process(1.0)
	assert_eq(rig.hospital.monitor_beats, 2)
	assert_eq(rig.hospital._monitor.bus, &"SFX")


func test_music_time_ramp_library_407_silence_stair_crowd_and_ending() -> void:
	var rig := _rig()
	rig.listener = Node3D.new()
	_add(rig.listener)
	for index in 10:
		var point := Node3D.new()
		_add(point)
		point.position = Vector3(index + 1, 0, 0)
		rig.stair_points.append(point)
	rig.set_area(&"stairs")
	assert_eq(rig._crowd.size(), 3)
	for player in rig._crowd:
		assert_true(player.playing and player.volume_db <= -18.0)
		assert_eq(player.bus, &"Ambience")
	rig.listener.position.x = 200
	rig._process(0.01)
	for player in rig._crowd:
		assert_false(player.playing)
	rig.set_area(&"library")
	assert_eq(rig.music._ambience.stream, Ch4AudioBank.clip("library"))
	assert_eq(rig.music._rain.stream, Ch4AudioBank.clip("drizzle"))
	var last_gain := -100.0
	for minute in [510, 520, 530, 540]:
		EventBus.time_changed.emit(minute)
		assert_true(rig.music._siren.playing)
		assert_true(rig.music._siren.volume_db > last_gain)
		last_gain = rig.music._siren.volume_db
	EventBus.time_changed.emit(999)
	assert_eq(rig.music._siren.volume_db, 0.0)
	rig.set_area(&"407")
	EventBus.time_changed.emit(535)
	for player in [rig.music._music, rig.music._ambience, rig.music._rain, rig.music._siren]:
		assert_false(player.playing)
	EventBus.chapter_finished.emit(3)
	assert_false(rig.music._end.playing)
	EventBus.chapter_finished.emit(4)
	assert_eq(rig.music._end.bus, &"Music")
	assert_eq(rig.music._end.stream, Ch4AudioBank.clip("music_end"))
	rig.music._end.stop()
	EventBus.chapter_finished.emit(4)
	assert_false(rig.music._end.playing)


func test_fade_slowing_heart_hospital_foley_voices_and_pa_no_replay() -> void:
	var rig := _rig()
	EventBus.fade_message_requested.emit(12.0)
	rig.hospital._process(0.01)
	var interval := rig.hospital.heart_interval()
	rig.hospital._process(5.0)
	EventBus.fade_message_requested.emit(12.0)
	assert_true(rig.hospital._fade_elapsed > 5.0)
	assert_true(rig.hospital.heart_interval() > interval)
	assert_true(rig.hospital._fade.volume_db < 0.0)
	rig.hospital._process(7.0)
	assert_false(rig.hospital._heart.playing)
	assert_false(rig.hospital._fade.playing)
	rig.monitor_marker = Node3D.new()
	_add(rig.monitor_marker)
	EventBus.ch4_ending.emit(&"all")
	assert_true(rig.hospital._hospital)
	assert_eq(rig.music._music.stream, Ch4AudioBank.clip("music_hospital"))
	rig.hospital.play_nurse_step(Vector3.ONE)
	assert_eq(rig.hospital._foley.bus, &"Footsteps")
	var step := rig.hospital._foley.stream
	rig.hospital.play_nurse_step(Vector3.ONE)
	assert_true(step != rig.hospital._foley.stream)
	rig.hospital.play_door(Vector3.ONE)
	assert_eq(rig.hospital._foley.bus, &"SFX")
	for id in Ch4AudioBank.VOICES:
		assert_true(rig.play_line(id, Vector3.ONE) > 0.0)
		assert_eq(rig.hospital._voice.bus, &"Voice")
		assert_eq(rig.hospital._voice.stream, Ch4AudioBank.voice(id))
		rig.hospital._voice.stop()
		assert_eq(rig.play_line(id, Vector3.ONE), 0.0)
		assert_false(rig.hospital._voice.playing)
	rig.play_pa_laugh(Vector3.ONE)
	assert_eq(rig._pa.bus, &"Voice")
	assert_eq(rig._pa.stream, Ch4AudioBank.clip("pa_laugh"))
	rig._pa.stop()
	rig.play_pa_laugh(Vector3.ONE)
	assert_false(rig._pa.playing)


func test_reduced_death_late_events_reset_missing_asset_and_scene_cleanup() -> void:
	var rig := _rig()
	_settings(true)
	EventBus.scare_triggered.emit(&"books_fall")
	assert_eq(rig._scare.volume_db, -10.0)
	EventBus.player_death_started.emit(&"door_burst")
	assert_eq(rig._scare.stream, Ch4AudioBank.clip("door_burst_soft"))
	rig._scare.stop()
	EventBus.player_death_started.emit(&"door_burst")
	EventBus.phone_decoy_thrown.emit(Vector3.ZERO, 0)
	EventBus.scare_triggered.emit(&"knife_pull")
	assert_false(rig._scare.playing)
	assert_false(rig.decoy._ring.playing)
	EventBus.checkpoint_loaded.emit(&"ch4_407")
	rig.decoy.sound_directory = ""
	EventBus.phone_decoy_thrown.emit(Vector3.ZERO, 0)
	assert_false(rig.decoy._ring.playing)
	rig.stop_emitting()
	EventBus.checkpoint_loaded.emit(&"ch4_407")
	EventBus.chapter_finished.emit(4)
	assert_false(rig.music._end.playing)
	var sources := _source_refs(rig)
	rig.free()
	await wait_frames(2)
	for ref in sources:
		assert_eq(ref.get_ref(), null, "all scene-owned audio players freed")
	EventBus.scare_triggered.emit(&"neck_hand")
	EventBus.phone_decoy_thrown.emit(Vector3.ONE, 0)
	assert_eq(AudioServer.bus_count, _buses)


func _source_refs(node: Node) -> Array[WeakRef]:
	var found: Array[WeakRef] = []
	if node is AudioStreamPlayer or node is AudioStreamPlayer3D:
		found.append(weakref(node))
	for child in node.get_children():
		found.append_array(_source_refs(child))
	return found


func test_ch4_audition_loads_all_assets_and_reset() -> void:
	var packed := load("res://audio/test/ch4_audio_test.tscn") as PackedScene
	assert_not_null(packed)
	var fixture := packed.instantiate()
	_add(fixture)
	for index in Ch4AudioBank.NAMES.size() + Ch4AudioBank.VOICES.size():
		fixture.audition(index)
		assert_true(fixture.preview.playing)
		assert_true(fixture.preview.volume_db <= 0.0)
	fixture.reset_preview()
	assert_false(fixture.preview.playing)
