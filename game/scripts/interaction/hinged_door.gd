class_name HingedDoor
extends Interactable
## T-242 (D-154, D-159): a hinged.gd leaf (room 407's bathroom and balcony doors) opened and closed
## by hand. It rides the leaf (the player looks at the leaf to use it); the leaf swings over the
## hand's hold as Door 407's does, and its levers and free edge take the hand by Door 407's rule
## (DoorHandles.sides). Chapters and the manager still use the hinge's own set_open.

## T-244: for sounds (lane E). `swung` when the leaf starts to turn, open or shut, over `seconds`
## (zero: at once, as the chapter or the manager sets the hinge); `settled` when it has got there.
signal swung(open: bool, seconds: float)
signal settled(open: bool)

## A hand swings the leaf no faster than this (the balcony door turns 172 degrees: it swings on
## after the hand has let go).
const SWING_SPEED: float = deg_to_rad(200.0)
## The leaf's collision is this thick for the player's look (metres).
const LOOK_THICKNESS: float = 0.12

## The hinged.gd node: Pivot, is_open, set_open(), open_angle().
var hinged: Node3D
var grips: Array[HandTarget] = []
var is_open: bool:
	get:
		return is_instance_valid(hinged) and bool(hinged.get("is_open"))
var _swing: Tween
var _swing_open: bool = false
## The hinge as this door last knew it (a change by someone else is told as a swing at once).
var _known_open: bool = false


## Hangs a HingedDoor on `door` (a hinged.gd node whose Pivot carries Leaf/Collision and the
## Tripo levers); null when it has no leaf to ride.
static func fit(door: Node3D) -> HingedDoor:
	var leaf_pivot := door.get_node_or_null("Pivot") as Node3D
	var leaf := door.get_node_or_null("Pivot/Leaf") as Node3D
	var shape := door.get_node_or_null("Pivot/Leaf/Collision") as CollisionShape3D
	if leaf_pivot == null or shape == null or not shape.shape is BoxShape3D:
		return null
	var hand := HingedDoor.new()
	hand.name = String(door.name) + "Hand"
	hand.hinged = door
	leaf_pivot.add_child(hand)
	hand.transform = leaf.transform * shape.transform
	var size: Vector3 = (shape.shape as BoxShape3D).size
	var face := CollisionShape3D.new()
	face.shape = BoxShape3D.new()
	(face.shape as BoxShape3D).size = Vector3(size.x, size.y, maxf(size.z, LOOK_THICKNESS))
	hand.add_child(face)
	var levers: Array[HandTarget] = DoorHandles.take(leaf_pivot.find_children("Lever*", "", true, false))
	hand.grips.append_array(levers)
	hand.grips.append_array(DoorHandles.sides(leaf_pivot, levers))
	hand._update_prompt()
	return hand


## The HingedDoor fitted on `door` (a hinged.gd node), or null.
static func of(door: Node) -> HingedDoor:
	var leaf_pivot := door.get_node_or_null("Pivot") if door != null else null
	if leaf_pivot != null:
		for child: Node in leaf_pivot.get_children():
			if child is HingedDoor:
				return child as HingedDoor
	return null


func hand_target(from: Vector3 = Vector3.INF, rank: Callable = Callable()) -> HandTarget:
	return HandTarget.best(grips, from, rank)


func _on_interact(_player: Node) -> void:
	swing(not is_open, hand_seconds)


## Where the leaf turns to when it is used next (radians about the pivot's Y).
func swing_angle() -> float:
	return 0.0 if is_open else _open_angle()


## The pivot the leaf turns on.
func pivot() -> Node3D:
	return hinged.get_node("Pivot") as Node3D


## Opens or closes the leaf over `seconds` (at once for zero: a plain press).
func swing(open: bool, seconds: float = 0.0) -> void:
	if _swing:
		_swing.kill()
		_swing = null
	var leaf_pivot := pivot()
	var angle: float = _open_angle() if open else 0.0
	_known_open = open
	if not is_finite(seconds) or seconds <= 0.0:
		hinged.call("set_open", open)
		_update_prompt()
		swung.emit(open, 0.0)
		settled.emit(open)
		return
	hinged.set("is_open", open)
	_swing_open = open
	_update_prompt()
	var time: float = maxf(seconds, absf(angle - leaf_pivot.rotation.y) / SWING_SPEED)
	_swing = create_tween().set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
	_swing.tween_property(leaf_pivot, "rotation:y", angle, time).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	_swing.finished.connect(func() -> void:
		_swing = null
		settled.emit(open))
	swung.emit(open, time)


func _ready() -> void:
	_known_open = is_open


func _physics_process(_delta: float) -> void:
	# The hinge was set by someone else meanwhile (a chapter, the manager): that stands.
	if _swing != null and is_open != _swing_open:
		_swing.kill()
		_swing = null
		hinged.call("set_open", is_open)
	if is_open != _known_open:
		_known_open = is_open
		swung.emit(is_open, 0.0)
		settled.emit(is_open)
	_update_prompt()


func _open_angle() -> float:
	return float(hinged.call("open_angle")) if hinged.has_method("open_angle") else PI / 2.0


func _update_prompt() -> void:
	prompt_key = "PROMPT_CLOSE_DOOR" if is_open else "PROMPT_OPEN_DOOR"
