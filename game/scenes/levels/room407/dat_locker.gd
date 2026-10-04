extends Marker3D
## Visual lock only; puzzle solution and charger contents belong to gameplay.

var unlocked: bool = false


func set_unlocked(value: bool) -> void:
	unlocked = value
	if is_node_ready():
		$Shackle.position.y = 0.035 if value else 0.0
		$Shackle.rotation.z = -0.35 if value else 0.0


func _ready() -> void:
	set_unlocked(unlocked)
