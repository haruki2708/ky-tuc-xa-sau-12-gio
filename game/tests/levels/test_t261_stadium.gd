extends TestCase
## T-261 (D-178): realistic graphics wave 4. The stadium (A13: R1 red rubber track, C1 worn grass, both stands in bare
## concrete S1, the main stand's sheet roof on steel trusses with three sheets gone, L1 steel floodlight poles, H1
## chain-link fences, whitewashed gate pillars, what lay in the stadium) and the garden-to-stadium strip (A16).
## All visual: colliders, nodes, lights, anchors, zones and navigation match main (fingerprints below were taken from
## main's scenes), PS1 meshes are hidden, never removed; nothing new hangs where the player walks under the stands.

const T259 := preload("res://tests/levels/test_t259_garden.gd")
const CAMPUS := preload("res://scenes/levels/campus/campus.tscn")
const STADIUM := preload("res://scenes/levels/campus/stadium.tscn")
const PROPS := preload("res://scenes/levels/campus/props.tscn")
const MODELS := "res://assets/models/graphics_pilot/realistic_map/wave4/"
const TEXTURES := "res://assets/textures/graphics_pilot/realistic_map/wave4/"
const GLBS := ["field.glb", "goal.glb", "stand.glb", "stand_south.glb", "pole_steel.glb", "fence_b40.glb", "gate_pillars.glb",
	"stadium_props.glb", "strip_garden_stadium.glb", "strip_stadium_props.glb"]
## md5 of the sorted rows of main's scenes (_probe_tmp copies of origin/main 072b7bb); this wave changes none of them.
const STADIUM_COLLIDERS_MD5 := "30bb677dad7fc54fd7a081d4939663d5"  # 53 colliders
const STADIUM_NODES_MD5 := "be790db1b0a517705d29328f409e7e52"  # 257 nodes
const CAMPUS_CONTRACT_MD5 := "2d7e21aeb14371114326fc6433d81216"  # as T-259 left it
const PROPS_COLLIDERS_MD5 := "97c2301b5e5f2375e59ef5ecf322a76b"  # as T-259 left it
## T-262 (D-180): 2124 = main's 2303 kept instances less the 180 the gate strip replaces (scaled to 0, outside this
## wave's areas) plus the corpse head given back at (43.6, 30.2) (outside this wave's A16 box, so a kept row again).
const PROPS_KEPT_MD5 := "e5d7b9ea958504f13e0b836c200facbe"  # 2124 instances kept
const G := -9.9
const STAND_Z0 := 212.7
const SOUTH_Z0 := 119.5
const COLUMNS_Z := 228.9
const REAL_TRIANGLE_BUDGET := 36000
## Replaced props.tscn instances (stadium_layout.PROP_KINDS / a16_kind): texture, kind, scale rounded to 1 cm.
const STADIUM_KINDS := [["white", "box", Vector3(0.04, 0.84, 0.04)], ["white", "box", Vector3(1.2, 0.07, 0.05)],
	["white", "box", Vector3(0.75, 0.32, 0.3)], ["white", "box", Vector3(0.32, 0.42, 0.2)], ["white", "box", Vector3(0.26, 0.2, 0.06)],
	["white", "box", Vector3(0.26, 0.1, 0.1)], ["white", "box", Vector3(0.42, 0.03, 0.3)], ["paper", "box", Vector3(0.34, 0.01, 0.16)],
	["white", "box", Vector3(0.8, 0.6, 0.8)], ["paper", "quad", Vector3(0.18, 1.0, 0.26)], ["white", "quad", Vector3(0.11, 1.0, 0.27)],
	["white", "quad", Vector3(0.07, 1.0, 0.15)], ["iron", "quad", Vector3(0.01, 1.0, 0.17)]]
const STADIUM_AREA := Rect2(108, 108, 182, 128)  # x 108..290, z 108..236
const A16_BOX := AABB(Vector3(50, -10.5, -11), Vector3(60, 4.5, 187))
const A16_RUBBLE := [Vector3(86.95, 1.6, 151.44), Vector3(99.2, 1.5, 173.5)]  # (x, radius, z)
const HIDE_WHOLE := ["Decals/D_paper_quad_p0_p0"]

var scene: Node3D


func after_each() -> void:
	if is_instance_valid(scene):
		scene.queue_free()
		await wait_frames(3)


# ---------------------------------------------------------------------------------------------- fingerprints

## Every node of stadium.tscn but this wave's layer (Real): path, class, transform, body layers and metas; lights also
## their energy, colour, range and shadow; Floodlights its visibility (the PS1 meshes' visibility is what changes).
static func stadium_rows(stadium: Node) -> PackedStringArray:
	var rows := PackedStringArray()
	for node in stadium.find_children("*", "", true, false):
		var path := String(stadium.get_path_to(node))
		if path == "Real" or path.begins_with("Real/"):
			continue
		var row := "%s|%s" % [path, node.get_class()]
		if node is Node3D:
			row += "|" + T259._snap((node as Node3D).transform)
		if node is CollisionObject3D:
			row += "|%d %d" % [(node as CollisionObject3D).collision_layer, (node as CollisionObject3D).collision_mask]
		for meta in node.get_meta_list():
			row += "|%s=%s" % [meta, node.get_meta(meta)]
		if node is OmniLight3D:
			var light := node as OmniLight3D
			row += "|%s %s %s %s %s" % [snappedf(light.light_energy, 0.0001), light.light_color, light.omni_range, light.shadow_enabled, light.visible]
		if path == "Floodlights":
			row += "|visible %s" % (node as Node3D).visible
		rows.append(row)
	rows.sort()
	return rows


static func _stadium_kind(chunk: String, values: PackedFloat32Array, k: int) -> bool:
	var parts := chunk.split("_")
	var scale := Vector3(Vector3(values[k], values[k + 1], values[k + 2]).length(), Vector3(values[k + 3], values[k + 4], values[k + 5]).length(),
		Vector3(values[k + 6], values[k + 7], values[k + 8]).length())
	for sig: Array in STADIUM_KINDS:
		var d := (scale - (sig[2] as Vector3)).abs()
		if sig[0] == parts[1] and sig[1] == parts[2] and d.x < 0.005 and d.y < 0.005 and d.z < 0.005:
			return true
	return false


## True if this props.tscn instance is one this wave replaces (stadium_layout.prop_kind / a16_kind).
static func replaced(chunk: String, values: PackedFloat32Array, k: int) -> bool:
	var at := Vector3(values[k + 9], values[k + 10], values[k + 11])
	if at.x >= 108.0 and at.x <= 290.0 and at.z >= 108.0 and at.z <= 236.0 and _stadium_kind(chunk, values, k):
		return true
	if not A16_BOX.has_point(at):
		return false
	var near := false
	for r: Vector3 in A16_RUBBLE:
		near = near or Vector2(at.x - r.x, at.z - r.z).length() <= r.y
	var biggest := maxf(Vector3(values[k], values[k + 1], values[k + 2]).length(), maxf(Vector3(values[k + 3], values[k + 4], values[k + 5]).length(),
		Vector3(values[k + 6], values[k + 7], values[k + 8]).length()))
	if (chunk.begins_with("P_paper") or chunk.begins_with("D_paper")) and at.y < -9.7:
		return true
	if near and chunk.begins_with("P_concrete_box") and biggest < 1.0:
		return true
	if near and chunk.begins_with("P_iron_cylinder") and absf(Vector3(values[k + 3], values[k + 4], values[k + 5]).length() - 1.1) < 0.05:
		return true
	return false


## props.tscn's instances this wave keeps (bodies, blood, cracks and drag marks, bins, everything outside), whole, with
## each chunk's visibility. Zeroed instances (T-259's, this wave's) and the replaced ones are left out, so main's and
## this wave's rows are the same unless a kept instance changed or vanished.
static func props_kept_rows(props: Node) -> PackedStringArray:
	var rows := PackedStringArray()
	for branch in ["Parts", "Decals"]:
		for chunk in props.get_node(branch).get_children():
			var path := "%s/%s" % [branch, chunk.name]
			var values: PackedFloat32Array = chunk.get("data")
			if path in HIDE_WHOLE:
				continue
			rows.append("%s|visible %s" % [path, (chunk as Node3D).visible])
			for k in range(0, values.size(), 16):
				var zero := values[k] == 0.0 and values[k + 4] == 0.0 and values[k + 8] == 0.0
				if zero or replaced(String(chunk.name), values, k):
					continue
				rows.append("%s|%d|%s" % [path, k / 16, str(values.slice(k, k + 16))])
	return rows


func test_colliders_nodes_lights_and_contract_match_main() -> void:
	var stadium := STADIUM.instantiate()
	var campus := CAMPUS.instantiate()
	var props := PROPS.instantiate()
	var found := {
		"stadium colliders": [T259.md5(T259.collider_rows(stadium)), STADIUM_COLLIDERS_MD5],
		"stadium nodes, lights": [T259.md5(stadium_rows(stadium)), STADIUM_NODES_MD5],
		"campus anchors, zones, navigation": [T259.md5(T259.campus_contract_rows(campus)), CAMPUS_CONTRACT_MD5],
		"props colliders": [T259.md5(T259.collider_rows(props)), PROPS_COLLIDERS_MD5],
	}
	for key: String in found:
		print("T261_FINGERPRINT %s %s" % [key, found[key][0]])
		assert_eq(found[key][0], found[key][1], key + " as main has them")
	stadium.free()
	campus.free()
	props.free()


func test_props_keep_bodies_blood_cracks_and_everything_outside() -> void:
	var props := PROPS.instantiate()
	var rows := props_kept_rows(props)
	print("T261_PROPS_KEPT %d rows %s" % [rows.size(), T259.md5(rows)])
	assert_eq(T259.md5(rows), PROPS_KEPT_MD5, "props this wave does not replace are as main has them")
	# Each replaced instance is scaled to 0, entry kept; the chunk shared with T-259's strip is hidden whole.
	var zeroed := 0
	for branch in ["Parts", "Decals"]:
		for chunk in props.get_node(branch).get_children():
			var values: PackedFloat32Array = chunk.get("data")
			for k in range(0, values.size(), 16):
				if values[k] == 0.0 and values[k + 4] == 0.0 and values[k + 8] == 0.0:
					zeroed += 1
	# T-262 (D-180): 371, the two corpse heads this wave had hidden as litter (P_paper_box_p2_p2 #1, P_paper_box_p2_p4 #1)
	# are back; later waves zero more instances elsewhere, so the count only has a floor.
	assert_true(zeroed >= 371, "replaced PS1 instances scaled to 0 (%d)" % zeroed)
	for path: String in HIDE_WHOLE:
		assert_false((props.get_node(path) as Node3D).visible, "hidden whole: " + path)
	for path in ["Decals/D_red_quad_p2_p2", "Decals/D_iron_quad_p2_p2", "Decals/D_white_quad_p2_p2"]:
		assert_true((props.get_node(path) as Node3D).visible, "left alone: " + path)
	props.free()


# ---------------------------------------------------------------------------------------------- the stadium

func _campus() -> void:
	scene = CAMPUS.instantiate()
	tree.root.add_child(scene)
	await tree.physics_frame
	await tree.physics_frame


func test_ps1_meshes_hidden_and_the_real_layer_hung() -> void:
	await _campus()
	var stadium := scene.get_node("Stadium")
	for path in ["Grass/Mesh", "MainBleachers/FrontWall0/Mesh", "MainBleachers/RearParapet/Mesh", "SecondaryBleachers/EndWest/Mesh",
			"GatePost110_166_-5/Mesh", "Pole2/Mesh", "RunningSurface", "Lane3", "PitchLine198", "GoalPost-1_162.34", "FloodHousing2_1",
			"Stand_concrete_box_p4_p5", "Stand_iron_box_p3_p5", "Stand_blue_box_p4_p2"]:
		assert_false((stadium.get_node(path) as Node3D).is_visible_in_tree(), "PS1 hidden: " + path)
	var real := stadium.get_node("Real")
	for path in ["Field", "MainStand", "SouthStand", "Fences", "Pillars", "Props", "Goals/Goal0", "Goals/Goal1"]:
		assert_true(real.has_node(path), "realistic layer: " + path)
	for i in 4:
		var pole := real.get_node("Poles/Pole%d" % i) as Node3D
		var ps1 := stadium.get_node("Pole%d" % i) as Node3D
		assert_true(Vector2(pole.global_position.x - ps1.global_position.x, pole.global_position.z - ps1.global_position.z).length() < 0.01,
			"pole %d stands on its collider" % i)
		# The lamps face the pitch centre.
		var aim := pole.global_transform.basis.x
		var to_centre := (Vector3(198, 0, 166) - Vector3(ps1.global_position.x, 0, ps1.global_position.z)).normalized()
		assert_true(Vector2(aim.x, aim.z).normalized().dot(Vector2(to_centre.x, to_centre.z)) > 0.99, "pole %d lamps face the pitch (%s, %s)" % [i, aim, to_centre])
	assert_eq((real.get_node("Goals/Goal0") as Node3D).global_position, Vector3(150, G, 166))
	assert_eq((real.get_node("Goals/Goal1") as Node3D).global_position, Vector3(246, G, 166))
	var triangles := 0
	var meshes := 0
	for mesh: MeshInstance3D in real.find_children("*", "MeshInstance3D", true, false):
		triangles += mesh.mesh.get_faces().size() / 3
		meshes += 1
	print("T261_REAL: %d triangles, %d meshes" % [triangles, meshes])
	assert_true(triangles <= REAL_TRIANGLE_BUDGET, "realistic stadium within its budget (%d)" % triangles)
	assert_true(meshes <= 60, "realistic stadium in few meshes (%d)" % meshes)


func test_lamp_glass_glows_only_with_the_floodlights() -> void:
	await _campus()
	var real := scene.get_node("Stadium/Real")
	var glow: StandardMaterial3D = real.get("glow")
	assert_not_null(glow, "lamp glass material shared")
	assert_false((scene.get_node("Stadium/Floodlights") as Node3D).visible, "floodlights off before the stadium")
	assert_eq(glow.emission_energy_multiplier, 0.0, "glass dark while off")
	scene.call("set_stadium_lights", true)
	assert_true(glow.emission_energy_multiplier > 1.0, "glass bright with the floodlights")
	scene.call("set_stadium_lights", false)
	assert_eq(glow.emission_energy_multiplier, 0.0, "glass dark again")
	var lit := 0
	for mesh: MeshInstance3D in real.get_node("Poles").find_children("*", "MeshInstance3D", true, false):
		for surface in mesh.mesh.get_surface_count():
			if mesh.get_surface_override_material(surface) == glow:
				lit += 1
	assert_eq(lit, 4, "the four poles' lamp glass shares the switched material")
	for i in 4:
		var light := scene.get_node("Stadium/Floodlights/Light%d" % i) as OmniLight3D
		assert_eq(light.light_energy, 12.0)
		assert_false(light.shadow_enabled)


## A standing player at `at` (on a 24 degree slope the capsule's foot sphere needs ~3 cm more than on flat ground).
func _capsule_clear(at: Vector3) -> bool:
	var capsule := CapsuleShape3D.new()
	capsule.radius = 0.3
	capsule.height = 1.75
	var query := PhysicsShapeQueryParameters3D.new()
	query.shape = capsule
	query.transform.origin = at + Vector3(0, 0.875 + 0.06, 0)
	query.collision_mask = 1
	return scene.get_world_3d().direct_space_state.intersect_shape(query).is_empty()


## The floor under (x, z), looked for from `from_y` down (under the stand: from just over the ground).
func _floor(x: float, z: float, from_y: float = 5.0) -> float:
	var hit := scene.get_world_3d().direct_space_state.intersect_ray(PhysicsRayQueryParameters3D.create(Vector3(x, from_y, z), Vector3(x, G - 1, z), 1))
	return hit.position.y if not hit.is_empty() else G


func test_capsule_walks_into_the_pitch_up_the_stand_and_under_it() -> void:
	await _campus()
	var routes := {
		"Start_stadium into the pitch": [Vector3(115, 0, 166), Vector3(150, 0, 166), Vector3(198, 0, 166)],
		"track to the top row": [Vector3(173, 0, 205), Vector3(173, 0, 214), Vector3(173, 0, 221), Vector3(173, 0, 227.3)],
		"round the north-west gate to B03": [Vector3(148, 0, 204), Vector3(148, 0, 216), Vector3(148, 0, 231), Vector3(166, 0, 231),
			Vector3(166, 0, 226.4), Vector3(164, 0, 224.6)],
		"to B02": [Vector3(148, 0, 216), Vector3(150, 0, 221), Vector3(153.2, 0, 221)],
	}
	for label: String in routes:
		var points: Array = routes[label]
		for i in range(points.size() - 1):
			for step in 9:
				var p: Vector3 = (points[i] as Vector3).lerp(points[i + 1], step / 8.0)
				p.y = _floor(p.x, p.z, 5.0 if label == "track to the top row" else G + 1.0)
				assert_true(_capsule_clear(p), "%s: clear at %s" % [label, p])


## Heights of the realistic layer's triangles over the point (x, z).
func _heights(root: Node, x: float, z: float) -> PackedFloat32Array:
	var out := PackedFloat32Array()
	var p := Vector2(x, z)
	var meshes := root.find_children("*", "MeshInstance3D", true, false)
	if root is MeshInstance3D:
		meshes.append(root)
	for mesh: MeshInstance3D in meshes:
		var xf := mesh.global_transform
		var aabb := xf * mesh.get_aabb()
		if x < aabb.position.x or x > aabb.end.x or z < aabb.position.z or z > aabb.end.z:
			continue
		var faces := mesh.mesh.get_faces()
		for i in range(0, faces.size(), 3):
			var a := xf * faces[i]
			var b := xf * faces[i + 1]
			var c := xf * faces[i + 2]
			var bary := Geometry2D.point_is_inside_triangle(p, Vector2(a.x, a.z), Vector2(b.x, b.z), Vector2(c.x, c.z))
			if not bary:
				continue
			var plane := Plane(a, b, c)
			if absf(plane.normal.y) < 1e-4:
				continue
			out.append((plane.d - plane.normal.x * x - plane.normal.z * z) / plane.normal.y)
	return out


func test_bars_b02_and_b03_lie_on_the_new_ground_with_headroom() -> void:
	await _campus()
	var real := scene.get_node("Stadium/Real")
	for key in ["BarSpawns/B02", "BarSpawns/B03"]:
		var bar: Vector3 = scene.call("get_anchor", key).global_position
		var ground := -INF
		for y in _heights(real.get_node("MainStand/Ground"), bar.x, bar.z):
			ground = maxf(ground, y)
		# The core settles bars on the collision floor (G); the new ground lies 4 mm over it.
		assert_true(absf(ground - G) < 0.02 and ground <= bar.y + 0.01, "%s: new ground at %.3f under the bar at %.3f" % [key, ground, bar.y])
		for y in _heights(real, bar.x, bar.z):
			assert_false(y > bar.y + 0.12 and y < bar.y + 2.2, "%s: nothing new over the bar below 2.2 m (%.3f)" % [key, y])


# ---------------------------------------------------------------------------------------------- the assets

func _vertices(glb: String, only: String = "") -> PackedVector3Array:
	var root := (load(MODELS + glb) as PackedScene).instantiate() as Node3D
	var out := PackedVector3Array()
	for mesh: MeshInstance3D in root.find_children("*", "MeshInstance3D", true, false):
		if not only.is_empty() and String(mesh.name) != only:
			continue
		var xf := Transform3D(Basis.IDENTITY, Vector3(0, G, 0))
		var n: Node = mesh
		var local := Transform3D.IDENTITY
		while n != null and n != root:
			local = (n as Node3D).transform * local
			n = n.get_parent()
		for v in mesh.mesh.get_faces():
			out.append(xf * local * v)
	root.free()
	return out


func _main_ramp(z: float) -> float:
	return G + maxf(0.0, (z - STAND_Z0) * (6.84 / 15.3))


func _south_ramp(z: float) -> float:
	return G + maxf(0.0, (SOUTH_Z0 - z) * (2.8 / 6.3))


func test_stands_follow_their_slabs_and_leave_headroom_underneath() -> void:
	var worst := 0.0
	for v in _vertices("stand.glb", "Steps"):
		if v.x > 158.05 and v.x < 237.95 and v.z > STAND_Z0 + 0.05 and v.z < 227.95 and v.y > _main_ramp(v.z) - 0.6:
			worst = maxf(worst, absf(v.y - _main_ramp(v.z)))
	for v in _vertices("stand_south.glb", "Steps"):
		if v.x > 168.05 and v.x < 227.95 and v.z < SOUTH_Z0 - 0.05 and v.z > 113.25 and v.y > _south_ramp(v.z) - 0.6:
			worst = maxf(worst, absf(v.y - _south_ramp(v.z)))
	assert_true(worst <= 0.45, "tread tops within 0.45 m of the slab collisions (%.3f)" % worst)
	var low := 0
	for part in ["Structure", "Roof", "RoofSheet"]:
		for v in _vertices("stand.glb", part):
			var in_column := absf(v.z - COLUMNS_Z) <= 0.28 and absf(fposmod(v.x - 158.0 + 5.0, 10.0) - 5.0) <= 0.28
			if in_column or v.x < 158.0 or v.x > 238.0 or v.z < 217.6 or v.z > 228.0:
				continue
			if v.y < G + 1.9 and v.y < _main_ramp(v.z) - 0.43:
				low += 1
	for v in _vertices("stand_south.glb", "Structure"):
		if v.y < G + 1.9 and v.y < _south_ramp(v.z) - 0.43 and v.z < 115.5:
			low += 1
	assert_eq(low, 0, "nothing hangs below 1.9 m in the space under the stands")


func test_poles_fences_and_pillars_stay_by_their_colliders() -> void:
	# Within reach (2.4 m) only the foot and the cable box, by the 0.3 m collider (the glb's origin is the foot).
	var root := (load(MODELS + "pole_steel.glb") as PackedScene).instantiate() as Node3D
	for mesh: MeshInstance3D in root.find_children("*", "MeshInstance3D", true, false):
		for v in mesh.mesh.get_faces():
			if v.y < 2.4:
				assert_true(Vector2(v.x, v.z).length() <= 0.4, "pole foot vertex %s" % v)
	root.free()
	var lines := []
	for x in [110.0, 286.0]:
		lines.append([Vector2(x, 119.8), Vector2(x, 212.4)])
	for z in [119.8, 212.4]:
		lines.append([Vector2(110, z), Vector2(286, z)])
	for v in _vertices("fence_b40.glb"):
		var on := false
		for line: Array in lines:
			var a: Vector2 = line[0]
			var b: Vector2 = line[1]
			var p := Vector2(v.x, v.z)
			var t := clampf((p - a).dot(b - a) / (b - a).length_squared(), 0.0, 1.0)
			on = on or p.distance_to(a.lerp(b, t)) <= 0.2
		assert_true(on, "fence vertex %s on a fence line" % v)
		assert_true(v.y <= G + 1.86, "fence vertex %s no taller than the gate leaves" % v)
	var posts := []
	for x in [143.0, 153.0, 243.0, 253.0]:
		for z in [119.8, 212.4]:
			posts.append(Vector2(x, z))
	for x in [110.0, 286.0]:
		for z in [161.0, 171.0]:
			posts.append(Vector2(x, z))
	for v in _vertices("gate_pillars.glb"):
		var near := false
		for post: Vector2 in posts:
			near = near or (absf(v.x - post.x) <= 0.28 and absf(v.z - post.y) <= 0.28)
		assert_true(near, "pillar vertex %s by a GatePost collider" % v)


func test_field_and_props_lie_inside_the_stadium() -> void:
	for v in _vertices("field.glb"):
		assert_true(v.x >= 109.99 and v.x <= 286.01 and v.z >= 119.99 and v.z <= 212.01 and v.y >= G - 0.001 and v.y <= G + 0.08,
			"field vertex %s flat on TrackBounds" % v)
	var outside := PackedVector3Array()
	for v in _vertices("stadium_props.glb"):
		if not STADIUM_AREA.grow(1.0).has_point(Vector2(v.x, v.z)) or v.y < G - 0.12:
			outside.append(v)
	assert_eq(outside.size(), 0, "stadium props inside the stadium, on or over the floor (%s)" % outside.slice(0, 4))


func test_strip_stays_in_its_box_and_hides_only_its_pieces() -> void:
	await _campus()
	var strip := scene.get_node("StripGardenStadium")
	var meshes := strip.find_children("*", "MeshInstance3D", true, false)
	assert_true(meshes.size() >= 6, "ground, road, kerbs, litter, rubble, pipes")
	for mesh: MeshInstance3D in meshes:
		var aabb := mesh.global_transform * mesh.get_aabb()
		# Litter cards (up to 0.42 m) are centred where the PS1 pieces lay inside the box.
		assert_true(A16_BOX.grow(0.25).encloses(aabb), "%s inside the A16 box (%s)" % [mesh.name, aabb])
	for path in ["Road/WestBranch/Mesh", "Road/StadiumWestAccess/Mesh"]:
		assert_false((scene.get_node(path) as Node3D).visible, "PS1 hidden: " + path)
	for path in ["Road/Avenue/Mesh", "Road/EastBranch/Mesh"]:
		assert_true((scene.get_node(path) as Node3D).visible, "left alone: " + path)


func test_every_wave4_texture_imports_vram_compressed() -> void:
	var count := 0
	for file in DirAccess.get_files_at(TEXTURES):
		if not file.ends_with(".png"):
			continue
		count += 1
		var config := ConfigFile.new()
		assert_eq(config.load(TEXTURES + file + ".import"), OK, file + " has import settings")
		assert_eq(config.get_value("params", "compress/mode"), 2, file + " VRAM compressed")
		assert_eq(config.get_value("params", "compress/normal_map"), 1 if file.ends_with("_normal.png") else 0, file + " normal-map flag")
		var meta: Dictionary = config.get_value("remap", "metadata", {})
		assert_true(meta.get("vram_texture", false), file + " imported as a VRAM texture")
	assert_eq(count, 11, "wave 4 textures found")


func test_glbs_use_only_shared_materials() -> void:
	for file: String in GLBS:
		var glb := (load(MODELS + file) as PackedScene).instantiate() as Node3D
		for mesh: MeshInstance3D in glb.find_children("*", "MeshInstance3D", true, false):
			for surface in mesh.mesh.get_surface_count():
				var material := mesh.mesh.surface_get_material(surface)
				assert_not_null(material, "%s %s surface %d" % [file, mesh.name, surface])
				if material != null:
					var path := material.resource_path
					assert_true(path.contains("/realistic_map/wave1/materials/W1") or path.contains("/realistic_map/wave3/materials/W3")
						or path.contains("/realistic_map/wave4/materials/W4"), "%s %s uses a shared material (%s)" % [file, mesh.name, path])
		glb.free()
