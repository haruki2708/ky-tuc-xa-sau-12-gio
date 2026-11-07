extends TestCase
## Build chapter fixtures only; never instantiate a bot or run a chapter.

const CH2_ACTIONS := preload("res://scripts/debug/ch2_actions.gd")


func test_profile_positions_clear_world_and_wipe_ray_hits_live_node() -> void:
	var saved := GameState.to_dict()
	var mouse := Input.mouse_mode
	for chapter in [2, 3]:
		GameState.reset()
		Chapter1Director.resume_checkpoint = &""
		var profile: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://../tools/ch%d-profile.json" % chapter))
		var scene: Node3D = load(profile.scene).instantiate()
		scene.get_node(profile.director).auto_start = false
		tree.root.add_child(scene)
		var player := scene.get_node("Player") as CharacterBody3D
		player.set_physics_process(false)
		await tree.physics_frame
		await tree.physics_frame
		if chapter == 2:
			assert_false(_overlaps(player, Vector3(33.5, 0.05, -2.0)).is_empty(), "regression: old bedroom point intersects the folding table")
			for key: String in profile.actions:
				for step: Dictionary in profile.actions[key].steps:
					if step.has("position"):
						var point := Vector3(step.position[0], step.position[1], step.position[2])
						assert_eq(_overlaps(player, point), [] as Array[String], key + " standing capsule")
			var helper := CH2_ACTIONS.new()
			helper.world = scene
			tree.root.add_child(helper)
			var wipe_step: Dictionary = profile.actions.wipe.steps[0]
			assert_false(wipe_step.has("aim"), "wipe must not store a world coordinate")
			var wipe := scene.get_node(wipe_step.aim_path) as Node3D
			var camera := player.get_node("Head/Camera3D") as Camera3D
			camera.make_current()
			var ray := camera.get_node("InteractRay") as RayCast3D
			for key in ["enter_shower", "leave_shower"]:
				var xyz: Array = profile.actions[key].steps[0].position
				player.global_position = Vector3(xyz[0], xyz[1], xyz[2])
				# Invoke only the aim portion, without holding input or playing the bot.
				var outcome: Dictionary = await helper._invoke(wipe, {"aim_path": wipe_step.aim_path, "position": xyz})
				assert_eq(outcome.status, "PASS")
				ray.force_raycast_update()
				assert_eq(ray.get_collider(), wipe, key + " ray must hit Wipe")
			# A missing target must fail rather than retain the previous aim.
			var missing: Dictionary = await helper._invoke(wipe, {"aim_path": "Missing"})
			assert_eq(missing.status, "FAIL")
			helper.free()
		else:
			# These are the two route waypoints that leave room 407.
			for index in 2:
				var xyz: Array = profile.routes.b[index].position
				assert_eq(_overlaps(player, Vector3(xyz[0], xyz[1], xyz[2])), [] as Array[String], "ch3 exit waypoint %d" % index)
			var alarm_index := -1
			var floor_one_index := -1
			for index in profile.routes.b.size():
				var point: Dictionary = profile.routes.b[index]
				if str(point.get("anchor", "")).ends_with("/P05"): floor_one_index = index
				if point.get("action") == "sound_fire_alarm": alarm_index = index
			assert_eq(alarm_index, floor_one_index + 1, "alarm follows arrival on floor 1 before the crowd corridor")
			assert_eq(profile.bindings.fire_alarm.flag, "ch3_fire_alarm")
			assert_eq(profile.actions.sound_fire_alarm.verify, profile.bindings.fire_alarm)
			var alarm: Node3D = scene.get_node(profile.actions.sound_fire_alarm.path)
			var xyz: Array = profile.routes.b[alarm_index].position
			var stand := Vector3(xyz[0], xyz[1], xyz[2])
			assert_eq(_overlaps(player, stand), [] as Array[String], "floor 1 alarm standing capsule")
			assert_true(stand.distance_to(alarm.global_position) < float(profile.actions.sound_fire_alarm.max_distance))
		scene.process_mode = Node.PROCESS_MODE_DISABLED
		for node: Node in scene.find_children("*", "", true, false):
			if node.has_method("stop_emitting"): node.stop_emitting()
			if node is AudioStreamPlayer or node is AudioStreamPlayer3D: node.stop()
		scene.queue_free()
		await tree.create_timer(0.3, true, false, true).timeout
	GameState.from_dict(saved)
	Input.mouse_mode = mouse


func _overlaps(player: CharacterBody3D, feet: Vector3) -> Array[String]:
	var capsule := CapsuleShape3D.new()
	capsule.radius = 0.3
	capsule.height = 1.75
	var query := PhysicsShapeQueryParameters3D.new()
	query.shape = capsule
	query.transform = Transform3D(Basis.IDENTITY, feet + Vector3(0, 0.875, 0))
	query.collision_mask = 1
	query.exclude = [player.get_rid()]
	query.margin = 0.0
	var names: Array[String] = []
	for hit: Dictionary in player.get_world_3d().direct_space_state.intersect_shape(query, 64):
		names.append(str(hit.collider.get_path()))
	return names
