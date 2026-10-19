class_name Interactable
extends Area3D
## Base for anything the player can use (doors, switches, papers...).
## Lives on collision layer 3 ("interactable"); give it a CollisionShape3D child.
## Subclasses override _on_interact(); the player's raycast calls interact().

const LAYER_INTERACTABLE := 1 << 2

## Translation key shown as the on-screen prompt, e.g. "PROMPT_OPEN_DOOR".
@export var prompt_key: String = "PROMPT_INTERACT"
@export var enabled: bool = true
## T-220: while a hand does the interaction, how long the thing takes to move (a door swings
## with the hand instead of snapping). Zero for a plain press.
var hand_seconds: float = 0.0


func _init() -> void:
	collision_layer = LAYER_INTERACTABLE
	collision_mask = 0


func interact(player: Node) -> void:
	if not enabled:
		return
	_on_interact(player)
	EventBus.interacted.emit(self)


## T-220: the same interaction, done by a hand that keeps hold for `seconds`.
func interact_by_hand(player: Node, seconds: float) -> void:
	hand_seconds = maxf(0.0, seconds) if is_finite(seconds) else 0.0
	interact(player)
	hand_seconds = 0.0


## The HandTarget a full body reaches for, or null for a plain press.
func hand_target() -> HandTarget:
	for child: Node in get_children():
		if child is HandTarget:
			return child as HandTarget
	return find_child("HandTarget", true, false) as HandTarget


func _on_interact(_player: Node) -> void:
	pass
