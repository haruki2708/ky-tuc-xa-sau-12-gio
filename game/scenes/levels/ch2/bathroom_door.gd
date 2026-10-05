extends "res://scenes/levels/ch1v2/hinged.gd"
## Visual impact only. Lane A/core counts pushes and requests opening.
var _shake: Tween


func set_stuck_shake(strength: float) -> void:
	if not is_node_ready() or is_open:
		return
	if _shake:
		_shake.kill()
	var amount := clampf(strength, 0.0, 1.0) if is_finite(strength) else 0.0
	$Pivot.rotation.y = 0.0
	_shake = create_tween()
	for angle in [.055, -.035, .025, -.012, 0.0]:
		_shake.tween_property($Pivot, "rotation:y", angle * amount, .045)


func set_open(value: bool) -> void:
	if _shake:
		_shake.kill()
	super.set_open(value)
