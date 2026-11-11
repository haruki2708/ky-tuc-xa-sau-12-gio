class_name DoorSwing
extends RefCounted
## T-242 (D-159): what a door's leaf sweeps as it turns on its hinge, so a body that would stand in
## its way steps clear first (PlayerBody.clear_spot). The leaf is the slab DoorHandles.sides
## measured: metas on the pivot, in the pivot's own space.


## How close the leaf's faces come to `point` (world, metres, in plan) while `pivot` turns from
## where it is to `to` (radians about its Y); INF for a pivot DoorHandles.sides has not measured.
## A point the leaf only swings away from is as far as it is now. (The slab's middle is taken to
## run through the hinge's axis, and to be as much thicker as it lies off it.)
static func nearest(pivot: Node3D, to: float, point: Vector3) -> float:
	var frame := pivot.get_parent() as Node3D
	if frame == null or not pivot.has_meta(&"leaf_length"):
		return INF
	var along: Vector3 = pivot.get_meta(&"leaf_along")
	var length: float = pivot.get_meta(&"leaf_length")
	var half: float = float(pivot.get_meta(&"leaf_half")) + absf(float(pivot.get_meta(&"leaf_offset")))
	var local: Vector3 = frame.global_transform.affine_inverse() * point - pivot.position
	local.y = 0.0
	var size: float = frame.global_basis.get_scale().x * pivot.scale.x
	var from: float = pivot.rotation.y
	var distance: float = local.length()
	# The leaf passes over the point's bearing: as near as the point is beyond its free end.
	var bearing: float = along.signed_angle_to(local, Vector3.UP) if distance > 0.0001 else from
	for turn: float in [0.0, TAU, -TAU]:
		if bearing + turn >= minf(from, to) and bearing + turn <= maxf(from, to):
			return (maxf(0.0, distance - length) - half) * size
	# Else as near as it is to the leaf where the swing starts or ends.
	var at := Vector2(local.x, local.z)
	var closest: float = INF
	for angle: float in [from, to]:
		var end: Vector3 = Basis(Vector3.UP, angle) * (along * length)
		closest = minf(closest, at.distance_to(Geometry2D.get_closest_point_to_segment(at, Vector2.ZERO, Vector2(end.x, end.z))))
	return (closest - half) * size


## A body of `radius` standing on `point` is in the way of that swing (the leaf comes nearer than
## `margin` to it).
static func hits(pivot: Node3D, to: float, point: Vector3, radius: float, margin: float = 0.0) -> bool:
	return nearest(pivot, to, point) < radius + margin
