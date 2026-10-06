extends TestCase
## D-058: metric extents, continuous capsule motion and independent Floor4 nav.
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
	for frame in 3:
		await tree.physics_frame


func after_each() -> void:
	fixture.queue_free()
	await wait_frames(2)
	await tree.create_timer(.4).timeout


func _motion(from: Vector3, to: Vector3) -> float:
	var shape := CapsuleShape3D.new()
	shape.height = 1.75
	shape.radius = .3
	var query := PhysicsShapeQueryParameters3D.new()
	query.shape = shape
	query.collision_mask = 1
	query.margin = .001
	query.transform.origin = from + Vector3(0, .875, 0)
	query.motion = to - from
	var space := fixture.get_world_3d().direct_space_state
	assert_true(space.intersect_shape(query).is_empty(), "clear starting capsule %s" % from)
	return space.cast_motion(query)[0]


func test_four_metre_floors_and_straight_outer_lane_on_all_floors() -> void:
	for number in range(1, 5):
		var y := (number - 4) * 3.3
		var collider: CollisionShape3D = floor4.get_node("Corridor/Floor/Collision") if number == 4 else campus.get_node("BuildingB/Floor%d/Slab/Collision" % number)
		var box := collider.shape as BoxShape3D
		var front := collider.global_position.z + box.size.z / 2.0
		var back := collider.global_position.z - box.size.z / 2.0
		assert_true(front >= 3.8 and front <= 4.2, "floor %d corridor width %f" % [number, front])
		assert_true(is_equal_approx(back, 0.0 if number == 4 else -7.6), "room-side slab extent preserved")
		assert_true(is_equal_approx(box.size.x, 44.0), "length stays 44 m")
		assert_true(_motion(Vector3(.4, y + .03, 3), Vector3(43.6, y + .03, 3)) > .999, "continuous outer lane on floor %d" % number)
		for x in range(1, 44, 2):
			var ray := PhysicsRayQueryParameters3D.create(Vector3(x, y + .2, 3), Vector3(x, y - .3, 3), 1)
			var hit := fixture.get_world_3d().direct_space_state.intersect_ray(ray)
			assert_false(hit.is_empty(), "floor support at %d/%d" % [number, x])
			if not hit.is_empty():
				assert_true(absf(hit.position.y - y) < .002, "unchanged floor elevation")
		assert_true(_motion(Vector3(.5, y + .03, 3), Vector3(-1, y + .03, 3)) > .999, "west landing connects across full width")
		assert_true(_motion(Vector3(22, y + .03, 3), Vector3(22, y + .03, 5)) < .9, "outer railing still blocks")
	assert_eq(floor4.get_node("Room407").position, Vector3(30, 0, 0))
	assert_eq(floor4.get_node("Door407").position, Vector3(32.44, .01, 0))
	assert_true(campus.get_node("Garden/Paving").position.z - 20 > 4.2, "garden stays beyond expanded footprint")


func test_fire_door_blocks_new_outer_lane_until_opened() -> void:
	for z in [.6, 2.0, 3.5]:
		assert_true(_motion(Vector3(43, .03, z), Vector3(45, .03, z)) < .8, "closed leaf cannot be bypassed at z=%f" % z)
	campus.set_fire_door_open(true)
	await tree.physics_frame
	await tree.physics_frame
	for z in [.6, 2.0, 3.5]:
		assert_true(_motion(Vector3(43, .03, z), Vector3(45, .03, z)) > .999, "open fire landing at z=%f" % z)
	assert_false(floor4.get_node("Corridor/Navigation").enabled, "Campus owns the hall map while attached")


func test_floor4_standalone_navigation_reaches_both_ends_and_room407() -> void:
	campus.free()
	floor4.get_node("Door407").set_open(true)
	assert_true(floor4.get_node("Corridor/Navigation").enabled, "standalone navigation restored")
	assert_true(floor4.get_node("Corridor/Room407Link").enabled)
	for frame in 10:
		await tree.physics_frame
	var map := floor4.get_world_3d().navigation_map
	NavigationServer3D.map_force_update(map)
	for target in [Vector3(1, 0, 3), Vector3(43, 0, 3)]:
		var path := NavigationServer3D.map_get_path(map, Vector3(32, .03, -.7), target, true)
		assert_true(path.size() >= 2 and path[-1].distance_to(target) < .1, "manager can navigate from 407 to %s" % target)
		for index in range(path.size() - 1):
			assert_true(_motion(path[index] + Vector3.UP * .04, path[index + 1] + Vector3.UP * .04) > .999, "manager capsule clears navigation segment")


func test_cctv_floor4_corridor_width_and_camera_target() -> void:
	var cctv := (load("res://scenes/levels/cctv/cctv_set.tscn") as PackedScene).instantiate() as Node3D
	fixture.add_child(cctv)
	var collider := cctv.get_node("Corridor/Floor/Collision") as CollisionShape3D
	assert_eq((collider.shape as BoxShape3D).size.z, 4.0)
	var camera := cctv.get_node("Corridor/Cam") as Camera3D
	var direction := (Vector3(8, .9, .2) - camera.position).normalized()
	assert_true((-camera.basis.z).dot(direction) > .999, "security camera still frames the room doors")
	assert_eq(cctv.get_node("Corridor/Door407").position.z, 0.0)
