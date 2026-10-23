extends Marker3D
## Visual switch state only; overload rules and cooldown belong to gameplay.
## T-226 (D-136): the strip, its rockers and lamps are the Blender model (build_electrics.py) instead
## of PS1 boxes: each RockerN rides Switch N's Rocker pivot and each LEDN lamp becomes Switch N's LED,
## so gameplay and lane A's switch areas keep their nodes.
## The kettle's plug is white; the laptop's and the router's red-taped adapter are black.
const KETTLE_WHITE := Color(0.82, 0.8, 0.74)
var switches: Array[bool] = [true, true, false]
var tripped: bool = false
var _spark_left: float = 0.0


func _ready() -> void:
	_dress()
	_sync()


func _dress() -> void:
	var model := get_node_or_null("Model") as Node3D
	if model == null:
		return
	(model.get_node("Case") as Node3D).reparent(self)
	for i in range(1, 4):
		var rocker := model.get_node("Rocker%d" % i) as Node3D
		var pivot := get_node("Switch%d/Rocker" % i) as Node3D
		pivot.global_transform = rocker.global_transform
		rocker.reparent(pivot)
		var lamp := model.get_node("LED%d" % i) as MeshInstance3D
		var led := get_node("Switch%d/LED" % i) as MeshInstance3D
		led.mesh = lamp.mesh
		led.global_transform = lamp.global_transform
	model.free()
	var white := StandardMaterial3D.new()
	white.albedo_color = KETTLE_WHITE
	white.roughness = 0.5
	($KettlePlug/Body as MeshInstance3D).material_override = white


func set_switch(i: int, on: bool) -> bool:
	if i < 1 or i > 3:
		return false
	switches[i - 1] = on and not tripped
	_sync()
	return true


func set_tripped(value: bool) -> void:
	tripped = value
	if value:
		switches.fill(false)
	_sync()


func spark() -> void:
	_spark_left = .18
	if is_node_ready():
		$Sparks.visible = true


func _sync() -> void:
	if not is_node_ready():
		return
	for i in range(3):
		var enabled: bool = switches[i] and not tripped
		get_node("Switch%d/LED" % (i + 1)).visible = enabled
		get_node("Switch%d/Rocker" % (i + 1)).rotation.x = -.15 if enabled else .15


func _process(delta: float) -> void:
	_spark_left = maxf(0.0, _spark_left - delta)
	$Sparks.visible = _spark_left > 0.0
