extends TestCase

const AMBIENCE := ["ceiling_fan", "fluorescent_hum", "night_insects_motorbike", "speaker_static", "breath_close"]
const SFX := ["water_drip_01", "water_drip_02", "water_drip_03", "slipper_tile_01", "slipper_tile_02", "slipper_tile_03", "slipper_tile_04", "slipper_run_01", "slipper_run_02", "slipper_run_03", "slipper_run_04", "wood_door_open", "wood_door_close", "fluorescent_flicker", "knock_01", "knock_02", "knock_03", "speaker_chime", "speaker_on", "speaker_off", "speaker_static_burst", "phone_vibrate", "light_switch", "door_latch"]


func test_all_ogg_load_and_decode_with_correct_loop_flags() -> void:
	var expected: Array[String] = []
	for category in ["ambience", "sfx"]:
		var names: Array = AMBIENCE if category == "ambience" else SFX + ["sting_low", "sting_hit", "slipper_place", "tube_cut", "slipper_rush_01", "slipper_rush_02", "slipper_rush_03", "slipper_rush_04", "whisper_co", "net_billow"]
		for clip_name in names:
			var path: String = "res://audio/%s/%s.ogg" % [category, clip_name]
			expected.append(path)
			var clip := load(path) as AudioStreamOggVorbis
			assert_not_null(clip, path)
			if clip == null:
				continue
			assert_true(clip.get_length() > 0.4, "nonempty " + path)
			assert_eq(clip.loop, category == "ambience" or clip_name == "phone_vibrate", "loop " + path)
			var playback := clip.instantiate_playback()
			playback.start()
			var frames := playback.mix_audio(1.0, 4096)
			var peak: float = 0.0
			for frame in frames:
				peak = maxf(peak, absf(frame.x))
			assert_true(peak > 0.00001, "decoded signal " + path)
			playback.stop()
	var actual := _find_ogg("res://audio")
	actual.sort()
	expected.sort()
	assert_eq(actual, expected, "all OGG files covered;")


func test_bus_layout_is_loaded_and_routed() -> void:
	assert_not_null(load("res://default_bus_layout.tres"), "layout resource")
	assert_eq(AudioServer.bus_count, 6, "bus count;")
	for bus_name in [&"Master", &"Ambience", &"SFX", &"Voice", &"Music", &"Footsteps"]:
		var index := AudioServer.get_bus_index(bus_name)
		assert_true(index >= 0, "bus " + bus_name)
		if index > 0:
			var expected_send: StringName = &"SFX" if bus_name == &"Footsteps" else &"Master"
			assert_eq(AudioServer.get_bus_send(index), expected_send, "send " + bus_name + ";")
	var footsteps := AudioServer.get_bus_index(&"Footsteps")
	if footsteps >= 0:
		assert_eq(AudioServer.get_bus_volume_db(footsteps), 0.0, "footsteps default gain;")
		assert_false(AudioServer.is_bus_mute(footsteps), "footsteps unmuted by default")
		assert_eq(AudioServer.get_bus_effect_count(footsteps), 0, "reverb stays on parent SFX bus;")
	var sfx := AudioServer.get_bus_index(&"SFX")
	if sfx >= 0:
		assert_eq(AudioServer.get_bus_effect_count(sfx), 1, "SFX reverb count;")
		if AudioServer.get_bus_effect_count(sfx) > 0:
			assert_true(AudioServer.get_bus_effect(sfx, 0) is AudioEffectReverb, "SFX retains reverb for footsteps")
			assert_true(AudioServer.is_bus_effect_enabled(sfx, 0), "SFX reverb enabled")
	var ambience := AudioServer.get_bus_index(&"Ambience")
	if ambience >= 0:
		assert_eq(AudioServer.get_bus_effect_count(ambience), 1, "reverb count;")
		var effect := AudioServer.get_bus_effect(ambience, 0) as AudioEffectReverb
		assert_not_null(effect, "ambience reverb")
		if effect != null:
			assert_true(effect.wet > 0 and effect.wet <= 0.2, "subtle reverb")


func test_footsteps_do_not_repeat_and_cover_all_variants() -> void:
	var player := FootstepPlayer.new()
	tree.root.add_child(player)
	player._rng.seed = 105
	var previous: AudioStream
	var seen: Array[AudioStream] = []
	for index in 128:
		player.play_footstep(&"tile")
		assert_not_null(player.stream, "step clip")
		assert_true(player.stream != previous, "consecutive step %d" % index)
		assert_true(player.pitch_scale >= 0.96 and player.pitch_scale <= 1.04, "pitch bounded")
		assert_true(absf(player.volume_db) <= 1.5, "volume bounded at default intensity")
		if not seen.has(player.stream):
			seen.append(player.stream)
		previous = player.stream
	assert_eq(seen.size(), 4, "all variants used;")
	assert_eq(player.bus, &"Footsteps", "step bus;")
	assert_true(player.playing, "step playback active on Footsteps")
	player.free()


func test_footstep_empty_unknown_and_duplicate_banks() -> void:
	var player := FootstepPlayer.new()
	tree.root.add_child(player)
	player.play_footstep(&"unknown")
	assert_eq(player.stream, null, "unsupported surface;")
	var clip: AudioStream = player.tile_variants[0]
	player.tile_variants.clear()
	player.play_footstep(&"tile")
	assert_eq(player.stream, null, "empty bank;")
	player.tile_variants.assign([null, clip, clip])
	player.play_footstep(&"tile")
	assert_eq(player.stream, clip, "single usable clip;")
	player.stop()
	player.play_footstep(&"tile")
	assert_false(player.playing, "single variant must not repeat")
	player.free()


func test_ambient_loop_does_not_modify_shared_stream() -> void:
	var original := load("res://audio/sfx/water_drip_01.ogg") as AudioStreamOggVorbis
	var emitter := AmbientEmitter.new()
	emitter.stream = original
	tree.root.add_child(emitter)
	assert_true(emitter.playing, "loop starts")
	assert_true(emitter.stream != original, "private stream")
	assert_true((emitter.stream as AudioStreamOggVorbis).loop, "loop enabled")
	assert_false(original.loop, "shared flag untouched")
	emitter.stop_emitting()
	assert_false(emitter.playing, "stop loop")
	assert_true(emitter._timer.is_stopped(), "stop timer")
	emitter.free()


func test_ambient_random_interval_lifecycle() -> void:
	var original := load("res://audio/ambience/ceiling_fan.ogg") as AudioStreamOggVorbis
	var emitter := AmbientEmitter.new()
	emitter.playback_mode = AmbientEmitter.PlaybackMode.RANDOM_INTERVAL
	emitter.stream = original
	emitter.interval_min = 0.06
	emitter.interval_max = 0.05
	tree.root.add_child(emitter)
	assert_false(emitter.playing, "wait before first random clip")
	assert_true(emitter._timer.time_left > 0, "first clip scheduled")
	await tree.create_timer(0.12).timeout
	assert_true(emitter.playing, "timer starts clip")
	assert_false((emitter.stream as AudioStreamOggVorbis).loop, "random clip is one-shot")
	assert_true(original.loop, "shared loop preserved")
	emitter.stop()
	emitter.finished.emit()
	assert_true(emitter._timer.time_left > 0, "next interval scheduled after finish")
	emitter.stop_emitting()
	await tree.create_timer(0.12).timeout
	assert_false(emitter.playing, "stopped emitter stays stopped")
	emitter.free()


func test_audio_room_loads_and_starts_sources() -> void:
	var scene := load("res://audio/test/audio_test.tscn") as PackedScene
	assert_not_null(scene, "listening room")
	if scene == null:
		return
	var room := scene.instantiate()
	tree.root.add_child(room)
	await wait_frames(2)
	for source_name in ["Fan", "Hum", "Night"]:
		var source := room.get_node(source_name) as AudioStreamPlayer3D
		assert_true(source.playing, source_name + " starts")
		assert_eq(source.bus, &"Ambience", source_name + " bus;")
	assert_eq((room.get_node("Footsteps") as AudioStreamPlayer3D).bus, &"Footsteps", "scene step bus;")
	assert_true((room.get_node("Camera3D") as Camera3D).current, "listener camera")
	room.free()


func _find_ogg(path: String) -> Array[String]:
	var found: Array[String] = []
	for file in DirAccess.get_files_at(path):
		if file.ends_with(".ogg"):
			found.append(path.path_join(file))
	for directory in DirAccess.get_directories_at(path):
		found.append_array(_find_ogg(path.path_join(directory)))
	return found


func test_footstep_intensity_selects_bank_without_repeats() -> void:
	var player := FootstepPlayer.new()
	tree.root.add_child(player)
	player._rng.seed = 123
	for case: Array in [[0.2, player.tile_variants], [0.6, player.tile_variants], [1.0, player.tile_run_variants]]:
		var intensity: float = case[0]
		var bank: Array[AudioStream] = case[1]
		var seen: Array[AudioStream] = []
		var previous: AudioStream
		for index in 64:
			player.play_footstep(&"tile", intensity)
			assert_true(bank.has(player.stream), "intensity %.1f uses expected bank" % intensity)
			assert_true(player.stream != previous, "no consecutive repeat at %.1f" % intensity)
			if not seen.has(player.stream):
				seen.append(player.stream)
			previous = player.stream
		assert_eq(seen.size(), 4, "all variants used at %.1f;" % intensity)
		assert_eq(player.bus, &"Footsteps", "walk/run step bus;")
	player.free()


func test_footstep_louder_when_running() -> void:
	var player := FootstepPlayer.new()
	tree.root.add_child(player)
	player.volume_variation_db = 0.0
	player.play_footstep(&"tile", 0.0)
	var soft := player.volume_db
	player.play_footstep(&"tile", 1.0)
	assert_true(player.volume_db > soft, "running gain above slow walk")
	player.play_footstep(&"tile", 5.0)
	assert_eq(player.volume_db, 3.0, "intensity clamps to 1;")
	player.free()


func test_walk_bank_quieter_than_run_bank() -> void:
	var report: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://../audio_source/build_report.json"))
	assert_not_null(report, "build report readable")
	if report == null:
		return
	var walk: Array[float] = []
	var run: Array[float] = []
	for entry: Dictionary in report["assets"]:
		var file: String = entry["file"]
		if file.contains("slipper_tile_"):
			walk.append(entry["lufs"])
		elif file.contains("slipper_run_"):
			run.append(entry["lufs"])
	assert_eq(walk.size(), 4, "walk entries;")
	assert_eq(run.size(), 4, "run entries;")
	assert_true(walk.max() < run.min(), "walk bank quieter than run bank")
	assert_true(walk.max() < -24.0, "walking clearly below door SFX (-18 LUFS)")
