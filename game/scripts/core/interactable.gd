class_name Interactable
extends Area3D
## Base for anything the player can use (doors, switches, papers...).
## Lives on collision layer 3 ("interactable"); give it a CollisionShape3D child.
## Subclasses override _on_interact(); the player's raycast calls interact().

const LAYER_INTERACTABLE := 1 << 2

## Translation key shown as the on-screen prompt, e.g. "PROMPT_OPEN_DOOR".
@export var prompt_key: String = "PROMPT_INTERACT"
@export var enabled: bool = true


func _init() -> void:
	collision_layer = LAYER_INTERACTABLE
	collision_mask = 0


func interact(player: Node) -> void:
	if not enabled:
		return
	_on_interact(player)
	EventBus.interacted.emit(self)


func _on_interact(_player: Node) -> void:
	pass
