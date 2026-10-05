class_name FootstepPlayer
extends AudioStreamPlayer3D
## Lane A integration: connect Player.footstep(surface, intensity) to play_footstep.
## intensity 0..1 (walk ~0.6, sprint 1). Unsupported surfaces stay silent.

## Intensity at or above this uses the running bank.
const RUN_THRESHOLD: float = 0.8

@export var tile_variants: Array[AudioStream] = [
	preload("res://audio/sfx/slipper_tile_01.ogg"),
	preload("res://audio/sfx/slipper_tile_02.ogg"),
	preload("res://audio/sfx/slipper_tile_03.ogg"),
	preload("res://audio/sfx/slipper_tile_04.ogg"),
]
@export var tile_run_variants: Array[AudioStream] = [
	preload("res://audio/sfx/slipper_run_01.ogg"),
	preload("res://audio/sfx/slipper_run_02.ogg"),
	preload("res://audio/sfx/slipper_run_03.ogg"),
	preload("res://audio/sfx/slipper_run_04.ogg"),
]
@export_range(0.0, 0.5) var pitch_variation: float = 0.04
@export_range(0.0, 12.0) var volume_variation_db: float = 1.5
## Gain added at intensity 0 and 1; interpolated in between.
@export var intensity_gain_db: Vector2 = Vector2(-3.0, 3.0)

var _rng := RandomNumberGenerator.new()
var _previous: Dictionary[int, AudioStream] = {}
var _base_pitch: float
var _base_volume: float


func _ready() -> void:
	bus = &"Footsteps"
	_rng.randomize()
	_base_pitch = pitch_scale
	_base_volume = volume_db


func play_footstep(surface: StringName, intensity: float = 0.5) -> void:
	if surface not in [&"tile", &"grass", &"concrete"]:
		return
	intensity = clampf(intensity, 0.0, 1.0)
	var running := intensity >= RUN_THRESHOLD
	var bank: Array[AudioStream] = tile_run_variants if running else tile_variants
	var bank_id := 1 if running else 0
	if surface != &"tile":
		bank = []
		bank_id = 2 if surface == &"grass" else 3
		for variant in range(1, 5):
			bank.append(Ch3AudioBank.clip("run_%s_%02d" % [surface, variant]))
	var candidates: Array[AudioStream] = []
	for clip in bank:
		if clip != null and clip != _previous.get(bank_id) and not candidates.has(clip):
			candidates.append(clip)
	# A bank with fewer than two unique clips cannot guarantee no repeats.
	if candidates.is_empty():
		return
	stream = candidates[_rng.randi_range(0, candidates.size() - 1)]
	_previous[bank_id] = stream
	pitch_scale = maxf(0.01, _base_pitch * _rng.randf_range(1.0 - pitch_variation, 1.0 + pitch_variation))
	volume_db = _base_volume + lerpf(intensity_gain_db.x, intensity_gain_db.y, intensity) \
		+ _rng.randf_range(-volume_variation_db, volume_variation_db)
	play()
