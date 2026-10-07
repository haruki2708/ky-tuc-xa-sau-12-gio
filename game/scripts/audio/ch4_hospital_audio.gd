class_name Ch4HospitalAudio
extends Node3D

@export_dir var sound_directory: String = Ch4AudioBank.DIRECTORY
@export_dir var voice_directory: String = Ch4AudioBank.VOICE_DIRECTORY
var monitor_beats: int = 0
var skipped_beats: int = 0
var heart_beats: int = 0
var _monitor: AudioStreamPlayer3D
var _foley: AudioStreamPlayer3D
var _voice: AudioStreamPlayer3D
var _fade: AudioStreamPlayer
var _heart: AudioStreamPlayer
var _hospital: bool = false
var _skip_next: bool = false
var _until_monitor: float = 1.0
var _fade_length: float = 0.0
var _fade_elapsed: float = 0.0
var _until_heart: float = 0.0
var _step: int = 0
var _said: Dictionary[String, bool] = {}
var _disabled: bool = false


func _ready() -> void:
	_monitor = Ch4AudioBank.spatial(self, &"SFX", 15.0)
	_foley = Ch4AudioBank.spatial(self, &"Footsteps", 15.0)
	_voice = Ch4AudioBank.spatial(self, &"Voice", 20.0)
	_fade = AudioStreamPlayer.new()
	_fade.bus = &"Music"
	add_child(_fade)
	_heart = AudioStreamPlayer.new()
	_heart.bus = &"SFX"
	add_child(_heart)


func enter_hospital(monitor_at: Vector3) -> void:
	if _disabled or not monitor_at.is_finite():
		return
	_monitor.global_position = monitor_at
	if _hospital:
		return
	stop_fade()
	_hospital = true
	_until_monitor = 1.0


func skip_monitor() -> void:
	if _hospital and not _disabled:
		_skip_next = true


func begin_fade(seconds: float) -> void:
	if _disabled or _fade_length > 0.0 or not is_finite(seconds) or seconds <= 0.0:
		return
	_fade_length = seconds
	_fade_elapsed = 0.0
	_until_heart = 0.0
	_fade.volume_db = 0.0
	Ch4AudioBank.play(_fade, "body_fade", sound_directory)


func heart_interval() -> float:
	return lerpf(0.8, 2.4, clampf(_fade_elapsed / maxf(_fade_length, 0.01), 0.0, 1.0))


func _process(delta: float) -> void:
	if _disabled:
		return
	if _hospital:
		_until_monitor -= delta
		if _until_monitor <= 0.000001:
			_until_monitor = 1.0
			if _skip_next:
				_skip_next = false
				skipped_beats += 1
			else:
				monitor_beats += 1
				Ch4AudioBank.play(_monitor, "monitor", sound_directory)
	if _fade_length > 0.0:
		_fade_elapsed += delta
		_until_heart -= delta
		var ratio := clampf(_fade_elapsed / _fade_length, 0.0, 1.0)
		_fade.volume_db = -36.0 * ratio
		_heart.volume_db = -24.0 * ratio
		if _fade_elapsed >= _fade_length:
			stop_fade()
		elif _until_heart <= 0.0:
			heart_beats += 1
			Ch4AudioBank.play(_heart, "heartbeat", sound_directory)
			_until_heart = heart_interval()


func play_line(id: String, at: Vector3) -> float:
	# Preview helper: keys now load approved T-200 files, with no draft aliases.
	if _disabled or _said.has(id) or not at.is_finite():
		return 0.0
	var stream := Ch4AudioBank.voice(id, voice_directory)
	if stream == null:
		return 0.0
	_said[id] = true
	_voice.stop()
	_voice.global_position = at
	_voice.stream = stream
	_voice.play()
	return stream.get_length()


func play_nurse_step(at: Vector3) -> void:
	if not _hospital or _disabled or not at.is_finite():
		return
	_step = 1 - _step
	_foley.bus = &"Footsteps"
	_foley.global_position = at
	Ch4AudioBank.play(_foley, "nurse_step_0%d" % (_step + 1), sound_directory)


func play_door(at: Vector3) -> void:
	if not _hospital or _disabled or not at.is_finite():
		return
	_foley.bus = &"SFX"
	_foley.global_position = at
	Ch4AudioBank.play(_foley, "hospital_door", sound_directory)


func stop_fade() -> void:
	_fade.stop()
	_heart.stop()
	_fade_length = 0.0


func reset() -> void:
	stop_fade()
	_monitor.stop()
	_foley.stop()
	_voice.stop()
	_hospital = false
	_skip_next = false
	_said.clear()


func stop_emitting() -> void:
	_disabled = true
	reset()
