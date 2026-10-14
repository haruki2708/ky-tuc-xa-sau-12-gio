extends TestCase
## T-218: room 407 sound sources sit on the furnished (G3) fan, tube, shower and mirror.

const ROOM := "res://scenes/levels/floor4/room_407.tscn"
## Largest gap (m) between a source and the centre of its fixture (the fan hub, the tube).
const REACH := 0.1
var _nodes: Array[Node] = []


func after_each() -> void:
	tree.paused = false
	for node in _nodes:
		if is_instance_valid(node):
			node.free()
	_nodes.clear()
	# Let the audio mixer consume the stop commands before the next test.
	await tree.create_timer(0.08).timeout


func _add(node: Node) -> void:
	_nodes.append(node)
	tree.root.add_child(node)


func _room() -> Node3D:
	var room := (load(ROOM) as PackedScene).instantiate() as Node3D
	_add(room)
	return room


## Director side of the shower rig: ShowerAudio under the room's ShowerStall.
func _shower(room: Node3D) -> ShowerAudio:
	var shower := ShowerAudio.new()
	room.get_node("Anchors/ShowerStall").add_child(shower)
	return shower


func _bounds(root: Node3D) -> AABB:
	var result := AABB()
	var first := true
	for mesh: MeshInstance3D in root.find_children("*", "MeshInstance3D", true, false):
		var box: AABB = mesh.global_transform * mesh.get_aabb()
		result = box if first else result.merge(box)
		first = false
	assert_false(first, "%s has meshes" % root.name)
	return result


func _near(source: Vector3, fixture: AABB, slack: float) -> bool:
	return fixture.grow(slack).has_point(source)


func test_fan_hum_sit_on_the_furnished_fan_and_tube() -> void:
	var room := _room()
	await wait_frames(2)
	var fan := room.get_node("Furnished/TripoProps/CeilingFan") as Node3D
	var rotor := fan.find_child("fan_rotor", true, false) as Node3D
	var source := room.get_node("FanAmbience") as AudioStreamPlayer3D
	assert_true(source.global_position.distance_to(rotor.global_position) <= REACH, "fan sound at the rotor")
	assert_true(_near(source.global_position, _bounds(fan), 0.1), "fan sound within the fan model")
	var tubes := room.get_node("Furnished/fixtures") as Node3D
	var tube_box := AABB()
	var first := true
	for mesh: MeshInstance3D in tubes.find_children("FluorescentTube*", "MeshInstance3D", true, false):
		var box: AABB = mesh.global_transform * mesh.get_aabb()
		tube_box = box if first else tube_box.merge(box)
		first = false
	assert_false(first, "furnished tube meshes exist")
	var hum := room.get_node("Room407MainLight/LightHum") as AudioStreamPlayer3D
	assert_true(hum.global_position.distance_to(tube_box.get_center()) <= REACH, "hum at the tube")
	assert_true(_near(hum.global_position, tube_box, 0.1), "hum within the tube fixture")


func test_fan_and_hum_levels_were_not_raised() -> void:
	var room := _room()
	# Owner likes quiet sound: T-218 only moves the sources.
	# (the zone gain scales volume_linear; the emitter keeps the scene's own level as its base)
	assert_eq((room.get_node("FanAmbience") as AmbientEmitter).get("_base_volume"), -12.0)
	assert_eq((room.get_node("Room407MainLight/LightHum") as AmbientEmitter).get("_base_volume"), -10.0)


func test_hum_follows_the_new_tube_flicker_pulses() -> void:
	var room := _room()
	var light := room.get_node("Room407MainLight") as OmniLight3D
	var hum := light.get_node("LightHum") as LightHum
	await wait_frames(2)
	assert_false(hum.playing, "dark tube: no hum")
	light.visible = true
	light.light_energy = 0.8
	await wait_frames(2)
	assert_true(hum.playing, "lit tube hums")
	light.set_flicker(true)
	var lit := 0
	var dark := 0
	var mismatches := 0
	var deadline := Time.get_ticks_msec() + 1700
	while Time.get_ticks_msec() < deadline:
		await wait_frames(1)
		var on := light.is_visible_in_tree() and light.light_energy > 0.001
		lit += int(on)
		dark += int(not on)
		mismatches += int(hum.playing != on)
	assert_true(lit > 0 and dark > 0, "both pulse phases happened (lit %d, dark %d)" % [lit, dark])
	assert_eq(mismatches, 0, "hum on exactly when the real light is on")
	light.set_flicker(false)
	await wait_frames(2)
	assert_true(hum.playing, "steady again")
	light.visible = false
	await wait_frames(1)
	assert_false(hum.playing, "switched off: silent")


func test_water_comes_from_the_new_shower_head() -> void:
	var room := _room()
	var shower := _shower(room)
	await wait_frames(2)
	var stall := room.get_node("Anchors/ShowerStall") as Node3D
	var emitter := room.get_node("Ch2Bathroom/Water") as Node3D
	var model := _bounds(room.get_node("Furnished/TripoProps/Shower") as Node3D)
	shower.set_water(37.0, true)
	var water := shower.get_node("Water") as AudioStreamPlayer3D
	assert_true(water.playing)
	assert_true(water.global_position.distance_to(emitter.global_position) <= 0.01, "water at the falling-water emitter")
	assert_true(_near(water.global_position, model, 0.3), "water within the shower model")
	assert_true(emitter.global_position.y < model.end.y, "the water starts under the shower top, not above it")
	assert_true(water.global_position.distance_to(stall.global_position) > 0.5, "water left the stall centre")
	shower.set_water(81.0, true)
	assert_true(water.playing and water.stream == Ch2AudioBank.clip("water_boiling"))
	shower.set_water(0.0, false)
	assert_false(water.playing, "set_water(false) still stops it")
	EventBus.shower_steam_changed.emit(0.5)
	assert_true((shower.get_node("Steam") as Node3D).position.is_zero_approx(), "steam keeps the stall centre")


func test_mirror_shiver_comes_from_the_small_mirror_and_door_cues_from_the_door() -> void:
	var room := _room()
	var shower := _shower(room)
	await wait_frames(2)
	var stall := room.get_node("Anchors/ShowerStall") as Node3D
	var figure := room.get_node("Ch2Bathroom/Reflection") as Node3D
	var glass := room.get_node("ReflectiveMirrorSmall") as Node3D
	var cue := shower.get_node("Cue") as AudioStreamPlayer3D
	shower.play_cue("mirror_shiver")
	assert_true(cue.playing)
	assert_true(cue.global_position.distance_to(figure.global_position) <= 0.01, "shiver where the figure appears")
	assert_true(cue.global_position.distance_to(glass.global_position) <= 0.35, "and within a hand of the glass")
	assert_true(_near(cue.global_position, _bounds(room.get_node("Furnished/TripoProps/MirrorSmall") as Node3D), 0.3))
	var handle := room.get_node("Extension/BathroomDoor/Pivot/Handle") as Node3D
	shower.play_door_push(2)
	assert_true(cue.global_position.distance_to(handle.global_position) <= 0.01, "door push at the door handle")
	shower.play_cue("mirror_shiver")
	shower.play_cue("door_burst")
	assert_true(cue.global_position.distance_to(handle.global_position) <= 0.01, "door burst at the door handle")
	assert_true(cue.global_position.distance_to(stall.global_position) > 1.0, "no longer in the stall centre")


func test_missing_nodes_fall_back_to_the_stall_never_the_world_origin() -> void:
	var room := _room()
	var shower := _shower(room)
	await wait_frames(2)
	var stall := room.get_node("Anchors/ShowerStall") as Node3D
	var cue := shower.get_node("Cue") as AudioStreamPlayer3D
	var water := shower.get_node("Water") as AudioStreamPlayer3D
	# Reflection figure gone: the furnished glass is the second choice.
	var reflection := room.get_node("Ch2Bathroom/Reflection")
	reflection.get_parent().remove_child(reflection)
	reflection.free()
	shower.play_cue("mirror_shiver")
	assert_true(cue.global_position.distance_to((room.get_node("ReflectiveMirrorSmall") as Node3D).global_position) <= 0.01)
	var glass := room.get_node("ReflectiveMirrorSmall")
	room.remove_child(glass)
	glass.free()
	shower.play_cue("mirror_shiver")
	assert_true(cue.global_position.is_equal_approx(stall.global_position), "no mirror anchor: stall centre")
	var emitter := room.get_node("Ch2Bathroom/Water")
	emitter.get_parent().remove_child(emitter)
	emitter.free()
	shower.set_water(37.0, true)
	assert_true(water.playing)
	assert_true(water.global_position.is_equal_approx(stall.global_position), "no emitter: stall centre")
	assert_false(water.global_position.is_zero_approx())
	# No room at all (the director falls back to its own child): still the parent's own spot.
	var holder := Node3D.new()
	holder.position = Vector3(36.0, 1.2, -6.3)
	_add(holder)
	var lone := ShowerAudio.new()
	holder.add_child(lone)
	lone.set_water(37.0, true)
	lone.play_cue("mirror_shiver")
	assert_true((lone.get_node("Water") as Node3D).global_position.is_equal_approx(holder.position))
	assert_true((lone.get_node("Cue") as Node3D).global_position.is_equal_approx(holder.position))


func test_follow_fixtures_off_restores_the_old_placement() -> void:
	var room := _room()
	var shower := _shower(room)
	shower.follow_fixtures = false
	await wait_frames(2)
	var stall := room.get_node("Anchors/ShowerStall") as Node3D
	shower.set_water(37.0, true)
	shower.play_cue("mirror_shiver")
	assert_true((shower.get_node("Water") as Node3D).global_position.is_equal_approx(stall.global_position))
	assert_true((shower.get_node("Cue") as Node3D).global_position.is_equal_approx(stall.global_position))


func test_reload_leaves_one_source_each_and_resets_the_shower() -> void:
	for round in 3:
		var room := _room()
		var shower := _shower(room)
		await wait_frames(2)
		assert_eq(room.find_children("FanAmbience", "", true, false).size(), 1, "one fan sound")
		assert_eq(room.find_children("LightHum", "", true, false).size(), 1, "one tube hum in the room")
		assert_eq(room.find_children("*", "ShowerAudio", true, false).size(), 1, "one shower rig")
		shower.set_water(37.0, true)
		shower.set_water(37.0, true)
		var playing := 0
		for player in shower.find_children("*", "AudioStreamPlayer3D", true, false):
			playing += int((player as AudioStreamPlayer3D).playing)
		assert_eq(playing, 1, "one water player, set twice")
		EventBus.checkpoint_loaded.emit(&"ch2_r3")
		for player in shower.find_children("*", "AudioStreamPlayer3D", true, false):
			assert_false((player as AudioStreamPlayer3D).playing, "checkpoint reload silences %s" % player.name)
		room.free()
		await tree.create_timer(0.05).timeout


## Every chapter has the furnished fan turning (chapter1_main collects fan_rotor) and the matching sound.
func test_fan_turns_and_sounds_in_all_four_chapters() -> void:
	for chapter in [1, 2, 3, 4]:
		var scene := (load("res://scenes/main/chapter%d.tscn" % chapter) as PackedScene).instantiate()
		var director := scene.get_node("Chapter%dDirector" % chapter)
		director.set("auto_start", false)
		Chapter1Director.resume_checkpoint = &""
		_add(scene)
		await wait_frames(6)
		var room := scene.get_node("Floor4/Room407")
		var rotor := room.get_node("Furnished/TripoProps/CeilingFan").find_child("fan_rotor", true, false) as Node3D
		assert_true(scene.get("_fan_rotors").has(rotor), "ch%d: the furnished rotor is driven" % chapter)
		var source := room.get_node("FanAmbience") as AudioStreamPlayer3D
		assert_true(source.playing, "ch%d: fan sound plays" % chapter)
		assert_true(source.global_position.distance_to(rotor.global_position) <= REACH, "ch%d: sound at the rotor" % chapter)
		_nodes.erase(scene)
		scene.free()
		await wait_frames(2)


func test_preview_opens_silent_toggles_each_source_and_swaps_placement() -> void:
	var preview := (load("res://audio/graphics_upgrade/room407_audio_preview.tscn") as PackedScene).instantiate()
	_add(preview)
	await wait_frames(3)
	var room: Node3D = preview.room
	for player in room.find_children("*", "AudioStreamPlayer3D", true, false):
		assert_false((player as AudioStreamPlayer3D).playing, "%s silent on open" % player.name)
	preview.toggle_fan()
	assert_true(preview.fan.playing)
	preview.toggle_light()
	await wait_frames(2)
	assert_true(preview.hum.playing, "lit tube hums")
	preview.toggle_flicker()
	assert_true(preview.light.flickering)
	preview.toggle_flicker()
	assert_false(preview.light.flickering)
	preview.set_water(&"warm")
	var water := preview.shower.get_node("Water") as AudioStreamPlayer3D
	assert_true(water.playing)
	var fixture_spot := water.global_position
	preview.place(false)
	assert_true(water.playing, "swapping placement keeps the water running")
	assert_true(water.global_position.is_equal_approx(room.get_node("Anchors/ShowerStall").global_position), "old placement: stall centre")
	assert_true(preview.fan.position.is_equal_approx(preview.OLD_FAN))
	preview.place(true)
	assert_true(water.global_position.is_equal_approx(fixture_spot))
	assert_true(preview.fan.position.is_equal_approx(preview.NEW_FAN))
	preview.toggle_steam()
	assert_true((preview.shower.get_node("Steam") as AudioStreamPlayer3D).playing)
	preview.play_mirror_shiver()
	assert_true((preview.shower.get_node("Cue") as AudioStreamPlayer3D).playing)
	preview.stop_all()
	for player in room.find_children("*", "AudioStreamPlayer3D", true, false):
		assert_false((player as AudioStreamPlayer3D).playing, "%s stopped" % player.name)
