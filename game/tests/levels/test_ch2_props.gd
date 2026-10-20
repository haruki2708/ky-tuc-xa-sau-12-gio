extends TestCase

const ROOM := "res://scenes/levels/floor4/room_407.tscn"
const STATES: Array[StringName] = [&"sit_play", &"talk", &"gagged", &"mumble", &"fall", &"revive", &"lunge", &"slump"]
var fixtures: Array[Node] = []


func spawn(path: String) -> Node3D:
	var node := (load(path) as PackedScene).instantiate() as Node3D
	fixtures.append(node)
	tree.root.add_child(node)
	return node


func after_each() -> void:
	for node in fixtures:
		node.queue_free()
	fixtures.clear()
	await wait_frames(2)


func test_all_states_move_reset_and_keep_legacy_api() -> void:
	for who in ["phuc", "viet", "dat"]:
		var body := spawn("res://scenes/levels/ch1_models/corpse_%s.tscn" % who)
		body.set_process(false)
		assert_true(body.is_in_group(&"ch2_corpse"))
		body.set_blood_visible(true)
		for state in STATES:
			assert_true(body.set_state(state), who + " " + state)
			body.set_process(false)
			body._process(.33)
			assert_true(body.get_node("Rig/Hips/Chest").transform.is_finite())
			assert_true(body.blood_visible, "blood independent of states")
		assert_false(body.set_state(&"unknown"))
		body.set_state(&"talk")
		body._process(.04)
		var mouth := body.get_node("Rig/Hips/Chest/Head/Mouth") as Node3D
		assert_true(mouth.scale.y > 1.5, "speaking mouth moves")
		body.set_state(&"gagged")
		assert_true(body.get_node("Rig/Hips/Chest/Head/Gag").visible)
		body.set_state(&"mumble")
		var head := body.get_node("Rig/Hips/Chest/Head") as Node3D
		var still := head.rotation
		body._process(.07)
		assert_true(head.rotation.distance_to(still) > .04, "mumble jerks head")
		body.set_state(&"fall")
		body._process(.5)
		assert_true(body.get_node("Rig/Hips/Chest").rotation.x > -.3, "fall settles")
		body.set_state(&"revive")
		body._process(.3)
		assert_true(body.get_node("Rig/Hips/Chest").rotation.x < -1.5, "revive returns upright")
		assert_true(body.get_node("Rig/Hips/Chest/Head/Gag").visible, "gag survives revival")
		body.set_state(&"lunge")
		body._process(.4)
		assert_true(absf(body.get_node("Rig").position.x) > 1.8, "lunge advances into aisle")
		assert_true(body.get_node("Rig/Hips/Chest/LeftArm").rotation.x > 1.5, "arms reach forward")
		var chest := body.get_node("Rig/Hips/Chest") as Node3D
		var arm := chest.get_node("LeftArm") as Node3D
		var hand := arm.get_node("Elbow/Hand") as Node3D
		assert_true(absf(hand.global_position.y - arm.global_position.y) < .02, "reaching arms compensate torso lean")
		body.set_pose(&"dead_a")
		assert_false(body.is_processing())
		assert_eq(body.get_node("Rig").position, Vector3(0, .145, -.82))
		assert_eq(mouth.scale, Vector3.ONE)
		assert_false(body.get_node("Rig/Hips/Chest/Head/Gag").visible)
		var count := 0
		for mesh: MeshInstance3D in body.find_children("*", "MeshInstance3D", true, false):
			count += mesh.mesh.get_faces().size() / 3
		assert_true(count < 1500, "%s: %d triangles" % [who, count])


func test_world_space_look_and_gag_mount_follow_moving_heads() -> void:
	var room := spawn(ROOM)
	room.position = Vector3(10, 2, 20)
	room.rotation.y = .7
	for number in [1, 2, 4]:
		var body := room.get_node("Anchors/Corpse%d/Body" % number)
		body.set_state(&"talk")
		var head := body.get_node("Rig/Hips/Chest/Head") as Node3D
		var local_head: Vector3 = body.to_local(head.global_position)
		assert_true(absf(local_head.x) > .54, "head clears upper bunk board at mattress edge")
		var chest := head.get_parent() as Node3D
		body.look_at_point(head.global_position + chest.global_basis * Vector3(.8, 0, -2))
		body._process(.1)
		assert_true(head.rotation.y < -.3, "world target converted to chest space")
		var anchor := room.get_node("Anchors/Gag%d" % number) as Marker3D
		anchor._process(0.0)
		assert_true(anchor.global_position.distance_to(head.to_global(Vector3(0, .005, -.14))) < .001)
		body.set_state(&"lunge")
		body._process(.3)
		anchor._process(0.0)
		assert_true(anchor.global_position.distance_to(head.to_global(Vector3(0, .005, -.14))) < .001)


func test_anchors_props_and_screen_are_reachable_from_stall() -> void:
	var room := spawn(ROOM)
	for name in ["RagSpot", "TowelSpot", "ShirtSpot", "Gag1", "Gag2", "Gag4", "ShowerScreen", "ShowerYes", "ShowerNo"]:
		assert_true(room.get_node("Anchors/" + name) is Marker3D, name)
	assert_eq(room.get_node("Anchors/RagSpot/Model").scene_file_path, "res://assets/models/graphics_pilot/room407_furnished/cleaning_rag.glb")
	assert_not_null(room.get_node("Clothesline"))
	var screen := room.get_node("Anchors/ShowerScreen/Surface") as MeshInstance3D
	assert_eq((screen.mesh as QuadMesh).size, Vector2(.4, .3))
	var stall := room.get_node("Anchors/ShowerStall") as Area3D
	for name in ["ShowerScreen", "ShowerYes", "ShowerNo"]:
		var target := room.get_node("Anchors/" + name) as Node3D
		assert_true(target.global_position.distance_to(stall.global_position + Vector3(0,.35,0)) < 1.0, "usable from inside stall")
	for name in ["towel", "shirt", "clothesline"]:
		var prop := spawn("res://scenes/levels/ch2/%s.tscn" % name)
		var count := 0
		for mesh: MeshInstance3D in prop.find_children("*", "MeshInstance3D", true, false):
			count += mesh.mesh.get_faces().size() / 3
		assert_true(count < 500, name + " small prop budget")


func test_zones_detect_player_and_exclude_other_rooms() -> void:
	var room := spawn(ROOM)
	room.position = Vector3(12,0,5)
	var body := CharacterBody3D.new()
	body.collision_layer = 2
	body.collision_mask = 0
	var shape := CollisionShape3D.new()
	var sphere := SphereShape3D.new()
	sphere.radius = .1
	shape.shape = sphere
	body.add_child(shape)
	room.add_child(body)
	for entry in [[Vector3(4,1,-2), "Bedroom"], [Vector3(2,1,-6), "Bedroom"], [Vector3(6.2,1,-6), "Bathroom"], [Vector3(2.8,1,-7.8), "Balcony"], [Vector3(4,1,.5), ""]]:
		body.position = entry[0]
		for i in range(3):
			await tree.physics_frame
		for name in ["Bedroom", "Bathroom", "Balcony"]:
			var zone := room.get_node("Zones/" + name) as Area3D
			assert_eq(zone.collision_layer, 0)
			assert_eq(zone.collision_mask, 2)
			assert_eq(zone.overlaps_body(body), name == entry[1], "zone " + name)
	body.position = Vector3(6.18,1,-6.32)
	for i in range(3):
		await tree.physics_frame
	assert_true(room.get_node("Anchors/ShowerStall").overlaps_body(body))
	body.position.x = 7.4
	for i in range(3):
		await tree.physics_frame
	assert_false(room.get_node("Anchors/ShowerStall").overlaps_body(body))


func test_water_steam_instance_isolation_and_reset() -> void:
	var room := spawn(ROOM)
	var other := spawn(ROOM)
	var effects := room.get_node("Ch2Bathroom")
	room.set_water(true, 8)
	assert_true(effects.get_node("Water").emitting)
	assert_false(effects.get_node("Steam").visible)
	room.set_water(true, 43)
	assert_true(effects.get_node("Steam").visible)
	room.set_steam(2.0)
	assert_eq(effects.steam_level, 1.0)
	assert_true(effects.get_node("MirrorFog").visible)
	assert_eq(other.get_node("Ch2Bathroom").steam_level, 0.0)
	assert_eq(other.get_node("Ch2Bathroom/Steam/Sheet0").material_override.get_shader_parameter("level"), 0.0)
	room.set_water(false, 43)
	assert_false(effects.get_node("Water").visible)
	assert_false(effects.get_node("Water").emitting)
	room.set_steam(NAN)
	assert_eq(effects.steam_level, 0.0)
	assert_false(effects.get_node("Steam").visible)
	assert_false(effects.get_node("MirrorFog").visible)
	room.flash_reflection()
	assert_true(effects.get_node("Reflection").visible)
	# Headless has no draw callback. Exercise exactly the callback used by renderer.
	RenderingServer.frame_post_draw.emit()
	assert_false(effects.get_node("Reflection").visible)
	assert_false(RenderingServer.frame_post_draw.is_connected(effects._clear_reflection))


func test_stuck_door_shakes_without_opening_then_cancels_on_open() -> void:
	var room := spawn(ROOM)
	var door := room.get_node("Extension/BathroomDoor")
	room.set_stuck_shake(1.0)
	await tree.create_timer(.07).timeout
	assert_false(door.is_open)
	assert_true(absf(door.get_node("Pivot").rotation.y) > .001)
	await tree.create_timer(.25).timeout
	assert_true(absf(door.get_node("Pivot").rotation.y) < .001)
	room.set_stuck_shake(1.0)
	room.set_bathroom_door_open(true)
	await tree.create_timer(.25).timeout
	assert_true(door.is_open)
	assert_true(absf(door.get_node("Pivot").rotation.y - door.open_angle()) < .001)
	room.set_bathroom_door_open(false)
	assert_eq(door.get_node("Pivot").rotation.y, 0.0)


func test_room310_keeps_existing_camera_contract_and_has_four_occupants() -> void:
	var set_root := spawn("res://scenes/levels/cctv/cctv_set.tscn")
	var room := set_root.get_node("Room310") as Node3D
	for name in ["Cam", "Hall/Cam", "Hall/Start", "Door", "VictimBed", "ManagerSpot", "Victim"]:
		assert_not_null(room.get_node_or_null(name), name)
	for number in [1, 2, 4]:
		var body := room.get_node("Corpse%d" % number)
		assert_eq(body.current_state, &"sit_play")
		assert_true(body.is_in_group(&"ch2_corpse"))
		var cam := room.get_node("Cam") as Camera3D
		var head := body.get_node("Rig/Hips/Chest/Head") as Node3D
		assert_false(cam.is_position_behind(head.global_position))
	assert_eq(room.get_node("Victim").current_pose, &"lie_awake")
