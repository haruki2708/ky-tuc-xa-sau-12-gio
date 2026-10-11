extends TestCase

const Probe := preload("res://scripts/debug/graphics_asset_probe.gd")


func test_measures_transformed_geometry_and_marker() -> void:
	var model := Node3D.new()
	var mesh := MeshInstance3D.new()
	mesh.name = "Visual"
	mesh.mesh = BoxMesh.new()
	mesh.scale = Vector3(2, 3, 4)
	mesh.position = Vector3(1, 2, 3)
	model.add_child(mesh)
	var marker := Marker3D.new()
	marker.name = "Grip"
	marker.position = Vector3(0, 1, 0)
	mesh.add_child(marker)
	var measured := Probe.measure(model)
	assert_eq(int(measured.triangles), 12, "counts imported faces, not manifest claims")
	assert_eq(measured.dimensions_m, [2.0, 3.0, 4.0])
	assert_eq(measured.nodes["Visual/Grip"].position_m, [1.0, 5.0, 3.0])
	assert_false(measured.nodes.has("Missing"))
	model.free()


func test_empty_model_does_not_claim_geometry_measurement() -> void:
	var model := Node3D.new()
	var measured := Probe.measure(model)
	assert_true("geometry_bounds" in measured.unavailable)
	assert_false(measured.has("dimensions_m"))
	model.free()


func test_imported_kit_measurements_are_available() -> void:
	var reports: Array = []
	for path: String in ["res://assets/models/kit/door.glb", "res://assets/models/kit/bunk_bed.glb",
		"res://assets/models/room407/backpack.glb"]:
		var scene := load(path) as PackedScene
		assert_not_null(scene, "existing kit model imports")
		if scene == null:
			continue
		var model := scene.instantiate() as Node3D
		assert_not_null(model, "existing kit model has a 3D root")
		if model == null:
			continue
		var report := Probe.report_for(model, path)
		assert_true(report.triangles > 0, "real imported faces are measured")
		assert_true(report.material_count > 0, "imported materials are measured")
		assert_true(report.has("dimensions_m"), "real imported bounds are measured")
		assert_true(report.dependency_hashes.has("game/" + path.trim_prefix("res://") + ".import"))
		assert_eq(report.dependency_unavailable, [], "dependency closure is readable")
		assert_true(report.dependency_hashes.has("game/assets/models/kit/kit_import.gd"),
			"includes inherited importer code even when ResourceLoader omits it")
		assert_true(report.dependency_hashes.has("game/rendering/ps1_surface_cutout.gdshader"),
			"includes literal preload dependencies, including inactive material variants")
		assert_true(report.dependency_hashes.has("game/rendering/ps1_surface.gdshaderinc"),
			"includes shader source dependencies")
		if path.ends_with("backpack.glb"):
			var expected := [0.29, 0.45636, 0.30274]
			for axis in range(3):
				assert_true(absf(report.dimensions_m[axis] - expected[axis]) < 0.0001,
					"backpack local bounds match B's G0 measurements")
		reports.append(report)
		model.free()
	print("GRAPHICS_PROBE_JSON=" + JSON.stringify(reports))


func test_root_placement_does_not_change_local_bounds_or_markers() -> void:
	var model := Node3D.new()
	var mesh := MeshInstance3D.new()
	mesh.name = "Visual"
	mesh.mesh = BoxMesh.new()
	mesh.position = Vector3(1, 2, 3)
	mesh.scale = Vector3(2, 3, 4)
	model.add_child(mesh)
	var marker := Marker3D.new()
	marker.name = "Grip"
	marker.position = Vector3(0, 1, 0)
	mesh.add_child(marker)
	var before := Probe.measure(model)
	model.position = Vector3(33.78, 0.02, -4.52)
	model.rotation_degrees = Vector3(15, 90, 30)
	model.scale = Vector3(2, 3, 4)
	var after := Probe.measure(model)
	assert_eq(after.dimensions_m, before.dimensions_m)
	assert_eq(after.bounds_min_m, before.bounds_min_m)
	assert_eq(after.nodes["Visual/Grip"].position_m, before.nodes["Visual/Grip"].position_m)
	assert_eq(after.nodes["."].position_m, [0.0, 0.0, 0.0])
	for axis in range(3):
		assert_true(absf(after.root_placement.scale[axis] - [2.0, 3.0, 4.0][axis]) < 0.00001)
	assert_eq(after.coordinate_space, "selected_root_local")
	model.free()


func test_hidden_variant_is_included_and_reported_explicitly() -> void:
	var model := Node3D.new()
	var hidden_mesh := MeshInstance3D.new()
	hidden_mesh.mesh = BoxMesh.new()
	hidden_mesh.visible = false
	model.add_child(hidden_mesh)
	var report := Probe.measure(model)
	assert_eq(int(report.triangles), 12)
	assert_eq(report.visibility_policy, "include_hidden")
	model.free()
