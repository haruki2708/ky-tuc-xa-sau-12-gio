class_name IronBar
extends Interactable
## An iron bar lying about in chapter 3 (and 4): taking it gives the player a fresh bar (IronBarWeapon).
## T-249 (D-165): a real length of rusted pipe (iron_bar.glb), lying on what is under it. Its origin
## is on the pipe's middle line, its far end toward +Z; the HandTarget is where the fist closes on it,
## near the grip end (IronBarWeapon.GRIP_Z).

## The pipe's middle line rests this far over a surface.
const REST: float = IronBarWeapon.RADIUS + 0.001

@export var max_hits: int = 8


func _ready() -> void:
	add_child(IronBarWeapon.make_model())


## Lie on a surface at this height (world).
func rest_on(surface_y: float) -> void:
	global_position.y = surface_y + REST


func interact(player: Node) -> void:
	if not enabled or not CarryItem.player_can_use(player) or not player.has_method("give_bar"):
		return
	enabled = false
	collision_layer = 0
	hide()
	player.call("give_bar", max_hits)
	EventBus.interacted.emit(self)
	# T-249: a hand that took it (interact_by_hand, PlayerBody) still stands up with it: the body
	# works on this node until its action is done.
	if hand_seconds > 0.0 and is_inside_tree():
		await get_tree().create_timer(hand_seconds + 0.5, false).timeout
	queue_free()
