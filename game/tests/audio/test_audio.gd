extends TestCase

const AMBIENCE := ["ceiling_fan", "fluorescent_hum", "night_insects_motorbike"]
const SFX := ["water_drip_01", "water_drip_02", "water_drip_03", "slipper_tile_01", "slipper_tile_02", "slipper_tile_03", "slipper_tile_04", "wood_door_open", "wood_door_close", "fluorescent_flicker"]


func test_all_ogg_load_and_decode_with_correct_loop_flags() -> void:
	var expected: Array[String] = []
	for category in ["ambience", "sfx"]:
		var names: Array = AMBIENCE if category == "ambience" else SFX
		for clip_name in names:
			var path: String = "res://audio/%s/%s.ogg" % [category, clip_name]
			expected.append(path)
			var clip := load(path) as AudioStreamOggVorbis
			assert_not_null(clip, path)
			if clip == null:
				continue
			assert_true(clip.get_length() > 0.4, "nonempty " + path)
			assert_eq(clip.loop, category == "ambience", "loop " + path)
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
	assert_eq(AudioServer.bus_count, 5, "bus count;")
	for bus_name in [&"Master", &"Ambience", &"SFX", &"Voice", &"Music"]:
		var index := AudioServer.get_bus_index(bus_name)
		assert_true(index >= 0, "bus " + bus_name)
		if index > 0:
			assert_eq(AudioServer.get_bus_send(index), &"Master", "send;")
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
		assert_true(player.pitch_scale >= 0.94 and player.pitch_scale <= 1.06, "pitch bounded")
		assert_true(absf(player.volume_db) <= 1.0, "volume bounded")
		if not seen.has(player.stream):
			seen.append(player.stream)
		previous = player.stream
	assert_eq(seen.size(), 4, "all variants used;")
	assert_eq(player.bus, &"SFX", "step bus;")
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
