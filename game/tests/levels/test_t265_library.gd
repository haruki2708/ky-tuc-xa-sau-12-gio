extends TestCase
## T-265 round 2 (D-185): the realistic library (library.tscn Real: three floors' insides, stairs and the well's railing,
## Q1 counter, the librarian's chair, the printed map, T1 tables, the stacks and books, M2's pieces and the double-faced
## rows, the mess, the doors, the barricade, the E1 facade) and the ring of ground round it (campus.tscn StripLibrary).
## Colliders, nodes, metas, lights and navigation of library.tscn are main's (md5 of main's rows, taken before the patch;
## Real and BackDoor/Hinge/LeafReal left out); PS1 meshes are hidden, never removed; the only new colliders are
## Real/Added's, each where card section 4 allows it (outside navigation + 0.6 m, out of the 1.5 m rings, off the links
## and sightlines, no slot under 1.2 m) and the two railings along the well's west edge (outside navigation + the zombie's
## widest shape); the player walks the library from the back door to floor 3's scare points and back, and the well's edge
## stops them; the zombies' routes from the six spawns reach floor 3. Replaces round 1's test_t265_pilot.gd.

const T259 := preload("res://tests/levels/test_t259_garden.gd")
const CAMPUS := preload("res://scenes/levels/campus/campus.tscn")
const LIBRARY := preload("res://scenes/levels/library/library.tscn")
const PROPS := preload("res://scenes/levels/campus/props.tscn")
const REAL_SCRIPT := preload("res://scenes/levels/library/library_real.gd")
const MODELS := "res://assets/models/graphics_pilot/realistic_map/wave8/"
const TEXTURES := "res://assets/textures/graphics_pilot/realistic_map/wave8/"
const GLBS := ["shell_f1", "shell_f2", "shell_f3", "stairs", "counter_q1", "librarian_chair", "map_print", "tables", "shelves_f1", "shelves_f2",
	"shelves_f3n", "shelves_f3s", "fill_f1", "fill_f2", "fill_f3", "back_frame", "back_leaf", "front_door", "barricade", "facade", "strip"]
const REAL := ["Shell_F1", "Shell_F2", "Shell_F3", "Stairs", "Counter", "LibrarianChair", "Map", "Tables", "Shelves_F1", "Shelves_F2",
	"Shelves_F3N", "Shelves_F3S", "Fill_F1", "Fill_F2", "Fill_F3", "BackFrame", "FrontDoor", "Barricade", "Facade", "Added"]
## md5 of the sorted rows of main's library.tscn (origin/main 4cad2a3, before patch_wave8.py's library step).
const LIBRARY_ROWS_MD5 := "9b2668a8bc6a14740878a571d110f8cb"
const LIBRARY_ROWS := 1533
const G := -9.9
const LEVELS := [-9.9, -6.6, -3.3]
const ADDED := 111            # wave8_layout.FINAL (109 pieces over 0.3 m) and the two railings
const NAV_BAND := 0.6
const RING := 1.5
const LANE := 1.2
const TOUCH := 0.05
const ZOMBIE_R := 0.31        # zombie.tscn's widest shape (head sphere 0.31; capsule 0.25, agent 0.3)
## The railings (card section 1.11): x 78.86..78.94, z 199..209, 1.1 m over floors 2 and 3.
const RAILS := {"WellRail_F2": AABB(Vector3(78.86, -6.6, 199.0), Vector3(0.08, 1.1, 10.0)),
	"WellRail_F3": AABB(Vector3(78.86, -3.3, 199.0), Vector3(0.08, 1.1, 10.0))}
const ZONE := AABB(Vector3(39, -10.5, 189), Vector3(52, 4.5, 42))
const FOOTPRINT := Rect2(44.89, 194.89, 40.22, 30.22)
const SCARES := [Vector2(57, 218), Vector2(73, 218)]
const SCARE_SHELVES := [Rect2(55.5, 217.7, 3.0, 0.6), Rect2(71.5, 217.7, 3.0, 0.6)]

var fixture: Node3D
var campus: Node3D
var library: Node3D
var player: CharacterBody3D


func after_each() -> void:
	if is_instance_valid(fixture):
		fixture.queue_free()
		await wait_frames(3)
		await tree.create_timer(0.35).timeout


func _campus(nav := false) -> void:
	fixture = Node3D.new()
	tree.root.add_child(fixture)
	campus = CAMPUS.instantiate() as Node3D
	fixture.add_child(campus)
	library = campus.get_node("Library") as Node3D
	await wait_frames(3)
	await tree.physics_frame
	if nav:
		var map := fixture.get_world_3d().navigation_map
		NavigationServer3D.map_force_update(map)
		for frame in 180:
			await tree.physics_frame
			var probe := NavigationServer3D.map_get_path(map, Vector3(65, G, 211), Vector3(65, -3.3, 211), true)
			if probe.size() >= 2 and probe[-1].distance_to(Vector3(65, -3.3, 211)) < 0.1:
				break


# ---------------------------------------------------------------------------------------------- fingerprints

static func _added(path: String) -> bool:
	return path == "Real" or path.begins_with("Real/") or path == "BackDoor/Hinge/LeafReal" or path.begins_with("BackDoor/Hinge/LeafReal/")


## Every node of library.tscn but this wave's (Real, the new leaf): path, class, transform, body layers, shapes, metas;
## lights' energy, colour, range, shadow; navigation's polygons and links. Visibility is left out (the PS1 meshes' changes).
static func library_rows(lib: Node) -> PackedStringArray:
	var rows := PackedStringArray()
	for node in lib.find_children("*", "", true, false):
		var path := String(lib.get_path_to(node))
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
			row += "|%s %s %s %s" % [snappedf(light.light_energy, 0.0001), light.light_color, light.omni_range, light.shadow_enabled]
		if node is NavigationLink3D:
			var link := node as NavigationLink3D
			row += "|%s %s %s %s" % [link.start_position, link.end_position, link.bidirectional, link.enabled]
		if node is NavigationRegion3D:
			var mesh := (node as NavigationRegion3D).navigation_mesh
			row += "|%d %d" % [mesh.get_polygon_count(), Array(mesh.get_vertices()).hash()]
		for meta in node.get_meta_list():
			row += "|%s=%s" % [meta, node.get_meta(meta)]
		rows.append(row)
	rows.sort()
	return rows


func test_library_contract_matches_main_and_the_ps1_is_hidden() -> void:
	var lib := LIBRARY.instantiate()
	var rows := library_rows(lib)
	print("T265_LIBRARY_ROWS %d %s" % [rows.size(), T259.md5(rows)])
	assert_eq(rows.size(), LIBRARY_ROWS, "library.tscn's rows as main's")
	assert_eq(T259.md5(rows), LIBRARY_ROWS_MD5, "library.tscn's nodes, colliders, lights and navigation as main has them")
	var hidden := 0
	for mesh: MeshInstance3D in lib.find_children("*", "MeshInstance3D", true, false):
		var path := String(lib.get_path_to(mesh))
		if _added(path) or path.begins_with("Counter/IronBar"):
			continue
		assert_false(mesh.visible, "PS1 hidden: " + path)
		hidden += 1
	assert_eq(hidden, 667, "every PS1 mesh of the library hidden, none removed")
	for name: String in REAL:
		assert_true(lib.has_node("Real/" + name), "Real/" + name)
	assert_true(lib.has_node("BackDoor/Hinge/LeafReal"), "the new leaf under BackDoor/Hinge")
	assert_true(lib.has_node("Counter/IronBar"), "the iron bar where it was")
	lib.free()


func test_bands_hidden_and_draw_ranges_set() -> void:
	await _campus()
	for k in 3:
		assert_false((campus.get_node("Shells/LibraryBand%d/Mesh" % k) as Node3D).visible, "LibraryBand%d hidden" % k)
	assert_true(campus.has_node("StripLibrary/Ground"), "the ring of ground")
	var near := 0
	var far := 0
	for mesh: MeshInstance3D in library.get_node("Real").find_children("*", "MeshInstance3D", true, false):
		var name := String(mesh.name)
		if name.begins_with("BooksFar_"):
			far += 1
			assert_eq(mesh.visibility_range_begin, REAL_SCRIPT.NEAR, name + " drawn beyond the near range")
		elif name.begins_with("Books_"):
			near += 1
			assert_eq(mesh.visibility_range_end, REAL_SCRIPT.NEAR, name + " drawn within the near range")
		if name.begins_with("Books") or name == "Mess":
			assert_eq(mesh.cast_shadow, GeometryInstance3D.SHADOW_CASTING_SETTING_OFF, name + " casts no shadow")
	assert_eq(near, far, "a far mesh for every near one")
	assert_true(near >= 40, "book clusters (%d)" % near)


func test_floors_drawn_for_the_camera() -> void:
	# Inside: one floor up or down; outside: floor 1's within 12 m (the doors' glass), nothing from afar.
	assert_eq(REAL_SCRIPT.floors_shown(Vector3(65, -8.3, 211)), [true, true, false], "floor 1")
	assert_eq(REAL_SCRIPT.floors_shown(Vector3(65, -5.0, 211)), [true, true, true], "floor 2")
	assert_eq(REAL_SCRIPT.floors_shown(Vector3(65, -1.7, 211)), [false, true, true], "floor 3")
	assert_eq(REAL_SCRIPT.floors_shown(Vector3(81.5, -5.4, 207.5)), [true, true, true], "the top of the first flight")
	assert_eq(REAL_SCRIPT.floors_shown(Vector3(65, -8.3, 228)), [true, false, false], "outside the back door")
	assert_eq(REAL_SCRIPT.floors_shown(Vector3(114, -4.5, 196)), [false, false, false], "from the stadium")


# ---------------------------------------------------------------------------------------------- the added colliders

class Box:
	var name: String
	var level: int
	var rect: Rect2
	var top: float

	func _init(n: String, l: int, r: Rect2, t: float) -> void:
		name = n
		level = l
		rect = r
		top = t


static func _gap(a: Rect2, b: Rect2) -> float:
	var dx := maxf(maxf(a.position.x - b.end.x, b.position.x - a.end.x), 0.0)
	var dz := maxf(maxf(a.position.y - b.end.y, b.position.y - a.end.y), 0.0)
	return Vector2(dx, dz).length()


static func _level(y: float) -> int:
	return 0 if y < -8.0 else (1 if y < -4.7 else 2)


func _world_box(shape: CollisionShape3D) -> AABB:
	var size := (shape.shape as BoxShape3D).size
	return shape.global_transform * AABB(-size / 2, size)


func _added_boxes() -> Array[Box]:
	var out: Array[Box] = []
	for body: StaticBody3D in library.get_node("Real/Added").get_children():
		var box := _world_box(body.get_node("Collision") as CollisionShape3D)
		out.append(Box.new(String(body.name), _level(box.position.y), Rect2(box.position.x, box.position.z, box.size.x, box.size.z), box.end.y))
	return out


## PS1 obstacles standing on a floor (walls, doors, shelves, tables, counter, barricade, stairs, rails).
func _ps1_obstacles(level: int) -> Array[Rect2]:
	var out: Array[Rect2] = []
	for shape: CollisionShape3D in library.find_children("*", "CollisionShape3D", true, false):
		var path := String(library.get_path_to(shape))
		if _added(path) or not (shape.shape is BoxShape3D) or path.begins_with("Floor") or path.begins_with("Roof") or path.begins_with("StairBase"):
			continue
		var body := shape.get_parent() as CollisionObject3D
		if body == null or body.collision_layer & 1 == 0:
			continue
		var box := _world_box(shape)
		if box.end.y < LEVELS[level] + 0.1 or box.position.y > LEVELS[level] + 1.9:
			continue
		out.append(Rect2(box.position.x, box.position.z, box.size.x, box.size.z))
	return out


func _nav_rects(level: int) -> Array[Rect2]:
	var out: Array[Rect2] = []
	for region: NavigationRegion3D in library.find_children("*", "NavigationRegion3D", true, false):
		var mesh := region.navigation_mesh
		var verts := mesh.get_vertices()
		for p in mesh.get_polygon_count():
			var poly := mesh.get_polygon(p)
			var lo := Vector3.INF
			var hi := -Vector3.INF
			for i in poly:
				var v := region.global_transform * verts[i]
				lo = lo.min(v)
				hi = hi.max(v)
			if absf(lo.y - LEVELS[level]) < 0.3:
				out.append(Rect2(lo.x, lo.z, hi.x - lo.x, hi.z - lo.z))
	return out


func _rings(level: int) -> Array[Vector2]:
	var out: Array[Vector2] = []
	for anchor: Node3D in campus.get_node("Anchors/Ch4").get_children():
		var p := anchor.global_position
		if FOOTPRINT.has_point(Vector2(p.x, p.z)) and p.y >= LEVELS[level] - 0.2 and p.y < LEVELS[level] + 3.0:
			out.append(Vector2(p.x, p.z))
	if level == 0:
		out.append(Vector2(65, 225))
	if level < 2:
		out.append(Vector2(81, 198))
	if level > 0:
		out.append(Vector2(81, 210))
	return out


static func _seg_gap(a: Vector2, b: Vector2, r: Rect2) -> float:
	var best := INF
	var n := maxi(2, int(a.distance_to(b) / 0.05))
	for k in n + 1:
		var p := a.lerp(b, float(k) / n)
		best = minf(best, _gap(Rect2(p, Vector2.ZERO), r))
	return best


static func _hits_triangle(r: Rect2, t: PackedVector2Array) -> bool:
	var corners := PackedVector2Array([r.position, Vector2(r.end.x, r.position.y), r.end, Vector2(r.position.x, r.end.y)])
	for c in corners:
		if Geometry2D.point_is_inside_triangle(c, t[0], t[1], t[2]):
			return true
	for v in t:
		if r.has_point(v):
			return true
	for i in 4:
		for j in 3:
			if Geometry2D.segment_intersects_segment(corners[i], corners[(i + 1) % 4], t[j], t[(j + 1) % 3]) != null:
				return true
	return false


func test_added_colliders_keep_card_section_4() -> void:
	await _campus()
	var added := _added_boxes()
	assert_eq(added.size(), ADDED, "added colliders under Real/Added")
	var links := []
	for link: NavigationLink3D in library.find_children("*", "NavigationLink3D", true, false):
		var a := link.global_transform * link.start_position
		var b := link.global_transform * link.end_position
		links.append([a, b])
	var sightlines := {0: PackedVector2Array([Vector2(65, 225), Vector2(54.5, 206), Vector2(59.5, 206)]),
		1: PackedVector2Array([Vector2(81, 210), Vector2(56.5, 216), Vector2(59.5, 216)])}
	for box: Box in added:
		var body := library.get_node("Real/Added/" + box.name) as StaticBody3D
		assert_eq(body.collision_layer, 1, box.name + " on the world layer")
		var navs := _nav_rects(box.level)
		if box.name.begins_with("WellRail"):
			var want: AABB = RAILS[box.name]
			var got := _world_box(body.get_node("Collision") as CollisionShape3D)
			assert_true(got.position.is_equal_approx(want.position) and got.size.is_equal_approx(want.size), "%s where the card puts it (%s)" % [box.name, got])
			for nav: Rect2 in navs:
				assert_true(_gap(box.rect, nav) >= ZOMBIE_R, "%s clear of navigation by the zombie's width (%.2f)" % [box.name, _gap(box.rect, nav)])
			for ramp: Rect2 in _nav_rects(box.level - 1):
				if ramp.size.y > 5.0 and ramp.position.x > 79.0:
					assert_true(_gap(box.rect, ramp) >= ZOMBIE_R, "%s clear of the flight's navigation" % box.name)
			continue
		assert_true(box.top - LEVELS[box.level] > 0.3, box.name + " is over 0.3 m (a collider)")
		for nav: Rect2 in navs:
			if _gap(box.rect, nav) < NAV_BAND:
				assert_true(false, "%s within 0.6 m of navigation %s" % [box.name, nav])
		for ring: Vector2 in _rings(box.level):
			assert_true(_gap(box.rect, Rect2(ring, Vector2.ZERO)) >= RING, "%s out of the 1.5 m ring at %s" % [box.name, ring])
		for link: Array in links:
			var a: Vector3 = link[0]
			var b: Vector3 = link[1]
			if absf(a.y - LEVELS[box.level]) < 0.3 and absf(b.y - LEVELS[box.level]) < 0.3:
				assert_true(_seg_gap(Vector2(a.x, a.z), Vector2(b.x, b.z), box.rect) >= NAV_BAND, "%s off the link %s" % [box.name, a])
		if sightlines.has(box.level):
			assert_false(_hits_triangle(box.rect, sightlines[box.level]), box.name + " off the sightline")
		if box.level == 1:
			for tx in [53.0, 58.0, 72.0]:
				assert_true(_gap(box.rect, Rect2(tx - 1.5, 215.3, 3.0, 1.4)) >= 3.0, box.name + " 3 m from the reading tables")
		# No slot under 1.2 m: against the PS1's obstacles and the other added pieces.
		var others := _ps1_obstacles(box.level)
		for other: Box in added:
			if other != box and other.level == box.level and not other.name.begins_with("WellRail"):
				others.append(other.rect)
		for r: Rect2 in others:
			var g := _gap(box.rect, r)
			if g > TOUCH and g < LANE - 0.001:
				assert_true(false, "%s leaves a %.2f m slot by %s" % [box.name, g, r])
				break


# ---------------------------------------------------------------------------------------------- what stands on the PS1

func _vertices(root: Node, filter := "") -> PackedVector3Array:
	var out := PackedVector3Array()
	for mesh: MeshInstance3D in root.find_children("*", "MeshInstance3D", true, false):
		if not filter.is_empty() and not String(mesh.name).begins_with(filter):
			continue
		for s in mesh.mesh.get_surface_count():
			for v: Vector3 in mesh.mesh.surface_get_arrays(s)[Mesh.ARRAY_VERTEX]:
				out.append(mesh.global_transform * v)
	return out


func test_counter_bar_map_chair_and_rule_book() -> void:
	await _campus()
	# The iron bar lies on the new top (its foot 0.8865 m; the top 0.868 m: a gap under 2 cm), the old collider (0.84 m)
	# within 3 cm under it.
	var bar := library.get_node("Counter/IronBar") as Node3D
	var foot := bar.global_position.y - IronBarWeapon.RADIUS
	var top := -INF
	for mesh: MeshInstance3D in library.get_node("Real/Counter").find_children("*", "MeshInstance3D", true, false):
		var faces := mesh.mesh.get_faces()
		for i in range(0, faces.size(), 3):
			var a := mesh.global_transform * faces[i]
			var b := mesh.global_transform * faces[i + 1]
			var c := mesh.global_transform * faces[i + 2]
			if absf(a.y - b.y) > 0.0005 or absf(a.y - c.y) > 0.0005 or a.y > foot + 0.001:
				continue
			var p := Vector2(bar.global_position.x, bar.global_position.z)
			if Geometry2D.point_is_inside_triangle(p, Vector2(a.x, a.z), Vector2(b.x, b.z), Vector2(c.x, c.z)):
				top = maxf(top, a.y)
	assert_true(foot - top >= 0.0 and foot - top <= 0.02, "the bar lies on the counter (gap %.4f)" % (foot - top))
	assert_true(top - (G + 0.84) <= 0.03, "the old collider within 3 cm under the top (%.4f)" % (top - (G + 0.84)))
	# The map's two red rings in the print where the PS1's FadedCircle segments run.
	var image := Image.load_from_file(ProjectSettings.globalize_path(TEXTURES + "map_print.png"))
	var paper := library.get_node("MapBoard") as Node3D
	var centre := paper.global_position
	var red := 0
	var segments := 0
	for mesh: Node3D in paper.find_children("FadedCircle*", "Node3D", false, false):
		segments += 1
		var at := mesh.global_position
		var u := (centre.z + 1.45 - at.z) / 2.9
		var v := (centre.y + 0.95 - at.y) / 1.9
		var best := 0.0
		for du in [-3, 0, 3]:
			for dv in [-3, 0, 3]:
				var px := image.get_pixel(clampi(int(u * image.get_width()) + du, 0, image.get_width() - 1), clampi(int(v * image.get_height()) + dv, 0, image.get_height() - 1))
				best = maxf(best, px.r - maxf(px.g, px.b))
		if best > 0.2:
			red += 1
	assert_eq(segments, 52, "the PS1 rings' 52 segments")
	assert_eq(red, segments, "every PS1 ring segment over the print's red ring")
	# The librarian's chair upright, its seat at LibrarianSeat (57, -9.44, 207.5); the rule book on ReadingTable13 at
	# ReadingDesk (58, -5.71, 216).
	var seat := campus.get_node("Anchors/Ch4/LibrarianSeat") as Node3D
	var on_seat := 0
	for v in _vertices(library.get_node("Real/LibrarianChair")):
		if Vector2(v.x - seat.global_position.x, v.z - seat.global_position.z).length() < 0.2 and absf(v.y - seat.global_position.y) < 0.01:
			on_seat += 1
	assert_true(on_seat >= 4, "the chair's seat at the anchor (%d vertices)" % on_seat)
	var desk := campus.get_node("Anchors/Ch4/ReadingDesk") as Node3D
	var book := AABB()
	var first := true
	for v in _vertices(library.get_node("Real/Tables"), "RuleBook"):
		book = AABB(v, Vector3.ZERO) if first else book.expand(v)
		first = false
	assert_true(book.grow(0.02).has_point(desk.global_position - Vector3(0, 0.01, 0)) or Vector2(book.get_center().x - desk.global_position.x,
		book.get_center().z - desk.global_position.z).length() < 0.05, "the rule book at ReadingDesk (%s)" % book)


func test_floors_treads_and_stacks_on_their_colliders() -> void:
	await _campus()
	for level in 3:
		for v in _vertices(library.get_node("Real/Shell_F%d" % (level + 1)), "Floor"):
			if v.y < LEVELS[level] - 0.001 or v.y > LEVELS[level] + 0.02:
				assert_true(false, "floor %d's face %s within 2 cm over its collider" % [level + 1, v])
				break
	for v in _vertices(library.get_node("Real/Stairs"), "Treads"):
		var off := INF
		for level: float in [-9.9, -6.6]:
			var ramp := level + (v.z - 199.0) * 0.33
			if absf(v.y - ramp) < absf(off):
				off = v.y - ramp
		if absf(off) > 0.125 or v.x < 79.0 or v.x > 84.0:
			assert_true(false, "tread vertex %s over its flight, within 12.5 cm of the ramp (%.3f)" % [v, off])
			break
	# The railing inside its colliders.
	for v in _vertices(library.get_node("Real/Stairs"), "WellRail"):
		var inside := false
		for box: AABB in RAILS.values():
			inside = inside or box.grow(0.002).has_point(v)
		if not inside:
			assert_true(false, "railing vertex %s inside its collider" % v)
			break
	# The nine PS1 shelves' new stacks inside their colliders (3 cm), the tables' tops inside theirs.
	for level in 3:
		var z := 202.0 if level == 1 else 218.0
		var shelves := [Rect2(49.45, z - 0.33, 3.1, 0.66), Rect2(55.45, z - 0.33, 3.1, 0.66), Rect2(71.45, z - 0.33, 3.1, 0.66)]
		var bad := 0
		var file := "Real/Shelves_F%d" % (level + 1) if level < 2 else "Real/Shelves_F3N"
		for v in _vertices(library.get_node(file), "Books_F%d_Shelf" % (level + 1)):
			var ok := false
			for r: Rect2 in shelves:
				ok = ok or r.has_point(Vector2(v.x, v.z))
			if not ok:
				bad += 1
		assert_eq(bad, 0, "floor %d: the PS1 shelves' books inside the old stacks" % (level + 1))
	for v in _vertices(library.get_node("Real/Tables"), "Tables"):
		var ok := false
		for tx in [53.0, 58.0, 72.0]:
			ok = ok or (absf(v.x - tx) <= 1.5005 and absf(v.z - 216.0) <= 0.7005 and v.y <= -6.6 + 0.8405)
		if not ok:
			assert_true(false, "table vertex %s inside a PS1 table" % v)
			break



func test_mess_keeps_clear_of_the_scares_and_the_aisles() -> void:
	await _campus()
	for v in _vertices(library.get_node("Real/Fill_F3"), "Mess"):
		var p := Vector2(v.x, v.z)
		for s: Vector2 in SCARES:
			assert_true(p.distance_to(s) >= 2.0, "floor 3's mess 2 m from the scare point %s (%s)" % [s, v])
		for r: Rect2 in SCARE_SHELVES:
			assert_true(_gap(Rect2(p, Vector2.ZERO), r) >= 2.0, "floor 3's mess 2 m from the scare shelf %s (%s)" % [r, v])
	for v in _vertices(library.get_node("Real/Fill_F1"), "Mess"):
		assert_true(Vector2(v.x - 57.0, v.z - 207.5).length() >= 2.0, "nothing lies by the librarian's chair (%s)" % v)
	for level in 3:
		for v in _vertices(library.get_node("Real/Fill_F%d" % (level + 1)), "Mess"):
			assert_true(v.y - LEVELS[level] <= 0.3, "the mess is flat (%s)" % v)
			if v.y - LEVELS[level] > 0.03:
				for nav: Rect2 in _nav_rects(level):
					assert_false(nav.has_point(Vector2(v.x, v.z)), "nothing over 3 cm on the aisles (%s)" % v)


# ---------------------------------------------------------------------------------------------- doors

func _clear(point: Vector3, height := 1.75) -> bool:
	var shape := CapsuleShape3D.new()
	shape.radius = 0.3
	shape.height = height
	var query := PhysicsShapeQueryParameters3D.new()
	query.shape = shape
	query.collision_mask = 1
	query.margin = 0.001
	query.transform.origin = point + Vector3(0, height / 2.0 + 0.06, 0)
	return fixture.get_world_3d().direct_space_state.intersect_shape(query).is_empty()


func test_back_door_new_leaf_swings_blocks_and_breaks() -> void:
	await _campus()
	var door := library.get_node("BackDoor")
	var leaf := door.get_node("Hinge/LeafReal") as Node3D
	var point := Vector3(65, G, 225)
	assert_false(_clear(point), "the shut door blocks")
	var shut := leaf.global_basis
	door.set_open(true)
	await tree.create_timer(0.4).timeout
	await tree.physics_frame
	assert_true(absf(rad_to_deg(shut.z.angle_to(leaf.global_basis.z)) - 90.0) < 1.0, "the new leaf swings 90 degrees with Hinge")
	for dz in [-0.6, 0.0, 0.6]:
		assert_true(_clear(point + Vector3(0, 0, dz)), "the open doorway lets a 0.3 m capsule through (z %+.1f)" % dz)
	for v in _vertices(leaf):
		assert_true(v.x >= 63.999 or v.z < 224.89, "the open leaf clears the jamb (%s)" % v)
		if v.x < 63.999 and v.z >= 224.89:
			break
	door.set_open(false)
	await tree.create_timer(0.4).timeout
	await tree.physics_frame
	assert_false(_clear(point), "shut again, it blocks")
	var bash := ZombieDoor.new()
	bash.door = door
	bash.blocker = door.blocker
	door.add_child(bash)
	bash.bash(0.2, 0.05)
	await tree.create_timer(0.4).timeout
	assert_true(bash.is_broken and door.is_open, "broken, it stands open")
	assert_true(_clear(point), "and lets the zombies in")


# ---------------------------------------------------------------------------------------------- walking

func _walk_to(target: Vector3, label: String) -> bool:
	var frames := 240 + int(player.global_position.distance_to(target) / 5.0 * 60.0 * 1.5)
	for frame in frames:
		await tree.physics_frame
		var offset := target - player.global_position
		offset.y = 0.0
		if offset.length() < 0.3:
			return true
		var d := offset.normalized()
		player.velocity.x = d.x * 5.0
		player.velocity.z = d.z * 5.0
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


func test_player_walks_the_library_and_the_well_edge_stops_them() -> void:
	await _campus()
	library.get_node("BackDoor").set_open(true)
	await tree.create_timer(0.4).timeout
	await _player_at(Vector3(65, G, 227.5))
	# In, the counter and the bar, the map, up to the reading desk, up to floor 3's two scares, down, out.
	var route := [Vector3(65, G, 223), Vector3(62, G, 211), Vector3(58.6, G, 207.6), Vector3(47.0, G, 211), Vector3(77.5, G, 211),
		Vector3(77.5, G, 197.5), Vector3(81.3, G, 197.5), Vector3(81.3, G, 200), Vector3(81.3, -6.6, 210.3), Vector3(65, -6.6, 211),
		Vector3(60.4, -6.6, 213.5), Vector3(60.4, -6.6, 215.6), Vector3(65, -6.6, 211), Vector3(77.5, -6.6, 208), Vector3(77.5, -6.6, 197.5),
		Vector3(81.3, -6.6, 197.5), Vector3(81.3, -6.6, 200), Vector3(81.3, -3.3, 210.3), Vector3(65, -3.3, 211), Vector3(57.6, -3.3, 211.5),
		Vector3(57.6, -3.3, 216.5), Vector3(57.6, -3.3, 211.5), Vector3(73.1, -3.3, 211.5), Vector3(73.1, -3.3, 217.35), Vector3(73.1, -3.3, 211.5),
		Vector3(81.3, -3.3, 210.6), Vector3(81.3, -3.3, 208), Vector3(81.3, -6.6, 198.5), Vector3(77.5, -6.6, 197.5), Vector3(77.5, -6.6, 208),
		Vector3(81.3, -6.6, 210.6), Vector3(81.3, -6.6, 208), Vector3(81.3, G, 198.5), Vector3(77.5, G, 197.5), Vector3(77.5, G, 211),
		Vector3(65, G, 211), Vector3(65, G, 223), Vector3(65, G, 227.5)]
	for target: Vector3 in route:
		if not await _walk_to(target, "%s" % target):
			return
		if target.y > -4.0 and target.z > 216.0:
			var scare := Vector3(57, -3.3, 218) if target.x < 65 else Vector3(73, -1.1, 218)
			var radius := 3.0 if target.x < 65 else 2.5
			assert_true(player.global_position.distance_to(scare) < radius, "the scare at %s fires from %s" % [scare, player.global_position])
	# The well's west edge on floors 2 and 3: walking east into it stops the player on the slab.
	for level: float in [-6.6, -3.3]:
		for z: float in [200.0, 205.0, 208.0]:
			player.global_position = Vector3(77.5, level + 0.05, z)
			player.velocity = Vector3.ZERO
			for frame in 4:
				await tree.physics_frame
			for frame in 90:
				await tree.physics_frame
				player.velocity = Vector3(4.0, 0.0 if player.is_on_floor() else player.velocity.y - 9.8 / 60.0, 0.0)
				player.move_and_slide()
			assert_true(player.global_position.x < 78.9 and player.global_position.y > level - 0.1,
				"the railing stops the player at z %.0f over %.1f (%s)" % [z, level, player.global_position])


func test_zombie_routes_from_the_spawns_reach_floor_three() -> void:
	await _campus(true)
	library.get_node("BackDoor").set_open(true)
	await tree.create_timer(0.4).timeout
	var map := fixture.get_world_3d().navigation_map
	for spawn: Node3D in campus.get_node("Anchors/Ch4/LibraryZombieSpawn").get_children():
		for to: Vector3 in [Vector3(65, -3.3, 211), Vector3(60.2, -6.6, 216), Vector3(60, G, 207.5)]:
			var path := NavigationServer3D.map_get_path(map, spawn.global_position, to, true)
			assert_true(path.size() >= 2 and path[-1].distance_to(to) < 0.15, "route %s -> %s" % [spawn.name, to])
			if path.size() < 2:
				continue
			for i in range(path.size() - 1):
				var n := maxi(1, ceili(path[i].distance_to(path[i + 1]) / 0.2))
				for k in n + 1:
					var p := path[i].lerp(path[i + 1], float(k) / n)
					if FOOTPRINT.grow(-0.3).has_point(Vector2(p.x, p.z)) and not _clear(p):
						assert_true(false, "the route %s -> %s blocked at %s" % [spawn.name, to, p])
						return


# ---------------------------------------------------------------------------------------------- the ring of ground, props

func test_strip_stays_in_the_box_off_the_floor() -> void:
	await _campus()
	var ground := _vertices(campus.get_node("StripLibrary"))
	assert_true(ground.size() > 100, "verge, aprons, drains, forecourt")
	for v in ground:
		var ok := ZONE.grow(0.02).has_point(v) and not FOOTPRINT.grow(-0.01).has_point(Vector2(v.x, v.z))
		if not ok:
			assert_true(false, "strip vertex %s in wave 8's box, off the library's floor" % v)
			return
	# The six spawn points stay clear (no collider of this wave there).
	for spawn: Node3D in campus.get_node("Anchors/Ch4/LibraryZombieSpawn").get_children():
		assert_true(_clear(spawn.global_position), "spawn %s clear" % spawn.name)


func test_props_in_the_box_untouched() -> void:
	var props := PROPS.instantiate()
	var count := 0
	for group in ["Parts", "Decals"]:
		for chunk in props.get_node(group).get_children():
			var data: PackedFloat32Array = chunk.get("data") if chunk.get("data") != null else PackedFloat32Array()
			for k in range(0, data.size(), 16):
				var at := Vector3(data[k + 9], data[k + 10], data[k + 11])
				if ZONE.has_point(at):
					count += 1
					assert_false(data[k] == 0.0 and data[k + 4] == 0.0 and data[k + 8] == 0.0, "%s/%s #%d in the box keeps its size" % [group, chunk.name, k / 16])
	assert_eq(count, 52, "props.tscn's 52 pieces in the box (2 rubble piles, papers), none scaled to 0")
	props.free()

# ---------------------------------------------------------------------------------------------- assets

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
	assert_true(count >= 12, "wave 8 textures found (%d)" % count)


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
		print("T265_TRIANGLES %s %d" % [glb, own])
		triangles += own
		root.free()
	print("T265_TRIANGLES total %d" % triangles)
