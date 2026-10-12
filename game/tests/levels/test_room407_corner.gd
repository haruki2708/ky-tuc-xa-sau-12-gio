extends TestCase

const PILOT := preload("res://scenes/levels/graphics_pilot/room407_corner_pilot.tscn")
const ROOM := preload("res://scenes/levels/floor4/room_407.tscn")


func _bounds(root: Node3D) -> AABB:
	var result := AABB()
	var first := true
	for mesh: MeshInstance3D in root.find_children("*", "MeshInstance3D", true, false):
		var box: AABB = root.global_transform.affine_inverse() * mesh.global_transform * mesh.get_aabb()
		result = box if first else result.merge(box)
		first = false
	return result


func _mesh_box(pilot: Node, part: String, mesh_name: String) -> AABB:
	var part_root: Node3D = pilot.after.get_node(part)
	var mesh: MeshInstance3D = part_root.find_child(mesh_name, true, false)
	return pilot.after.global_transform.affine_inverse() * mesh.global_transform * mesh.get_aabb()


func test_corner_snapshot_is_visual_only_and_capture_is_opt_in() -> void:
	var report := "res://../art_source/graphics_upgrade/room407_corner/previews/capture_report.json"
	var timestamp := FileAccess.get_modified_time(report) if FileAccess.file_exists(report) else 0
	var settings := FileAccess.get_file_as_bytes("user://settings.cfg") if FileAccess.file_exists("user://settings.cfg") else PackedByteArray()
	var pilot := PILOT.instantiate()
	tree.root.add_child(pilot)
	await wait_frames(2)
	for root: Node in [pilot.before, pilot.after]:
		for node: Node in root.find_children("*", "", true, false):
			assert_false(node is CollisionObject3D or node is CollisionShape3D or node is NavigationRegion3D, "pilot cannot add gameplay physics/navigation")
			assert_false(node is AudioStreamPlayer3D, "pilot cannot start gameplay audio")
			assert_true(node.get_script() == null, "source scripts must never execute")
	assert_false(App.is_quitting(), "smoke loading must not capture or quit")
	assert_eq(FileAccess.get_modified_time(report) if FileAccess.file_exists(report) else 0, timestamp)
	assert_eq(FileAccess.get_file_as_bytes("user://settings.cfg") if FileAccess.file_exists("user://settings.cfg") else PackedByteArray(), settings)
	pilot.set_mode(false, false)
	assert_true(pilot.before.visible and not pilot.after.visible and pilot.torch.visible)
	assert_false(pilot.tube_light.visible)
	pilot.set_mode(true, true)
	assert_true(pilot.after.visible and pilot.tube_light.visible and not pilot.torch.visible)
	var override_ref: WeakRef = weakref(pilot.shader_override)
	pilot.queue_free()
	await wait_frames(2)
	assert_true(override_ref.get_ref() == null, "override lifetime ends with the pilot")


func test_corner_surfaces_match_existing_room_within_one_centimetre() -> void:
	var pilot := PILOT.instantiate()
	tree.root.add_child(pilot)
	var source := ROOM.instantiate()
	# Compare actual imported bounds to source box surfaces, not generator metadata.
	var floor_box := _mesh_box(pilot, "floor", "Floor")
	var old_floor: MeshInstance3D = source.get_node("Floor/Mesh")
	var expected_floor: AABB = source.get_node("Floor").transform * old_floor.get_aabb()
	assert_true(absf(floor_box.end.y - expected_floor.end.y) <= 0.01)
	assert_true(absf(floor_box.position.z - expected_floor.position.z) <= 0.01)
	var wall := _mesh_box(pilot, "architecture", "WestWall")
	var old_wall: MeshInstance3D = source.get_node("WestWall/Mesh")
	var expected_wall: AABB = source.get_node("WestWall").transform * old_wall.get_aabb()
	assert_true(absf(wall.end.x - expected_wall.end.x) <= 0.01)
	for name: String in ["BackWest", "BackEast", "BalconyLintel"]:
		var box := _mesh_box(pilot, "architecture", name)
		var old: MeshInstance3D = source.get_node("Extension/" + name + "/Mesh")
		var expected: AABB = old.get_parent().transform * old.get_aabb()
		assert_true(box.position.distance_to(expected.position) <= 0.01, name + " minimum")
		assert_true(box.end.distance_to(expected.end) <= 0.01, name + " maximum")
	assert_true(absf(_mesh_box(pilot, "architecture", "Ceiling").position.y - 3.0) <= 0.01)
	for row: Array in [["LowerMattress", 0.43], ["UpperMattress", 1.20]]:
		var mattress := _mesh_box(pilot, "bunk_a", row[0])
		assert_true(absf(mattress.end.y - row[1]) <= 0.01, row[0] + " sleeping surface")
		assert_true(absf(mattress.size.x - 0.8) <= 0.01 and absf(mattress.size.z - 1.9) <= 0.01)
	var desk := _mesh_box(pilot, "study_desk", "DeskTop")
	assert_true(absf(desk.end.y - 0.76) <= 0.01)
	assert_true(desk.size.distance_to(Vector3(1.5, 0.05, 0.65)) <= 0.01)
	source.free()
	pilot.queue_free()
	await wait_frames(2)


func test_corner_all_eight_approved_props_keep_source_footprints_and_basis() -> void:
	var pilot := PILOT.instantiate()
	tree.root.add_child(pilot)
	var source := ROOM.instantiate()
	assert_eq(pilot.props.get_child_count(), 8)
	for row: Dictionary in pilot.bindings:
		var prop: Node3D = pilot.props.get_node(row.name)
		var old: Node3D = source.get_node(row.source_node)
		var old_transform := old.transform
		var parent := old.get_parent()
		while parent != source:
			if parent is Node3D:
				old_transform = parent.transform * old_transform
			parent = parent.get_parent()
		assert_true(absf(prop.position.x - old_transform.origin.x) <= 0.01, row.name + " X")
		assert_true(absf(prop.position.z - old_transform.origin.z) <= 0.01, row.name + " Z")
		assert_true(prop.scale.is_equal_approx(Vector3.ONE), row.name + " unit scale")
		if row.name not in ["Fridge", "RiceCooker", "Towel"]:
			assert_true(absf(prop.position.y - old_transform.origin.y) <= 0.01, row.name + " Y")
			assert_true(prop.basis.is_equal_approx(old_transform.basis), row.name + " source basis")
	# New normalized assets have floor pivots instead of old box centre pivots.
	var fridge: Node3D = pilot.props.get_node("Fridge")
	var cooker: Node3D = pilot.props.get_node("RiceCooker")
	assert_true((fridge.basis * Vector3.FORWARD).is_equal_approx(Vector3.LEFT))
	assert_true(absf(fridge.position.y) <= 0.01)
	assert_true(absf(cooker.position.y + _bounds(cooker).position.y - (fridge.position.y + _bounds(fridge).end.y)) <= 0.01, "cooker rests on fridge")
	var bucket: Node3D = pilot.props.get_node("Bucket")
	var towel: Node3D = pilot.props.get_node("Towel")
	assert_true(towel.basis.is_equal_approx(Basis.IDENTITY), "folded normalized towel is horizontal, old hanging-towel X rotation is obsolete")
	assert_true(absf(towel.position.y + _bounds(towel).position.y - (bucket.position.y + _bounds(bucket).end.y)) <= 0.01, "towel lowered onto the resized bucket")
	source.free()
	pilot.queue_free()
	await wait_frames(2)
