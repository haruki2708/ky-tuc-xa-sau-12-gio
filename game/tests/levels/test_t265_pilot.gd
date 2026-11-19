extends TestCase
## T-265 round 1: the pilot's glbs (no scene uses them yet; capture_wave8.gd hangs them at run time). Every wave-8
## texture imports VRAM compressed; every glb maps its materials onto shared .tres files; the counter's new top keeps the
## iron bar lying on it (gap <= 2 cm) and the old collider's top within 3 cm under it; shelves, books and tables stay inside
## the PS1 colliders' envelope; the new back leaf fits its Hinge frame and clears the jamb when open; the map stays on the
## PS1 board's footprint; the stairs' treads stay over the PS1 flight. Round 2 replaces this file.

const MODELS := "res://assets/models/graphics_pilot/realistic_map/wave8/"
const TEXTURES := "res://assets/textures/graphics_pilot/realistic_map/wave8/"
const G := -9.9
const GLBS := ["shell_f1", "shell_f2", "shell_f3", "stairs", "counter_q1", "counter_q2", "librarian_chair", "map_print", "map_drawn",
	"shelf_steel", "shelf_wood", "books_full", "books_sparse", "books_tipped", "table_t1", "table_t2", "rule_book", "back_frame",
	"back_leaf", "front_door", "barricade", "facade_e1", "facade_e2", "strip", "fill_m2", "fill_m3", "mess"]


## Vertices per MeshInstance3D name of a glb whose root sits at (0, y0, 0).
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


func _inside(file: String, box: AABB, y0: float = G) -> void:
	var parts := glb_vertices(file, y0)
	for name: String in parts:
		for v: Vector3 in parts[name]:
			if not box.grow(0.0005).has_point(v):
				assert_true(false, "%s/%s vertex %s inside %s" % [file, name, v, box])
				return


func test_every_wave8_texture_imports_vram_compressed() -> void:
	var count := 0
	for file in DirAccess.get_files_at(TEXTURES):
		if not file.ends_with(".png"):
			continue
		count += 1
		var config := ConfigFile.new()
		assert_eq(config.load(TEXTURES + file + ".import"), OK, file + " has import settings")
		assert_eq(config.get_value("params", "compress/mode"), 2, file + " VRAM compressed")
		assert_eq(config.get_value("params", "compress/normal_map"), 1 if file.ends_with("_normal.png") else 0, file + " normal-map flag")
	assert_true(count >= 11, "wave 8 textures found (%d)" % count)


func test_glbs_use_only_shared_materials() -> void:
	var triangles := 0
	for glb: String in GLBS:
		var root := (load(MODELS + glb + ".glb") as PackedScene).instantiate() as Node3D
		var own := 0
		for mesh: MeshInstance3D in root.find_children("*", "MeshInstance3D", true, false):
			own += mesh.mesh.get_faces().size() / 3
			for surface in mesh.mesh.get_surface_count():
				var material := mesh.mesh.surface_get_material(surface)
				assert_true(material != null and material.resource_path.begins_with("res://assets/models/graphics_pilot/realistic_map/"),
					"%s/%s surface %d uses a shared material" % [glb, mesh.name, surface])
		print("T265_PILOT_TRIANGLES %s %d" % [glb, own])
		triangles += own
		root.free()
	print("T265_PILOT_TRIANGLES total %d" % triangles)


func test_counter_top_holds_the_iron_bar() -> void:
	# The bar's middle line is 0.9 over the floor (Counter/IronBar), its radius 0.0135: its foot at 0.8865. The PS1 top's
	# collider ends at 0.84. The new top face under the bar (x 57.9..58.1, z 205.5..206.5) must sit 0..2 cm under the bar's
	# foot and at most 3 cm over the collider.
	var foot := G + 0.9 - IronBarWeapon.RADIUS
	for file in ["counter_q1", "counter_q2"]:
		var top := -INF
		var root := (load(MODELS + file + ".glb") as PackedScene).instantiate() as Node3D
		for mesh: MeshInstance3D in root.find_children("*", "MeshInstance3D", true, false):
			var faces := mesh.mesh.get_faces()
			for i in range(0, faces.size(), 3):
				var a := faces[i] + Vector3(0, G, 0)
				var b := faces[i + 1] + Vector3(0, G, 0)
				var c := faces[i + 2] + Vector3(0, G, 0)
				if absf(a.y - b.y) > 0.0005 or absf(a.y - c.y) > 0.0005 or a.y > foot + 0.001:
					continue
				for p: Vector2 in [Vector2(58.0, 205.6), Vector2(58.0, 206.0), Vector2(58.0, 206.4)]:
					if Geometry2D.point_is_inside_triangle(p, Vector2(a.x, a.z), Vector2(b.x, b.z), Vector2(c.x, c.z)):
						top = maxf(top, a.y)
		root.free()
		assert_true(foot - top >= 0.0 and foot - top <= 0.02, "%s: the bar lies on the top (gap %.4f)" % [file, foot - top])
		assert_true(top - (G + 0.84) <= 0.03, "%s: the collider's top within 3 cm under it (%.4f)" % [file, top - (G + 0.84)])


func test_shelves_books_and_tables_fit_the_ps1_colliders() -> void:
	# Shelf<t>_<x>: sides x +-1.52, depth z -0.3..0.3, height 2.2 (local); the new stack may stand 3 cm proud.
	for file in ["shelf_steel", "shelf_wood"]:
		_inside(file, AABB(Vector3(-1.55, 0.0, -0.33), Vector3(3.1, 2.2, 0.64)), 0.0)
	for file in ["books_full", "books_sparse", "books_tipped"]:
		# Between the stack's sides (inner faces at +-1.48) and in front of its back panel (z 0.22).
		_inside(file, AABB(Vector3(-1.48, 0.1, -0.3), Vector3(2.96, 2.1, 0.52)), 0.0)
	# ReadingTable<x>: the top 3 x 1.4 at 0.72..0.84 (only Top is solid); the table under it, the chairs 1.2 m out.
	var tables := glb_vertices("table_t1", 0.0)
	for v: Vector3 in tables["TableT1"]:
		assert_true(absf(v.x) <= 1.5001 and absf(v.z) <= 0.7001 and v.y <= 0.8401, "table_t1 vertex %s inside the PS1 table" % v)
		if absf(v.x) > 1.5001 or absf(v.z) > 0.7001 or v.y > 0.8401:
			break
	# The barricade's table inside the PS1 table's top (2.6 x 1.3 at (65, 196), 0.84 high).
	var bar := glb_vertices("barricade")
	for v: Vector3 in bar["BarricadeTable"]:
		assert_true(absf(v.x - 65.0) <= 1.3001 and absf(v.z - 196.0) <= 0.6501 and v.y <= G + 0.8401, "barricade table vertex %s" % v)
		if absf(v.x - 65.0) > 1.3001:
			break


func test_back_leaf_fits_its_hinge_and_clears_the_jamb() -> void:
	# In BackDoor/Hinge's frame: the leaf 0..1.94 wide, 2.4 high, within 0.1 of the wall's plane; open (Hinge turned 90
	# degrees about y), its hinge side stays at x >= 64.0 (the jamb's face).
	var parts := glb_vertices("back_leaf", 0.0)
	var open := Basis(Vector3.UP, PI / 2.0)
	for name: String in parts:
		for v: Vector3 in parts[name]:
			var ok := v.x >= -0.015 and v.x <= 1.94 and v.y >= -0.001 and v.y <= 2.4 and absf(v.z) <= 0.1
			assert_true(ok, "back_leaf/%s vertex %s inside the leaf's frame" % [name, v])
			var world := Vector3(64.03, G, 225.0) + open * v
			if world.z > 224.89:
				assert_true(world.x >= 63.999, "back_leaf/%s open vertex %s clears the jamb (x 64)" % [name, world])
			if not ok:
				return


func test_map_stays_on_the_ps1_board() -> void:
	for file in ["map_print", "map_drawn"]:
		_inside(file, AABB(Vector3(45.11, -9.16, 209.44), Vector3(0.1, 2.12, 3.12)))


func test_stair_treads_stay_over_the_ps1_flights() -> void:
	# Stairs0/1: x 79..84, z 199..209 (with a 2 cm nosing in front of the first riser); each tread's top on the ramp's middle
	# line (within half a riser of the collider's slope).
	for v: Vector3 in glb_vertices("stairs")["Treads"]:
		assert_true(v.x >= 79.0 and v.x <= 84.0 and v.z >= 198.97 and v.z <= 209.0, "tread vertex %s over the flight" % v)
		var off := INF
		for level: float in [-9.9, -6.6]:
			var ramp := level + (v.z - 199.0) * 0.33
			if absf(v.y - ramp) < absf(off):
				off = v.y - ramp
		# Tread tops within half a riser (7.5 cm) of the slope, their 4 cm slabs and the 2 cm nosings under that.
		assert_true(absf(off) <= 0.125, "tread vertex %s within 12.5 cm of the ramp (%.3f)" % [v, off])
		if absf(off) > 0.125 or v.x < 79.0 or v.x > 84.0:
			break
