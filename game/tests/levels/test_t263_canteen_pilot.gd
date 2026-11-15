extends TestCase
## T-263 round 1: the canteen pilot's glbs (no scene uses them yet; capture_wave6.gd hangs them at run time). Every
## wave-6 texture imports VRAM compressed; every glb maps its materials onto shared .tres files; tables and stools
## (both options, knocked stools too), the stoves and their pots stay inside the PS1 colliders below head height; the
## door openings are not narrowed (main door to 3.3 m, west exit and store door to 2.4 m, kitchen opening to 3.3 m);
## the new clock reads 4:00 like KitchenClock's stopped_hour; the lit screen lies within the PS1 TV's box.
## Round 2 replaces this file with test_t263_canteen.gd.

const MODELS := "res://assets/models/graphics_pilot/realistic_map/wave6/"
const TEXTURES := "res://assets/textures/graphics_pilot/realistic_map/wave6/"
const CANTEEN := preload("res://scenes/levels/campus/canteen.tscn")
const G := -9.9
const HEAD := G + 2.0
const GLBS := ["hall_shell", "windows", "ceiling_panels", "ceiling_roof", "lights_fans", "tables_inox", "tables_stone",
	"tables_stone_mess", "tableware", "tableware_mess", "counter_inox", "counter_tiled", "price_boards", "tv", "tv_screen",
	"kitchen_room", "kitchen_k1", "kitchen_k2", "clock", "facade"]


## World-space vertices of every mesh in a glb (root at Godot (0, G, 0)), per MeshInstance3D name.
static func glb_vertices(file: String) -> Dictionary:
	var root := (load(MODELS + file + ".glb") as PackedScene).instantiate() as Node3D
	var out := {}
	for mesh: MeshInstance3D in root.find_children("*", "MeshInstance3D", true, false):
		var xf := mesh.transform
		var up := mesh.get_parent() as Node3D
		while up != null and up != root:
			xf = up.transform * xf
			up = up.get_parent() as Node3D
		xf = Transform3D(Basis.IDENTITY, Vector3(0, G, 0)) * xf
		var verts := PackedVector3Array()
		for s in mesh.mesh.get_surface_count():
			for v: Vector3 in mesh.mesh.surface_get_arrays(s)[Mesh.ARRAY_VERTEX]:
				verts.append(xf * v)
		out[String(mesh.name)] = verts
	root.free()
	return out


static func collider_boxes(canteen: Node, prefix: String) -> Array[AABB]:
	var boxes: Array[AABB] = []
	for shape: CollisionShape3D in canteen.find_children("*", "CollisionShape3D", true, false):
		var body := shape.get_parent()
		var path := String(canteen.get_path_to(body))
		if not path.begins_with(prefix):
			continue
		var size := (shape.shape as BoxShape3D).size
		boxes.append(shape.global_transform * AABB(-size / 2, size))
	return boxes


func _inside(v: Vector3, boxes: Array[AABB], grow: float) -> bool:
	for box: AABB in boxes:
		var b := box.grow(grow)
		if v.x >= b.position.x and v.x <= b.end.x and v.z >= b.position.z and v.z <= b.end.z:
			return true
	return false


func test_every_wave6_texture_imports_vram_compressed() -> void:
	var count := 0
	for file in DirAccess.get_files_at(TEXTURES):
		if not file.ends_with(".png.import"):
			continue
		var text := FileAccess.get_file_as_string(TEXTURES + file)
		assert_true(text.contains("compress/mode=2"), file + " VRAM compressed")
		if file.contains("_normal"):
			assert_true(text.contains("compress/normal_map=1"), file + " flagged as a normal map")
		count += 1
	assert_true(count >= 15, "wave-6 textures (%d)" % count)


func test_every_glb_uses_shared_materials_only() -> void:
	for glb: String in GLBS:
		var text := FileAccess.get_file_as_string(MODELS + glb + ".glb.import")
		assert_true(text.contains("use_external/enabled\": true"), glb + " maps its materials onto shared .tres")
		var paths := RegEx.create_from_string("use_external/path\": \"([^\"]+)\"").search_all(text)
		assert_true(paths.size() > 0, glb + " has material entries")
		for m: RegExMatch in paths:
			assert_true(ResourceLoader.exists(m.get_string(1)), "%s: %s exists" % [glb, m.get_string(1)])


func test_tables_and_stools_stay_inside_the_table_colliders() -> void:
	var canteen := CANTEEN.instantiate() as Node3D
	tree.root.add_child(canteen)
	var boxes := collider_boxes(canteen, "Table_")
	assert_eq(boxes.size(), 21, "21 table colliders")
	for glb in ["tables_inox", "tables_stone", "tables_stone_mess"]:
		var outside := 0
		var verts := glb_vertices(glb)
		for name: String in verts:
			for v: Vector3 in verts[name]:
				if v.y < HEAD and not _inside(v, boxes, 0.06):
					outside += 1
		assert_eq(outside, 0, glb + ": every vertex below head height over a table's collider")
	canteen.free()


func test_stoves_and_pots_stay_over_the_cooktop_collider() -> void:
	var canteen := CANTEEN.instantiate() as Node3D
	tree.root.add_child(canteen)
	var boxes := collider_boxes(canteen, "Cooktop")
	assert_eq(boxes.size(), 1, "the cooktop collider")
	for glb in ["kitchen_k1", "kitchen_k2"]:
		var outside := 0
		var verts := glb_vertices(glb)
		for name: String in verts:
			for v: Vector3 in verts[name]:
				if v.y < HEAD and not _inside(v, boxes, 0.08):
					outside += 1
		assert_eq(outside, 0, glb + ": everything under head height over the cooktop (the hood is higher)")
	canteen.free()


func test_door_openings_are_not_narrowed() -> void:
	# [x0, x1, z0, z1, lowest y allowed] of the openings' clear volume (the floor and threshold lie under G + 0.02).
	var openings := [[186.02, 193.98, 19.86, 20.14, -6.6], [169.86, 170.14, 39.52, 41.48, -7.5], [201.02, 202.98, 43.86, 44.14, -7.5],
		[186.02, 197.98, 43.86, 44.14, -6.6]]
	for glb in ["hall_shell", "windows", "facade", "ceiling_panels", "lights_fans", "price_boards", "counter_inox", "counter_tiled"]:
		var verts := glb_vertices(glb)
		for name: String in verts:
			for v: Vector3 in verts[name]:
				for o: Array in openings:
					if v.x > o[0] and v.x < o[1] and v.z > o[2] and v.z < o[3] and v.y > G + 0.02 and v.y < o[4] - 0.001:
						assert_true(false, "%s/%s narrows an opening at %s" % [glb, name, v])
						return


func test_clock_reads_four_and_the_screen_is_in_the_ps1_tv() -> void:
	var canteen := CANTEEN.instantiate() as Node3D
	tree.root.add_child(canteen)
	var clock := canteen.get_node("KitchenClock") as Node3D
	assert_eq(int(clock.get_meta("stopped_hour")), 4, "KitchenClock stopped at 4")
	var centre := clock.global_position
	var root := (load(MODELS + "clock.glb") as PackedScene).instantiate() as Node3D
	var hour_tips: Array[Vector2] = []
	for mesh: MeshInstance3D in root.find_children("*", "MeshInstance3D", true, false):
		for s in mesh.mesh.get_surface_count():
			if mesh.mesh.surface_get_material(s).resource_name != "W1ClockHand":
				continue
			for v: Vector3 in mesh.mesh.surface_get_arrays(s)[Mesh.ARRAY_VERTEX]:
				var w := mesh.transform * v + Vector3(0, G, 0)
				var d := Vector2(w.x - centre.x, w.y - centre.y)
				if d.length() > 0.1 and d.length() < 0.15:
					hour_tips.append(d)
	root.free()
	assert_true(hour_tips.size() >= 2, "the hour hand's tip")
	for d: Vector2 in hour_tips:
		# Seen from the kitchen (looking +z) 4 o'clock is down and to the viewer's right, which is -x.
		var angle := rad_to_deg(atan2(-d.x, d.y))
		assert_true(absf(angle - 120.0) < 8.0, "hour hand at 4 o'clock (%f degrees clockwise from 12)" % angle)
	# The new panel's screen (1.11 x 0.68) is a little wider than the PS1 one (1.04 x 0.66): inside the PS1 case's box.
	var case := (canteen.get_node("TV/Case/Mesh") as MeshInstance3D)
	var ps1 := case.global_transform * case.get_aabb()
	var lit := glb_vertices("tv_screen")
	for name: String in lit:
		for v: Vector3 in lit[name]:
			assert_true(ps1.grow(0.02).has_point(v), "lit screen inside the PS1 TV case's box (%s)" % v)
	canteen.free()
