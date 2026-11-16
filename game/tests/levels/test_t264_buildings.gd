extends TestCase
## T-264 round 2 (D-182): the buildings. Building A as a windowed wall (A2), the lecture hall with its flat roof and
## concrete louvres (R1), the gym with its corrugated vault (R2), all in the canteen's yellow, a fake room (shader) behind
## every window; building B's outside (floors 5-6 front as blocked corridors, the back, the stair towers' skin, the
## roof); chapters 1-2's light building A in the garden backdrop. Colliders, nodes, metas, anchors, zones and navigation
## are main's (md5 of main's rows taken before the patch) but for WindowSilhouette2, moved into its window (D-182 item 8);
## PS1 meshes are hidden, never removed; the three figures stand at their nodes; nothing goes deeper than 0.45 m behind
## a front (the core's occluders start 0.5 m in) and nothing under head height stands more than 0.15 m out of a collider.

const T259 := preload("res://tests/levels/test_t259_garden.gd")
const CAMPUS := preload("res://scenes/levels/campus/campus.tscn")
const SHELLS := preload("res://scenes/levels/campus/shells.tscn")
const BUILDING_B := preload("res://scenes/levels/campus/building_b.tscn")
const BACKDROP := preload("res://scenes/levels/floor4/garden_backdrop.tscn")
const MODELS := "res://assets/models/graphics_pilot/realistic_map/wave7/"
const GLBS := ["bldga", "figure", "lecture", "gym", "b_outside", "bldga_light"]
## md5 of the sorted rows of main's scenes (origin/main 0d7a25e, before patch_wave7.py).
const SHELLS_NODES_MD5 := "de6e542b7223c6ea3180e7016fe8dbdd"
const B_NODES_MD5 := "559b38455bfdcf19c668d63ddf1ccc53"
const CAMPUS_COLLIDERS_MD5 := "5f21b42e2c6bf772a38248595e1a310d"
const CAMPUS_CONTRACT_MD5 := "2d7e21aeb14371114326fc6433d81216"
const G := -9.9
const HEAD := G + 2.0
## Shell boxes (x0, x1, z0, z1), their front at z0.
const SHELL_BOXES := {"BuildingA": [0.0, 44.0, 54.0, 64.0], "Lecture": [-50.0, 30.0, 180.0, 200.0], "Gym": [-60.0, 0.0, 90.0, 130.0]}
const GLB_OF := {"BuildingA": "bldga", "Lecture": "lecture", "Gym": "gym"}

var fixture: Node3D
var campus: Node3D


func after_each() -> void:
	if is_instance_valid(fixture):
		fixture.queue_free()
		await wait_frames(3)


static func _added(path: String) -> bool:
	return path == "Real" or path.begins_with("Real/") or path.contains("/Figure")


## Every node of a scene but this wave's layers: path, class, transform (WindowSilhouette2: y and z only), body layers,
## shapes, metas. Visibility is left out (the PS1 meshes' is what changes).
static func node_rows(root: Node) -> PackedStringArray:
	var rows := PackedStringArray()
	for node in root.find_children("*", "", true, false):
		var path := String(root.get_path_to(node))
		if _added(path):
			continue
		var row := "%s|%s" % [path, node.get_class()]
		if node is Node3D:
			var xf := (node as Node3D).transform
			row += ("|%s %s" % [snappedf(xf.origin.y, 0.0001), snappedf(xf.origin.z, 0.0001)]) if path == "WindowSilhouette2" else "|" + T259._snap(xf)
		if node is CollisionObject3D:
			row += "|%d %d" % [(node as CollisionObject3D).collision_layer, (node as CollisionObject3D).collision_mask]
		if node is CollisionShape3D:
			row += "|" + T259._shape((node as CollisionShape3D).shape)
		for meta in node.get_meta_list():
			row += "|%s=%s" % [meta, node.get_meta(meta)]
		rows.append(row)
	rows.sort()
	return rows


func test_colliders_nodes_and_contract_match_main() -> void:
	var shells := SHELLS.instantiate()
	var b := BUILDING_B.instantiate()
	var campus_scene := CAMPUS.instantiate()
	var found := {
		"shells nodes, colliders": [T259.md5(node_rows(shells)), SHELLS_NODES_MD5],
		"building B nodes, colliders": [T259.md5(node_rows(b)), B_NODES_MD5],
		"campus colliders": [T259.md5(T259.collider_rows(campus_scene)), CAMPUS_COLLIDERS_MD5],
		"campus anchors, zones, navigation": [T259.md5(T259.campus_contract_rows(campus_scene)), CAMPUS_CONTRACT_MD5],
	}
	for key: String in found:
		print("T264_FINGERPRINT %s %s" % [key, found[key][0]])
		assert_eq(found[key][0], found[key][1], key + " as main has them")
	var moved := (shells.get_node("WindowSilhouette2") as Node3D).position
	assert_true(moved.x > 31.5 and moved.x < 33.5, "WindowSilhouette2 in its window (x %f)" % moved.x)
	for k in 2:
		assert_eq((shells.get_node("WindowSilhouette%d" % k) as Node3D).position, [Vector3(7, -1.9, 53.8), Vector3(18, -1.9, 53.8)][k],
			"WindowSilhouette%d where it was" % k)
	shells.free()
	b.free()
	campus_scene.free()


func _campus() -> void:
	fixture = Node3D.new()
	tree.root.add_child(fixture)
	campus = CAMPUS.instantiate() as Node3D
	fixture.add_child(campus)
	await tree.physics_frame


func test_ps1_hidden_and_the_real_layers_hung() -> void:
	await _campus()
	var shells := campus.get_node("Shells")
	for node in shells.find_children("*", "MeshInstance3D", true, false):
		var path := String(shells.get_path_to(node))
		if _added(path) or path.begins_with("LibraryBand"):
			continue
		assert_false((node as Node3D).visible, "PS1 hidden: Shells/" + path)
	for path in ["LibraryBand0/Mesh", "LibraryBand1/Mesh", "LibraryBand2/Mesh"]:
		assert_true((shells.get_node(path) as Node3D).visible, "wave 8's LibraryBand left alone: " + path)
	for name in ["BuildingA", "Lecture", "Gym"]:
		assert_true(shells.has_node("Real/" + name), "Shells/Real/" + name)
	for k in 3:
		assert_true(shells.has_node("WindowSilhouette%d/Figure" % k), "the figure at WindowSilhouette%d" % k)
	var b := campus.get_node("BuildingB")
	for path in ["UpperFloor5/Mesh", "UpperFloor6/Mesh"]:
		assert_false((b.get_node(path) as Node3D).visible, "PS1 hidden: " + path)
	for child in b.get_children():
		if String(child.name).begins_with("UpperWindow"):
			assert_false((child.get_node("Mesh") as Node3D).visible, "PS1 hidden: %s/Mesh" % child.name)
	assert_true(b.has_node("Real/Outside"), "BuildingB/Real/Outside")


func _vertices(file: String, root_xf: Transform3D = Transform3D(Basis.IDENTITY, Vector3(0, G, 0))) -> PackedVector3Array:
	var root := (load(MODELS + file + ".glb") as PackedScene).instantiate() as Node3D
	var out := PackedVector3Array()
	for mesh: MeshInstance3D in root.find_children("*", "MeshInstance3D", true, false):
		var xf := mesh.transform
		var up := mesh.get_parent() as Node3D
		while up != null and up != root:
			xf = up.transform * xf
			up = up.get_parent() as Node3D
		xf = root_xf * xf
		for s in mesh.mesh.get_surface_count():
			for v: Vector3 in mesh.mesh.surface_get_arrays(s)[Mesh.ARRAY_VERTEX]:
				out.append(xf * v)
	root.free()
	return out


func test_fronts_stay_within_0_45_m_and_nothing_in_reach_beyond_the_colliders() -> void:
	for name: String in SHELL_BOXES:
		var box: Array = SHELL_BOXES[name]
		var x0: float = box[0]
		var x1: float = box[1]
		var z0: float = box[2]
		var z1: float = box[3]
		for v: Vector3 in _vertices(GLB_OF[name]):
			var inside: bool = v.x > x0 + 0.3 and v.x < x1 - 0.3 and v.z > z0 and v.z < z1 - 1.0
			if inside:
				assert_true(v.z <= z0 + 0.451, "%s: vertex %s within 0.45 m of the front (occluder from 0.5 m)" % [name, v])
				if v.z > z0 + 0.451:
					break
			if v.y < HEAD:
				var dx := maxf(maxf(x0 - v.x, v.x - x1), 0.0)
				var dz := maxf(maxf(z0 - v.z, v.z - z1), 0.0)
				assert_true(Vector2(dx, dz).length() <= 0.151, "%s: vertex %s under head height within 0.15 m of the collider" % [name, v])
				if Vector2(dx, dz).length() > 0.151:
					break
	for v: Vector3 in _vertices("b_outside"):
		assert_false(v.z > -7.5 and v.z < 0.0 and v.x > 0.2 and v.x < 43.8, "building B: vertex %s inside the occluded block (z < 0)" % v)
		if v.y < HEAD:
			var dx := maxf(maxf(-5.16 - v.x, v.x - 49.16), 0.0)
			var dz := maxf(maxf(-7.7 - v.z, v.z - 4.2), 0.0)
			assert_true(Vector2(dx, dz).length() <= 0.151, "building B: vertex %s under head height within 0.15 m of its walls" % v)
			if Vector2(dx, dz).length() > 0.151:
				break


func test_three_figures_stand_in_their_windows() -> void:
	await _campus()
	for k in 3:
		var node := campus.get_node("Shells/WindowSilhouette%d" % k) as Node3D
		var lo := Vector3(INF, INF, INF)
		var hi := -lo
		for mesh: MeshInstance3D in node.get_node("Figure").find_children("*", "MeshInstance3D", true, false):
			var aabb := mesh.global_transform * mesh.get_aabb()
			lo = lo.min(aabb.position)
			hi = hi.max(aabb.end)
		var p := node.global_position
		assert_true(lo.x < p.x and hi.x > p.x and lo.y < p.y and hi.y > p.y, "figure %d spans its node %s (%s..%s)" % [k, p, lo, hi])
		assert_true(lo.z >= 54.0 and hi.z <= 54.45, "figure %d behind the front, within 0.45 m (%s..%s)" % [k, lo, hi])
		var window_x: float = [7.5, 17.5, 32.5][k]
		assert_true(absf(p.x - window_x) <= 1.0, "figure %d inside the window at x %f" % [k, window_x])


func test_light_building_a_in_chapters_one_and_two() -> void:
	var backdrop := BACKDROP.instantiate() as Node3D
	tree.root.add_child(backdrop)
	await wait_frames(1)
	assert_true(backdrop.has_node("BuildingA"), "the light building A in the garden backdrop")
	for mesh: MeshInstance3D in backdrop.get_node("BuildingA").find_children("*", "MeshInstance3D", true, false):
		assert_eq(mesh.cast_shadow, GeometryInstance3D.SHADOW_CASTING_SETTING_OFF, "no shadow: " + mesh.name)
		for s in mesh.mesh.get_surface_count():
			var name := mesh.mesh.surface_get_material(s).resource_name
			assert_false(name.begins_with("W7Room"), "no fake room in chapters 1-2 (%s)" % name)
			assert_true(name != "W7Palette" or mesh.name != "Figure", "no figure")
	assert_eq(backdrop.find_children("*", "CollisionObject3D", true, false).size(), 0, "no collision")
	assert_eq(backdrop.find_children("*", "Light3D", true, false).size(), 0, "no light")
	backdrop.free()


func _walk(player: CharacterBody3D, points: Array) -> void:
	player.global_position = (points[0] as Vector3) + Vector3(0, 0.05, 0)
	for frame in 4:
		await tree.physics_frame
	for target: Vector3 in points.slice(1):
		var reached := false
		for frame in 240 + int(player.global_position.distance_to(target) / 4.0 * 90.0):
			await tree.physics_frame
			var offset := target - player.global_position
			offset.y = 0.0
			if offset.length() < 0.3:
				reached = true
				break
			var d := offset.normalized()
			player.velocity = Vector3(d.x * 4.0, 0.0 if player.is_on_floor() else player.velocity.y - 9.8 / 60.0, d.z * 4.0)
			player.move_and_slide()
		assert_true(reached, "reached %s (feet %s)" % [target, player.global_position])
		if not reached:
			return


func test_player_walks_round_the_three_buildings() -> void:
	await _campus()
	var player := (load("res://scenes/player/player.tscn") as PackedScene).instantiate() as CharacterBody3D
	fixture.add_child(player)
	player.set_physics_process(false)
	player.set_process_input(false)
	player.set_process_unhandled_input(false)
	for name: String in SHELL_BOXES:
		var b: Array = SHELL_BOXES[name]
		var x0: float = b[0] - 0.7
		var x1: float = b[1] + 0.7
		var z0: float = b[2] - 0.7
		var z1: float = b[3] + 0.7
		await _walk(player, [Vector3(x0, G, z0), Vector3(x1, G, z0), Vector3(x1, G, z1), Vector3(x0, G, z1), Vector3(x0, G, z0)])


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
	print("T264_BUILDING_TRIANGLES %d" % triangles)
	assert_true(triangles < 75000, "wave 7's buildings within budget (%d triangles)" % triangles)
