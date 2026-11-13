extends TestCase
## T-256 (D-170): the rest of floor 4 in room 407's style: the shared washroom (part A), the corridor's props (B), the
## fire door's lever clear of the railing (C), the CCTV corridor set (D). Visual only where the card says so: every
## collider of those scenes prints as main had it (main 8aad1c3, before T-256), old nodes and anchors stay where they
## were, the PS1 pictures are hidden not freed, and a body still walks where it walked.

const FLOOR := preload("res://scenes/levels/floor4/floor4.tscn")
const WASHROOM_MESHES: Array[String] = ["Shell", "Stalls", "Trough", "Fixtures", "Props", "MirrorStain"]
const KEPT_WASHROOM: Array[String] = ["Floor", "WestWall", "BackWall", "EastWall", "Ceiling", "EntranceWest",
	"EntranceEast", "EntranceLintel", "StallDoor_0", "StallDoor_1", "StallDoor_2", "StallPartition_0", "StallPartition_1",
	"StallPartition_2", "Sink_0", "Sink_1", "Sink_2", "Tap_0", "Tap_1", "Tap_2", "TapWater", "Mirror", "WashroomLight",
	"WashroomLight/LightHum", "WaterDrips", "ReverbZone", "AmbientZone", "Details"]
## Collider prints of main 8aad1c3 (_collider_print below): the washroom.
const WASHROOM_PRINT := "042e9400a266b40b28fade2b91f8675e"
const RADIUS := 0.3
const HEIGHT := 1.75
const WALK_SPEED := 6.0
var fixtures: Array[Node] = []


func after_each() -> void:
	for node in fixtures:
		if is_instance_valid(node):
			node.queue_free()
	fixtures.clear()
	await wait_frames(2)


func _spawn(upgraded := true) -> Node3D:
	var floor4 := FLOOR.instantiate() as Node3D
	floor4.get_node("Washroom").set("upgraded", upgraded)
	fixtures.append(floor4)
	tree.root.add_child(floor4)
	return floor4


## Every CollisionShape3D under `root` (and the body holding it): path, shape, size, place, layers, on or off.
static func collider_print(root: Node, skip: Callable = Callable()) -> String:
	var rows: Array[String] = []
	var to_root := (root as Node3D).global_transform.affine_inverse() if root is Node3D else Transform3D()
	for node: Node in root.find_children("*", "CollisionShape3D", true, false):
		if skip.is_valid() and skip.call(node):
			continue
		var shape_node := node as CollisionShape3D
		var body := shape_node.get_parent() as CollisionObject3D
		var shape := shape_node.shape
		var size := ""
		if shape is BoxShape3D:
			size = str((shape as BoxShape3D).size.snapped(Vector3.ONE * 0.0001))
		elif shape is CapsuleShape3D:
			size = "%.4f %.4f" % [(shape as CapsuleShape3D).radius, (shape as CapsuleShape3D).height]
		elif shape is CylinderShape3D:
			size = "%.4f %.4f" % [(shape as CylinderShape3D).radius, (shape as CylinderShape3D).height]
		var xform: Transform3D = to_root * shape_node.global_transform
		rows.append("%s|%s|%s|%s|%s|%s|%d|%d" % [root.get_path_to(shape_node), shape.get_class() if shape else "-", size,
			str(xform.origin.snapped(Vector3.ONE * 0.0001)), str(xform.basis.get_euler().snapped(Vector3.ONE * 0.001)),
			shape_node.disabled, body.collision_layer if body else -1, body.collision_mask if body else -1])
	rows.sort()
	return "\n".join(rows)


func test_washroom_colliders_and_nodes_are_main_s() -> void:
	var floor4 := _spawn()
	await wait_frames(3)
	var washroom := floor4.get_node("Washroom") as Node3D
	var print_now := collider_print(washroom)
	print("T256_WASHROOM_PRINT ", print_now.md5_text())
	assert_eq(print_now.md5_text(), WASHROOM_PRINT, "washroom colliders as main has them")
	var ps1 := _spawn(false)
	await wait_frames(2)
	assert_eq(collider_print(ps1.get_node("Washroom")), print_now, "the real washroom adds no collider")
	for path: String in KEPT_WASHROOM:
		assert_not_null(washroom.get_node_or_null(path), "kept " + path)
	var anchors := {"WashroomTapRunning": Vector3(0.24, 1.0, -2.85), "WashroomMirror": Vector3(0.15, 1.62, -1.85),
		"WashroomNotice": Vector3(0.15, 1.55, -3.25)}
	for name: String in anchors:
		assert_true((floor4.get_node("Anchors/" + name) as Node3D).position.is_equal_approx(anchors[name]), name + " in place")
	assert_true((washroom.get_node("Mirror") as Node3D).position.is_equal_approx(Vector3(0.145, 1.62, -1.85)), "mirror in place")
	assert_true((washroom.get_node("TapWater") as Node3D).position.is_equal_approx(Vector3(0.282, 0.985, -2.85)), "water in place")
	var light := washroom.get_node("WashroomLight") as OmniLight3D
	assert_true(is_equal_approx(light.light_energy, 1.2) and is_equal_approx(light.omni_range, 5.0) and not light.shadow_enabled,
		"the washroom light as it was")


func test_washroom_real_over_hidden_ps1() -> void:
	var floor4 := _spawn()
	await wait_frames(3)
	var washroom := floor4.get_node("Washroom") as Node3D
	var real := washroom.get_node_or_null("Real") as Node3D
	assert_not_null(real, "the real washroom")
	for name: String in WASHROOM_MESHES:
		assert_not_null(real.find_child(name, true, false), "washroom part " + name)
	for path: String in ["Floor/Mesh", "WestWall/Mesh", "StallDoor_1/Model", "StallPartition_1/Mesh", "Sink_1/Model", "Tap_1",
			"WashroomLight/Fixture/Mesh", "Details", "Mirror/Frame"]:
		var node := washroom.get_node(path) as Node3D
		assert_false(node.visible, "PS1 hidden: " + path)
	# The whole washroom within budget (card 6.4: <= 30 000 triangles).
	var triangles := 0
	for mesh: MeshInstance3D in real.find_children("*", "MeshInstance3D", true, false):
		for surface in mesh.mesh.get_surface_count():
			var arrays := mesh.mesh.surface_get_arrays(surface)
			var indices: PackedInt32Array = arrays[Mesh.ARRAY_INDEX]
			triangles += (indices.size() if not indices.is_empty() else (arrays[Mesh.ARRAY_VERTEX] as PackedVector3Array).size()) / 3
	assert_true(triangles <= 30000, "washroom %d triangles" % triangles)
	# Off: the PS1 washroom as it was.
	var ps1 := _spawn(false)
	await wait_frames(2)
	assert_true(ps1.get_node_or_null("Washroom/Real") == null, "no real washroom when switched off")
	assert_true((ps1.get_node("Washroom/Floor/Mesh") as Node3D).visible, "PS1 floor shows when off")


func test_washroom_mirror_reflects_like_room_407() -> void:
	var floor4 := _spawn()
	await wait_frames(3)
	var mirror := floor4.get_node("Washroom/Mirror") as Node3D
	assert_eq(mirror.get("mirror_size"), Vector2(2.5, 0.95), "glass narrowed clear of the notice board")
	assert_true(bool(mirror.get("require_in_view")), "drawn only while in view")
	var surface := mirror.get_node("Surface") as MeshInstance3D
	assert_eq(((surface.material_override as ShaderMaterial).shader as Shader).resource_path, "res://rendering/mirror_surface_hd.gdshader",
		"room 407's HD surface")
	assert_eq((mirror.get_node("ReflectionViewport") as SubViewport).size, Vector2i(800, 304), "407's texels")
	var stain := floor4.get_node("Washroom/Real").find_child("MirrorStain", true, false) as MeshInstance3D
	assert_eq(stain.layers, 1 << 18, "the stain on the surface layer: the reflection does not see it")
	# A player (the body carrying the camera) is followed.
	var player := Node3D.new()
	var script := GDScript.new()
	script.source_code = "extends Node3D\nvar body := true\n"
	script.reload()
	player.set_script(script)
	var head := Node3D.new()
	head.name = "Head"
	player.add_child(head)
	var camera := Camera3D.new()
	head.add_child(camera)
	fixtures.append(player)
	tree.root.add_child(player)
	camera.make_current()
	player.global_position = floor4.to_global(Vector3(1.5, 0.0, -1.85))
	await wait_frames(3)
	assert_eq(mirror.get("follow"), player, "the mirror follows the player")
	for mesh: MeshInstance3D in mirror.get_node("ReflectionBody").find_children("*", "MeshInstance3D", true, false):
		assert_false(mesh.visible, "with the body, the PS1 stand-in hides")


func _walk(floor4: Node3D, body: CharacterBody3D, points: Array) -> String:
	for point: Vector3 in points:
		var goal := floor4.to_global(point + Vector3(0, HEIGHT / 2.0 + 0.02, 0))
		var frames := int(ceilf(body.global_position.distance_to(goal) / WALK_SPEED * 60.0)) + 40
		for frame in frames:
			var to := goal - body.global_position
			to.y = 0.0
			if to.length() < 0.06:
				break
			body.velocity = to.normalized() * minf(WALK_SPEED, to.length() * 60.0)
			body.move_and_slide()
			await tree.physics_frame
		var left := goal - body.global_position
		left.y = 0.0
		if left.length() > 0.12:
			return "stuck at %s on the way to %s" % [floor4.to_local(body.global_position), point]
	return ""


func _capsule() -> CharacterBody3D:
	var body := CharacterBody3D.new()
	body.collision_layer = 2
	body.collision_mask = 1
	var shape := CollisionShape3D.new()
	var capsule := CapsuleShape3D.new()
	capsule.radius = RADIUS
	capsule.height = HEIGHT
	shape.shape = capsule
	body.add_child(shape)
	fixtures.append(body)
	tree.root.add_child(body)
	return body


func test_a_body_walks_to_every_tap_and_stall() -> void:
	var floor4 := _spawn()
	await wait_frames(3)
	var body := _capsule()
	for goal: Vector3 in [Vector3(0.95, 0, -0.85), Vector3(0.95, 0, -1.85), Vector3(0.95, 0, -2.85), Vector3(1.0, 0, -3.15),
			Vector3(3.0, 0, -3.15), Vector3(5.0, 0, -3.15)]:
		body.global_position = floor4.to_global(Vector3(3.0, HEIGHT / 2.0 + 0.02, 1.5))
		await tree.physics_frame
		var stuck := await _walk(floor4, body, [Vector3(3.0, 0, 0.4), Vector3(3.0, 0, -1.0), goal])
		assert_eq(stuck, "", "to %s" % goal)
