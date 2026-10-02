extends TestCase

var _fixture: Node3D


func before_each() -> void:
	_fixture = Node3D.new()
	tree.root.add_child(_fixture)


func after_each() -> void:
	_fixture.free()
	# Let the audio mixer consume the stop commands before ending the runner.
	await tree.create_timer(0.08).timeout


func test_hum_small_speaker_report_matches_asset() -> void:
	var report_path := ProjectSettings.globalize_path("res://").path_join("../audio_source/build_report.json")
	var report: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(report_path))
	var found: bool = false
	for entry: Dictionary in report.get("assets", []):
		if entry.get("file") != "game/audio/ambience/fluorescent_hum.ogg":
			continue
		found = true
		assert_true(entry.has("highpass_200hz_lufs"), "HP200 measured")
		assert_true(is_finite(float(entry.get("highpass_200hz_lufs", INF))), "finite HP200 loudness")
		assert_true(float(entry.get("highpass_200hz_loss_lu", INF)) <= 10.0, "small-speaker loss <=10 LU")
		# Owner-chosen level (D-016), quieter than the -24 LUFS ambience default.
		assert_true(absf(float(entry["lufs"]) + 32.0) <= 1.0, "hum at -32 LUFS")
		assert_true(float(entry["boundary_delta"]) <= 0.02, "loop seam threshold")
		assert_eq(entry["sha256"], FileAccess.get_sha256("res://audio/ambience/fluorescent_hum.ogg"), "measurement matches OGG;")
	assert_true(found, "hum measurement in report")
	var hum := load("res://audio/ambience/fluorescent_hum.ogg") as AudioStreamOggVorbis
	assert_true(hum != null and hum.loop, "hum imports as loop")
	var flicker := load("res://audio/sfx/fluorescent_flicker.ogg") as AudioStreamOggVorbis
	assert_true(flicker != null and not flicker.loop, "flicker one-shot")
	assert_true(flicker.get_length() >= 1.0 and flicker.get_length() <= 2.0, "flicker duration")


func test_ambient_zone_physics_entry_exit_and_reverse_fade() -> void:
	var emitter := _emitter()
	var zone := _ambient_zone(emitter)
	var player := _body(Vector3(10, 0, 0))
	await _settle()
	assert_true(emitter.volume_linear < 0.0001, "outside is silent")
	player.position = Vector3.ZERO
	await _settle()
	var rising := emitter.volume_linear
	assert_true(rising > 0.0, "entry raises volume")
	player.position.x = 10
	await _settle()
	var falling := emitter.volume_linear
	await tree.create_timer(0.1).timeout
	assert_true(emitter.volume_linear < falling, "exit reverses an unfinished fade")
	await tree.create_timer(0.25).timeout
	assert_true(emitter.volume_linear < 0.0001, "exit finishes at silence")
	player.position.x = 0
	await _settle()
	await tree.create_timer(0.4).timeout
	assert_true(is_equal_approx(emitter.volume_linear, 1.0), "returns to configured gain")
	assert_true(zone.occupied, "player detected")


func test_shared_emitter_overlap_and_restart_preserve_gain() -> void:
	var emitter := _emitter()
	var first := _ambient_zone(emitter, Vector3(-1, 0, 0))
	var second := _ambient_zone(emitter, Vector3(1, 0, 0))
	first.fade_time = 0.05
	second.fade_time = 0.05
	var player := _body(Vector3.ZERO)
	await _settle()
	await tree.create_timer(0.15).timeout
	assert_true(first.occupied and second.occupied, "overlap detected")
	assert_true(is_equal_approx(emitter.volume_linear, 1.0), "overlap does not add gain")
	player.position.x = 2.5
	await _settle()
	await tree.create_timer(0.15).timeout
	assert_false(first.occupied, "left first zone")
	assert_true(second.occupied, "still in second zone")
	assert_true(is_equal_approx(emitter.volume_linear, 1.0), "leaving one zone does not mute another")
	player.position.x = 10
	await _settle()
	await tree.create_timer(0.15).timeout
	emitter.stop_emitting()
	emitter.start_emitting()
	assert_true(emitter.volume_linear < 0.0001, "new clip does not overwrite zone mute")


func test_zone_ignores_other_layers_and_tracks_multiple_bodies() -> void:
	var emitter := _emitter()
	var zone := _ambient_zone(emitter)
	zone.fade_time = 0.0
	_body(Vector3.ZERO, 1)
	await _settle()
	assert_false(zone.occupied, "world layer ignored")
	var first := _body(Vector3.ZERO)
	var second := _body(Vector3.ZERO)
	await _settle()
	first.free()
	assert_true(zone.occupied, "second player keeps zone occupied")
	second.free()
	assert_false(zone.occupied, "removed bodies release occupancy")
	assert_true(emitter.volume_linear < 0.0001, "removed last player mutes")
	zone.free()
	assert_true(is_equal_approx(emitter.volume_linear, 1.0), "deleted last zone restores independent emitter")


func test_reverb_overlap_priority_exit_and_scene_cleanup() -> void:
	var effect := _sfx_reverb()
	assert_not_null(effect, "SFX reverb exists")
	if effect == null:
		return
	var original := Vector3(effect.room_size, effect.damping, effect.wet)
	var room := _reverb_zone(Vector3(-1, 0, 0), ReverbZone.Preset.ROOM)
	var bath := _reverb_zone(Vector3(1, 0, 0), ReverbZone.Preset.BATHROOM)
	bath.mix_priority = 10
	var player := _body(Vector3(-2.5, 0, 0))
	await _settle()
	await tree.create_timer(0.15).timeout
	assert_true(is_equal_approx(effect.wet, 0.12), "room applied")
	player.position.x = 0
	await _settle()
	await tree.create_timer(0.15).timeout
	assert_true(is_equal_approx(effect.wet, 0.32), "priority bathroom wins overlap")
	player.position.x = -2.5
	await _settle()
	await tree.create_timer(0.15).timeout
	assert_true(is_equal_approx(effect.wet, 0.12), "exiting bathroom returns to occupied room")
	player.position.x = -10
	await _settle()
	await tree.create_timer(0.15).timeout
	assert_true(Vector3(effect.room_size, effect.damping, effect.wet).is_equal_approx(original), "leaving all restores baseline")
	player.position.x = 0
	await _settle()
	room.free()
	bath.free()
	assert_true(Vector3(effect.room_size, effect.damping, effect.wet).is_equal_approx(original), "unload restores baseline even mid-fade")


func test_light_visibility_energy_and_flicker_lifecycle() -> void:
	var light := OmniLight3D.new()
	_fixture.add_child(light)
	var hum := LightHum.new()
	hum.light = light
	_fixture.add_child(hum)
	assert_true(hum.playing, "lit lamp hums")
	light.visible = false
	assert_false(hum.playing, "hide stops immediately")
	light.visible = true
	assert_true(hum.playing, "show restarts")
	light.light_energy = 0.0001
	await wait_frames(2)
	assert_false(hum.playing, "near-zero energy stops")
	light.light_energy = 1.0
	await wait_frames(2)
	assert_true(hum.playing, "energy restored")
	hum.flicker(0.3)
	assert_false(hum.playing, "flicker interrupts steady hum")
	assert_true(hum._flicker_player.playing, "flicker one-shot plays")
	await tree.create_timer(0.45).timeout
	assert_true(hum.playing, "steady hum resumes after duration")
	assert_false(hum._flicker_player.playing, "one-shot stops at duration")
	hum.flicker(1.5)
	light.visible = false
	assert_false(hum.playing or hum._flicker_player.playing, "light off silences both sources immediately")
	light.free()
	await wait_frames(2)
	assert_false(hum.playing, "missing light stays silent")


func test_light_hum_respects_zone_when_restarted_and_flickering() -> void:
	var light := OmniLight3D.new()
	_fixture.add_child(light)
	var hum := LightHum.new()
	hum.light = light
	_fixture.add_child(hum)
	_ambient_zone(hum)
	light.visible = false
	light.visible = true
	hum.flicker(0.3)
	await wait_frames(2)
	assert_true(hum.volume_linear < 0.0001, "zone mute survives light restart")
	assert_true(hum._flicker_player.volume_linear < 0.0001, "flicker respects zone gain")
	_fixture.visible = false
	await wait_frames(2)
	assert_false(hum.playing or hum._flicker_player.playing, "hidden ancestor silences hum")


func test_zones_scene_player_traversal_and_keys() -> void:
	var scene := load("res://audio/test/zones_test.tscn") as PackedScene
	var level := scene.instantiate()
	_fixture.add_child(level)
	var player := level.get_node("Player") as CharacterBody3D
	player.set_physics_process(false)
	for name in ["RoomAmbience", "CorridorAmbience", "BathroomAmbience", "RoomReverb", "CorridorReverb", "BathroomReverb"]:
		level.get_node(name).set("fade_time", 0.05)
	for step in [[8.0, "RoomAmbience", "Hum"], [0.0, "CorridorAmbience", "Night"], [-7.0, "BathroomAmbience", "Drips"]]:
		player.position = Vector3(0, 0.05, float(step[0]))
		await _settle()
		await tree.create_timer(0.15).timeout
		assert_true(level.get_node(step[1]).occupied, "actual Player enters " + step[1])
		assert_true(level.get_node(step[2]).volume_linear > 0.01, "source enabled " + step[2])
	var key := InputEventKey.new()
	key.pressed = true
	key.physical_keycode = KEY_L
	level._unhandled_key_input(key)
	assert_false(level.get_node("Hum").playing, "L switches hum off")
	level._unhandled_key_input(key)
	key.physical_keycode = KEY_F
	level._unhandled_key_input(key)
	assert_true(level.get_node("Hum")._flicker_player.playing, "F starts flicker")
	assert_true(player.footstep.is_connected(level.get_node("Player/Footsteps").play_footstep), "step signal wired in fixture")


func _emitter() -> AmbientEmitter:
	var emitter := AmbientEmitter.new()
	emitter.name = "Emitter"
	emitter.stream = load("res://audio/ambience/fluorescent_hum.ogg")
	emitter.volume_variation_db = 0.0
	_fixture.add_child(emitter)
	return emitter


func _ambient_zone(emitter: AmbientEmitter, position: Vector3 = Vector3.ZERO) -> AmbientZone:
	var zone := AmbientZone.new()
	zone.position = position
	zone.fade_time = 0.3
	zone.emitters.assign([NodePath("../" + String(emitter.name))])
	_shape(zone)
	_fixture.add_child(zone)
	return zone


func _reverb_zone(position: Vector3, preset: ReverbZone.Preset) -> ReverbZone:
	var zone := ReverbZone.new()
	zone.position = position
	zone.preset = preset
	zone.fade_time = 0.05
	_shape(zone)
	_fixture.add_child(zone)
	return zone


func _shape(zone: Area3D) -> void:
	var collision := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(4, 4, 4)
	collision.shape = box
	zone.add_child(collision)


func _body(position: Vector3, layer: int = 2) -> CharacterBody3D:
	var body := CharacterBody3D.new()
	body.collision_layer = layer
	body.collision_mask = 0
	body.position = position
	var collision := CollisionShape3D.new()
	var sphere := SphereShape3D.new()
	sphere.radius = 0.1
	collision.shape = sphere
	body.add_child(collision)
	_fixture.add_child(body)
	return body


func _sfx_reverb() -> AudioEffectReverb:
	var index := AudioServer.get_bus_index(&"SFX")
	if index < 0 or AudioServer.get_bus_effect_count(index) == 0:
		return null
	return AudioServer.get_bus_effect(index, 0) as AudioEffectReverb


func _settle() -> void:
	for frame in 4:
		await tree.physics_frame
	await tree.process_frame
