extends TestCase
## T-262 round 2 (D-180): the realistic gate (gate.tscn Real: C2 court, P1 pillars, G1 gate, SA sign with text, K1
## booth and its interior, the outside strip), the whole south wall (campus.tscn WallSouth, W1) and the A16 gate strip
## (StripGate: lawn, paved walk, the Avenue's end, cars, barricades, cones, dropped things, papers, rubble). Colliders,
## nodes, anchors, zones and navigation are main's (md5 of main's rows, _probe_tmp copies of origin/main f19bf4b); PS1
## meshes are hidden, never removed; nothing new stands on the sightlines from Start_gate and the road to the twelve
## guards; the new pieces stay inside the PS1 colliders or out of reach; the player still walks the companions' way.

const T259 := preload("res://tests/levels/test_t259_garden.gd")
const T264 := preload("res://tests/levels/test_t264_rest.gd")
const GATE := preload("res://scenes/levels/campus/gate.tscn")
const CAMPUS := preload("res://scenes/levels/campus/campus.tscn")
const PROPS := preload("res://scenes/levels/campus/props.tscn")
const MODELS := "res://assets/models/graphics_pilot/realistic_map/wave5/"
const TEXTURES := "res://assets/textures/graphics_pilot/realistic_map/wave5/"
const GLBS := ["court", "outside", "court_cracks", "pillars_plaster", "gate_swing", "sign_arch", "booth_masonry", "booth_interior",
	"wall_south", "strip_gate", "strip_gate_props"]
## md5 of the sorted rows of main's scenes; this wave changes none of them.
const GATE_NODES_MD5 := "26c58f4a871429596e0983396fa728a1"  # 145 rows
const CAMPUS_COLLIDERS_MD5 := "1e0dd9426510b21e245fbf2b84ee80c2"  # 1072 colliders: 957 and T-265's 115 in Library/Real/Added
const CAMPUS_CONTRACT_MD5 := "2d7e21aeb14371114326fc6433d81216"  # as T-259 and T-261 left it
const PROPS_COLLIDERS_MD5 := "97c2301b5e5f2375e59ef5ecf322a76b"  # as T-259 left it
const G := -9.9
const A16_BOX := AABB(Vector3(180, -10.5, -60), Vector3(82, 4.5, 73))
const T263_BOX := AABB(Vector3(166, -10.5, 13), Vector3(52, 4.5, 47))  # T-263's canteen strip (round 2, D-181)
const GUARD_EYES := [Vector3(220, -8.3, -25), Vector3(220, -8.3, -15), Vector3(205, -8.3, -16), Vector3(235, -8.3, -30)]
const PS1_HIDDEN := ["Court/Mesh", "Pillar209/Mesh", "Pillar231/Mesh", "Booth/Mesh", "HalfFallenSign", "BoothWindow", "BoothRoof",
	"PillarCrack", "GateCross0.5", "GateCross3.4", "RoadCrack212", "RoadCrack222", "RoadCrack233"]
## props.tscn chunks this wave touches (patch_gate.py, w5_ps1_props.json): every instance zeroed in them lies in the box.
const CHUNKS := ["Decals/D_iron_quad_p2_m1", "Decals/D_iron_quad_p2_p0", "Decals/D_iron_quad_p3_m1", "Decals/D_paper_quad_p2_m1",
	"Decals/D_paper_quad_p2_p0", "Decals/D_paper_quad_p3_m1", "Decals/D_white_quad_p2_m1", "Decals/D_white_quad_p2_p0",
	"Decals/D_white_quad_p3_m1", "Parts/P_concrete_box_p5_m1", "Parts/P_iron_box_p4_m1", "Parts/P_iron_box_p5_m1", "Parts/P_iron_box_p5_m2",
	"Parts/P_iron_cylinder_p4_m1", "Parts/P_iron_cylinder_p5_m1", "Parts/P_paper_box_p4_m1", "Parts/P_paper_box_p5_m1",
	"Parts/P_white_box_p4_m1", "Parts/P_white_box_p4_p0", "Parts/P_white_box_p5_m1", "Parts/P_white_box_p5_m2", "Parts/P_white_box_p5_p0",
	"Parts/P_white_box_p6_m2", "Parts/P_white_cone_p5_m2"]
## The corpse heads T-259/T-261 had hidden as litter (D-180): given back.
const HEADS := [["Parts/P_paper_box_p1_p0", 0], ["Parts/P_paper_box_p2_p2", 1], ["Parts/P_paper_box_p2_p4", 1]]

var fixture: Node3D
var campus: Node3D
var player: CharacterBody3D


func after_each() -> void:
	if is_instance_valid(fixture):
		fixture.queue_free()
		await wait_frames(3)


func _campus() -> void:
	fixture = Node3D.new()
	tree.root.add_child(fixture)
	campus = CAMPUS.instantiate() as Node3D
	fixture.add_child(campus)
	await tree.physics_frame
	await tree.physics_frame


# ---------------------------------------------------------------------------------------------- fingerprints

## Every node of gate.tscn but this wave's layer (Real): path, class, transform, body layers, metas, shapes. Visibility
## is left out (the PS1 meshes' is what changes).
static func gate_rows(gate: Node) -> PackedStringArray:
	var rows := PackedStringArray()
	for node in gate.find_children("*", "", true, false):
		var path := String(gate.get_path_to(node))
		if path == "Real" or path.begins_with("Real/"):
			continue
		var row := "%s|%s" % [path, node.get_class()]
		if node is Node3D:
			row += "|" + T259._snap((node as Node3D).transform)
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
	var gate := GATE.instantiate()
	var campus_scene := CAMPUS.instantiate()
	var props := PROPS.instantiate()
	var found := {
		"gate nodes, colliders": [T259.md5(gate_rows(gate)), GATE_NODES_MD5],
		"campus colliders (Fence/S, ground, gate, booth...)": [T259.md5(T259.collider_rows(campus_scene)), CAMPUS_COLLIDERS_MD5],
		"campus anchors, zones, navigation": [T259.md5(T259.campus_contract_rows(campus_scene)), CAMPUS_CONTRACT_MD5],
		"props colliders": [T259.md5(T259.collider_rows(props)), PROPS_COLLIDERS_MD5],
	}
	for key: String in found:
		print("T262_FINGERPRINT %s %s" % [key, found[key][0]])
		assert_eq(found[key][0], found[key][1], key + " as main has them")
	gate.free()
	campus_scene.free()
	props.free()


# ---------------------------------------------------------------------------------------------- layers

func test_ps1_meshes_hidden_and_the_real_layers_hung() -> void:
	await _campus()
	var gate := campus.get_node("Gate")
	for path: String in PS1_HIDDEN:
		assert_false((gate.get_node(path) as Node3D).visible, "PS1 hidden: " + path)
	for child in gate.get_children():
		var name := String(child.name)
		if name.begins_with("GateBar") or name.begins_with("SignScar"):
			assert_false((child as Node3D).visible, "PS1 hidden: " + name)
	for name in ["Court", "Outside", "Cracks", "Pillars", "Gate", "Sign", "Booth", "Interior"]:
		assert_true(gate.has_node("Real/" + name), "Real/" + name)
	assert_false((campus.get_node("Fence/S/Mesh") as Node3D).visible, "PS1 south wall hidden (its collider stays)")
	var avenue := campus.get_node("Road/Avenue/Mesh") as MeshInstance3D
	# T-264 round 3 (D-182) lays the Avenue x 0..180 in asphalt and hides this mesh (test_t264_rest checks it).
	assert_true(avenue.visible or campus.has_node("StripRest/Ground"), "the Avenue's PS1 mesh stays shown up to x 180")
	var aabb := avenue.global_transform * avenue.get_aabb()
	assert_true(absf(aabb.position.x) < 0.01 and absf(aabb.end.x - 180.0) < 0.01, "Road/Avenue's mesh spans x 0..180 (%s)" % aabb)
	for path in ["WallSouth/Wall", "StripGate/Ground", "StripGate/Props"]:
		assert_true(campus.has_node(path), path)
	# Draw distances set by gate_real.gd once loaded.
	var interior := gate.get_node("Real/Interior").find_children("*", "MeshInstance3D", true, false)[0] as MeshInstance3D
	assert_eq(interior.visibility_range_end, 30.0, "booth interior drawn within 30 m")
	var near := 0
	var far := 0
	for mesh: MeshInstance3D in campus.get_node("WallSouth").find_children("*", "MeshInstance3D", true, false):
		if String(mesh.name).begins_with("BarsNear"):
			near += 1
			assert_eq(mesh.visibility_range_end, 45.0, mesh.name + " near")
		elif String(mesh.name).begins_with("BarsFar"):
			far += 1
			assert_eq(mesh.visibility_range_begin, 45.0, mesh.name + " far")
	assert_true(near >= 16 and near == far, "the wall's chunks have near bars and far cards (%d, %d)" % [near, far])


func test_props_replaced_in_the_box_only_and_three_heads_back() -> void:
	var props := PROPS.instantiate()
	var zeroed := 0
	var canteen := 0
	for path: String in CHUNKS:
		var data: PackedFloat32Array = props.get_node(path).get("data")
		for k in range(0, data.size(), 16):
			if data[k] == 0.0 and data[k + 4] == 0.0 and data[k + 8] == 0.0:
				var at := Vector3(data[k + 9], data[k + 10], data[k + 11])
				if A16_BOX.grow(0.01).has_point(at):
					zeroed += 1
					continue
				# T-264 round 3 (D-182): the rest of A16's pieces in the shared chunks (test_t264_rest checks them).
				if T264.in_rest(at):
					continue
				# T-263 round 2 (D-181, HARU allowed this edit): three of these chunks also hold the canteen strip's
				# papers, sandals and a backpack, scaled to 0 in T-263's box (x 166..218, z 13..60); test_t263_canteen
				# checks them.
				assert_true(T263_BOX.grow(0.01).has_point(at), "%s: only pieces in the gate's or the canteen's box hidden (%s)" % [path, at])
				canteen += 1
	assert_eq(zeroed, 180, "cars, barricades, cones, papers, dropped things and the rubble scaled to 0")
	assert_eq(canteen, 16, "T-263's papers, sandals and backpack in the shared chunks")
	for head: Array in HEADS:
		var data: PackedFloat32Array = props.get_node(head[0]).get("data")
		var k: int = head[1] * 16
		var scale := Vector3(data[k], data[k + 1], data[k + 2]).length()
		assert_true(absf(scale - 0.22) < 0.001, "%s #%d: the head is back (%f)" % [head[0], head[1], scale])
		assert_eq(Color(data[k + 12], data[k + 13], data[k + 14]).to_html(false), Color(0.9, 0.7, 0.6).to_html(false), "skin tint")
	props.free()


func test_strip_stays_in_its_box() -> void:
	await _campus()
	var meshes := campus.get_node("StripGate").find_children("*", "MeshInstance3D", true, false)
	assert_true(meshes.size() >= 8, "lawn, walk, kerbs, cars, furniture, props, litter, rubble, rods (%d)" % meshes.size())
	for mesh: MeshInstance3D in meshes:
		var aabb := mesh.global_transform * mesh.get_aabb()
		assert_true(A16_BOX.grow(0.3).encloses(aabb), "%s inside the A16 box (%s)" % [mesh.name, aabb])


# ---------------------------------------------------------------------------------------------- contract

func _world_vertices(root: Node3D) -> PackedVector3Array:
	var out := PackedVector3Array()
	for mesh: MeshInstance3D in root.find_children("*", "MeshInstance3D", true, false):
		for s in mesh.mesh.get_surface_count():
			for v: Vector3 in mesh.mesh.surface_get_arrays(s)[Mesh.ARRAY_VERTEX]:
				out.append(mesh.global_transform * v)
	return out


func test_new_pieces_stay_in_the_ps1_colliders_or_out_of_reach() -> void:
	await _campus()
	var real := campus.get_node("Gate/Real")
	for v in _world_vertices(real.get_node("Gate")):
		assert_true(v.x >= 209.7 and v.x <= 230.3 and v.z >= -59.09 and v.z <= -58.91 and v.y <= G + 4.0, "gate vertex %s in Gate/Gate" % v)
	var tilt := Basis(Vector3(0, 0, 1), deg_to_rad(7.0))
	for v in _world_vertices(real.get_node("Pillars")):
		var west := v.x < 220.0
		var p: Vector3 = (tilt.inverse() * (v - Vector3(209, -6.9, -59))) if west else (v - Vector3(231, -6.9, -59))
		assert_true(absf(p.x) <= 0.701 and absf(p.z) <= 0.701 and p.y <= 3.0 and p.y >= -3.31, "pillar vertex %s in its collider" % v)
	for name in ["Booth", "Interior"]:
		for v in _world_vertices(real.get_node(name)):
			var inside := v.x >= 237.499 and v.x <= 242.501 and v.z >= -56.001 and v.z <= -51.999
			assert_true(inside or v.y >= G + 2.85, "%s vertex %s in the Booth collider or roof height" % [name, v])
	for v in _world_vertices(real.get_node("Sign")):
		assert_true(v.y >= G + 2.3 or (v.z >= -59.09 and v.z <= -58.91), "sign vertex %s low down in the gate's 0.18 m" % v)
	for v in _world_vertices(real.get_node("Outside")):
		assert_true(v.z <= -60.149, "outside vertex %s beyond the wall" % v)
	for v in _world_vertices(campus.get_node("WallSouth")):
		assert_true(v.z >= -60.151 and v.z <= -59.849 and v.y <= G + 3.001 and v.x >= -80.001 and v.x <= 420.001
			and (v.x <= 208.31 or v.x >= 231.69), "wall vertex %s inside Fence/S" % v)
	# Cars inside their PS1 colliders (4.4 x 1.5 x 1.9 m, turned as the PS1 cars), barricades in theirs (2.2 x 1.0 x 0.5 m).
	var boxes: Array = []
	for car: Array in [[208.0, -37.0, 62.0], [238.5, -33.5, 100.0], [236.0, -26.0, 10.0], [227.13, -20.63, 170.76], [187.62, -6.28, 76.7]]:
		boxes.append([Transform3D(Basis(Vector3.UP, deg_to_rad(car[2])), Vector3(car[0], 0, car[1])), Vector3(2.2, 1.5, 0.95)])
	var cars := campus.get_node("StripGate/Props").find_children("Cars", "MeshInstance3D", true, false)[0] as MeshInstance3D
	var outside := PackedVector3Array()
	for s in cars.mesh.get_surface_count():
		for v: Vector3 in cars.mesh.surface_get_arrays(s)[Mesh.ARRAY_VERTEX]:
			var w := cars.global_transform * v
			var inside := false
			for box: Array in boxes:
				var local: Vector3 = (box[0] as Transform3D).affine_inverse() * Vector3(w.x, 0, w.z)
				var half: Vector3 = box[1]
				inside = inside or (absf(local.x) <= half.x + 0.001 and absf(local.z) <= half.z + 0.001 and w.y - G <= half.y + 0.001)
			if not inside:
				outside.append(w)
	assert_eq(outside.size(), 0, "car vertices inside the cars' colliders (%s)" % outside.slice(0, 4))


func test_sightlines_to_the_twelve_guards_stay_clear() -> void:
	await _campus()
	var tris := PackedVector3Array()
	for root: Node in [campus.get_node("Gate/Real"), campus.get_node("StripGate"), campus.get_node("WallSouth")]:
		for mesh: MeshInstance3D in root.find_children("*", "MeshInstance3D", true, false):
			var aabb := mesh.global_transform * mesh.get_aabb()
			if aabb.end.z < -60.2 or aabb.position.z > -14.0 or aabb.position.x > 236.0 or aabb.end.x < 204.0:
				continue
			for v: Vector3 in mesh.mesh.get_faces():
				tris.append(mesh.global_transform * v)
	var blocked: Array[String] = []
	for eye: Vector3 in GUARD_EYES:
		for guard in campus.get_node("Anchors/GuardLine").get_children():
			var chest := (guard as Node3D).global_position + Vector3(0, 1.3, 0)
			for t in range(0, tris.size(), 3):
				if Geometry3D.segment_intersects_triangle(eye, chest, tris[t], tris[t + 1], tris[t + 2]) != null:
					blocked.append("%s from %s" % [guard.name, eye])
					break
	assert_true(tris.size() > 0, "pieces near the line checked")
	assert_eq(blocked.size(), 0, "nothing new between an eye and a guard's chest (%s)" % [blocked])


func _walk_to(target: Vector3, label: String) -> bool:
	var frames := 240 + int(player.global_position.distance_to(target) / 4.0 * 60.0 * 1.5)
	for frame in frames:
		await tree.physics_frame
		var offset := target - player.global_position
		offset.y = 0.0
		if offset.length() < 0.3:
			return true
		var d := offset.normalized()
		player.velocity.x = d.x * 4.0
		player.velocity.z = d.z * 4.0
		player.velocity.y = 0.0 if player.is_on_floor() else player.velocity.y - 9.8 / 60.0
		player.move_and_slide()
	assert_true(false, "%s unreachable; feet %s" % [label, player.global_position])
	return false


func test_real_player_walks_to_the_guards_edge_and_on_to_the_canteen() -> void:
	await _campus()
	player = (load("res://scenes/player/player.tscn") as PackedScene).instantiate() as CharacterBody3D
	fixture.add_child(player)
	player.set_physics_process(false)
	player.set_process_input(false)
	player.set_process_unhandled_input(false)
	var start: Vector3 = (campus.get_node("Anchors/Start_gate") as Node3D).global_position
	player.global_position = start + Vector3(0, 0.05, 0)
	for frame in 4:
		await tree.physics_frame
	if not await _walk_to(Vector3(220, G, -41.5), "12 m from the nearest guard"):
		return
	if not await _walk_to(start, "back to Start_gate"):
		return
	for name in ["P28", "P29", "P30_Wait_canteen"]:
		var at: Vector3 = (campus.get_node("Anchors/Paths/Nhat/" + name) as Node3D).global_position
		if not await _walk_to(at, name):
			return


# ---------------------------------------------------------------------------------------------- assets

func test_every_wave5_texture_imports_vram_compressed() -> void:
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
	assert_eq(count, 11, "wave 5 textures found")


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
	print("T262_TRIANGLES %d" % triangles)
	assert_true(triangles < 60000, "wave 5's layers within budget (%d triangles)" % triangles)
