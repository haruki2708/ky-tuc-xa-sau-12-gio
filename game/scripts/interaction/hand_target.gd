class_name HandTarget
extends Marker3D
## T-220 (D-121): where a hand takes hold of its parent Interactable. A player with a full
## body (PlayerBody) reaches here for one second instead of using the thing at once.
## Place the marker on the grip point itself: the lever, the edge, and for a paper just inside
## its right-hand side edge, half way up (the owner: a sheet is taken by a side edge, 19/10).
## For pick_up keep the marker's axes on the thing's own (a paper's +Z face), so the face turns
## to the eyes when lifted and the sheet stays upright. A thing used from either side (a door)
## has one HandTarget per side; the one nearest the player is taken.
## T-239: a paper has one per edge (readable.gd), each with +X out across its edge: the pinch's
## fingers run along its +Y, and the hand takes the edge its reach suits (preference, best).

enum Grip { GRIP, PINCH, HOOK }

@export var grip: Grip = Grip.GRIP
## The thing comes away in the hand (a paper): it is lifted to the eyes before it is used,
## and goes back to its place when the player is done with it.
@export var pick_up: bool = false
## D-124: a lever the hand turns before the thing moves (a door handle). Put this HandTarget
## under the lever so the hand rides it down; lever_degrees about lever_axis (lever space).
@export var lever: Node3D
@export var lever_axis: Vector3 = Vector3.BACK
@export var lever_degrees: float = 0.0


## T-239: how well this marker suits a hand reaching from `from` (higher is better).
## - A paper's edge (pick_up): the pinch whose fingers (+Y) point most along the reach as it runs
##   over the sheet, so the wrist stays straight (the owner saw it bent, 09/11). A sheet standing up
##   that the reach meets square on: the one whose fingers point up (its right-hand edge).
## - A door's grip (DoorHandles.sides): -INF where it must not be used from (see _door_preference).
## - Anything else: the nearest.
func preference(from: Vector3) -> float:
	if has_meta(&"door_levers"):
		return _door_preference(from)
	if pick_up:
		var basis := global_basis.orthonormalized()
		var reach: Vector3 = global_position - from
		reach -= basis.z * reach.dot(basis.z)
		var along: float = basis.y.dot(reach.normalized()) if reach.length() > 0.001 else 0.0
		if absf(basis.z.y) > 0.7:
			return along
		var share: float = clampf(reach.length() / SQUARE_ON, 0.0, 1.0)
		return along * share + basis.y.dot(Vector3.UP) * (1.0 - share)
	return -global_position.distance_squared_to(from)


## T-239 (owner, 09/11): from one side of the doorway only that side's lever, when its face is turned
## toward the body (in room 407 the corridor lever is never used); with that face turned away (the leaf
## open), the leaf's free edge. The nearest of what is left.
func _door_preference(from: Vector3) -> float:
	var hinge := get_meta(&"door_hinge") as Node3D
	var frame: Node3D = hinge.get_parent() as Node3D if is_instance_valid(hinge) else null
	if frame == null:
		return -global_position.distance_squared_to(from)
	var normal: Vector3 = frame.global_basis.orthonormalized() * (get_meta(&"door_normal") as Vector3)
	var side: float = signf((from - hinge.global_position).dot(normal))
	var mine: HandTarget = null
	for target: HandTarget in get_meta(&"door_levers"):
		if is_instance_valid(target) and signf(float(target.get_meta(&"door_side"))) == side:
			mine = target
	var turned: bool = mine != null and (from - mine.global_position).dot(mine.lever.global_basis.z) > 0.0
	var allowed: bool = self == mine and turned
	if not is_instance_valid(lever):
		# The free edge: when that side's lever is turned away.
		allowed = not turned
	return -global_position.distance_squared_to(from) if allowed else -INF


## Below this much reach along a standing sheet (metres) the reach meets it square on.
const SQUARE_ON: float = 0.15
## A paper's pinch whose fingers point further than this off the reach (preference) bends the wrist
## too far: it is taken only when no other edge is within reach.
const MIN_ALONG: float = 0.25
## best()'s rank for a marker out of reach, and what a bent wrist adds.
const OUT_OF_REACH: int = 100
const BENT: int = 10


## The one of `markers` that suits a hand reaching from `from` best; the first without a `from`;
## null if none may be used from there (preference -INF).
## `rank` (optional, marker -> int, lower is better: the body's kind of reach, OUT_OF_REACH if none)
## goes first, so an edge the body reaches with less is taken (as long as the wrist suits it: BENT);
## then the preference. The prompt (can_reach) and the action (perform) both ask it the same, so
## they agree (D-152).
static func best(markers: Array[HandTarget], from: Vector3 = Vector3.INF, rank: Callable = Callable()) -> HandTarget:
	if markers.is_empty():
		return null
	if not from.is_finite():
		return markers[0]
	var values: Dictionary = {}
	var order: Array[HandTarget] = []
	for marker: HandTarget in markers:
		values[marker] = marker.preference(from)
		# -INF: not to be used from here at all (a door's other side).
		if values[marker] > -INF:
			order.append(marker)
	if order.is_empty():
		return null
	order.sort_custom(func(a: HandTarget, b: HandTarget) -> bool: return values[a] > values[b])
	if not rank.is_valid():
		return order[0]
	var chosen: HandTarget = null
	var chosen_rank: int = 0
	for marker: HandTarget in order:
		var value: int = int(rank.call(marker))
		if marker.pick_up and values[marker] < MIN_ALONG:
			value += BENT
		if chosen == null or value < chosen_rank:
			chosen = marker
			chosen_rank = value
		if chosen_rank == 0:
			break
	return chosen
