extends OmniLight3D
@export var phase: float = 0.0
var _time: float = 0.0


func _process(delta: float) -> void:
	_time += delta
	light_energy = .35 if sin(_time * 2.1 + phase) + sin(_time * 17.3 + phase) > -.7 else .015
