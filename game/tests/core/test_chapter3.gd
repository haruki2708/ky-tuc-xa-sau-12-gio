extends TestCase
## Chapter 3 flow (T-181) in the real scene: building B, the garden, the
## stadium, the gate and canteen, deaths, and whether the things the player
## must use can be reached with a ray (lesson from chapter 1).

var scene: Node
var director: Chapter3Director
var player: Node3D
var restarts: Array[StringName] = []
var failed: Array[StringName] = []


func before_each() -> void:
	scene = load("res://scenes/main/chapter3.tscn").instantiate()
	director = scene.get_node("Chapter3Director")
	director.auto_start = false
	director.time_scale = 0.002
	Chapter1Director.resume_checkpoint = &""
	tree.root.add_child(scene)
	scene.get_node("FloorSpeaker").voice_directory = ""
	player = scene.get_node("Player")
	restarts.clear()
	failed.clear()
	director.restart_requested.connect(func(id: StringName) -> void: restarts.append(id))
	EventBus.player_failed.connect(_on_failed)
	RuleSystem.load_rule_set(load(Chapter3Director.CH3_RULE_SET))
	await wait_frames(3)


func after_each() -> void:
	EventBus.player_failed.disconnect(_on_failed)
	scene.queue_free()
	await wait_frames(3)


func _on_failed(reason: StringName) -> void:
	failed.append(reason)


func _until(condition: Callable, seconds: float = 20.0) -> void:
	var deadline := Time.get_ticks_msec() + int(seconds * 1000.0)
	while not condition.call() and Time.get_ticks_msec() < deadline:
		await wait_frames(1)


func _put(where: Vector3) -> void:
	player.global_position = where
	player.velocity = Vector3.ZERO


func _anchor(path: String) -> Node3D:
	return scene.get_node("Campus/Anchors/" + path) as Node3D


func test_scene_has_the_lane_pieces() -> void:
	assert_not_null(scene.get_node_or_null("Campus"), "campus")
	assert_not_null(director._horde, "horde")
	assert_eq(director._guards.size(), 12, "12 guards;")
	for key in ["FireKey", "FireDoor", "Extinguisher2F"]:
		assert_true(director._uses.has(key), "use " + key)
	assert_true(bool(player.get("stamina_enabled")), "stamina on in chapter 3")
	var errors := RuleSystem.load_rule_set(load(Chapter3Director.CH3_RULE_SET))
	assert_true(errors.is_empty(), "rules valid")


func test_building_b_to_the_garden() -> void:
	director.stop_after = &"b"
	director.run_from(&"b")
	await _until(func() -> bool: return director._scared.get(&"roommates_rise", false), 10.0)
	assert_true(director._scared.get(&"roommates_rise", false), "roommates rose")
	_put(Vector3(20.0, 0.05, 1.2))
	await _until(func() -> bool: return director._scared.get(&"corridor_turn", false), 10.0)
	assert_true(director._scared.get(&"corridor_turn", false), "out of 407: the corridor turns")
	# The fire door needs the key.
	director._uses["FireDoor"].interact(player)
	assert_false(GameState.get_flag(&"ch3_fire_door_open", false), "locked without the key")
	director._uses["FireKey"].interact(player)
	director._uses["FireDoor"].interact(player)
	assert_true(GameState.get_flag(&"ch3_fire_door_open", false), "opened with the key")
	_put(Vector3(40.0, -3.25, 1.2))
	await wait_frames(5)
	_put(Vector3(30.0, -6.55, 1.2))
	await wait_frames(5)
	director._uses["Extinguisher2F"].interact(player)
	await _until(func() -> bool: return director._companions.has(&"minh_nhat"), 10.0)
	assert_true(director._companions.has(&"minh_nhat"), "Minh Nhật joins after the noise")
	_put(Vector3(10.0, -9.85, 1.2))
	await wait_frames(5)
	_put(_anchor("Start_garden").global_position)
	await _until(func() -> bool: return director.finished or not failed.is_empty(), 20.0)
	assert_true(director.finished, "zone 1 done")
	assert_eq(failed, [] as Array[StringName], "alive;")


func test_a_zombie_grab_kills_and_reloads_the_zone() -> void:
	director.run_from(&"b")
	await wait_frames(5)
	EventBus.player_caught.emit(&"zombie")
	await _until(func() -> bool: return not restarts.is_empty(), 20.0)
	assert_eq(failed, [&"DEATH_CH3_GRABBED"] as Array[StringName], "grabbed;")
	assert_eq(restarts, [&"ch3_b"] as Array[StringName], "reload building B;")


func test_garden_ngu_gives_the_bar() -> void:
	director.stop_after = &"garden"
	director.run_from(&"garden")
	await _until(func() -> bool: return director._companions.has(&"ngu"), 10.0)
	assert_true(director._companions.has(&"ngu"), "Ngư at the bench")
	assert_true(director._companions.has(&"minh_nhat"), "Minh Nhật there too (resumed mid-chapter)")
	_put(_anchor("NguBench").global_position + Vector3(1.0, 0.0, 0.0))
	await _until(func() -> bool: return player.bar_weapon != null and player.bar_weapon.hits_left > 0, 10.0)
	assert_eq(player.bar_weapon.hits_left, 8, "a bar with 8 hits;")
	_put(_anchor("Start_stadium").global_position)
	await _until(func() -> bool: return director.finished, 20.0)
	assert_true(director.finished, "on to the stadium")


func test_stadium_waves_then_the_gate() -> void:
	director.stop_after = &"stadium"
	director.run_from(&"stadium")
	await _until(func() -> bool: return director._horde.active_count() > 0 or director._horde.get_child_count() > 0, 10.0)
	assert_true(director._horde.get_child_count() > 0, "zombies pour in")
	await _until(func() -> bool: return director._scared.get(&"stadium_lights", false), 5.0)
	assert_true(director._scared.get(&"stadium_lights", false), "the lights flash once")
	_put(_anchor("Start_gate").global_position)
	await _until(func() -> bool: return director.finished or not failed.is_empty(), 30.0)
	assert_true(director.finished, "stadium survived, at the gate")


func test_gate_canteen_and_the_end() -> void:
	director.run_from(&"gate")
	await wait_frames(5)
	_put(_anchor("CanteenTV").global_position + Vector3(0.0, 0.0, 2.0))
	await _until(func() -> bool: return director.finished or not failed.is_empty(), 30.0)
	assert_true(director._scared.get(&"canteen_tv", false), "the TV came on")
	assert_true(director.finished, "chapter 3 done")
	assert_true(Progress.unlocked_chapter() >= 4, "chapter 4 unlocked")


func test_striking_a_guard_kills() -> void:
	director.run_from(&"gate")
	await wait_frames(5)
	EventBus.player_caught.emit(&"guard")
	await _until(func() -> bool: return not restarts.is_empty(), 20.0)
	assert_eq(failed, [&"DEATH_CH3_GUARD"] as Array[StringName], "the baton;")
	assert_eq(restarts, [&"ch3_gate"] as Array[StringName], "reload at the gate;")


## A ray from where a player would stand or crouch (0.7–1.2 m away, any
## side, eyes at 1.6 m or 1.0 m above the floor) reaches the thing without
## hitting a wall first.
func test_things_to_use_can_be_reached() -> void:
	await wait_frames(4)
	var space := (scene as Node3D).get_world_3d().direct_space_state
	var things: Dictionary = {}
	for key in ["FireKey", "FireDoor", "Extinguisher2F"]:
		things[key] = director._uses[key]
	for bar in director.find_children("*", "Interactable", false, false):
		if String(bar.get_script().resource_path).ends_with("iron_bar.gd"):
			things["bar %s" % bar.name] = bar
	assert_true(things.size() >= 9, "3 uses and 6 bars (%d)" % things.size())
	for key: String in things:
		var use: Interactable = things[key]
		var target := use.global_position
		var floor_y := _floor_below(space, target)
		var reached := false
		for dir: Vector3 in [Vector3.RIGHT, Vector3.LEFT, Vector3.FORWARD, Vector3.BACK]:
			for distance: float in [0.7, 1.0, 1.2]:
				for eye_height: float in [1.6, 1.0]:
					var eye := target + dir * distance
					eye.y = floor_y + eye_height
					var query := PhysicsRayQueryParameters3D.create(eye, target + (target - eye).normalized() * 0.3, 1 | (1 << 2))
					query.collide_with_areas = true
					var hit := space.intersect_ray(query)
					if not hit.is_empty() and hit.collider == use:
						reached = true
		assert_true(reached, "%s reachable by the interact ray (at %s)" % [key, target])


func _floor_below(space: PhysicsDirectSpaceState3D, from: Vector3) -> float:
	var hit := space.intersect_ray(PhysicsRayQueryParameters3D.create(from, from + Vector3.DOWN * 4.0, 1))
	return hit.position.y if not hit.is_empty() else from.y - 0.8


## Owner playtest 2026-10-06: with the key, E on the fire door did nothing. A
## look straight at the door at eye height hit lane B's leaf, not the use
## (whose box sat on the floor). Look like a player does: level, from the
## corridor, standing and crouched.
func test_fire_door_answers_a_straight_look() -> void:
	await wait_frames(4)
	var space := (scene as Node3D).get_world_3d().direct_space_state
	var use: Ch3Use = director._uses["FireDoor"]
	var door := _anchor("FireDoor").global_position
	for eye_height: float in [1.0, 1.6]:
		for back: float in [1.0, 1.8]:
			var eye := Vector3(door.x - back, door.y + eye_height, door.z)
			var query := PhysicsRayQueryParameters3D.create(eye, eye + Vector3(back + 1.0, 0.0, 0.0), 1 | (1 << 2))
			query.collide_with_areas = true
			var hit := space.intersect_ray(query)
			assert_true(not hit.is_empty() and hit.collider == use,
				"eye %.1f m, %.1f m back hits the use (got %s)" % [eye_height, back, hit.get("collider")])
