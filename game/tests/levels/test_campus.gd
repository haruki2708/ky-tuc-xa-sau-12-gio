extends TestCase

const CAMPUS := preload("res://scenes/levels/campus/campus.tscn")
var fixture: Node3D
var campus: Node3D


func before_each() -> void:
	fixture = Node3D.new()
	fixture.name = "CampusFixture"
	tree.root.add_child(fixture)
	campus = CAMPUS.instantiate()
	fixture.add_child(campus)
	await tree.physics_frame
	await tree.physics_frame


func after_each() -> void:
	fixture.queue_free()
	await wait_frames(2)


func test_contract_and_switches() -> void:
	for key in ["Start_garden", "Start_stadium", "Start_gate", "FireDoor", "FireKey", "Collapse2F", "Room203Door", "Extinguisher2F", "MainDoor1F", "ManagerWindow", "ManagerKnife", "NguBench", "GuardBooth", "CanteenTV", "CanteenClock", "CanteenExit", "Clues/Clock4F", "Clues/CrackStair", "Clues/SirenSpot", "Clues/GatePillar"]:
		assert_true(campus.get_anchor(key) is Marker3D, key)
	for area in ["B4", "B3", "B2", "B1", "Road", "Garden", "Stadium", "Gate", "Canteen"]:
		for category in ["ZombieSpawns", "ZombieIdle"]:
			var branch: Node3D = campus.get_anchor(category + "/" + area)
			assert_not_null(branch, category + area)
			if branch:
				assert_true(branch.get_child_count() >= 6, category + area)
	for who in ["Nhat", "Ngu"]:
		var route: Node3D = campus.get_anchor("Paths/" + who)
		assert_true(route.get_child_count() > 10, who)
		for index in route.get_child_count():
			assert_true(String(route.get_child(index).name).begins_with("P%02d" % (index + 1)), "ordered route")
	assert_eq(campus.get_anchor("GuardLine").get_child_count(), 12)
	assert_true(campus.get_anchor("BarSpawns").get_child_count() >= 6)
	for key in ["BuildingB", "Road", "Garden", "Stadium", "Gate", "Canteen", "GuardRadius", "Bleachers"]:
		var zone := campus.get_node("Zones/" + key) as Area3D
		assert_true(zone.get_node("Collision").shape is BoxShape3D, key)
		assert_eq(zone.collision_mask, 2)
	assert_false(campus.get_node("Navigation/FireDoorLink").enabled)
	campus.set_fire_door_open(true)
	assert_eq(campus.get_node("BuildingB/FireDoor/Leaf").collision_layer, 0)
	assert_true(campus.get_node("Navigation/FireDoorLink").enabled)
	campus.set_fire_door_open(false)
	assert_eq(campus.get_node("BuildingB/FireDoor/Leaf").collision_layer, 1)
	campus.set_main_door_chained(false)
	assert_eq(campus.get_node("BuildingB/MainDoor/Leaf").collision_layer, 0)
	assert_false(campus.get_node("BuildingB/MainDoor/Chains").visible)
	campus.set_main_door_chained(true)
	assert_eq(campus.get_node("BuildingB/MainDoor/Leaf").collision_layer, 1)
	campus.set_canteen_tv(true)
	assert_true(campus.get_node("Canteen/TV/Screen").visible)
	campus.set_stadium_lights(true)
	assert_true(campus.get_node("Stadium/Floodlights").visible)


func _capsule_clear(feet: Vector3, height: float) -> bool:
	var capsule := CapsuleShape3D.new()
	capsule.radius = .3
	capsule.height = height
	var query := PhysicsShapeQueryParameters3D.new()
	query.shape = capsule
	query.transform.origin = feet + Vector3(0, height * .5 + .015, 0)
	query.collision_mask = 1
	return campus.get_world_3d().direct_space_state.intersect_shape(query).is_empty()


func test_window_crouch_and_collapsed_stair_collision() -> void:
	var window: Vector3 = campus.get_anchor("ManagerWindow").global_position
	assert_true(_capsule_clear(window, 1.15), "crouched capsule fits the 1.44 m aperture")
	assert_false(_capsule_clear(window, 1.75), "standing capsule cannot cross the window")
	assert_false(_capsule_clear(Vector3(46.5, -6.6, -1), 1.75), "collapse physically blocks floor 2 flight")
	for y in [0.0, -3.3, -6.6, -9.9]:
		assert_true(_capsule_clear(Vector3(-.5, y, 1.2), 1.75), "main landing clear at %s" % y)
		assert_true(_capsule_clear(Vector3(-3.8, y, .5), 1.75), "descending flight entrance at %s" % y)


func test_navigation_connects_room407_stairs_window_and_canteen() -> void:
	var floor4 := (load("res://scenes/levels/floor4/floor4.tscn") as PackedScene).instantiate() as Node3D
	fixture.add_child(floor4)
	campus.attach_floor4(floor4)
	await tree.physics_frame
	await tree.physics_frame
	var map := campus.get_world_3d().navigation_map
	NavigationServer3D.map_force_update(map)
	for attempt in 120:
		if NavigationServer3D.map_get_iteration_id(map) > 0:
			break
		await tree.physics_frame
	# The large shared outdoor region synchronizes on a worker thread.
	for attempt in 180:
		if NavigationServer3D.map_get_closest_point(map, Vector3(32, 0, 1.2)).distance_to(Vector3(32, 0, 1.2)) < .1:
			break
		await tree.physics_frame
	var targets: Array[Vector3] = [Vector3(13.75, -6.6, -2), Vector3(4, -8.9, -7.6), Vector3(22, -9.9, 8), Vector3(115, -9.9, 166), Vector3(220, -9.9, -25), Vector3(190, -9.9, 32), Vector3(202, -9.9, 54), Vector3(198, -6.9, 224.8)]
	for target in targets:
		var path := NavigationServer3D.map_get_path(map, Vector3(32, .03, -2), target, true)
		assert_true(path.size() > 1 and path[-1].distance_to(target) < .5, "connected route to %s, last=%s" % [target, path[-1] if not path.is_empty() else Vector3.INF])
	assert_false(campus.has_node("Navigation/FireStairsDown2A"), "collapsed flight has no navigation surface")
	assert_eq(floor4.get_node("Corridor/WestEnd").collision_layer, 0)
	campus.queue_free()
	await wait_frames(2)
	assert_eq(floor4.get_node("Corridor/WestEnd").collision_layer, 1, "detach restores original Floor4")
	assert_true(floor4.get_node("Corridor/WestEnd").visible)
