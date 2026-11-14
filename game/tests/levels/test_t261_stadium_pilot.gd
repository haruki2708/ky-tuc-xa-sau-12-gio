extends TestCase
## T-261 round 1: the stadium pilot's assets (no scene uses them yet; capture_wave4.gd hangs them into chapter 3 at
## run time). Textures VRAM compressed, glbs only on shared materials, and every piece stays inside the space the
## PS1 colliders already block or above head height, so round 2 can hang them without touching a collider.

const W4 := "res://assets/models/graphics_pilot/realistic_map/wave4/"
const W4_TEXTURES := "res://assets/textures/graphics_pilot/realistic_map/wave4/"
const G := -9.9
const STAND_Z0 := 212.7
const COLUMNS_Z := 228.9
const AISLES := [Vector2(170, 176), Vector2(195, 201), Vector2(220, 226)]
const GLBS := ["field", "goal", "stand", "stand_seats", "pole_steel", "pole_concrete", "fence_b40", "fence_bars", "gate_pillars"]


## World-space vertices of every mesh in a glb placed at `at` (stadium space: the glb origin is Godot (0, G, 0)).
func _vertices(glb: String, at: Vector3 = Vector3(0, G, 0), only: String = "") -> PackedVector3Array:
	var root := (load(W4 + glb + ".glb") as PackedScene).instantiate() as Node3D
	var out := PackedVector3Array()
	for mesh: MeshInstance3D in root.find_children("*", "MeshInstance3D", true, false):
		if not only.is_empty() and String(mesh.name) != only:
			continue
		var xf := Transform3D(Basis.IDENTITY, at) * _local(mesh, root)
		for s in mesh.mesh.get_surface_count():
			for v: Vector3 in mesh.mesh.surface_get_arrays(s)[Mesh.ARRAY_VERTEX]:
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


func _ramp(z: float) -> float:
	return G + maxf(0.0, (z - STAND_Z0) * (6.84 / 15.3))


func test_textures_are_vram_compressed() -> void:
	var dir := DirAccess.open(W4_TEXTURES)
	var checked := 0
	for file in dir.get_files():
		if not file.ends_with(".png.import"):
			continue
		var text := FileAccess.get_file_as_string(W4_TEXTURES + file)
		assert_true(text.contains("compress/mode=2"), "%s is VRAM compressed" % file)
		if file.contains("_normal."):
			assert_true(text.contains("compress/normal_map=1"), "%s is flagged as a normal map" % file)
		checked += 1
	assert_eq(checked, 12, "wave-4 textures checked")


func test_glbs_use_only_shared_materials() -> void:
	for glb: String in GLBS:
		var text := FileAccess.get_file_as_string(W4 + glb + ".glb.import")
		assert_false(text.is_empty(), "%s.glb.import exists" % glb)
		var external := text.count("\"use_external/enabled\": true")
		assert_true(external > 0, "%s maps its materials" % glb)
		for line in text.split("\n"):
			if line.begins_with("\"use_external/path\""):
				var path := line.get_slice("\"", 3)
				assert_true(ResourceLoader.exists(path), "%s: %s exists" % [glb, path])
		var root := (load(W4 + glb + ".glb") as PackedScene).instantiate() as Node3D
		for mesh: MeshInstance3D in root.find_children("*", "MeshInstance3D", true, false):
			for s in mesh.mesh.get_surface_count():
				var m := mesh.mesh.surface_get_material(s)
				assert_true(m != null and m.resource_path.begins_with("res://assets/models/graphics_pilot/realistic_map/"),
					"%s/%s surface %d uses a shared material (%s)" % [glb, mesh.name, s, m.resource_path if m != null else "none"])
		root.free()


func test_stand_steps_follow_the_slab_and_leave_headroom_underneath() -> void:
	var worst := 0.0
	for v in _vertices("stand", Vector3(0, G, 0), "Steps"):
		if v.x > 158.05 and v.x < 237.95 and v.z > STAND_Z0 + 0.05 and v.z < 227.95 and v.y > _ramp(v.z) - 0.6:
			worst = maxf(worst, absf(v.y - _ramp(v.z)))
	assert_true(worst <= 0.45, "tread tops stay within 0.45 m of the slab collision (%.3f)" % worst)
	# In the free space under the slab (from z 217.6, where a 1.75 m player fits under its 0.4 m thickness), nothing
	# but the columns (inside RoofColumn colliders) comes below 1.9 m: rakers, struts and the roof stay over head height.
	var low := 0
	for part in ["Structure", "Roof", "RoofSheet"]:
		for v in _vertices("stand", Vector3(0, G, 0), part):
			var in_column := absf(v.z - COLUMNS_Z) <= 0.28 and absf(fposmod(v.x - 158.0 + 5.0, 10.0) - 5.0) <= 0.28
			if in_column or v.x < 158.0 or v.x > 238.0 or v.z < 217.6 or v.z > 228.0:
				continue
			if v.y < G + 1.9 and v.y < _ramp(v.z) - 0.43:
				low += 1
	assert_eq(low, 0, "nothing hangs below 1.9 m in the space under the stand")


func test_seats_sit_on_treads_outside_the_aisles() -> void:
	var count := 0
	for v in _vertices("stand_seats"):
		count += 1
		for aisle: Vector2 in AISLES:
			assert_false(v.x > aisle.x + 0.01 and v.x < aisle.y - 0.01, "seat vertex %s in an aisle" % v)
		assert_true(v.x >= 158.0 and v.x <= 238.0 and v.z >= STAND_Z0 and v.z <= 228.0, "seat vertex %s on the stand" % v)
		assert_true(v.y >= _ramp(v.z) - 0.45 and v.y <= _ramp(v.z) + 1.2, "seat vertex %s on its tread" % v)
		if count > 4000:
			break


func test_poles_fences_and_pillars_stay_by_their_colliders() -> void:
	for kind in ["steel", "concrete"]:
		for v in _vertices("pole_" + kind, Vector3(112, G, 210)):
			if v.y < G + 2.4:  # within reach: the foot and the cable box stay by the 0.3 m collider
				assert_true(absf(v.x - 112.0) <= 0.36 and absf(v.z - 210.0) <= 0.36, "%s pole foot vertex %s" % [kind, v])
	# Fence runs (x = 110 and z = 212.4) and the gate leaves folded 0.14 m outside them.
	for kind in ["b40", "bars"]:
		for v in _vertices("fence_" + kind):
			var on_west := absf(v.x - 110.0) <= 0.2 and v.z >= 119.7 and v.z <= 212.5
			var on_north := absf(v.z - 212.4) <= 0.2 and v.x >= 109.9 and v.x <= 158.2
			assert_true(on_west or on_north, "%s fence vertex %s on a fence line" % [kind, v])
			assert_true(v.y <= G + 1.86, "%s fence vertex %s not taller than the gate leaves" % [kind, v])
	for v in _vertices("gate_pillars"):
		var near := false
		for post: Vector2 in [Vector2(110, 161), Vector2(110, 171), Vector2(143, 212.4), Vector2(153, 212.4)]:
			near = near or (absf(v.x - post.x) <= 0.28 and absf(v.z - post.y) <= 0.28)
		assert_true(near, "pillar vertex %s by a GatePost collider" % v)


func test_field_lies_flat_on_track_bounds() -> void:
	for v in _vertices("field"):
		assert_true(v.x >= 109.99 and v.x <= 286.01 and v.z >= 119.99 and v.z <= 212.01, "field vertex %s inside TrackBounds" % v)
		assert_true(v.y >= G - 0.001 and v.y <= G + 0.08, "field vertex %s flat on the floor" % v)
