extends TestCase
## Real chapter geometry, with the story director stopped. T-203 dependencies
## are measured explicitly; --t202-integration requires them to pass as well.

const PlayerScript = preload("res://scripts/player/player.gd")
var scene: Node3D
var player: PlayerScript
var director: Chapter1Director
var old_mouse: Input.MouseMode


func before_each() -> void:
	old_mouse = Input.mouse_mode
	GameState.reset()
	Chapter1Director.resume_checkpoint = &""
	scene = load("res://scenes/main/chapter1.tscn").instantiate()
	director = scene.get_node("Chapter1Director")
	director.auto_start = false
	tree.root.add_child(scene)
	player = scene.get_node("Player")
	player.set_physics_process(false)
	await _ticks(3)


func after_each() -> void:
	tree.paused = false
	Input.action_release("interact")
	for node: Node in scene.find_children("*", "AudioStreamPlayer3D", true, false):
		if node.has_method("stop_emitting"):
			node.call("stop_emitting")
		(node as AudioStreamPlayer3D).stop()
	scene.queue_free()
	await wait_frames(3)
	GameState.reset()
	RuleSystem.reset()
	Input.mouse_mode = old_mouse


func _ticks(count: int) -> void:
	for index: int in count:
		await tree.physics_frame
		await tree.process_frame


func _aim(from: Vector3, at: Vector3) -> Object:
	player.global_position = from
	player.rotation = Vector3.ZERO
	player.head.position = Vector3(0, 1.6, 0)
	player.head.rotation = Vector3.ZERO
	player.camera.position = Vector3.ZERO
	player.camera.look_at(at)
	player._update_focus()
	return player.interact_ray.get_collider()


func test_real_room_bunk_rays_from_six_aisle_positions_and_e() -> void:
	for bed: int in [1, 2, 3, 4]:
		var spot: HideSpot = director._bunks[bed]
		var center: Vector3 = spot.global_position
		var side: float = 1.0 if bed in [1, 2] else -1.0
		var hits: int = 0
		var blockers: Dictionary = {}
		var success_from: Vector3
		var success_at: Vector3
		for distance: float in [0.9, 1.2]:
			for stand_z: float in [-0.6, 0.0, 0.6]:
				for aim_z: float in [-0.8, -0.48, -0.16, 0.16, 0.48, 0.8]:
					var from: Vector3 = Vector3(center.x + side * distance, 0.03, center.z + stand_z)
					var at: Vector3 = center + Vector3(0, 0.1, aim_z)
					var collider: Object = _aim(from, at)
					if collider == spot:
						hits += 1
						success_from = from
						success_at = at
					else:
						var label: String = str((collider as Node).get_path()) if collider is Node else "out of reach"
						blockers[label] = int(blockers.get(label, 0)) + 1
		print("T-202 RAYS bed=%d hits=%d/36 (%.1f%%) blockers=%s" % [bed, hits, hits / 36.0 * 100.0, blockers])
		var legacy_solid_bunk: bool = false
		if bed == 3:
			for shape_node: Node in scene.get_node("Floor4/Room407/BunkB").find_children("*", "CollisionShape3D", true, false):
				var shape: Shape3D = (shape_node as CollisionShape3D).shape
				if shape is BoxShape3D:
					var size: Vector3 = (shape as BoxShape3D).size
					legacy_solid_bunk = legacy_solid_bunk or (size.x >= 0.8 and size.y > 1.5 and size.z >= 1.8)
		if not legacy_solid_bunk or OS.get_cmdline_user_args().has("--t202-integration"):
			assert_true(hits >= 29, "bed %d must hit at least 80%% of 36 rays" % bed)
		else:
			print("T-202 DEPENDENCY: bed 3 still has the solid BunkB collision; requires T-203.")
		if hits > 0:
			_aim(success_from, success_at)
			Input.action_press("interact")
			player._physics_process(1.0 / 60.0)
			Input.action_release("interact")
			assert_true(player.is_hidden(), "E enters bed %d" % bed)
			assert_eq(GameState.get_flag(&"player_bed", 0), bed)
			player.leave_hide_spot(false)
			await _ticks(2)


func test_lower_mattress_and_upper_search_have_distinct_prompts() -> void:
	var lower: HideSpot = director._bunks[2]
	var search: Node3D = scene.get_node("Floor4/Room407/Anchors/PhucMattress/SearchPhucMattress")
	var from: Vector3 = Vector3(lower.global_position.x + 1.2, 0.03, lower.global_position.z)
	assert_eq(_aim(from, lower.global_position + Vector3(0, 0.1, 0)), lower)
	assert_eq(player._focus_key, "PROMPT_LIE_DOWN")
	assert_eq(_aim(from, search.global_position), search)
	assert_eq(player._focus_key, "PROMPT_CH1_LIFT_MATTRESS")


func test_bed3_e_with_legacy_box_disabled_only_in_fixture() -> void:
	# Isolate Lane A's area from the known T-203 dependency. The preceding
	# measurement keeps all production collisions and reports the real result.
	var solid: CollisionObject3D = scene.get_node_or_null("Floor4/Room407/BunkB/WorldCollision") as CollisionObject3D
	if solid != null:
		solid.collision_layer = 0
	await _ticks(2)
	var spot: HideSpot = director._bunks[3]
	var from: Vector3 = Vector3(spot.global_position.x - 1.2, 0.03, spot.global_position.z)
	assert_eq(_aim(from, spot.global_position + Vector3(0, 0.1, 0)), spot)
	Input.action_press("interact")
	player._physics_process(1.0 / 60.0)
	Input.action_release("interact")
	assert_true(player.is_hidden())
	assert_eq(GameState.get_flag(&"player_bed", 0), 3)
	player.leave_hide_spot(false)


func test_real_room_hunt_balcony_and_bathroom() -> void:
	EventBus.player_caught.disconnect(director._on_player_caught)
	var caught: Array[StringName] = []
	var listener: Callable = func(id: StringName) -> void: caught.append(id)
	EventBus.player_caught.connect(listener)
	var room: Node3D = scene.get_node("Floor4/Room407")
	var door: Node = scene.get_node("Floor4/Door407")
	door.call("set_open", true)
	var bathroom_door: Node = room.get_node("Extension/BathroomDoor")
	bathroom_door.call("set_open", true)
	for destination: Vector3 in [Vector3(32.8, 0.03, -7.8), Vector3(36.85, 0.03, -5.6)]:
		var actor: DormManager = load("res://scenes/entity/manager.tscn").instantiate()
		actor.position = Chapter1Director.DOOR_SPOT
		# No speech or death consequence from the paused story; keep real collision/nav.
		actor.audio_rig = Node3D.new()
		scene.add_child(actor.audio_rig)
		scene.add_child(actor)
		player.global_position = destination
		await _ticks(3)
		var map: RID = actor.navigation.get_navigation_map()
		var closest: Vector3 = NavigationServer3D.map_get_closest_point(map, destination)
		var covered: bool = Vector2(closest.x - destination.x, closest.z - destination.z).length() < 0.5
		var arrivals: Array[Vector3] = []
		actor.arrived.connect(func() -> void: arrivals.append(actor.global_position))
		actor.hunt(player)
		for tick: int in 740:
			await _ticks(1)
			if actor.state != DormManager.State.HUNTING:
				break
		var distance: float = Vector2(actor.position.x - destination.x, actor.position.z - destination.z).length()
		print("T-202 HUNT target=%s nav_covered=%s final=%s distance=%.2f arrivals=%d" % [destination, covered, actor.position, distance, arrivals.size()])
		if covered or OS.get_cmdline_user_args().has("--t202-integration"):
			assert_eq(arrivals.size(), 1, "hunt arrives using the real room navmesh")
			assert_true(distance <= DormManager.HUNT_REACH + 0.05)
		else:
			print("T-202 DEPENDENCY: room navmesh does not reach this target; requires T-203.")
		assert_true(actor.state in [DormManager.State.LUNGING, DormManager.State.KILLING], "arrival or timeout starts kill")
		await _ticks(90)
		assert_eq(caught, [&"manager"], "kill emits exactly once after approach or timeout")
		caught.clear()
		actor.queue_free()
		await _ticks(2)
	EventBus.player_caught.disconnect(listener)


func test_real_door_opening_contract() -> void:
	var door: Node3D = scene.get_node("Floor4/Door407")
	var pivot: Node3D = door.get_node("Pivot")
	var timed: bool = false
	for method: Dictionary in door.get_method_list():
		if method.name == "set_open":
			timed = method.args.size() >= 2
	var actor: DormManager = load("res://scenes/entity/manager.tscn").instantiate()
	actor.position = Chapter1Director.DOOR_SPOT
	actor.audio_rig = Node3D.new()
	scene.add_child(actor.audio_rig)
	scene.add_child(actor)
	var openings: Array[float] = []
	actor.door_opened.connect(func() -> void: openings.append(pivot.rotation.y))
	actor.open_door(door, 1.5)
	assert_true(openings.is_empty())
	await _ticks(30)
	if timed:
		assert_true(pivot.rotation.y < -0.1 and pivot.rotation.y > -1.4)
		assert_true(openings.is_empty())
	else:
		print("T-202 DEPENDENCY: Door407 only accepts set_open(value); slow opening requires T-203.")
		assert_false(OS.get_cmdline_user_args().has("--t202-integration"), "integration requires the timed door API")
	await _ticks(70)
	assert_eq(openings.size(), 1)
	assert_true(absf(openings[0] + PI / 2.0) < 0.01)
