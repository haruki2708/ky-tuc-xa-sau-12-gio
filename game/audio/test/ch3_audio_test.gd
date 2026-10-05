extends Node3D
## Audio-only fixture; console controls in audio_source/ch3/README.md.

var listener: Node3D
var high_spot: Marker3D
var horde: Ch3HordeAudio
var rigs: Array[ZombieAudio] = []
var player_audio: Ch3PlayerAudio
var death: Ch1PlayerAudio
var music: Ch3Music
var environment: Ch3Environment
var siren: Ch3SirenAudio
var guard: Ch3GuardAudio
var steps: FootstepPlayer
var preview: AudioStreamPlayer
var selected: int = 0
var _step_time: float = 0.0
var _walking: bool = false
var _surface: StringName = &"tile"


func _ready() -> void:
	listener = Node3D.new()
	add_child(listener)
	var camera := Camera3D.new()
	camera.position.y = 1.5
	listener.add_child(camera)
	camera.make_current()
	high_spot = Marker3D.new()
	high_spot.position = Vector3(0, 8, 0) # Fixture only, not campus coordinates.
	add_child(high_spot)
	horde = Ch3HordeAudio.new()
	horde.listener = listener
	add_child(horde)
	for index in 40:
		var actor := Node3D.new()
		actor.position = Vector3((index % 8 - 4) * 2, 0, -3 - (index / 8) * 3)
		add_child(actor)
		var rig := ZombieAudio.new()
		rig.hissing = index % 2 == 1
		actor.add_child(rig)
		rigs.append(rig)
		horde.register(rig)
	player_audio = Ch3PlayerAudio.new()
	add_child(player_audio)
	death = Ch1PlayerAudio.new()
	add_child(death)
	music = Ch3Music.new()
	add_child(music)
	environment = Ch3Environment.new()
	add_child(environment)
	for position_value in [Vector3(-25, 0, -30), Vector3(30, 0, -35)]:
		var point := Marker3D.new()
		point.position = position_value
		add_child(point)
		environment.scream_points.append(point)
	siren = Ch3SirenAudio.new()
	siren.listener = listener
	siren.high_spot = high_spot
	add_child(siren)
	guard = Ch3GuardAudio.new()
	guard.guard = listener # Test signal identity; no gameplay guard in this fixture.
	listener.add_child(guard)
	steps = FootstepPlayer.new()
	listener.add_child(steps)
	preview = AudioStreamPlayer.new()
	add_child(preview)
	print("CH3 audio: 1 horde; 2 bar; 3/4 stamina; 5 wind; 6 siren high; G low; 7 baton; 8/9 music; C canteen; E ending; Z/X deaths; T/Y/U steps; arrows clips; 0 reset.")
	if "--ch3-audio-preview" in OS.get_cmdline_user_args():
		audition(0)


func _process(delta: float) -> void:
	_step_time -= delta
	if _step_time <= 0:
		_step_time = 0.8
		for rig in rigs:
			rig.play_step()
		if _walking:
			steps.play_footstep(_surface, 1.0)


func reset_preview() -> void:
	EventBus.checkpoint_loaded.emit(&"ch3_audio_fixture")
	preview.stop()
	steps.stop()
	_walking = false
	listener.position = Vector3.ZERO


func audition(index: int) -> void:
	reset_preview()
	selected = posmod(index, Ch3AudioBank.NAMES.size())
	var clip_name := Ch3AudioBank.NAMES[selected]
	preview.bus = &"Music" if clip_name.begins_with("music_") else (&"Ambience" if clip_name in ["wind", "stadium", "canteen", "stairs", "horde", "rescue_siren", "far_scream"] else (&"Footsteps" if clip_name.begins_with("run_") or clip_name.begins_with("zombie_drag_") else &"SFX"))
	Ch3AudioBank.play(preview, clip_name)
	print("CH3 audition: ", selected + 1, "/", Ch3AudioBank.NAMES.size(), " ", clip_name)


func _unhandled_key_input(event: InputEvent) -> void:
	if not event is InputEventKey or not event.pressed or event.echo:
		return
	var key := (event as InputEventKey).physical_keycode
	match key:
		KEY_LEFT: audition(selected - 1)
		KEY_RIGHT: audition(selected + 1)
		KEY_SPACE: audition(selected)
		KEY_0: reset_preview()
		KEY_1:
			for rig in rigs:
				rig.set_hunting(true)
			horde.update_mix()
			print("CH3 individual zombies: ", horde.audible_count(), "/40")
		KEY_D:
			for rig in rigs:
				if rig.audible:
					rig.play_door_hit()
					break
		KEY_2: EventBus.bar_swung.emit(true, 2)
		KEY_M: EventBus.bar_swung.emit(false, 2)
		KEY_B: EventBus.bar_broken.emit()
		KEY_3: EventBus.stamina_changed.emit(0.5, false)
		KEY_4: EventBus.stamina_changed.emit(0.0, true)
		KEY_R: EventBus.stamina_changed.emit(1.0, false)
		KEY_5: environment.set_area(&"garden")
		KEY_F: environment.play_far_scream()
		KEY_6:
			listener.position = high_spot.position
			siren.set_enabled(true)
		KEY_G: listener.position = Vector3.ZERO
		KEY_7: EventBus.guard_warned.emit(listener, true)
		KEY_8:
			music.set_area(&"road")
			music.set_running(true)
		KEY_9:
			environment.set_area(&"stadium")
			music.set_area(&"stadium")
			music.set_wave(true)
		KEY_C:
			environment.set_area(&"canteen")
			music.set_area(&"canteen")
		KEY_S: environment.set_area(&"stairs")
		KEY_E: EventBus.chapter_finished.emit(3)
		KEY_Z, KEY_X:
			reset_preview()
			EventBus.player_death_started.emit(&"zombie_grab" if key == KEY_Z else &"guard_shock")
		KEY_T, KEY_Y, KEY_U:
			_surface = &"tile" if key == KEY_T else (&"grass" if key == KEY_Y else &"concrete")
			_walking = true
		KEY_ESCAPE: App.quit()


func stop_emitting() -> void:
	set_process(false)
	preview.stop()
	steps.stop()
	for source in [horde, player_audio, death, music, environment, siren, guard]:
		if is_instance_valid(source):
			source.stop_emitting()


func _exit_tree() -> void:
	stop_emitting()
