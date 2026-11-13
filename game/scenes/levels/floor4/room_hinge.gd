extends "res://scenes/levels/ch1v2/hinged.gd"
## T-255 (D-168): a bathroom or balcony door of rooms 401-406 and 408 (floor4_rooms.gd), geometry only. Shut when a
## chapter starts; open, its Pivot turns open_degrees (the bathroom door into the bathroom, the balcony door out and
## back against the facade, as room 407's). A hand opens and closes it through lane A's HingedDoor.

@export_range(-180.0, 180.0) var open_degrees: float = 90.0


func set_open(value: bool) -> void:
	is_open = value
	if is_node_ready():
		$Pivot.rotation.y = open_angle() if value else 0.0


## How far the leaf turns when open (radians); a hand-swung door tweens to this.
func open_angle() -> float:
	return deg_to_rad(open_degrees)
