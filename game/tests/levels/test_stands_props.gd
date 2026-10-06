extends TestCase
## T-192 (D-064): the rebuilt stands, the moved gates and the street props.

const G := -9.9
const MAIN_K := 0.38 / 0.85
const MAIN_Z0 := 212.7
const TRIANGLE_BUDGET_PROPS := 32000
const TRIANGLE_BUDGET_STADIUM := 12000

var fixture: Node3D
var campus: Node3D
var player: CharacterBody3D
var _mouse_mode: Input.MouseMode


func before_each() -> void:
	_mouse_mode = Input.mouse_mode
	fixture = Node3D.new()
	fixture.name = "StandsFixture"
	tree.root.add_child(fixture)
	campus = (load("res://scenes/levels/campus/campus.tscn") as PackedScene).instantiate() as Node3D
	fixture.add_child(campus)
	await tree.physics_frame
	await tree.physics_frame


func after_each() -> void:
	fixture.queue_free()
	await wait_frames(3)
	Input.mouse_mode = _mouse_mode


func _main_y(z: float) -> float:
	return G + maxf(0.0, MAIN_K * (z - MAIN_Z0))


func _capsule_clear(feet: Vector3, height: float = 1.75) -> bool:
	var capsule := CapsuleShape3D.new()
	capsule.radius = .3
	capsule.height = height
	var query := PhysicsShapeQueryParameters3D.new()
	query.shape = capsule
	query.transform.origin = feet + Vector3(0, height * .5 + .015, 0)
	query.collision_mask = 1
	return campus.get_world_3d().direct_space_state.intersect_shape(query).is_empty()


func _ground_hit(x: float, z: float, from_y: float = 14.0) -> Dictionary:
	var query := PhysicsRayQueryParameters3D.create(Vector3(x, from_y, z), Vector3(x, G - 1.0, z), 1)
	return campus.get_world_3d().direct_space_state.intersect_ray(query)


func _sync_navigation() -> RID:
	var map := campus.get_world_3d().navigation_map
	NavigationServer3D.map_force_update(map)
	for attempt in 120:
		if NavigationServer3D.map_get_iteration_id(map) > 0:
			break
		await tree.physics_frame
	# The large shared outdoor region synchronizes on a worker thread.
	for attempt in 240:
		if NavigationServer3D.map_get_closest_point(map, Vector3(115, G, 166)).distance_to(Vector3(115, G, 166)) < .1:
			break
		await tree.physics_frame
	return map


func _triangles(node: Node) -> int:
	var total := 0
	if node is MeshInstance3D and node.mesh:
		total += node.mesh.get_faces().size() / 3
	elif node is MultiMeshInstance3D and node.multimesh and node.multimesh.mesh:
		total += node.multimesh.mesh.get_faces().size() / 3 * node.multimesh.instance_count
	for child in node.get_children():
		total += _triangles(child)
	return total


func test_main_stand_is_tall_covered_and_next_to_the_track() -> void:
	var stadium := campus.get_node("Stadium")
	var tiers: Vector2i = stadium.get_meta("tiers")
	assert_true(tiers.x >= 16 and tiers.x <= 20, "main stand has 16-20 tiers (%d)" % tiers.x)
	assert_true(tiers.y >= 6 and tiers.y <= 8, "south stand has 6-8 tiers (%d)" % tiers.y)
	var top := _ground_hit(198, 227.5)
	assert_false(top.is_empty(), "the stand has a walkable top")
	var height: float = top.position.y - G
	assert_true(height >= 6.0 and height <= 8.0, "main stand is 6-8 m tall (%.2f)" % height)
	# Front edge close to the running track (first tread starts at z = 212.7, the track ends at 210.7).
	assert_false(_ground_hit(198, 213.3).is_empty())
	assert_true(_ground_hit(198, 213.3).position.y - G < .5, "tier 0 is level with the ground")
	# Roof on columns: nine columns behind the stand and a roof slab above the top row.
	var roof_boxes := 0
	for part in stadium.find_children("Stand_concrete_box_*", "Node3D", false, false):
		roof_boxes += part.find_children("*", "MultiMeshInstance3D", true, false).size()
	assert_true(roof_boxes > 0, "stand batches exist")
	for i in 9:
		assert_true(stadium.has_node("RoofColumn%d" % i), "roof column %d" % i)
	var south := _ground_hit(198, 114.0)
	assert_false(south.is_empty())
	var south_height: float = south.position.y - G
	assert_true(south_height >= 2.0 and south_height <= 3.4, "south stand is low (%.2f)" % south_height)
	assert_true(_ground_hit(198, 119.2).position.y - G < .5, "south stand starts at the track")


func test_old_small_stand_is_gone_and_gates_moved_to_the_stand_ends() -> void:
	# Nothing left of the small stand that stood outside the south fence at z = 108.
	assert_true(_ground_hit(198, 109.0).is_empty() or _ground_hit(198, 109.0).position.y < G + .1, "no stand outside the south fence")
	assert_false(campus.get_node("Stadium").has_node("SecondaryBleachers/Tier0"), "old tier boxes are gone")
	# Open gates at both ends of the north and south stands, west and east as before.
	for gate in [Vector3(148, G, 212.4), Vector3(248, G, 212.4), Vector3(148, G, 119.8), Vector3(248, G, 119.8), Vector3(110, G, 166), Vector3(286, G, 166)]:
		assert_true(_capsule_clear(gate + Vector3(0, .02, 0)), "gate open at %s" % gate)
	# The centre of both stands is closed to the pitch: a low wall in front, no way through.
	for blocked in [Vector3(164, G, 212.4), Vector3(186, G, 212.4), Vector3(176, G, 119.8), Vector3(198, G, 119.8)]:
		assert_false(_capsule_clear(blocked + Vector3(0, .02, 0)), "wall closes %s" % blocked)
	# Fence runs next to the gates.
	assert_false(_capsule_clear(Vector3(130, G + .02, 212.4)))
	assert_false(_capsule_clear(Vector3(268, G + .02, 119.8)))


func test_anchors_siren_spot_bar_spawn_and_pipes() -> void:
	var siren: Node3D = campus.get_anchor("Clues/SirenSpot")
	var floor_hit := _ground_hit(siren.global_position.x, siren.global_position.z)
	assert_true(absf(floor_hit.position.y - siren.global_position.y) < .3, "siren spot lies on the top row (%s vs %s)" % [floor_hit.position.y, siren.global_position.y])
	var highest := -1000.0
	for x in range(160, 237, 4):
		for z_step in 30:
			var hit := _ground_hit(float(x), 213.0 + z_step * .5)
			if not hit.is_empty():
				highest = maxf(highest, hit.position.y)
	assert_true(siren.global_position.y >= highest - .35, "siren spot is at the highest place of the main stand (%.2f of %.2f)" % [siren.global_position.y, highest])
	assert_true(siren.global_position.y - G >= 6.0)
	var bar: Node3D = campus.get_anchor("BarSpawns/B03")
	assert_true(bar.global_position.x > 158 and bar.global_position.x < 238 and bar.global_position.z > 217.8 and bar.global_position.z < 228.0, "B03 lies under the main stand")
	assert_true(absf(bar.global_position.y - (G + .08)) < .05)
	# Roof of the space under the stand is well above the 2 m the core uses to settle bars.
	var up := campus.get_world_3d().direct_space_state.intersect_ray(PhysicsRayQueryParameters3D.create(bar.global_position + Vector3(0, .1, 0), bar.global_position + Vector3(0, 6, 0), 1))
	assert_false(up.is_empty())
	assert_true(up.position.y - bar.global_position.y > 2.5, "headroom above B03 is %.2f" % (up.position.y - bar.global_position.y))
	assert_eq(campus.get_anchor("Start_stadium").global_position, Vector3(115, G, 166), "Start_stadium unchanged")


func _walk_to(target: Vector3, label: String) -> bool:
	var frames := 200 + int(player.global_position.distance_to(target) / 2.2 * 60.0 * 1.4)
	for frame in frames:
		await tree.physics_frame
		var offset := target - player.global_position
		offset.y = 0
		if offset.length() < 0.2 and absf(player.position.y - target.y) < 0.2:
			return true
		_step(offset.normalized())
	var blockers: Array[String] = []
	for index in player.get_slide_collision_count():
		var collider := player.get_slide_collision(index).get_collider() as Node
		if collider != null:
			blockers.append(String(collider.name))
	assert_true(false, "%s unreachable; feet=%s target=%s blockers=%s" % [label, player.position, target, blockers])
	return false


func _step(direction: Vector3, speed: float = 2.4) -> void:
	player.velocity.x = direction.x * speed
	player.velocity.z = direction.z * speed
	if not player.is_on_floor():
		player.velocity += player.get_gravity() * player.get_physics_process_delta_time()
	else:
		player.velocity.y = 0.0
	player.move_and_slide()


func _spawn_player(at: Vector3) -> void:
	player = (load("res://scenes/player/player.tscn") as PackedScene).instantiate() as CharacterBody3D
	player.position = at
	fixture.add_child(player)
	player.set_physics_process(false)
	player.set_process_input(false)
	player.set_process_unhandled_input(false)
	for frame in 3:
		await tree.physics_frame


func test_real_player_walks_from_the_track_to_the_highest_row() -> void:
	await _spawn_player(Vector3(173, G + .03, 205))
	for z in [209.0, 212.0, 214.0, 218.0, 223.0, 227.3]:
		var point := Vector3(173, _main_y(z), z)
		if not await _walk_to(point, "aisle z=%s" % z):
			return
	assert_true(player.is_on_floor())
	var siren: Node3D = campus.get_anchor("Clues/SirenSpot")
	if not await _walk_to(Vector3(siren.global_position.x, siren.global_position.y, siren.global_position.z), "siren spot"):
		return
	var offset := player.global_position - siren.global_position
	assert_true(absf(offset.y) <= .6 and Vector2(offset.x, offset.z).length() <= 2.5, "the player stands where the siren plays (%s)" % offset)
	print("T192 WALK: top row reached, feet=", player.position)


func test_real_player_walks_into_the_space_under_the_stand_and_picks_the_bar_spot() -> void:
	await _spawn_player(Vector3(148, G + .03, 204))
	var bar: Node3D = campus.get_anchor("BarSpawns/B03")
	var route: Array[Vector3] = [Vector3(148, G, 210), Vector3(148, G, 216), Vector3(148, G, 231), Vector3(166, G, 231), Vector3(166, G, 226.4), Vector3(bar.global_position.x, G, bar.global_position.z - .9)]
	var labels: Array[String] = ["north gate", "outside the fence", "behind the stand", "behind B03", "under the stand", "next to B03"]
	for index in route.size():
		if not await _walk_to(route[index], labels[index]):
			return
	assert_true(player.global_position.distance_to(bar.global_position) < 1.5, "close enough to take the bar")


func test_navigation_garden_stadium_gate_canteen_and_stand() -> void:
	var map := await _sync_navigation()
	var stops: Array[Vector3] = [campus.get_anchor("Start_garden").global_position, campus.get_anchor("Start_stadium").global_position,
		campus.get_anchor("Start_gate").global_position, campus.get_anchor("CanteenExit").global_position]
	for index in range(stops.size() - 1):
		var path := NavigationServer3D.map_get_path(map, stops[index], stops[index + 1], true)
		assert_true(path.size() > 1 and path[-1].distance_to(stops[index + 1]) < .6, "route %d: %s -> %s ends at %s" % [index, stops[index], stops[index + 1], path[-1] if not path.is_empty() else Vector3.INF])
	# Zombies spawned at each pitch entrance reach both stands and the top row.
	var siren: Vector3 = campus.get_anchor("Clues/SirenSpot").global_position
	var tier: Vector3 = Vector3(173, _main_y(220.0), 220.0)
	var south_tier := Vector3(183, G + .4 / .9 * 4.0, 115.5)
	for spawn in campus.get_anchor("ZombieSpawns/Stadium").get_children():
		var start: Vector3 = (spawn as Node3D).global_position
		# The big outdoor lattice polygons answer closest-point queries up to 2 m away (also on origin/main).
		assert_true(NavigationServer3D.map_get_closest_point(map, start).distance_to(start) < 2.1, "%s lies on the navmesh" % spawn.name)
		for target in [siren, tier, south_tier]:
			var path := NavigationServer3D.map_get_path(map, start, target, true)
			assert_true(path.size() > 1 and path[-1].distance_to(target) < .6, "%s reaches %s (ends at %s)" % [spawn.name, target, path[-1] if not path.is_empty() else Vector3.INF])
	# The way from the pitch to the space under the stand goes round a gate, not through the stand.
	var under := NavigationServer3D.map_get_path(map, Vector3(198, G, 190), Vector3(190, G, 225), true)
	assert_true(under.size() > 2 and under[-1].distance_to(Vector3(190, G, 225)) < .6, "path under the stand exists")
	var length := 0.0
	for i in range(under.size() - 1):
		length += under[i].distance_to(under[i + 1])
	assert_true(length > 90.0, "path to the space under the stand goes round the gate (%.1f m)" % length)
	# The four entrances for the horde stay in the four directions.
	var spawns: Node3D = campus.get_anchor("ZombieSpawns/Stadium")
	var north: bool = false
	var south: bool = false
	var west: bool = false
	var east: bool = false
	for spawn in spawns.get_children():
		var p: Vector3 = (spawn as Node3D).global_position
		north = north or p.z > 205.0
		south = south or p.z < 128.0
		west = west or p.x < 120.0
		east = east or p.x > 276.0
	assert_true(north and south and west and east, "zombies still pour in from north, south, west and east")


func test_street_props_fill_every_route_and_leave_the_lane_free() -> void:
	var props := campus.get_node("Props")
	var points: PackedVector3Array = props.get_meta("points")
	assert_true(points.size() >= 200, "street props placed: %d" % points.size())
	var markers: Array[Vector3] = []
	for child in campus.get_anchor("Paths/Nhat").get_children():
		if int(String(child.name).substr(1, 2)) >= 10:
			markers.append((child as Node3D).global_position)
	assert_true(markers.size() > 15)
	var worst := 99
	var checked := 0
	for i in range(markers.size() - 1):
		var a := markers[i]
		var b := markers[i + 1]
		# The route inside the garden follows the lanes between the beds (nav, not a straight line).
		var in_garden: bool = a.x == 22.0 and b.x == 22.0
		var length := a.distance_to(b)
		var steps := maxi(1, int(length / 5.0))
		for k in steps + 1:
			var p := a.lerp(b, float(k) / steps)
			var near := 0
			for point in points:
				if Vector2(point.x - p.x, point.z - p.z).length() <= 30.0:
					near += 1
			worst = mini(worst, near)
			assert_true(near >= 3, "at %s only %d props within 30 m" % [p, near])
			var inside_canteen: bool = p.x > 168 and p.x < 212 and p.z > 19 and p.z < 56
			var inside_garden: bool = p.x > -1 and p.x < 45 and p.z > 5.5 and p.z < 50
			if in_garden or inside_canteen or inside_garden:
				continue
			var normal := Vector3(-(b.z - a.z), 0, b.x - a.x).normalized()
			for lateral in [-2.0, 0.0, 2.0]:
				var spot: Vector3 = p + normal * lateral
				spot.y = G + .02
				# The sill ramp below the manager window (T-183) is walked on, not blocked.
				if spot.x > 1.5 and spot.x < 6.5 and spot.z > -11.5 and spot.z < -6.5:
					continue
				checked += 1
				assert_true(_capsule_clear(spot), "lane blocked at %s (route %d, %.0f m aside)" % [spot, i, lateral])
	print("T192 PROPS: ", points.size(), " notable props, fewest within 30 m = ", worst, ", lane samples = ", checked)
	# Every spawn and idle point stays free of solid props.
	for group in ["ZombieSpawns", "ZombieIdle"]:
		for area in campus.get_anchor(group).get_children():
			for marker in area.get_children():
				var at: Vector3 = (marker as Node3D).global_position
				if at.y < G + .5:
					assert_true(_capsule_clear(Vector3(at.x, G + .02, at.z)), "%s/%s/%s is free" % [group, area.name, marker.name])


func test_triangle_budget_and_batched_nodes() -> void:
	var props := _triangles(campus.get_node("Props"))
	var stadium := _triangles(campus.get_node("Stadium"))
	print("T192 TRIANGLES: props=", props, " stadium=", stadium)
	assert_true(props <= TRIANGLE_BUDGET_PROPS, "props %d triangles" % props)
	assert_true(stadium <= TRIANGLE_BUDGET_STADIUM, "stadium %d triangles" % stadium)
	var multis := campus.get_node("Props").find_children("*", "MultiMeshInstance3D", true, false)
	assert_true(multis.size() > 20 and multis.size() < 300, "props are batched in chunked MultiMeshes (%d)" % multis.size())
	for multi: MultiMeshInstance3D in multis:
		assert_true(multi.visibility_range_end > 0.0, "chunk %s is distance culled" % multi.get_parent().name)
	var lights := campus.get_node("Props/Lights").get_children()
	assert_true(lights.size() >= 8, "some street lamps still burn")
	for light in lights:
		assert_false((light as Light3D).shadow_enabled, "no shadow lights")
