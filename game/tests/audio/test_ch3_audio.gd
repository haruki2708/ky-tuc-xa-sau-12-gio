extends TestCase

var _nodes: Array[Node] = []
var _buses: int
var _had_settings: bool
var _settings_bytes: PackedByteArray


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
		_stop_sources(node)
	# Let the audio thread retire stopped playbacks before deleting their owners.
	await tree.create_timer(0.1).timeout
	for node in _nodes:
		node.free()
	if _had_settings:
		var file := FileAccess.open("user://settings.cfg", FileAccess.WRITE)
		file.store_buffer(_settings_bytes)
		file.close()
	else:
		DirAccess.remove_absolute("user://settings.cfg")
	await tree.create_timer(0.1).timeout
	assert_eq(AudioServer.bus_count, _buses)


func _stop_sources(node: Node) -> void:
	if node is AudioStreamPlayer or node is AudioStreamPlayer3D:
		node.stop()
	for child in node.get_children():
		_stop_sources(child)


func test_ch3_assets_decode_and_match_lufs_hashes_loops() -> void:
	var report: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://../audio_source/ch3/build_report.json"))
	assert_eq(report["assets"].size(), Ch3AudioBank.NAMES.size())
	var seen: Array[String] = []
	for entry: Dictionary in report["assets"]:
		seen.append(entry["name"])
		var clip := Ch3AudioBank.clip(entry["name"]) as AudioStreamOggVorbis
		assert_not_null(clip)
		if clip == null:
			continue
		assert_eq(FileAccess.get_sha256(clip.resource_path), entry["sha256"])
		assert_eq(FileAccess.get_sha256("res://../audio_source/ch3/raw/%s.wav" % entry["name"]), entry["raw_sha256"])
		assert_true(absf(float(entry["lufs"]) - float(entry["target_lufs"])) <= 1.0)
		assert_true(float(entry["true_peak_db"]) <= -2.0)
		assert_true(float(entry["lufs"]) <= -32.0, "quiet bank")
		assert_eq(clip.loop, Ch3AudioBank.LOOPS.has(entry["name"]))
		assert_true(int(entry["bytes"]) < 10000000)
		if clip.loop:
			assert_true(float(entry["boundary_delta"]) < 0.01)
		var playback := clip.instantiate_playback()
		playback.start()
		var peak := 0.0
		for frame in playback.mix_audio(1.0, ceili(clip.get_length() * 48000)):
			peak = maxf(peak, absf(frame.x))
		assert_true(peak > 0.000001 and peak < 0.8, entry["name"])
		playback.stop()
	for clip_name in Ch3AudioBank.NAMES:
		assert_true(seen.has(clip_name))
	assert_eq(Ch3AudioBank.clip("../missing"), null)
	assert_eq(Ch3AudioBank.clip("pant", ""), null)


func test_forty_zombies_only_nearest_eight_then_move_sleep_occlude_and_free() -> void:
	var listener := Node3D.new()
	_add(listener)
	var manager := Ch3HordeAudio.new()
	manager.listener = listener
	_add(manager)
	manager.set_process(false)
	var rigs: Array[ZombieAudio] = []
	for index in 40:
		var actor := Node3D.new()
		actor.position.x = index + 1
		_add(actor)
		var rig := ZombieAudio.new()
		actor.add_child(rig)
		manager.register(rig)
		rigs.append(rig)
		EventBus.zombie_woke.emit(actor)
	manager.voice_limit = 100
	manager.update_mix()
	assert_eq(manager.audible_count(), 8, "runtime value also hard capped")
	for index in 40:
		assert_eq(rigs[index].audible, index < 8)
	assert_true(manager._bed.playing)
	assert_eq(manager._bed.volume_linear, 1.0)
	listener.position.x = 40
	manager.voice_limit = 6
	manager.update_mix()
	assert_eq(manager.audible_count(), 6)
	assert_false(rigs[0]._voice.playing)
	assert_true(rigs[39]._voice.playing)
	EventBus.zombie_stunned.emit(rigs[39].zombie, 5.0)
	assert_false(rigs[39]._voice.playing, "stun silences immediately")
	rigs[38].set_eligible(false)
	manager.update_mix()
	assert_false(rigs[38].audible)
	assert_eq(manager.audible_count(), 6)
	rigs[37].free()
	manager.update_mix()
	assert_eq(manager._rigs.size(), 39)
	listener.position.x = 200
	manager.update_mix()
	assert_eq(manager.audible_count(), 0, "no individual sources past sixty metres")
	EventBus.player_death_started.emit(&"zombie_grab")
	EventBus.zombie_woke.emit(rigs[0].zombie)
	manager.update_mix()
	assert_false(manager._bed.playing, "late wake cannot restart after death")
	EventBus.checkpoint_loaded.emit(&"ch3_stadium")
	assert_false(manager._bed.playing)
	manager.stop_emitting()
	EventBus.zombie_woke.emit(rigs[0].zombie)
	manager.update_mix()
	assert_eq(manager.audible_count(), 0)


func test_zombie_steps_door_hits_sleep_and_unregistration() -> void:
	var listener := Node3D.new()
	_add(listener)
	var manager := Ch3HordeAudio.new()
	manager.listener = listener
	_add(manager)
	var actor := Node3D.new()
	_add(actor)
	var rig := ZombieAudio.new()
	actor.add_child(rig)
	manager.register(rig)
	rig.play_step()
	assert_false(rig._foley.playing)
	EventBus.zombie_woke.emit(actor)
	manager.update_mix()
	rig.play_step()
	assert_eq(rig._foley.bus, &"Footsteps")
	var previous := rig._foley.stream
	rig.play_step()
	assert_true(rig._foley.stream != previous)
	rig.play_door_hit()
	assert_eq(rig._foley.bus, &"SFX")
	assert_eq(rig._foley.stream, Ch3AudioBank.clip("door_pound_01"))
	manager.unregister(rig)
	assert_false(rig._voice.playing)
	assert_false(rig._foley.playing)
	assert_false(manager._bed.playing)


func test_stamina_drives_pant_cadence_gain_exhaustion_heart_and_recovery() -> void:
	var player := Ch3PlayerAudio.new()
	_add(player)
	player.set_process(false)
	EventBus.stamina_changed.emit(0.8, false)
	player._process(0.01)
	assert_true(player._pant.playing)
	var interval := player.pant_interval()
	var gain := player._pant.volume_db
	EventBus.stamina_changed.emit(0.2, false)
	assert_true(player.pant_interval() < interval)
	assert_true(player._pant.volume_db > gain)
	assert_false(player._heart.playing)
	EventBus.stamina_changed.emit(0.0, true)
	player._process(1.1)
	assert_true(player._heart.playing)
	assert_eq(player.pant_interval(), 1.05)
	EventBus.stamina_changed.emit(1.0, false)
	assert_false(player._heart.playing)
	assert_false(player._pant.playing)
	EventBus.stamina_changed.emit(NAN, true)
	assert_false(player.exhausted)
	EventBus.player_death_started.emit(&"zombie_grab")
	EventBus.stamina_changed.emit(0.0, true)
	player._process(2.0)
	assert_false(player._pant.playing)
	EventBus.checkpoint_loaded.emit(&"ch3_garden")
	EventBus.stamina_changed.emit(0.0, true)
	player.set_process(true)
	tree.paused = true
	var remaining := player._until_pant
	await wait_frames(3)
	assert_eq(player._until_pant, remaining)
	tree.paused = false


func test_bar_hit_miss_bend_break_pick_and_no_gameplay_noise() -> void:
	var player := Ch3PlayerAudio.new()
	_add(player)
	var noises: Array[StringName] = []
	var on_noise := func(_p: Vector3, _r: float, source: StringName) -> void: noises.append(source)
	EventBus.noise_emitted.connect(on_noise)
	EventBus.bar_swung.emit(false, 2)
	assert_eq(player._swing.stream, Ch3AudioBank.clip("bar_swing"))
	assert_eq(player._impact.stream, Ch3AudioBank.clip("bar_miss"))
	assert_false(player._metal.playing)
	EventBus.bar_swung.emit(true, 2)
	assert_eq(player._impact.stream, Ch3AudioBank.clip("bar_hit"))
	assert_eq(player._metal.stream, Ch3AudioBank.clip("bar_bend"))
	EventBus.bar_broken.emit()
	assert_eq(player._metal.stream, Ch3AudioBank.clip("bar_break"))
	EventBus.bar_picked.emit(8)
	assert_false(player._metal.playing)
	EventBus.stamina_changed.emit(0.0, true)
	player._process(2)
	assert_true(noises.is_empty(), "audio never attracts zombies a second time")
	EventBus.noise_emitted.disconnect(on_noise)


func test_siren_requires_high_marker_stillness_and_enabled_lifecycle() -> void:
	var listener := Node3D.new()
	_add(listener)
	var marker := Marker3D.new()
	marker.position = Vector3(10, 8, -4)
	_add(marker)
	var siren := Ch3SirenAudio.new()
	siren.listener = listener
	siren.high_spot = marker
	_add(siren)
	siren.set_process(false)
	siren.set_enabled(true)
	listener.position = Vector3(10, 0, -4)
	siren._process(0.1)
	siren._process(0.1)
	assert_false(siren._player.playing, "same xz below stands remains silent")
	listener.position = marker.position
	siren._process(0.1)
	assert_false(siren._player.playing, "arriving still moving")
	siren._process(0.1)
	assert_true(siren._player.playing)
	assert_eq(siren._player.stream, Ch3AudioBank.clip("rescue_siren"))
	listener.position.x += 0.1
	siren._process(0.1)
	assert_false(siren._player.playing, "walking at high spot remains silent")
	listener.position.x += 10
	siren._process(0.1)
	siren._process(0.1)
	assert_false(siren._player.playing, "high elsewhere remains silent")
	listener.position = marker.position
	siren._process(0.1)
	siren._process(0.1)
	EventBus.player_death_started.emit(&"guard_shock")
	assert_false(siren.enabled)
	assert_false(siren._player.playing)
	siren.stop_emitting()
	siren.set_enabled(true)
	assert_false(siren.enabled)


func test_environment_profiles_insects_screams_and_restore() -> void:
	var insects := AmbientEmitter.new()
	insects.stream = load("res://audio/ambience/night_insects_motorbike.ogg")
	_add(insects)
	var environment := Ch3Environment.new()
	environment.insect_emitters.append(insects)
	_add(environment)
	for position_value in [Vector3(25, 0, 0), Vector3(-25, 0, 0)]:
		var point := Marker3D.new()
		point.position = position_value
		_add(point)
		environment.scream_points.append(point)
	for area in [&"stadium", &"canteen", &"stairs", &"garden"]:
		environment.set_area(area)
		assert_false(insects.playing)
		assert_eq(environment._bed.stream, Ch3AudioBank.clip("wind" if area == &"garden" else String(area)))
		environment.play_far_scream()
		assert_eq(environment._scream.playing, area in [&"stadium", &"garden"])
	environment.play_far_scream()
	var last_position := environment._scream.global_position
	environment.play_far_scream()
	assert_true(environment._scream.global_position != last_position)
	EventBus.player_death_started.emit(&"zombie_grab")
	environment._process(1.0)
	assert_false(insects.playing, "death in chapter 3 does not bring insects back")
	EventBus.checkpoint_loaded.emit(&"ch3_garden")
	environment._process(1.0)
	assert_false(insects.playing, "checkpoint in chapter 3 does not bring insects back")
	EventBus.chapter_finished.emit(3)
	assert_false(environment._bed.playing)
	assert_false(environment._scream.playing)
	assert_true(insects.playing, "restore prior emitter when leaving chapter")


func test_guard_identity_warning_off_and_checkpoint() -> void:
	var actor := Node3D.new()
	_add(actor)
	var other := Node3D.new()
	_add(other)
	var guard := Ch3GuardAudio.new()
	actor.add_child(guard)
	EventBus.guard_warned.emit(other, true)
	assert_false(guard._player.playing)
	EventBus.guard_warned.emit(actor, true)
	assert_true(guard._player.playing)
	var playback := guard._player.get_stream_playback()
	EventBus.guard_warned.emit(actor, true)
	assert_eq(guard._player.get_stream_playback(), playback)
	EventBus.guard_warned.emit(actor, false)
	assert_false(guard._player.playing)
	EventBus.guard_warned.emit(actor, true)
	EventBus.checkpoint_loaded.emit(&"ch3_gate")
	assert_false(guard._player.playing)
	EventBus.player_death_started.emit(&"guard_shock")
	EventBus.guard_warned.emit(actor, true)
	assert_false(guard._player.playing)


func test_ch3_death_signal_order_once_and_reduced_live() -> void:
	var player := Ch1PlayerAudio.new()
	_add(player)
	for kind in [&"zombie_grab", &"guard_shock"]:
		_settings(false)
		EventBus.checkpoint_loaded.emit(&"ch3_b")
		EventBus.player_caught.emit(&"zombie" if kind == &"zombie_grab" else &"guard")
		assert_false(player._foley.playing, "no legacy manager kill before detail")
		EventBus.player_death_started.emit(kind)
		assert_eq(player._death.stream, Ch3AudioBank.clip("death_" + String(kind)))
		var playback := player._death.get_stream_playback()
		EventBus.player_death_started.emit(kind)
		assert_eq(player._death.get_stream_playback(), playback)
		EventBus.player_caught.emit(&"zombie")
		assert_false(player._foley.playing)
		_settings(true)
		assert_eq(player._death.stream, Ch3AudioBank.clip("death_zombie_soft" if kind == &"zombie_grab" else "death_guard_soft"))
	EventBus.checkpoint_loaded.emit(&"ch3_gate")
	player.chapter3_directory = ""
	EventBus.player_death_started.emit(&"guard_shock")
	assert_false(player._death.playing)


func test_music_run_wave_canteen_latch_ending_once_and_death() -> void:
	var music := Ch3Music.new()
	_add(music)
	music.set_process(false)
	music.set_area(&"road")
	music.set_running(true)
	music._process(1.5)
	assert_true(music._beds[0].playing)
	music.set_area(&"stadium")
	music.set_wave(true)
	music._process(1.5)
	assert_false(music._beds[0].playing)
	assert_true(music._beds[1].playing)
	music.set_area(&"canteen")
	music.set_running(true)
	music.set_wave(true)
	music._process(2)
	assert_false(music._beds[0].playing)
	assert_false(music._beds[1].playing)
	EventBus.chapter_finished.emit(2)
	assert_false(music._end.playing)
	EventBus.chapter_finished.emit(3)
	assert_true(music._end.playing)
	var playback := music._end.get_stream_playback()
	EventBus.chapter_finished.emit(3)
	assert_eq(music._end.get_stream_playback(), playback)
	music.set_area(&"road")
	music._process(2)
	assert_false(music._beds[0].playing)
	EventBus.player_death_started.emit(&"zombie_grab")
	assert_false(music._end.playing)
	music.set_area(&"stadium")
	music.set_wave(true)
	music._process(2)
	assert_false(music._beds[1].playing)


func test_grass_concrete_running_steps_no_repeat_and_footsteps_bus() -> void:
	var player := FootstepPlayer.new()
	_add(player)
	for surface in [&"grass", &"concrete"]:
		var seen: Array[AudioStream] = []
		var previous: AudioStream
		for index in 64:
			player.play_footstep(surface, 1.0)
			assert_true(player.stream != previous)
			assert_true(player.stream.resource_path.contains("run_" + String(surface)))
			if not seen.has(player.stream):
				seen.append(player.stream)
			previous = player.stream
		assert_eq(seen.size(), 4)
		assert_eq(player.bus, &"Footsteps")


func test_ch3_audition_all_clips_reset_and_no_audio_bus_leak() -> void:
	var packed := load("res://audio/test/ch3_audio_test.tscn") as PackedScene
	assert_not_null(packed)
	var fixture := packed.instantiate()
	_add(fixture)
	for index in Ch3AudioBank.NAMES.size():
		fixture.audition(index)
		assert_true(fixture.preview.playing)
		assert_eq(fixture.preview.stream, Ch3AudioBank.clip(Ch3AudioBank.NAMES[index]))
	fixture.reset_preview()
	assert_false(fixture.preview.playing)
	assert_eq(fixture.horde.audible_count(), 0)


func test_ch3_reverb_presets_restore_shared_sfx_bus() -> void:
	var index := AudioServer.get_bus_index(&"SFX")
	var effect := AudioServer.get_bus_effect(index, 0) as AudioEffectReverb
	var baseline := Vector3(effect.room_size, effect.damping, effect.wet)
	for preset in [ReverbZone.Preset.STADIUM, ReverbZone.Preset.CANTEEN, ReverbZone.Preset.STAIRS]:
		var zone := ReverbZone.new()
		zone.preset = preset
		zone.fade_time = 0
		tree.root.add_child(zone)
		zone.occupied = true
		zone._on_occupancy_changed(true)
		var target := ReverbZone.PRESETS[preset]
		assert_true(is_equal_approx(effect.room_size, target.x))
		assert_true(is_equal_approx(effect.wet, target.z))
		zone.free()
		assert_true(is_equal_approx(effect.wet, baseline.z))


func test_missing_banks_stay_silent_and_stopped_rigs_cannot_restart() -> void:
	var player := Ch3PlayerAudio.new()
	player.sound_directory = ""
	_add(player)
	EventBus.stamina_changed.emit(0.2, false)
	player._process(2.0)
	EventBus.bar_swung.emit(true, 2)
	assert_false(player._pant.playing)
	assert_false(player._swing.playing)
	player.stop_emitting()
	player.sound_directory = Ch3AudioBank.DIRECTORY
	EventBus.checkpoint_loaded.emit(&"ch3_b")
	EventBus.bar_broken.emit()
	assert_false(player._metal.playing)
	var music := Ch3Music.new()
	music.sound_directory = ""
	_add(music)
	music.set_area(&"stadium")
	music.set_wave(true)
	music._process(2.0)
	assert_false(music._beds[1].playing)
	music.stop_emitting()
	music.sound_directory = Ch3AudioBank.DIRECTORY
	EventBus.chapter_finished.emit(3)
	assert_false(music._end.playing)
