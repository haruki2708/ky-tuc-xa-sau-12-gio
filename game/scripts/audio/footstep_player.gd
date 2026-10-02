class_name FootstepPlayer
extends AudioStreamPlayer3D
## Lane A integration: call play_footstep(&"tile") from Player.footstep.
## Unsupported surfaces stay silent until their sound bank is supplied.

@export var tile_variants: Array[AudioStream] = [
	preload("res://audio/sfx/slipper_tile_01.ogg"),
	preload("res://audio/sfx/slipper_tile_02.ogg"),
	preload("res://audio/sfx/slipper_tile_03.ogg"),
	preload("res://audio/sfx/slipper_tile_04.ogg"),
]
@export_range(0.0, 0.5) var pitch_variation: float = 0.06
@export_range(0.0, 12.0) var volume_variation_db: float = 1.0

var _rng := RandomNumberGenerator.new()
var _previous: AudioStream
var _base_pitch: float
var _base_volume: float


func _ready() -> void:
	bus = &"SFX"
	_rng.randomize()
	_base_pitch = pitch_scale
	_base_volume = volume_db


func play_footstep(surface: StringName) -> void:
	if surface != &"tile":
		return
	var candidates: Array[AudioStream] = []
	for clip in tile_variants:
		if clip != null and clip != _previous and not candidates.has(clip):
			candidates.append(clip)
	# A bank with fewer than two unique clips cannot guarantee no repeats.
	if candidates.is_empty():
		return
	stream = candidates[_rng.randi_range(0, candidates.size() - 1)]
	_previous = stream
	pitch_scale = maxf(0.01, _base_pitch * _rng.randf_range(1.0 - pitch_variation, 1.0 + pitch_variation))
	volume_db = _base_volume + _rng.randf_range(-volume_variation_db, volume_variation_db)
	play()
