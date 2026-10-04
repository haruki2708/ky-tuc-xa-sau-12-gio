extends Node3D
## Controls in audio_source/ch1v2/README.md. No settings are written here.

var taps: WallTaps
var mission: Ch1MissionAudio
var phone: PhoneCallAudio
var player_audio: Ch1PlayerAudio
var cctv: CctvAudio
var preview: AudioStreamPlayer
var selected: int = 0
var _handle_on: bool = false
var _camera_on: bool = false
var _channel: int = 0


func _ready() -> void:
	var camera := Camera3D.new()
	camera.position = Vector3(0, 1.5, 4)
	add_child(camera)
	camera.make_current()
	taps = WallTaps.new()
	taps.listener = camera
	add_child(taps)
	mission = Ch1MissionAudio.new()
	add_child(mission)
	mission.position = Vector3(1, 1, 1)
	phone = PhoneCallAudio.new()
	add_child(phone)
	player_audio = Ch1PlayerAudio.new()
	add_child(player_audio)
	cctv = CctvAudio.new()
	add_child(cctv)
	preview = AudioStreamPlayer.new()
	preview.bus = &"SFX"
	add_child(preview)
	if "--ch1v2-audio-preview" in OS.get_cmdline_user_args():
		taps.play_sequence(Vector3(0, 1, 0), [1, 3, 3, 4])


func audition(index: int) -> void:
	reset_preview()
	selected = posmod(index, Ch1V2AudioBank.NAMES.size())
	var clip_name: String = Ch1V2AudioBank.NAMES[selected]
	preview.bus = &"PhoneSFX" if clip_name in ["kiet_ring", "call_reconnect"] else &"SFX"
	preview.stream = Ch1V2AudioBank.clip(clip_name)
	preview.play()
	print("CH1V2 audition: ", selected + 1, "/", Ch1V2AudioBank.NAMES.size(), " ", clip_name, " -> ", preview.bus)


func _unhandled_key_input(event: InputEvent) -> void:
	if not event is InputEventKey or not event.pressed or event.echo:
		return
	match (event as InputEventKey).physical_keycode:
		KEY_LEFT: audition(selected - 1)
		KEY_RIGHT: audition(selected + 1)
		KEY_SPACE: audition(selected)
		KEY_F1: taps.play_sequence(Vector3(0, 1, 0), [1, 3, 3, 4])
		KEY_F2: taps.set_other_side(not taps.other_side)
		KEY_F3: mission.play_cue(&"router_power_off")
		KEY_F4: mission.play_cue(&"router_boot")
		KEY_F5: mission.play_cue(&"router_online")
		KEY_F6: mission.play_cue(&"power_switch")
		KEY_F7: mission.play_cue(&"power_short")
		KEY_F8:
			_handle_on = not _handle_on
			mission.set_handle_rattling(_handle_on)
		KEY_F9: mission.play_cue(&"lock_alarm")
		KEY_K:
			EventBus.phone_call_incoming.emit(&"audio_fixture")
			EventBus.phone_call_answered.emit(&"audio_fixture")
			phone.play_remote_ring(true)
		KEY_L: EventBus.phone_call_lost.emit(&"audio_fixture")
		KEY_R: EventBus.phone_call_restored.emit(&"audio_fixture")
		KEY_1: _death(&"fall_back")
		KEY_2: _death(&"bed_burst")
		KEY_3: _death(&"manager_kill")
		KEY_4: _death(&"none")
		KEY_C:
			_camera_on = not _camera_on
			cctv.set_viewing(_camera_on)
		KEY_N:
			_channel += 1
			cctv.select_channel(StringName("fixture_%d" % _channel))
		KEY_0: reset_preview()
		KEY_ESCAPE: App.quit()


func _death(kind: StringName) -> void:
	player_audio._on_chapter(1)
	EventBus.player_death_started.emit(kind)


func reset_preview() -> void:
	preview.stop()
	taps.stop_emitting()
	mission._reset(null)
	phone.end_call(false)
	player_audio._on_chapter(1)
	cctv.set_viewing(false)
	_handle_on = false
	_camera_on = false
