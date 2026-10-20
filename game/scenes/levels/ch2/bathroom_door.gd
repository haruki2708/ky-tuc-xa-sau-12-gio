extends "res://scenes/levels/ch1v2/hinged.gd"
## Visual impact only. Lane A/core counts pushes and requests opening.

## The hinge sits inside the thickness of the bathroom's west wall, so at 90 degrees the leaf
## sank into the wall and vanished (the owner saw it, D-124). Open, it stops short of the wall;
## the basin on that wall was set back 22 cm (placements.json) so the leaf clears it too.
@export_range(1.0, 90.0) var open_degrees: float = 82.0

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
	if is_node_ready():
		$Pivot.rotation.y = open_angle() if value else 0.0


## How far the leaf turns when open (radians); a hand-swung door tweens to this.
func open_angle() -> float:
	return deg_to_rad(open_degrees)
