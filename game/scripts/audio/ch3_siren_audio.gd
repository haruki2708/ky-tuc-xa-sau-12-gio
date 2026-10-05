class_name Ch3SirenAudio
extends Node
## Bind feet/root positions to Lane B's high Clues/SirenSpot marker.
## A small vertical window excludes the track directly underneath the stands.

@export var listener: Node3D
@export var high_spot: Node3D
@export var horizontal_radius: float = 2.5
@export var vertical_tolerance: float = 0.6
@export var still_speed: float = 0.12
@export_dir var sound_directory: String = Ch3AudioBank.DIRECTORY
var enabled: bool = false
var _player: AudioStreamPlayer
var _previous_position: Vector3
var _sampled: bool = false
var _stopped: bool = false


func _ready() -> void:
	_player = AudioStreamPlayer.new()
	_player.bus = &"Ambience"
	add_child(_player)
	EventBus.checkpoint_loaded.connect(_reset)
	EventBus.player_death_started.connect(_reset)
	EventBus.chapter_started.connect(_reset)
	EventBus.chapter_finished.connect(_reset)


func set_enabled(value: bool) -> void:
	enabled = value and not _stopped
	if not enabled:
		_sampled = false
		if _player != null:
			_player.stop()


func _process(delta: float) -> void:
	if not enabled or _stopped or not is_instance_valid(listener) or not is_instance_valid(high_spot) or not listener.is_inside_tree() or not high_spot.is_inside_tree():
		_player.stop()
		_sampled = false
		return
	var position_now := listener.global_position
	var speed := position_now.distance_to(_previous_position) / maxf(delta, 0.000001)
	var offset := position_now - high_spot.global_position
	var at_high_spot := absf(offset.y) <= maxf(0.0, vertical_tolerance) and Vector2(offset.x, offset.z).length() <= maxf(0.0, horizontal_radius)
	if _sampled and at_high_spot and speed <= maxf(0.0, still_speed):
		Ch3AudioBank.play(_player, "rescue_siren", sound_directory)
	else:
		_player.stop()
	_previous_position = position_now
	_sampled = true


func _reset(_reason: Variant) -> void:
	set_enabled(false)


func stop_emitting() -> void:
	_stopped = true
	set_enabled(false)
