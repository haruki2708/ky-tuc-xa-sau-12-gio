class_name BuildingScreams
extends Node3D
## Bounded delayed spatial wave. Caller chooses when/where any deaths happen.

@export_dir var sound_directory: String = Ch1AudioBank.DIRECTORY
@export var floor_base_y: float = 0.0
@export var listener: Node3D
var _pending: Array[Dictionary] = []
var _voices: Array[AudioStreamPlayer3D] = []
var _rng := RandomNumberGenerator.new()
var _last_variant: int = -1


func play_wave(origin: Vector3, count: int = 4, spread_seconds: float = 6.0) -> void:
	if not is_inside_tree() or not origin.is_finite() or not is_finite(spread_seconds) or spread_seconds < 0.0:
		return
	# Replace the previous wave; never accumulate unbounded timers or voices.
	stop_emitting()
	count = clampi(count, 0, 12)
	for index in count:
		var offset := Vector3(_rng.randf_range(-9.0, 9.0), (index % 3) * 3.3, _rng.randf_range(-7.0, 7.0))
		_pending.append({"delay": spread_seconds * index / maxi(1, count - 1), "position": origin + offset})
	_process(0.0)


func play_at(world_position: Vector3) -> void:
	if not is_inside_tree() or not world_position.is_finite() or _voices.size() >= 12:
		return
	var variant := _rng.randi_range(0, 2)
	if variant >= _last_variant:
		variant += 1
	variant %= 4
	_last_variant = variant
	var clip := Ch1AudioBank.clip("scream_%02d" % (variant + 1), sound_directory)
	if clip == null:
		return
	var voice := AudioStreamPlayer3D.new()
	voice.bus = &"SFX"
	voice.stream = clip
	voice.unit_size = 4.0
	voice.max_distance = 70.0
	voice.volume_db = -8.0 if Ch1AudioBank.reduced() else 0.0
	add_child(voice)
	voice.global_position = world_position
	var muffle := FloorMuffle.new()
	muffle.floor_base_y = floor_base_y
	muffle.listener = listener
	voice.add_child(muffle)
	_voices.append(voice)
	voice.finished.connect(func() -> void:
		_voices.erase(voice)
		voice.queue_free())
	voice.play()


func _process(delta: float) -> void:
	for index in range(_pending.size() - 1, -1, -1):
		_pending[index]["delay"] -= delta
		if float(_pending[index]["delay"]) <= 0.0:
			var point: Vector3 = _pending[index]["position"]
			_pending.remove_at(index)
			play_at(point)


func stop_emitting() -> void:
	_pending.clear()
	for voice in _voices:
		voice.stop()
		voice.queue_free()
	_voices.clear()
