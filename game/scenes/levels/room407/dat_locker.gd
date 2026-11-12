extends Marker3D
## Visual lock only; puzzle solution and charger contents belong to gameplay.

var unlocked: bool = false
## T-245 (D-163): the furnished padlock's shackle (room407.gd hangs it here as Shackle/Swing, its
## origin on the long leg): unlocked, it lifts out of the short leg's hole and turns about the long one.
const SWING_LIFT := 0.011
const SWING_TURN := deg_to_rad(65.0)


func set_unlocked(value: bool) -> void:
	unlocked = value
	if not is_node_ready():
		return
	var swing := get_node_or_null("Shackle/Swing") as Node3D
	if swing != null:
		$Shackle.position.y = 0.0
		$Shackle.rotation.z = 0.0
		if not swing.has_meta(&"shut"):
			swing.set_meta(&"shut", swing.transform)
		var shut: Transform3D = swing.get_meta(&"shut")
		swing.transform = shut * Transform3D(Basis(Vector3.UP, SWING_TURN), Vector3.UP * SWING_LIFT) if value else shut
		return
	$Shackle.position.y = 0.035 if value else 0.0
	$Shackle.rotation.z = -0.35 if value else 0.0


func _ready() -> void:
	set_unlocked(unlocked)
