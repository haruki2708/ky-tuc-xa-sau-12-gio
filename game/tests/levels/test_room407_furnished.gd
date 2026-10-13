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
	var meshes := root.find_children("*", "MeshInstance3D", true, false)
	if root is MeshInstance3D:
		meshes.append(root)
	for mesh: MeshInstance3D in meshes:
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


func test_blender_soft_props_stay_within_budget() -> void:
	# D-095 Blender props: nets <= 8000 triangles each (large-prop budget), lines and poster small.
	var folder := "res://assets/models/graphics_pilot/room407_furnished/"
	for row: Array in [["mosquito_net_lower_closed", BUDGET_LARGE], ["mosquito_net_lower_open", BUDGET_LARGE],
			["mosquito_net_upper_closed", BUDGET_LARGE], ["clothesline_room", BUDGET_SMALL],
			["clothesline_balcony", BUDGET_SMALL], ["poster_football", BUDGET_SMALL], ["bunk_mattress", BUDGET_SMALL]]:
		var model := (load(folder + row[0] + ".glb") as PackedScene).instantiate()
		assert_true(_triangles(model) <= row[1], "%s within %d triangles" % row)
		model.free()


func test_split_props_hinge_and_spin_like_the_playable_scenes() -> void:
	# split_animated.py: Viet's locker door on a -X hinge (hinged.gd), the fan rotor on a plumb axis (main.gd).
	var folder := "res://assets/models/graphics_pilot/room407_furnished/"
	var locker := (load(folder + "locker_viet.glb") as PackedScene).instantiate() as Node3D
	tree.root.add_child(locker)
	assert_true(_triangles(locker) <= BUDGET_LARGE, "locker_viet within the large-prop budget")
	var pivot := locker.find_child("DoorPivot", true, false) as Node3D
	var cabinet := _bounds(locker.find_child("LockerBody", true, false) as Node3D, locker)
	assert_true(absf(cabinet.size.x - 0.70) <= 0.01, "as wide as locker_closed")
	assert_true(absf(cabinet.get_center().x) <= 0.01 and absf(cabinet.get_center().z) <= 0.01, "origin at the cabinet centre")
	var shut := _bounds(pivot, locker)
	assert_true(shut.position.x >= cabinet.position.x - 0.01 and shut.end.x <= 0.0, "closed door covers the -X compartment")
	assert_true(shut.position.z >= cabinet.position.z - 0.005 and shut.end.z <= cabinet.position.z + 0.15, "closed door sits in the cabinet front")
	pivot.rotation.y = PI / 2.0
	var opened := _bounds(pivot, locker)
	assert_true(opened.position.z <= cabinet.position.z - 0.2 and opened.end.x <= cabinet.position.x + 0.05, "+90 degrees swings the door out at the hinge side")
	locker.queue_free()
	var fan := (load(folder + "ceiling_fan_split.glb") as PackedScene).instantiate() as Node3D
	tree.root.add_child(fan)
	assert_true(_triangles(fan) <= BUDGET_LARGE, "ceiling_fan_split within the large-prop budget")
	assert_true(absf(_bounds(fan, fan).end.y) <= 0.005, "origin at the canopy top (placed at ceiling height)")
	var rotor := fan.find_child("fan_rotor", true, false) as Node3D
	assert_true(rotor.transform.basis.is_equal_approx(Basis()), "rotor spins about the vertical")
	assert_true(Vector2(rotor.position.x, rotor.position.z).length() <= 0.005, "rotor axis under the downrod")
	# The motor housing (everything within 0.14 m of the axis) is centred on it: no wobble.
	var hub := AABB()
	var first := true
	for vertex: Vector3 in ((rotor.get_child(0) as MeshInstance3D).mesh.surface_get_arrays(0)[Mesh.ARRAY_VERTEX] as PackedVector3Array):
		if Vector2(vertex.x, vertex.z).length() < 0.14:
			hub = AABB(vertex, Vector3.ZERO) if first else hub.expand(vertex)
			first = false
	assert_true(Vector2(hub.get_center().x, hub.get_center().z).length() <= 0.01 and hub.end.y <= 0.005, "hub centred on the axis, below the collar")
	fan.queue_free()
	await wait_frames(2)
