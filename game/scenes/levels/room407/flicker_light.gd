extends OmniLight3D
## Deterministic visual pulse, pause-aware; LightHum observes the real energy.

var flickering: bool = false
var _rest_energy: float = 0.0
var _rest_visible: bool = true
var _elapsed: float = 0.0


func set_flicker(value: bool) -> void:
	if value == flickering:
		return
	flickering = value
	if value:
		_rest_energy = light_energy
		_rest_visible = visible
		_elapsed = 0.0
		visible = true
	else:
		light_energy = _rest_energy
		visible = _rest_visible


func _process(delta: float) -> void:
	if not flickering:
		return
	_elapsed += delta
	var pulse := fmod(_elapsed, 0.73)
	light_energy = maxf(_rest_energy, 0.7) if (pulse < .08 or (pulse > .14 and pulse < .29) or pulse > .43) else 0.0
