extends TestCase
## T-222 (D-126, D-127, D-129): the upgraded shell of room 407, the playable room's since the owner
## approved it (shell_t222; false keeps the T-213 corner shell for before captures).

const ROOM := "res://scenes/levels/floor4/room_407.tscn"
## The balcony in room space (shell_layout.py BALCONY, BALCONY_DOOR): the wall's outside face, the
## parapet's inside face, the divider east of the door and the doorway's jambs.
const WALL_OUT := -7.075
const PARAPET_IN := -8.45
const DIVIDER_EAST := 5.14
const DOORWAY := Vector2(2.3, 3.3)
## The manager's body (manager.tscn capsule).
const MANAGER_RADIUS := 0.3
var fixtures: Array[Node] = []


func spawn(t222: bool = true) -> Node3D:
	var room := (load(ROOM) as PackedScene).instantiate() as Node3D
	room.shell_t222 = t222
	fixtures.append(room)
	tree.root.add_child(room)
	return room


func after_each() -> void:
	for node in fixtures:
		node.queue_free()
	fixtures.clear()
	await wait_frames(2)


## A leaf's own mesh in room space (its levers are child meshes and stay out).
func _room_box(room: Node3D, leaf: MeshInstance3D) -> AABB:
	return room.global_transform.affine_inverse() * leaf.global_transform * leaf.get_aabb()


## The 8 corners of a box in a node's space (a collision box, a mesh's AABB) in room space.
func _room_corners(room: Node3D, node: Node3D, box: AABB) -> Array[Vector3]:
	var corners: Array[Vector3] = []
	for corner: int in 8:
		corners.append(room.to_local(node.global_transform * box.get_endpoint(corner)))
	return corners


func _leaf_collision_box(door: Node3D) -> AABB:
	var size: Vector3 = ((door.get_node("Pivot/Leaf/Collision") as CollisionShape3D).shape as BoxShape3D).size
	return AABB(-size / 2.0, size)


func test_shell_has_every_part() -> void:
	var furnished := spawn().get_node("Furnished")
	for path: String in ["floor/Floor", "floor/BathFloor", "floor/SkirtingWest", "floor/FrontSkirtingEast",
			"architecture/FrontWallWest", "architecture/BathroomSide", "architecture/BalconyRevealTop",
			"ceiling/Ceiling", "frames/RoomDoorFrame", "frames/BathArchitraveE", "frames/BalconyFrameW",
			"fixtures/RoomDoor", "fixtures/BalconyDoorPivot", "balcony/BalconyFloor",
			"balcony/ParapetInner", "outside/OutsideSky"]:
		assert_not_null(furnished.get_node_or_null(path), path)
	assert_eq(furnished.get_node("Decals").get_child_count(), 0, "the grime is painted into the surfaces")
	for node: Node in furnished.find_children("*", "", true, false):
		# T-224 (D-134): the small props the manager knocks over are rigid bodies on his props layer.
		if String(furnished.get_path_to(node)).get_slice("/", 1) in Room407Obstacles.DYNAMIC:
			continue
		assert_false(node is CollisionObject3D or node is CollisionShape3D, "visual only: " + String(furnished.get_path_to(node)))


func test_surfaces_wear_the_aged_shader_on_their_mask() -> void:
	var furnished := spawn().get_node("Furnished")
	for path: String in ["architecture/WestWall", "floor/Floor", "ceiling/Ceiling", "balcony/ExtBackWest", "floor/SkirtingEast"]:
		var mesh := furnished.get_node(path) as MeshInstance3D
		var material := mesh.get_surface_override_material(0) as ShaderMaterial
		assert_not_null(material, path)
		assert_not_null(material.get_shader_parameter("mask"), path + " mask")
		assert_true(mesh.mesh.surface_get_format(0) & Mesh.ARRAY_FORMAT_TEX_UV2 != 0, path + " has the atlas UV2")


func test_door_wall_parts_move_with_the_corridor_wall() -> void:
	var room := spawn()
	var shift: float = room.DOOR_WALL_SHIFT
	for part: String in ["frames/RoomDoorFrame", "floor/FrontSkirtingWest", "floor/FrontSkirtingEast", "architecture/DoorLintel"]:
		var source := (load(Room407Furnish.SHELL_T222 + part.get_slice("/", 0) + ".glb") as PackedScene).instantiate() as Node3D
		var original := (source.get_node(part.get_slice("/", 1)) as Node3D).position.z
		source.free()
		assert_true(absf((room.get_node("Furnished/" + part) as Node3D).position.z - original - shift) < 0.0001, part)


## D-133: the old corridor wall no longer shows between the doorway and the narrower Tripo leaf.
func test_room_door_stop_shuts_the_latch_gap() -> void:
	var room := spawn()
	var strip := _room_box(room, room.get_node("Furnished/frames/RoomDoorStop") as MeshInstance3D)
	var wall := _room_box(room, room.get_node("Furnished/architecture/FrontWallWest") as MeshInstance3D)
	var leaf := _room_box(room, room.get_node("Furnished/fixtures/RoomDoor") as MeshInstance3D)
	assert_true(strip.position.x <= wall.end.x + 0.001, "from the doorway's edge")
	assert_true(strip.end.x >= leaf.position.x - 0.001, "to the leaf's latch edge")
	assert_true(strip.position.z <= leaf.position.z + 0.001 and strip.end.z >= leaf.end.z - 0.001, "as deep as the leaf")


func test_tripo_bathroom_door_swings_with_its_levers() -> void:
	var room := spawn()
	var leaf := room.get_node("Extension/BathroomDoor/Pivot/BathroomDoor") as MeshInstance3D
	assert_not_null(leaf, "the Tripo leaf rides the bathroom door's pivot")
	assert_eq(leaf.find_children("Lever*", "", false, false).size(), 2, "a lever on each face")
	var box := _room_box(room, leaf)
	assert_true(absf(box.size.y - 2.2) < 0.02, "leaf height %f" % box.size.y)


func test_balcony_door_stands_open_against_the_outside_wall() -> void:
	var room := spawn()
	var door := room.get_node("Extension/BalconyDoor") as Node3D
	assert_true(door.get("is_open"), "D-127: open when the chapter starts")
	var pivot := door.get_node("Pivot") as Node3D
	assert_true(absf(rad_to_deg(pivot.rotation.y) + 172.0) < 0.5, "as far as the shell built it")
	var hinge := (room.get_node("Furnished/fixtures/BalconyDoorPivot") as Node3D).global_position
	assert_true(pivot.global_position.is_equal_approx(hinge), "on the shell's hinge line")
	var leaf := _room_box(room, pivot.get_node("BalconyDoor") as MeshInstance3D)
	assert_true(leaf.end.z <= WALL_OUT + 0.005, "outside the wall, nothing in the doorway")
	assert_true(leaf.position.z >= PARAPET_IN, "clear of the parapet")
	assert_true(leaf.position.x >= DOORWAY.y - 0.1 and leaf.end.x <= DIVIDER_EAST, "east of the doorway, clear of the divider")
	for lever: MeshInstance3D in pivot.get_node("BalconyDoor").find_children("Lever*", "MeshInstance3D", false, false):
		for corner: Vector3 in _room_corners(room, lever, lever.get_aabb()):
			assert_true(corner.z <= WALL_OUT + 0.002, "the lever between leaf and wall stays off the wall")


func test_balcony_door_collision_is_the_leaf() -> void:
	var room := spawn()
	var door := room.get_node("Extension/BalconyDoor") as Node3D
	var body := door.get_node("Pivot/Leaf") as StaticBody3D
	assert_eq(body.collision_layer, 1, "blocks like a wall")
	var mesh := _room_box(room, door.get_node("Pivot/BalconyDoor") as MeshInstance3D)
	var corners := _room_corners(room, body, _leaf_collision_box(door))
	var shape := AABB(corners[0], Vector3.ZERO)
	for corner: Vector3 in corners:
		shape = shape.expand(corner)
	assert_true(shape.position.distance_to(mesh.position) < 0.01 and shape.end.distance_to(mesh.end) < 0.01,
		"the box is the leaf: %s vs %s" % [shape, mesh])


func test_balcony_door_shuts_the_doorway_and_swings_clear() -> void:
	var room := spawn()
	var door := room.get_node("Extension/BalconyDoor") as Node3D
	var body := door.get_node("Pivot/Leaf") as Node3D
	var pivot := door.get_node("Pivot") as Node3D
	door.call("set_open", false)
	for corner: Vector3 in _room_corners(room, body, _leaf_collision_box(door)):
		assert_true(corner.x > DOORWAY.x - 0.001 and corner.x < DOORWAY.y + 0.001, "shut: in the doorway (x %f)" % corner.x)
		assert_true(corner.z >= WALL_OUT - 0.001 and corner.z <= WALL_OUT + 0.051, "shut: in the frame (z %f)" % corner.z)
	var open: float = door.call("open_angle")
	for step: int in range(1, 41):
		pivot.rotation.y = open * step / 40.0
		for corner: Vector3 in _room_corners(room, body, _leaf_collision_box(door)):
			assert_true(corner.z <= WALL_OUT + 0.051, "never into the room")
			assert_true(corner.z >= PARAPET_IN and corner.x <= DIVIDER_EAST, "clear of parapet and divider at step %d" % step)
	door.call("set_open", true)
	assert_true(is_equal_approx(pivot.rotation.y, open), "opens again")


## The manager walks out onto the balcony (ManagerNavigation): along every edge of its path the
## open leaf stays further off than the manager's body radius.
func test_open_balcony_door_leaves_the_manager_path_clear() -> void:
	var room := spawn()
	var door := room.get_node("Extension/BalconyDoor") as Node3D
	var body := door.get_node("Pivot/Leaf") as Node3D
	var half: Vector3 = _leaf_collision_box(door).end
	var mesh := (room.get_node("ManagerNavigation") as NavigationRegion3D).navigation_mesh
	var vertices := mesh.vertices
	var nearest := INF
	for index: int in mesh.get_polygon_count():
		var polygon := mesh.get_polygon(index)
		for i: int in polygon.size():
			var a: Vector3 = vertices[polygon[i]]
			var b: Vector3 = vertices[polygon[(i + 1) % polygon.size()]]
			for t: int in 21:
				var local := body.global_transform.affine_inverse() * room.to_global(a.lerp(b, t / 20.0))
				nearest = minf(nearest, Vector2(maxf(absf(local.x) - half.x, 0.0), maxf(absf(local.z) - half.z, 0.0)).length())
	assert_true(nearest >= MANAGER_RADIUS, "nearest path edge %.3f m from the leaf" % nearest)


func test_tripo_levers_take_the_hand() -> void:
	var floor4 := (load("res://scenes/levels/floor4/floor4.tscn") as PackedScene).instantiate() as Node3D
	fixtures.append(floor4)
	tree.root.add_child(floor4)
	var room := floor4.get_node("Room407") as Node3D
	for path: String in ["Door407/Pivot/HandlePivot", "Room407/Extension/BathroomDoor/Pivot/BathroomDoor",
			"Room407/Extension/BalconyDoor/Pivot/BalconyDoor"]:
		var levers := floor4.get_node(path).find_children("Lever*", "MeshInstance3D", false, false)
		var targets := DoorHandles.take(levers)
		assert_eq(targets.size(), 2, path + ": one per face")
		for target: HandTarget in targets:
			var lever := target.lever as MeshInstance3D
			assert_eq(target.get_parent(), lever, path + ": the hand rides the lever")
			assert_true(lever.get_aabb().grow(0.004).has_point(target.position), path + ": the grip is on the bar")
			var rest: float = room.to_local(target.global_position).y
			lever.rotate_object_local(target.lever_axis, deg_to_rad(target.lever_degrees))
			assert_true(room.to_local(target.global_position).y < rest - 0.02, path + ": pressing takes the bar down")
			lever.rotate_object_local(target.lever_axis, -deg_to_rad(target.lever_degrees))


func test_towel_hangs_on_the_balcony_line() -> void:
	var room := spawn()
	var spot := room.get_node("Anchors/TowelSpot") as Node3D
	assert_true(spot.position.is_equal_approx(Vector3(2.8, 2.15, -7.85)), "towel spot on the line")
	assert_not_null(room.get_node_or_null("Anchors/TowelSpot/Model/BalconyTowel"), "the Tripo towel hides with the story")
	for mesh: MeshInstance3D in room.get_node("Anchors/TowelSpot/Model").find_children("*", "MeshInstance3D", true, false):
		if not mesh.has_meta(&"furnished") and not room.get_node("Anchors/TowelSpot/Model/BalconyTowel").is_ancestor_of(mesh):
			assert_false(mesh.visible, "PS1 towel hidden: " + mesh.name)


func test_the_playable_room_wears_the_t222_shell() -> void:
	var room := (load(ROOM) as PackedScene).instantiate() as Node3D
	fixtures.append(room)
	tree.root.add_child(room)
	assert_true(room.shell_t222, "D-129: approved for the game")
	assert_not_null(room.get_node_or_null("Furnished/ceiling"), "the T-222 shell")
	assert_not_null(room.get_node_or_null("Extension/BalconyDoor"), "with its balcony door")


func test_corner_shell_keeps_the_old_room() -> void:
	var room := spawn(false)
	assert_true(room.get_node_or_null("Furnished/ceiling") == null, "no T-222 parts")
	assert_true(room.get_node_or_null("Extension/BalconyDoor") == null, "no balcony door")
	assert_true((room.get_node("Anchors/TowelSpot") as Node3D).position.is_equal_approx(Vector3(2.8, 1.8, -8.12)), "towel spot unchanged")


func test_textures_stay_within_budget() -> void:
	for file: String in ["mask_walls.png", "mask_floor.png", "mask_ceiling.png", "mask_balcony.png", "night_sky.png",
			"wall_peel_color.jpg", "plastered_wall_02_color.jpg"]:
		var texture := load(Room407Furnish.SHELL_TEX + file) as Texture2D
		assert_true(texture.get_width() <= 2048 and texture.get_height() <= 2048, file)


func test_room_door_levers_rattle_on_the_handle_pivot() -> void:
	for t222: bool in [true, false]:
		var floor4 := (load("res://scenes/levels/floor4/floor4.tscn") as PackedScene).instantiate() as Node3D
		floor4.get_node("Room407").shell_t222 = t222
		fixtures.append(floor4)
		tree.root.add_child(floor4)
		var handle := floor4.get_node("Door407/Pivot/HandlePivot") as Node3D
		var levers := handle.find_children("Lever*", "", false, false)
		assert_eq(levers.size(), 2 if t222 else 0, "levers on the handle pivot (t222 %s)" % t222)
		assert_eq((handle.get_node("Grip") as Node3D).visible, not t222, "the PS1 box grip only without them")
		if t222:
			var leaf := floor4.get_node("Door407/Pivot/RoomDoor") as MeshInstance3D
			assert_not_null(leaf, "the Tripo leaf hangs on Door407")
			for lever: MeshInstance3D in levers:
				var length := lever.get_aabb().size.x * lever.global_basis.get_scale().x
				assert_true(length > 0.13, "D-133: a main door's lever, %.3f m" % length)
			var spindle := floor4.global_transform.affine_inverse() * handle.global_position
			assert_true(absf(spindle.y - 1.05) < 0.01, "pivot at the levers' spindle height")
