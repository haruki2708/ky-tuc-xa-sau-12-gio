class_name Ch4DoorAudio
extends Node3D

# One rig per registered door; parent it to the door/marker, never to the player.
@export var door_id: StringName = &""
@export_dir var sound_directory: String = Ch4AudioBank.DIRECTORY
var fraction: float = 0.0
var enabled: bool = true
var hit_count: int = 0
var burst_count: int = 0
var _until_hit: float = 0.0
var _active: bool = false
var _broken: bool = false
var _disabled: bool = false
var _pound: AudioStreamPlayer3D
var _crack: AudioStreamPlayer3D
var _splinters: AudioStreamPlayer3D
var _growl: AudioStreamPlayer3D


func _ready() -> void:
	_pound = Ch4AudioBank.spatial(self, &"SFX", 20.0)
	_crack = Ch4AudioBank.spatial(self, &"SFX", 20.0)
	_splinters = Ch4AudioBank.spatial(self, &"SFX", 20.0)
	_growl = Ch4AudioBank.spatial(self, &"SFX", 15.0)
	_growl.volume_db = -6.0
	EventBus.door_damage_changed.connect(_damage)
	EventBus.checkpoint_loaded.connect(_reset)


func _damage(id: StringName, value: float) -> void:
	if _disabled or not enabled or id != door_id or door_id.is_empty() or not is_finite(value):
		return
	if value <= 0.0:
		_reset()
		return
	if _broken:
		return
	fraction = clampf(value, 0.0, 1.0)
	if fraction >= 1.0:
		play_burst()
		return
	if not _active:
		_active = true
		_hit()
		_until_hit = 0.7
	# Threshold layers begin immediately; repeated progress events do not restart them.
	if fraction >= 0.8:
		Ch3AudioBank.play(_growl, "zombie_growl")
	else:
		_growl.stop()


func _process(delta: float) -> void:
	if not _active or _disabled or not enabled:
		return
	_until_hit -= delta
	if _until_hit <= 0.000001:
		_hit()
		# Drop missed hits after a stall instead of producing a burst of catch-up audio.
		_until_hit = 0.7


func _hit() -> void:
	hit_count += 1
	_pound.volume_db = lerpf(-12.0, -2.0, fraction)
	_crack.volume_db = -6.0
	_splinters.volume_db = -6.0
	Ch4AudioBank.play(_pound, "door_pound", sound_directory)
	if fraction >= 0.3:
		Ch4AudioBank.play(_crack, "wood_crack", sound_directory)
	if fraction >= 0.6:
		Ch4AudioBank.play(_splinters, "wood_splinters", sound_directory)


func play_burst() -> void:
	if _disabled or not enabled or _broken:
		return
	_silence()
	_broken = true
	burst_count += 1
	_pound.volume_db = 0.0
	Ch4AudioBank.play(_pound, "door_burst_soft" if Ch1AudioBank.reduced() else "door_burst", sound_directory)


func _silence() -> void:
	_active = false
	for player in [_pound, _crack, _splinters, _growl]:
		player.stop()


func _reset(_reason: Variant = null) -> void:
	_silence()
	fraction = 0.0
	_broken = false
	_until_hit = 0.0


func stop_emitting() -> void:
	_disabled = true
	_silence()


func suspend(keep_burst: bool = false) -> void:
	enabled = false
	_active = false
	_crack.stop()
	_splinters.stop()
	_growl.stop()
	if not keep_burst or not _broken:
		_pound.stop()
