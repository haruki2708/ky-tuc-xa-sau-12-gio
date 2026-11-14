extends TestCase
## T-258: in chapters 3-4 (floor 4 inside the campus's building B) the main stairwell's east wall stood 6 cm into the
## floor-4 washroom (its PS1 box Wall0.08... and W1Stairs' wall over 2.74 m reached x 0.16; the washroom's wall face is
## x 0.1), hiding T-256's mirror, pipes and notice board. On floor 4, beside the washroom, the wall now stops at x 0.1:
## the PS1 box is split into floors 1-3 (unchanged), floor 4 beside the washroom (EastWall4) and floor 4 behind it
## (EastWall4Back, unchanged thickness); main_stairs.glb's wall over 2.74 m and its end do the same. A deliberate
## collision change on floor 4 only: the stair side of the wall (its west face, x 0) stays where it was.
## Room 408 against the fire stairwell (x 43.84) was checked the same way (step 4 of the card): nothing stands in it.

const FLOOR := preload("res://scenes/levels/floor4/floor4.tscn")
const CAMPUS := preload("res://scenes/levels/campus/campus.tscn")
## Floor-4 rooms against a stairwell: washroom.tscn's room (inner faces x 0.1, 5.9, z -4.9, -0.1, ceiling 3.0) and
## room 408 (T-255 rooms.json: x 38.1 .. 43.84, back wall z -6.925).
const ROOMS := {
	"washroom": AABB(Vector3(0.1, 0.0, -4.9), Vector3(5.8, 3.0, 4.8)),
	"room 408": AABB(Vector3(38.1, 0.0, -6.925), Vector3(5.74, 3.0, 6.825)),
}
## The main stairwell's east wall boxes (world, building B at the campus's origin): main's one box was
## x 0 .. 0.16, y -10.75 .. 2.75, z -6.2 .. -0.2.
const WALL_BOXES := {
	"Wall0.08000000000000007": AABB(Vector3(0.0, -10.75, -6.2), Vector3(0.16, 10.75, 6.0)),
	"EastWall4": AABB(Vector3(0.0, 0.0, -5.0), Vector3(0.1, 2.75, 4.8)),
	"EastWall4Back": AABB(Vector3(0.0, 0.0, -6.2), Vector3(0.16, 2.75, 1.2)),
}
const WASHROOM_FACE := 0.1
var fixture: Node3D
var floor4: Node3D
var campus: Node3D
var _mouse_mode: Input.MouseMode


func before_each() -> void:
	_mouse_mode = Input.mouse_mode
	fixture = Node3D.new()
	tree.root.add_child(fixture)
	floor4 = FLOOR.instantiate() as Node3D
	campus = CAMPUS.instantiate() as Node3D
	fixture.add_child(floor4)
	fixture.add_child(campus)
	for frame in 3:
		await tree.physics_frame


func after_each() -> void:
	fixture.queue_free()
	await wait_frames(3)
	Input.mouse_mode = _mouse_mode


## Triangle against box, separating axes (box axes, the triangle's normal, the nine edge crossings).
static func triangle_meets_box(a: Vector3, b: Vector3, c: Vector3, box: AABB) -> bool:
	var centre := box.get_center()
	var h := box.size * 0.5
	var v0 := a - centre
	var v1 := b - centre
	var v2 := c - centre
	for i in 3:
		if minf(v0[i], minf(v1[i], v2[i])) > h[i] or maxf(v0[i], maxf(v1[i], v2[i])) < -h[i]:
			return false
	var n := (v1 - v0).cross(v2 - v0)
	if absf(n.dot(v0)) > h.x * absf(n.x) + h.y * absf(n.y) + h.z * absf(n.z):
		return false
	for edge: Vector3 in [v1 - v0, v2 - v1, v0 - v2]:
		for axis: Vector3 in [Vector3(0, -edge.z, edge.y), Vector3(edge.z, 0, -edge.x), Vector3(-edge.y, edge.x, 0)]:
			if axis.length_squared() < 1e-12:
				continue
			var p0 := v0.dot(axis)
			var p1 := v1.dot(axis)
			var p2 := v2.dot(axis)
			var r := h.x * absf(axis.x) + h.y * absf(axis.y) + h.z * absf(axis.z)
			if minf(p0, minf(p1, p2)) > r or maxf(p0, maxf(p1, p2)) < -r:
				return false
	return true


## Visible campus meshes with a triangle inside the box: "path (n triangles)".
func _meshes_in(box: AABB) -> Array[String]:
	var found: Array[String] = []
	for mesh: MeshInstance3D in campus.find_children("*", "MeshInstance3D", true, false):
		if mesh.mesh == null or not mesh.is_visible_in_tree():
			continue
		var xf := mesh.global_transform
		if not (xf * mesh.get_aabb()).intersects(box):
			continue
		var faces := mesh.mesh.get_faces()
		var count := 0
		for i in range(0, faces.size(), 3):
			if triangle_meets_box(xf * faces[i], xf * faces[i + 1], xf * faces[i + 2], box):
				count += 1
		if count > 0:
			found.append("%s (%d triangles)" % [campus.get_path_to(mesh), count])
	return found


func _bodies_in(box: AABB) -> Array[String]:
	var params := PhysicsShapeQueryParameters3D.new()
	var shape := BoxShape3D.new()
	shape.size = box.size
	params.shape = shape
	params.transform = Transform3D(Basis(), box.get_center())
	params.collision_mask = 0xFFFFFFFF
	var found: Array[String] = []
	for hit: Dictionary in fixture.get_world_3d().direct_space_state.intersect_shape(params, 64):
		var body := hit.collider as Node
		if body != null and campus.is_ancestor_of(body):
			found.append(String(campus.get_path_to(body)))
	return found


func test_no_campus_shape_or_mesh_stands_in_the_rooms() -> void:
	for room: String in ROOMS:
		# 2 mm inside the room's faces: what stands on a face (the wall boxes' x 0.1) is not in the room.
		var box := (ROOMS[room] as AABB).grow(-0.002)
		var meshes := _meshes_in(box)
		var bodies := _bodies_in(box)
		print("T258 %s: meshes %s, bodies %s" % [room, meshes, bodies])
		assert_true(meshes.is_empty(), "no campus mesh in the %s: %s" % [room, meshes])
		assert_true(bodies.is_empty(), "no campus collider in the %s: %s" % [room, bodies])


func test_westward_rays_meet_the_washroom_wall_at_its_face() -> void:
	var space := fixture.get_world_3d().direct_space_state
	var worst := 0.0
	# Between the sinks, under the mirror, in a stall, high under the ceiling (the old wall's top and W1Stairs' box).
	for at: Vector3 in [Vector3(3, 1.5, -0.3), Vector3(3, 0.4, -1.35), Vector3(3, 1.6, -1.85), Vector3(3, 0.4, -2.35),
			Vector3(3, 2.6, -3.3), Vector3(1.0, 1.5, -4.3), Vector3(3, 2.9, -2.0), Vector3(3, 2.97, -0.5)]:
		var query := PhysicsRayQueryParameters3D.create(at, Vector3(-1.0, at.y, at.z), 1)
		var hit := space.intersect_ray(query)
		assert_false(hit.is_empty(), "the ray from %s meets a wall" % at)
		if hit.is_empty():
			continue
		var x: float = (hit.position as Vector3).x
		worst = maxf(worst, absf(x - WASHROOM_FACE))
		assert_true(absf(x - WASHROOM_FACE) < 0.001, "from %s the wall is at x %.4f (washroom face 0.1; %s)" % [at, x,
			(hit.collider as Node).get_path()])
	print("T258 RAYS: west wall met at x 0.1 (worst %.5f)" % worst)


func test_wall_boxes_split_only_on_floor4_beside_the_washroom() -> void:
	var stairs := campus.get_node("BuildingB/MainStairs") as Node3D
	var volume := 0.0
	for name: String in WALL_BOXES:
		var body := stairs.get_node_or_null(name) as StaticBody3D
		assert_not_null(body, name)
		if body == null:
			continue
		assert_eq(body.collision_layer, 1, name + " world layer")
		assert_eq(body.collision_mask, 0, name + " mask")
		var shape_node := body.get_node("Collision") as CollisionShape3D
		var size := (shape_node.shape as BoxShape3D).size
		var box := AABB(shape_node.global_position - size * 0.5, size)
		var expected: AABB = WALL_BOXES[name]
		assert_true(box.position.is_equal_approx(expected.position) and box.size.is_equal_approx(expected.size),
			"%s is %s (expected %s)" % [name, box, expected])
		# The stair side (west face x 0) stays where main had it.
		assert_true(is_zero_approx(box.position.x), name + " west face at x 0")
		var mesh := body.get_node("Mesh") as MeshInstance3D
		var drawn := mesh.global_transform * mesh.get_aabb()
		assert_true(drawn.position.is_equal_approx(box.position) and drawn.size.is_equal_approx(box.size), name + " drawn as its box")
		volume += box.size.x * box.size.y * box.size.z
	# Main's box less the 6 cm strip beside the washroom on floor 4, nothing else.
	var main_box := 0.16 * 13.5 * 6.0
	var strip := 0.06 * 2.75 * 4.8
	assert_true(absf(volume - (main_box - strip)) < 1e-4, "the three boxes are main's box less the strip (%.5f)" % volume)


## From inside the stairwell its east wall's plaster (W1Stairs, x -0.103) is still there over floor 4's storey: rays
## from over the well, eastward, meet a W1Stairs wall triangle at the plaster's line everywhere.
func test_stairwell_side_of_the_wall_stays_closed() -> void:
	var walls := campus.get_node("BuildingB/MainStairs/W1Stairs").find_child("Walls", true, false) as MeshInstance3D
	assert_not_null(walls, "W1Stairs walls")
	if walls == null:
		return
	var xf := walls.global_transform
	var faces := walls.mesh.get_faces()
	var missing: Array[Vector3] = []
	for y: float in [-1.5, 0.1, 1.0, 2.0, 2.7, 2.8, 3.0, 3.6]:
		for z: float in [-0.3, -1.2, -2.4, -3.6, -4.8, -5.6, -6.1]:
			var origin := Vector3(-1.0, y, z)
			var nearest := INF
			for i in range(0, faces.size(), 3):
				var hit: Variant = Geometry3D.ray_intersects_triangle(origin, Vector3.RIGHT, xf * faces[i], xf * faces[i + 1], xf * faces[i + 2])
				if hit != null:
					nearest = minf(nearest, (hit as Vector3).x)
			if absf(nearest - -0.103) > 0.02:
				missing.append(origin)
	assert_true(missing.is_empty(), "the stairwell's east plaster closed at %s" % [missing])


func test_player_walks_main_flights_4a_4b_and_landing_4() -> void:
	var player := load("res://scenes/player/player.tscn").instantiate() as CharacterBody3D
	player.position = Vector3(-0.5, 0.03, 3.0)
	fixture.add_child(player)
	# As test_t254_landing_rail: the scene's capsule, mask, floor snap and move_and_slide, steered here.
	player.set_physics_process(false)
	player.set_process_input(false)
	player.set_process_unhandled_input(false)
	for frame in 3:
		await tree.physics_frame
	# Across landing 4 by the washroom wall, down 4A to the turn landing, down 4B by its east wall to floor 3's
	# landing, then back up both flights to landing 4.
	var route: Array[Vector3] = [Vector3(-0.5, 0.0, 0.6), Vector3(-4.2, 0.0, 1.2), Vector3(-3.05, 0.0, 0.45),
		Vector3(-3.05, -1.65, -5.4), Vector3(-0.5, -1.65, -5.4), Vector3(-0.5, -3.3, 0.6), Vector3(-1.2, -3.3, 1.5),
		Vector3(-1.2, -1.65, -5.4), Vector3(-3.8, -1.65, -5.4), Vector3(-3.8, 0.0, 0.6), Vector3(-1.0, 0.0, 2.5)]
	for target: Vector3 in route:
		if not await _walk_to(player, target):
			return
	assert_true(player.is_on_floor(), "back on landing 4, standing")
	print("T258 WALK: landing 4, flights 4A and 4B down and up")


func _walk_to(player: CharacterBody3D, target: Vector3) -> bool:
	for frame in 420:
		await tree.physics_frame
		var offset := target - player.global_position
		offset.y = 0.0
		if offset.length() < 0.15 and absf(player.global_position.y - target.y) < 0.15:
			return true
		var direction := offset.normalized()
		player.velocity.x = direction.x * 2.2
		player.velocity.z = direction.z * 2.2
		if not player.is_on_floor():
			player.velocity += player.get_gravity() * player.get_physics_process_delta_time()
		else:
			player.velocity.y = 0.0
		player.move_and_slide()
	assert_true(false, "%s unreachable; feet at %s" % [target, player.global_position])
	return false
