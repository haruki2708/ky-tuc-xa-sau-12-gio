extends TestCase
## T-233, T-235 (D-142, D-144): the whole floor-4 corridor in room 407's style is visual only. Since T-237
## (D-148) floor4.gd builds it in every chapter (corridor_shell.gd); it must leave every collider, marker, light,
## area and navigation node of the gameplay contract (art_source/graphics_upgrade/floor4_corridor/PLAN.md
## section 2) exactly as the PS1 floor has it, keep the lanes clear, swing the Tripo leaves with RoomDoor and
## keep the room numbers where they were. The pilot (corridor_g5_pilot.gd) adds the unpicked variants on top.

const FLOOR := preload("res://scenes/levels/floor4/floor4.tscn")
const SHELL := preload("res://scenes/levels/floor4/corridor_shell.gd")
const PILOT := preload("res://scenes/levels/floor4/corridor_g5_pilot.gd")
const PILOT_SCENE := "res://scenes/levels/floor4/corridor_g5_pilot.tscn"
const ROOM_DOORS: Array[String] = ["401", "402", "403", "404", "405", "406", "408"]
## RoomPlate_* centres (T-190 layout).
const PLATES := {"401": 8.0, "402": 12.0, "403": 16.0, "404": 20.0, "405": 24.0, "406": 28.0, "407": 32.0, "408": 42.0}
const LIGHTS: Array[String] = ["CorridorLight_401", "CorridorLight_402", "CorridorLight_403", "CorridorLight_404",
	"CorridorLight_405", "CorridorLight_406", "CorridorLight_407", "CorridorLight_408", "CorridorLight_Desk"]
## PLAN.md section 2: nodes later lanes and directors call by name.
const CONTRACT: Array[String] = ["Corridor", "Room407", "Washroom", "DutyDesk", "Environment", "Anchors",
	"Door407/Pivot", "Door407/Pivot/Leaf", "Door407/Pivot/RulesPaper", "Door407/Pivot/HandlePivot/Grip",
	"Door407/InteractShape", "Anchors/RulesPaper407", "DoorGap", "Threshold/Shape",
	"Corridor/RoomPartition_38/Mesh", "Corridor/Navigation", "Corridor/Room407Link", "Corridor/WestEnd",
	"Corridor/EastEnd", "Corridor/RailingBarrier", "Corridor/Former408Wall", "Corridor/Sealed408",
	"Corridor/Doorway_408", "Corridor/AmbientZone", "Corridor/ReverbZone", "Washroom/EntranceWest",
	"Washroom/EntranceEast", "Washroom/EntranceLintel", "Anchors/HallBoard", "Anchors/Speaker"]
## Where a body walks: nothing new may reach into it (the floor, wall, ceiling and end faces, the skirting,
## architraves, sills and plates lie on its edges; lamps above, railing beyond).
const WALKABLE := AABB(Vector3(0.02, 0.013, 0.12), Vector3(43.96, 2.78, 3.81))
## Triangles of what the playable corridor shows (geometry_report.json default_triangles, about 42 000).
const TRIANGLE_BUDGET := 50000
var fixtures: Array[Node] = []


func after_each() -> void:
	for node in fixtures:
		node.queue_free()
	fixtures.clear()
	await wait_frames(2)
	await tree.create_timer(0.4).timeout


## with_corridor false: the PS1 floor (floor4.gd upgraded_corridor off); variants: the pilot's extra looks.
func spawn(with_corridor: bool, origin: Vector3 = Vector3.ZERO, variants: bool = false) -> Node3D:
	var floor4 := FLOOR.instantiate() as Node3D
	floor4.position = origin
	floor4.set("upgraded_corridor", with_corridor)
	fixtures.append(floor4)
	tree.root.add_child(floor4)
	if variants:
		PILOT.add_variants(floor4)
	return floor4


## The pilot's own nodes: G5Corridor and the G5* pieces it hangs under floor 4 (leaves, end walls).
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
		if node.has_meta(&"room_number"):
			row.append(node.get_meta(&"room_number"))
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


func _bounds(floor4: Node3D, node: Node) -> AABB:
	var box := AABB()
	var first := true
	var meshes: Array[Node] = node.find_children("*", "MeshInstance3D", true, false)
	if node is MeshInstance3D:
		meshes.append(node)
	for mesh: MeshInstance3D in meshes:
		var b: AABB = floor4.global_transform.affine_inverse() * mesh.global_transform * mesh.get_aabb()
		box = b if first else box.merge(b)
		first = false
	return box


func test_corridor_parts_and_contract_nodes() -> void:
	var floor4 := spawn(true)
	await wait_frames(2)
	var corridor := floor4.get_node_or_null("G5Corridor") as Node3D
	assert_not_null(corridor, "floor 4 builds the corridor by itself")
	for part: String in ["shell", "frames", "lamps", "railing", "plates_alu"]:
		assert_not_null(corridor.get_node_or_null(part), "corridor part " + part)
	# D-148: the playable corridor has the owner's picks only (aluminium plates, 408 walled up).
	for part: String in ["plates_enamel", "seal_board"]:
		assert_true(corridor.get_node_or_null(part) == null, "unpicked variant left out: " + part)
	assert_eq(SHELL.build(floor4), corridor, "a second build keeps the one corridor")
	assert_eq(floor4.find_children("G5Corridor*", "", false, false).size(), 1, "one corridor")
	assert_eq(floor4.get_node("Corridor/WestEnd").find_children("G5*", "", false, false).size(), 1, "one west end wall")
	assert_eq(floor4.get_node("Corridor/LockedDoor_403/Hinge").find_children("G5*", "", false, false).size(), 1, "one leaf")
	assert_true(spawn(false).get_node_or_null("G5Corridor") == null, "the PS1 floor has none")
	for bay: String in ["Washroom", "401", "402", "403", "404", "405", "406", "407W", "407E", "408"]:
		assert_not_null(corridor.get_node_or_null("shell/Bay" + bay), "shell bay " + bay)
		assert_not_null(corridor.get_node_or_null("railing/Rail" + bay), "railing bay " + bay)
	for room: String in ["401", "402", "403", "404", "405", "406", "407", "408", "408Old"]:
		assert_not_null(corridor.get_node_or_null("frames/Frame" + room), "door frame " + room)
	for light: String in LIGHTS:
		assert_not_null(corridor.get_node_or_null("lamps/Lamp_" + light), "batten under " + light)
	assert_true(corridor.find_child("*classic*", true, false) == null, "railing A2 removed (D-144)")
	for path: String in CONTRACT:
		assert_not_null(floor4.get_node_or_null(path), "contract node " + path)
	for room: String in ROOM_DOORS:
		for child: String in ["Blocker", "Hinge", "Hinge/Leaf"]:
			assert_not_null(floor4.get_node_or_null("Corridor/LockedDoor_%s/%s" % [room, child]), "LockedDoor_%s/%s" % [room, child])
	for light: String in LIGHTS:
		assert_not_null(floor4.get_node_or_null("Corridor/%s/LightHum" % light), light + "/LightHum")
	# The shell wears room 407's shader with this corridor's masks.
	var bay := corridor.get_node("shell/Bay403") as MeshInstance3D
	var shaders := 0
	for surface in bay.mesh.get_surface_count():
		var material := bay.get_surface_override_material(surface) as ShaderMaterial
		if material:
			shaders += 1
			assert_eq(material.shader.resource_path, "res://rendering/room407_shell.gdshader")
			assert_true((material.get_shader_parameter("mask") as Texture2D).resource_path.begins_with(
				"res://assets/textures/graphics_pilot/floor4_corridor/mask_"), "corridor mask")
	assert_eq(shaders, bay.mesh.get_surface_count(), "every surface of a bay uses the shell shader")


func test_gameplay_nodes_are_untouched() -> void:
	# Both at the origin, compared in the same frame (room 407's rigid props have not moved yet).
	var plain := spawn(false)
	var built := spawn(true)
	assert_true(plain.get_node_or_null("G5Corridor") == null, "baseline is the PS1 floor")
	assert_not_null(built.get_node_or_null("G5Corridor"), "default floor has the corridor")
	var before := _snapshot(plain)
	var after := _snapshot(built)
	assert_true(before.size() > 500, "floor 4 inventory (%d nodes)" % before.size())
	for path: String in before:
		assert_true(after.has(path), "node kept: " + path)
		if after.has(path):
			assert_true(_same(before[path], after[path]), "unchanged: %s %s -> %s" % [path, before[path], after[path]])
	for path: String in after:
		assert_true(before.has(path), "no new gameplay node: " + path)
	assert_true(built.find_children("*", "CollisionObject3D", true, false).all(
		func(n: Node) -> bool: return not _added_by_pilot(built, n)), "no collider added")


func test_new_visuals_stay_out_of_the_walkway() -> void:
	var floor4 := spawn(true)
	await wait_frames(1)
	var corridor := floor4.get_node("G5Corridor") as Node3D
	var to_floor := floor4.global_transform.affine_inverse()
	var inside := WALKABLE.grow(-0.001)
	var triangles := 0
	var meshes: Array[Node] = corridor.find_children("*", "MeshInstance3D", true, false)
	meshes.append(floor4.get_node("Corridor/WestEnd/G5EndWest"))
	meshes.append(floor4.get_node("Corridor/EastEnd/G5EndEast"))
	for mesh: MeshInstance3D in meshes:
		# Joined meshes (a bay, a door frame) span the corridor, so test their vertices, not their boxes.
		var into := to_floor * mesh.global_transform
		var offending := 0
		for surface in mesh.mesh.get_surface_count():
			var arrays := mesh.mesh.surface_get_arrays(surface)
			for vertex: Vector3 in arrays[Mesh.ARRAY_VERTEX] as PackedVector3Array:
				if inside.has_point(into * vertex):
					offending += 1
			if mesh.is_visible_in_tree():
				triangles += (arrays[Mesh.ARRAY_INDEX] as PackedInt32Array).size() / 3
		assert_eq(offending, 0, "%s stays out of the walkway" % mesh.name)
	assert_true(triangles > 20000 and triangles < TRIANGLE_BUDGET, "corridor triangles %d" % triangles)
	# Each Tripo leaf closes inside its old leaf's blocker; only its levers stand out of it.
	for room: String in ROOM_DOORS:
		var x := float(room.to_int() - 401) * 4.0 + 8.0 if room != "408" else 42.0
		var blocker := AABB(Vector3(x - 0.47, 0.0, -0.08), Vector3(0.93, 2.4, 0.16))
		var leaf := floor4.get_node("Corridor/LockedDoor_%s/Hinge/G5Leaf" % room) as Node3D
		for mesh: MeshInstance3D in leaf.find_children("*", "MeshInstance3D", true, false):
			var box: AABB = to_floor * mesh.global_transform * mesh.get_aabb()
			if mesh.find_parent("Lever*") == null:
				assert_true(blocker.encloses(box), "%s leaf inside its blocker (%s)" % [room, box])
			else:
				assert_true(box.end.z < 0.14 and box.position.z > -0.2, "%s lever close to the leaf (%s)" % [room, box])


func test_lanes_stay_clear() -> void:
	var floor4 := spawn(true)
	await tree.physics_frame
	await tree.physics_frame
	var space := floor4.get_world_3d().direct_space_state
	var shape := CapsuleShape3D.new()
	shape.radius = 0.3
	shape.height = 1.75
	# Z = 3 the whole way; Z = 1 too, except in front of the duty desk (PS1 until round 3, z up to 0.745),
	# which a body passes 10 cm further out; and into room 407.
	var lanes := [[Vector3(0.4, 0.03, 3.0), Vector3(43.6, 0.03, 3.0)], [Vector3(0.4, 0.03, 1.0), Vector3(38.9, 0.03, 1.0)],
		[Vector3(38.9, 0.03, 1.1), Vector3(41.1, 0.03, 1.1)], [Vector3(41.1, 0.03, 1.0), Vector3(43.6, 0.03, 1.0)],
		[Vector3(32.0, 0.03, 2.0), Vector3(32.0, 0.03, 0.45)]]
	for lane: Array in lanes:
		var query := PhysicsShapeQueryParameters3D.new()
		query.shape = shape
		query.collision_mask = 1
		query.margin = 0.001
		query.transform.origin = (lane[0] as Vector3) + Vector3(0, 0.875, 0)
		query.motion = (lane[1] as Vector3) - (lane[0] as Vector3)
		assert_true(space.intersect_shape(query).is_empty(), "lane starts clear at %s" % lane[0])
		assert_true(space.cast_motion(query)[0] >= 0.999, "lane %s -> %s unblocked" % [lane[0], lane[1]])


func test_every_room_door_swings_its_tripo_leaf() -> void:
	var floor4 := spawn(true)
	await wait_frames(1)
	for room: String in ROOM_DOORS:
		var door := floor4.get_node("Corridor/LockedDoor_" + room) as RoomDoor
		assert_true((floor4.get_node("Corridor/LockedDoor_%s/Hinge/Leaf" % room) as Node3D).find_children("*", "MeshInstance3D", true, false)
			.all(func(m: Node) -> bool: return not (m as Node3D).visible), room + " PS1 leaf hidden")
		door.set_open(true)
	await tree.create_timer(0.5).timeout
	for room: String in ROOM_DOORS:
		var leaf := floor4.get_node("Corridor/LockedDoor_%s/Hinge/G5Leaf" % room) as Node3D
		assert_true(absf(leaf.global_basis.x.z + 1.0) < 0.01, "%s leaf turned out into the corridor (%s)" % [room, leaf.global_basis.x])
		assert_true(leaf.global_position.z - floor4.global_position.z > 0.4, room + " open leaf stands in the corridor")
		(floor4.get_node("Corridor/LockedDoor_" + room) as RoomDoor).set_open(false)
	await tree.create_timer(0.5).timeout
	for room: String in ROOM_DOORS:
		var leaf := floor4.get_node("Corridor/LockedDoor_%s/Hinge/G5Leaf" % room) as Node3D
		assert_true(absf(leaf.global_position.z - floor4.global_position.z + 0.025) < 0.01, room + " closed again")


func test_room_plates_keep_their_numbers_and_places() -> void:
	var floor4 := spawn(true, Vector3.ZERO, true)
	await wait_frames(1)
	var corridor := floor4.get_node("G5Corridor")
	for style: String in ["Alu", "Enamel"]:
		for room: String in PLATES:
			var plate := corridor.get_node_or_null("plates_%s/Plate%s_%s" % [style.to_lower(), style, room]) as Node3D
			assert_not_null(plate, "%s plate %s" % [style, room])
			if plate == null:
				continue
			var box := _bounds(floor4, plate)
			var old := floor4.get_node("Corridor/RoomPlate_" + room) as Node3D
			assert_true(absf(box.get_center().x - PLATES[room]) < 0.01 and absf(box.get_center().x - old.position.x) < 0.01,
				"%s plate %s centred over its door (%s)" % [style, room, box.get_center()])
			assert_true(absf(box.get_center().y - old.position.y) < 0.01, "%s plate %s at the old height" % [style, room])
			assert_true(box.position.z >= 0.099 and box.end.z < 0.11, "%s plate %s on the wall (%s)" % [style, room, box])
			assert_eq((old.get_node("Mesh") as Node).get_meta(&"room_number"), room.to_int(), "room number kept " + room)
	assert_true((corridor.get_node("plates_alu") as Node3D).visible, "aluminium plates by default")
	assert_false((corridor.get_node("plates_enamel") as Node3D).visible, "pilot's enamel plates start hidden")
	PILOT.set_plates(floor4, "enamel")
	assert_false((corridor.get_node("plates_alu") as Node3D).visible, "aluminium off")
	assert_true((corridor.get_node("plates_enamel") as Node3D).visible, "enamel on")
	assert_false((floor4.get_node("Corridor/RoomPlate_405/Mesh") as Node3D).visible, "PS1 plate hidden")


func test_old_408_doorway_and_ends() -> void:
	var floor4 := spawn(true, Vector3.ZERO, true)
	await wait_frames(1)
	var corridor := floor4.get_node("G5Corridor")
	var sealed := floor4.get_node("Corridor/Sealed408") as MeshInstance3D
	assert_false(sealed.visible, "PS1 seal panel hidden under the new doorway")
	assert_eq(Vector2(sealed.position.x, sealed.position.y), Vector2(36, 1.02), "Sealed408 kept in place")
	var board := corridor.get_node("seal_board") as Node3D
	assert_false(board.visible, "walled up by default")
	var box := _bounds(floor4, board)
	assert_true(box.position.x > 35.5 and box.end.x < 36.5 and box.end.z <= 0.1, "planks inside the old frame (%s)" % box)
	PILOT.set_seal(floor4, "boarded")
	assert_true(board.visible, "planks on")
	# The end walls go with their caps: Campus hides the caps to open the stairs.
	for cap: String in ["WestEnd", "EastEnd"]:
		var cap_node := floor4.get_node("Corridor/" + cap) as Node3D
		var wall := cap_node.get_node("G5End" + cap.trim_suffix("End")) as Node3D
		assert_true(wall.is_visible_in_tree(), cap + " end wall shown")
		cap_node.hide()
		assert_false(wall.is_visible_in_tree(), cap + " end wall hidden with its cap")
		cap_node.show()
	SHELL.set_upgraded(floor4, false)
	assert_true(sealed.visible, "PS1 seal back")
	assert_false((floor4.get_node("Corridor/WestEnd/G5EndWest") as Node3D).visible, "end wall off with the corridor")


func test_before_after_and_tube_glow() -> void:
	var floor4 := spawn(true)
	await wait_frames(1)
	var corridor := floor4.get_node("G5Corridor") as Node3D
	var ps1: Array = corridor.get_meta(&"ps1")
	var added: Array = corridor.get_meta(&"added")
	assert_true(ps1.size() >= 140, "PS1 meshes replaced (%d)" % ps1.size())
	assert_true(ps1.all(func(n: Node3D) -> bool: return not n.visible), "PS1 hidden under the corridor")
	SHELL.set_upgraded(floor4, false)
	assert_false(corridor.visible, "corridor off")
	assert_true(ps1.all(func(n: Node3D) -> bool: return n.visible), "PS1 back")
	assert_true(added.all(func(n: Node3D) -> bool: return not n.visible), "leaves and end walls off")
	SHELL.set_upgraded(floor4, true)
	for light_name: String in LIGHTS:
		var batten := corridor.get_node("lamps/Lamp_" + light_name) as MeshInstance3D
		var glow: StandardMaterial3D = null
		for surface in batten.mesh.get_surface_count():
			var material := batten.get_surface_override_material(surface)
			if material and material.resource_name == "CorrTubeGlow":
				glow = material as StandardMaterial3D
		assert_true(glow != null and glow.emission_energy_multiplier > 0.5, light_name + " tubes glow")
		if glow == null:
			continue
		var light := floor4.get_node("Corridor/" + light_name) as Light3D
		light.visible = false
		await wait_frames(2)
		assert_eq(glow.emission_energy_multiplier, 0.0, light_name + " tubes dark with their light")
		light.visible = true
		await wait_frames(2)
		assert_true(glow.emission_energy_multiplier > 0.5, light_name + " tubes back")


func test_pilot_scene_loads() -> void:
	var scene := (load(PILOT_SCENE) as PackedScene).instantiate() as Node3D
	fixtures.append(scene)
	tree.root.add_child(scene)
	await wait_frames(2)
	assert_not_null(scene.get_node_or_null("Floor4/G5Corridor"), "pilot scene builds the corridor")
	assert_eq(scene.get_node("Floor4").find_children("G5Corridor*", "", false, false).size(), 1,
		"pilot reuses the floor's corridor (no second build)")
	assert_eq(scene.get_node("Floor4/Corridor/LockedDoor_401/Hinge").find_children("G5*", "", false, false).size(), 1,
		"one Tripo leaf per door")
	for part: String in ["plates_enamel", "seal_board"]:
		assert_not_null(scene.get_node_or_null("Floor4/G5Corridor/" + part), "pilot variant " + part)
	assert_not_null(scene.get_node_or_null("Player"), "pilot is walkable")
	scene.process_mode = Node.PROCESS_MODE_DISABLED
