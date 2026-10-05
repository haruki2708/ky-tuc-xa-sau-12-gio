class_name Ch3HordeAudio
extends Node
## One manager per chapter. No global/static registry survives scene changes.

@export var listener: Node3D
@export_range(1, 8) var voice_limit: int = 8
@export var audible_distance: float = 60.0
@export_dir var sound_directory: String = Ch3AudioBank.DIRECTORY
var _rigs: Array[ZombieAudio] = []
var _bed: AudioStreamPlayer
var _stopped: bool = false
var _suspended: bool = false


func _ready() -> void:
	_bed = AudioStreamPlayer.new()
	_bed.bus = &"Ambience"
	add_child(_bed)
	EventBus.checkpoint_loaded.connect(_reset)
	EventBus.player_death_started.connect(_suspend)
	EventBus.chapter_started.connect(_reset)
	EventBus.chapter_finished.connect(_suspend)


func register(rig: ZombieAudio) -> void:
	if is_instance_valid(rig) and not _rigs.has(rig):
		_rigs.append(rig)
		update_mix()


func unregister(rig: ZombieAudio) -> void:
	if is_instance_valid(rig):
		rig.set_audible(false)
	_rigs.erase(rig)
	update_mix()


func _process(_delta: float) -> void:
	update_mix()


func update_mix() -> void:
	var candidates: Array[ZombieAudio] = []
	var hunting_count := 0
	for index in range(_rigs.size() - 1, -1, -1):
		var rig := _rigs[index]
		if not is_instance_valid(rig) or not rig.is_inside_tree() or rig.is_queued_for_deletion():
			_rigs.remove_at(index)
			continue
		if rig.hunting:
			hunting_count += 1
		if not _stopped and not _suspended and is_instance_valid(listener) and listener.is_inside_tree() and rig.hunting and rig.eligible and rig.global_position.distance_to(listener.global_position) < minf(60.0, maxf(0.0, audible_distance)):
			candidates.append(rig)
	if candidates.size() > 1:
		candidates.sort_custom(func(a: ZombieAudio, b: ZombieAudio) -> bool:
			var da := a.global_position.distance_squared_to(listener.global_position)
			var db := b.global_position.distance_squared_to(listener.global_position)
			return a.get_instance_id() < b.get_instance_id() if is_equal_approx(da, db) else da < db)
	candidates.resize(mini(candidates.size(), clampi(voice_limit, 1, 8)))
	# Disable losers first: never transiently exceed the budget when nearest changes.
	for rig in _rigs:
		if not candidates.has(rig):
			rig.set_audible(false)
	for rig in candidates:
		rig.set_audible(true)
	if _bed == null:
		return
	if _stopped or _suspended or hunting_count == 0 or not is_instance_valid(listener) or not listener.is_inside_tree():
		_bed.stop()
	else:
		_bed.volume_linear = clampf(float(hunting_count) / 40.0, 0.0, 1.0)
		Ch3AudioBank.play(_bed, "horde", sound_directory)


func audible_count() -> int:
	var count := 0
	for rig in _rigs:
		if is_instance_valid(rig) and rig.audible:
			count += 1
	return count


func _reset(_reason: Variant) -> void:
	_suspended = false
	for rig in _rigs:
		if is_instance_valid(rig):
			rig.set_hunting(false)
	if _bed != null:
		_bed.stop()


func _suspend(reason: Variant) -> void:
	_reset(reason)
	_suspended = true


func stop_emitting() -> void:
	_stopped = true
	_reset(null)


func _exit_tree() -> void:
	stop_emitting()
