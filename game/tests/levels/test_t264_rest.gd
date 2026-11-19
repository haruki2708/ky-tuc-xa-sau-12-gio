extends TestCase
## T-264 round 3 (D-182): the rest of the campus ground. campus.tscn StripRest (rest_real.gd: Ground, Fences, Props glbs;
## the real trees and street lights as MultiMeshes on the PS1 clusters' points); props.tscn's replaced instances scaled
## to 0; the PS1 tiles under the new ground, the roads, Fence/N|E|W, the benches and fallen mopeds hidden, never removed;
## the floor-4 balconies' outside in building B's new back colour. Colliders, anchors, zones and navigation as main has
## them; the seen road and paving within 2 cm of the tiles' collider (-9.94); no leaf below 2 m outside a trunk's box;
## the fences inside their colliders; corpse pieces, blood and drag marks untouched; every wave-7 texture VRAM compressed.

const T259 := preload("res://tests/levels/test_t259_garden.gd")
const CAMPUS := preload("res://scenes/levels/campus/campus.tscn")
const PROPS := preload("res://scenes/levels/campus/props.tscn")
const REST := preload("res://scenes/levels/campus/rest_real.gd")
const MODELS := "res://assets/models/graphics_pilot/realistic_map/wave7/"
const TEXTURES := "res://assets/textures/graphics_pilot/realistic_map/wave7/"
const CAMPUS_COLLIDERS_MD5 := "5f21b42e2c6bf772a38248595e1a310d"   # as test_t262_gate / test_t263_canteen have it
const CAMPUS_CONTRACT_MD5 := "2d7e21aeb14371114326fc6433d81216"    # as T-259, T-261, T-262, T-263 left it
const G := -9.9
const COLLIDER_TOP := -9.94
## Main's props.tscn: drag marks and cracks (D_iron), blood (D_red) and skin-tinted pieces (heads) still drawn.
const KEPT := {"D_iron": 661, "D_red": 60, "skin": 30}
const TILES_HIDDEN := 37
## The library and 6 m round it (wave 8): its tiles keep their PS1 mesh.
const WAVE8 := [39.0, 91.0, 189.0, 231.0]

## The rest of A16 (wave7_layout.region == "rest"): the campus less wave 8, the buildings' boxes and the earlier strips
## (T-263's box less its west corner x 166..170, z 37..60). Every instance this wave scaled to 0 lies here; the earlier
## waves' tests ask it before calling a zeroed piece theirs.
const NOT_REST := [[39.0, 91.0, 189.0, 231.0], [-5.2, 49.2, -10.8, 4.3], [0.0, 44.0, 54.0, 64.0], [-50.0, 30.0, 180.0, 200.0],
	[-60.0, 0.0, 90.0, 130.0], [-6.0, 50.0, 4.0, 50.0], [108.0, 290.0, 108.0, 236.0], [50.0, 110.0, -11.0, 176.0],
	[180.0, 262.0, -60.0, 13.0], [166.0, 218.0, 13.0, 60.0]]

var fixture: Node3D
var campus: Node3D


static func in_rest(at: Vector3) -> bool:
	if at.x < -80.0 or at.x > 420.0 or at.z < -60.0 or at.z > 290.0:
		return false
	for box: Array in NOT_REST:
		if at.x >= box[0] and at.x <= box[1] and at.z >= box[2] and at.z <= box[3]:
			if box[0] == 166.0 and at.x < 170.0 and at.z > 37.0:
				continue   # T-263's corner, this wave's
			return false
	return true


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


func test_colliders_and_contract_match_main() -> void:
	var scene := CAMPUS.instantiate()
	var colliders := T259.md5(T259.collider_rows(scene))
	var contract := T259.md5(T259.campus_contract_rows(scene))
	print("T264_REST_FINGERPRINT %s %s" % [colliders, contract])
	assert_eq(colliders, CAMPUS_COLLIDERS_MD5, "campus colliders as main has them")
	assert_eq(contract, CAMPUS_CONTRACT_MD5, "anchors, zones, navigation as main has them")
	scene.free()


func test_ps1_hidden_never_removed() -> void:
	await _campus()
	var hidden := 0
	for tile in campus.get_node("Ground").get_children():
		var mesh := tile.get_node("Mesh") as MeshInstance3D
		var c := (tile as Node3D).position
		var in_wave8 := c.x + 25.0 > WAVE8[0] and c.x - 25.0 < WAVE8[1] and c.z + 25.0 > WAVE8[2] and c.z - 25.0 < WAVE8[3]
		if not mesh.visible:
			hidden += 1
			assert_false(in_wave8, "%s (wave 8's ground) keeps its mesh" % tile.name)
		assert_true(tile.has_node("Collision"), "%s keeps its collider" % tile.name)
	assert_eq(hidden, TILES_HIDDEN, "tiles under the new ground hidden")
	for path in ["Road/Avenue/Mesh", "Road/EastBranch/Mesh", "Road/StadiumEastAccess/Mesh", "Fence/N/Mesh", "Fence/E/Mesh", "Fence/W/Mesh"]:
		assert_false((campus.get_node(path) as Node3D).visible, "PS1 hidden: " + path)
	for k in 3:
		assert_false((campus.get_node("Road/RoadBench%d" % k) as Node3D).visible, "RoadBench%d hidden" % k)
		assert_false((campus.get_node("Road/FallenMoped%d" % k) as Node3D).visible, "FallenMoped%d hidden" % k)
		assert_true(campus.has_node("Road/BenchBody%d" % k) and campus.has_node("Road/MopedBody%d" % k), "their colliders stay")
	for path in ["StripRest/Ground", "StripRest/Fences", "StripRest/Props"]:
		assert_true(campus.has_node(path), path)
	assert_eq(campus.get_node("Props/Lights").get_child_count(), 11, "the street lamps' lights as they were")


func test_trees_and_lamps_on_the_ps1_points() -> void:
	await _campus()
	var trees := 0
	var lamps := 0
	for path in ["Road", "Props/Trees"]:
		for cluster in campus.get_node(path).get_children():
			var kind: Variant = cluster.get("kind")
			if kind != "tree" and kind != "lamp":
				continue
			var points: PackedVector3Array = cluster.get("points")
			for child in cluster.get_children():
				if child is MultiMeshInstance3D:
					assert_false((child as Node3D).visible, "%s: PS1 shapes hidden" % cluster.name)
			var holder := campus.get_node("StripRest/" + String(cluster.name))
			var placed := 0
			for multi: MultiMeshInstance3D in holder.get_children():
				if multi.name.ends_with("Bark") or multi.name == "Pole":
					placed += multi.multimesh.instance_count
					var origins: PackedVector3Array = multi.get_meta("origins")
					assert_eq(origins.size(), multi.multimesh.instance_count, "%s/%s: one origin per instance" % [cluster.name, multi.name])
					for o in origins:
						assert_true(Array(points).has(o), "%s/%s stands on a PS1 point (%s)" % [cluster.name, multi.name, o])
				assert_true(multi.visibility_range_end > 0.0 and multi.visibility_range_end <= 125.0, "%s/%s draws to 125 m at most" % [cluster.name, multi.name])
				if multi.name.contains("Leaves") or multi.name.ends_with("Far") or multi.name == "LampGlass":
					assert_eq(multi.cast_shadow, GeometryInstance3D.SHADOW_CASTING_SETTING_OFF, "%s/%s casts no shadow" % [cluster.name, multi.name])
			assert_eq(placed, points.size(), "%s: one tree or light per point" % cluster.name)
			if kind == "tree":
				trees += placed
			else:
				lamps += placed
	print("T264_REST_TREES %d LAMPS %d" % [trees, lamps])
	assert_eq(trees, 175, "every tree point")
	assert_eq(lamps, 21, "every street light point")
	# The arms reach over the road: x 86 over WestBranch (west), the Avenue's lights (z -20) north.
	assert_true(is_equal_approx(REST.lamp_yaw(86.0, 5.0), -PI / 2.0), "WestBranch's lights reach west")
	assert_true(is_equal_approx(REST.lamp_yaw(120.0, -20.0), 0.0), "the Avenue's lights reach over it")


static func _vertices(file: String, mesh_name: String) -> PackedVector3Array:
	var root := (load(MODELS + file) as PackedScene).instantiate() as Node3D
	var out := PackedVector3Array()
	for mesh: MeshInstance3D in root.find_children("*", "MeshInstance3D", true, false):
		if mesh_name != "" and String(mesh.name) != mesh_name:
			continue
		for s in mesh.mesh.get_surface_count():
			for v: Vector3 in mesh.mesh.surface_get_arrays(s)[Mesh.ARRAY_VERTEX]:
				out.append(mesh.transform * v)
	root.free()
	return out


func test_trunks_inside_their_boxes_and_no_leaf_below_two_metres() -> void:
	# The trees are placed scaled 0.9..1.1 (rest_real.gd): the 0.22 m trunk stays inside TreeTrunk's 0.5 m box.
	for sp in ["bang", "phuong", "xacu"]:
		for name in ["Leaves", "LeavesMid"]:
			for v in _vertices("tree_%s.glb" % sp, name):
				assert_true(v.y >= 2.0 / 0.9, "%s %s vertex %s over 2 m" % [sp, name, v])
				if v.y < 2.0 / 0.9:
					break
		for v in _vertices("tree_%s.glb" % sp, "Bark"):
			if v.y < 3.0:
				assert_true(Vector2(v.x, v.z).length() * 1.1 <= 0.25, "%s trunk vertex %s inside the trunk box" % [sp, v])
				if Vector2(v.x, v.z).length() * 1.1 > 0.25:
					break
	# Far cards (from 85 m) are flat crossed quads, transparent but for the crown and the trunk.


func test_seen_ground_within_two_centimetres_of_the_collider() -> void:
	for name in ["Road", "Paved", "Verge"]:
		for v in _vertices("ground.glb", name):
			var y := v.y + G
			var top := -9.87 if name == "Road" and v.x > 177.0 else -9.915   # the Avenue rises to T-262's stretch
			assert_true(y >= COLLIDER_TOP and y <= top + 0.0005, "%s vertex %s within 2 cm of the collider" % [name, Vector3(v.x, y, v.z)])
			if y < COLLIDER_TOP or y > top + 0.0005:
				break


func test_fences_inside_their_colliders() -> void:
	for v in _vertices("fences.glb", ""):
		var p := Vector3(v.x, v.y + G, v.z)
		var inside := (absf(p.x + 80.0) <= 0.15 or absf(p.x - 420.0) <= 0.15 or absf(p.z - 290.0) <= 0.15) and p.y >= G - 0.07 and p.y <= G + 3.0
		assert_true(inside, "fence vertex %s inside Fence/N|E|W" % p)
		if not inside:
			break


func test_corpse_pieces_blood_and_drag_marks_untouched() -> void:
	var props := PROPS.instantiate()
	var kept := {"D_iron": 0, "D_red": 0, "skin": 0}
	for chunk in props.find_children("*", "Node3D", true, false):
		var data: Variant = chunk.get("data")
		if not data is PackedFloat32Array:
			continue
		var values: PackedFloat32Array = data
		for k in range(0, values.size(), 16):
			var drawn := false
			for c in 9:
				drawn = drawn or values[k + c] != 0.0
			if not drawn:
				continue
			var tint := Vector3(values[k + 12], values[k + 13], values[k + 14])
			if String(chunk.name).begins_with("D_iron"):
				kept.D_iron += 1
			elif String(chunk.name).begins_with("D_red"):
				kept.D_red += 1
			elif tint.is_equal_approx(Vector3(0.9, 0.7, 0.6)):
				kept.skin += 1
	print("T264_REST_KEPT ", kept)
	for key: String in KEPT:
		assert_eq(kept[key], KEPT[key], "%s pieces still drawn as main has them" % key)
	# The rest's instances at 0: this wave's 365 (rest_props.py; the two phones stay drawn) and the 49 main already had there.
	var zeroed := 0
	for chunk in props.find_children("*", "Node3D", true, false):
		var data: Variant = chunk.get("data")
		if not data is PackedFloat32Array:
			continue
		var values: PackedFloat32Array = data
		for k in range(0, values.size(), 16):
			if values[k] == 0.0 and values[k + 4] == 0.0 and values[k + 8] == 0.0 and in_rest(Vector3(values[k + 9], values[k + 10], values[k + 11])):
				zeroed += 1
	assert_eq(zeroed, 365 + 49, "the rest of A16's replaced instances scaled to 0")
	props.free()


func test_floor4_balconies_take_the_new_back_colour() -> void:
	var exterior := load("res://assets/models/graphics_pilot/floor4_rooms/materials/F4Exterior.tres") as ShaderMaterial
	var back := load(MODELS + "materials/W7WallPale.tres") as ShaderMaterial
	assert_eq(exterior.get_shader_parameter("base_tint"), back.get_shader_parameter("base_tint"), "rooms 401-408's outside as the new back")
	assert_eq(exterior.get_shader_parameter("base_albedo"), back.get_shader_parameter("base_albedo"), "the same painted plaster")
	var room407 := load("res://scenes/levels/room407/room407_furnish.gd")
	var look: Dictionary = room407.SHELL_LOOKS["ShellExterior"]
	assert_eq(look.base_tint, back.get_shader_parameter("base_tint"), "room 407's balcony as the new back")


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
	assert_true(count >= 18, "wave 7 textures found (%d)" % count)


func test_glbs_use_only_shared_materials() -> void:
	var triangles := 0
	for glb in ["ground", "fences", "rest_props", "tree_bang", "tree_phuong", "tree_xacu", "lamp_steel"]:
		var root := (load(MODELS + glb + ".glb") as PackedScene).instantiate() as Node3D
		for mesh: MeshInstance3D in root.find_children("*", "MeshInstance3D", true, false):
			triangles += mesh.mesh.get_faces().size() / 3
			for surface in mesh.mesh.get_surface_count():
				var material := mesh.mesh.surface_get_material(surface)
				assert_true(material != null and material.resource_path.begins_with("res://assets/models/graphics_pilot/realistic_map/"),
					"%s/%s surface %d uses a shared material" % [glb, mesh.name, surface])
		root.free()
	print("T264_REST_TRIANGLES %d" % triangles)
	assert_true(triangles < 90000, "round 3's glbs within budget (%d triangles)" % triangles)


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


func test_player_walks_the_round_one_routes() -> void:
	await _campus()
	var player := (load("res://scenes/player/player.tscn") as PackedScene).instantiate() as CharacterBody3D
	fixture.add_child(player)
	player.set_physics_process(false)
	player.set_process_input(false)
	player.set_process_unhandled_input(false)
	# The north loop round the stadium, down EastBranch; along the west and north fences.
	await _walk(player, [Vector3(100, G, 245), Vector3(300, G, 245), Vector3(310, G, 200), Vector3(310, G, 120)])
	await _walk(player, [Vector3(-78.6, G, -55), Vector3(-78.6, G, 280), Vector3(-75, G, 288.6), Vector3(100, G, 288.6)])
