extends TestCase

var floor_scene: Node3D
var room: Node3D


func before_each() -> void:
	floor_scene = load("res://scenes/levels/floor4/floor4.tscn").instantiate()
	tree.root.add_child(floor_scene)
	room = floor_scene.get_node("Room407")
	for i in range(3):
		await tree.physics_frame


func after_each() -> void:
	floor_scene.queue_free()
	await wait_frames(2)
	await tree.create_timer(.4).timeout


func test_both_bunks_have_clear_mattress_aim_from_aisle() -> void:
	for bed in range(1, 5):
		var target: Vector3 = room.get_node("Anchors/Bunks/Bunk%d" % bed).global_position
		var side: float = 1.0 if bed <= 2 else -1.0
		for distance: float in [.95, 1.15, 1.3]:
			for offset: float in [-.25, 0.0, .25]:
				var eye := Vector3(target.x + side * distance, 1.6, target.z + offset)
				var query := PhysicsRayQueryParameters3D.create(eye, target, 1)
				var hit := room.get_world_3d().direct_space_state.intersect_ray(query)
				assert_true(hit.is_empty(), "bed %d mattress ray from %s blocked by %s" % [bed, eye, hit.get("collider")])
	assert_eq(room.get_node("BunkA").position, Vector3(.65, 0, -3))
	assert_eq(room.get_node("BunkB").position, Vector3(7.35, 0, -2.7))


func test_real_player_cannot_walk_through_either_bunk() -> void:
	var player := load("res://scenes/player/player.tscn").instantiate() as CharacterBody3D
	floor_scene.add_child(player)
	player.set_physics_process(false)
	player.set_process_unhandled_input(false)
	for bed in [2, 3]:
		var target: Vector3 = room.get_node("Anchors/Bunks/Bunk%d" % bed).global_position
		var side: float = 1.0 if bed == 2 else -1.0
		for crouch: bool in [false, true]:
			player._set_crouched(crouch)
			player.global_position = Vector3(target.x + side * 1.3, .03, target.z)
			await tree.physics_frame
			var collision := player.move_and_collide(Vector3(-side * 2.5, 0, 0))
			assert_not_null(collision, "player blocked by bed %d, crouch %s" % [bed, crouch])
			assert_true((player.global_position.x - target.x) * side > .65, "player remains on aisle side")
	player.queue_free()


func test_door_tween_timing_collision_anchor_and_legacy_api() -> void:
	var door := floor_scene.get_node("Door407")
	var pivot := door.get_node("Pivot") as Node3D
	door.set_open(true, 1.5)
	assert_true(absf(pivot.rotation.y) < .001, "no immediate snap")
	await tree.create_timer(.7).timeout
	assert_true(pivot.rotation.y < -.3 and pivot.rotation.y > -1.2, "partly open at 0.7 seconds")
	_assert_door_collision_and_anchor(door)
	await tree.create_timer(.65).timeout
	assert_true(pivot.rotation.y > -PI / 2.0 + .005, "not finished before 1.5 seconds")
	await tree.create_timer(.25).timeout
	assert_true(absf(pivot.rotation.y + PI / 2.0) < .001, "finished after 1.5 seconds")
	door.set_open(false)
	assert_eq(pivot.rotation.y, 0.0)
	door.set_open(true)
	assert_true(absf(pivot.rotation.y + PI / 2.0) < .001, "legacy open is immediate")


func _assert_door_collision_and_anchor(door: Node) -> void:
	var pivot := door.get_node("Pivot") as Node3D
	var center: Vector3 = pivot.to_global(Vector3(-.44, 1.0, 0))
	var normal: Vector3 = pivot.global_basis.z
	var hit := room.get_world_3d().direct_space_state.intersect_ray(
		PhysicsRayQueryParameters3D.create(center + normal * .2, center - normal * .2, 1))
	assert_false(hit.is_empty(), "physical leaf follows the tween")
	if not hit.is_empty():
		assert_true(door.is_ancestor_of(hit.collider), "hit moving door collision")
	var paper := door.get_node("Pivot/RulesPaper") as Node3D
	var anchor := floor_scene.get_node("Anchors/RulesPaper407") as Node3D
	assert_true(anchor.global_position.is_equal_approx(paper.global_position), "paper anchor follows tween")
	assert_true(anchor.global_basis.z.is_equal_approx(-paper.global_basis.z), "paper anchor faces inside")


func test_door_reversal_reset_and_rattle_during_animation() -> void:
	var door := floor_scene.get_node("Door407")
	var pivot := door.get_node("Pivot") as Node3D
	door.set_open(true, 1.5)
	await tree.create_timer(.5).timeout
	var angle: float = pivot.rotation.y
	door.set_open(false, .5)
	assert_true(is_equal_approx(angle, pivot.rotation.y), "reverse from current angle")
	door.rattle(1.0)
	door.stop_rattle()
	assert_true(is_equal_approx(angle, pivot.rotation.y), "rattle cannot snap active swing")
	await tree.create_timer(.65).timeout
	assert_true(absf(pivot.rotation.y) < .001)
	door.rattle(1.0)
	door._process(.04)
	assert_true(absf(door.get_node("Pivot/HandlePivot").rotation.z) > .01)
	door.set_open(true, 1.5)
	assert_eq(door.get_node("Pivot/HandlePivot").rotation.z, 0.0)
	door.set_open(false)
	await tree.create_timer(.1).timeout
	assert_eq(pivot.rotation.y, 0.0, "instant reset cancels old tween")


func test_navigation_reaches_balcony_and_bathroom_without_crossing_solids() -> void:
	floor_scene.get_node("Door407").set_open(true)
	room.set_bathroom_door_open(true)
	await tree.physics_frame
	await tree.physics_frame
	var nav_map: RID = room.get_world_3d().navigation_map
	var start := Vector3(32, .03, .3)
	# Map sync runs asynchronously; a heavier floor (T-215) can need more than two physics frames.
	for i in range(120):
		if NavigationServer3D.map_get_path(nav_map, start, room.to_global(Vector3(2.8, .03, -7.8)), true).size() >= 2:
			break
		await tree.physics_frame
	for local_target: Vector3 in [Vector3(2.8, .03, -7.8), Vector3(.6, .03, -7.8), Vector3(4.6, .03, -7.8), Vector3(6.18, .03, -6.3), Vector3(6.85, .03, -4.6)]:
		var target: Vector3 = room.to_global(local_target)
		var path: PackedVector3Array = NavigationServer3D.map_get_path(nav_map, start, target, true)
		assert_true(path.size() >= 2, "route exists to %s" % local_target)
		if path.size() < 2:
			continue
		assert_true(path[0].distance_to(start) < .05, "starts at door")
		assert_true(path[-1].distance_to(target) < .05, "ends at requested destination, not closest old polygon")
		for i in range(1, path.size()):
			_assert_capsule_clear(path[i - 1], path[i])


func _assert_capsule_clear(start: Vector3, end: Vector3) -> void:
	var capsule := CapsuleShape3D.new()
	capsule.radius = .35
	capsule.height = 1.9
	var query := PhysicsShapeQueryParameters3D.new()
	query.shape = capsule
	query.collision_mask = 1
	query.transform.origin = start + Vector3(0, .95, 0)
	query.motion = end - start
	var space := room.get_world_3d().direct_space_state
	assert_true(space.intersect_shape(query).is_empty(), "route point clear: %s" % start)
	var motion := space.cast_motion(query)
	assert_true(motion[0] > .999, "capsule route blocked: %s -> %s (%s)" % [start, end, motion])


func test_khoa_note_slot_and_recessed_outlet() -> void:
	var anchor := room.get_node("Anchors/KhoaNoteSlot") as Marker3D
	assert_not_null(anchor)
	assert_true(anchor.global_position.is_equal_approx(Vector3(30.2, .015, -1.8)))
	var outlet := room.get_node("Anchors/KhoaOutlet") as Node3D
	var triangles: int = 0
	for mesh: MeshInstance3D in outlet.find_children("*", "MeshInstance3D", true, false):
		triangles += mesh.mesh.get_faces().size() / 3
	assert_true(triangles > 0 and triangles < 500)
	assert_true(outlet.get_node("Cover").position.y - .06 > outlet.get_node("BottomTrim").position.y + .011, "open slit beneath cover")
	var hit := room.get_world_3d().direct_space_state.intersect_ray(PhysicsRayQueryParameters3D.create(
		Vector3(31, .15, -1.8), anchor.global_position + Vector3(0, .01, 0), 1))
	assert_true(hit.is_empty(), "note landing point is outside the wall and reachable")
