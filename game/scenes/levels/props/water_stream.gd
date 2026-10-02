extends Node3D
## A thin stream of water from a tap spout into the basin (T-138). Origin at
## the nozzle; the stream falls `height` metres. The story turns it on and off
## with set_running().

const SHADER := preload("res://rendering/water_stream.gdshader")

@export var height: float = 0.12
@export var running: bool = false:
	set(value):
		running = value
		if is_node_ready():
			_sync()

var _splash: MeshInstance3D
var _time: float = 0.0


func _ready() -> void:
	var material := ShaderMaterial.new()
	material.shader = SHADER
	var stream_mesh := CylinderMesh.new()
	stream_mesh.top_radius = 0.0045
	stream_mesh.bottom_radius = 0.007
	stream_mesh.height = height
	stream_mesh.radial_segments = 6
	stream_mesh.rings = 1
	stream_mesh.material = material
	var stream := MeshInstance3D.new()
	stream.name = "Stream"
	stream.mesh = stream_mesh
	stream.position.y = -height / 2.0
	stream.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(stream)
	var splash_mesh := CylinderMesh.new()
	splash_mesh.top_radius = 0.03
	splash_mesh.bottom_radius = 0.035
	splash_mesh.height = 0.004
	splash_mesh.radial_segments = 8
	splash_mesh.rings = 1
	splash_mesh.material = material
	_splash = MeshInstance3D.new()
	_splash.name = "Splash"
	_splash.mesh = splash_mesh
	_splash.position.y = -height
	_splash.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(_splash)
	_sync()


func set_running(on: bool) -> void:
	running = on


func _sync() -> void:
	visible = running
	set_process(running)


func _process(delta: float) -> void:
	_time += delta
	var wobble := 1.0 + 0.18 * sin(_time * 31.0) * sin(_time * 7.0)
	_splash.scale = Vector3(wobble, 1.0, wobble)
