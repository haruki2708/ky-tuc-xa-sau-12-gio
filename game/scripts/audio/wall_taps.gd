class_name WallTaps
extends Node3D
## Flat row/column digit pairs. Gaps are measured between tap onsets.

signal sequence_finished
signal tap_played(group_index: int, tap_index: int)

@export_dir var sound_directory: String = Ch1V2AudioBank.DIRECTORY
@export var tap_interval: float = 0.28
@export var other_side: bool = true
@export var listener: Node3D
@export var floor_base_y: float = 0.0
var _source: AudioStreamPlayer3D
var _muffle: FloorMuffle
var _schedule: Array[Dictionary] = []
var _cursor: int = 0
var _elapsed: float = 0.0
var _finish_at: float = 0.0
var _active: bool = false
var _generation: int = 0
var _variant: int = 0


func _ready() -> void:
	_source = AudioStreamPlayer3D.new()
	_source.name = "Taps"
	_source.bus = &"SFX"
	_source.unit_size = 3.0
	add_child(_source)
	_muffle = FloorMuffle.new()
	_muffle.listener = listener
	_muffle.floor_base_y = floor_base_y
	_source.add_child(_muffle)
	set_other_side(other_side)
	EventBus.chapter_started.connect(_reset)
	EventBus.checkpoint_loaded.connect(_reset)


func set_other_side(enabled: bool) -> void:
	other_side = enabled
	if _muffle != null:
		_muffle.maximum_cutoff_hz = 900.0 if enabled else 20500.0
		_muffle.extra_loss_db = 4.0 if enabled else 0.0
		_muffle._process(0.0)


func play_sequence(world_position: Vector3, groups: Array[int], gap_digit: float = 1.0, gap_letter: float = 2.5) -> bool:
	if not is_node_ready() or not world_position.is_finite() or groups.size() > 128:
		return false
	if not is_finite(tap_interval) or tap_interval < 0.05 or not is_finite(gap_digit) or not is_finite(gap_letter) or gap_digit < tap_interval or gap_letter < tap_interval:
		return false
	for count in groups:
		if count < 1 or count > 5:
			return false
	stop_emitting()
	global_position = world_position
	_muffle._process(0.0)
	var onset := 0.0
	for group_index in groups.size():
		for tap_index in groups[group_index]:
			_schedule.append({"at": onset, "group": group_index, "tap": tap_index})
			if tap_index < groups[group_index] - 1:
				onset += tap_interval
		if group_index < groups.size() - 1:
			onset += gap_letter if group_index % 2 == 1 else gap_digit
	if _schedule.is_empty():
		sequence_finished.emit()
		return true
	_active = true
	_finish_at = onset + 0.5
	_process(0.0)
	return true


func play_tap(world_position: Vector3) -> void:
	play_sequence(world_position, [1])


func _process(delta: float) -> void:
	if not _active:
		return
	_elapsed += delta
	var generation := _generation
	while _cursor < _schedule.size() and float(_schedule[_cursor]["at"]) <= _elapsed + 0.000001:
		var entry: Dictionary = _schedule[_cursor]
		_cursor += 1
		_variant = (_variant + 1) % 3
		_source.stream = Ch1V2AudioBank.clip("wall_tap_%02d" % (_variant + 1), sound_directory)
		if _source.stream != null:
			_source.play()
		tap_played.emit(entry["group"], entry["tap"])
		if generation != _generation:
			return
	if _elapsed >= _finish_at:
		_active = false
		_schedule.clear()
		sequence_finished.emit()


func stop_emitting() -> void:
	_generation += 1
	_active = false
	_schedule.clear()
	_cursor = 0
	_elapsed = 0.0
	if _source != null:
		_source.stop()


func _reset(_value: Variant) -> void:
	stop_emitting()
