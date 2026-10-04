class_name Speaker
extends AudioStreamPlayer3D
## Old PA effects, offline voice clips and subtitles; no story decisions.
## Use stop_emitting() to cancel, including during App's audio drain.

signal announcement_finished

enum Stage { IDLE, POWER_ON, CHIME, LINES, POWER_OFF }
const POWER_ON: AudioStream = preload("res://audio/sfx/speaker_on.ogg")
const CHIME: AudioStream = preload("res://audio/sfx/speaker_chime.ogg")
const POWER_OFF: AudioStream = preload("res://audio/sfx/speaker_off.ogg")
const STATIC: AudioStream = preload("res://audio/ambience/speaker_static.ogg")
const BURST: AudioStream = preload("res://audio/sfx/speaker_static_burst.ogg")

## Relative gain keeps the static bed below subtitles' future spoken audio.
@export_range(-40.0, 0.0) var static_gain_db: float = -12.0
@export_dir var voice_directory: String = "res://audio/voice"
## Settings is the runtime default; fixed locales support the audition fixture.
@export_enum("Settings", "vi", "en") var voice_locale: String = "Settings"
## Chapter 1 replaces the demo jingle with a relay/noise start and short line hiss.
@export var chapter_profile: bool = false

var stage: Stage = Stage.IDLE
var _background: AudioStreamPlayer3D
var _burst: AudioStreamPlayer3D
var _voice: AudioStreamPlayer3D
var _lines: Array[Dictionary] = []
var _line_index: int = 0
var _line_seconds: float = 4.0
var _remaining: float = 0.0


func _ready() -> void:
	bus = &"Voice"
	_background = _make_layer("BackgroundStatic", STATIC)
	_burst = _make_layer("StaticBurst", BURST)
	_voice = _make_layer("Speech", null)
	_sync_layers()
	finished.connect(_on_effect_finished)


func play_announcement(lines: Array, line_seconds: float = 4.0) -> void:
	if not is_node_ready() or not is_finite(line_seconds) or line_seconds <= 0.0:
		return
	stop_emitting()
	# Copy accepted fields so edits to the caller's Array cannot alter this run.
	for entry: Variant in lines:
		if not entry is Dictionary:
			continue
		var key: Variant = entry.get("text_key", "")
		var garbled: Variant = entry.get("garbled", false)
		if not (key is String or key is StringName) or String(key).strip_edges().is_empty() or not garbled is bool:
			continue
		_lines.append({"text_key": String(key), "garbled": garbled})
	if _lines.is_empty():
		announcement_finished.emit()
		return
	_line_seconds = line_seconds
	_line_index = 0
	stage = Stage.POWER_ON
	_play_effect(Ch1AudioBank.clip("pa_on") if chapter_profile else POWER_ON)


func stop_emitting() -> void:
	stage = Stage.IDLE
	_remaining = 0.0
	_lines.clear()
	stop()
	if is_instance_valid(_background):
		_background.stop()
	if is_instance_valid(_burst):
		_burst.stop()
	if is_instance_valid(_voice):
		_voice.stop()


func _make_layer(label: String, clip: AudioStream) -> AudioStreamPlayer3D:
	var player := AudioStreamPlayer3D.new()
	player.name = label
	player.stream = clip
	add_child(player)
	return player


func _sync_layers() -> void:
	for player in [_background, _burst, _voice]:
		player.bus = &"Voice"
		player.volume_db = volume_db + (static_gain_db if player == _background else 0.0)
		player.pitch_scale = pitch_scale
		player.unit_size = unit_size
		player.max_distance = max_distance
		player.max_db = max_db
		player.attenuation_model = attenuation_model
		player.panning_strength = panning_strength
		player.emission_angle_enabled = emission_angle_enabled
		player.emission_angle_degrees = emission_angle_degrees
		player.emission_angle_filter_attenuation_db = emission_angle_filter_attenuation_db
		player.attenuation_filter_cutoff_hz = attenuation_filter_cutoff_hz
		player.attenuation_filter_db = attenuation_filter_db


func _play_effect(clip: AudioStream) -> void:
	bus = &"Voice"
	stream = clip
	play()


func _on_effect_finished() -> void:
	match stage:
		Stage.POWER_ON:
			if chapter_profile:
				stage = Stage.LINES
				_sync_layers()
				_background.play()
				_begin_line()
				return
			stage = Stage.CHIME
			_play_effect(CHIME)
		Stage.CHIME:
			stage = Stage.LINES
			_sync_layers()
			_background.play()
			_begin_line()
		Stage.POWER_OFF:
			stop_emitting()
			announcement_finished.emit()


func _begin_line() -> void:
	_burst.stop()
	_voice.stop()
	_voice.stream = null
	if _line_index >= _lines.size():
		_background.stop()
		stage = Stage.POWER_OFF
		_play_effect(POWER_OFF)
		return
	var entry := _lines[_line_index]
	_remaining = _line_seconds
	_sync_layers()
	_voice.stream = SpeakerVoiceBank.load_clip(voice_directory, _current_voice_locale(), entry["text_key"])
	if _voice.stream != null:
		_remaining = maxf(_line_seconds, _voice.stream.get_length() + 0.4)
		_voice.play()
	if entry["garbled"]:
		_burst.stream = BURST
		_burst.play()
	elif chapter_profile:
		_burst.stream = Ch1AudioBank.clip("pa_burst")
		_burst.play()
	# Caller chooses the key (e.g. RULE_3_GARBLED); never reveal hidden text here.
	# No work after emit: subscribers may cancel/restart the announcement.
	EventBus.subtitle_requested.emit(entry["text_key"], _remaining)


func _current_voice_locale() -> String:
	if voice_locale in ["vi", "en"]:
		return voice_locale
	var config := ConfigFile.new()
	if config.load("user://settings.cfg") == OK:
		var locale: Variant = config.get_value("ui", "locale", "vi")
		if locale is String and locale in ["vi", "en"]:
			return locale
	return "vi"


func _process(delta: float) -> void:
	if stage == Stage.IDLE:
		return
	_sync_layers()
	if stage == Stage.LINES:
		_remaining -= delta
		if _remaining <= 0.0:
			_line_index += 1
			_begin_line()


func _exit_tree() -> void:
	stop_emitting()
