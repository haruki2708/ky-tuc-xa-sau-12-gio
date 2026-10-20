class_name HandTarget
extends Marker3D
## T-220 (D-121): where a hand takes hold of its parent Interactable. A player with a full
## body (PlayerBody) reaches here for one second instead of using the thing at once.
## Place the marker on the grip point itself: the lever, the edge, and for a paper just inside
## its right-hand side edge, half way up (the owner: a sheet is taken by a side edge, 19/10).
## For pick_up keep the marker's axes on the thing's own (a paper's +Z face), so the face turns
## to the eyes when lifted and the sheet stays upright. A thing used from either side (a door)
## has one HandTarget per side; the one nearest the player is taken.

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
