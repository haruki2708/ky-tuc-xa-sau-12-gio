class_name Ch3GuardAudio
extends Node3D

@export var guard: Node3D
@export_dir var sound_directory: String = Ch3AudioBank.DIRECTORY
var _player: AudioStreamPlayer3D
var _stopped: bool = false
var _suspended: bool = false


func _ready() -> void:
	if guard == null:
		guard = get_parent() as Node3D
	_player = AudioStreamPlayer3D.new()
	_player.bus = &"SFX"
	_player.max_distance = 10.0
	add_child(_player)
	EventBus.guard_warned.connect(_on_warned)
	EventBus.checkpoint_loaded.connect(_reset)
	EventBus.chapter_started.connect(_reset)
	EventBus.chapter_finished.connect(_suspend)
	EventBus.player_death_started.connect(_suspend)


func _on_warned(source: Node3D, warned: bool) -> void:
	if source != guard or _stopped or _suspended:
		return
	if warned:
		Ch3AudioBank.play(_player, "baton_buzz", sound_directory)
	else:
		_player.stop()


func _reset(_reason: Variant) -> void:
	_suspended = false
	_player.stop()


func _suspend(reason: Variant) -> void:
	_reset(reason)
	_suspended = true


func stop_emitting() -> void:
	_stopped = true
	if _player != null:
		_player.stop()
