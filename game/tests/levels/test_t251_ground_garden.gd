extends TestCase
## T-251: real chapter visibility, checkpoint placement and physical garden clearance.

var scene: Node3D


func after_each() -> void:
	if is_instance_valid(scene):
		scene.queue_free()
		await wait_frames(3)
	Chapter1Director.resume_checkpoint = &""
	Checkpoint.clear()
	GameState.reset()
	RuleSystem.reset()


func _chapter(number: int) -> Chapter1Director:
	scene = load("res://scenes/main/chapter%d.tscn" % number).instantiate()
	var director: Chapter1Director = scene.get_node("Chapter%dDirector" % number)
	director.auto_start = false
	Chapter1Director.resume_checkpoint = &""
	tree.root.add_child(scene)
	return director


func test_only_campus_chapters_hide_the_room_backdrop() -> void:
	for number in range(1, 5):
		_chapter(number)
		await wait_frames(3)
		var outside: Node3D = scene.get_node("Floor4/Room407/Furnished/outside")
		for mesh: Node3D in outside.get_children():
			assert_eq(mesh.is_visible_in_tree(), number <= 2, "chapter %d: %s" % [number, mesh.name])
		assert_true(scene.get_node("Floor4/Room407/Furnished/architecture").is_visible_in_tree(), "room remains visible")
		scene.queue_free()
		await wait_frames(3)


func test_garden_direct_start_keeps_both_feet_on_the_ground() -> void:
	var director := _chapter(3) as Chapter3Director
	await wait_frames(3)
	director.run_from(&"garden")
	await _check_garden_pair(director)


func test_garden_saved_checkpoint_keeps_both_feet_on_the_ground() -> void:
	var director := _chapter(3) as Chapter3Director
	await wait_frames(3)
	GameState.chapter = 3
	Checkpoint.save(&"ch3_garden")
	Chapter1Director.resume_checkpoint = &"ch3_garden"
	director.start()
	await _check_garden_pair(director)


func _check_garden_pair(director: Chapter3Director) -> void:
	var player: CharacterBody3D = scene.get_node("Player")
	assert_true(director._companions.has(&"minh_nhat"), "Nhat joins immediately")
	if not director._companions.has(&"minh_nhat"):
		return
	var nhat: CharacterBody3D = director._companions[&"minh_nhat"]
	var start: Node3D = scene.get_node("Campus/Anchors/Start_garden")
	for frame in 30:
		await tree.physics_frame
		var delta := player.global_position - nhat.global_position
		assert_true(Vector2(delta.x, delta.z).length() >= 0.6, "separate capsules, frame %d" % frame)
		assert_true(absf(delta.y) < 0.1, "neither stands on the other, frame %d" % frame)
		assert_true(absf(player.global_position.y - start.global_position.y) < 0.1, "player at garden floor")
	assert_true(player.global_position.distance_to(start.global_position) < 0.1, "original player checkpoint preserved")
	assert_true((-player.global_basis.z).dot(Vector3.BACK) > 0.99, "faces into the garden")
	assert_true(nhat.following, "existing follow behavior preserved")
	assert_true(director._companions.has(&"ngu"), "Ngu still waits at the bench")


func _campus() -> void:
	scene = load("res://scenes/levels/campus/campus.tscn").instantiate()
	tree.root.add_child(scene)
	await tree.physics_frame
	await tree.physics_frame


func test_every_low_crown_blocks_the_player_at_its_visible_surface() -> void:
	await _campus()
	var crowns := scene.get_node("Garden").find_children("LowCrown*", "MeshInstance3D", false, false)
	assert_eq(crowns.size(), 12, "all low garden crowns")
	var state := scene.get_world_3d().direct_space_state
	for crown: MeshInstance3D in crowns:
		var mesh := crown.mesh as CylinderMesh
		for height in [-0.6, 0.0, 0.6]:
			var center := crown.global_position + Vector3(0, height, 0)
			var radius := lerpf(mesh.bottom_radius, mesh.top_radius, (height + mesh.height / 2.0) / mesh.height)
			for side: Vector3 in [Vector3.RIGHT, Vector3.LEFT, Vector3.FORWARD, Vector3.BACK]:
				var hit := state.intersect_ray(PhysicsRayQueryParameters3D.create(center + side * 1.5, center, 1))
				assert_false(hit.is_empty(), "%s at height %s" % [crown.name, height])
				if not hit.is_empty():
					assert_eq(hit.collider.name, &"CanopyCollision", "hits the canopy")
					assert_true(absf(hit.position.distance_to(center) - radius) < 0.03, "collision follows tapered mesh")
	# Sweep the real player capsule into the same tree used for the before/after pictures.
	var player: CharacterBody3D = load("res://scenes/player/player.tscn").instantiate()
	scene.add_child(player)
	player.set_physics_process(false)
	player.global_position = Vector3(7.8, -9.35, 12)
	await tree.physics_frame
	var collision := player.move_and_collide(Vector3(-1.8, 0, 0))
	assert_not_null(collision, "player cannot enter the low canopy")
	if collision != null:
		assert_eq(collision.get_collider().name, &"CanopyCollision", "canopy stops the body")
	assert_true(player.global_position.x > 7.15, "body stays outside the visible leaves")


func test_crowns_leave_anchors_paths_and_navigation_clear() -> void:
	await _campus()
	var state := scene.get_world_3d().direct_space_state
	var capsule := CapsuleShape3D.new()
	capsule.radius = 0.3
	capsule.height = 1.75
	var query := PhysicsShapeQueryParameters3D.new()
	query.shape = capsule
	query.collision_mask = 1
	var markers := scene.get_node("Anchors").find_children("*", "Marker3D", true, false)
	for marker: Node3D in markers:
		query.transform.origin = marker.global_position + Vector3(0, 0.9, 0)
		for hit in state.intersect_shape(query, 32):
			assert_false(hit.collider.name == &"CanopyCollision", "anchor clear: %s" % marker.get_path())
	# Each crown lies inside an already blocked bed; navigation stays outside its footprint.
	var map := scene.get_world_3d().navigation_map
	NavigationServer3D.map_force_update(map)
	for attempt in 180:
		var entry := Vector3(22, -9.9, 8)
		if NavigationServer3D.map_get_iteration_id(map) > 0 and NavigationServer3D.map_get_closest_point(map, entry).distance_to(entry) < 0.1:
			break
		await tree.physics_frame
	for crown: MeshInstance3D in scene.get_node("Garden").find_children("LowCrown*", "MeshInstance3D", false, false):
		var at := crown.global_position
		at.y = -9.9
		var nearest := NavigationServer3D.map_get_closest_point(map, at)
		assert_true(Vector2(nearest.x - at.x, nearest.z - at.z).length() > 1.4, "navmesh clears crown and actor radius: %s" % crown.name)
	# Sample actual navigation segments between companion waypoints, without running a bot.
	for who in ["Nhat", "Ngu"]:
		var route := scene.get_node("Anchors/Paths/" + who).get_children()
		for i in range(1, route.size()):
			var a: Vector3 = route[i - 1].global_position
			var b: Vector3 = route[i].global_position
			if a.z < 8 or a.z > 48 or b.z < 8 or b.z > 48 or a.x > 48 or b.x > 48:
				continue
			var path := NavigationServer3D.map_get_path(map, a, b, true)
			assert_true(path.size() > 1, "garden navigation connects %s/%s" % [who, route[i].name])
			for segment in range(1, path.size()):
				var steps := ceili(path[segment - 1].distance_to(path[segment]) / 0.2)
				for step in range(steps + 1):
					query.transform.origin = path[segment - 1].lerp(path[segment], float(step) / maxi(steps, 1)) + Vector3(0, 0.9, 0)
					for hit in state.intersect_shape(query, 32):
						assert_false(hit.collider.name == &"CanopyCollision", "companion path clear: %s" % who)
