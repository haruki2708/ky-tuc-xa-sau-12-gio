extends Node3D
## Physical leaf only; locks and interaction prompts belong to Lane A/core.
var is_open: bool = false


func set_open(value: bool) -> void:
	is_open = value
	$Leaf.rotation.y = PI / 2.0 if value else 0.0
	# T-250: a door of two leaves (the fire door) swings its passive, visual-only LeafB the other way, to the
	# same side; Leaf alone keeps the collision.
	var second := get_node_or_null("LeafB") as Node3D
	if second != null:
		second.rotation.y = -PI / 2.0 if value else 0.0
	# Keep the opened door out of the traversal envelope.
	$Leaf.collision_layer = 0 if value else 1
