extends "res://scenes/levels/ch1v2/hinged.gd"
## T-222 (D-127): room 407's balcony door, geometry only. Its Pivot sits on the hinge line (east
## jamb, outside face of the wall) and carries the Tripo leaf and the leaf's collision (room407.gd).
## Open when a chapter starts: swung out against the outside wall, clear of the way onto the balcony.

## Past square, nearly flat on the wall; the lever on the wall side keeps the leaf 8 degrees off it.
@export_range(-180.0, 180.0) var open_degrees: float = -172.0


func _init() -> void:
	is_open = true


func set_open(value: bool) -> void:
	is_open = value
	if is_node_ready():
		$Pivot.rotation.y = open_angle() if value else 0.0


## How far the leaf turns when open (radians); a hand-swung door tweens to this.
func open_angle() -> float:
	return deg_to_rad(open_degrees)
