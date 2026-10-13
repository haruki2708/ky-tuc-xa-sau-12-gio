extends TestCase

const PILOT := preload("res://scenes/levels/graphics_pilot/room407_furnished_pilot.tscn")
const ANCHORS := preload("res://scenes/levels/room407/room407_anchors.tscn")
const BATCH2 := "res://assets/models/graphics_pilot/room407_batch2/"
const BUDGET_LARGE := 8000
const BUDGET_SMALL := 5000
const LARGE := ["bunk_frame", "blanket_messy", "desk", "locker_closed", "locker_open", "ceiling_fan",
	"bookshelf", "shoe_rack", "standing_fan", "toilet"]


func _bounds(root: Node3D, space: Node3D) -> AABB:
	var result := AABB()
	var first := true
	for mesh: MeshInstance3D in root.find_children("*", "MeshInstance3D", true, false):
		var box: AABB = space.global_transform.affine_inverse() * mesh.global_transform * mesh.get_aabb()
		result = box if first else result.merge(box)
		first = false
	return result


func _triangles(root: Node) -> int:
	var count := 0
	for mesh: MeshInstance3D in root.find_children("*", "MeshInstance3D", true, false):
		for surface in mesh.mesh.get_surface_count():
			var arrays := mesh.mesh.surface_get_arrays(surface)
			var indices: PackedInt32Array = arrays[Mesh.ARRAY_INDEX]
			count += indices.size() / 3 if indices.size() > 0 else (arrays[Mesh.ARRAY_VERTEX] as PackedVector3Array).size() / 3
	return count


func test_furnished_pilot_is_visual_only_and_capture_is_opt_in() -> void:
	var report := "res://../art_source/graphics_upgrade/room407_furnished/previews/capture_report.json"
	var timestamp := FileAccess.get_modified_time(report) if FileAccess.file_exists(report) else 0
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
	assert_eq(pilot.props.get_child_count(), pilot.bindings.size())
	pilot.set_mode(false, false)
	assert_true(pilot.before.visible and not pilot.after.visible and pilot.torch.visible)
	pilot.set_mode(true, true)
	assert_true(pilot.after.visible and not pilot.torch.visible)
	pilot.queue_free()
	await wait_frames(2)


func test_batch2_models_stay_within_budget_and_one_material() -> void:
	var names: Array[String] = []
	for file: String in DirAccess.get_files_at(BATCH2):
		if file.ends_with(".glb"):
			names.append(file.get_basename())
	assert_eq(names.size(), 32, "32 baked Tripo props (mattress uses the Blender build, D-095)")
	for name in names:
		var model := (load(BATCH2 + name + ".glb") as PackedScene).instantiate()
		var limit := BUDGET_LARGE if name in LARGE else BUDGET_SMALL
		assert_true(_triangles(model) <= limit, "%s within %d triangles" % [name, limit])
		var meshes := model.find_children("*", "MeshInstance3D", true, false)
		assert_eq(meshes.size(), 1, name + " single mesh")
		assert_eq((meshes[0] as MeshInstance3D).mesh.get_surface_count(), 1, name + " single material")
		model.free()


func test_bunk_decks_and_mattresses_land_on_the_sleeping_anchors() -> void:
	var pilot := PILOT.instantiate()
	tree.root.add_child(pilot)
	var anchors := ANCHORS.instantiate()
	var tops := {}
	for row: Array in [["MattressViet", "Bunks/Bunk2"], ["MattressPhuc", "Bunks/Bunk1"],
			["MattressTrung", "Bunks/Bunk3"], ["MattressDat", "Bunks/Bunk4"]]:
		var mattress: Node3D = pilot.props.get_node(row[0])
		var box := _bounds(mattress, pilot.after)
		var bunk: Node3D = anchors.get_node(row[1])
		# Bunk markers sit on the sleeping surface (corner pilot: mattress top 0.43 / 1.20).
		assert_true(absf(box.end.y - bunk.position.y) <= 0.01, row[0] + " sleeping surface")
		assert_true(absf(box.get_center().x - bunk.position.x) <= 0.01 and absf(box.get_center().z - bunk.position.z) <= 0.01, row[0] + " centred on the bunk")
		tops[row[0]] = box.end.y
	for bunk_name: String in ["BunkA", "BunkB"]:
		var frame := _bounds(pilot.props.get_node(bunk_name), pilot.after)
		assert_true(frame.size.distance_to(Vector3(0.9, 1.5, 2.0)) <= 0.02, bunk_name + " footprint")
		assert_true(absf(frame.position.y) <= 0.005, bunk_name + " stands on the floor")
	assert_true(absf(float(tops["MattressViet"]) - 0.43) <= 0.01 and absf(float(tops["MattressPhuc"]) - 1.20) <= 0.01)
	anchors.free()
	pilot.queue_free()
	await wait_frames(2)
