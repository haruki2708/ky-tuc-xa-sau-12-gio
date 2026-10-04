extends Marker3D
## Reversible physical hinge; no interaction, inventory or puzzle decisions.
var is_open: bool = false


func _ready() -> void:
	set_open(is_open)


func set_open(value: bool) -> void:
	is_open = value
	if is_node_ready():
		$Pivot.rotation.y = PI / 2.0 if value else 0.0
