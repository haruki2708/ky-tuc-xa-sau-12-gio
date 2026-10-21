extends TestCase
## T-222 (D-126, D-127): the upgraded shell of room 407 (shell_t222; the playable room keeps the
## corner shell until the owner approves the pilot).

const ROOM := "res://scenes/levels/floor4/room_407.tscn"
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


func test_shell_has_every_part() -> void:
	var furnished := spawn().get_node("Furnished")
	for path: String in ["floor/Floor", "floor/BathFloor", "floor/SkirtingWest", "floor/FrontSkirtingEast",
			"architecture/FrontWallWest", "architecture/BathroomSide", "architecture/BalconyRevealTop",
			"ceiling/Ceiling", "frames/RoomDoorFrame", "frames/BathArchitraveE", "frames/BalconyFrameW",
			"fixtures/RoomDoor", "fixtures/BalconyDoorPivot/BalconyDoor", "balcony/BalconyFloor",
			"balcony/ParapetInner", "outside/OutsideSky"]:
		assert_not_null(furnished.get_node_or_null(path), path)
	assert_eq(furnished.get_node("Decals").get_child_count(), 0, "the grime is painted into the surfaces")
	for node: Node in furnished.find_children("*", "", true, false):
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


func test_tripo_bathroom_door_swings_with_its_levers() -> void:
	var room := spawn()
	var leaf := room.get_node("Extension/BathroomDoor/Pivot/BathroomDoor") as MeshInstance3D
	assert_not_null(leaf, "the Tripo leaf rides the bathroom door's pivot")
	assert_eq(leaf.find_children("Lever*", "", false, false).size(), 2, "a lever on each face")
	var box := _room_box(room, leaf)
	assert_true(absf(box.size.y - 2.2) < 0.02, "leaf height %f" % box.size.y)


func test_balcony_door_stands_open_against_the_outside_wall() -> void:
	var room := spawn()
	var pivot := room.get_node("Furnished/fixtures/BalconyDoorPivot") as Node3D
	assert_true(absf(rad_to_deg(pivot.rotation.y) + 172.0) < 0.5, "D-127: open when the chapter starts")
	var leaf := _room_box(room, room.get_node("Furnished/fixtures/BalconyDoorPivot/BalconyDoor") as MeshInstance3D)
	assert_true(leaf.end.z <= -7.07, "outside the wall, nothing in the doorway")
	assert_true(leaf.position.z >= -8.45, "clear of the parapet")
	assert_true(leaf.position.x >= 3.2 and leaf.end.x <= 5.14, "east of the doorway, clear of the divider")


func test_towel_hangs_on_the_balcony_line() -> void:
	var room := spawn()
	var spot := room.get_node("Anchors/TowelSpot") as Node3D
	assert_true(spot.position.is_equal_approx(Vector3(2.8, 2.15, -7.85)), "towel spot on the line")
	assert_not_null(room.get_node_or_null("Anchors/TowelSpot/Model/BalconyTowel"), "the Tripo towel hides with the story")
	for mesh: MeshInstance3D in room.get_node("Anchors/TowelSpot/Model").find_children("*", "MeshInstance3D", true, false):
		if not mesh.has_meta(&"furnished") and not room.get_node("Anchors/TowelSpot/Model/BalconyTowel").is_ancestor_of(mesh):
			assert_false(mesh.visible, "PS1 towel hidden: " + mesh.name)


func test_corner_shell_stays_for_the_playable_room() -> void:
	var room := spawn(false)
	assert_true(room.get_node_or_null("Furnished/ceiling") == null, "no T-222 parts")
	assert_true((room.get_node("Anchors/TowelSpot") as Node3D).position.is_equal_approx(Vector3(2.8, 1.8, -8.12)), "towel spot unchanged")


func test_textures_stay_within_budget() -> void:
	for file: String in ["mask_walls.png", "mask_floor.png", "mask_ceiling.png", "mask_balcony.png", "night_sky.png",
			"wall_peel_color.jpg", "plastered_wall_02_color.jpg"]:
		var texture := load(Room407Furnish.SHELL_TEX + file) as Texture2D
		assert_true(texture.get_width() <= 2048 and texture.get_height() <= 2048, file)
