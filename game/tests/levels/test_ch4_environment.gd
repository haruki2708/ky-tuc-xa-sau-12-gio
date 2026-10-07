extends TestCase
## Physical routes and contracts, not chapter-4 story logic.
var fixture: Node3D
var campus: Node3D
var floor4: Node3D
var anchors: Node3D


func before_each() -> void:
	fixture = Node3D.new()
	tree.root.add_child(fixture)
	floor4 = load("res://scenes/levels/floor4/floor4.tscn").instantiate()
	fixture.add_child(floor4)
	campus = load("res://scenes/levels/campus/campus.tscn").instantiate()
	fixture.add_child(campus)
	anchors = campus.get_node("Anchors/Ch4")
	await wait_frames(3)
	var map := fixture.get_world_3d().navigation_map
	NavigationServer3D.map_force_update(map)
	# The complete campus synchronizes thousands of regions asynchronously.
	# Wait for a real cross-region route, not an arbitrary count of frames.
	for frame in 180:
		await tree.physics_frame
		var ready_path := NavigationServer3D.map_get_path(map, Vector3(.5,-9.9,2), Vector3(-4,-9.9,2.8), true)
		if ready_path.size() >= 2 and ready_path[-1].distance_to(Vector3(-4,-9.9,2.8)) < .1:
			break


func after_each() -> void:
	fixture.queue_free()
	await wait_frames(3)
	await tree.create_timer(.35).timeout


func _clear(point: Vector3, height: float = 1.75) -> bool:
	var shape := CapsuleShape3D.new()
	shape.radius = .3
	shape.height = height
	var query := PhysicsShapeQueryParameters3D.new()
	query.shape = shape
	query.collision_mask = 1
	query.margin = .001
	query.transform.origin = point + Vector3(0, height / 2.0 + .06, 0)
	return fixture.get_world_3d().direct_space_state.intersect_shape(query).is_empty()


func _route(from: Vector3, to: Vector3) -> void:
	var map := fixture.get_world_3d().navigation_map
	var path := NavigationServer3D.map_get_path(map, from, to, true)
	assert_true(path.size() >= 2, "route exists %s -> %s" % [from, to])
	if path.size() < 2:
		return
	assert_true(path[0].distance_to(from) < .15, "route starts at anchor: %s vs %s" % [path[0], from])
	assert_true(path[-1].distance_to(to) < .15, "route reaches target: %s vs %s" % [path[-1], to])
	for index in range(path.size() - 1):
		var count := maxi(1, ceili(path[index].distance_to(path[index + 1]) / .2))
		for step in range(count + 1):
			var point := path[index].lerp(path[index + 1], float(step) / count)
			var height := 1.15 if point.x > 3 and point.x < 5 and point.z < -6 and point.y < -7.5 else 1.75
			if not _clear(point, height):
				assert_true(false, "capsule blocked at %s on %s -> %s" % [point, from, to])
				return


func test_new_doors_block_open_reclose_and_accept_zombie_door() -> void:
	for door: Node3D in [campus.get_node("Library/BackDoor"), anchors.get_node("Room407/Door")]:
		assert_true(door.is_in_group(&"room_doors"))
		assert_eq(door.blocker, door.get_node("Blocker"))
		var point := Vector3(65,-9.9,225) if door.room == &"library_back" else Vector3(32,0,0)
		assert_false(_clear(point), "closed capsule blocked: %s" % door.room)
		door.set_open(true)
		await tree.create_timer(.4).timeout
		await tree.physics_frame
		assert_true(door.is_open)
		assert_eq(door.blocker.collision_layer, 0)
		for z in [-.6,0,.6]:
			assert_true(_clear(point + Vector3(0,0,z)), "opened capsule clear %s z=%s" % [door.room,z])
		door.set_open(false)
		await tree.create_timer(.4).timeout
		await tree.physics_frame
		assert_false(_clear(point), "reclosed capsule blocked")
		var bash := ZombieDoor.new()
		bash.door = door
		bash.blocker = door.blocker
		door.add_child(bash)
		bash.bash(.2,.05)
		await tree.create_timer(.4).timeout
		assert_true(bash.is_broken)
		assert_true(door.is_open)
		assert_true(_clear(point))


func test_routes_split_library_return_room_and_all_library_floors() -> void:
	for key in ["Start_split","Start_library","Start_return","Start_407","Counter","MapBoard","ReadingDesk","LibrarianSeat","ScareShelf3F","ThrownBook3F"]:
		assert_true(anchors.get_node(key) is Marker3D,key)
	assert_eq(anchors.get_node("LibraryZombieSpawn").get_child_count(),6)
	campus.get_node("Library/BackDoor").set_open(true)
	anchors.get_node("Room407/Door").set_open(true)
	await tree.create_timer(.4).timeout
	for pair in [["Start_split","Start_library"],["Start_library","Start_return"],["Start_return","Start_407"]]:
		_route(anchors.get_node(pair[0]).global_position, anchors.get_node(pair[1]).global_position)
	_route(Vector3(172,-9.9,40.5),anchors.get_node("Start_split").global_position)
	for target in [Vector3(65,-6.6,211),Vector3(65,-3.3,211)]:
		_route(anchors.get_node("Start_library").global_position,target)
	_route(Vector3(65,-9.9,211),Vector3(60,-9.9,207.5))
	_route(Vector3(65,-6.6,211),Vector3(60.2,-6.6,216))
	for spawn: Node3D in anchors.get_node("LibraryZombieSpawn").get_children():
		_route(spawn.global_position,Vector3(65,-9.9,226))
	# Closing the leaf must still allow zombies to approach from outdoors.
	campus.get_node("Library/BackDoor").set_open(false)
	await tree.create_timer(.4).timeout
	_route(Vector3(62,-9.9,228),Vector3(65,-9.9,226))


func test_stair_crowd_markers_reachable_and_have_passing_space() -> void:
	var crowd := anchors.get_node("StairCrowd")
	assert_eq(crowd.get_child_count(),10)
	for marker: Node3D in crowd.get_children():
		assert_true(marker.position.x < 0 and marker.position.x > -5)
		_route(Vector3(.5,marker.position.y,2),marker.global_position)
		assert_true(_clear(marker.global_position))
	for a: Node3D in crowd.get_children():
		for b: Node3D in crowd.get_children():
			if a != b and is_equal_approx(a.position.y,b.position.y):
				assert_true(a.position.distance_to(b.position) >= 1.4, "space for two zombie radii and player")


func test_slats_fake_spots_and_damage_layers_preserve_legacy_door() -> void:
	for bed in [1,2,4]:
		var slat := anchors.get_node("Room407/Slat%d" % bed) as Marker3D
		var bunk := floor4.get_node("Room407/Anchors/Bunks/Bunk%d" % bed) as Marker3D
		assert_true(slat.global_position.distance_to(bunk.global_position)<.1)
		EventBus.bed_slat_flipped.emit(bed)
		assert_true(slat.flipped)
	await tree.create_timer(.5).timeout
	for bed in [1,2,4]:
		var slat := anchors.get_node("Room407/Slat%d" % bed)
		assert_true(absf(slat.get_node("Hinge").rotation.z)>1.0)
		slat.set_flipped(false)
	for key in ["FakeLocker","FakeCeiling","FakeVent"]:
		assert_true(anchors.get_node("Room407/"+key) is Marker3D)
	var proxy := anchors.get_node("Room407/Door")
	var original := floor4.get_node("Door407")
	original.set_open(true)
	await wait_frames(2)
	assert_true(proxy.is_open)
	assert_eq(proxy.blocker.collision_layer,0)
	original.set_open(false)
	await wait_frames(2)
	assert_false(proxy.is_open)
	for fraction in [0.0,.3,.6,.8,1.0,0.0]:
		EventBus.door_damage_changed.emit(&"407",fraction)
		assert_eq(proxy.get_node("Damage/Cracks").visible,fraction>=.3)
		assert_eq(proxy.get_node("Damage/Hole").visible,fraction>=.6)
		assert_eq(proxy.get_node("Damage/Hand").visible,fraction>=.8)
		assert_eq(original.get_node("Pivot/Leaf").visible,fraction<.6)
	EventBus.door_damage_changed.emit(&"library_back",1.0)
	assert_eq(proxy.damage_fraction,0.0)


func test_proxy_teardown_restores_standalone_room407() -> void:
	var original := floor4.get_node("Door407")
	var net := floor4.get_node("Room407/BunkA/Net_Phuc") as Node3D
	var old_visibility := net.visible
	EventBus.bed_slat_flipped.emit(1)
	EventBus.door_damage_changed.emit(&"407",.8)
	assert_false(net.visible)
	campus.queue_free()
	await wait_frames(3)
	await tree.physics_frame
	assert_eq(net.visible,old_visibility)
	assert_true(original.get_node("Pivot/Leaf").visible)
	assert_false(_clear(Vector3(32,0,0)), "legacy leaf collision restored")
	original.set_open(true)
	await tree.physics_frame
	assert_true(_clear(Vector3(32,0,0)))


func _triangles(node: Node) -> int:
	var result := 0
	if node is MeshInstance3D and node.mesh != null:
		result += node.mesh.get_faces().size() / 3
	for child in node.get_children():
		result += _triangles(child)
	return result


func test_hospital_contract_occupancy_and_triangle_budgets() -> void:
	var hospital: Node3D = load("res://scenes/levels/hospital/hospital_room.tscn").instantiate()
	fixture.add_child(hospital)
	for name in ["Trung","Nhat","Ngu"]:
		assert_true(hospital.get_node("Bed_"+name+"/Card") is Marker3D)
		assert_true(_triangles(hospital.get_node("Bed_"+name))<1500)
	for key in ["Nurse1","Nurse2","MonitorAudio"]:
		assert_true(hospital.get_node(key) is Marker3D)
	assert_true(hospital.get_node("Camera_Wake") is Camera3D)
	hospital.set_companions_visible(false)
	assert_false(hospital.get_node("Bed_Nhat/Patient").visible)
	assert_false(hospital.get_node("Bed_Ngu/Patient").visible)
	hospital.set_companions_visible(true)
	assert_true(hospital.get_node("Bed_Nhat/Patient").visible)
	for child in campus.get_node("Library").get_children():
		if String(child.name).begins_with("Shelf"):
			assert_true(_triangles(child)<1500)
	assert_true(_triangles(anchors.get_node("Room407/Door"))<500)
	for bed in [1,2,4]: assert_true(_triangles(anchors.get_node("Room407/Slat%d"%bed))<500)
	for node in [campus.get_node("Library"),anchors,hospital]:
		print("T196_TRIANGLES: %s %d"%[node.name,_triangles(node)])
	hospital.queue_free()
