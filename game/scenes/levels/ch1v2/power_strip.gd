extends Marker3D
## Visual switch state only; overload rules and cooldown belong to gameplay.
var switches: Array[bool] = [true, true, false]
var tripped: bool = false
var _spark_left: float = 0.0


func _ready() -> void:
	_sync()


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
