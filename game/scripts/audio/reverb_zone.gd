class_name ReverbZone
extends AudioZone
## One listener/SFX bus. Higher mix_priority wins; latest entry breaks ties.
## Retarget one shared tween from current values so overlaps never reset the bus.

enum Preset { ROOM, CORRIDOR, BATHROOM, STADIUM, CANTEEN, STAIRS }
const PRESETS: Array[Vector3] = [
	Vector3(0.35, 0.65, 0.12), Vector3(0.7, 0.45, 0.22), Vector3(0.85, 0.2, 0.32),
	Vector3(0.95, 0.65, 0.12), Vector3(0.45, 0.8, 0.1), Vector3(0.75, 0.4, 0.24),
]
const PARAMETERS: Array[StringName] = [&"room_size", &"damping", &"wet"]

@export var preset: Preset = Preset.ROOM
@export var mix_priority: int = 0
@export_range(0.0, 5.0) var fade_time: float = 0.35

static var _zones: Array[ReverbZone] = []
static var _effect: AudioEffectReverb
static var _baseline: Vector3
static var _transition: Tween
static var _sequence: int = 0
var _entry_order: int = 0


func _ready() -> void:
	super._ready()
	if _zones.is_empty():
		var index := AudioServer.get_bus_index(&"SFX")
		if index >= 0:
			for effect_index in AudioServer.get_bus_effect_count(index):
				var candidate := AudioServer.get_bus_effect(index, effect_index) as AudioEffectReverb
				if candidate != null:
					_effect = candidate
					_baseline = Vector3(_effect.room_size, _effect.damping, _effect.wet)
					break
	_zones.append(self)
	occupancy_changed.connect(_on_occupancy_changed)


func _on_occupancy_changed(inside: bool) -> void:
	if inside:
		_sequence += 1
		_entry_order = _sequence
	_refresh_mix()


func _refresh_mix() -> void:
	if _effect == null:
		return
	if _transition != null:
		_transition.kill()
	var winner: ReverbZone
	for zone in _zones:
		if not zone.occupied:
			continue
		if winner == null or zone.mix_priority > winner.mix_priority or (zone.mix_priority == winner.mix_priority and zone._entry_order > winner._entry_order):
			winner = zone
	var target := _baseline if winner == null else PRESETS[winner.preset]
	var duration := fade_time if winner == null else winner.fade_time
	if duration <= 0.0 or _zones.is_empty():
		for index in PARAMETERS.size():
			_effect.set(PARAMETERS[index], target[index])
	else:
		# SceneTree ownership survives the departing zone until the fade completes.
		_transition = get_tree().create_tween().set_parallel(true)
		for index in PARAMETERS.size():
			_transition.tween_property(_effect, String(PARAMETERS[index]), target[index], duration)


func _exit_tree() -> void:
	_zones.erase(self)
	_refresh_mix()
	if _zones.is_empty():
		_effect = null
		_transition = null
		_sequence = 0
	super._exit_tree()
