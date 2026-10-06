extends TestCase
## T-188/D-060: real player body, gravity and slide motion through Floor4 + Campus.

var fixture: Node3D
var campus: Node3D
var player: CharacterBody3D
var _mouse_mode: Input.MouseMode


func before_each() -> void:
	_mouse_mode = Input.mouse_mode
	fixture = Node3D.new()
	tree.root.add_child(fixture)
	var floor4 := load("res://scenes/levels/floor4/floor4.tscn").instantiate() as Node3D
	campus = load("res://scenes/levels/campus/campus.tscn").instantiate() as Node3D
	fixture.add_child(floor4)
	fixture.add_child(campus)
	campus.set_fire_door_open(true)
	player = load("res://scenes/player/player.tscn").instantiate() as CharacterBody3D
	player.position = Vector3(42, 0.03, 2)
	fixture.add_child(player)
	# Replace input steering only; retain the scene's capsule, mask, floor snap
	# and CharacterBody3D motion. No geometry changes or waypoint teleporting.
	player.set_physics_process(false)
	player.set_process_input(false)
	player.set_process_unhandled_input(false)
	for frame in 3:
		await tree.physics_frame


func after_each() -> void:
	fixture.queue_free()
	await wait_frames(3)
	Input.mouse_mode = _mouse_mode


func _step(direction: Vector3, speed: float = 2.2, jump: bool = false) -> void:
	player.velocity.x = direction.x * speed
	player.velocity.z = direction.z * speed
	if jump and player.is_on_floor():
		player.velocity.y = 4.5
	elif not player.is_on_floor():
		player.velocity += player.get_gravity() * player.get_physics_process_delta_time()
	else:
		player.velocity.y = 0.0
	player.move_and_slide()


func _walk_to(target: Vector3, label: String) -> bool:
	for frame in 360:
		await tree.physics_frame
		var offset := target - player.global_position
		offset.y = 0
		if offset.length() < 0.15 and absf(player.position.y - target.y) < 0.15:
			return true
		_step(offset.normalized())
	var blockers: Array[String] = []
	for index in player.get_slide_collision_count():
		var collider := player.get_slide_collision(index).get_collider() as Node
		if collider != null:
			blockers.append(String(collider.name))
	assert_true(false, "%s unreachable; feet=%s target=%s blockers=%s" % [label, player.position, target, blockers])
	return false


func test_real_player_walks_floor4_fire_door_both_flights_to_floor2_hall() -> void:
	var targets: Array[Vector3] = [
		Vector3(45.2, 0, 2), Vector3(45.2, 0, 0.4),
		Vector3(45.2, -1.65, -5.4), Vector3(47.8, -1.65, -5.4),
		Vector3(47.8, -3.3, 0.5), Vector3(45.2, -3.3, 0.5),
		Vector3(45.2, -4.95, -5.4), Vector3(47.8, -4.95, -5.4),
		Vector3(47.8, -6.6, 0.5), Vector3(47.8, -6.6, 2), Vector3(42, -6.6, 2),
	]
	var labels: Array[String] = ["fire door", "4A top", "4A turn", "4B top", "floor3 landing", "3A top", "3A turn", "3B top", "floor2 landing", "floor2 exit", "floor2 hall"]
	for index in targets.size():
		if not await _walk_to(targets[index], labels[index]):
			return
	assert_true(player.is_on_floor(), "arrived walking on floor2, not falling through it")
	assert_true(player.position.x < 44 and absf(player.position.y + 6.6) < 0.1)
	print("T188 WALK: reached floor2 hall, feet=", player.position)


func test_floor2_landing_cannot_walk_or_fall_through_collapsed_flight() -> void:
	# Independent starts span the entire stairwell, including both slab edges
	# and the narrow gap between flight A and the usable returning flight B.
	for x in [44.35, 45.25, 46.35, 46.6, 46.9, 47.8, 48.65]:
		player.position = Vector3(x, -6.57, 0.7)
		player.velocity = Vector3.ZERO
		for frame in 210:
			await tree.physics_frame
			_step(Vector3(0, 0, -1), 3.6)
			if player.position.y < -6.9:
				assert_true(false, "escaped collapse from x=%s; feet=%s" % [x, player.position])
				return
	assert_false(campus.has_node("Navigation/FireStairsDown2A"))
	print("T188 BLOCK: all seven floor2 approaches remain above floor1")


func test_return_flight_edges_and_jump_cannot_bypass_collapsed_flight() -> void:
	# A synthetic 1 m hop is stronger than current player input (no jump action).
	# Reach each departure point on foot from floor2, then try crossing the well.
	for z in [-0.6, -2.4, -4.5]:
		for hop in [false, true]:
			player.position = Vector3(47.8, -6.57, 0.7)
			player.velocity = Vector3.ZERO
			if not await _walk_to(Vector3(47.8, -6.6 - z * 3.3 / 9.6, z), "reverse 3B edge"):
				return
			for frame in 180:
				await tree.physics_frame
				_step(Vector3.LEFT, 3.6, hop and frame == 0)
				if player.position.y < -6.9:
					assert_true(false, "fell through well at z=%s hop=%s feet=%s" % [z, hop, player.position])
					return
	print("T188 EDGES: walk/hop probes cannot drop to floor1")
