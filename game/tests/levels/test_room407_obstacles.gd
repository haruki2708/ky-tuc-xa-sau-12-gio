extends TestCase
## T-224 (D-134): in the T-222 room the manager's small props are rigid bodies he knocks over and
## his navigation mesh is baked around everything else.

const FLOOR := "res://scenes/levels/floor4/floor4.tscn"
const MANAGER := preload("res://scenes/entity/manager.tscn")
## Room space: the corridor where he comes from, both bunks' check spots, the balcony, the bathroom.
const CORRIDOR := Vector3(-4.5, 0.05, 2.0)
const PLACES := {"bunk A": Vector3(1.55, 0.05, -2.45), "bunk B": Vector3(6.45, 0.05, -2.15),
	"balcony": Vector3(2.8, 0.05, -7.6), "bathroom": Vector3(6.6, 0.05, -5.6)}
var fixtures: Array[Node] = []


func after_each() -> void:
	for node in fixtures:
		node.queue_free()
	fixtures.clear()
	await wait_frames(2)


func _floor4() -> Node3D:
	var floor4 := (load(FLOOR) as PackedScene).instantiate() as Node3D
	fixtures.append(floor4)
	tree.root.add_child(floor4)
	return floor4


func test_the_owners_small_props_are_rigid_on_the_props_layer() -> void:
	var room := _floor4().get_node("Room407") as Node3D
	var props := room.get_node("Furnished/TripoProps")
	for prop_name: String in Room407Obstacles.DYNAMIC:
		var body := props.get_node_or_null(prop_name) as RigidBody3D
		assert_not_null(body, prop_name + " is a rigid body")
		if body == null:
			continue
		assert_eq(body.collision_layer, DormManager.PROPS_LAYER, prop_name + " on his props layer")
		assert_true(body.collision_mask & 1 != 0, prop_name + " rests on the world")
		assert_true(is_equal_approx(body.mass, Room407Obstacles.DYNAMIC[prop_name]), prop_name + " weighs its kilos")
		assert_not_null(body.get_node_or_null("Model"), prop_name + " carries its model")
		assert_eq(body.find_children("*", "CollisionShape3D", false, false).size(), 1)
	for prop_name: String in ["StudyDesk", "BunkA", "Fridge"]:
		assert_false(props.get_node(prop_name) is RigidBody3D, prop_name + " stays put (the desk was not chosen)")
	for shape: CollisionShape3D in room.get_node("StudyStool").find_children("*", "CollisionShape3D", true, false):
		assert_true(shape.disabled, "the old stool's collision gives way to the rigid one")


func test_he_reaches_the_beds_balcony_and_bathroom_from_the_corridor() -> void:
	var room := _floor4().get_node("Room407") as Node3D
	var map := room.get_world_3d().navigation_map
	# Map sync runs asynchronously (as in test_room407_fixes.gd).
	for frame in 120:
		if NavigationServer3D.map_get_path(map, room.to_global(CORRIDOR), room.to_global(PLACES["balcony"]), true).size() >= 2:
			break
		await tree.physics_frame
	for place: String in PLACES:
		var goal: Vector3 = room.to_global(PLACES[place])
		var path := NavigationServer3D.map_get_path(map, room.to_global(CORRIDOR), goal, true)
		assert_true(path.size() > 1, place + ": a path")
		if path.size() > 1:
			assert_true(Vector2(path[-1].x - goal.x, path[-1].z - goal.z).length() < 0.3, "%s: ends there (%s)" % [place, room.to_local(path[-1])])


## No part of the mesh lies on a bed, desk, locker or anything else that blocks him (his radius
## round each), so he walks around them; the props he knocks over do not block it.
func test_the_mesh_keeps_clear_of_every_blocking_prop() -> void:
	var room := _floor4().get_node("Room407") as Node3D
	var mesh := (room.get_node("ManagerNavigation") as NavigationRegion3D).navigation_mesh
	assert_true(mesh.get_polygon_count() > 50, "baked, not the old lanes")
	var vertices := mesh.vertices
	var blocked := 0
	for prop: Node3D in room.get_node("Furnished/TripoProps").get_children():
		if prop is RigidBody3D or String(prop.name) in Room407Obstacles.PASSABLE:
			continue
		var row: Dictionary = prop.get_meta(&"placement", {})
		var box: AABB = room.global_transform.affine_inverse() * prop.global_transform * Room407Furnish.local_bounds(prop)
		if row.get("mount", "") == "wall" or box.position.y > Room407Obstacles.OVERHEAD or box.size.y < 0.05:
			continue
		blocked += 1
		var inner := Rect2(box.position.x + 0.05, box.position.z + 0.05, box.size.x - 0.1, box.size.z - 0.1)
		if inner.size.x <= 0.0 or inner.size.y <= 0.0:
			continue
		for index: int in mesh.get_polygon_count():
			var polygon := mesh.get_polygon(index)
			var centre := Vector3.ZERO
			for vertex: int in polygon:
				centre += vertices[vertex] / polygon.size()
			assert_false(inner.has_point(Vector2(centre.x, centre.z)), "%s: no path on it" % prop.name)
	assert_true(blocked > 30, "most of the room's things block him (%d)" % blocked)
	var bin := (room.get_node("Furnished/TripoProps/TrashBin") as Node3D).global_position
	var on_mesh := NavigationServer3D.map_get_closest_point(room.get_world_3d().navigation_map, bin)
	assert_true(Vector2(on_mesh.x - bin.x, on_mesh.z - bin.z).length() < 0.05, "the bin stands on his way to the balcony")


func test_walking_into_a_bin_knocks_it_over() -> void:
	var world := Node3D.new()
	fixtures.append(world)
	tree.root.add_child(world)
	var ground := StaticBody3D.new()
	var plane := CollisionShape3D.new()
	plane.shape = WorldBoundaryShape3D.new()
	ground.add_child(plane)
	world.add_child(ground)
	var bin := RigidBody3D.new()
	bin.collision_layer = DormManager.PROPS_LAYER
	bin.collision_mask = 1 | DormManager.PROPS_LAYER
	bin.mass = 1.0
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(0.3, 0.3, 0.3)
	shape.shape = box
	shape.position.y = 0.15
	bin.add_child(shape)
	world.add_child(bin)
	bin.position = Vector3(0, 0, -1.5)
	var manager := MANAGER.instantiate() as DormManager
	world.add_child(manager)
	manager.speed = 1.2
	manager.walk_to(Vector3(0, 0, -4.0))
	for frame in 240:
		await tree.physics_frame
	var moved := Vector2(bin.position.x, bin.position.z + 1.5).length()
	var tipped := bin.global_basis.y.angle_to(Vector3.UP)
	assert_true(moved > 0.3 or tipped > 0.5, "kicked %.2f m, tipped %.2f rad" % [moved, tipped])
	assert_true(manager.global_position.z < -3.5, "he walks on, not blocked by it (%s)" % manager.global_position)
