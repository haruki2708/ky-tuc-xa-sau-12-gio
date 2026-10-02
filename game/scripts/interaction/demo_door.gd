extends Interactable
## Test-room door only; production Door407 remains owned by lane B.

var is_open: bool = false


func _on_interact(_player: Node) -> void:
	is_open = not is_open
	$Pivot.rotation.y = -PI / 2.0 if is_open else 0.0
