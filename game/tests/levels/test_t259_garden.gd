extends TestCase
## T-259 (D-175): realistic graphics wave 3. The garden (A12: 8 plumeria and 4 crape myrtle, F1 beds, whitewashed
## kerbs, grey "con sâu" pavers, terrazzo benches, globe lamps, the toppled bunk), the B-to-garden strip (A16: lawn,
## paving curb, gutter, litter, rubble, notice board) and chapters 1-2's light copy seen from floor 4 (A05).
## All visual: colliders, nodes, anchors, zones, navigation and lights match main (fingerprints below were taken from
## main's scenes), PS1 meshes are hidden, never removed, foliage lower than 2 m stays inside T-251's CanopyCollision.

const TEXTURES := "res://assets/textures/graphics_pilot/realistic_map/wave3/"
const MODELS := "res://assets/models/graphics_pilot/realistic_map/wave3/"
const GARDEN := preload("res://scenes/levels/campus/garden.tscn")
const CAMPUS := preload("res://scenes/levels/campus/campus.tscn")
const PROPS := preload("res://scenes/levels/campus/props.tscn")
const TREE_GLBS := ["tree_plumeria_a.glb", "tree_plumeria_b.glb", "tree_plumeria_c.glb", "tree_lagerstroemia_a.glb",
	"tree_lagerstroemia_b.glb"]
const GLBS := TREE_GLBS + ["garden_beds.glb", "garden_planting.glb", "paving_block.glb", "bench_ngu.glb", "bench_back.glb",
	"garden_lamp.glb", "fallen_bunk.glb", "garden_backdrop.glb", "strip_b_garden.glb", "strip_props.glb"]
## md5 of the sorted rows of main's scenes (see _rows); this wave changes none of them.
const GARDEN_COLLIDERS_MD5 := "6e3434f62c26463ec94584e191da9971"  # 32 colliders
const GARDEN_NODES_MD5 := "a8a0156fbc047dcc88984730980eaecf"  # 524 nodes
const CAMPUS_CONTRACT_MD5 := "2d7e21aeb14371114326fc6433d81216"  # 1079 rows
const PROPS_COLLIDERS_MD5 := "97c2301b5e5f2375e59ef5ecf322a76b"  # 175 colliders
const PAVING_Y := -9.9
const FREE_HEIGHT := 2.0
const TRUNK_RADIUS := 0.13
## PS1 chunks of props.tscn this wave replaces (wave3/garden_layout.py A16_HIDE).
const A16_ALL := ["Parts/P_paper_box_p0_p0", "Parts/P_paper_box_p0_p1", "Decals/D_paper_quad_m1_p0", "Parts/P_iron_box_p0_p0",
	"Parts/P_wood_box_p0_p0"]
const A16_PARTLY := ["Parts/P_paper_box_p1_p0", "Decals/D_paper_quad_p0_p0", "Parts/P_concrete_box_p0_p1", "Parts/P_iron_cylinder_p0_p1"]

var scene: Node3D


func after_each() -> void:
	if is_instance_valid(scene):
		scene.queue_free()
		await wait_frames(3)
	Chapter1Director.resume_checkpoint = &""
	Checkpoint.clear()
	GameState.reset()
	RuleSystem.reset()


# ---------------------------------------------------------------------------------------------- fingerprints

static func _xf(node: Node, root: Node) -> Transform3D:
	var xf := Transform3D.IDENTITY
	var at := node
	while at != root and at != null:
		if at is Node3D:
			xf = (at as Node3D).transform * xf
		at = at.get_parent()
	return xf


static func _snap(xf: Transform3D) -> String:
	var b := xf.basis
	return "%s %s %s %s" % [b.x.snapped(Vector3.ONE * 0.0001), b.y.snapped(Vector3.ONE * 0.0001), b.z.snapped(Vector3.ONE * 0.0001),
		xf.origin.snapped(Vector3.ONE * 0.0001)]


static func _shape(shape: Shape3D) -> String:
	if shape is BoxShape3D:
		return str((shape as BoxShape3D).size.snapped(Vector3.ONE * 0.0001))
	if shape is ConvexPolygonShape3D:
		return str(Array((shape as ConvexPolygonShape3D).points).hash())
	if shape is ConcavePolygonShape3D:
		return str(Array((shape as ConcavePolygonShape3D).get_faces()).hash())
	if shape is CapsuleShape3D:
		return "%s %s" % [(shape as CapsuleShape3D).radius, (shape as CapsuleShape3D).height]
	if shape is CylinderShape3D:
		return "%s %s" % [(shape as CylinderShape3D).radius, (shape as CylinderShape3D).height]
	if shape is SphereShape3D:
		return str((shape as SphereShape3D).radius)
	return "null" if shape == null else shape.get_class()


static func collider_rows(root: Node) -> PackedStringArray:
	var rows := PackedStringArray()
	for node in root.find_children("*", "CollisionShape3D", true, false):
		var cs := node as CollisionShape3D
		var body := cs.get_parent() as CollisionObject3D
		rows.append("%s|%s|%s|%s|%d|%d|%s" % [root.get_path_to(cs), cs.shape.get_class() if cs.shape else "null", _snap(_xf(cs, root)),
			_shape(cs.shape), body.collision_layer if body else -1, body.collision_mask if body else -1, cs.disabled])
	rows.sort()
	return rows


## Every node of garden.tscn but this wave's layer (Real) and what scripts add at run time: path, class, transform;
## lights also their energy, colour, range, shadow, script and phase.
static func garden_node_rows(garden: Node) -> PackedStringArray:
	var rows := PackedStringArray()
	for node in garden.find_children("*", "", true, false):
		var path := String(garden.get_path_to(node))
		if path == "Real" or path.begins_with("Real/"):
			continue
		var row := "%s|%s" % [path, node.get_class()]
		if node is Node3D:
			row += "|" + _snap((node as Node3D).transform)
		if node is OmniLight3D:
			var light := node as OmniLight3D
			row += "|%s %s %s %s %s %s" % [snappedf(light.light_energy, 0.0001), light.light_color, light.omni_range, light.shadow_enabled,
				light.get_script().resource_path if light.get_script() else "", light.get("phase")]
		if node.has_method("get") and node.get("points") != null:
			row += "|" + str(node.get("points"))
		rows.append(row)
	rows.sort()
	return rows


## campus.tscn's gameplay contract round the garden: anchors, zones, navigation (card section 4).
static func campus_contract_rows(campus: Node) -> PackedStringArray:
	var rows := PackedStringArray()
	for branch in ["Anchors", "Zones", "Navigation"]:
		var root := campus.get_node(branch)
		for node in root.find_children("*", "", true, false):
			var row := "%s/%s|%s" % [branch, root.get_path_to(node), node.get_class()]
			if node is Node3D:
				row += "|" + _snap((node as Node3D).transform)
			if node is NavigationRegion3D:
				var mesh := (node as NavigationRegion3D).navigation_mesh
				# Built-in meshes' paths carry the scene's file name, so compare their content.
				var ref := mesh.resource_path if mesh and not mesh.resource_path.contains("::") else ""
				row += "|%s %d %d" % [ref, mesh.get_polygon_count() if mesh else -1, Array(mesh.get_vertices()).hash() if mesh else 0]
			if node is NavigationLink3D:
				var link := node as NavigationLink3D
				row += "|%s %s %s" % [link.start_position, link.end_position, link.enabled]
			if node is CollisionShape3D:
				row += "|" + _shape((node as CollisionShape3D).shape)
			rows.append(row)
	rows.sort()
	return rows


static func md5(rows: PackedStringArray) -> String:
	return "\n".join(rows).md5_text()


func test_colliders_nodes_anchors_and_lights_match_main() -> void:
	var garden := GARDEN.instantiate()
	var campus := CAMPUS.instantiate()
	var props := PROPS.instantiate()
	var found := {
		"garden colliders": [md5(collider_rows(garden)), GARDEN_COLLIDERS_MD5],
		"garden nodes, lights": [md5(garden_node_rows(garden)), GARDEN_NODES_MD5],
		"campus anchors, zones, navigation": [md5(campus_contract_rows(campus)), CAMPUS_CONTRACT_MD5],
		"props colliders": [md5(collider_rows(props)), PROPS_COLLIDERS_MD5],
	}
	for key: String in found:
		print("T259_FINGERPRINT %s %s" % [key, found[key][0]])
		assert_eq(found[key][0], found[key][1], key + " as main has them")
	garden.free()
	campus.free()
	props.free()


# ---------------------------------------------------------------------------------------------- the garden

func _campus() -> void:
	scene = CAMPUS.instantiate()
	tree.root.add_child(scene)
	await tree.physics_frame
	await tree.physics_frame


func test_ps1_meshes_hidden_and_the_real_layer_hung() -> void:
	await _campus()
	var garden := scene.get_node("Garden") as Node3D
	var hidden := ["Paving/Mesh", "NguBench/Mesh", "NguBenchLeg21.15", "NguBenchLeg22.85", "BrokenBunk"]
	for i in 4:
		for j in 3:
			hidden += ["Bed%d_%d/Mesh" % [i, j], "Bed%d_%d/Soil" % [i, j], "LowTrunk%d_%d" % [i, j], "LowCrown%d_%d" % [i, j]]
			for k in 4:
				hidden.append("Bush%d_%d_%d" % [i, j, k])
				for m in 3:
					hidden.append("Flower%d_%d_%d_%d" % [i, j, k, m])
	for b in 4:
		hidden += ["Bench%d" % b, "DetachedRail%d" % b]
	for path: String in hidden:
		assert_false((garden.get_node(path) as Node3D).is_visible_in_tree(), "PS1 hidden: " + path)
	var trees := garden.get_node("Real/Trees").get_children()
	assert_eq(trees.size(), 12, "a tree in every bed")
	var plumeria := 0
	for tree_node: Node in trees:
		var file := tree_node.scene_file_path.get_file()
		plumeria += 1 if file.begins_with("tree_plumeria_") else 0
		var bed := garden.get_node("Bed" + String(tree_node.name).trim_prefix("Tree")) as Node3D
		var at := (tree_node as Node3D).global_position
		assert_true(Vector2(at.x - bed.global_position.x, at.z - bed.global_position.z).length() < 0.001, "%s at its bed's centre" % tree_node.name)
		assert_true(absf(at.y - PAVING_Y) < 0.001, "%s on the paving level" % tree_node.name)
	assert_eq(plumeria, 8, "D-175: 8 plumeria, 4 crape myrtle")
	assert_eq(garden.get_node("Real/Benches").get_child_count(), 5, "Ngư's bench and Bench0-3")
	for b in 4:
		var bench := garden.get_node("Real/Benches/Bench%d" % b) as Node3D
		assert_true(bench.global_position.distance_to((garden.get_node("Bench%d" % b) as Node3D).global_position) < 0.001, "Bench%d in place" % b)
	var lamps := 0
	for node: Node in garden.find_children("GardenLights_*", "Node3D", false, false):
		for child: Node in node.get_children():
			if child is MultiMeshInstance3D:
				assert_false((child as MultiMeshInstance3D).visible, "PS1 lamp post hidden")
			elif String(child.name).begins_with("RealLamp"):
				lamps += 1
	assert_eq(lamps, 6, "a globe lamp on every old lamp point")
	for mesh: MeshInstance3D in garden.get_node("Real").find_children("*", "MeshInstance3D", true, false):
		if String(mesh.name) in ["Leaves", "LeavesFar", "Planting"]:
			assert_eq(mesh.cast_shadow, GeometryInstance3D.SHADOW_CASTING_SETTING_OFF, "no leaf shadow: " + String(mesh.get_path()))


func test_lamp_globes_glow_with_their_flicker_light() -> void:
	await _campus()
	var garden := scene.get_node("Garden")
	var light := garden.get_node("Flicker1") as OmniLight3D
	light.set_process(false)
	light.light_energy = 0.35
	await tree.process_frame
	var globe: MeshInstance3D = null
	for lamp: Node in garden.get_node("GardenLights_0_0").get_children():
		if String(lamp.name).begins_with("RealLamp") and absf((lamp as Node3D).position.z - light.position.z) < 0.01:
			globe = lamp.find_child("Globe", true, false) as MeshInstance3D
	assert_not_null(globe, "lamp under Flicker1")
	if globe == null:
		return
	var material := globe.get_surface_override_material(0) as StandardMaterial3D
	var lit := material.emission_energy_multiplier
	light.light_energy = 0.015
	await tree.process_frame
	assert_true(lit > 0.5, "globe glows while its light is on")
	assert_true(material.emission_energy_multiplier < lit * 0.1, "globe dims with its light")


func test_placed_trees_keep_low_foliage_inside_their_canopy_block() -> void:
	await _campus()
	var garden := scene.get_node("Garden")
	for tree_node: Node3D in garden.get_node("Real/Trees").get_children():
		var key := String(tree_node.name).trim_prefix("Tree")
		var crown := garden.get_node("LowCrown" + key) as Node3D
		var shape := (garden.get_node("LowCrown%s/CanopyCollision/Shape" % key) as CollisionShape3D).shape as ConvexPolygonShape3D
		var bottom := INF
		var top := -INF
		var r_bottom := 0.0
		var r_top := 0.0
		for p: Vector3 in shape.points:
			bottom = minf(bottom, p.y)
			top = maxf(top, p.y)
		for p: Vector3 in shape.points:
			if is_equal_approx(p.y, bottom):
				r_bottom = maxf(r_bottom, Vector2(p.x, p.z).length())
			else:
				r_top = maxf(r_top, Vector2(p.x, p.z).length())
		var to_crown := crown.global_transform.affine_inverse()
		var bad := 0
		for mesh: MeshInstance3D in tree_node.find_children("*", "MeshInstance3D", true, false):
			for surface in mesh.mesh.get_surface_count():
				for v: Vector3 in mesh.mesh.surface_get_arrays(surface)[Mesh.ARRAY_VERTEX]:
					var world := mesh.global_transform * v
					if world.y - PAVING_Y >= FREE_HEIGHT:
						continue
					var p := to_crown * world
					if p.y < bottom:
						if Vector2(p.x, p.z).length() > TRUNK_RADIUS:
							bad += 1
						continue
					# Octagonal frustum (corners at 0°, 45°...): every edge's outward normal at 22.5° + k * 45°.
					var r := lerpf(r_bottom, r_top, (p.y - bottom) / (top - bottom)) * cos(PI / 8.0)
					for k in 8:
						var a := PI / 8.0 + k * PI / 4.0
						if p.x * cos(a) + p.z * sin(a) > r + 0.001:
							bad += 1
							break
		assert_eq(bad, 0, "%s: vertices under 2 m outside LowCrown%s's block" % [tree_node.name, key])


func _capsule_clear(state: PhysicsDirectSpaceState3D, a: Vector3, b: Vector3) -> String:
	var capsule := CapsuleShape3D.new()
	capsule.radius = 0.3
	capsule.height = 1.75
	var query := PhysicsShapeQueryParameters3D.new()
	query.shape = capsule
	query.collision_mask = 1
	var steps := ceili(a.distance_to(b) / 0.25)
	for step in range(steps + 1):
		query.transform.origin = a.lerp(b, float(step) / steps) + Vector3(0, 0.875 + 0.05, 0)
		for hit in state.intersect_shape(query, 4):
			return "%s at %s" % [hit.collider.get_path(), query.transform.origin]
	return ""


func test_capsule_walks_the_aisles_to_ngu_and_to_the_bar() -> void:
	await _campus()
	var state := scene.get_world_3d().direct_space_state
	var y := PAVING_Y
	var routes := [
		[Vector3(1.5, y, 17), Vector3(42.5, y, 17)], [Vector3(1.5, y, 27), Vector3(42.5, y, 27)],
		[Vector3(9.45, y, 37), Vector3(42.5, y, 37)], [Vector3(14, y, 8.5), Vector3(14, y, 47.5)],
		[Vector3(30, y, 12), Vector3(30, y, 47.5)],
		[(scene.get_node("Anchors/Start_garden") as Node3D).global_position, Vector3(14, y, 8.5)],
		[Vector3(14, y, 27), Vector3(22, y, 27.2)], [Vector3(14, y, 37), Vector3(9.45, y, 37)],
	]
	for route: Array in routes:
		var blocked := _capsule_clear(state, route[0], route[1])
		assert_eq(blocked, "", "clear from %s to %s" % [route[0], route[1]])


func test_bar_b01_rests_on_the_toppled_bunk() -> void:
	await _campus()
	var state := scene.get_world_3d().direct_space_state
	var b01 := scene.get_node("Anchors/BarSpawns/B01") as Node3D
	var hit := state.intersect_ray(PhysicsRayQueryParameters3D.create(b01.global_position + Vector3(0, 2, 0), b01.global_position - Vector3(0, 0.3, 0), 1))
	assert_false(hit.is_empty(), "bar finds a surface")
	if hit.is_empty():
		return
	var rest: float = (hit.position as Vector3).y
	assert_true(absf(rest - (-8.95)) < 0.02, "the old bunk collider's top (%s)" % rest)
	# The new bunk's upper guard rail runs under the bar at that height.
	var frame := scene.get_node("Garden/Real/FallenBunk").find_child("Frame", true, false) as MeshInstance3D
	var best := -INF
	for v: Vector3 in frame.mesh.surface_get_arrays(0)[Mesh.ARRAY_VERTEX]:
		var w := frame.global_transform * v
		if absf(w.x - b01.global_position.x) < 0.1 and absf(w.z - b01.global_position.z) < 1.0:
			best = maxf(best, w.y)
	assert_true(absf(best - rest) < 0.02, "guard rail top %s under the bar" % best)
	assert_true(scene.get_node("Garden/FallenBunk/Collision") != null, "FallenBunk collider kept")


func test_ngu_bench_sits_on_the_ps1_seat() -> void:
	var garden := GARDEN.instantiate() as Node3D
	var seat := garden.get_node("NguBench") as Node3D
	var box := ((garden.get_node("NguBench/Collision") as CollisionShape3D).shape as BoxShape3D).size
	var seat_top := seat.position.y + box.y / 2.0
	var bench := garden.get_node("Real/Benches/NguBench") as Node3D
	var mesh := bench.find_children("*", "MeshInstance3D", true, false)[0] as MeshInstance3D
	var aabb := _xf(mesh, garden) * mesh.get_aabb()
	garden.free()
	assert_true(absf(aabb.end.y - seat_top) < 0.005, "bench top at the PS1 seat top (Ngư's anchor)")
	assert_true(absf(aabb.position.y - PAVING_Y) < 0.005, "bench stands on the paving")
	assert_true(aabb.size.x <= box.x + 0.001 and aabb.size.z <= box.z + 0.001, "bench inside the seat's footprint")


# ---------------------------------------------------------------------------------------------- strip, assets

func test_strip_layer_stays_in_the_a16_strip_and_hides_what_it_replaces() -> void:
	await _campus()
	var strip := scene.get_node("StripBGarden") as Node3D
	var meshes := strip.find_children("*", "MeshInstance3D", true, false)
	assert_true(meshes.size() >= 7, "lawn, curb, gutter, litter, rubble, pipes, notice board")
	# Card section 3: x -6..50, z 4..50, y -10.5..-6; the three rubble piles straddle z 50 and are replaced whole, as
	# far as their PS1 pieces went (colliders Body_p0_p1/S0-S2 reach z 53).
	var box := AABB(Vector3(-6.01, -10.5, 4.0), Vector3(56.02, 4.5, 49.5))
	for mesh: MeshInstance3D in meshes:
		var aabb := mesh.global_transform * mesh.get_aabb()
		assert_true(box.encloses(aabb), "%s inside the strip (%s)" % [mesh.name, aabb])
	var props := scene.get_node("Props")
	for path: String in A16_ALL:
		assert_false((props.get_node(path) as Node3D).visible, "PS1 hidden: " + path)
	for path: String in A16_PARTLY:
		var data: PackedFloat32Array = props.get_node(path).get("data")
		var zeroed := 0
		for k in range(0, data.size(), 16):
			if data[k] == 0.0 and data[k + 4] == 0.0 and data[k + 8] == 0.0:
				zeroed += 1
				var at := Vector3(data[k + 9], data[k + 10], data[k + 11])
				assert_true(at.x > -6.5 and at.x < 50.5 and at.z > 4.0 and at.z < 53.5, "%s: only strip pieces hidden (%s)" % [path, at])
		assert_true(zeroed > 0, path + " pieces in the strip hidden")
	for path in ["Parts/P_white_box_p0_p0", "Decals/D_red_quad_p0_p0", "Decals/D_iron_quad_p0_p0"]:
		assert_true((props.get_node(path) as Node3D).visible, "left alone (corpses, drag marks): " + path)


func test_every_wave3_texture_imports_vram_compressed() -> void:
	var count := 0
	for file in DirAccess.get_files_at(TEXTURES):
		if not file.ends_with(".png"):
			continue
		count += 1
		var config := ConfigFile.new()
		assert_eq(config.load(TEXTURES + file + ".import"), OK, file + " has import settings")
		assert_eq(config.get_value("params", "compress/mode"), 2, file + " VRAM compressed")
		assert_eq(config.get_value("params", "compress/normal_map"), 1 if file.ends_with("_normal.png") else 0, file + " normal-map flag")
		assert_true(config.get_value("params", "mipmaps/generate"), file + " has mipmaps")
		var meta: Dictionary = config.get_value("remap", "metadata", {})
		assert_true(meta.get("vram_texture", false), file + " imported as a VRAM texture")
	assert_true(count >= 22, "wave 3 textures found (%d)" % count)


func test_glbs_use_only_shared_materials() -> void:
	for file: String in GLBS:
		var glb := (load(MODELS + file) as PackedScene).instantiate() as Node3D
		for mesh: MeshInstance3D in glb.find_children("*", "MeshInstance3D", true, false):
			for surface in mesh.mesh.get_surface_count():
				var material := mesh.mesh.surface_get_material(surface)
				assert_not_null(material, "%s %s surface %d" % [file, mesh.name, surface])
				if material != null:
					var path := material.resource_path
					assert_true(path.contains("/realistic_map/wave1/materials/W1") or path.contains("/realistic_map/wave2/materials/W2")
						or path.contains("/realistic_map/wave3/materials/W3"), "%s %s uses a shared material (%s)" % [file, mesh.name, path])
		glb.free()


# ---------------------------------------------------------------------------------------------- chapters 1-2 copy

func _chapter(number: int) -> void:
	scene = load("res://scenes/main/chapter%d.tscn" % number).instantiate()
	var director := scene.get_node("Chapter%dDirector" % number)
	director.set("auto_start", false)
	Chapter1Director.resume_checkpoint = &""
	tree.root.add_child(scene)
	await wait_frames(3)


func test_light_copy_only_in_chapters_one_and_two() -> void:
	for number in range(1, 5):
		await _chapter(number)
		var corridor := scene.get_node("Floor4/Corridor")
		var backdrop := corridor.get_node("GardenBackdrop") as Node3D
		assert_eq(backdrop.is_visible_in_tree(), number <= 2, "chapter %d: light copy" % number)
		for k in 4:
			assert_false((corridor.get_node("YardTree_%d" % k) as Node3D).is_visible_in_tree(), "chapter %d: YardTree_%d hidden" % [number, k])
		var lamp := corridor.get_node("DistantStreetLamp") as OmniLight3D
		assert_eq(lamp.is_visible_in_tree(), number <= 2, "chapter %d: distant street light as before" % number)
		assert_true(is_equal_approx(lamp.light_energy, 0.5), "light energy unchanged")
		for part in ["Fixture", "Stem"]:
			assert_false((lamp.get_node(part) as Node3D).is_visible_in_tree(), "chapter %d: old %s hidden" % [number, part])
		if number <= 2:
			for mesh: MeshInstance3D in backdrop.find_children("*", "MeshInstance3D", true, false):
				assert_eq(mesh.cast_shadow, GeometryInstance3D.SHADOW_CASTING_SETTING_OFF, "light copy casts no shadow")
			assert_eq(backdrop.find_children("*", "CollisionObject3D", true, false).size(), 0, "light copy has no collision")
			assert_eq(backdrop.find_children("*", "Light3D", true, false).size(), 0, "light copy adds no light")
		scene.queue_free()
		await wait_frames(3)
