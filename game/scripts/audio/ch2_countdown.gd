class_name Ch2Countdown
extends Node
## Audio clock only; never submits a choice or causes death on timeout.

signal ticked(remaining: float)

@export var listen_chain: bool = true
@export var clip_name: String = "chain_tick"
@export_dir var sound_directory: String = Ch2AudioBank.DIRECTORY
var remaining: float = 0.0
var _next_tick: float = 0.0
var _elapsed: float = 0.0
var _duration: float = 0.0
var _speaker: StringName
var _player: AudioStreamPlayer
var _stopped: bool = false


func _ready() -> void:
	_player = AudioStreamPlayer.new()
	_player.bus = &"SFX"
	add_child(_player)
	if listen_chain:
		EventBus.chain_turn_started.connect(_on_turn)
		EventBus.chain_word_spoken.connect(_on_word)
		EventBus.chain_choice_made.connect(_reset)
	EventBus.chapter_started.connect(_reset)
	EventBus.chapter_finished.connect(_reset)
	EventBus.checkpoint_loaded.connect(_reset)
	EventBus.player_death_started.connect(_reset)


func start(seconds: float) -> void:
	if _stopped or not is_node_ready() or not is_finite(seconds) or seconds <= 0.0:
		return
	cancel()
	_duration = minf(seconds, 120.0)
	remaining = _duration
	_elapsed = 0.0
	_next_tick = 0.5 if remaining <= 5.0 else 1.0
	_player.stream = Ch2AudioBank.clip(clip_name, sound_directory)


func _process(delta: float) -> void:
	if _stopped or remaining <= 0.0:
		return
	_elapsed += delta
	remaining = maxf(0.0, _duration - _elapsed)
	# Do not emit a burst of overdue sounds after a slow frame.
	if _elapsed >= _next_tick and remaining > 0.0:
		_next_tick = _elapsed + (0.5 if remaining <= 5.0 else 1.0)
		if _player.stream != null:
			_player.play()
		ticked.emit(remaining)
	if remaining <= 0.0:
		_player.stop()


func cancel() -> void:
	remaining = 0.0
	if _player != null:
		_player.stop()


func _on_turn(who: StringName, seconds: float) -> void:
	_speaker = who
	start(seconds)


func _on_word(who: StringName, key: String) -> void:
	if who == _speaker and not key.is_empty():
		cancel()


func _reset(_value: Variant) -> void:
	cancel()


func stop_emitting() -> void:
	cancel()
	_stopped = true
