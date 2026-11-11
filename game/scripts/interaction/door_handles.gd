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


## T-239 (owner, 09/11): a door's lever HandTargets learn which side of the doorway each is on, and the
## leaf gets one more grip at its free edge, so a body takes (HandTarget._door_preference): from one
## side of the doorway only that side's lever, when its face is turned toward the body; with that
## face turned away (the leaf open), the free edge.
## `pivot` swings the leaf (its parent stays put); `levers` are its two faces' HandTargets.
static func sides(pivot: Node3D, levers: Array[HandTarget]) -> Array[HandTarget]:
	var edges: Array[HandTarget] = []
	if levers.size() != 2 or not pivot.get_parent() is Node3D:
		return edges
	var to_pivot: Basis = pivot.global_basis.orthonormalized().inverse()
	# Each face's outward normal in the doorway's frame, with the leaf shut.
	var shut: Basis = Basis.from_euler(Vector3(pivot.rotation.x, 0.0, pivot.rotation.z))
	var normal: Vector3 = (shut * (to_pivot * levers[0].lever.global_basis.z).normalized()).normalized()
	for target: HandTarget in levers:
		var out: Vector3 = shut * (to_pivot * target.lever.global_basis.z).normalized()
		target.set_meta(&"door_hinge", pivot)
		target.set_meta(&"door_normal", normal)
		target.set_meta(&"door_side", signf(out.dot(normal)))
		target.set_meta(&"door_levers", levers)
	# The free edge: from the hinge's axis past the levers' spindle to the far end of the leaf.
	var spindle: Vector3 = pivot.to_local(levers[0].lever.global_position.lerp(levers[1].lever.global_position, 0.5))
	var along := Vector3(spindle.x, 0.0, spindle.z)
	if along.length() < 0.05:
		return edges
	along = along.normalized()
	var reach: float = spindle.dot(along)
	for mesh: MeshInstance3D in pivot.find_children("*", "MeshInstance3D", true, false):
		if mesh.mesh == null or _under_lever(mesh, levers):
			continue
		var box: AABB = mesh.get_aabb()
		var to_local: Transform3D = pivot.global_transform.affine_inverse() * mesh.global_transform
		for corner: int in 8:
			reach = maxf(reach, (to_local * box.get_endpoint(corner)).dot(along))
	_measure_leaf(pivot, levers, along, reach)
	# One more grip at the free edge itself, half way through the leaf at the levers' height: the
	# hand hooks round it as it reaches (HOOK, PlayerBody._grip_basis).
	var edge := HandTarget.new()
	edge.name = "HandTargetEdge"
	edge.grip = HandTarget.Grip.HOOK
	pivot.add_child(edge)
	edge.position = Vector3(spindle.x, spindle.y, spindle.z) + along * (reach - spindle.dot(along) - EDGE_IN)
	edge.set_meta(&"door_hinge", pivot)
	edge.set_meta(&"door_normal", normal)
	edge.set_meta(&"door_levers", levers)
	edges.append(edge)
	return edges


## T-242: the leaf as a slab, for DoorSwing (metas on the pivot, in its space): which way it runs
## from the hinge (`leaf_along`), how far (`leaf_length`), half its thickness (`leaf_half`) and how
## far its middle lies off the hinge's axis toward (along.z, 0, -along.x) (`leaf_offset`).
static func _measure_leaf(pivot: Node3D, levers: Array[HandTarget], along: Vector3, reach: float) -> void:
	var across := Vector3(along.z, 0.0, -along.x)
	var low: float = INF
	var high: float = -INF
	for mesh: MeshInstance3D in pivot.find_children("*", "MeshInstance3D", true, false):
		if mesh.mesh == null or not mesh.is_visible_in_tree() or _under_lever(mesh, levers):
			continue
		var box: AABB = mesh.get_aabb()
		var to_local: Transform3D = pivot.global_transform.affine_inverse() * mesh.global_transform
		var run := Vector2(INF, -INF)
		var thick := Vector2(INF, -INF)
		for corner: int in 8:
			var point: Vector3 = to_local * box.get_endpoint(corner)
			run = Vector2(minf(run.x, point.dot(along)), maxf(run.y, point.dot(along)))
			thick = Vector2(minf(thick.x, point.dot(across)), maxf(thick.y, point.dot(across)))
		# The leaf itself, not what hangs on it (a paper, a latch).
		if run.y - run.x >= reach * 0.5:
			low = minf(low, thick.x)
			high = maxf(high, thick.y)
	if low > high:
		low = -0.02
		high = 0.02
	pivot.set_meta(&"leaf_along", along)
	pivot.set_meta(&"leaf_length", reach)
	pivot.set_meta(&"leaf_half", (high - low) * 0.5)
	pivot.set_meta(&"leaf_offset", (high + low) * 0.5)


## How far in from the free edge the hook takes it.
const EDGE_IN: float = 0.01


static func _under_lever(node: Node, levers: Array[HandTarget]) -> bool:
	for target: HandTarget in levers:
		if target.lever == node or target.lever.is_ancestor_of(node):
			return true
	return false
