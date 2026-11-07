extends TestCase
## T-233 (D-142): the floor-4 corridor pilot segment (corridor_g5_pilot.gd) is visual only. Built over
## floor4.tscn it must leave every collider, marker, light, area and navigation node of the gameplay
## contract (art_source/graphics_upgrade/floor4_corridor/PLAN.md section 2) exactly as it was, keep the
## lanes clear, and swing 406's Tripo leaf with RoomDoor.

const FLOOR := preload("res://scenes/levels/floor4/floor4.tscn")
const PILOT := preload("res://scenes/levels/floor4/corridor_g5_pilot.gd")
const PILOT_SCENE := "res://scenes/levels/floor4/corridor_g5_pilot.tscn"
## PLAN.md section 2: nodes later lanes and directors call by name.
const CONTRACT: Array[String] = ["Corridor", "Room407", "Washroom", "DutyDesk", "Environment", "Anchors",
	"Door407/Pivot", "Door407/Pivot/Leaf", "Door407/Pivot/RulesPaper", "Door407/Pivot/HandlePivot/Grip",
	"Door407/InteractShape", "Anchors/RulesPaper407", "DoorGap", "Threshold/Shape",
	"Corridor/RoomPartition_38/Mesh", "Corridor/Navigation", "Corridor/Room407Link", "Corridor/WestEnd",
	"Corridor/EastEnd", "Corridor/RailingBarrier", "Corridor/LockedDoor_406/Blocker",
	"Corridor/LockedDoor_406/Hinge", "Corridor/LockedDoor_408/Hinge", "Corridor/RoomPlate_406",
	"Corridor/RoomPlate_407", "Corridor/Former408Wall", "Corridor/CorridorLight_406/LightHum",
	"Corridor/CorridorLight_407/LightHum", "Corridor/AmbientZone", "Corridor/ReverbZone"]
## Where a body walks in the segment: nothing new may reach into it (the floor, wall and ceiling faces,
## the skirting, architraves and sills lie on its edges; lamps above, railing beyond).
const WALKABLE := AABB(Vector3(26.0, 0.013, 0.12), Vector3(8.0, 2.78, 3.81))
## Triangles of what the pilot shows (shell, frames, lamps, dense railing; geometry_report.json).
const TRIANGLE_BUDGET := 12000
var fixtures: Array[Node] = []


func after_each() -> void:
	for node in fixtures:
		node.queue_free()
	fixtures.clear()
	await wait_frames(2)
	await tree.create_timer(0.4).timeout


func spawn(with_segment: bool, origin: Vector3 = Vector3.ZERO) -> Node3D:
	var floor4 := FLOOR.instantiate() as Node3D
	floor4.position = origin
	fixtures.append(floor4)
	tree.root.add_child(floor4)
	if with_segment:
		PILOT.build(floor4)
	return floor4


## The pilot's own nodes: G5Segment and the G5* pieces it adds under floor 4 (split meshes, 406's leaf).
func _added_by_pilot(floor4: Node3D, node: Node) -> bool:
	while node != floor4:
		if String(node.name).begins_with("G5"):
			return true
		node = node.get_parent()
	return false


## Every node of floor4 by path, in floor4's space: transform, collision, lights, navigation and sound
## (mesh visibility aside). Runtime nodes with generated names (@...) differ per instance and stay out.
func _snapshot(floor4: Node3D) -> Dictionary:
	var result := {}
	var to_floor := floor4.global_transform.affine_inverse()
	for node: Node in floor4.find_children("*", "", true, false):
		var path := String(floor4.get_path_to(node))
		if _added_by_pilot(floor4, node) or "@" in path:
			continue
		var row := []
		if node is Node3D:
			row.append(to_floor * (node as Node3D).global_transform)
		if node is CollisionObject3D:
			row.append_array([(node as CollisionObject3D).collision_layer, (node as CollisionObject3D).collision_mask])
		if node is CollisionShape3D:
			var shape := (node as CollisionShape3D).shape
			row.append_array([(node as CollisionShape3D).disabled, shape.get_class(),
				(shape as BoxShape3D).size if shape is BoxShape3D else null])
		if node is Light3D:
			row.append_array([(node as Light3D).visible, (node as Light3D).light_energy, (node as Light3D).shadow_enabled])
		if node is NavigationLink3D:
			row.append_array([(node as NavigationLink3D).start_position, (node as NavigationLink3D).end_position])
		if node is NavigationRegion3D:
			var nav := (node as NavigationRegion3D).navigation_mesh
			row.append(nav.get_vertices().size() if nav else -1)
		if node is AudioStreamPlayer3D:
			var stream := (node as AudioStreamPlayer3D).stream
			row.append(stream.resource_path if stream else "")
		result[path] = row
	return result


func _same(a: Array, b: Array) -> bool:
	if a.size() != b.size():
		return false
	for i in a.size():
		if a[i] is Transform3D:
			if not (a[i] as Transform3D).is_equal_approx(b[i]):
				return false
		elif a[i] is Vector3 or a[i] is float:
			if not is_equal_approx_any(a[i], b[i]):
				return false
		elif a[i] != b[i]:
			return false
	return true


func is_equal_approx_any(a: Variant, b: Variant) -> bool:
	return (a as Vector3).is_equal_approx(b) if a is Vector3 else is_equal_approx(a, b)


func test_segment_parts_and_contract_nodes() -> void:
	var floor4 := spawn(true)
	await wait_frames(2)
	var segment := floor4.get_node_or_null("G5Segment") as Node3D
	assert_not_null(segment, "pilot segment built")
	for part: String in ["shell", "frames", "lamps", "railing_dense", "railing_classic"]:
		assert_not_null(segment.get_node_or_null(part), "segment part " + part)
	for path: String in ["shell/WallWest", "shell/Lintel406", "shell/WallMiddle", "shell/Lintel407", "shell/WallEast",
			"shell/HallFloor", "shell/HallCeiling", "shell/Skirting1", "frames/Door406LiningW", "frames/Door407Sill",
			"frames/Door406StopW", "lamps/Lamp0Housing", "railing_dense/Handrail", "railing_dense/Post2"]:
		assert_not_null(segment.get_node_or_null(path), path)
	for path: String in CONTRACT:
		assert_not_null(floor4.get_node_or_null(path), "contract node " + path)
	assert_true((segment.get_node("railing_dense") as Node3D).visible, "dense railing by default")
	assert_false((segment.get_node("railing_classic") as Node3D).visible, "classic railing hidden")
	PILOT.set_railing(floor4, "classic")
	assert_false((segment.get_node("railing_dense") as Node3D).visible, "dense railing off")
	assert_true((segment.get_node("railing_classic") as Node3D).visible, "classic railing on")
	PILOT.set_railing(floor4, "dense")
	assert_true((segment.get_node("railing_dense") as Node3D).visible, "dense railing back")
	# The shell surfaces wear room 407's shader with this segment's masks.
	var wall := segment.get_node("shell/WallMiddle") as MeshInstance3D
	var material := wall.get_surface_override_material(0) as ShaderMaterial
	assert_not_null(material, "wall has the shell shader")
	if material:
		assert_eq(material.shader.resource_path, "res://rendering/room407_shell.gdshader")
		assert_eq((material.get_shader_parameter("mask") as Texture2D).resource_path,
			"res://assets/textures/graphics_pilot/floor4_corridor/mask_walls.png")


func test_gameplay_nodes_are_untouched() -> void:
	# Both at the origin, compared in the same frame (room 407's rigid props have not moved yet).
	var plain := spawn(false)
	var built := spawn(true)
	var before := _snapshot(plain)
	var after := _snapshot(built)
	assert_true(before.size() > 500, "floor 4 inventory (%d nodes)" % before.size())
	for path: String in before:
		assert_true(after.has(path), "node kept: " + path)
		if after.has(path):
			assert_true(_same(before[path], after[path]), "unchanged: %s %s -> %s" % [path, before[path], after[path]])
	for path: String in after:
		assert_true(before.has(path), "no new gameplay node: " + path)


func test_new_visuals_stay_out_of_the_walkway() -> void:
	var floor4 := spawn(true)
	await wait_frames(1)
	var segment := floor4.get_node("G5Segment") as Node3D
	var triangles := 0
	for mesh: MeshInstance3D in segment.find_children("*", "MeshInstance3D", true, false):
		var box: AABB = floor4.global_transform.affine_inverse() * mesh.global_transform * mesh.get_aabb()
		assert_false(box.intersects(WALKABLE), "%s stays out of the walkway (%s)" % [mesh.name, box])
		if mesh.is_visible_in_tree():
			for surface in mesh.mesh.get_surface_count():
				triangles += (mesh.mesh.surface_get_arrays(surface)[Mesh.ARRAY_INDEX] as PackedInt32Array).size() / 3
	assert_true(triangles > 2000 and triangles < TRIANGLE_BUDGET, "pilot triangles %d" % triangles)
	# 406's Tripo leaf closes inside the old leaf's blocker; only its levers stand out of it.
	var leaf := floor4.get_node("Corridor/LockedDoor_406/Hinge/G5Leaf") as Node3D
	var blocker := AABB(Vector3(27.53, 0.0, -0.08), Vector3(0.93, 2.4, 0.16))
	for mesh: MeshInstance3D in leaf.find_children("*", "MeshInstance3D", true, false):
		var box: AABB = floor4.global_transform.affine_inverse() * mesh.global_transform * mesh.get_aabb()
		if mesh.find_parent("Lever*") == null:
			assert_true(blocker.encloses(box), "406 leaf inside its blocker (%s)" % box)
		else:
			assert_true(box.end.z < 0.14 and box.position.z > -0.2, "406 lever close to the leaf (%s)" % box)


func test_lanes_stay_clear() -> void:
	var floor4 := spawn(true)
	await tree.physics_frame
	await tree.physics_frame
	var space := floor4.get_world_3d().direct_space_state
	var shape := CapsuleShape3D.new()
	shape.radius = 0.3
	shape.height = 1.75
	for lane: Array in [[Vector3(24.5, 0.03, 3.0), Vector3(35.5, 0.03, 3.0)], [Vector3(24.5, 0.03, 1.0), Vector3(35.5, 0.03, 1.0)],
			[Vector3(32.0, 0.03, 2.0), Vector3(32.0, 0.03, 0.45)]]:
		var query := PhysicsShapeQueryParameters3D.new()
		query.shape = shape
		query.collision_mask = 1
		query.margin = 0.001
		query.transform.origin = (lane[0] as Vector3) + Vector3(0, 0.875, 0)
		query.motion = (lane[1] as Vector3) - (lane[0] as Vector3)
		assert_true(space.intersect_shape(query).is_empty(), "lane starts clear at %s" % lane[0])
		assert_true(space.cast_motion(query)[0] >= 0.999, "lane %s -> %s unblocked" % [lane[0], lane[1]])


func test_door_406_swings_the_tripo_leaf() -> void:
	var floor4 := spawn(true)
	await wait_frames(1)
	var door := floor4.get_node("Corridor/LockedDoor_406") as RoomDoor
	var leaf := floor4.get_node("Corridor/LockedDoor_406/Hinge/G5Leaf") as Node3D
	assert_true((floor4.get_node("Corridor/LockedDoor_406/Hinge/Leaf") as Node3D).find_children("*", "MeshInstance3D", true, false)
		.all(func(m: Node) -> bool: return not (m as Node3D).visible), "PS1 leaf hidden")
	door.set_open(true)
	await tree.create_timer(0.5).timeout
	var facing := leaf.global_basis.x
	assert_true(facing.is_equal_approx(Vector3(0, 0, -1)) or absf(facing.z + 1.0) < 0.01, "leaf turned out into the corridor (%s)" % facing)
	assert_true(leaf.global_position.z - floor4.global_position.z > 0.4, "open leaf stands in the corridor")
	door.set_open(false)
	await tree.create_timer(0.5).timeout
	assert_true(absf(leaf.global_position.z - floor4.global_position.z + 0.025) < 0.01, "closed again")


func test_before_after_and_tube_glow() -> void:
	var floor4 := spawn(true)
	await wait_frames(1)
	var segment := floor4.get_node("G5Segment") as Node3D
	var ps1: Array = segment.get_meta(&"ps1")
	var added: Array = segment.get_meta(&"added")
	assert_true(ps1.size() >= 30, "PS1 meshes of the segment (%d)" % ps1.size())
	assert_true(ps1.all(func(n: Node3D) -> bool: return not n.visible), "PS1 hidden under the segment")
	PILOT.set_upgraded(floor4, false)
	assert_false(segment.visible, "segment off")
	assert_true(ps1.all(func(n: Node3D) -> bool: return n.visible), "PS1 back")
	assert_true(added.all(func(n: Node3D) -> bool: return not n.visible), "split pieces and 406 leaf off")
	PILOT.set_upgraded(floor4, true)
	var tube := segment.get_node("lamps").find_children("FluorescentTube*", "MeshInstance3D", true, false)[0] as MeshInstance3D
	var glow := tube.material_override as StandardMaterial3D
	assert_true(glow != null and glow.emission_enabled and glow.emission_energy_multiplier > 0.5, "tube glows")
	var light := floor4.get_node("Corridor/CorridorLight_406" if absf(tube.global_position.x - 28.0) < 1.0 else "Corridor/CorridorLight_407") as Light3D
	light.visible = false
	await wait_frames(2)
	assert_eq(glow.emission_energy_multiplier, 0.0, "tube dark with its light")
	light.visible = true
	await wait_frames(2)
	assert_true(glow.emission_energy_multiplier > 0.5, "tube back with its light")


func test_pilot_scene_loads() -> void:
	var scene := (load(PILOT_SCENE) as PackedScene).instantiate() as Node3D
	fixtures.append(scene)
	tree.root.add_child(scene)
	await wait_frames(2)
	assert_not_null(scene.get_node_or_null("Floor4/G5Segment"), "pilot scene builds the segment")
	assert_not_null(scene.get_node_or_null("Player"), "pilot is walkable")
	scene.process_mode = Node.PROCESS_MODE_DISABLED
