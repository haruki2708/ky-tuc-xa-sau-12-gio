class_name Ch4Music
extends Node

@export_dir var sound_directory: String = Ch4AudioBank.DIRECTORY
var area: StringName = &""
var _music: AudioStreamPlayer
var _ambience: AudioStreamPlayer
var _rain: AudioStreamPlayer
var _siren: AudioStreamPlayer
var _end: AudioStreamPlayer
var _muted: bool = false
var _ended: bool = false
var _disabled: bool = false
var _minutes: int = 510


func _ready() -> void:
	_music = _player(&"Music")
	_ambience = _player(&"Ambience")
	_rain = _player(&"Ambience")
	_siren = _player(&"Ambience")
	_end = _player(&"Music")
	_minutes = GameState.minutes
	EventBus.time_changed.connect(_on_time)


func _player(bus_name: StringName) -> AudioStreamPlayer:
	var player := AudioStreamPlayer.new()
	player.bus = bus_name
	add_child(player)
	return player


func set_area(value: StringName) -> void:
	if _disabled or _ended:
		return
	area = value
	_refresh()


func set_muted(value: bool) -> void:
	_muted = value
	_refresh()


func _on_time(value: int) -> void:
	_minutes = value
	_refresh()


func _refresh() -> void:
	if _disabled or _muted or _ended or area not in [&"road", &"library", &"return_b", &"stairs", &"hospital"]:
		_silence()
		return
	Ch4AudioBank.play(_music, "music_hospital" if area == &"hospital" else "music_sparse", sound_directory)
	if area == &"library":
		Ch4AudioBank.play(_ambience, "library", sound_directory)
		Ch4AudioBank.play(_rain, "drizzle", sound_directory)
	else:
		_ambience.stop()
		_rain.stop()
	if area != &"hospital" and _minutes >= 510:
		_siren.volume_db = lerpf(-18.0, 0.0, clampf(float(_minutes - 510) / 30.0, 0.0, 1.0))
		Ch3AudioBank.play(_siren, "rescue_siren")
	else:
		_siren.stop()


func play_ending() -> void:
	if _disabled or _ended:
		return
	_ended = true
	_silence()
	Ch4AudioBank.play(_end, "music_end", sound_directory)


func _silence() -> void:
	for player in [_music, _ambience, _rain, _siren]:
		player.stop()


func reset() -> void:
	_silence()
	_end.stop()
	area = &""
	_muted = false
	_ended = false
	_minutes = GameState.minutes


func stop_emitting() -> void:
	_disabled = true
	reset()
