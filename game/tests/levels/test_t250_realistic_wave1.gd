extends TestCase
## T-250 (D-166) wave 1: the duty desk (A01), the fire stairs and their door (A07) and the main stairs (A06) look
## real, and gameplay sees exactly what it saw: the same colliders, markers and names; the fire door still swings
## (its lock and handle ride on the leaf); the key drawer slides on its own; every visible tread lies on its
## collision ramp at its centre (within 2 cm), and no new rubble or rail reaches into a walkable space.

const FLOOR := preload("res://scenes/levels/floor4/floor4.tscn")
const CAMPUS := preload("res://scenes/levels/campus/campus.tscn")
## Every collider of the two stairwells, the fire door and the duty desk as main had them before T-250
## (_collider_print below, recorded on main ee05aa5).
const COLLIDERS_MD5 := "c666d1adfd7714eb34419cd58fe46459"
## Markers and anchors directors and tests look up (positions as main has them).
const CAMPUS_ANCHORS := {"FireKey": Vector3(39.8, 0.66, 0.42), "FireDoor": Vector3(44, 0, 2), "Collapse2F": Vector3(46.5, -6.6, -1),
	"Clues/Clock4F": Vector3(40, 2.05, 0.18), "Clues/CrackStair": Vector3(49, -2, -3)}
const BUILDING_NODES := {"DeskClock": Vector3(40, 2.05, 0.18), "KeyStem": Vector3(39.8, 0.66, 0.42),
	"KeyTooth": Vector3(39.85, 0.66, 0.44), "StairCrack": Vector3(48.88, -0.4, -3), "FireRubbleDetail": Vector3(22, 0, 0),
	"UpperRubbleDetail": Vector3.ZERO, "Handrail_-4.9_0": Vector3(-4.9, -0.1, -2.4), "Handrail_48.9_-3.3": Vector3(48.9, -3.4, -2.4),
	"FireDoor": Vector3(44, 0, 2), "FireDoor/Leaf": Vector3(44, 1.2, 3.9)}
const FLOOR_NODES: Array[String] = ["DutyDesk/Desk", "DutyDesk/Desk/Collision", "DutyDesk/Desk/Model", "DutyDesk/DeskItems",
	"DutyDesk/DeskTelephone", "DutyDesk/DutyStool", "DutyDesk/HallBoard", "DutyDesk/Speaker", "DutyDesk/DutyDeskLamp",
	"DutyDesk/DutyDeskLamp/Fixture", "DutyDesk/SpeakerIdle", "DutyDesk/ReverbZone", "DutyDesk/AmbientZone",
	"Anchors/HallBoard", "Anchors/DutyLog", "Anchors/Speaker"]
## Flights of build_campus.py stairs(): side, upper floor, letter (Fire has no 2A/2B: collapsed).
const FLIGHT_KEYS := [["Main", 4, "A"], ["Main", 4, "B"], ["Main", 3, "A"], ["Main", 3, "B"], ["Main", 2, "A"], ["Main", 2, "B"],
	["Fire", 4, "A"], ["Fire", 4, "B"], ["Fire", 3, "A"], ["Fire", 3, "B"]]
var FLIGHTS: Array[Array] = []
var fixtures: Array[Node] = []


func before_each() -> void:
	# The same float arithmetic as build_campus.py (Fire 3B's 1.65 m comes out a hair over, so 12 treads).
	if not FLIGHTS.is_empty():
		return
	for key: Array in FLIGHT_KEYS:
		var x0 := -5.0 if key[0] == "Main" else 44.0
		var y := (int(key[1]) - 4) * 3.3
		if key[2] == "A":
			FLIGHTS.append([key[0], "%dA" % key[1], x0 + 0.12, x0 + 2.28, 0.0, -4.8, y, y - 1.65])
		else:
			FLIGHTS.append([key[0], "%dB" % key[1], x0 + 2.72, x0 + 4.88, -4.8, 0.0, y - 1.65, y - 3.3])


func after_each() -> void:
	for node in fixtures:
		if is_instance_valid(node):
			node.queue_free()
	fixtures.clear()
	await wait_frames(2)


func _spawn_floor() -> Node3D:
	var floor4 := FLOOR.instantiate() as Node3D
	fixtures.append(floor4)
	tree.root.add_child(floor4)
	return floor4


func _spawn_campus() -> Node3D:
	var campus := CAMPUS.instantiate() as Node3D
	fixtures.append(campus)
	tree.root.add_child(campus)
	return campus


func _collider_print(campus: Node3D, floor4: Node3D) -> String:
	var rows: Array[String] = []
	var roots: Array[Node] = [campus.get_node("BuildingB/MainStairs"), campus.get_node("BuildingB/FireStairs"),
		campus.get_node("BuildingB/FireDoor"), floor4.get_node("DutyDesk/Desk")]
	for root: Node in roots:
		var nodes: Array[Node] = root.find_children("*", "CollisionShape3D", true, false)
		for node: Node in nodes:
			var shape_node := node as CollisionShape3D
			var body := shape_node.get_parent() as CollisionObject3D
			var shape := shape_node.shape
			var params := ""
			if shape is BoxShape3D:
				params = str((shape as BoxShape3D).size.snappedf(0.0001))
			elif shape is ConvexPolygonShape3D:
				for p: Vector3 in (shape as ConvexPolygonShape3D).points:
					params += str(p.snappedf(0.0001))
			var origin := shape_node.global_transform.origin.snappedf(0.0001)
			rows.append("%s|%s|%s|%s|%d|%d" % [String(root.get_path_to(node)), origin, shape.get_class(), params,
				body.collision_layer if body else -1, body.collision_mask if body else -1])
	rows.sort()
	return "\n".join(rows)


func test_colliders_markers_and_names_are_main_s() -> void:
	var floor4 := _spawn_floor()
	var campus := _spawn_campus()
	await wait_frames(2)
	var print_text := _collider_print(campus, floor4)
	print("T250 COLLIDERS md5=%s rows=%d" % [print_text.md5_text(), print_text.count("\n") + 1])
	assert_eq(print_text.md5_text(), COLLIDERS_MD5, "stairwell, fire door and desk colliders exactly as on main")
	for key: String in CAMPUS_ANCHORS:
		var anchor: Node3D = campus.get_anchor(key)
		assert_not_null(anchor, "anchor " + key)
		if anchor:
			assert_true(anchor.global_position.is_equal_approx(CAMPUS_ANCHORS[key]), "%s at %s" % [key, anchor.global_position])
	for path: String in BUILDING_NODES:
		var node := campus.get_node_or_null("BuildingB/" + path) as Node3D
		assert_not_null(node, "kept " + path)
		if node:
			assert_true(node.global_position.is_equal_approx(BUILDING_NODES[path]), "%s at %s" % [path, node.global_position])
	assert_eq(campus.get_node("BuildingB/DeskClock").get_meta(&"stopped_hour"), 4, "clock clue stopped at 4")
	for path: String in FLOOR_NODES:
		assert_not_null(floor4.get_node_or_null(path), "kept " + path)
	assert_true(floor4.get_node("DutyDesk/SpeakerIdle") is AmbientEmitter, "idle speaker sound stays")
	assert_true(floor4.get_node("DutyDesk/Desk/Collision").shape is BoxShape3D)


func test_duty_desk_drawer_slides_on_its_own_and_holds_the_key() -> void:
	var floor4 := _spawn_floor()
	var campus := _spawn_campus()
	await wait_frames(2)
	var desk := floor4.get_node("DutyDesk")
	var drawer := floor4.get_node_or_null("DutyDesk/Desk/Model/KeyDrawer") as Node3D
	var carcass := floor4.get_node_or_null("DutyDesk/Desk/Model/Carcass") as Node3D
	assert_not_null(drawer, "the key drawer is a node of its own")
	assert_not_null(carcass, "the desk body")
	if drawer == null or carcass == null:
		return
	assert_false(drawer.is_ancestor_of(carcass) or carcass.is_ancestor_of(drawer), "drawer and body are separate")
	var shut := drawer.global_position
	var body := carcass.global_position
	desk.call("set_drawer_open", 1.0)
	assert_true((drawer.global_position - shut).is_equal_approx(Vector3(0, 0, 0.34)), "slides 0.34 m out along +Z")
	assert_true(carcass.global_position.is_equal_approx(body), "the body stays")
	desk.call("set_drawer_open", 0.0)
	assert_true(drawer.global_position.is_equal_approx(shut), "and back")
	# The new desk keeps inside the PS1 desk's collision box (handles 1-2 cm proud of its front).
	var box := _bounds(carcass)
	assert_true(box.position.x > 39.24 and box.end.x < 40.76 and box.position.z > 0.09 and box.end.z < 0.77 and box.end.y < 0.81,
		"desk inside its collider: %s" % box)
	# The fire key lies on the drawer's bottom, inside the drawer.
	var key := campus.get_node_or_null("BuildingB/KeyStem/Model") as Node3D
	assert_not_null(key, "the real key")
	if key:
		var kbox := _bounds(key)
		var dbox := _bounds(drawer)
		assert_true(absf(kbox.position.y - 0.650) < 0.004, "key on the drawer bottom: %s" % kbox)
		assert_true(dbox.grow(0.001).encloses(kbox), "key inside the drawer: %s in %s" % [kbox, dbox])
	assert_false(campus.get_node("BuildingB/KeyStem/Mesh").visible, "PS1 key hidden")


func test_fire_door_swings_with_lock_handle_and_second_leaf() -> void:
	var campus := _spawn_campus()
	await wait_frames(2)
	var door := campus.get_node("BuildingB/FireDoor") as Node3D
	var leaf := door.get_node("Leaf") as StaticBody3D
	var leaf_b := door.get_node_or_null("LeafB") as Node3D
	var lock := door.get_node_or_null("Leaf/Lock") as Node3D
	var handle := door.get_node_or_null("Leaf/Handle") as Node3D
	assert_not_null(leaf_b, "second leaf")
	assert_not_null(lock, "lock on the leaf")
	assert_not_null(handle, "handle on the leaf")
	assert_not_null(door.get_node_or_null("Leaf/Model"), "steel leaf")
	assert_not_null(door.get_node_or_null("Frame"), "frame")
	if leaf_b == null or lock == null or handle == null:
		return
	assert_true(leaf_b.find_children("*", "CollisionObject3D", true, false).is_empty(), "second leaf is visual only")
	assert_false(leaf.get_node("Mesh").visible, "PS1 slab hidden")
	# Shut: both leaves fill the opening z 0.1 .. 3.9 within the old slab's thickness, the lock near the middle.
	var a := _bounds(door.get_node("Leaf/Model"))
	var b := _bounds(leaf_b)
	assert_true(a.position.z > 1.95 and a.end.z < 3.92 and b.position.z > 0.11 and b.end.z < 2.06, "leaves span the opening: %s %s" % [a, b])
	assert_true(absf(a.get_center().x - 44.0) < 0.07 and absf(b.get_center().x - 44.0) < 0.07, "leaves in the door plane")
	var lock_local := leaf.global_transform.affine_inverse() * lock.global_position
	var handle_local := leaf.global_transform.affine_inverse() * handle.global_position
	assert_true(lock.global_position.distance_to(Vector3(44, 0.978, 2.03)) < 0.05, "lock by the meeting edge: %s" % lock.global_position)
	assert_true(handle.global_position.distance_to(Vector3(44, 1.05, 2.03)) < 0.05, "handle at 1.05 m: %s" % handle.global_position)
	var use_box := AABB(Vector3(44 - 0.7, 0.0, 2 - 0.7), Vector3(1.4, 2.2, 1.4))
	assert_true(use_box.has_point(lock.global_position) and use_box.has_point(handle.global_position), "inside Use_FireDoor's box")
	campus.set_fire_door_open(true)
	assert_eq(leaf.collision_layer, 0)
	assert_true(is_equal_approx(leaf.rotation.y, PI / 2.0) and is_equal_approx(leaf_b.rotation.y, -PI / 2.0), "both leaves swing")
	assert_true((leaf.global_transform.affine_inverse() * lock.global_position).is_equal_approx(lock_local), "lock rides on the leaf")
	assert_true((leaf.global_transform.affine_inverse() * handle.global_position).is_equal_approx(handle_local), "handle rides on the leaf")
	# Open: both leaves lie flat into the corridor, against its rail and its wall, clear of the opening.
	a = _bounds(door.get_node("Leaf/Model"))
	b = _bounds(leaf_b)
	assert_true(a.end.x < 44.06 and a.position.x > 42.0 and a.position.z > 3.85 and a.end.z < 3.96, "leaf A along the rail: %s" % a)
	assert_true(b.end.x < 44.06 and b.position.x > 42.15 and b.position.z > 0.1 and b.end.z < 0.2, "leaf B along the wall: %s" % b)
	campus.set_fire_door_open(false)
	assert_eq(leaf.collision_layer, 1)
	assert_true(is_zero_approx(leaf_b.rotation.y), "second leaf shuts too")


func _bounds(node: Node) -> AABB:
	var box := AABB()
	var first := true
	var meshes: Array[Node] = node.find_children("*", "MeshInstance3D", true, false)
	if node is MeshInstance3D:
		meshes.append(node)
	for mesh: MeshInstance3D in meshes:
		var b: AABB = mesh.global_transform * mesh.get_aabb()
		box = b if first else box.merge(b)
		first = false
	return box


## World triangles of the new stairwell meshes, bucketed by 0.25 m cells in x/z for downward sampling.
func _triangles(root: Node3D) -> Dictionary:
	var cells := {}
	for mesh: MeshInstance3D in root.find_children("*", "MeshInstance3D", true, false):
		if not mesh.is_visible_in_tree():
			continue
		var faces := mesh.mesh.get_faces()
		var xf := mesh.global_transform
		for i in range(0, faces.size(), 3):
			var a := xf * faces[i]
			var b := xf * faces[i + 1]
			var c := xf * faces[i + 2]
			var lo := Vector2(minf(a.x, minf(b.x, c.x)), minf(a.z, minf(b.z, c.z)))
			var hi := Vector2(maxf(a.x, maxf(b.x, c.x)), maxf(a.z, maxf(b.z, c.z)))
			for cx in range(floori(lo.x / 0.25), floori(hi.x / 0.25) + 1):
				for cz in range(floori(lo.y / 0.25), floori(hi.y / 0.25) + 1):
					var key := Vector2i(cx, cz)
					if not cells.has(key):
						cells[key] = []
					(cells[key] as Array).append([a, b, c])
	return cells


func _visible_top(cells: Dictionary, x: float, z: float, below: float) -> float:
	var best := -INF
	var key := Vector2i(floori(x / 0.25), floori(z / 0.25))
	for tri: Array in cells.get(key, []):
		var hit: Variant = Geometry3D.ray_intersects_triangle(Vector3(x, below, z), Vector3.DOWN, tri[0], tri[1], tri[2])
		if hit != null:
			best = maxf(best, (hit as Vector3).y)
	return best


func test_visible_treads_lie_on_the_collision_ramps() -> void:
	var campus := _spawn_campus()
	await tree.physics_frame
	await tree.physics_frame
	var space := campus.get_world_3d().direct_space_state
	var worst := 0.0
	var samples := 0
	# Each tread against its own ramp: the Collapse box (main's, kept) stands up to 14 cm over flight 3A's last
	# treads, and the debris drawn there is checked in test_rubble_and_broken_flights_stay_out_of_reach.
	var ramps_only: Array[RID] = [(campus.get_node("BuildingB/FireStairs/Collapse") as CollisionObject3D).get_rid()]
	for side: String in ["Main", "Fire"]:
		var stairs := campus.get_node_or_null("BuildingB/%sStairs/W1Stairs" % side) as Node3D
		assert_not_null(stairs, side + " stairwell model")
		if stairs == null:
			continue
		var cells := _triangles(stairs)
		for flight: Array in FLIGHTS:
			if flight[0] != side:
				continue
			var y0: float = flight[6]
			var y1: float = flight[7]
			var n := maxi(4, ceili(absf(y1 - y0) / 0.15))
			for i in n:
				var t := (i + 0.5) / n
				var z: float = lerpf(flight[4], flight[5], t)
				for x: float in [lerpf(flight[2], flight[3], 0.3), lerpf(flight[2], flight[3], 0.7)]:
					var top := _visible_top(cells, x, z, lerpf(y0, y1, t) + 0.5)
					var query := PhysicsRayQueryParameters3D.create(Vector3(x, top + 0.5, z), Vector3(x, top - 1.0, z), 1, ramps_only)
					var hit := space.intersect_ray(query)
					assert_false(hit.is_empty(), "%s %s tread %d has its ramp under it" % [side, flight[1], i])
					if hit.is_empty():
						continue
					var gap := absf(top - (hit.position as Vector3).y)
					worst = maxf(worst, gap)
					samples += 1
					assert_true(gap <= 0.02, "%s %s tread %d: visible %.3f, collision %.3f" % [side, flight[1], i, top, (hit.position as Vector3).y])
		# Landings and turns: the terrazzo top is the collision top.
		var x0 := -5.0 if side == "Main" else 44.0
		for y: float in [0.0, -3.3, -6.6, -9.9]:
			var top := _visible_top(cells, x0 + 2.5, 2.0, y + 0.5)
			assert_true(absf(top - y) <= 0.005, "%s landing at %.1f: %.3f" % [side, y, top])
	print("T250 TREADS samples=%d worst=%.4f m" % [samples, worst])
	assert_true(samples >= 200, "every tread sampled (%d)" % samples)


## Walkable volumes near the new rubble and broken flights (floor landings and flights, head height above them).
func _walk_volumes() -> Array[Array]:
	var result: Array[Array] = []
	for x0: float in [-5.0, 44.0]:
		for y: float in [0.0, -3.3, -6.6, -9.9]:
			result.append(["box", AABB(Vector3(x0 + 0.05, y + 0.02, 0.05), Vector3(4.9, 1.9, 3.9))])
	for flight: Array in FLIGHTS:
		result.append(["ramp", flight])
	return result


func test_rubble_and_broken_flights_stay_out_of_reach() -> void:
	var campus := _spawn_campus()
	await wait_frames(2)
	var volumes := _walk_volumes()
	for side: String in ["Main", "Fire"]:
		var stairs := campus.get_node_or_null("BuildingB/%sStairs/W1Stairs" % side) as Node3D
		if stairs == null:
			assert_true(false, side + " stairwell model")
			continue
		for part: String in ["Upper", "Rubble"]:
			var mesh := stairs.find_child(part, true, false) as MeshInstance3D
			if mesh == null:
				continue
			var offending := 0
			var example := Vector3.ZERO
			for surface in mesh.mesh.get_surface_count():
				for vertex: Vector3 in mesh.mesh.surface_get_arrays(surface)[Mesh.ARRAY_VERTEX] as PackedVector3Array:
					var p := mesh.global_transform * vertex
					for volume: Array in volumes:
						var inside := false
						if volume[0] == "box":
							inside = (volume[1] as AABB).has_point(p)
						else:
							var f: Array = volume[1]
							var t := inverse_lerp(f[4], f[5], p.z)
							if t >= 0.0 and t <= 1.0 and p.x > float(f[2]) + 0.02 and p.x < float(f[3]) - 0.02:
								var floor_y := lerpf(f[6], f[7], t)
								inside = p.y > floor_y + 0.05 and p.y < floor_y + 1.9
						if inside:
							offending += 1
							example = p
							break
			assert_eq(offending, 0, "%s %s out of every walkable space (e.g. %s)" % [side, part, example])
	# The debris on fire flight 3A's last treads shows the Collapse box's top there: inside the box's footprint,
	# never above its top (y -4.6), so a foot meets it where the collider is.
	var spill := campus.get_node("BuildingB/FireStairs/W1Stairs").find_child("Spill", true, false) as MeshInstance3D
	assert_not_null(spill, "debris over the box's bump on flight 3A")
	if spill:
		var box := spill.global_transform * spill.get_aabb()
		var footprint := AABB(Vector3(44.0, -5.0, -4.25), Vector3(2.3, 0.405, 0.5))
		assert_true(footprint.encloses(box), "spill inside the Collapse box over 3A: %s" % box)
