class_name FloorMuffle
extends Node
## Child of any AudioStreamPlayer3D. Private bus keeps filtering source-local.
## Set floor_base_y to a slab height shared by all floors (including negative y).

@export var floor_height: float = 3.3
@export var floor_base_y: float = 0.0
@export var listener: Node3D
@export var loss_per_floor_db: float = 8.0
## Optional source-local occlusion, independent of the floor gap (T-164 wall taps).
@export var maximum_cutoff_hz: float = 20500.0
@export var extra_loss_db: float = 0.0

var floor_gap: int = 0
var _source: AudioStreamPlayer3D
var _original_bus: StringName
var _private_bus: StringName
var _filter: AudioEffectLowPassFilter


func _ready() -> void:
	_source = get_parent() as AudioStreamPlayer3D
	if _source == null:
		set_process(false)
		return
	_original_bus = _source.bus
	_private_bus = StringName("FloorMuffle_%d" % get_instance_id())
	AudioServer.add_bus()
	var index := AudioServer.bus_count - 1
	AudioServer.set_bus_name(index, _private_bus)
	AudioServer.set_bus_send(index, _original_bus)
	_filter = AudioEffectLowPassFilter.new()
	_filter.resonance = 0.5
	_filter.db = AudioEffectFilter.FILTER_24DB
	AudioServer.add_bus_effect(index, _filter)
	_source.bus = _private_bus
	_process(0.0)


func _process(_delta: float) -> void:
	var target: Node3D = listener if is_instance_valid(listener) else get_viewport().get_audio_listener_3d()
	if target == null:
		target = get_viewport().get_camera_3d()
	if target != null:
		update_listener_position(target.global_position)
	else:
		_apply_gap(0)


func update_listener_position(world_position: Vector3) -> void:
	if not is_instance_valid(_source) or not world_position.is_finite():
		return
	var height := floor_height if is_finite(floor_height) and floor_height > 0.1 else 3.3
	var base := floor_base_y if is_finite(floor_base_y) else 0.0
	var source_floor := floori((_source.global_position.y - base + 0.001) / height)
	var listener_floor := floori((world_position.y - base + 0.001) / height)
	_apply_gap(clampi(absi(source_floor - listener_floor), 0, 6))


func _apply_gap(gap: int) -> void:
	var index := AudioServer.get_bus_index(_private_bus)
	if index < 0 or _filter == null:
		return
	floor_gap = gap
	var ceiling := clampf(maximum_cutoff_hz, 100.0, 20500.0) if is_finite(maximum_cutoff_hz) else 20500.0
	_filter.cutoff_hz = minf(ceiling, 20500.0 if gap == 0 else maxf(450.0, 2200.0 / gap))
	AudioServer.set_bus_effect_enabled(index, 0, gap > 0 or ceiling < 20500.0)
	var loss := clampf(loss_per_floor_db, 0.0, 20.0) if is_finite(loss_per_floor_db) else 8.0
	var extra := clampf(extra_loss_db, 0.0, 40.0) if is_finite(extra_loss_db) else 0.0
	AudioServer.set_bus_volume_db(index, -loss * gap - extra)


func _exit_tree() -> void:
	if is_instance_valid(_source) and _source.bus == _private_bus:
		_source.bus = _original_bus
	var index := AudioServer.get_bus_index(_private_bus)
	if index >= 0:
		AudioServer.remove_bus(index)
