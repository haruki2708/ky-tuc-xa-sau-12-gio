extends TestCase
## T-215 (D-102): the playable room 407 draws the furnished room and keeps every gameplay node.
## D-129: with the T-222 shell, whose only new physics is the balcony door (D-127).

const ROOM := "res://scenes/levels/floor4/room_407.tscn"
const FLOOR := "res://scenes/levels/floor4/floor4.tscn"
var fixtures: Array[Node] = []


func spawn(path: String, furnished: bool = true) -> Node3D:
	var node := (load(path) as PackedScene).instantiate() as Node3D
	var room: Node = node if node.has_method("furnished_room_door") else node.get_node("Room407")
	room.furnished = furnished
	fixtures.append(node)
	tree.root.add_child(node)
	return node


func after_each() -> void:
	for node in fixtures:
		node.queue_free()
	fixtures.clear()
	await wait_frames(2)


func _physics(root: Node) -> Array:
	var result: Array = []
	for node: Node in root.find_children("*", "", true, false):
		if node is CollisionObject3D or node is CollisionShape3D or node is NavigationRegion3D:
			result.append([String(root.get_path_to(node)), (node as Node3D).global_transform])
	return result


func _row(name: String) -> Dictionary:
	for row: Dictionary in Room407Furnish.placements():
		if row.name == name:
			return row
	return {}


func test_furnished_room_is_built_with_every_prop() -> void:
	var room := spawn(ROOM)
	var furnished := room.get_node("Furnished")
	for part: String in Room407Furnish.SHELL_PARTS["t222"]:
		assert_not_null(furnished.get_node_or_null(part), part)
	var carried: int = room.FOLLOW.merged(room.T222_FOLLOW).size()
	var props := furnished.get_node("TripoProps")
	assert_eq(props.get_child_count() + carried, Room407Furnish.placements("t222").size(), "every row is placed once")
	assert_eq(furnished.get_node("Decals").get_child_count(), 0, "the T-222 shell paints its grime in")
	for node: Node in furnished.find_children("*", "", true, false):
		# T-224 (D-134): the small props the manager knocks over are rigid bodies on his props layer.
		var path := String(furnished.get_path_to(node))
		if path.get_slice("/", 1) in Room407Obstacles.DYNAMIC:
			continue
		# T-225 (D-135): furniture the player walked through has a Solid box.
		if path.get_slice("/", 1) in Room407Obstacles.SOLID and path.get_slice("/", 2) == "Solid":
			continue
		assert_false(node is CollisionObject3D or node is CollisionShape3D, "visual only: " + path)


func test_takeaway_box_leaves_the_papers_and_songbook_clear() -> void:
	# T-225 (D-135): the box lay over Việt's guitar songbook (owner's playtest, so_ghi.png).
	var room := spawn(ROOM)
	var prop: Node3D = room.furnished_prop("TakeawayBox")
	var box: AABB = prop.global_transform * Room407Furnish.local_bounds(prop)
	var papers := Node3D.new()
	room.add_child(papers)
	preload("res://scenes/main/chapter1_main.gd").place_papers(room.get_node("Anchors") as Node3D, papers)
	var things: Array[Node] = papers.get_children()
	things.append(room.get_node("Anchors/GuitarSongbook/Book"))
	for thing: Node in things:
		for mesh: MeshInstance3D in thing.find_children("*", "MeshInstance3D", true, false):
			var bounds: AABB = (mesh.global_transform * mesh.get_aabb()).grow(0.005)
			assert_false(box.intersects(bounds), "clear of " + String(room.get_path_to(mesh)))


func test_standing_fan_runs_and_hums() -> void:
	# T-226 (D-136, owner: the fan, plugged in, should be running).
	var room := spawn(ROOM)
	var fan: Node3D = room.furnished_prop("StandingFan")
	var rotor := fan.find_child("Rotor", true, false) as Node3D
	assert_not_null(rotor, "split fan")
	assert_not_null(rotor.get_node_or_null("Blades"))
	assert_eq(rotor.find_children("BladesTrail*", "MeshInstance3D", false, false).size(), 2, "two trailing copies")
	assert_true(rotor.global_basis.y.dot(-fan.global_basis.z) > 0.95, "the blades turn about the fan's facing")
	var before := rotor.basis
	await wait_frames(3)
	assert_false(rotor.basis.is_equal_approx(before), "the blades turn")
	assert_true(rotor.global_basis.y.dot(-fan.global_basis.z) > 0.95, "still about the same axis")
	var hum := rotor.get_node("FanHum") as AmbientEmitter
	assert_eq(hum.bus, &"Ambience")
	assert_true(hum.volume_db <= -20.0 and hum.max_distance <= 6.0, "quiet, only beside the fan")
	assert_true(hum.volume_linear < 0.001, "silent while nobody is in the room (its AmbientZone)")
	assert_not_null(room.furnished_prop("SocketFan"), "plugged into the wall by it")


func test_timetable_paper_is_dimmed_for_the_torch() -> void:
	# T-225 (D-135): its near-white paper burnt out under the torch close up.
	var room := spawn(ROOM)
	var timetable: Node3D = room.furnished_prop("Timetable")
	var surfaces := 0
	for mesh: MeshInstance3D in timetable.find_children("*", "MeshInstance3D", true, false):
		for surface in mesh.mesh.get_surface_count():
			var material := mesh.get_active_material(surface) as StandardMaterial3D
			assert_true(material.albedo_color.r <= Room407Furnish.PAPER_TINT["Timetable"] + 0.001,
				"%s at %s" % [mesh.name, material.albedo_color])
			surfaces += 1
	assert_true(surfaces >= 2, "paper and tape")
	var source := (load(_row("Timetable").model) as PackedScene).instantiate() as Node3D
	var paper := source.find_children("timetable", "MeshInstance3D", true, false)[0] as MeshInstance3D
	assert_eq((paper.get_active_material(0) as StandardMaterial3D).albedo_color, Color.WHITE, "the shared model keeps its own")
	source.free()


func test_physics_and_navigation_are_unchanged() -> void:
	var old := _physics(spawn(ROOM, false))
	var room := spawn(ROOM)
	var new := _physics(room).filter(func(entry: Array) -> bool:
		return not String(entry[0]).begins_with("Extension/BalconyDoor") and not String(entry[0]).begins_with("Furnished/TripoProps/"))
	assert_not_null(room.get_node_or_null("Extension/BalconyDoor/Pivot/Leaf/Collision"), "D-127: the balcony door is new")
	assert_eq(new.size(), old.size(), "same collision/navigation nodes besides it")
	for i in old.size():
		assert_eq(new[i][0], old[i][0])
		# Viet's locker door and its pivot follow the model's hinge (a few cm).
		if not String(old[i][0]).begins_with("Anchors/VietLocker/Pivot"):
			assert_true(new[i][1].is_equal_approx(old[i][1]), "unchanged: " + String(old[i][0]))


func _is_furnished(node: Node, room: Node) -> bool:
	while node != room:
		if node.has_meta(&"furnished") or String(node.name) == "Furnished":
			return true
		node = node.get_parent()
	return false


func test_ps1_meshes_give_way_except_story_and_puzzle_ones() -> void:
	var old := spawn(ROOM, false)
	var room := spawn(ROOM)
	var checked := 0
	for mesh: MeshInstance3D in room.find_children("*", "MeshInstance3D", true, false):
		if _is_furnished(mesh, room):
			continue
		var path := String(room.get_path_to(mesh))
		var keep: bool = room._matches(path, room.KEEP_PS1) and not room._matches(path, room.REPLACED_PS1) \
				and not room._matches(path, room.T222_REPLACED_PS1)
		var before := old.get_node_or_null(path) as MeshInstance3D
		if before == null:
			continue  # runtime meshes get unique names per instance
		assert_eq(mesh.visible, before.visible and keep, path)
		checked += 1
	assert_true(checked > 200, "every PS1 mesh checked (%d)" % checked)
	for path in ["Anchors/PowerStrip/Case", "Anchors/DatLocker/CombinationLock/Mesh", "Anchors/Router/Model/LED",
			"Details/BloodSeep/BlanketStain1", "Ch2Bathroom/MirrorFog"]:
		assert_eq((room.get_node(path) as Node3D).visible, (old.get_node(path) as Node3D).visible, "kept: " + path)
	for path in ["Anchors/TrashBin/Base", "Anchors/Router/Model/Case", "Anchors/TeamPhoto/Frame", "WestWall/Mesh",
			"Anchors/VietLocker/Pivot/Door/Mesh", "Extension/BathroomDoor/Pivot/Leaf/Mesh"]:
		assert_false((room.get_node(path) as Node3D).visible, "replaced: " + path)


func test_nets_mattress_and_pillow_follow_their_story_nodes() -> void:
	var room := spawn(ROOM)
	var net := room.get_node("BunkA/Net_Phuc/NetPhuc") as Node3D
	var row := _row("NetPhuc")
	assert_true(net.global_position.is_equal_approx(Vector3(row.position[0], row.position[1], row.position[2])))
	room.get_node("BunkA/Net_Phuc").visible = false
	assert_false(net.is_visible_in_tree(), "slat flip / mattress lift hide the net")
	var mattress := room.get_node("Anchors/PhucMattress/Pivot/MattressPhuc") as Node3D
	var rest := mattress.global_position
	room.get_node("Anchors/PhucMattress").set_lifted(true)
	assert_true(mattress.global_position.distance_to(rest) > 0.1, "Phuc's mattress lifts with the clue")
	assert_not_null(room.get_node("Anchors/PhucMattress/Pivot/BlanketPhuc"))
	room.set_slashed(0.5)
	assert_false(room.get_node("Furnished/TripoProps/BlanketTrung").visible, "slashed bedding replaces the blanket")
	assert_true(room.get_node("Details/TrungPillow/PillowTrung").is_visible_in_tree())
	room.set_slashed(1.0)
	assert_false(room.get_node("Details/TrungPillow/PillowTrung").is_visible_in_tree())
	room.set_slashed(0.0)
	assert_true(room.get_node("Furnished/TripoProps/BlanketTrung").visible)


func test_viet_locker_and_bathroom_door_swing_on_their_hinges() -> void:
	var room := spawn(ROOM)
	var locker := room.get_node("Anchors/VietLocker")
	var door := room.get_node("Anchors/VietLocker/Pivot/FurnishedDoor") as Node3D
	var closed := door.global_transform
	assert_eq((room.get_node("Furnished/TripoProps/LockerViet") as Node3D).find_child("DoorPivot", true, false).get_child_count(), 0)
	locker.set_open(true)
	assert_false(door.global_transform.is_equal_approx(closed), "the furnished door swings open")
	locker.set_open(false)
	assert_true(door.global_transform.is_equal_approx(closed))
	var bath := room.get_node("Extension/BathroomDoor/Pivot/BathroomDoor") as Node3D
	var shut := bath.global_transform
	(room.get_node("Extension/BathroomDoor/Pivot") as Node3D).rotation.y = 1.2
	assert_false(bath.global_transform.is_equal_approx(shut))


func test_door_wall_meets_the_corridor_wall_and_tubes_follow_the_main_light() -> void:
	var room := spawn(ROOM)
	var wall := room.get_node("Furnished/architecture/FrontWallWest") as Node3D
	var shell := (load(Room407Furnish.SHELL_T222 + "architecture.glb") as PackedScene).instantiate() as Node3D
	var rest: float = (shell.get_node("FrontWallWest") as Node3D).position.z
	shell.free()
	assert_true(absf(wall.position.z - (rest + room.DOOR_WALL_SHIFT)) < 0.001, "door wall moved onto the corridor wall")
	var timetable := room.get_node("Furnished/TripoProps/Timetable") as Node3D
	assert_true(timetable.position.z < -0.1 and timetable.position.z > -0.13, "paper on the moved wall")
	assert_true((room.get_node("Furnished/TripoProps/RouterShelf") as Node3D).position.is_equal_approx(Vector3(4.6, 1.226, -0.162)),
		"rows already aligned to the playable wall stay")
	var mirror := room.get_node("Furnished/TripoProps/MirrorSmall") as Node3D
	var glass: AABB = mirror.transform * Room407Furnish.local_bounds(mirror)
	var fog := room.get_node("Ch2Bathroom/MirrorFog") as Node3D
	assert_true(glass.grow(0.02).has_point(fog.position), "chapter 2 fog sits on the furnished mirror")
	assert_true(fog.position.x > glass.end.x, "fog in front of the glass")
	var light := room.get_node("Room407MainLight") as OmniLight3D
	var tube: StandardMaterial3D = room._tubes[0]
	light.visible = true
	light.light_energy = 1.0
	await wait_frames(1)
	assert_true(tube.emission_energy_multiplier > 0.5)
	light.visible = false
	await wait_frames(1)
	assert_eq(tube.emission_energy_multiplier, 0.0)


func test_floor_hangs_the_furnished_room_door_on_door407() -> void:
	var floor4 := spawn(FLOOR)
	var leaf := floor4.get_node("Door407/Pivot/RoomDoor") as Node3D
	var shut := leaf.global_transform
	for mesh: MeshInstance3D in floor4.get_node("Door407/Pivot/Leaf").find_children("*", "MeshInstance3D", true, false):
		assert_false(mesh.visible)
	floor4.get_node("Door407").set_open(true)
	assert_false(leaf.global_transform.is_equal_approx(shut))
	var fan := floor4.get_node("Room407/Furnished/TripoProps/CeilingFan").find_child("fan_rotor", true, false)
	assert_not_null(fan, "main.gd spins every fan_rotor under Floor4")


func test_no_corridor_face_shares_a_plane_with_the_furnished_walls() -> void:
	# D-113: Corridor/RoomPartition_38 lay in the furnished east wall's plane (x = 7.9) and the two
	# flickered above the bathroom tiles. Its collision stays.
	var floor4 := spawn(FLOOR)
	await wait_frames(1)
	var room := floor4.get_node("Room407") as Node3D
	var walls: Array[AABB] = []
	for mesh: MeshInstance3D in room.get_node("Furnished/architecture").find_children("*", "MeshInstance3D", true, false):
		walls.append(mesh.global_transform * mesh.get_aabb())
	for mesh: MeshInstance3D in floor4.get_node("Corridor").find_children("*", "MeshInstance3D", true, false):
		if not mesh.is_visible_in_tree():
			continue
		var box: AABB = mesh.global_transform * mesh.get_aabb()
		for wall in walls:
			for axis in 3:
				var a := (axis + 1) % 3
				var b := (axis + 2) % 3
				var overlap_a := minf(box.end[a], wall.end[a]) - maxf(box.position[a], wall.position[a])
				var overlap_b := minf(box.end[b], wall.end[b]) - maxf(box.position[b], wall.position[b])
				# Walls that only meet at an edge share their floor/ceiling planes over a few cm: skip.
				if overlap_a < 0.3 or overlap_b < 0.3:
					continue
				var flush := absf(box.position[axis] - wall.position[axis]) < 0.002 or absf(box.end[axis] - wall.end[axis]) < 0.002
				assert_false(flush, "%s shares a plane with the furnished room" % floor4.get_path_to(mesh))
	assert_not_null(floor4.get_node("Corridor/RoomPartition_38/Collision"), "the partition still blocks")
	var plain := spawn(FLOOR, false)
	await wait_frames(1)
	assert_true((plain.get_node("Corridor/RoomPartition_38/Mesh") as Node3D).is_visible_in_tree(), "PS1 room keeps it")


func test_room_is_darker_and_the_torch_wider_inside_only() -> void:
	var floor4 := spawn(FLOOR)
	var room := floor4.get_node("Room407") as Node3D
	var environment := (floor4.get_node("Environment") as WorldEnvironment).environment
	var outside_ambient := environment.ambient_light_energy
	var camera := Camera3D.new()
	fixtures.append(camera)
	tree.root.add_child(camera)
	camera.make_current()
	var torch := SpotLight3D.new()
	torch.name = "Flashlight"
	torch.light_energy = 1.5
	torch.spot_angle = 28.0
	camera.add_child(torch)
	camera.global_position = room.to_global(Vector3(2.8, 1.6, 2.0))
	await wait_frames(30)
	assert_eq(environment.ambient_light_energy, outside_ambient, "the corridor keeps floor 4's night")
	assert_eq(torch.light_energy, 1.5)
	camera.global_position = room.to_global(Vector3(4.0, 1.6, -3.0))
	await wait_frames(60)
	assert_true(is_equal_approx(environment.ambient_light_energy, room.ROOM_ENVIRONMENT.ambient_light_energy), "room night as dark as the pilot")
	assert_true(environment.ssao_enabled)
	assert_true(is_equal_approx(torch.light_energy, room.ROOM_TORCH.light_energy), "pilot torch inside the room")
	assert_true(is_equal_approx(torch.spot_angle, room.ROOM_TORCH.spot_angle))
	var tube := room.get_node("Room407MainLight") as OmniLight3D
	assert_true(tube.shadow_enabled and tube.omni_range == room.TUBE_LIGHT.omni_range, "pilot ceiling tube")
	tube.set_flicker(true)
	tube.visible = true
	var peak := 0.0
	for i in 40:
		await wait_frames(1)
		peak = maxf(peak, tube.light_energy)
	tube.set_flicker(false)
	assert_true(is_equal_approx(peak, room.TUBE_LIGHT.flicker_energy), "the flicker lights the room like the pilot tube")
	for name in ["CorridorLight_406", "CorridorLight_407", "CorridorLight_408"]:
		assert_true((floor4.get_node("Corridor/" + name) as OmniLight3D).shadow_enabled, name + " stops at the room walls")
	assert_false((floor4.get_node("Corridor/CorridorLight_401") as OmniLight3D).shadow_enabled, "far corridor lights unchanged")
	floor4.queue_free()
	fixtures.erase(floor4)
	await wait_frames(2)
	assert_eq(environment.ambient_light_energy, outside_ambient, "the shared environment is handed back")
	assert_false(environment.ssao_enabled)


func test_furnished_mirrors_reflect_only_when_looked_at() -> void:
	var room := spawn(ROOM)
	var body := Node3D.new()
	fixtures.append(body)
	var head := Node3D.new()
	head.name = "Head"
	head.position.y = 1.6
	body.add_child(head)
	var camera := Camera3D.new()
	head.add_child(camera)
	room.add_child(body)
	camera.make_current()
	for prop_name: String in room.MIRROR_GLASS:
		var mirror := room.get_node("Reflective" + prop_name) as Node3D
		var model := room.get_node("Furnished/TripoProps/" + prop_name) as Node3D
		var glass: Dictionary = room.MIRROR_GLASS[prop_name]
		assert_true(mirror.require_in_view, prop_name)
		assert_true(mirror.mirror_size.is_equal_approx(glass.size), prop_name + " glass size")
		assert_true(((mirror.get_node("Surface") as MeshInstance3D).mesh as QuadMesh).size.is_equal_approx(glass.size))
		var texels: Vector2i = (mirror.get_node("ReflectionViewport") as SubViewport).size
		assert_true(absf(float(texels.x) / texels.y - glass.size.x / glass.size.y) < 0.01, "reflection keeps the glass aspect")
		# The glass sits on the model's glass, a few millimetres out, facing away from the model.
		var centre := model.to_global(glass.centre)
		assert_true(mirror.global_position.distance_to(centre) < 0.01, prop_name + " on the glass")
		var out := mirror.global_basis.z
		assert_true(out.dot(mirror.global_position - centre) > 0.0, prop_name + " in front of the glass")
		# In front and looking at it: reflects the player's body. Turned away or outside: off.
		body.global_position = mirror.global_position + out * 1.2 - Vector3(0, mirror.global_position.y, 0)
		camera.look_at(mirror.global_position)
		await wait_frames(3)
		assert_eq(mirror.follow, body, prop_name + " follows the camera's body")
		assert_true(mirror.rendering_active, prop_name + " renders when looked at")
		camera.look_at(mirror.global_position + out * 3.0)
		await wait_frames(3)
		assert_false(mirror.rendering_active, prop_name + " idle when turned away")
		body.global_position = room.to_global(Vector3(3.0, 0.0, 2.0))
		camera.look_at(mirror.global_position)
		await wait_frames(3)
		assert_false(mirror.rendering_active, prop_name + " idle from the corridor")
	assert_eq(room.get_node("Ch2Bathroom/MirrorFog").get_parent(), room.get_node("Ch2Bathroom"), "chapter 2 effects untouched")


func test_ps1_room_stays_available() -> void:
	var room := spawn(ROOM, false)
	assert_true(room.get_node_or_null("Furnished") == null)
	assert_true((room.get_node("WestWall/Mesh") as MeshInstance3D).visible)
	assert_true(room.furnished_room_door() == null)
