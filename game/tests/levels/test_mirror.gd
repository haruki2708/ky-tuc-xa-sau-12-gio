extends TestCase

const WASHROOM := preload("res://scenes/levels/floor4/washroom.tscn")
const SILHOUETTE := preload("res://scenes/levels/entity/silhouette.tscn")
var room: Node3D
var player: Node3D
var camera: Camera3D
var mirror: Node3D


func before_each() -> void:
	room = WASHROOM.instantiate()
	tree.root.add_child(room)
	player = Node3D.new()
	room.add_child(player)
	player.position = Vector3(1.5, 0.03, -1.85)
	player.rotation.y = PI / 2.0
	camera = Camera3D.new()
	player.add_child(camera)
	camera.position.y = 1.6
	mirror = room.get_node("Mirror")
	mirror.follow = player
	mirror.set_process(false)
	mirror._process(0.01)


func after_each() -> void:
	room.queue_free()
	await wait_frames(2)
	await tree.create_timer(0.4).timeout


func test_lag_half_second_interpolates_position_and_rotation() -> void:
	mirror.set_lag(0.5)
	var initial := player.global_position
	for i in range(1, 101):
		player.position.z = initial.z + i * 0.01
		player.rotation.y = PI / 2.0 + i * 0.005
		mirror._process(0.01)
		if i == 25:
			assert_true(mirror.reflection_body.global_position.is_equal_approx(initial), "holds earliest sample before 0.5 s of history")
	assert_true(absf(mirror.reflection_body.global_position.z - (initial.z + 0.5)) < 0.011, "0.5 s delay at 1 m/s, tolerance one tick")
	assert_true(absf(mirror.reflection_body.global_rotation.y - (PI / 2.0 + 0.25)) < 0.011, "orientation delayed by the same interval")
	mirror.set_lag(0.0)
	mirror._process(0.01)
	assert_true(mirror.reflection_body.global_position.is_equal_approx(player.global_position), "zero lag follows immediately")


func test_stare_freezes_body_tracks_reflected_eye_then_release_follows() -> void:
	player.rotation.y = 0.0
	mirror._process(0.01)
	var frozen: Transform3D = mirror.reflection_body.global_transform
	mirror.stare()
	player.position.z += 0.4
	for i in range(80):
		mirror._process(0.01)
	assert_true(mirror.reflection_body.global_transform.is_equal_approx(frozen), "stare freezes torso")
	var head: Node3D = mirror.reflection_body.head
	var toward_eye: Vector3 = (mirror.reflection_camera.global_position - head.global_position).normalized()
	assert_true((-head.global_basis.z).dot(toward_eye) > 0.999, "head looks at virtual eye, through glass at player")
	mirror.release()
	mirror._process(0.01)
	assert_false(mirror.is_staring)
	assert_eq(mirror.lag_seconds, 0.0)
	assert_true(mirror.reflection_body.global_position.is_equal_approx(player.global_position), "release follows current player")
	assert_true(head.global_basis.is_equal_approx(camera.global_basis), "release restores camera orientation")


func test_render_layers_projection_and_room_gate() -> void:
	assert_true(mirror.rendering_active)
	assert_false(camera.get_cull_mask_value(20), "player camera excludes body")
	assert_true(mirror.reflection_camera.get_cull_mask_value(20), "mirror sees body")
	assert_false(mirror.reflection_camera.get_cull_mask_value(19), "no recursive glass rendering")
	for mesh: MeshInstance3D in mirror.reflection_body.find_children("*", "MeshInstance3D", true, false):
		assert_eq(mesh.layers, 1 << 19)
		assert_eq(mesh.cast_shadow, GeometryInstance3D.SHADOW_CASTING_SETTING_OFF)
	var eye: Vector3 = mirror.reflection_camera.global_position
	assert_true(absf(eye.x - (2.0 * mirror.global_position.x - camera.global_position.x)) < 0.001, "eye reflected across glass")
	assert_true(absf(eye.z - camera.global_position.z) < 0.001)
	# The full glass rectangle must map to the off-axis frustum corners.
	var top_left: Vector3 = mirror.to_global(Vector3(-1.4, 0.475, 0))
	var projected: Vector2 = mirror.reflection_camera.unproject_position(top_left)
	assert_true(projected.distance_to(Vector2(560, 0)) < 0.1, "right edge before horizontal mirror flip")
	player.position.z += 0.6
	camera.position.y += 0.2
	mirror._process(0.01)
	projected = mirror.reflection_camera.unproject_position(top_left)
	assert_true(projected.distance_to(Vector2(560, 0)) < 0.1, "off-center/raised eye still maps glass corner exactly")
	player.position = Vector3(3, 0.03, 1.2)
	mirror._process(0.01)
	assert_false(mirror.rendering_active, "outside washroom")
	assert_eq(mirror.viewport.render_target_update_mode, SubViewport.UPDATE_DISABLED)
	assert_false(mirror.reflection_body.visible)
	mirror.follow = null
	mirror._process(0.01)
	assert_true(camera.get_cull_mask_value(20), "source mask restored on unbind")


func test_live_process_delay_and_exit_reentry_reset() -> void:
	mirror.set_lag(0.5)
	mirror.set_process(true)
	var initial := player.position
	await tree.create_timer(0.1).timeout
	player.position.z += 0.5
	await tree.create_timer(0.2).timeout
	assert_true(mirror.reflection_body.global_position.is_equal_approx(initial), "actual process timeline still shows old pose at 0.2 s")
	await tree.create_timer(0.4).timeout
	assert_true(mirror.reflection_body.global_position.is_equal_approx(player.global_position), "actual process catches up after 0.6 s")
	player.position = Vector3(3, 0.03, 1.0)
	await wait_frames(2)
	assert_false(mirror.rendering_active)
	player.position = Vector3(2, 0.03, -1)
	await wait_frames(2)
	assert_true(mirror.reflection_body.global_position.is_equal_approx(player.global_position), "reentry cannot show stale pose from earlier visit")


func test_step_out_is_supported_clear_capsule_on_washroom_floor() -> void:
	await tree.physics_frame
	await tree.physics_frame
	var point: Vector3 = mirror.step_out()
	assert_true(point.is_equal_approx(Vector3(1.27, 0.03, -1.85)), "room-space exit clear of sinks")
	var shape := CapsuleShape3D.new()
	shape.radius = 0.3
	shape.height = 1.85
	var query := PhysicsShapeQueryParameters3D.new()
	query.shape = shape
	query.transform.origin = point + Vector3(0, 0.925, 0)
	query.collision_mask = 1
	var space := room.get_world_3d().direct_space_state
	assert_true(space.intersect_shape(query).is_empty(), "entity spawn clear of wall/sink")
	var ray := PhysicsRayQueryParameters3D.create(point + Vector3.UP, point + Vector3.DOWN, 1)
	var hit := space.intersect_ray(ray)
	assert_false(hit.is_empty(), "floor below exit")
	if not hit.is_empty():
		assert_eq(hit.collider.get_meta("surface", &""), &"tile")


func test_silhouette_budget_visibility_isolation_and_sway() -> void:
	var first: Node3D = SILHOUETTE.instantiate()
	var second: Node3D = SILHOUETTE.instantiate()
	room.add_child(first)
	room.add_child(second)
	var triangles := 0
	var bounds := AABB()
	for mesh: MeshInstance3D in first.find_children("*", "MeshInstance3D", true, false):
		bounds = bounds.merge(first.global_transform.affine_inverse() * mesh.global_transform * mesh.get_aabb())
		for surface in mesh.mesh.get_surface_count():
			var arrays := mesh.mesh.surface_get_arrays(surface)
			var indices: PackedInt32Array = arrays[Mesh.ARRAY_INDEX]
			triangles += (indices.size() if not indices.is_empty() else arrays[Mesh.ARRAY_VERTEX].size()) / 3
	assert_true(triangles > 0 and triangles < 800, "imported triangle count: %d" % triangles)
	assert_true(bounds.size.y > 1.78 and bounds.size.y < 1.94, "about 1.85 m tall: %s" % bounds)
	assert_true(absf(bounds.position.y) < 0.02, "origin at feet")
	first.set_visible_amount(0.35)
	assert_eq(first._material.get_shader_parameter("visible_amount"), 0.35)
	assert_eq(second.visible_amount, 1.0, "materials not shared across entities")
	first.set_visible_amount(-1.0)
	assert_false(first.visible)
	first.set_visible_amount(2.0)
	assert_true(first.visible)
	assert_eq(first.visible_amount, 1.0)
	first._process(0.7)
	assert_true(absf(first.get_node("Sway").rotation.z) > 0.001, "idle sway")
