extends Interactable
## Demonstration fixture for player_test.tscn.

@export var light: Light3D


func _on_interact(_player: Node) -> void:
	if is_instance_valid(light):
		light.visible = not light.visible
