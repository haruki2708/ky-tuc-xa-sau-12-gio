extends Node3D
## Powered LED blinks visually; network/puzzle state belongs to integrator.
@export var led_on: bool = true
var _elapsed: float = 0.0
var network_state: StringName = &"off"
var _steady_power: bool = false
var _network_led: MeshInstance3D


func _ready() -> void:
	_network_led = MeshInstance3D.new()
	_network_led.name = "NetworkLED"
	var mesh := BoxMesh.new()
	mesh.size = Vector3(.012,.007,.003)
	_network_led.mesh = mesh
	_network_led.position = Vector3(-.025,.034,-.069)
	var material := StandardMaterial3D.new()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	_network_led.material_override = material
	add_child(_network_led)
	set_led(led_on)


func set_led(on: bool) -> void:
	_steady_power = false
	led_on = on
	_elapsed = 0.0
	if is_node_ready():
		$LED.visible = on


func set_power(on: bool) -> void:
	set_led(on)
	_steady_power = true
	_update_network()


func set_network(state: StringName) -> bool:
	if state not in [&"off", &"booting", &"red", &"ok"]:
		return false
	network_state = state
	_elapsed = 0.0
	_update_network()
	return true


func _update_network() -> void:
	if not is_instance_valid(_network_led):
		return
	_network_led.visible = led_on and network_state != &"off" and (network_state != &"booting" or fmod(_elapsed,.6)<.3)
	(_network_led.material_override as StandardMaterial3D).albedo_color = Color(.95,.025,.01) if network_state == &"red" else Color(.05,1,.18)


func _process(delta: float) -> void:
	_elapsed = fmod(_elapsed + delta, 1.2)
	$LED.visible = led_on and (_steady_power or _elapsed < .85 or _elapsed > 1.05)
	_update_network()
