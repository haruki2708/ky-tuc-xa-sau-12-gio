extends Node3D
## Audition controls are documented in audio_source/ch1/README.md.

var manager: ManagerAudio
var screams: BuildingScreams
var phone: PhoneCallAudio
var player_audio: Ch1PlayerAudio
var corpse: CorpseAudio
var music: Ch1Music
var speaker: Speaker
var preview: AudioStreamPlayer
var selected: int = 0
var _travel: Tween
var _drag: bool = false
var _blood: bool = false
var _silent: bool = false
var _holding: bool = false
var _paused: bool = false


func _ready() -> void:
	var camera := Camera3D.new()
	camera.name = "Camera3D"
	camera.position = Vector3(0, 1.5, 8)
	add_child(camera)
	camera.make_current()
	manager = ManagerAudio.new()
	manager.name = "ManagerAudio"
	manager.listener = camera
	add_child(manager)
	manager.place_at(Vector3(0, 0, 2))
	screams = BuildingScreams.new()
	screams.listener = camera
	add_child(screams)
	phone = PhoneCallAudio.new()
	add_child(phone)
	player_audio = Ch1PlayerAudio.new()
	add_child(player_audio)
	corpse = CorpseAudio.new()
	add_child(corpse)
	corpse.position = Vector3(1, 0, 5)
	music = Ch1Music.new()
	add_child(music)
	speaker = Speaker.new()
	speaker.chapter_profile = true
	add_child(speaker)
	speaker.position = Vector3(0, 2, 3)
	preview = AudioStreamPlayer.new()
	preview.bus = &"SFX"
	add_child(preview)
	# Simple visible floors and source marker, entirely inside the audio fixture.
	for level in 3:
		var floor_mesh := MeshInstance3D.new()
		var box := BoxMesh.new()
		box.size = Vector3(10, 0.1, 5)
		floor_mesh.mesh = box
		floor_mesh.position = Vector3(0, level * 3.3 - 0.1, -2)
		add_child(floor_mesh)
	var marker := MeshInstance3D.new()
	marker.mesh = SphereMesh.new()
	manager.add_child(marker)
	var light := DirectionalLight3D.new()
	light.rotation_degrees = Vector3(-40, -20, 0)
	add_child(light)
	if "--ch1-audio-preview" in OS.get_cmdline_user_args():
		start_travel()


func audition(index: int) -> void:
	reset_preview()
	selected = posmod(index, Ch1AudioBank.NAMES.size())
	preview.stop()
	var clip_name: String = Ch1AudioBank.NAMES[selected]
	preview.bus = &"PhoneSFX" if clip_name == "call_drop" or clip_name == "call_disconnect" else &"SFX"
	if clip_name.begins_with("pa_"):
		preview.bus = &"Voice"
	elif clip_name == "blood_drip":
		preview.bus = &"Ambience"
	preview.stream = Ch1AudioBank.clip(clip_name)
	preview.play()
	print("CH1 audition: ", selected + 1, "/", Ch1AudioBank.NAMES.size(), " ", clip_name, " -> ", preview.bus)


func start_travel() -> void:
	if _travel != null:
		_travel.kill()
	manager.place_at(Vector3(-4, 6.6, 0))
	manager.play_drag(true)
	_drag = true
	_travel = create_tween()
	_travel.tween_property(manager, "global_position", Vector3(4, 3.3, 0), 6.0)
	_travel.tween_interval(1.0)
	_travel.tween_property(manager, "global_position", Vector3(0, 0, 2), 6.0)
	_travel.tween_callback(manager.play_knock)


func _unhandled_key_input(event: InputEvent) -> void:
	if not event is InputEventKey or not event.pressed or event.echo:
		return
	match (event as InputEventKey).physical_keycode:
		KEY_RIGHT: audition(selected + 1)
		KEY_LEFT: audition(selected - 1)
		KEY_SPACE: audition(selected)
		KEY_F1: manager.play_step()
		KEY_F2:
			_drag = not _drag
			manager.play_drag(_drag)
		KEY_F3: manager.play_knock()
		KEY_F4: manager.play_slash()
		KEY_F5: manager.play_slash(&"wood")
		KEY_F6: manager.play_kill()
		KEY_F7: screams.play_wave(Vector3(0, 0, -2), 8, 7.0)
		KEY_F8: EventBus.phone_call_incoming.emit(&"audio_fixture")
		KEY_F9: EventBus.phone_call_answered.emit(&"audio_fixture")
		KEY_F10: EventBus.chat_member_changed.emit(&"fixture_member", &"dead")
		KEY_F11: phone.end_call()
		KEY_F12: start_travel()
		KEY_B:
			_blood = not _blood
			corpse.play_drips(_blood)
		KEY_C: corpse.play_pose()
		KEY_H:
			_holding = not _holding
			EventBus.breath_held.emit(_holding)
		KEY_G: EventBus.noise_emitted.emit(Vector3.ZERO, 4.0, &"breath")
		KEY_M:
			_silent = false
			music.silence_before_door(false)
			music.set_active(true)
			music.set_tension(0.0)
		KEY_T: music.set_tension(1.0)
		KEY_S:
			_silent = not _silent
			music.silence_before_door(_silent)
		KEY_V: speaker.play_announcement([{"text_key": "RULE_1"}, {"text_key": "RULE_2"}])
		KEY_P:
			_paused = not _paused
			EventBus.game_paused.emit(_paused)
		KEY_0: reset_preview()
		KEY_ESCAPE: App.quit()


func reset_preview() -> void:
	if _travel != null:
		_travel.kill()
	preview.stop()
	for source: AudioStreamPlayer3D in manager._players.values():
		source.stop()
	manager.place_at(Vector3(0, 0, 2))
	screams.stop_emitting()
	phone.end_call(false)
	corpse.play_drips(false)
	corpse._rustle.stop()
	EventBus.breath_held.emit(false)
	player_audio._foley.stop()
	music.set_active(false)
	music.set_tension(0.0)
	music.silence_before_door(true)
	speaker.stop_emitting()
	_drag = false
	_blood = false
	_holding = false
	_silent = true
	_paused = false
	EventBus.game_paused.emit(false)


func stop_emitting() -> void:
	if _travel != null:
		_travel.kill()
