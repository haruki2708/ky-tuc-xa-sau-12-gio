extends TestCase
## Contract tests against the shipped chapter, not a replacement director.

const ACTIONS := preload("res://scripts/debug/ch3_actions.gd")
const POLICY := preload("res://scripts/debug/ch3_policy.gd")


func test_real_profile_nodes_actions_and_navigation_endpoints() -> void:
	var profile: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://../tools/ch3-profile.json"))
	assert_eq(POLICY.preflight(profile), [] as Array[String])
	var state := GameState.to_dict()
	var mouse := Input.mouse_mode
	GameState.reset()
	Chapter1Director.resume_checkpoint = &""
	var scene: Node3D = load(profile.scene).instantiate()
	var director := scene.get_node("Chapter3Director")
	director.auto_start = false
	tree.root.add_child(scene)
	var player: Node3D = scene.get_node("Player")
	player.set_physics_process(false)
	var helper := ACTIONS.new()
	helper.world = scene
	helper.profile = profile
	tree.root.add_child(helper)
	await wait_frames(4)
	for stage: String in POLICY.STAGES:
		_check_route(scene, profile.routes[stage])
	_check_route(scene, [profile.guard_target])
	assert_not_null(scene.get_node_or_null(profile.bindings.death_ui))
	for path: String in profile.bindings.guard_paths:
		assert_not_null(scene.get_node_or_null(path), path)
	var zombie: Node = load(profile.zombie_scene).instantiate()
	assert_not_null(zombie.get_node_or_null(profile.bindings.bar_head_path))
	zombie.free()
	assert_false(GameState.get_flag(&"ch3_has_key", false))
	assert_false(GameState.get_flag(&"ch3_fire_door_open", false))
	assert_false(GameState.get_flag(&"ch3_alarm", false))
	scene.get_node(profile.actions.open_fire_door.path).interact(player)
	assert_false(GameState.get_flag(&"ch3_fire_door_open", false), "door must require key")
	var rejected: Dictionary = await helper.perform("take_key")
	assert_eq(rejected.status, "FAIL", "cannot interact remotely")
	assert_false(GameState.get_flag(&"ch3_has_key", false))
	for key in ["open_407", "take_key", "open_fire_door", "sound_extinguisher"]:
		var spec: Dictionary = profile.actions[key]
		var target: Node3D = scene.get_node(spec.path)
		# Unit-test setup only; the bot uses input and navmesh, never this placement.
		player.global_position = target.global_position + Vector3(0, 0, 1)
		var outcome: Dictionary = await helper.perform(key)
		assert_eq(outcome.status, "PASS", key)
		assert_true(ACTIONS.acknowledged(spec.verify, target, scene), key)
	# The outdoor navigation mesh has hundreds of regions and registers over
	# several physics frames: wait until the stadium start is on the map (as
	# test_campus does) before auditing the routes.
	var map := scene.get_world_3d().navigation_map
	for frame in 600:
		if NavigationServer3D.map_get_closest_point(map, Vector3(115, -9.9, 166)).distance_to(Vector3(115, -9.9, 166)) < 0.5:
			break
		await tree.physics_frame
	var previous := Vector3(32, 0.05, -2.2)
	for stage: String in POLICY.STAGES:
		previous = _check_paths(scene, profile.routes[stage], previous, helper.guard_positions())
	helper.profile = {"actions": profile.menu_actions}
	player.call("_set_stamina", 0.2)
	for key in ["zombies_off", "zombies_on", "give_bar", "refill"]:
		var outcome: Dictionary = await helper.perform(key)
		assert_eq(outcome.status, "PASS", key)
	assert_false(ACTIONS.acknowledged({"path": "Missing", "property": "stamina", "equals": 1}, null, scene))
	assert_false(ACTIONS.acknowledged({"path": "Player", "property": "bar_weapon:hits_left", "equals": 7}, null, scene))
	helper.free()
	scene.queue_free()
	await wait_frames(3)
	GameState.from_dict(state)
	Input.mouse_mode = mouse


func _check_route(scene: Node3D, route: Array) -> void:
	for point: Dictionary in route:
		if point.has("loop"):
			_check_route(scene, point.loop)
			continue
		if point.has("anchor"):
			assert_true(scene.get_node_or_null(point.anchor) is Node3D, str(point.anchor))
		if point.has("wait_for") and point.wait_for.has("path"):
			assert_not_null(scene.get_node_or_null(point.wait_for.path), "wait target")


func _check_paths(scene: Node3D, route: Array, previous: Vector3, guards: Array[Vector3]) -> Vector3:
	var map := scene.get_world_3d().navigation_map
	for point: Dictionary in route:
		if point.has("loop"):
			previous = _check_paths(scene, point.loop, previous, guards)
			# Validate the closing leg too, without running the four-minute loop.
			previous = _check_paths(scene, point.loop, previous, guards)
			continue
		var target: Vector3
		if point.has("position"):
			target = Vector3(point.position[0], point.position[1], point.position[2])
		else:
			target = (scene.get_node(point.anchor) as Node3D).global_position
		var path := NavigationServer3D.map_get_path(map, previous, target, true)
		if not POLICY.path_reaches(path, target):
			print("QA_CH3_NAV: from=", previous, " target=", target, " closest=", NavigationServer3D.map_get_closest_point(map, target), " end=", path[-1] if not path.is_empty() else Vector3.INF)
		assert_true(POLICY.path_reaches(path, target), "navmesh endpoint: " + str(point))
		assert_true(POLICY.avoids_guards(path, guards), "guard clearance: " + str(point))
		previous = target
	return previous
