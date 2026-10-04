class_name Ch1PlayerAudio
extends Node
## Listener-local Foley; never emits gameplay noise or decides breath exhaustion.

@export_dir var sound_directory: String = Ch1AudioBank.DIRECTORY
@export var handle_player_caught: bool = true
var _heart: AudioStreamPlayer
var _foley: AudioStreamPlayer
var _holding: bool = false
var _held_seconds: float = 0.0
var _until_beat: float = 0.0
var _stopped: bool = false


func _ready() -> void:
	_heart = AudioStreamPlayer.new()
	_heart.name = "Heartbeat"
	_heart.bus = &"SFX"
	add_child(_heart)
	_foley = AudioStreamPlayer.new()
	_foley.name = "Foley"
	_foley.bus = &"SFX"
	add_child(_foley)
	EventBus.breath_held.connect(_on_breath)
	EventBus.noise_emitted.connect(_on_noise)
	EventBus.player_hidden.connect(_on_hidden)
	EventBus.player_caught.connect(_on_caught)
	EventBus.chapter_started.connect(_on_chapter)
	EventBus.settings_changed.connect(_on_settings)


func _on_breath(holding: bool) -> void:
	if _stopped or holding == _holding:
		return
	_holding = holding
	_held_seconds = 0.0
	_until_beat = 0.0
	if not holding:
		_heart.stop()


func heartbeat_interval() -> float:
	return lerpf(1.1, 0.66, clampf(_held_seconds / 8.0, 0.0, 1.0))


func _process(delta: float) -> void:
	if not _holding or _stopped:
		return
	_held_seconds += delta
	_until_beat -= delta
	if _until_beat <= 0.0:
		_until_beat = heartbeat_interval()
		_heart.stream = Ch1AudioBank.clip("heartbeat", sound_directory)
		if _heart.stream != null:
			_heart.play()


func play_action(action: StringName) -> void:
	if _stopped or _foley == null or action not in [&"breath_gasp", &"bunk_climb", &"bunk_creak", &"wall_knock", &"locker_unlock", &"charger_plug", &"manager_kill", &"kill_soft"]:
		return
	var clip_name := String(action)
	if action == &"manager_kill" and Ch1AudioBank.reduced():
		clip_name = "kill_soft"
	_foley.stop()
	_foley.stream = Ch1AudioBank.clip(clip_name, sound_directory)
	if _foley.stream != null:
		_foley.play()


func _on_noise(_position: Vector3, radius: float, source: StringName) -> void:
	# T-151 contract: ordinary breath = 1.5 m, mandatory gasp = 4 m.
	if source == &"breath" and radius >= 4.0:
		_on_breath(false)
		play_action(&"breath_gasp")


func _on_hidden(hidden: bool, kind: StringName) -> void:
	if not hidden:
		_on_breath(false)
	if kind in [&"bunk", &"bed"]:
		play_action(&"bunk_creak")


func _on_caught(_entity_id: StringName) -> void:
	_on_breath(false)
	if handle_player_caught:
		play_action(&"manager_kill")


func _on_settings(section: String, key: String) -> void:
	if section == "accessibility" and key == "reduce_scares" and Ch1AudioBank.reduced():
		if _foley.playing and _foley.stream == Ch1AudioBank.clip("manager_kill", sound_directory):
			play_action(&"kill_soft")


func _on_chapter(_chapter: int) -> void:
	_on_breath(false)
	_foley.stop()


func stop_emitting() -> void:
	_stopped = true
	_holding = false
	if _heart != null:
		_heart.stop()
	if _foley != null:
		_foley.stop()
