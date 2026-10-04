class_name EntityVisibility
extends RefCounted
## Conservative visibility sampling: origin plus visible mesh centres/corners.

static func is_seen_by(camera: Camera3D, node: Node3D, max_distance: float = 15.0) -> bool:
	if not is_instance_valid(camera) or not is_instance_valid(node):
		return false
	if not camera.is_inside_tree() or not node.is_inside_tree() or not node.is_visible_in_tree():
		return false
	if camera.get_world_3d() != node.get_world_3d():
		return false
	if camera.global_position.distance_to(node.global_position) >= maxf(0.0, max_distance):
		return false
	var points: PackedVector3Array = PackedVector3Array([node.global_position])
	var meshes: Array[Node] = node.find_children("*", "MeshInstance3D", true, false)
	if node is MeshInstance3D:
		meshes.append(node)
	for child: Node in meshes:
		var mesh: MeshInstance3D = child as MeshInstance3D
		if mesh.mesh == null or not mesh.is_visible_in_tree():
			continue
		var bounds: AABB = mesh.get_aabb()
		points.append(mesh.to_global(bounds.get_center()))
		for index: int in 8:
			points.append(mesh.to_global(bounds.get_endpoint(index)))
	var excluded: Array[RID] = []
	var ancestor: Node = camera
	while ancestor != null:
		if ancestor is CollisionObject3D:
			excluded.append(ancestor.get_rid())
		ancestor = ancestor.get_parent()
	for point: Vector3 in points:
		if not camera.is_position_in_frustum(point):
			continue
		var ray: PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.create(camera.global_position, point, 1)
		ray.exclude = excluded
		var hit: Dictionary = camera.get_world_3d().direct_space_state.intersect_ray(ray)
		if hit.is_empty():
			return true
		var collider: Node = hit.get("collider") as Node
		if collider == node or (collider != null and (node.is_ancestor_of(collider) or collider.is_ancestor_of(node))):
			return true
	return false
