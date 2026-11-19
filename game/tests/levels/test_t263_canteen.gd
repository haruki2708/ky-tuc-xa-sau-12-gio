extends TestCase
## T-263 round 2 (D-181): the realistic canteen (canteen.tscn Real: T1 tables, F1 floor and walls, Q1 counter with the
## black wood price boards, C2 ceiling, K1 kitchen, M2 mess, the TV's wordless news frame; the east side's basins and
## tray return, the store, the outside walls and roofs, the bikes), the west exit's faces and the A16 strip round the
## canteen (campus.tscn StripCanteen). Colliders, nodes, metas, lights, labels' words, anchors, zones and navigation are
## main's (md5 of main's rows, taken from main's scenes before the patch); PS1 meshes and labels are hidden, never
## removed; the TV still turns on and off and the kitchen clock still reads 4; nothing new stands where the player walks
## and no door is narrowed; the player walks the companions' way through the hall and the store, into the kitchen, and
## in through the west exit from chapter 4's start. Replaces round 1's test_t263_canteen_pilot.gd.

const T259 := preload("res://tests/levels/test_t259_garden.gd")
const T264 := preload("res://tests/levels/test_t264_rest.gd")
const CAMPUS := preload("res://scenes/levels/campus/campus.tscn")
const CANTEEN := preload("res://scenes/levels/campus/canteen.tscn")
const PROPS := preload("res://scenes/levels/campus/props.tscn")
const MODELS := "res://assets/models/graphics_pilot/realistic_map/wave6/"
const TEXTURES := "res://assets/textures/graphics_pilot/realistic_map/wave6/"
const GLBS := ["hall_shell", "windows", "ceiling_panels", "lights_fans", "tables_inox", "tableware_mess", "counter_inox", "price_boards",
	"tv", "tv_screen", "kitchen_room", "kitchen_k1", "clock", "facade", "hall_east", "store", "outside", "bikes", "strip_canteen",
	"strip_canteen_props"]
const REAL := ["HallShell", "Windows", "Ceiling", "LightsFans", "Tables", "Tableware", "Counter", "PriceBoards", "TV", "KitchenRoom",
	"Stove", "Clock", "Facade", "HallEast", "Store", "Outside", "Bikes"]
## md5 of the sorted rows of main's scenes (origin/main d27337c, before patch_canteen.py's round 2 steps).
const CANTEEN_NODES_MD5 := "7da3acc439769ecf78cf7a00ff4bd4b0"  # 1757 rows: canteen.tscn and its WestExit
const CAMPUS_COLLIDERS_MD5 := "5f21b42e2c6bf772a38248595e1a310d"  # as test_t262_gate has it
const CAMPUS_CONTRACT_MD5 := "2d7e21aeb14371114326fc6433d81216"  # as T-259, T-261 and T-262 left it
const PROPS_COLLIDERS_MD5 := "97c2301b5e5f2375e59ef5ecf322a76b"  # as T-259 left it
const G := -9.9
const HEAD := G + 2.0
const A16_BOX := AABB(Vector3(166, -10.5, 13), Vector3(52, 4.5, 47))
const WAVE8 := Rect2(166, 37, 4, 23)          # x 166..170, z 37..60: the way to the library (wave 8)
## The building is an L: the hall, and the kitchen with the store behind its east part (x 170..185.875 behind the hall is the yard).
const FOOTPRINT := [Rect2(169.875, 19.875, 40.25, 24.25), Rect2(185.875, 44.125, 24.25, 8.0)]
## props.tscn chunks with the pieces this wave replaces (papers, sandals, a backpack, trays): 18 scaled to 0 in the box.
const CHUNKS := ["Decals/D_paper_quad_p2_p0", "Decals/D_white_quad_p2_p0", "Parts/P_white_box_p4_p0", "Parts/P_paper_box_p5_p1",
	"Parts/P_white_box_p5_p1"]
## T-262's gate box (its own pieces in the shared chunks were zeroed there).
const GATE_BOX := AABB(Vector3(180, -10.5, -60), Vector3(82, 4.5, 73))
## [x0, x1, z0, z1, lowest y allowed] of the openings' clear volume (floors and sills lie under G + 0.02).
const OPENINGS := [[186.02, 193.98, 19.7, 20.3, -6.6], [169.7, 170.3, 39.52, 41.48, -7.5], [201.02, 202.98, 43.7, 44.3, -7.5],
	[186.145, 197.855, 43.7, 44.3, -6.6], [200.02, 203.98, 51.5, 52.5, -7.47]]  # the kitchen opening between its side walls' faces

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

static func _added(path: String) -> bool:
	return path == "Real" or path.begins_with("Real/") or path == "TV/Screen/Lit" or path.begins_with("TV/Screen/Lit/")


## Every node of canteen.tscn (its WestExit too) but this wave's layer: path, class, transform, body layers, metas,
## shapes; lights' energy, colour, range and shadow; labels' words; navigation links and the threshold's mesh. Visibility
## is left out (the PS1 meshes' is what changes) but for TV/Screen, the node campus.gd toggles.
static func canteen_rows(canteen: Node) -> PackedStringArray:
	var rows := PackedStringArray()
	for node in canteen.find_children("*", "", true, false):
		var path := String(canteen.get_path_to(node))
		if _added(path):
			continue
		var row := "%s|%s" % [path, node.get_class()]
		if node is Node3D:
			row += "|" + T259._snap((node as Node3D).transform)
		if node is CollisionObject3D:
			row += "|%d %d" % [(node as CollisionObject3D).collision_layer, (node as CollisionObject3D).collision_mask]
		if node is CollisionShape3D:
			row += "|" + T259._shape((node as CollisionShape3D).shape) + " %s" % (node as CollisionShape3D).disabled
		if node is OmniLight3D:
			var light := node as OmniLight3D
			row += "|%s %s %s %s %s" % [snappedf(light.light_energy, 0.0001), light.light_color, light.omni_range, light.shadow_enabled, light.visible]
		if node is Label3D:
			row += "|" + (node as Label3D).text
		if node is NavigationLink3D:
			var link := node as NavigationLink3D
			row += "|%s %s %s %s" % [link.start_position, link.end_position, link.bidirectional, link.enabled]
		if node is NavigationRegion3D:
			var mesh := (node as NavigationRegion3D).navigation_mesh
			row += "|%d %d" % [mesh.get_polygon_count(), Array(mesh.get_vertices()).hash()]
		if path == "TV/Screen":
			row += "|visible %s" % (node as Node3D).visible
		for meta in node.get_meta_list():
			row += "|%s=%s" % [meta, node.get_meta(meta)]
		rows.append(row)
	rows.sort()
	return rows


func test_colliders_nodes_lights_and_contract_match_main() -> void:
	var canteen := CANTEEN.instantiate()
	var campus_scene := CAMPUS.instantiate()
	var props := PROPS.instantiate()
	var rows := canteen_rows(canteen)
	var found := {
		"canteen nodes, colliders, lights, labels, west exit": [T259.md5(rows), CANTEEN_NODES_MD5],
		"campus colliders": [T259.md5(T259.collider_rows(campus_scene)), CAMPUS_COLLIDERS_MD5],
		"campus anchors, zones, navigation": [T259.md5(T259.campus_contract_rows(campus_scene)), CAMPUS_CONTRACT_MD5],
		"props colliders": [T259.md5(T259.collider_rows(props)), PROPS_COLLIDERS_MD5],
	}
	print("T263_CANTEEN_ROWS %d" % rows.size())
	for key: String in found:
		print("T263_FINGERPRINT %s %s" % [key, found[key][0]])
		assert_eq(found[key][0], found[key][1], key + " as main has them")
	assert_eq(int(canteen.get_node("KitchenClock").get_meta("stopped_hour")), 4, "KitchenClock still stopped at 4")
	canteen.free()
	campus_scene.free()
	props.free()


# ---------------------------------------------------------------------------------------------- layers

func test_ps1_hidden_and_the_real_layers_hung() -> void:
	await _campus()
	var canteen := campus.get_node("Canteen")
	var hidden := 0
	for node in canteen.find_children("*", "", true, false):
		var path := String(canteen.get_path_to(node))
		if _added(path) or not (node is MeshInstance3D or node is Label3D):
			continue
		assert_false((node as Node3D).visible, "PS1 hidden: " + path)
		hidden += 1
	assert_eq(hidden, 932 + 8 + 5, "every PS1 mesh and label of the canteen and its west exit hidden")
	for name: String in REAL:
		assert_true(canteen.has_node("Real/" + name), "Real/" + name)
	assert_true(canteen.has_node("TV/Screen/Lit"), "the lit screen under TV/Screen")
	for name in ["Ground", "Props"]:
		assert_true(campus.has_node("StripCanteen/" + name), "StripCanteen/" + name)
	# canteen_real.gd's draw distances and shadows, set once loaded.
	var ware := canteen.get_node("Real/Tableware").find_children("*", "MeshInstance3D", true, false)
	assert_true(ware.size() >= 2, "trays and tableware")
	for mesh: MeshInstance3D in ware:
		assert_eq(mesh.visibility_range_end, 40.0, mesh.name + " drawn within 40 m")
		assert_eq(mesh.cast_shadow, GeometryInstance3D.SHADOW_CASTING_SETTING_OFF, mesh.name + " casts no shadow")
	for mesh: MeshInstance3D in canteen.get_node("Real/Store").find_children("*", "MeshInstance3D", true, false):
		assert_eq(mesh.visibility_range_end, 40.0, "store's " + mesh.name + " drawn within 40 m")
	for mesh: MeshInstance3D in campus.get_node("StripCanteen/Ground").find_children("*", "MeshInstance3D", true, false):
		assert_eq(mesh.cast_shadow, GeometryInstance3D.SHADOW_CASTING_SETTING_OFF, "strip's " + mesh.name + " casts no shadow")


func test_tv_turns_on_and_off_and_the_clock_reads_four() -> void:
	await _campus()
	var lit := campus.get_node("Canteen/TV/Screen/Lit") as Node3D
	campus.call("set_canteen_tv", true)
	assert_true(lit.is_visible_in_tree(), "the lit screen shows with the TV on")
	campus.call("set_canteen_tv", false)
	assert_false(lit.is_visible_in_tree(), "and goes with the TV off")
	# The lit screen (1.11 x 0.68) lies in the PS1 case's box; it faces the hall (+x).
	var case := campus.get_node("Canteen/TV/Case/Mesh") as MeshInstance3D
	var ps1 := case.global_transform * case.get_aabb()
	for v in _world_vertices(lit):
		assert_true(ps1.grow(0.02).has_point(v), "lit screen inside the PS1 TV case's box (%s)" % v)
	# The new clock's hour hand at 4 o'clock: seen from the kitchen (looking +z) that is down and to the right (-x).
	var clock := campus.get_node("Canteen/KitchenClock") as Node3D
	var centre := clock.global_position
	var tips: Array[Vector2] = []
	for mesh: MeshInstance3D in campus.get_node("Canteen/Real/Clock").find_children("*", "MeshInstance3D", true, false):
		for s in mesh.mesh.get_surface_count():
			if mesh.mesh.surface_get_material(s).resource_name != "W1ClockHand":
				continue
			for v: Vector3 in mesh.mesh.surface_get_arrays(s)[Mesh.ARRAY_VERTEX]:
				var w := mesh.global_transform * v
				var d := Vector2(w.x - centre.x, w.y - centre.y)
				if d.length() > 0.1 and d.length() < 0.15:
					tips.append(d)
	assert_true(tips.size() >= 2, "the hour hand's tip")
	for d: Vector2 in tips:
		var angle := rad_to_deg(atan2(-d.x, d.y))
		assert_true(absf(angle - 120.0) < 8.0, "hour hand at 4 o'clock (%f degrees clockwise from 12)" % angle)


# ---------------------------------------------------------------------------------------------- the contract

func _world_vertices(root: Node) -> PackedVector3Array:
	var out := PackedVector3Array()
	for mesh: MeshInstance3D in root.find_children("*", "MeshInstance3D", true, false):
		for s in mesh.mesh.get_surface_count():
			for v: Vector3 in mesh.mesh.surface_get_arrays(s)[Mesh.ARRAY_VERTEX]:
				out.append(mesh.global_transform * v)
	return out


func _boxes(prefix: String) -> Array[AABB]:
	var boxes: Array[AABB] = []
	var canteen := campus.get_node("Canteen")
	for shape: CollisionShape3D in canteen.find_children("*", "CollisionShape3D", true, false):
		if String(canteen.get_path_to(shape.get_parent())).begins_with(prefix):
			var size := (shape.shape as BoxShape3D).size
			boxes.append(shape.global_transform * AABB(-size / 2, size))
	return boxes


static func _over(v: Vector3, boxes: Array[AABB], grow: float) -> bool:
	for box: AABB in boxes:
		var b := box.grow(grow)
		if v.x >= b.position.x and v.x <= b.end.x and v.z >= b.position.z and v.z <= b.end.z:
			return true
	return false


var _keep_boxes: Array[AABB] = []
var _keep_grow := 0.0


## Vertices under head height that `keep` (a method of this test) does not allow.
func _outside(vertices: PackedVector3Array, keep: Callable) -> PackedVector3Array:
	var bad := PackedVector3Array()
	for v in vertices:
		if v.y < HEAD and not keep.call(v):
			bad.append(v)
	return bad


func _keep_over(v: Vector3) -> bool:
	return _over(v, _keep_boxes, _keep_grow)


## The east side: basins on SinkBlock, the rack on TrayReturn, taps, mirrors, posters and AC heads on the walls, sills on
## the floor; the slop bins and their lid where the PS1 bins stood (they had no collider either).
func _keep_east(v: Vector3) -> bool:
	return _keep_over(v) or v.x >= 209.5 or v.x <= 170.5 or v.y <= G + 0.02 or Vector2(v.x - 208.4, v.z - 41.55).length() <= 0.85


## The store: racks in the PS1 racks' footprints, sacks where the PS1 sacks lay, wall and floor pieces.
func _keep_store(v: Vector3) -> bool:
	return _keep_over(v) or v.y <= G + 0.02 or v.x <= 198.2 or v.x >= 209.8 or v.z >= 51.5 or v.z <= 44.2


## Outside: low pieces against the walls (downpipes, hoses, plinths, the west exit's leaf), in the gas cage or by the bins.
func _keep_outside(v: Vector3) -> bool:
	var p := Vector2(v.x, v.z)
	return _footprint_distance(p) <= 0.35 or Rect2(188.55, 52.1, 1.5, 1.4).has_point(p) or Rect2(204.4, 53.6, 2.4, 1.3).has_point(p)


static func _footprint_distance(p: Vector2) -> float:
	var best := 99.0
	for r: Rect2 in FOOTPRINT:
		var dx := maxf(maxf(r.position.x - p.x, p.x - r.end.x), 0.0)
		var dy := maxf(maxf(r.position.y - p.y, p.y - r.end.y), 0.0)
		best = minf(best, Vector2(dx, dy).length())
	return best


## The bikes where the PS1 bikes stood (x 171.4..180.6 along the facade at z 17.2; they never had colliders).
func _keep_bikes(v: Vector3) -> bool:
	return v.x > 170.9 and v.x < 181.1 and v.z > 16.4 and v.z < 18.0


func test_new_pieces_stay_on_their_ps1_colliders_or_out_of_reach() -> void:
	await _campus()
	var real := campus.get_node("Canteen/Real")
	_keep_boxes = _boxes("Table_")
	_keep_grow = 0.06
	assert_eq(_keep_boxes.size(), 21, "21 table colliders")
	var bad := _outside(_world_vertices(real.get_node("Tables")), _keep_over)
	assert_eq(bad.size(), 0, "tables and stools over the tables' colliders (%s)" % bad.slice(0, 3))
	_keep_boxes = _boxes("Cooktop")
	_keep_grow = 0.08
	bad = _outside(_world_vertices(real.get_node("Stove")), _keep_over)
	assert_eq(bad.size(), 0, "the stove and its pots over the cooktop (%s)" % bad.slice(0, 3))
	_keep_boxes = _boxes("SinkBlock")
	_keep_boxes.append_array(_boxes("TrayReturn"))
	_keep_grow = 0.03
	bad = _outside(_world_vertices(real.get_node("HallEast")), _keep_east)
	assert_eq(bad.size(), 0, "east side's pieces on their colliders, the walls or the floor (%s)" % bad.slice(0, 3))
	_keep_boxes = [AABB(Vector3(198.84, G, 45.48), Vector3(0.72, 3, 5.04)), AABB(Vector3(208.84, G, 45.48), Vector3(0.72, 3, 5.04)),
		AABB(Vector3(199.95, G, 48.8), Vector3(0.9, 1, 2.4)), AABB(Vector3(196.45, G, 44.6), Vector3(0.9, 1, 1.6))]
	_keep_grow = 0.0
	bad = _outside(_world_vertices(real.get_node("Store")), _keep_store)
	assert_eq(bad.size(), 0, "store's racks, boxes and sacks in the PS1 ones' places (%s)" % bad.slice(0, 3))
	bad = _outside(_world_vertices(real.get_node("Outside")), _keep_outside)
	assert_eq(bad.size(), 0, "outside fixtures against the walls, in the gas cage or by the bins (%s)" % bad.slice(0, 3))
	bad = _outside(_world_vertices(real.get_node("Bikes")), _keep_bikes)
	assert_eq(bad.size(), 0, "bikes where the PS1 bikes stood (%s)" % bad.slice(0, 3))


func test_no_opening_is_narrowed() -> void:
	await _campus()
	for root: Node in [campus.get_node("Canteen/Real"), campus.get_node("StripCanteen")]:
		for v in _world_vertices(root):
			for o: Array in OPENINGS:
				if v.x > o[0] and v.x < o[1] and v.z > o[2] and v.z < o[3] and v.y > G + 0.02 and v.y < o[4] - 0.001:
					assert_true(false, "a new piece narrows an opening at %s" % v)
					return


# ---------------------------------------------------------------------------------------------- the strip

func test_strip_stays_in_its_box_off_wave_8_and_the_building() -> void:
	await _campus()
	var ground := _world_vertices(campus.get_node("StripCanteen/Ground"))
	assert_true(ground.size() > 100, "lawn, pavers, yard, kerbs, drains")
	for v in ground:
		var p := Vector2(v.x, v.z)
		var ok := A16_BOX.grow(0.02).has_point(v) and not WAVE8.grow(-0.02).has_point(p) and not (FOOTPRINT[0].grow(-0.02).has_point(p)
			or FOOTPRINT[1].grow(-0.02).has_point(p))
		assert_true(ok, "strip ground vertex %s in the A16 box, off wave 8's corner and the building" % v)
		if not ok:
			return
	# The replaced pieces lie where the PS1 ones did (two papers had drifted onto the store's floor), on the surface.
	for v in _world_vertices(campus.get_node("StripCanteen/Props")):
		var ok := A16_BOX.grow(0.3).has_point(v) and not WAVE8.has_point(Vector2(v.x, v.z)) and v.y > G - 0.04 and v.y < G + 0.3
		assert_true(ok, "strip piece vertex %s in the A16 box, on the ground" % v)
		if not ok:
			return


func test_props_replaced_in_the_box_only() -> void:
	var props := PROPS.instantiate()
	var in_box := 0
	for path: String in CHUNKS:
		var data: PackedFloat32Array = props.get_node(path).get("data")
		for k in range(0, data.size(), 16):
			if data[k] == 0.0 and data[k + 4] == 0.0 and data[k + 8] == 0.0:
				var at := Vector3(data[k + 9], data[k + 10], data[k + 11])
				var here := A16_BOX.grow(0.01).has_point(at) and not WAVE8.has_point(Vector2(at.x, at.z))
				# T-264 round 3 (D-182): the rest of A16's pieces in the shared chunks (test_t264_rest checks them).
				assert_true(here or GATE_BOX.grow(0.01).has_point(at) or T264.in_rest(at), "%s: only pieces in the canteen's or the gate's box hidden (%s)" % [path, at])
				if here:
					in_box += 1
	assert_eq(in_box, 18, "the strip's papers, sandals, backpack and trays scaled to 0")
	props.free()


# ---------------------------------------------------------------------------------------------- walking

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


func _player_at(at: Vector3) -> void:
	player = (load("res://scenes/player/player.tscn") as PackedScene).instantiate() as CharacterBody3D
	fixture.add_child(player)
	player.set_physics_process(false)
	player.set_process_input(false)
	player.set_process_unhandled_input(false)
	player.global_position = at + Vector3(0, 0.05, 0)
	for frame in 4:
		await tree.physics_frame


func test_player_walks_the_companions_way_the_kitchen_and_the_west_exit() -> void:
	await _campus()
	var paths := campus.get_node("Anchors/Paths/Nhat")
	await _player_at((paths.get_node("P29") as Node3D).global_position)
	for name in ["P30_Wait_canteen", "P31", "P32", "P33"]:
		if not await _walk_to((paths.get_node(name) as Node3D).global_position, name):
			return
	for target: Vector3 in [Vector3(202, G, 43), Vector3(192, G, 42), Vector3(192, G, 49.6), Vector3(190.5, G, 46.5), Vector3(192, G, 42)]:
		if not await _walk_to(target, "the kitchen %s" % target):
			return
	for target: Vector3 in [Vector3(176.5, G, 37.8), Vector3(172, G, 40.5), Vector3(167.5, G, 40.5)]:
		if not await _walk_to(target, "out of the west exit %s" % target):
			return
	var split: Vector3 = (campus.get_node("Anchors/Ch4/Start_split") if campus.has_node("Anchors/Ch4/Start_split")
		else campus.get_node("Ch4/Start_split")).global_position
	for target: Vector3 in [split, Vector3(172, G, 40.5), Vector3(176.5, G, 37.8)]:
		if not await _walk_to(target, "chapter 4's way in %s" % target):
			return


# ---------------------------------------------------------------------------------------------- assets

func test_every_wave6_texture_imports_vram_compressed() -> void:
	var count := 0
	for file in DirAccess.get_files_at(TEXTURES):
		if not file.ends_with(".png"):
			continue
		count += 1
		var config := ConfigFile.new()
		assert_eq(config.load(TEXTURES + file + ".import"), OK, file + " has import settings")
		assert_eq(config.get_value("params", "compress/mode"), 2, file + " VRAM compressed")
		assert_eq(config.get_value("params", "compress/normal_map"), 1 if file.ends_with("_normal.png") else 0, file + " normal-map flag")
	assert_true(count >= 16, "wave 6 textures found (%d)" % count)


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
	print("T263_TRIANGLES %d" % triangles)
	assert_true(triangles < 110000, "wave 6's layers within budget (%d triangles)" % triangles)
