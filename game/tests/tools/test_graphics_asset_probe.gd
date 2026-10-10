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
	for name in ["door", "bunk_bed"]:
		var path := "res://assets/models/kit/%s.glb" % name
		var scene := load(path) as PackedScene
		assert_not_null(scene, "existing kit model imports")
		if scene == null:
			continue
		var model := scene.instantiate() as Node3D
		assert_not_null(model, "existing kit model has a 3D root")
		if model == null:
			continue
		var report := Probe.measure(model)
		assert_true(report.triangles > 0, "real imported faces are measured")
		assert_true(report.material_count > 0, "imported materials are measured")
		assert_true(report.has("dimensions_m"), "real imported bounds are measured")
		report["file"] = "game/" + path.trim_prefix("res://")
		report["sha256"] = FileAccess.get_sha256(path)
		report["engine"] = Engine.get_version_info().string
		report["method"] = "Godot imported Mesh.get_faces; rest pose; root-local transforms"
		reports.append(report)
		model.free()
	print("GRAPHICS_PROBE_JSON=" + JSON.stringify(reports))
