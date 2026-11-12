extends TestCase
## T-252: visual upgrade must preserve the original room collision/door contract.
const CORRIDOR := preload("res://scenes/levels/floor4/corridor.tscn")
const ROOMS: Array[int] = [401, 402, 403, 404, 405, 406, 408]
const TOTAL_TRIANGLE_BUDGET := 90000
var fixture: Node3D


func before_each() -> void:
	fixture = CORRIDOR.instantiate() as Node3D
	tree.root.add_child(fixture)
	await wait_frames(2)


func after_each() -> void:
	fixture.queue_free()
	await wait_frames(2)


func test_each_room_has_fitted_blender_shell_and_furniture() -> void:
	for room: int in ROOMS:
		var visual := fixture.get_node("RoomInterior_%d/T252Visual" % room) as Node3D
		var center := 41.0 if room == 408 else 8.0 + (room - 401) * 4.0
		var half := 3.0 if room == 408 else 2.0
		assert_eq(visual.position, Vector3(center, 0, 0), "room %d placement" % room)
		for part: String in ["Shell", "Furnishings/BunkWest", "Furnishings/BunkEast", "Furnishings/Locker", "Furnishings/Desk", "Furnishings/Stool"]:
			assert_true(visual.has_node(part), "room %d missing %s" % [room, part])
		assert_true(visual.find_children("*", "CollisionObject3D", true, false).is_empty(), "visuals cannot alter collision")
		assert_true(visual.find_children("*", "Light3D", true, false).is_empty(), "lighting unchanged")
		for mesh: MeshInstance3D in visual.find_children("*", "MeshInstance3D", true, false):
			var bounds: AABB = fixture.global_transform.affine_inverse() * mesh.global_transform * mesh.get_aabb()
			assert_true(bounds.position.x >= center-half-.01 and bounds.end.x <= center+half+.01, "room width: %s" % mesh.get_path())
			assert_true(bounds.position.z >= -5.11 and bounds.end.z <= .001, "no visual enters corridor")
			assert_true(bounds.position.y >= -.201 and bounds.end.y <= 3.151, "room height")


func test_ps1_meshes_hidden_and_original_nodes_retained() -> void:
	for room: int in ROOMS:
		var interior := fixture.get_node("RoomInterior_%d" % room)
		for part: String in ["Bunk0.4", "Bunk1.45", "Post-4.35", "Post-2.55", "Locker"]:
			assert_true(interior.has_node(part + "/Collision"))
			assert_false((interior.get_node(part + "/Mesh") as Node3D).visible, "old furniture hidden")
		for prefix: String in ["Floor_", "Ceiling_"]:
			assert_false((fixture.get_node(prefix + str(room) + "/Mesh") as Node3D).visible)
		if room != 408:
			assert_false((fixture.get_node("BackWall_%d/Mesh" % room) as Node3D).visible)
	for part: String in ["RoomPartition_6", "RoomPartition_10", "RoomPartition_14", "RoomPartition_18", "RoomPartition_22", "RoomPartition_26", "RoomPartition_38", "Room408BackWall", "Room408EastWall"]:
		assert_false((fixture.get_node(part + "/Mesh") as Node3D).visible)
		assert_true(fixture.has_node(part + "/Collision"))


func test_closed_rooms_cull_furniture_and_follow_door_swing() -> void:
	for room: int in ROOMS:
		var visual := fixture.get_node("RoomInterior_%d/T252Visual" % room)
		assert_false((visual.get_node("Furnishings") as Node3D).visible)
		assert_true((visual.get_node("Shell") as Node3D).visible, "exterior backing stays solid")
		var door := fixture.get_node("LockedDoor_%d" % room) as RoomDoor
		assert_false(door.is_open)
		assert_eq(door.blocker.collision_layer, 1)
		door.set_open(true)
	await tree.create_timer(.4).timeout
	for room: int in ROOMS:
		var visual := fixture.get_node("RoomInterior_%d/T252Visual" % room)
		assert_true((visual.get_node("Furnishings") as Node3D).visible)
		var door := fixture.get_node("LockedDoor_%d" % room) as RoomDoor
		assert_eq(door.blocker.collision_layer, 0)
		door.set_open(false)
	await wait_frames(1)
	for room: int in ROOMS:
		assert_true((fixture.get_node("RoomInterior_%d/T252Visual/Furnishings" % room) as Node3D).visible, "furniture retained during closing")
	await tree.create_timer(.4).timeout
	for room: int in ROOMS:
		assert_false((fixture.get_node("RoomInterior_%d/T252Visual/Furnishings" % room) as Node3D).visible)
		assert_eq((fixture.get_node("LockedDoor_%d" % room) as RoomDoor).blocker.collision_layer, 1)


func test_mesh_budget_and_shared_materials() -> void:
	var triangles: int = 0
	var materials: Dictionary = {}
	for room: int in ROOMS:
		var visual := fixture.get_node("RoomInterior_%d/T252Visual" % room)
		for instance: MeshInstance3D in visual.find_children("*", "MeshInstance3D", true, false):
			for surface: int in instance.mesh.get_surface_count():
				var count := instance.mesh.surface_get_array_index_len(surface)
				if count == 0:
					count = instance.mesh.surface_get_array_len(surface)
				triangles += int(count / 3)
				var material := instance.get_active_material(surface) as StandardMaterial3D
				assert_not_null(material)
				materials[material] = true
				if material.resource_name != "T252_Dark":
					assert_not_null(material.albedo_texture, "CC0 albedo loaded")
					assert_not_null(material.normal_texture, "CC0 normal loaded")
	assert_true(triangles > 70000 and triangles <= TOTAL_TRIANGLE_BUDGET, "seven room triangle budget: %d" % triangles)
	assert_eq(materials.size(), 8, "materials shared across all rooms")


func test_baseline_collision_and_door_blocks_are_unchanged() -> void:
	# Exact original A03 gameplay blocks plus their shape resources, captured from a64361d.
	var expected: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://tests/levels/t252_contract.json"))
	var source := FileAccess.get_file_as_string(CORRIDOR.resource_path).replace("\r", "")
	var node_re := RegEx.new()
	node_re.compile('^node name="([^"]+)"(?: type="[^"]+")? parent="([^"]+)"')
	var resource_re := RegEx.new()
	resource_re.compile('^sub_resource type="[^"]+" id="([^"]+)"')
	var seen: Dictionary = {}
	for raw: String in source.split("["):
		var key := ""
		var match_node := node_re.search(raw)
		var match_resource := resource_re.search(raw)
		if match_node != null:
			var parent := match_node.get_string(2)
			key = "node:" + (parent + "/" if parent != "." else "") + match_node.get_string(1)
		elif match_resource != null:
			key = "resource:" + match_resource.get_string(1)
		if expected.has(key):
			assert_eq(("[" + raw.strip_edges()).sha256_text(), expected[key], "baseline changed: " + key)
			seen[key] = true
	assert_eq(seen.size(), expected.size(), "all baseline gameplay nodes/resources retained")
