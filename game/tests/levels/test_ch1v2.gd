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


func test_anchors_extent_bounds_and_navigation() -> void:
	for name in ["PowerStrip","LanBlueEnd","LanGrayEnd","LanWallPort","VietLocker","PhucMattress","TrashBin","TeamPhoto","GuitarSongbook","PhucCard","DeskLampSwitch","DatLocker","DatNote","Router","WallKnock406","WallKnock408","ManagerApproach","PhucBooks","VietPhoto","TrungChargingCable"]:
		assert_true(room.get_node("Anchors/"+name) is Marker3D,name)
	assert_eq(room.get_node("Floor/Collision").shape.size,Vector3(8,.2,7))
	assert_eq(room.global_position,Vector3(30,0,0))
	assert_eq(room.get_node("BunkB").position,Vector3(7.35,0,-2.7))
	var body := CharacterBody3D.new()
	body.collision_layer = 2
	body.collision_mask = 0
	var shape := CollisionShape3D.new()
	shape.shape = SphereShape3D.new()
	shape.shape.radius = .05
	body.add_child(shape)
	room.add_child(body)
	for point in [Vector3(4,1,-3),Vector3(6.8,1,-5.5),Vector3(2.8,1,-7.8)]:
		body.position = point
		for i in range(3):
			await tree.physics_frame
		assert_true(room.get_node("Bounds").overlaps_body(body),"inside bounds "+str(point))
	body.position = Vector3(2,1,.6)
	for i in range(3):
		await tree.physics_frame
	assert_false(room.get_node("Bounds").overlaps_body(body),"corridor outside Bounds")
	var map := room.get_world_3d().navigation_map
	var destination: Vector3 = room.get_node("Anchors/ManagerApproach").global_position
	var path := NavigationServer3D.map_get_path(map,Vector3(32,.03,-.7),destination,true)
	assert_true(path.size() >= 2,"connected manager navmesh")
	if path.size() >= 2:
		assert_true(path[-1].distance_to(destination)<.1,"navmesh reaches bed 3 approach")
		for i in range(path.size()-1):
			assert_true(_motion(room.to_local(path[i]),room.to_local(path[i+1]))>.999,"manager capsule clears furniture")
	for pair in [["Bunks/Bunk1/View","WallKnock406"],["Bunks/Bunk4/View","WallKnock408"]]:
		assert_true(room.get_node("Anchors/"+pair[0]).global_position.distance_to(room.get_node("Anchors/"+pair[1]).global_position)<1.5,"wall knock reachable from bed")


func _motion(from: Vector3,to: Vector3) -> float:
	var query := PhysicsShapeQueryParameters3D.new()
	var capsule := CapsuleShape3D.new()
	capsule.radius = .3
	capsule.height = 1.75
	query.shape = capsule
	query.transform.origin = room.to_global(from+Vector3(0,.875,0))
	query.motion = to-from
	query.collision_mask = 1
	return room.get_world_3d().direct_space_state.cast_motion(query)[0]


func test_bathroom_balcony_routes_and_door_collision() -> void:
	assert_true(_motion(Vector3(5.85,.03,-3.3),Vector3(5.85,.03,-4.7))<.9,"bath door closed blocks")
	room.set_bathroom_door_open(true)
	await tree.physics_frame
	await tree.physics_frame
	assert_true(_motion(Vector3(5.85,.03,-3.3),Vector3(5.85,.03,-5.5))>.999,"bathroom entry clear")
	assert_true(_motion(Vector3(2.8,.03,-6.3),Vector3(2.8,.03,-7.8))>.999,"balcony reachable")
	assert_true(_motion(Vector3(2.8,.03,-7.8),Vector3(2.8,.03,-9.0))<.9,"balcony rail blocks exit")
	room.set_bathroom_door_open(false)
	assert_false(room.get_node("Extension/BathroomDoor").is_open)
	assert_eq(room.get_node("Extension/FloorBalcony").get_meta("surface"),&"tile")
	assert_eq(room.get_node("Floor").get_meta("surface"),&"tile")
	assert_not_null(floor_scene.get_node("Corridor/Sealed408"))
	assert_true(floor_scene.get_node_or_null("Corridor/BackWall_408")==null,"old 408 wall cannot cut bathroom")


func test_strip_is_the_blender_model_with_plugs_and_leads() -> void:
	# T-226 (D-136, owner: the strip and the network ends were still boxes).
	var strip := room.get_node("Anchors/PowerStrip")
	assert_eq(strip.position, Vector3(1.35, .02, -2.35), "where chapter 1 used to nudge it, by the plugs' leads")
	var case := strip.get_node("Case") as MeshInstance3D
	assert_false(case.mesh is PrimitiveMesh, "modelled case")
	assert_true(strip.get_node_or_null("Model") == null, "the model's parts moved onto the gameplay nodes")
	for i in range(1, 4):
		var rocker := strip.get_node("Switch%d/Rocker/Rocker%d" % [i, i]) as MeshInstance3D
		assert_not_null(rocker, "rocker %d rides its pivot" % i)
		var led := strip.get_node("Switch%d/LED" % i) as MeshInstance3D
		assert_true(led.mesh != null and not (led.mesh is PrimitiveMesh), "lamp %d" % i)
		var top: float = (case.global_transform * case.get_aabb()).end.y
		assert_true(absf(led.global_position.y - top) < .005, "lamp %d sits in the case top" % i)
	for plug in ["LaptopPlug", "RouterPlug", "KettlePlug"]:
		assert_not_null(strip.get_node_or_null(plug + "/Body"), plug)
	assert_not_null(strip.get_node_or_null("RouterPlug/RedTape"), "the router's plug keeps its red tape")
	var cables := room.get_node("Cables")
	for lead in ["StripPower", "FanPower", "StripPlug", "FanPlug"]:
		assert_not_null(cables.get_node_or_null(lead), lead)
	assert_not_null(room.get_node_or_null("Anchors/LanWallPort/PortFace/Jacks"), "modelled LAN faceplate")
	var plug := room.get_node("Anchors/LanBlueEnd/Plug") as Node3D
	assert_not_null(plug.get_node_or_null("Contacts"), "modelled RJ45 plug")
	assert_true(absf(room.get_node("Anchors/LanBlueEnd").position.y - .0045) < .001, "the loose plug lies on the floor")


func test_switches_trip_and_sparks_reset() -> void:
	var strip := room.get_node("Anchors/PowerStrip")
	for i in range(1,4):
		assert_true(strip.get_node("Switch%d"%i) is Marker3D)
		strip.set_switch(i,true)
		assert_true(strip.get_node("Switch%d/LED"%i).visible)
	strip.set_tripped(true)
	for i in range(1,4):
		assert_false(strip.get_node("Switch%d/LED"%i).visible)
	strip.set_switch(2,true)
	assert_false(strip.get_node("Switch2/LED").visible,"tripped state cannot show live switch")
	strip.set_tripped(false)
	strip.set_switch(2,true)
	assert_true(strip.get_node("Switch2/LED").visible)
	assert_false(strip.set_switch(0,true))
	strip.spark()
	assert_true(strip.get_node("Sparks").visible)
	strip._process(.2)
	assert_false(strip.get_node("Sparks").visible)


func test_cables_router_states_and_instance_independence() -> void:
	var blue := room.get_node("Anchors/LanBlueEnd") as Node3D
	var gray := room.get_node("Anchors/LanGrayEnd") as Node3D
	var blue_floor := blue.position
	var gray_floor := gray.position
	assert_not_null(room.get_node("Cables/BlueCable").mesh,"blue cable visible before interaction")
	assert_not_null(room.get_node("Cables/GrayCable").mesh,"gray cable visible before interaction")
	assert_true(room.set_plugged(&"blue",true))
	assert_true(blue.position.distance_to(room.get_node("Anchors/LanWallPort").position)<.1)
	assert_eq(gray.position,gray_floor)
	room.set_plugged(&"blue",false)
	assert_eq(blue.position,blue_floor)
	assert_false(room.set_plugged(&"unknown",true))
	var router := room.get_node("Anchors/Router/Model")
	router.set_power(true)
	router.set_network(&"booting")
	assert_true(router.get_node("NetworkLED").visible)
	router._process(.35)
	assert_false(router.get_node("NetworkLED").visible)
	assert_true(router.get_node("LED").visible,"power remains steady while network blinks")
	router.set_network(&"red")
	assert_true(router.get_node("NetworkLED").material_override.albedo_color.r>.9)
	router.set_network(&"ok")
	assert_true(router.get_node("NetworkLED").material_override.albedo_color.g>.9)
	router.set_power(false)
	assert_false(router.get_node("LED").visible)
	assert_false(router.get_node("NetworkLED").visible)
	assert_false(router.set_network(&"bad"))


func test_search_props_mattress_followers_and_lamp_reset() -> void:
	var locker := room.get_node("Anchors/VietLocker")
	locker.set_open(true)
	assert_true(locker.get_node("Pivot").rotation.y>1.5)
	locker.set_open(false)
	assert_eq(locker.get_node("Pivot").rotation.y,0.0)
	var mattress := room.get_node("Anchors/PhucMattress")
	var body := room.get_node("Anchors/Corpse1/Body") as Node3D
	var original := body.global_transform
	mattress.set_lifted(true)
	assert_true(body.global_position.y>original.origin.y+.2,"body follows lifted mattress")
	mattress.set_lifted(false)
	assert_true(body.global_transform.is_equal_approx(original),"exact reset retains public node path")
	for pair in [["VietLocker/Paper1",1],["PhucMattress/Paper2",2],["TrashBin/Paper3",3]]:
		assert_eq(room.get_node("Anchors/"+pair[0]).fragment_id,pair[1])
	room.set_flicker(true)
	room.set_desk_lamp(false)
	assert_eq(room.get_node("Room407DeskLamp").light_energy,0.0)
	assert_false(room.get_node("Room407DeskLamp").flickering)
	assert_true(room.get_node("Room407DeskLamp/Fixture").is_visible_in_tree(),"physical lamp stays visible when off")
	room.set_desk_lamp(true)
	assert_true(room.get_node("Room407DeskLamp").light_energy>0)
	room.set_flicker(false)


func test_door_rattle_stays_closed_and_cancels_cleanly() -> void:
	var door := floor_scene.get_node("Door407")
	door.rattle(1.0)
	door._process(.04)
	assert_false(door.is_open)
	assert_true(absf(door.get_node("Pivot/HandlePivot").rotation.z)>.01)
	assert_true(absf(door.get_node("Pivot").rotation.y)<.01)
	door.stop_rattle()
	assert_eq(door.get_node("Pivot").rotation.y,0.0)
	assert_eq(door.get_node("Pivot/HandlePivot").rotation.z,0.0)
	door.rattle(.1)
	door._process(.2)
	assert_eq(door.get_node("Pivot").rotation.y,0.0)
	door.rattle(2)
	door.set_open(true)
	door._process(.1)
	assert_true(door.is_open)
	assert_true(absf(door.get_node("Pivot").rotation.y+PI/2)<.001)


func test_new_prop_triangle_budgets() -> void:
	for model in ["power_strip","viet_locker","phuc_mattress","bunk_a_frame","trash_bin","torn_paper","team_photo","guitar_songbook","phuc_card","bathroom_door"]:
		var node := load("res://scenes/levels/ch1v2/"+model+".tscn").instantiate() as Node3D
		tree.root.add_child(node)
		var triangles := 0
		for mesh: MeshInstance3D in node.find_children("*","MeshInstance3D",true,false):
			triangles += mesh.mesh.get_faces().size()/3
		var limit := 1500 if model in ["viet_locker","phuc_mattress","bunk_a_frame","bathroom_door"] else 500
		# T-226 (D-136): the strip is a Blender model now (~3.2k triangles, rockers and lamps included) with
		# its three plugs (~1.1k each); a Tripo prop of the room is baked to 5k (D-093).
		if model == "power_strip":
			limit = 8000
		assert_true(triangles>0 and triangles<limit,model+" triangle budget")
		print("T162_TRIANGLES: %s %d"%[model,triangles])
		node.queue_free()
	await wait_frames(2)
