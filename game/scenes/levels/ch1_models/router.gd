extends Node3D
## Powered LED blinks visually; network/puzzle state belongs to integrator.
@export var led_on: bool = true
var _elapsed: float = 0.0


func _ready() -> void:
	set_led(led_on)


func set_led(on: bool) -> void:
	led_on = on
	_elapsed = 0.0
	if is_node_ready():
		$LED.visible = on


func _process(delta: float) -> void:
	_elapsed = fmod(_elapsed + delta, 1.2)
	$LED.visible = led_on and (_elapsed < .85 or _elapsed > 1.05)
