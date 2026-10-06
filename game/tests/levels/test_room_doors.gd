extends TestCase
## D-061: physical room exits and nav routes, with the complete integrated map.

var fixture: Node3D
var floor4: Node3D
var campus: Node3D


func before_each() -> void:
	fixture = Node3D.new()
	tree.root.add_child(fixture)
	floor4 = (load("res://scenes/levels/floor4/floor4.tscn") as PackedScene).instantiate()
	campus = (load("res://scenes/levels/campus/campus.tscn") as PackedScene).instantiate()
	fixture.add_child(floor4)
	fixture.add_child(campus)
	for frame in 5:
		await tree.physics_frame


func after_each() -> void:
	fixture.queue_free()
	await wait_frames(2)
	await tree.create_timer(.4).timeout


func _doors() -> Array[Node]:
	return tree.get_nodes_in_group(&"room_doors")


func _spawn(door: Node3D) -> Vector3:
	var number := int(String(door.room))
	return campus.get_node("Anchors/RoomSpawns/B%d/R%d" % [number / 100, number]).global_position


func _motion(from: Vector3, to: Vector3) -> float:
	var capsule := CapsuleShape3D.new()
	capsule.radius = .3
	capsule.height = 1.6
	var query := PhysicsShapeQueryParameters3D.new()
	query.shape = capsule
	query.collision_mask = 1
	query.margin = .001
	query.transform.origin = from + Vector3(0, .8, 0)
	query.motion = to - from
	var space := fixture.get_world_3d().direct_space_state
	assert_true(space.intersect_shape(query).is_empty(), "spawn capsule clear at %s" % from)
	return space.cast_motion(query)[0]


func test_all_22_room_doors_block_then_clear_capsules_and_close_again() -> void:
	assert_eq(_doors().size(), 22)
	var expected: Array[int] = [201, 202, 204, 205, 206, 207, 208, 301, 302, 303, 304, 305, 306, 307, 308, 401, 402, 403, 404, 405, 406, 408]
	var actual: Array[int] = []
	for door: Node3D in _doors():
		actual.append(int(String(door.room)))
		assert_false(door is Interactable, "player cannot interact with room door")
		assert_false(door.is_open)
		assert_eq(door.blocker, door.get_node("Blocker"))
		assert_eq(door.blocker.collision_layer, 1)
		var from := _spawn(door) + Vector3.UP * .03
		var to := Vector3(from.x, from.y, 2)
		assert_true(_motion(from, to) < .8, "closed door blocks room %s" % door.room)
		assert_true(_motion(from + Vector3(.6, 0, 0), from) > .999, "second zombie fits beside spawn")
		door.set_open(true)
	actual.sort()
	assert_eq(actual, expected)
	await tree.create_timer(.4).timeout
	await tree.physics_frame
	for door: Node3D in _doors():
		assert_true(door.is_open)
		assert_eq(door.blocker.collision_layer, 0)
		assert_true(is_equal_approx(door.get_node("Hinge").rotation.y, PI / 2.0))
		var from := _spawn(door) + Vector3.UP * .03
		assert_true(_motion(from, Vector3(from.x, from.y, 2)) > .999, "opened door clears room %s" % door.room)
		door.set_open(false)
	await tree.create_timer(.4).timeout
	await tree.physics_frame
	for door: Node3D in _doors():
		assert_false(door.is_open)
		assert_eq(door.blocker.collision_layer, 1)
		assert_true(is_zero_approx(door.get_node("Hinge").rotation.y))
		var from := _spawn(door) + Vector3.UP * .03
		assert_true(_motion(from, Vector3(from.x, from.y, 2)) < .8, "reset closes room %s" % door.room)


func test_all_spawns_connect_to_hall_even_while_doors_are_closed() -> void:
	var map := fixture.get_world_3d().navigation_map
	NavigationServer3D.map_force_update(map)
	for frame in 12:
		await tree.physics_frame
	NavigationServer3D.map_force_update(map)
	for door: Node3D in _doors():
		var from := _spawn(door)
		var to := Vector3(22, from.y, 2)
		var path := NavigationServer3D.map_get_path(map, from, to, true)
		assert_true(path.size() >= 2, "nonempty route for %s" % door.room)
		if path.size() < 2:
			continue
		assert_true(path[0].distance_to(from) < .1, "route really starts inside room %s" % door.room)
		assert_true(path[-1].distance_to(to) < .1, "route reaches corridor for %s: %s" % [door.room, path])
		door.set_open(true)
	await tree.create_timer(.4).timeout
	await tree.physics_frame
	for door: Node3D in _doors():
		var from := _spawn(door)
		var path := NavigationServer3D.map_get_path(map, from, Vector3(22, from.y, 2), true)
		for index in range(path.size() - 1):
			assert_true(_motion(path[index] + Vector3.UP * .03, path[index + 1] + Vector3.UP * .03) > .999, "nav segment clears world for %s" % door.room)


func test_rooms_are_enclosed_and_408_is_separate_from_407() -> void:
	var space := fixture.get_world_3d().direct_space_state
	for door: Node3D in _doors():
		var from := _spawn(door) + Vector3.UP
		for direction in [Vector3.LEFT, Vector3.RIGHT, Vector3.BACK * -1, Vector3.UP, Vector3.DOWN]:
			var ray := PhysicsRayQueryParameters3D.create(from, from + direction * 9, 1)
			assert_false(space.intersect_ray(ray).is_empty(), "enclosed room %s toward %s" % [door.room, direction])
	assert_eq(floor4.get_node("Room407").position, Vector3(30, 0, 0))
	assert_eq(floor4.get_node("Door407").position, Vector3(32.44, .01, 0))
	assert_eq(campus.get_node("Anchors/RoomSpawns/B4/R408").position, Vector3(42, 0, -1.5))
	assert_true(_motion(Vector3(39, .03, -1.5), Vector3(37, .03, -1.5)) < .9, "wall separates new 408 from 407")
	assert_false(campus.has_node("Anchors/RoomSpawns/B4/R407"))
	assert_false(campus.has_node("Anchors/RoomSpawns/B2/R203"))


func test_distant_idle_markers_face_room407_and_zombie_door_contract_works() -> void:
	var idle := campus.get_node("Anchors/ZombieIdle/B4")
	assert_eq(idle.get_child_count(), 6)
	for marker: Node3D in idle.get_children():
		assert_true(marker.position.x >= .5 and marker.position.x <= 5)
		assert_true(marker.position.z > .5 and marker.position.z < 3.5)
		assert_true((-marker.basis.z).dot(Vector3.RIGHT) > .99)
		assert_true(_motion(marker.position + Vector3.UP * .03, marker.position + Vector3.UP * .03) > .999)
	var door := _doors()[0] as Node3D
	var bash := ZombieDoor.new()
	bash.door = door
	bash.blocker = door.blocker
	door.add_child(bash)
	assert_true(bash.is_closed())
	bash.bash(.2, .05)
	await tree.create_timer(.4).timeout
	await tree.physics_frame
	assert_true(bash.is_broken)
	assert_true(door.is_open)
	assert_eq(door.blocker.collision_layer, 0)
	assert_false(bash.is_closed())
	# A reversal cancels the previous swing, rather than leaving two tweens active.
	door.set_open(false)
	door.set_open(true)
	await tree.create_timer(.4).timeout
	assert_true(is_equal_approx(door.get_node("Hinge").rotation.y, PI / 2.0))
