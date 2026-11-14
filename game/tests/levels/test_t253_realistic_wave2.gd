extends TestCase
## T-253 (D-167) wave 2: building B's floors 1-3 (corridors, rooms seen through doors, room 203, the lobby, the
## manager's room and window, the main door) and the fire kit (extinguisher, alarm model) rebuilt in wave 1's style.
## Visual only: every collider and every node that was in building_b.tscn on main keeps its place (prints recorded
## on main 1c66187); the new models have no collider, stay out of the corridors' walkway, stand inside the PS1
## bodies they draw, and the doors, plates, window steps, extinguisher and alarm are built so that the actions of
## T-247 (rows 7, 8, 10) can be added later.

const BUILDING := preload("res://scenes/levels/campus/building_b.tscn")
const ALARM := "res://assets/models/graphics_pilot/realistic_map/wave2/fire_alarm.glb"
## Prints of main's building_b.tscn (1c66187; collider_rows: 331 rows, node_rows: 2216 rows, over a fresh instance).
## Swapping the lower floors' wall_door kit for another model would drop its 72 doorway colliders: the kit stays.
## T-258 split MainStairs' east wall box on purpose (floor 4 beside the washroom stops at x 0.1; checked in
## test_t258_main_stairs_wall.gd): Wall0.08000000000000007 (body, Collision, Mesh) moved from centre y -4 / 13.5 high
## to y -5.375 / 10.75 high, and EastWall4, EastWall4Back (body, Collision, Mesh each) were added; every other row is
## main's (was b3bd51f1f869a37863e36a6d5bea1c23 / 331 rows and eba52505effdec29d159f136d8b467dd / 2216 rows).
const COLLIDERS_MD5 := "4563095cff01942e4fe085fa191ae3dc"
const NODES_MD5 := "976f35d09f7d4a855e9601be37b849a7"
## Left out of the node print, on main and now alike: the models hung under building B's nodes (wave 1's and
## wave 2's: Model, Surround, Frame and LeafB children) and wave 2's own nodes.
const ADDED_NAMES: Array[String] = ["W2Hall", "W2Rooms", "Room203Furnished", "Room203Leaf", "F1BrokenDoors",
	"ManagerDeskModel", "ManagerDoorLeaf", "W2ManagerWindow", "W2ManagerRoom", "W2Lobby", "ExtinguisherBracket",
	"Model", "Surround", "Frame", "LeafB"]
const FLOORS := {1: -9.9, 2: -6.6, 3: -3.3}
var building: Node3D


func before_each() -> void:
	building = BUILDING.instantiate() as Node3D
	tree.root.add_child(building)
	await tree.physics_frame
	await tree.physics_frame


func after_each() -> void:
	building.queue_free()
	await wait_frames(2)


static func is_added(path: String) -> bool:
	for part: String in path.split("/"):
		if part in ADDED_NAMES:
			return true
	return false


## Every collision shape in the scene: path, place, shape, its body's layer and mask.
static func collider_rows(root: Node3D) -> PackedStringArray:
	var rows: PackedStringArray = []
	for node: Node in root.find_children("*", "CollisionShape3D", true, false):
		var shape_node := node as CollisionShape3D
		var body := shape_node.get_parent() as CollisionObject3D
		var shape := shape_node.shape
		var params := ""
		if shape is BoxShape3D:
			params = str((shape as BoxShape3D).size.snappedf(0.0001))
		elif shape is ConvexPolygonShape3D:
			for p: Vector3 in (shape as ConvexPolygonShape3D).points:
				params += str(p.snappedf(0.0001))
		elif shape != null:
			params = shape.get_class()
		var xf := shape_node.global_transform
		rows.append("%s|%s|%s|%s|%s|%d|%d|%s" % [String(root.get_path_to(node)), xf.origin.snappedf(0.0001),
			xf.basis.get_euler().snappedf(0.001), shape.get_class() if shape else "-", params,
			body.collision_layer if body else -1, body.collision_mask if body else -1, str(shape_node.disabled)])
	rows.sort()
	return rows


## Every node of building B but the models hung on it: path, class, global place. The plates' Number labels and
## the room doors' Hinge (with its Leaf) keep their path and class; wave 2 restyles the labels and moves each
## RoomDoor's visual pivot onto its doorway's edge (x + 0.45, as floor 4's), its Blocker and collision unmoved.
static func node_rows(root: Node3D) -> PackedStringArray:
	var rows: PackedStringArray = []
	for node: Node in root.find_children("*", "", true, true):
		var path := String(root.get_path_to(node))
		if is_added(path):
			continue
		var row := "%s|%s" % [path, node.get_class()]
		if node is Node3D and not (node is Label3D) and not "/Hinge" in path:
			var xf := (node as Node3D).global_transform
			row += "|%s|%s" % [xf.origin.snappedf(0.0001), xf.basis.get_euler().snappedf(0.001)]
		rows.append(row)
	rows.sort()
	return rows


func test_colliders_and_main_nodes_are_main_s() -> void:
	var colliders := "\n".join(collider_rows(building))
	var nodes := "\n".join(node_rows(building))
	print("T253 COLLIDERS md5=%s rows=%d NODES md5=%s rows=%d" % [colliders.md5_text(), colliders.count("\n") + 1,
		nodes.md5_text(), nodes.count("\n") + 1])
	assert_eq(colliders.md5_text(), COLLIDERS_MD5, "every collider of building B exactly as on main")
	assert_eq(nodes.md5_text(), NODES_MD5, "every node of main's building B there, in its place")


func _added_roots() -> Array[Node]:
	var result: Array[Node] = []
	for node: Node in building.find_children("*", "", true, true):
		var path := String(building.get_path_to(node))
		if is_added(path) and not is_added(path.get_base_dir()):
			result.append(node)
	return result


func test_new_models_have_no_colliders_and_hide_only_ps1_meshes() -> void:
	var roots := _added_roots()
	assert_true(roots.size() >= 60, "wave-2 models hung (%d)" % roots.size())
	for root: Node in roots:
		assert_true(root.find_children("*", "CollisionObject3D", true, false).is_empty(), "%s has no collider" % building.get_path_to(root))
		assert_false(root is CollisionObject3D, "%s is no body" % building.get_path_to(root))
	for floor_number: int in [1, 2, 3]:
		var floor_node := building.get_node("Floor%d" % floor_number)
		for name: String in ["W2Hall", "W2Rooms"]:
			var model := floor_node.get_node_or_null(name) as Node3D
			assert_true(model != null and model.is_visible_in_tree(), "Floor%d/%s shows" % [floor_number, name])
		var kit := building.get_node("KitDetail%d" % floor_number)
		for i in 8:
			assert_false((kit.get_node("RailingTop%d" % i) as Node3D).visible, "PS1 rail top %d hidden" % i)
			assert_false((kit.get_node("Tube%d" % i) as Node3D).visible, "PS1 tube %d hidden" % i)
			assert_false((kit.get_node("Plate%d/Mesh" % i) as Node3D).visible, "PS1 plate %d hidden" % i)
		for light: Node in kit.find_children("Light*", "OmniLight3D", false, false):
			assert_true((light as Node3D).is_visible_in_tree(), "%s still lights the corridor" % light.name)
		assert_eq(kit.find_children("Light*", "OmniLight3D", false, false).size(), 5, "five corridor lights")
		# Every PS1 wall, slab and ceiling box keeps its mesh: the new plaster stands 3 mm in front of it.
		for name: String in ["Slab", "Ceiling", "Facade0L", "Lintel3", "Partition6"]:
			assert_true((floor_node.get_node(name + "/Mesh") as Node3D).visible, "Floor%d/%s mesh kept" % [floor_number, name])


## Walkways: each corridor between the room wall and the rail from the floor to just under the beams, the room
## doors' passages; no new vertex may stand in them (doors are checked shut; plates, frames, skirting and the rail's
## curb stay at their walls).
func test_corridors_keep_their_walkway_clear() -> void:
	var worst := ""
	for floor_number: int in [1, 2, 3]:
		var y: float = FLOORS[floor_number]
		var walk := AABB(Vector3(0.05, y + 0.02, 0.12), Vector3(43.9, 2.55, 3.78))
		for root: Node in _added_roots():
			for mesh: MeshInstance3D in _meshes(root):
				var xf := mesh.global_transform
				for v: Vector3 in mesh.mesh.get_faces():
					var p := xf * v
					if walk.has_point(p):
						worst = "%s at %s" % [building.get_path_to(mesh), p]
						break
	assert_eq(worst, "", "no new vertex in a corridor's walkway")


func _meshes(root: Node) -> Array[MeshInstance3D]:
	var result: Array[MeshInstance3D] = []
	if root is MeshInstance3D:
		result.append(root as MeshInstance3D)
	for node: Node in root.find_children("*", "MeshInstance3D", true, false):
		result.append(node as MeshInstance3D)
	return result


func _bounds(node: Node) -> AABB:
	var box := AABB()
	var first := true
	for mesh: MeshInstance3D in _meshes(node):
		var b: AABB = mesh.global_transform * mesh.get_aabb()
		box = b if first else box.merge(b)
		first = false
	return box


func test_room_doors_swing_their_two_leaves_and_shut_doors_stay() -> void:
	var count := 0
	for floor_number: int in [2, 3]:
		for i in 8:
			var door := building.get_node_or_null("Floor%d/Door%d" % [floor_number, i]) as RoomDoor
			if floor_number == 2 and i == 2:
				assert_true(door == null, "203 has no door")
				continue
			assert_not_null(door, "room door %d%02d" % [floor_number, i + 1])
			var leaf := door.get_node("Hinge/Leaf") as Node3D
			assert_false((leaf.get_node("Mesh") as Node3D).visible, "PS1 leaf hidden")
			assert_true(is_equal_approx((door.get_node("Hinge") as Node3D).position.x, 0.45), "%s pivots on the doorway's edge" % door.room)
			var shut := _bounds(leaf.get_node("Model"))
			# Shut, the leaf fills the kit's 0.9 m doorway (x +/- 0.45) inside its 20 cm reveal.
			var x := door.global_position.x
			assert_true(shut.position.x > x - 0.455 and shut.end.x < x + 0.455 and shut.size.x > 0.88, "%s leaf fills the doorway (%s)" % [door.room, shut])
			assert_true(shut.position.z > -0.1 and shut.end.z < 0.2, "%s leaf stands in the reveal" % door.room)
			count += 1
		await wait_frames(1)
	assert_eq(count, 15, "15 room doors")
	var door := building.get_node("Floor2/Door6") as RoomDoor
	var model := door.get_node("Hinge/Leaf/Model") as Node3D
	var before := _bounds(model)
	door.set_open(true)
	await tree.create_timer(0.5).timeout
	var after := _bounds(model)
	# 207 (the hideout) swings out into the corridor from the doorway's edge, flat by the east jamb.
	assert_true(after.end.z > 0.85 and after.position.x > 35.75 + 0.4 and after.end.x < 35.75 + 0.6, "207 open by its jamb (%s)" % after)
	door.set_open(false)
	await tree.create_timer(0.5).timeout
	assert_true(_bounds(model).position.is_equal_approx(before.position), "and shuts again")
	for i: int in [2, 5, 7]:
		var shut_door := building.get_node("Floor1/Door%d" % i) as StaticBody3D
		assert_eq(shut_door.collision_layer, 1, "floor-1 door %d still shuts its room" % i)
		var box := _bounds(shut_door.get_node("Model"))
		assert_true(absf(box.get_center().x - shut_door.global_position.x) < 0.02 and box.size.x > 0.88, "door %d drawn in its doorway" % i)
	for frame: Node in building.find_children("Frame?", "", true, false):
		if not String(frame.get_parent().name).begins_with("KitDetail"):
			continue
		assert_false((frame.get_node("wall_door") as Node3D).visible, "%s kit mesh hidden" % frame.name)
		assert_eq((frame.get_node("WorldCollision") as StaticBody3D).collision_layer, 1, "%s kit collision kept" % frame.name)
		assert_true((frame.get_node("Surround") as Node3D).is_visible_in_tree(), "%s new surround" % frame.name)


func test_plates_print_their_room_numbers_on_aluminium() -> void:
	for floor_number: int in [1, 2, 3]:
		for i in 8:
			var plate := building.get_node("KitDetail%d/Plate%d" % [floor_number, i]) as Node3D
			var label := plate.get_node("Number") as Label3D
			assert_eq(label.text, str(floor_number * 100 + i + 1), "plate %d%02d" % [floor_number, i + 1])
			var model := plate.get_node_or_null("Model") as Node3D
			assert_true(model != null and model.is_visible_in_tree(), "aluminium plate %s" % label.text)
			if model:
				var box := _bounds(model)
				assert_true(label.global_position.z > box.end.z - 0.0012, "%s printed on the plate's face" % label.text)
				assert_true(box.has_point(Vector3(label.global_position.x, label.global_position.y, box.get_center().z)), "%s centred on it" % label.text)
			var frame := _bounds(building.get_node("KitDetail%d/Frame%d" % [floor_number, i]))
			assert_true(frame.size.x > 1.8 and frame.size.y > 2.5, "door surround %d%02d" % [floor_number, i + 1])


## Room furniture: the light bunks and lockers inside the PS1 RoomInterior bodies' envelope, room 203's room-407
## furniture inside Room203BedBody / Room203DeskBody and out of 203's nav areas (but for flat things).
func test_room_furniture_stays_inside_its_bodies() -> void:
	for floor_number: int in [2, 3]:
		var envelopes: Array[AABB] = []
		for room: Node in building.get_node("Floor%d" % floor_number).find_children("RoomInterior_*", "", false, true):
			var bunk := AABB()
			var first := true
			for body: Node in room.get_children():
				var shape := (body.get_node("Collision") as CollisionShape3D)
				var size := (shape.shape as BoxShape3D).size
				var box := AABB(shape.global_position - size / 2, size)
				if String(body.name) == "Locker":
					envelopes.append(box.grow(0.02))
				else:
					bunk = box if first else bunk.merge(box)
					first = false
			envelopes.append(AABB(Vector3(bunk.position.x, bunk.position.y - 0.4, bunk.position.z), bunk.size + Vector3(0, 0.4, 0)).grow(0.02))
		var rooms := building.get_node("Floor%d/W2Rooms" % floor_number)
		var loose := 0
		var checked := 0
		for mesh: MeshInstance3D in _meshes(rooms):
			for s in mesh.mesh.get_surface_count():
				var mat := mesh.get_active_material(s)
				if mat == null or not mat.resource_name in ["W2BunkPaint", "W2LockerPaint", "W2Mattress", "W2Chieu", "W2Pillow", "W1WoodPale"]:
					continue
				var arrays := mesh.mesh.surface_get_arrays(s)
				for v: Vector3 in arrays[Mesh.ARRAY_VERTEX]:
					var p := mesh.global_transform * v
					checked += 1
					if not envelopes.any(func(e: AABB) -> bool: return e.has_point(p)):
						loose += 1
		assert_true(checked > 1000, "floor %d furniture checked (%d)" % [floor_number, checked])
		assert_eq(loose, 0, "floor %d bunks and lockers inside their bodies" % floor_number)
	var bed := _body_box("Room203BedBody").grow(0.03)
	var desk := _body_box("Room203DeskBody").grow(0.03)
	var furnished := building.get_node("Room203Furnished")
	for name: String in ["BunkFrame", "MattressLow", "MattressHigh", "PillowLow", "PillowHigh", "BlanketLow", "BlanketHigh"]:
		var box := _bounds(furnished.get_node(name))
		assert_true(bed.encloses(box), "203 %s inside the bed's body (%s)" % [name, box])
	var desk_box := _bounds(furnished.get_node("Desk"))
	assert_true(desk.encloses(desk_box), "203 desk inside the desk's body (%s)" % desk_box)
	for name: String in ["Books", "Notebook"]:
		var box := _bounds(furnished.get_node(name))
		var on_top := absf(box.position.y - desk_box.end.y) < 0.02
		var over := box.position.x >= desk.position.x and box.end.x <= desk.end.x and box.position.z >= desk.position.z and box.end.z <= desk.end.z
		assert_true(on_top and over, "203 %s on the desk (%s)" % [name, box])
	var nav := [AABB(Vector3(11.4, -6.6, -2.1), Vector3(4.7, 2.0, 1.7)), AABB(Vector3(13.15, -6.6, -6.8), Vector3(0.9, 2.0, 4.7))]
	for node: Node in furnished.get_children() + [building.get_node("Room203Leaf")]:
		var box := _bounds(node)
		if box.size.y < 0.12:
			continue
		for area: AABB in nav:
			assert_false(area.intersects(box), "203 %s clear of the nav area %s" % [node.name, area])
	assert_false((building.get_node("Room203Bed") as Node3D).visible, "PS1 bunk hidden")


func _body_box(name: String) -> AABB:
	var shape := building.get_node(name + "/Collision") as CollisionShape3D
	var size := (shape.shape as BoxShape3D).size
	return AABB(shape.global_position - size / 2, size)


## World triangles of a model, for downward sampling.
func _faces(root: Node) -> Array[Array]:
	var result: Array[Array] = []
	for mesh: MeshInstance3D in _meshes(root):
		var faces := mesh.mesh.get_faces()
		var xf := mesh.global_transform
		for i in range(0, faces.size(), 3):
			result.append([xf * faces[i], xf * faces[i + 1], xf * faces[i + 2]])
	return result


func _top(faces: Array[Array], x: float, z: float, from_y: float) -> float:
	var best := -INF
	for tri: Array in faces:
		var hit: Variant = Geometry3D.ray_intersects_triangle(Vector3(x, from_y, z), Vector3.DOWN, tri[0], tri[1], tri[2])
		if hit != null:
			best = maxf(best, (hit as Vector3).y)
	return best


func test_window_steps_lie_on_their_ramps_and_the_opening_is_clear() -> void:
	var window := building.get_node("W2ManagerWindow")
	var faces := _faces(window)
	var space := building.get_world_3d().direct_space_state
	var g := -9.9
	var worst := 0.0
	var samples := 0
	# Tread centres on WindowApproach (z -4.5 -> -7.2, y 0 -> 1) and WindowExit (z -8.0 -> -10.7, y 1 -> 0).
	for ramp: Array in [["WindowApproach", -4.5, -7.2, 0.0, 1.0], ["WindowExit", -8.0, -10.7, 1.0, 0.0]]:
		assert_false((building.get_node("%s/Tread00" % ramp[0]) as Node3D).visible, "PS1 treads hidden")
		for i in 7:
			var t := (i + 0.5) / 7.0
			var z: float = lerpf(ramp[1], ramp[2], t)
			for x: float in [3.5, 4.5]:
				var top := _top(faces, x, z, g + 2.0)
				var hit := space.intersect_ray(PhysicsRayQueryParameters3D.create(Vector3(x, top + 0.5, z), Vector3(x, top - 1.0, z), 1))
				assert_false(hit.is_empty(), "%s tread %d has its ramp" % [ramp[0], i])
				if hit.is_empty():
					continue
				var gap := absf(top - (hit.position as Vector3).y)
				worst = maxf(worst, gap)
				samples += 1
				assert_true(gap <= 0.02, "%s tread %d: visible %.3f, ramp %.3f" % [ramp[0], i, top, (hit.position as Vector3).y])
	print("T253 WINDOW TREADS samples=%d worst=%.4f m" % [samples, worst])
	assert_eq(samples, 28, "every tread sampled")
	# Over the sill: the bridge top is the collision top, and nothing new stands in the 1.8 m way through between
	# the sill (y 1.0, the frame's 1.5 cm bottom bar) and the head (2.44, the frame's 5 cm head bar).
	for z: float in [-7.9, -7.6, -7.3]:
		var top := _top(faces, 4.0, z, g + 2.0)
		assert_true(absf(top - (g + 1.0)) <= 0.003, "bridge top at z %.1f: %.3f" % [z, top])
	var way := AABB(Vector3(3.12, g + 1.016, -8.0), Vector3(1.76, 1.36, 0.8))
	var inside := 0
	for root: Node in _added_roots():
		for tri: Array in _faces(root):
			for p: Vector3 in tri:
				if way.has_point(p):
					inside += 1
	assert_eq(inside, 0, "the way through the window is clear")
	for k in 9:
		assert_false((building.get_node("GlassShard%d" % k) as Node3D).visible, "PS1 shard %d hidden" % k)


func test_main_door_swings_two_glass_leaves_and_hides_the_chain() -> void:
	var door := building.get_node("MainDoor")
	var leaf := door.get_node("Leaf") as StaticBody3D
	var leaf_b := door.get_node("LeafB") as Node3D
	assert_not_null(leaf.get_node_or_null("Model"), "main leaf drawn")
	assert_not_null(leaf_b.get_node_or_null("Model"), "second leaf drawn")
	assert_false((leaf.get_node("Mesh") as Node3D).visible, "PS1 slab hidden (node kept for test_campus)")
	var shut := _bounds(leaf).merge(_bounds(leaf_b))
	assert_true(shut.size.x > 2.95 and shut.size.x < 3.05, "two leaves fill the 3 m door (%s)" % shut.size)
	door.call("set_open", true)
	assert_true(is_equal_approx(leaf.rotation.y, PI / 2.0) and is_equal_approx(leaf_b.rotation.y, -PI / 2.0), "both swing in")
	var open_a := _bounds(leaf)
	var open_b := _bounds(leaf_b)
	assert_true(open_a.end.z < 4.2 and open_a.position.z < 3.0 and open_a.end.x < 17.86, "leaf against the west pier (%s)" % open_a)
	assert_true(open_b.end.z < 4.2 and open_b.position.z < 3.0 and open_b.position.x > 20.64, "LeafB against the east pier (%s)" % open_b)
	door.call("set_open", false)
	var chains := door.get_node("Chains") as Node3D
	assert_not_null(chains.get_node_or_null("Model"), "the chain")
	for child: Node in chains.get_children():
		if child.name != &"Model":
			assert_false((child as Node3D).visible, "PS1 chain %s hidden" % child.name)
	chains.visible = false
	assert_false((chains.get_node("Model") as Node3D).is_visible_in_tree(), "unchaining hides the new chain too")


func test_extinguisher_bracket_and_alarm_are_ready_for_their_actions() -> void:
	var bottle := building.get_node("FireExtinguisher") as MeshInstance3D
	assert_true(bottle.global_position.is_equal_approx(Vector3(48.86, -5.8, 2.4)), "extinguisher node in place")
	assert_eq(bottle.layers, 0, "its PS1 cone is drawn on no layer")
	var model := bottle.get_node("Model") as Node3D
	assert_true(model.is_visible_in_tree(), "the bottle shows")
	assert_not_null(model.find_child("Lever", true, false), "the squeeze lever is its own node")
	var grip := model.find_child("Grip", true, false) as Node3D
	assert_not_null(grip, "a grip point on the carry handle")
	var box := _bounds(model)
	assert_true(box.end.x < 48.997 and box.size.y > 0.5 and box.size.y < 0.65, "bottle off the wall, 4 kg size (%s)" % box)
	assert_true(AABB(Vector3(48.58, -5.9, 2.15), Vector3(0.5, 0.8, 0.5)).intersects(box), "within its use zone")
	var bracket := building.get_node("ExtinguisherBracket") as Node3D
	assert_false(bottle.is_ancestor_of(bracket), "the bracket is not part of the bottle")
	assert_true(_bounds(bracket).end.x <= 48.998, "the bracket on the wall")
	assert_false((building.get_node("ExtinguisherHandle") as Node3D).visible, "PS1 handle hidden")
	var alarm := (load(ALARM) as PackedScene).instantiate() as Node3D
	building.add_child(alarm)
	var button := alarm.find_child("Button", true, false) as Node3D
	assert_not_null(button, "the alarm's push button is its own node")
	assert_not_null(alarm.find_child("Press", true, false), "a press point on the button")
	var housing := _bounds(alarm.find_child("Box", true, false))
	var face := _bounds(button)
	assert_true(housing.size.x <= 0.22 and housing.position.y >= -0.13 and housing.position.z >= -0.04, "fits core's 0.22 x 0.28 x 0.06 box (%s)" % housing)
	assert_true(face.get_center().distance_to(Vector3(0, -0.008, 0.019)) < 0.01 and button.position.z > 0.02, "button on the face (%s)" % face)
	alarm.queue_free()
