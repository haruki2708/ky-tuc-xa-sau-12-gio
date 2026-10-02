class_name AmbientEmitter
extends AudioStreamPlayer3D
## Spatial loop or intermittent one-shot source. Call start_emitting/stop_emitting.

enum PlaybackMode { LOOP, RANDOM_INTERVAL }

@export var playback_mode: PlaybackMode = PlaybackMode.LOOP
@export var start_on_ready: bool = true
@export var clips: Array[AudioStream] = []
@export_range(0.05, 120.0) var interval_min: float = 3.0
@export_range(0.05, 120.0) var interval_max: float = 8.0
@export_range(0.0, 0.5) var pitch_variation: float = 0.04
@export_range(0.0, 12.0) var volume_variation_db: float = 1.5

var _rng := RandomNumberGenerator.new()
var _timer: Timer
var _active: bool = false
var _base_pitch: float
var _base_volume: float
var _volume_offset_db: float = 0.0
var _zone_gains: Dictionary[int, float] = {}


func _ready() -> void:
	_rng.randomize()
	_base_pitch = pitch_scale
	# A zone can register before this node's _ready (scene child order).
	if _zone_gains.is_empty():
		_base_volume = volume_db
	_timer = Timer.new()
	_timer.one_shot = true
	_timer.timeout.connect(_play_clip)
	add_child(_timer)
	finished.connect(_on_finished)
	if start_on_ready:
		start_emitting()


func start_emitting() -> void:
	if _active:
		return
	_active = true
	if playback_mode == PlaybackMode.LOOP:
		_play_clip()
	else:
		_schedule_next()


func stop_emitting() -> void:
	_active = false
	if is_instance_valid(_timer):
		_timer.stop()
	stop()


func _play_clip() -> void:
	if not _active:
		return
	var selected: AudioStream = stream
	if not clips.is_empty():
		selected = clips[_rng.randi_range(0, clips.size() - 1)]
	if selected == null:
		return
	# Imported resources are shared: never alter another emitter's loop flag.
	stream = selected.duplicate() as AudioStream
	if stream is AudioStreamOggVorbis:
		(stream as AudioStreamOggVorbis).loop = playback_mode == PlaybackMode.LOOP
	elif stream is AudioStreamWAV:
		(stream as AudioStreamWAV).loop_mode = AudioStreamWAV.LOOP_FORWARD if playback_mode == PlaybackMode.LOOP else AudioStreamWAV.LOOP_DISABLED
	pitch_scale = maxf(0.01, _base_pitch * _rng.randf_range(1.0 - pitch_variation, 1.0 + pitch_variation))
	_volume_offset_db = _rng.randf_range(-volume_variation_db, volume_variation_db)
	_apply_volume()
	play()


func set_zone_gain(zone_id: int, gain: float) -> void:
	if _zone_gains.is_empty() and not is_node_ready():
		_base_volume = volume_db
	_zone_gains[zone_id] = clampf(gain, 0.0, 1.0)
	_apply_volume()


func remove_zone_gain(zone_id: int) -> void:
	_zone_gains.erase(zone_id)
	_apply_volume()


func _apply_volume() -> void:
	var gain: float = 1.0 if _zone_gains.is_empty() else 0.0
	for value: float in _zone_gains.values():
		gain = maxf(gain, value)
	# Max, not sum: overlapping zones cannot amplify a shared source.
	volume_linear = db_to_linear(_base_volume + _volume_offset_db) * gain


func _on_finished() -> void:
	if not _active:
		return
	if playback_mode == PlaybackMode.RANDOM_INTERVAL:
		_schedule_next()
	else:
		_play_clip()


func _schedule_next() -> void:
	var lower := maxf(0.05, minf(interval_min, interval_max))
	var upper := maxf(lower, maxf(interval_min, interval_max))
	_timer.start(_rng.randf_range(lower, upper))


func _exit_tree() -> void:
	stop_emitting()
