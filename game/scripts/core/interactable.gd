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


## The HandTarget a full body reaches for, or null for a plain press. A thing used from either
## side (a door's two handles) has one per side; a paper one per edge (T-239): the one that suits
## a hand reaching from `from` best is taken (HandTarget.best: the nearest, or for a paper the edge
## its reach suits; with `rank`, the body's kind of reach for each first). Without `from`, the
## first. Markers of a nested Interactable (Door 407's latch, T-228) belong to that thing, not to
## this one.
func hand_target(from: Vector3 = Vector3.INF, rank: Callable = Callable()) -> HandTarget:
	var markers: Array[HandTarget] = []
	for node: Node in find_children("*", "Marker3D", true, false):
		var marker := node as HandTarget
		if marker != null and _owns(marker):
			markers.append(marker)
	return HandTarget.best(markers, from, rank)


func _owns(marker: Node) -> bool:
	var node := marker.get_parent()
	while node != self:
		if node == null or node is Interactable:
			return false
		node = node.get_parent()
	return true


func _on_interact(_player: Node) -> void:
	pass
