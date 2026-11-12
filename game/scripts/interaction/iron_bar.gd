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


## T-249: which way the bar is taken: +1 its far end (+Z) stays the far end of the bar in the hand,
## -1 it is taken by its other end (a pipe looks the same either way round).
var _side: float = 1.0


## The hand takes the end on its right, the rest of the bar running off to the left of whoever
## reaches from `from` (a right hand, palm down, has its thumb to the left): the one HandTarget moves
## to that end.
func hand_target(from: Vector3 = Vector3.INF, rank: Callable = Callable()) -> HandTarget:
	var marker: HandTarget = super(from, rank)
	if marker != null and from.is_finite() and is_inside_tree():
		var local: Vector3 = to_local(from)
		# Kept while the reacher stands about on the bar's own line.
		if absf(local.x) > 0.1:
			_side = 1.0 if local.x > 0.0 else -1.0
		marker.position = Vector3(0.0, 0.0, IronBarWeapon.GRIP_Z * _side)
	return marker


## The bar's frame at the fist that takes it (world): the origin on its middle line where the hand
## closes, +Z toward the end that will be the far one, +X out of the palm (down: the hand comes from
## above).
func grip_frame() -> Transform3D:
	var basis := Basis(Vector3.DOWN, Vector3(_side, 0.0, 0.0), Vector3(0.0, 0.0, _side))
	return Transform3D((global_basis.orthonormalized() * basis).orthonormalized(),
			to_global(Vector3(0.0, 0.0, IronBarWeapon.GRIP_Z * _side)))


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
