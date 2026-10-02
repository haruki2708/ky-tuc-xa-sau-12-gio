class_name AmbientZone
extends AudioZone
## Paths are relative to this Area3D and must point to AmbientEmitter nodes.

@export var emitters: Array[NodePath] = []
@export_range(0.0, 10.0) var fade_time: float = 1.0

var _sources: Array[AmbientEmitter] = []
var _gain: float = 0.0
var _fade: Tween


func _ready() -> void:
	super._ready()
	for path in emitters:
		var source := get_node_or_null(path) as AmbientEmitter
		if source != null and not _sources.has(source):
			_sources.append(source)
	_set_gain(0.0)
	occupancy_changed.connect(_on_occupancy_changed)


func _on_occupancy_changed(inside: bool) -> void:
	if _fade != null:
		_fade.kill()
	var target := 1.0 if inside else 0.0
	if fade_time <= 0.0:
		_set_gain(target)
	else:
		_fade = create_tween()
		_fade.tween_method(_set_gain, _gain, target, fade_time)


func _set_gain(gain: float) -> void:
	_gain = gain
	for source in _sources:
		if is_instance_valid(source):
			source.set_zone_gain(get_instance_id(), gain)


func _exit_tree() -> void:
	if _fade != null:
		_fade.kill()
	for source in _sources:
		if is_instance_valid(source):
			source.remove_zone_gain(get_instance_id())
	super._exit_tree()
