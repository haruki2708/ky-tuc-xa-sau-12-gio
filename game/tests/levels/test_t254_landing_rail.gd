extends TestCase
## T-254: floor 4's landing edge over the stair well and flight 4B, open in both building B stairwells, gets a rail:
## a thin layer-1 box (5 cm x 1 m, standing on the slab, clear of flights 4A/4B and the landing's walkway) where the
## drawn balustrade stands, so the real player pushing at that edge from anywhere on the landing stays on floor 4,
## and still walks down flight 4A past the rail's end. test_t250_realistic_wave1.gd proves every other stairwell
## collider unchanged (its print leaves these two bodies out).

## World boxes: from flight 4A's top newel (x0 + 2.255) to the side-B wall (main: floor 4's washroom wall at x -0.1;
## fire: the stairwell wall at x 49), on the slab's edge z 0 .. 0.05, 1 m high.
const RAILS := {
	"Main": AABB(Vector3(-2.745, 0.0, 0.0), Vector3(2.645, 1.0, 0.05)),
	"Fire": AABB(Vector3(46.255, 0.0, 0.0), Vector3(2.745, 1.0, 0.05)),
}
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
	player.position = Vector3(-1.0, 0.03, 2.0)
	fixture.add_child(player)
	# As test_fire_stairs: the scene's capsule, mask, floor snap and move_and_slide, steered here instead of by input.
	player.set_physics_process(false)
	player.set_process_input(false)
	player.set_process_unhandled_input(false)
	for frame in 3:
		await tree.physics_frame


func after_each() -> void:
	fixture.queue_free()
	await wait_frames(3)
	Input.mouse_mode = _mouse_mode


func _x0(side: String) -> float:
	return -5.0 if side == "Main" else 44.0


func _rail(side: String) -> StaticBody3D:
	return campus.get_node_or_null("BuildingB/%sStairs/Landing4Rail" % side) as StaticBody3D


func _step(direction: Vector3, speed: float = 2.2) -> void:
	player.velocity.x = direction.x * speed
	player.velocity.z = direction.z * speed
	if not player.is_on_floor():
		player.velocity += player.get_gravity() * player.get_physics_process_delta_time()
	else:
		player.velocity.y = 0.0
	player.move_and_slide()


func _place(at: Vector3) -> void:
	player.global_position = at
	player.velocity = Vector3.ZERO
	await tree.physics_frame


func _walk_to(target: Vector3, label: String) -> bool:
	for frame in 360:
		await tree.physics_frame
		var offset := target - player.global_position
		offset.y = 0
		if offset.length() < 0.15 and absf(player.global_position.y - target.y) < 0.15:
			return true
		_step(offset.normalized())
	assert_true(false, "%s unreachable; feet=%s target=%s" % [label, player.global_position, target])
	return false


func test_rail_colliders_stand_on_the_landing_edge() -> void:
	await tree.physics_frame
	var space := campus.get_world_3d().direct_space_state
	for side: String in RAILS:
		var body := _rail(side)
		assert_not_null(body, side + " Landing4Rail")
		if body == null:
			continue
		assert_eq(body.collision_layer, 1, side + " rail on the world layer")
		assert_eq(body.collision_mask, 0, side + " rail mask")
		var shapes: Array[Node] = body.find_children("*", "CollisionShape3D", false, false)
		assert_eq(shapes.size(), 1, side + " one shape")
		if shapes.size() != 1:
			continue
		var shape_node := shapes[0] as CollisionShape3D
		assert_true(shape_node.shape is BoxShape3D, side + " box shape")
		var size := (shape_node.shape as BoxShape3D).size
		var box := AABB(shape_node.global_position - size / 2.0, size)
		var want: AABB = RAILS[side]
		assert_true(box.position.is_equal_approx(want.position) and box.size.is_equal_approx(want.size),
			"%s rail box %s, want %s" % [side, box, want])
		var x0 := _x0(side)
		# From before flight 4A's inner edge (x0 + 2.28, the well's start) to the side-B wall, on the slab only:
		# nothing over flight 4A or 4B (z < 0) and nothing in the landing's walkway (z > 0.05, as T-250's test has it).
		assert_true(box.position.x <= x0 + 2.28 and box.end.x >= x0 + 4.9, "%s spans the well and flight 4B" % side)
		assert_true(box.position.z >= 0.0 and box.end.z <= 0.05 + 0.0001, "%s on the slab edge only" % side)
		assert_false(box.intersects(AABB(Vector3(x0 + 0.05, 0.02, 0.05), Vector3(4.9, 1.9, 3.9))), side + " clear of the landing walkway")
		assert_true(box.end.x <= x0 + 5.0 + 0.0001, side + " stops at the wall")
		# A body from the landing towards the well meets the rail at every point along it, right up to the wall.
		for k in 9:
			var x := lerpf(x0 + 2.3, x0 + 4.88, k / 8.0)
			for y: float in [0.2, 0.9]:
				var query := PhysicsRayQueryParameters3D.create(Vector3(x, y, 0.6), Vector3(x, y, -0.6))
				var hit := space.intersect_ray(query)
				assert_false(hit.is_empty(), "%s edge closed at x %.2f, y %.1f" % [side, x, y])
				if not hit.is_empty():
					assert_true(hit.collider == body, "%s edge at x %.2f meets the rail, not %s" % [side, x, (hit.collider as Node).name])


func test_drawn_rail_stands_inside_its_collider() -> void:
	for side: String in RAILS:
		var x0 := _x0(side)
		var rails := campus.get_node_or_null("BuildingB/%sStairs/W1Stairs" % side) as Node3D
		assert_not_null(rails, side + " stairwell model")
		if rails == null:
			continue
		var mesh := rails.find_child("Rails", true, false) as MeshInstance3D
		assert_not_null(mesh, side + " Rails mesh")
		if mesh == null:
			continue
		# Every rail vertex near floor 4's landing edge on side B (past flight 4A's newel) is the new balustrade.
		var near := AABB(Vector3(x0 + 2.3, -0.05, -0.2), Vector3(2.8, 1.3, 0.4))
		# Within 5 mm of the box (the handrail's round section), the wall newel's cap 2 cm over its top as the
		# flights' newels have it (1.02 m).
		var allowed: AABB = (RAILS[side] as AABB).grow(0.005)
		allowed.size.y += 0.02
		var count := 0
		var outside := 0
		var example := Vector3.ZERO
		var lo := INF
		var hi := -INF
		for surface in mesh.mesh.get_surface_count():
			for vertex: Vector3 in mesh.mesh.surface_get_arrays(surface)[Mesh.ARRAY_VERTEX] as PackedVector3Array:
				var p := mesh.global_transform * vertex
				if not near.has_point(p):
					continue
				count += 1
				lo = minf(lo, p.x)
				hi = maxf(hi, p.x)
				if not allowed.has_point(p):
					outside += 1
					example = p
		assert_true(count > 200, "%s balustrade drawn on the edge (%d vertices)" % [side, count])
		assert_eq(outside, 0, "%s balustrade inside its collider (e.g. %s)" % [side, example])
		assert_true(lo < x0 + 2.4 and hi > (RAILS[side] as AABB).end.x - 0.01, "%s balustrade from the newel to the wall: %.3f..%.3f" % [side, lo, hi])


func test_player_pushing_at_the_edge_stays_on_floor4() -> void:
	for side: String in RAILS:
		var x0 := _x0(side)
		# Over the well gap, along flight 4B and in the corner at the wall; straight at the edge and slanting.
		for x: float in [x0 + 2.45, x0 + 3.0, x0 + 3.8, x0 + 4.6]:
			for direction: Vector3 in [Vector3(0, 0, -1), Vector3(0.5, 0, -1).normalized()]:
				await _place(Vector3(x, 0.03, 0.9))
				var lowest := player.global_position.y
				for frame in 150:
					await tree.physics_frame
					_step(direction, 3.6)
					lowest = minf(lowest, player.global_position.y)
					# Main's landing opens east into floor 4's corridor: a slanting push that slides along the rail
					# out of the stairwell has passed the rail's whole length.
					if player.global_position.x > x0 + 5.0:
						break
				var feet := player.global_position
				assert_true(lowest > -0.1, "%s from x %.2f dir %s: fell to %.2f, feet=%s" % [side, x, direction, lowest, feet])
				assert_true(feet.z > 0.25, "%s from x %.2f dir %s: held at the rail, feet=%s" % [side, x, direction, feet])
	print("T254 RAIL: every push at both landing edges stays on floor 4")


func test_player_still_walks_down_flight_4a_past_the_rail() -> void:
	for side: String in RAILS:
		var x0 := _x0(side)
		await _place(Vector3(x0 + 4.2, 0.03, 1.5))
		# Down flight 4A by its well side, brushing the rail's end, to the turn landing and on to flight 4B's top.
		var targets: Array[Vector3] = [Vector3(x0 + 1.95, 0.0, 0.45), Vector3(x0 + 1.95, -1.65, -5.4), Vector3(x0 + 3.8, -1.65, -5.4)]
		for target: Vector3 in targets:
			if not await _walk_to(target, "%s %s" % [side, target]):
				return
		assert_true(player.is_on_floor(), side + " on the turn landing")
	print("T254 WALK: flight 4A free past the rail on both sides")
