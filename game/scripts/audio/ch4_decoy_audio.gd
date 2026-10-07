class_name Ch4DecoyAudio
extends Node3D

@export_dir var sound_directory: String = Ch4AudioBank.DIRECTORY
var remaining: float = 0.0
var enabled: bool = true
var _charges: int = -1
var _disabled: bool = false
var _ring: AudioStreamPlayer3D
var _foley: AudioStreamPlayer3D


func _ready() -> void:
	_ring = Ch4AudioBank.spatial(self, &"SFX")
	_foley = Ch4AudioBank.spatial(self, &"SFX")
	EventBus.phone_decoy_thrown.connect(_on_throw)
	EventBus.checkpoint_loaded.connect(_reset)
	EventBus.player_death_started.connect(_reset)


func _on_throw(at: Vector3, charges_left: int) -> void:
	if _disabled or not enabled or not at.is_finite() or charges_left < 0:
		return
	if charges_left == _charges and global_position.is_equal_approx(at):
		return
	global_position = at
	_charges = charges_left
	remaining = 6.0
	_ring.stop()
	Ch4AudioBank.play(_ring, "decoy_ring", sound_directory)
	Ch4AudioBank.play(_foley, "phone_land", sound_directory)
	# Gameplay owns noise_emitted; audio must never emit it a second time.


func _process(delta: float) -> void:
	if remaining <= 0.0:
		return
	remaining = maxf(0.0, remaining - delta)
	if remaining <= 0.000001:
		remaining = 0.0
		_ring.stop()
		if _charges == 0:
			Ch4AudioBank.play(_foley, "battery_empty", sound_directory)


func _reset(_reason: Variant = null) -> void:
	remaining = 0.0
	_charges = -1
	_ring.stop()
	_foley.stop()


func stop_emitting() -> void:
	_disabled = true
	_reset()
