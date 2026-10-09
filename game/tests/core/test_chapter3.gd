extends TestCase
## Chapter 3 flow (T-181) in the real scene: building B, the garden, the
## stadium, the gate and canteen, deaths, and whether the things the player
## must use can be reached with a ray (lesson from chapter 1).

var scene: Node
var director: Chapter3Director
var player: Node3D
const ROOM_BASH_SLOW := 3.0
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


## D-062: floor 2 holds only the crowd at 203's door; the walk from the fire
## stairs to the extinguisher is clear, and its bang drags the crowd away.
func test_floor_two_crowd_leaves_203_for_the_extinguisher() -> void:
	director.run_from(&"b")
	await _until(func() -> bool: return director._crowd_203.size() == 4, 10.0)
	assert_eq(director._crowd_203.size(), 4, "four at 203's door;")
	var hideout: Node3D = director._room_door(&"207")
	assert_true(hideout != null and bool(hideout.get("is_open")), "room 207 stands open to hide in")
	var door := _anchor("Room203Door").global_position
	var extinguisher := _anchor("Extinguisher2F").global_position
	assert_true(extinguisher.x > 36.0, "extinguisher near the fire stairs")
	for zombie in director._crowd_203:
		assert_true(zombie.global_position.distance_to(door) < 2.5, "crowd at the door")
	for actor in director._horde.get_children():
		if actor is Zombie:
			var at: Vector3 = (actor as Zombie).global_position
			assert_false(absf(at.y - door.y) < 1.0 and at.x > 30.0, "nothing between the fire stairs and the extinguisher: %s" % at)
	# Bang it on the fire-stair landing, hide deep in the open room 207, wait
	# until the whole crowd stands in the stairwell, then walk west unseen.
	_put(extinguisher + Vector3(-1.3, -1.05, 0.0))
	await wait_frames(3)
	director._uses["Extinguisher2F"].interact(player)
	_put(Vector3(35.75, -6.55, -4.5))
	var gathered := func() -> bool:
		for zombie in director._crowd_203:
			if zombie.global_position.distance_to(extinguisher) > 3.5:
				return false
		return true
	await _until(gathered, 30.0)
	for zombie in director._crowd_203:
		assert_true(zombie.global_position.distance_to(extinguisher) < 3.5, "in the stairwell: %s" % zombie.global_position)
	assert_true(director._crowd_203_gone(), "the crowd left 203's door")
	await _until(func() -> bool: return director._companions.has(&"minh_nhat"), 15.0)
	assert_true(director._companions.has(&"minh_nhat"), "Minh Nhật comes out")
	var at := Vector3(35.75, -6.55, -1.0)
	for goal in [Vector3(35.75, -6.55, 2.0), Vector3(2.0, -6.55, 2.0)]:
		while at.distance_to(goal) > 0.2:
			at = at.move_toward(goal, 0.035)
			_put(at)
			await wait_frames(1)
	for zombie in director._crowd_203:
		assert_true(zombie.global_position.distance_to(extinguisher) < 3.5, "still in the stairwell after Trung slipped away")
	assert_eq(failed, [] as Array[StringName], "alive;")


## D-074 (chapter 3 playtest): Trung walks back from the extinguisher to 207
## at walking pace, toward the crowd. The bang must keep them going to the
## landing (they used to see him and stop in 207's doorway), and Minh Nhật
## walks out of 203 instead of popping up beside Trung.
func test_floor_two_walk_back_to_207_stays_unseen() -> void:
	director.run_from(&"b")
	await _until(func() -> bool: return director._crowd_203.size() == 4, 10.0)
	var extinguisher := _anchor("Extinguisher2F").global_position
	var door := _anchor("Room203Door").global_position
	player.set_physics_process(false)
	var at := extinguisher + Vector3(-1.3, -1.05, 0.0)
	_put(at)
	for i in 3:
		await tree.physics_frame
	director._uses["Extinguisher2F"].interact(player)
	var route: Array[Vector3] = [Vector3(44.0, -6.55, 2.0), Vector3(35.75, -6.55, 2.0), Vector3(35.75, -6.55, -2.3)]
	var jumps: Array[String] = []
	var nhat_last := Vector3.INF
	var nhat_max_x := -INF
	var deadline := Time.get_ticks_msec() + 45000
	while Time.get_ticks_msec() < deadline and failed.is_empty():
		if not route.is_empty():
			at = at.move_toward(route[0], 2.2 / 60.0)
			if at.distance_to(route[0]) < 0.05:
				route.pop_front()
			_put(at)
		await tree.physics_frame
		for zombie in director._crowd_203:
			var goal: Vector3 = zombie.get("_goal")
			assert_false(route.is_empty() and goal.distance_to(player.global_position) < 1.5, "a crowd zombie went for the hidden Trung at %s" % zombie.global_position)
		var nhat: Node3D = director._companions.get(&"minh_nhat")
		if nhat != null:
			if nhat_last != Vector3.INF and nhat.global_position.distance_to(nhat_last) > 2.0:
				jumps.append("%s -> %s" % [nhat_last, nhat.global_position])
			nhat_last = nhat.global_position
			nhat_max_x = maxf(nhat_max_x, nhat.global_position.x)
	assert_eq(failed, [] as Array[StringName], "hidden in 207, never caught;")
	for zombie in director._crowd_203:
		assert_true(zombie.global_position.distance_to(extinguisher) < 4.0, "the crowd stands in the stairwell: %s" % zombie.global_position)
	assert_true(director._companions.has(&"minh_nhat"), "Minh Nhật came out;")
	assert_eq(jumps, [] as Array[String], "Minh Nhật walked, no jump;")
	assert_true(nhat_max_x > door.x + 10.0, "he walked down the corridor toward Trung (reached x %.1f);" % nhat_max_x)


## D-075: floor 1 is no longer packed: four zombies stand in the far half with
## their backs to the stairs and turn on Trung only after a few seconds.
func test_floor_one_crowd_waits_in_the_far_half() -> void:
	director.run_from(&"b")
	await _until(func() -> bool: return director._crowd_203.size() == 4, 10.0)
	player.set_physics_process(false)
	_put(Vector3(-1.0, -9.85, 2.0))
	await _until(func() -> bool: return director._crowd_1f.size() == 4, 10.0)
	assert_eq(director._crowd_1f.size(), 4, "four on floor 1;")
	for actor in director._horde.get_children():
		if actor is Zombie:
			assert_false((actor as Zombie).global_position.y < -9.0 and (actor as Zombie).global_position.x < 40.0, "no horde idle on floor 1: %s" % (actor as Zombie).global_position)
	for zombie in director._crowd_1f:
		assert_true(zombie.global_position.x >= 16.0, "far half: %s" % zombie.global_position)
	await tree.create_timer(Chapter3Director.FLOOR1_CROWD_DELAY - 1.0).timeout
	for zombie in director._crowd_1f:
		assert_eq(zombie.state, &"asleep", "still turned away before the delay;")
	await tree.create_timer(2.0).timeout
	var awake := 0
	for zombie in director._crowd_1f:
		if zombie.state == &"hunting":
			awake += 1
	assert_eq(awake, 4, "they turn on Trung after the delay;")


## D-075: the fire alarm at the foot of the main stairs drags the floor 1 crowd
## to the bell at the far end; Trung at the stairs stays alive.
func test_fire_alarm_pulls_the_floor_one_crowd_away() -> void:
	director.run_from(&"b")
	await _until(func() -> bool: return director._crowd_203.size() == 4, 10.0)
	player.set_physics_process(false)
	_put(Vector3(-1.0, -9.85, 2.0))
	await _until(func() -> bool: return director._crowd_1f.size() == 4, 10.0)
	var alarm: Ch3Use = director._uses.get("FireAlarm1F")
	assert_not_null(alarm, "the fire alarm is placed;")
	if alarm == null:
		return
	assert_true(alarm.global_position.distance_to(Chapter3Director.FIRE_ALARM_AT) < 0.05, "on the wall by the stairs;")
	_put(Vector3(0.9, -9.85, 1.2))
	await tree.create_timer(0.2).timeout
	alarm.interact(player)
	var bell := Vector3(Chapter3Director.FIRE_BELL_AT.x, -9.9, Chapter3Director.FIRE_BELL_AT.z)
	await _until(func() -> bool:
		for zombie in director._crowd_1f:
			if zombie.global_position.distance_to(bell) > 4.5:
				return false
		return true, 30.0)
	for zombie in director._crowd_1f:
		assert_true(zombie.global_position.distance_to(bell) < 4.5, "at the bell: %s" % zombie.global_position)
	assert_eq(failed, [] as Array[StringName], "alive at the stairs;")


## D-075: leaving 207 early and walking toward 203, Minh Nhật comes along at
## once instead of waiting for the crowd to reach the landing.
func test_minh_nhat_follows_at_once_when_trung_comes_back() -> void:
	director.run_from(&"b")
	await _until(func() -> bool: return director._crowd_203.size() == 4, 10.0)
	var extinguisher := _anchor("Extinguisher2F").global_position
	_put(extinguisher + Vector3(-1.3, -1.05, 0.0))
	await wait_frames(3)
	director._uses["Extinguisher2F"].interact(player)
	await _until(func() -> bool: return director._companions.has(&"minh_nhat"), 10.0)
	var nhat: Node3D = director._companions[&"minh_nhat"]
	assert_true(director._crowd_pull_active, "the crowd is still on its way;")
	# Trung slips back west to 203 at once (behind the crowd's line of travel).
	_put(_anchor("Room203Door").global_position + Vector3(6.0, 0.05, 2.0))
	await _until(func() -> bool: return bool(nhat.get("following")), 5.0)
	assert_true(nhat.get("following"), "he follows as soon as Trung is near;")


## D-063: Minh Nhật and Ngư walk behind Trung from the garden to the stadium.
func test_companions_follow_the_player_to_the_stadium() -> void:
	director.time_scale = 1.0
	director.stop_after = &"garden"
	director.run_from(&"garden")
	await _until(func() -> bool: return director._companions.has(&"ngu"), 10.0)
	_put(_anchor("NguBench").global_position + Vector3(0.0, 0.0, -1.5))
	await _until(func() -> bool: return bool(director._companions[&"ngu"].following), 10.0)
	assert_true(director._companions[&"ngu"].following, "Ngư follows after the meeting")
	var at: Vector3 = player.global_position
	for goal in [Vector3(48, -9.85, 28), Vector3(80, -9.85, 28), Vector3(80, -9.85, 90)]:
		while at.distance_to(goal) > 0.3:
			at = at.move_toward(goal, 0.12)
			_put(at)
			director._horde.clear_all()
			await wait_frames(1)
	await _until(func() -> bool:
		for member in director._companions:
			if director._companions[member].global_position.distance_to(player.global_position) > 8.0:
				return false
		return true, 10.0)
	for member in director._companions:
		var companion: Node3D = director._companions[member]
		assert_true(companion.global_position.distance_to(player.global_position) < 8.0,
			"%s kept up: %s vs %s" % [member, companion.global_position, player.global_position])


## D-061 / T-191: leaving 407 shows no zombie in the hall at once. A room's
## zombies wait behind its shut door, hammer on it, and only then come out.
func test_zombies_come_out_of_the_rooms_not_the_hall() -> void:
	director.stop_after = &"b"
	director.run_from(&"b")
	await _until(func() -> bool: return director._scared.get(&"roommates_rise", false), 10.0)
	_put(Vector3(37.0, 0.05, 2.5))
	await _until(func() -> bool: return director._scared.get(&"corridor_turn", false), 10.0)
	for actor in director._horde.get_children():
		if actor is Zombie and (actor as Zombie).global_position.y > -1.0:
			assert_true((actor as Zombie).global_position.x < 10.0, "idle crowd waits at the main stairs: %s" % (actor as Zombie).global_position)
	await _until(func() -> bool: return not director._room_tracks.is_empty(), 5.0)
	assert_false(director._room_tracks.is_empty(), "a near room starts hammering on its door")
	var first: Dictionary = director._room_tracks[0]
	var zombie: Zombie = first["zombie"]
	var adapter: ZombieDoor = first["door"]
	assert_true(zombie.global_position.z < -0.4, "still inside the room: %s" % zombie.global_position)
	assert_true(adapter.is_closed(), "the door holds at first")
	assert_false(director._rooms_opened.has(&"401"), "far rooms stay quiet")
	await _until(func() -> bool: return not adapter.is_closed(), 10.0)
	assert_false(adapter.is_closed(), "the door bursts open after the bashing")
	await _until(func() -> bool: return zombie.global_position.z > 0.6, 8.0)
	assert_true(zombie.global_position.z > 0.6, "the zombie walks out into the hall: %s" % zombie.global_position)
	assert_eq(failed, [] as Array[StringName], "alive;")


## Room 408 is quiet on the way to the desk and bursts open after the key.
func test_room_408_opens_after_the_key() -> void:
	director.stop_after = &"b"
	director.run_from(&"b")
	await _until(func() -> bool: return director._scared.get(&"roommates_rise", false), 10.0)
	_put(Vector3(38.5, 0.05, 2.5))
	await _until(func() -> bool: return director._scared.get(&"corridor_turn", false), 10.0)
	await wait_frames(30)
	assert_false(director._rooms_opened.has(&"408"), "408 quiet before the key")
	director._uses["FireKey"].interact(player)
	await _until(func() -> bool: return director._rooms_opened.has(&"408"), 5.0)
	assert_true(director._rooms_opened.has(&"408"), "408 opens after the key")
	var count := 0
	for track: Dictionary in director._room_tracks:
		if (track["zombie"] as Zombie).door_bash_seconds > ROOM_BASH_SLOW:
			count += 1
	assert_eq(count, 2, "two zombies in 408;")


## Floor 3: the rooms next to the fire stairs wake as Trung comes down.
func test_floor_three_rooms_next_to_the_stairs_open() -> void:
	director.stop_after = &"b"
	director.run_from(&"b")
	await _until(func() -> bool: return director._scared.get(&"roommates_rise", false), 10.0)
	_put(Vector3(44.0, 0.05, 2.5))
	await _until(func() -> bool: return director._scared.get(&"corridor_turn", false), 10.0)
	_put(Vector3(46.0, -3.25, 2.0))
	await _until(func() -> bool: return director._rooms_opened.has(&"308"), 5.0)
	assert_true(director._rooms_opened.has(&"308"), "308 beside the landing opens")
	assert_false(director._rooms_opened.has(&"301"), "far floor-3 rooms stay quiet")
	assert_false(director._rooms_opened.has(&"406"), "floor 4 rooms do not open from floor 3")


## The QA menu and the bot reach the horde and the player through these hooks.
func test_debug_hooks_for_the_qa_menu() -> void:
	director.stop_after = &"garden"
	director.run_from(&"garden")
	await _until(func() -> bool: return director._companions.has(&"ngu"), 10.0)
	director.debug_zombies_off()
	assert_eq(director._horde.max_active, 0, "zombies off;")
	director.debug_zombies_on()
	assert_eq(director._horde.max_active, 40, "zombies on;")
	player.spend_stamina(0.8)
	assert_true(player.stamina < 0.3, "stamina spent")
	director.debug_refill()
	assert_eq(player.stamina, 1.0, "stamina refilled;")
	director.debug_give_bar()
	assert_eq(player.bar_weapon.hits_left, 8, "a bar with 8 hits;")
	assert_eq(director._guards.size(), 12, "twelve guards;")
	assert_eq(String(director._guards[0].name), "Guard01", "guards have stable names;")


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
