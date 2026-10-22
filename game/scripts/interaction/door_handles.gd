class_name DoorHandles
extends RefCounted
## T-220 (D-124): lever handles on both faces of a door leaf, each with a HandTarget riding its
## lever, so a full body takes the lever, presses it down, then the door swings.

const LEVER := preload("res://assets/models/props/door_lever.glb")
## How far a pressed lever turns.
const PRESS_DEGREES: float = 35.0
## Where the hand takes the bar, in lever space (the bar runs along +X, out of the face is +Z).
const GRIP_POINT: Vector3 = Vector3(0.07, 0.0, 0.034)
## T-222: the Tripo lever's bar is shorter (to x 0.078) and stands further off the face (z 0.046..0.065).
const TRIPO_GRIP_POINT: Vector3 = Vector3(0.06, 0.0, 0.056)


## `leaf`: what swings with the door (its pivot, or a handle pivot on it). `centre`: the handle's
## spindle at mid-thickness of the leaf (world). `normal`: one face's outward normal (world).
## `hinge`: toward the hinge (world); the bars point that way. `half`: half the leaf's thickness.
static func fit(leaf: Node3D, centre: Vector3, normal: Vector3, hinge: Vector3, half: float) -> Array[HandTarget]:
	var targets: Array[HandTarget] = []
	for side: float in [1.0, -1.0]:
		var out: Vector3 = (normal * side).normalized()
		var bar: Vector3 = (hinge - out * hinge.dot(out)).normalized()
		var basis := Basis(bar, out.cross(bar), out)
		var lever := Node3D.new()
		lever.name = "LeverFront" if side > 0.0 else "LeverBack"
		leaf.add_child(lever)
		lever.global_transform = Transform3D(basis, centre + out * half)
		lever.add_child(LEVER.instantiate())
		targets.append(_take(lever, GRIP_POINT))
	return targets


## T-222: HandTargets on levers a leaf already has (the Tripo levers of the upgraded shell, built
## in the same lever space), in place of fitting new ones.
static func take(levers: Array[Node], grip_point: Vector3 = TRIPO_GRIP_POINT) -> Array[HandTarget]:
	var targets: Array[HandTarget] = []
	for lever: Node in levers:
		targets.append(_take(lever as Node3D, grip_point))
	return targets


static func _take(lever: Node3D, grip_point: Vector3) -> HandTarget:
	var target := HandTarget.new()
	target.name = "HandTarget"
	target.grip = HandTarget.Grip.GRIP
	target.lever = lever
	target.lever_axis = Vector3.BACK
	# Pressing sends the bar's end down: toward lever -Y where lever Y is up, else +Y.
	target.lever_degrees = -PRESS_DEGREES if lever.global_basis.y.y > 0.0 else PRESS_DEGREES
	lever.add_child(target)
	target.position = grip_point
	return target
