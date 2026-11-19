extends TestCase
## T-264 round 1: the pilot's glbs (no scene uses them yet; capture_wave7.gd hangs them at run time). Every wave-7 texture
## imports VRAM compressed; every glb maps its materials onto shared .tres files; the three trees keep only the trunk
## (inside TreeTrunk's 0.5 m box) below 3 m and no leaf there; the fence pieces stay inside Fence/W's collider, the bench
## inside BenchBody2's, the moped inside MopedBody1's; building A's new front adds nothing under head height more than
## 0.15 m out from its collider. Round 2 moved the buildings to test_t264_buildings.gd and dropped the options the owner did not
## pick (D-182); round 3 replaces this file.

const MODELS := "res://assets/models/graphics_pilot/realistic_map/wave7/"
const TEXTURES := "res://assets/textures/graphics_pilot/realistic_map/wave7/"
const G := -9.9
const HEAD := G + 2.0
const GLBS := ["road_asphalt", "verge_grass", "tree_bang", "tree_phuong", "tree_xacu", "lamp_steel", "bench", "moped", "fence_b40"]


## World-space vertices per MeshInstance3D name of a glb whose root sits at (0, y0, 0).
static func glb_vertices(file: String, y0: float = G) -> Dictionary:
	var root := (load(MODELS + file + ".glb") as PackedScene).instantiate() as Node3D
	var out := {}
	for mesh: MeshInstance3D in root.find_children("*", "MeshInstance3D", true, false):
		var xf := mesh.transform
		var up := mesh.get_parent() as Node3D
		while up != null and up != root:
			xf = up.transform * xf
			up = up.get_parent() as Node3D
		xf = Transform3D(Basis.IDENTITY, Vector3(0, y0, 0)) * xf
		var verts := PackedVector3Array()
		for s in mesh.mesh.get_surface_count():
			for v: Vector3 in mesh.mesh.surface_get_arrays(s)[Mesh.ARRAY_VERTEX]:
				verts.append(xf * v)
		out[String(mesh.name)] = verts
	root.free()
	return out


func test_every_wave7_texture_imports_vram_compressed() -> void:
	var count := 0
	for file in DirAccess.get_files_at(TEXTURES):
		if not file.ends_with(".png"):
			continue
		count += 1
		var config := ConfigFile.new()
		assert_eq(config.load(TEXTURES + file + ".import"), OK, file + " has import settings")
		assert_eq(config.get_value("params", "compress/mode"), 2, file + " VRAM compressed")
		assert_eq(config.get_value("params", "compress/normal_map"), 1 if file.ends_with("_normal.png") else 0, file + " normal-map flag")
	assert_true(count >= 15, "wave 7 textures found (%d)" % count)


func test_glbs_use_only_shared_materials() -> void:
	var triangles := 0
	for glb: String in GLBS:
		var root := (load(MODELS + glb + ".glb") as PackedScene).instantiate() as Node3D
		for mesh: MeshInstance3D in root.find_children("*", "MeshInstance3D", true, false):
			triangles += mesh.mesh.get_faces().size() / 3
			for surface in mesh.mesh.get_surface_count():
				var material := mesh.mesh.surface_get_material(surface)
				assert_true(material != null and material.resource_path.begins_with("res://assets/models/graphics_pilot/realistic_map/"),
					"%s/%s surface %d uses a shared material" % [glb, mesh.name, surface])
		root.free()
	print("T264_PILOT_TRIANGLES %d" % triangles)


func test_trees_keep_the_trunk_box_and_no_leaf_below_three_metres() -> void:
	for species in ["bang", "phuong", "xacu"]:
		var parts := glb_vertices("tree_" + species, 0.0)
		for v: Vector3 in parts["Leaves"]:
			assert_true(v.y >= 3.0, "%s leaf vertex %s at or over 3 m" % [species, v])
			if v.y < 3.0:
				break
		for v: Vector3 in parts["Bark"]:
			if v.y < 3.0:
				assert_true(absf(v.x) <= 0.25 and absf(v.z) <= 0.25, "%s trunk vertex %s inside TreeTrunk's 0.5 m box" % [species, v])
				if absf(v.x) > 0.25 or absf(v.z) > 0.25:
					break


func _inside(file: String, box: AABB) -> void:
	for name: String in glb_vertices(file).keys():
		for v: Vector3 in glb_vertices(file)[name]:
			if not box.has_point(v):
				assert_true(false, "%s/%s vertex %s inside %s" % [file, name, v, box])
				return


func test_fence_bench_and_moped_stay_inside_their_colliders() -> void:
	for file in ["fence_b40"]:
		_inside(file, AABB(Vector3(-80.16, G - 0.07, 94.8), Vector3(0.32, 3.08, 30.4)))
	_inside("bench", AABB(Vector3(148 - 1.21, G - 0.01, -22 - 0.31), Vector3(2.42, 0.82, 0.62)))
	_inside("moped", AABB(Vector3(145 - 0.95, G - 0.06, -18 - 0.6), Vector3(1.9, 0.72, 1.2)))
