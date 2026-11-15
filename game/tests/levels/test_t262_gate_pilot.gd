extends TestCase
## T-262 round 1: the gate pilot's assets (no scene uses them yet; capture_wave5.gd hangs them into chapter 3 at run
## time). Textures VRAM compressed, glbs only on shared materials, every piece inside the space a PS1 collider already
## blocks (or out of reach: above head height, outside the wall), and nothing new on the sightlines from Start_gate and
## the road to the twelve guards' chests, so round 2 can hang them without touching a collider or the guards' scene.

const W5 := "res://assets/models/graphics_pilot/realistic_map/wave5/"
const W5_TEXTURES := "res://assets/textures/graphics_pilot/realistic_map/wave5/"
const G := -9.9
const GROUND := -9.94
const HEAD := 2.0
const GLBS := ["court", "outside", "court_cracks", "pillars_plaster", "pillars_brick", "gate_swing", "gate_folding", "sign_arch",
	"sign_band", "sign_letters", "booth_masonry", "booth_prefab", "booth_interior", "wall_plaster", "wall_brick", "barrier", "cone"]
const BARRIERS := [Vector3(213.0, -49.5, 8.0), Vector3(227.0, -49.5, -6.0)]


## World-space vertices of every mesh in a glb placed by `xform` (default: the glb origin at Godot (0, G, 0)).
func _vertices(glb: String, xform: Transform3D = Transform3D(Basis.IDENTITY, Vector3(0, G, 0))) -> PackedVector3Array:
	var root := (load(W5 + glb + ".glb") as PackedScene).instantiate() as Node3D
	var out := PackedVector3Array()
	for mesh: MeshInstance3D in root.find_children("*", "MeshInstance3D", true, false):
		var xf := xform * _local(mesh, root)
		for s in mesh.mesh.get_surface_count():
			for v: Vector3 in mesh.mesh.surface_get_arrays(s)[Mesh.ARRAY_VERTEX]:
				out.append(xf * v)
	root.free()
	return out


## World-space triangles (flat list, three vertices each) of a glb.
func _triangles(glb: String, xform: Transform3D = Transform3D(Basis.IDENTITY, Vector3(0, G, 0))) -> PackedVector3Array:
	var root := (load(W5 + glb + ".glb") as PackedScene).instantiate() as Node3D
	var out := PackedVector3Array()
	for mesh: MeshInstance3D in root.find_children("*", "MeshInstance3D", true, false):
		var xf := xform * _local(mesh, root)
		for v: Vector3 in mesh.mesh.get_faces():
			out.append(xf * v)
	root.free()
	return out


func _local(node: Node3D, root: Node3D) -> Transform3D:
	var xf := Transform3D.IDENTITY
	var n: Node = node
	while n != null and n != root:
		xf = (n as Node3D).transform * xf
		n = n.get_parent()
	return xf


## Pillar-local coordinates (centre origin) of a world point, Pillar209 turned 7 degrees about z as in gate.tscn.
func _pillar_local(v: Vector3, x: float, degrees: float) -> Vector3:
	var basis := Basis(Vector3(0, 0, 1), deg_to_rad(degrees))
	return basis.inverse() * (v - Vector3(x, -6.9, -59.0))


func test_textures_are_vram_compressed() -> void:
	var checked := 0
	for file in DirAccess.get_files_at(W5_TEXTURES):
		if not file.ends_with(".png.import"):
			continue
		var text := FileAccess.get_file_as_string(W5_TEXTURES + file)
		assert_true(text.contains("compress/mode=2"), "%s is VRAM compressed" % file)
		assert_true(text.contains("compress/normal_map=%d" % (1 if file.contains("_normal.") else 0)), "%s normal-map flag" % file)
		assert_true(text.contains("\"vram_texture\": true"), "%s imported as a VRAM texture" % file)
		checked += 1
	assert_eq(checked, 16, "wave-5 textures checked")


func test_glbs_use_only_shared_materials() -> void:
	for glb: String in GLBS:
		var text := FileAccess.get_file_as_string(W5 + glb + ".glb.import")
		assert_false(text.is_empty(), "%s.glb.import exists" % glb)
		assert_true(text.count("\"use_external/enabled\": true") > 0, "%s maps its materials" % glb)
		var root := (load(W5 + glb + ".glb") as PackedScene).instantiate() as Node3D
		for mesh: MeshInstance3D in root.find_children("*", "MeshInstance3D", true, false):
			for s in mesh.mesh.get_surface_count():
				var m := mesh.mesh.surface_get_material(s)
				assert_true(m != null and m.resource_path.begins_with("res://assets/models/graphics_pilot/realistic_map/"),
					"%s/%s surface %d uses a shared material (%s)" % [glb, mesh.name, s, m.resource_path if m != null else "none"])
		root.free()


func test_gate_leaves_stay_in_the_gate_collider() -> void:
	for glb in ["gate_swing", "gate_folding"]:
		var outside := PackedVector3Array()
		for v in _vertices(glb):
			if v.x < 209.7 or v.x > 230.3 or v.z < -59.09 or v.z > -58.91 or v.y < G - 0.01 or v.y > G + 4.0:
				outside.append(v)
		assert_eq(outside.size(), 0, "%s inside Gate/Gate's 20 x 4 x 0.18 m (%s)" % [glb, outside.slice(0, 3)])


func test_pillars_stay_in_their_colliders() -> void:
	for glb in ["pillars_plaster", "pillars_brick"]:
		for v in _vertices(glb):
			var near_209 := v.x < 220.0
			var p := _pillar_local(v, 209.0 if near_209 else 231.0, 7.0 if near_209 else 0.0)
			# The plinth goes 0.3 m under the court so the tilted pillar's lifted corner meets the ground.
			assert_true(absf(p.x) <= 0.701 and absf(p.z) <= 0.701 and p.y <= 3.0 and p.y >= -3.31,
				"%s vertex %s inside its pillar collider (local %s)" % [glb, v, p])


func test_signs_hang_in_the_gate_plane_below_head_height() -> void:
	for glb in ["sign_arch", "sign_band", "sign_letters"]:
		for v in _vertices(glb):
			assert_true(v.x >= 208.3 and v.x <= 231.75, "%s vertex %s between the pillars" % [glb, v])
			if v.y < G + HEAD + 0.3:
				assert_true(v.z >= -59.09 and v.z <= -58.91, "%s vertex %s low down stays in the gate collider's 0.18 m" % [glb, v])


func test_booth_wall_and_court_stay_where_the_ps1_blocked_or_lay() -> void:
	for glb in ["booth_masonry", "booth_prefab", "booth_interior"]:
		for v in _vertices(glb):
			var inside := v.x >= 237.499 and v.x <= 242.501 and v.z >= -56.001 and v.z <= -51.999 and v.y >= G - 0.01
			assert_true(inside or v.y >= G + 2.85, "%s vertex %s inside the Booth collider or roof height" % [glb, v])
	for glb in ["wall_plaster", "wall_brick"]:
		for v in _vertices(glb):
			var run := (v.x >= 185.99 and v.x <= 208.31) or (v.x >= 231.69 and v.x <= 262.01)
			assert_true(run and v.z >= -60.151 and v.z <= -59.849 and v.y >= G - 0.01 and v.y <= G + 3.001,
				"%s vertex %s inside Fence/S (500 x 3 x 0.3 m) beside the gate" % [glb, v])
	for v in _vertices("court"):
		assert_true(v.x >= 190.0 and v.x <= 250.0 and v.z >= -60.0 and v.z <= -20.0 and v.y >= GROUND - 0.001 and v.y <= G + 0.001,
			"court vertex %s on the Court box" % v)
	for v in _vertices("court_cracks"):
		assert_true(v.y >= G and v.y <= G + 0.01, "crack vertex %s flat on the court" % v)
	for v in _vertices("outside"):
		assert_true(v.z <= -60.149, "outside vertex %s beyond the wall, out of reach" % v)


func test_barrier_and_cone_fit_the_ps1_pieces() -> void:
	for v in _vertices("barrier", Transform3D.IDENTITY):
		assert_true(absf(v.x) <= 1.1 and absf(v.z) <= 0.25 and v.y >= 0.0 and v.y <= 1.0, "barrier vertex %s inside the 2.2 x 1.0 x 0.5 m collider" % v)
	for v in _vertices("cone", Transform3D.IDENTITY):
		assert_true(Vector2(v.x, v.z).length() <= 0.3 and v.y >= 0.0 and v.y <= 0.71, "cone vertex %s within a 0.7 m cone" % v)


func test_sightlines_to_the_twelve_guards_stay_clear() -> void:
	# Every pilot piece of both option sets, the barriers placed as the PS1 ones.
	var tris := PackedVector3Array()
	for glb in ["pillars_plaster", "pillars_brick", "gate_swing", "gate_folding", "sign_arch", "sign_band", "sign_letters",
			"booth_masonry", "booth_prefab", "booth_interior", "wall_plaster", "wall_brick"]:
		tris.append_array(_triangles(glb))
	for b: Vector3 in BARRIERS:
		tris.append_array(_triangles("barrier", Transform3D(Basis(Vector3.UP, deg_to_rad(b.z)), Vector3(b.x, G, b.y))))
	var eyes: Array[Vector3] = [Vector3(220, G + 1.6, -25), Vector3(220, G + 1.6, -15), Vector3(205, G + 1.6, -16), Vector3(235, G + 1.6, -30)]
	var blocked: Array[String] = []
	for eye: Vector3 in eyes:
		for i in 12:
			var chest := Vector3(210.0 + i * 20.0 / 11.0, G + 1.3, -54.0)
			for t in range(0, tris.size(), 3):
				if Geometry3D.segment_intersects_triangle(eye, chest, tris[t], tris[t + 1], tris[t + 2]) != null:
					blocked.append("G%02d from %s" % [i + 1, eye])
					break
	assert_eq(blocked.size(), 0, "nothing new between the eye and a guard's chest (%s)" % [blocked])
