extends Interactable
## Greybox toggle only. Story locks and rule consequences belong to gameplay.

var is_open: bool = false


func _on_interact(_player: Node) -> void:
	set_open(not is_open)


func set_open(value: bool) -> void:
	is_open = value
	$Pivot.rotation.y = -PI / 2.0 if is_open else 0.0
	var floor_root := get_parent()
	if floor_root.has_method("sync_door_anchor"):
		floor_root.sync_door_anchor()
