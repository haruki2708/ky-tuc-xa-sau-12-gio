extends TestCase
## Validate imported assets, including export basis and animation pivots.

const KIT_NAMES: Array[String] = [
	"wall_straight", "wall_door", "door", "bunk_bed", "locker",
	"ceiling_fan", "plastic_stool",
	"mosquito_net_closed", "mosquito_net_open",
]


func _instance(name: String) -> Node3D:
	var scene := load("res://assets/models/kit/%s.glb" % name) as PackedScene
	assert_not_null(scene, name + " loads as PackedScene")
	return scene.instantiate() as Node3D if scene != null else null


func _vertices(node: Node, parent_transform: Transform3D = Transform3D.IDENTITY) -> PackedVector3Array:
	var points := PackedVector3Array()
	var transform := parent_transform
	if node is Node3D:
		transform = parent_transform * (node as Node3D).transform
	if node is MeshInstance3D:
		var mesh := (node as MeshInstance3D).mesh
		if mesh != null:
			for vertex in mesh.get_faces():
				points.append(transform * vertex)
	for child in node.get_children():
		points.append_array(_vertices(child, transform))
	return points


func _bounds(node: Node) -> AABB:
	var vertices := _vertices(node)
	assert_true(not vertices.is_empty(), "bounding box requires geometry")
	if vertices.is_empty():
		return AABB()
	var box := AABB(vertices[0], Vector3.ZERO)
	for vertex in vertices:
		box = box.expand(vertex)
	return box


func test_all_models_load_within_triangle_budgets() -> void:
	for name in KIT_NAMES:
		var model := _instance(name)
		if model == null:
			continue
		var faces := _vertices(model)
		assert_true(faces.size() >= 3, name + " contains a mesh")
		var is_small := name in ["ceiling_fan", "plastic_stool"] or name.begins_with("mosquito_net")
		var limit := 500 if is_small else 1500
		assert_true(faces.size() / 3 < limit, name + " triangle budget")
		var expected_bottom := 0.415 if name.begins_with("mosquito_net") else 0.0
		assert_true(absf(_bounds(model).position.y - expected_bottom) < 0.001,
			name + " root at bed foot reference for nets, at base for other props")
		model.free()


func test_required_dimensions_within_five_percent() -> void:
	var expected := {
		"wall_straight": Vector3(2.0, 3.0, 0.2),
		"wall_door": Vector3(2.0, 3.0, 0.2),
		"bunk_bed": Vector3(0.9, 1.7, 2.0),
		"plastic_stool": Vector3(0.36, 0.30, 0.36),
	}
	for name: String in expected:
		var model := _instance(name)
		if model == null:
			continue
		var measured := _bounds(model).size
		var target: Vector3 = expected[name]
		for axis in range(3):
			assert_true(absf(measured[axis] - target[axis]) <= target[axis] * 0.05,
				"%s axis %d expected %.3f m, got %.3f m" % [name, axis, target[axis], measured[axis]])
		model.free()


func test_doorway_clearance() -> void:
	var model := _instance("wall_door")
	if model == null:
		return
	var vertices := _vertices(model)
	for x in [-0.44, 0.0, 0.44]:
		for y in [0.01, 1.0, 2.09]:
			for i in range(0, vertices.size(), 3):
				var hit: Variant = Geometry3D.ray_intersects_triangle(
					Vector3(x, y, -1), Vector3.BACK, vertices[i], vertices[i + 1], vertices[i + 2])
				assert_true(hit == null, "0.9 x 2.1 m opening must remain empty")
	model.free()


func test_door_hinge_and_front_direction() -> void:
	var model := _instance("door")
	if model == null:
		return
	var box := _bounds(model)
	assert_true(absf(box.end.x) < 0.001, "hinge edge at local X = 0")
	assert_true(absf(box.position.x + 0.88) < 0.001, "leaf extends from hinge by 0.88 m")
	assert_true(box.position.z < -0.07 and box.end.z <= 0.021,
		"handle faces Godot -Z after basis conversion")
	model.rotation.y = PI / 2
	var turned := _bounds(model)
	assert_true(absf(turned.end.z - 0.88) < 0.001, "door rotates around hinge")
	model.free()


func test_fan_rotor_is_independent() -> void:
	var model := _instance("ceiling_fan")
	if model == null:
		return
	var rotor := model.find_child("fan_rotor", true, false) as Node3D
	assert_not_null(rotor, "fan_rotor child")
	if rotor != null:
		var before := _vertices(rotor)
		assert_true(before.size() >= 3, "rotor has its own mesh")
		assert_true(absf(rotor.position.x) < 0.001 and absf(rotor.position.z) < 0.001,
			"rotor pivot on vertical motor axis")
		var parent := rotor.get_parent() as Node3D
		var parent_before := parent.transform
		rotor.rotate_y(0.5)
		assert_true(_vertices(rotor) != before, "rotor geometry responds to rotation")
		assert_eq(parent.transform, parent_before, "motor parent remains stationary")
	model.free()


func test_materials_use_ps1_shader_with_small_nearest_textures() -> void:
	# T-118: kit_import.gd bakes PS1 shader materials (nearest albedo + vertex snap).
	for name in KIT_NAMES:
		var model := _instance(name)
		if model == null:
			continue
		for node in model.find_children("*", "MeshInstance3D", true, false):
			var instance := node as MeshInstance3D
			for surface in range(instance.mesh.get_surface_count()):
				var material := instance.get_active_material(surface) as ShaderMaterial
				assert_not_null(material, name + " PS1 shader material")
				if material == null:
					continue
				var shader_file := material.shader.resource_path.get_file()
				assert_true(shader_file in ["ps1_surface.gdshader", "ps1_surface_cutout.gdshader"],
					name + " uses a PS1 surface shader, got " + shader_file)
				var texture := material.get_shader_parameter("albedo_texture") as Texture2D
				assert_not_null(texture, name + " albedo texture")
				if texture != null:
					assert_true(texture.resource_path.begins_with("res://assets/textures/kit/"),
						name + " uses canonical external texture")
					assert_true(texture.get_width() >= 64 and texture.get_width() <= 256,
						name + " texture width 64..256")
					assert_true(texture.get_height() >= 64 and texture.get_height() <= 256,
						name + " texture height 64..256")
		model.free()
	var include := FileAccess.get_file_as_string("res://rendering/ps1_surface.gdshaderinc")
	assert_true(include.contains("albedo_texture : source_color, filter_nearest"), "albedo sampled nearest")


func test_kit_textures_are_lossless_without_mipmaps() -> void:
	# The editor must not turn them into VRAM-compressed, mipmapped textures.
	for file in DirAccess.get_files_at("res://assets/textures/kit"):
		if not file.ends_with(".png"):
			continue
		var import := ConfigFile.new()
		assert_eq(import.load("res://assets/textures/kit/%s.import" % file), OK, file + " import settings")
		assert_eq(import.get_value("params", "compress/mode"), 0, file + " lossless")
		assert_eq(import.get_value("params", "mipmaps/generate"), false, file + " no mipmaps")
		assert_eq(import.get_value("params", "detect_3d/compress_to"), 0, file + " editor 3D detection disabled")
		var image := (load("res://assets/textures/kit/" + file) as Texture2D).get_image()
		assert_false(image.is_compressed(), file + " imported uncompressed")
		assert_false(image.has_mipmaps(), file + " imported without mipmaps")


func test_showcase_has_seven_models_and_camera() -> void:
	var scene := load("res://scenes/levels/kit_showcase.tscn") as PackedScene
	assert_not_null(scene, "showcase loads")
	if scene == null:
		return
	var instance := scene.instantiate()
	tree.root.add_child(instance)
	await wait_frames(2)
	assert_eq(instance.get_node("Models").get_child_count(), 7, "seven displayed models")
	assert_true((instance.get_node("Camera3D") as Camera3D).current, "showcase camera active")
	var bed := instance.get_node("Models/BunkBed") as Node3D
	var lower := bed.get_node("LowerNet") as Node3D
	var upper := bed.get_node("UpperNet") as Node3D
	assert_true(absf(_bounds(lower).position.y - 0.415) < 0.001, "lower hem tucked into mat")
	assert_true(absf(_bounds(lower).end.y - 1.075) < 0.001, "lower roof under upper platform")
	assert_true(absf(_bounds(upper).position.y - 1.185) < 0.001, "upper hem tucked into mat")
	assert_true(absf(_bounds(upper).end.y - 1.67) < 0.001, "upper roof meets net frame")
	assert_not_null(bed.get_node_or_null("SleepingDummy"), "dummy behind closed net")
	instance.queue_free()
	await wait_frames(1)


func test_stool_splayed_base_and_carrying_hole() -> void:
	var model := _instance("plastic_stool")
	if model == null:
		return
	var points := _vertices(model)
	var base_half_width := 0.0
	var seat_half_width := 0.0
	for point in points:
		if point.y < 0.01:
			base_half_width = maxf(base_half_width, absf(point.x))
		if point.y > 0.29:
			seat_half_width = maxf(seat_half_width, absf(point.x))
	assert_true(base_half_width > seat_half_width * 1.2, "base visibly wider than seat")
	assert_true(absf(seat_half_width * 2 - 0.28) < 0.014, "seat width 0.28 m +/-5%")
	var center_hits := 0
	var seat_hits := 0
	for i in range(0, points.size(), 3):
		if Geometry3D.ray_intersects_triangle(Vector3(0, 1, 0), Vector3.DOWN,
			points[i], points[i + 1], points[i + 2]) != null:
			center_hits += 1
		if Geometry3D.ray_intersects_triangle(Vector3(0.08, 1, 0), Vector3.DOWN,
			points[i], points[i + 1], points[i + 2]) != null:
			seat_hits += 1
	assert_eq(center_hits, 0, "carry slot is a real through-hole")
	assert_true(seat_hits > 0, "seat beside slot is solid")
	model.free()


func test_nets_have_cutout_weave_and_no_collision() -> void:
	for name in ["mosquito_net_closed", "mosquito_net_open"]:
		var model := _instance(name)
		if model == null:
			continue
		var transparent_surfaces := 0
		for node in model.find_children("*", "MeshInstance3D", true, false):
			var mesh := node as MeshInstance3D
			for surface in range(mesh.mesh.get_surface_count()):
				var material := mesh.get_active_material(surface) as ShaderMaterial
				if material != null and material.resource_name == "net_weave":
					transparent_surfaces += 1
					# Cutout shader: alpha scissor 0.5 and cull_disabled (two-sided cloth).
					assert_eq(material.shader.resource_path.get_file(), "ps1_surface_cutout.gdshader",
						name + " alpha-scissor, two-sided shader")
		assert_true(transparent_surfaces > 0, name + " transparent weave exists")
		assert_true(model.find_children("*", "CollisionShape3D", true, false).is_empty(),
			name + " has no collision")
		model.free()
	var net_texture := load("res://assets/textures/kit/net_weave.png") as Texture2D
	var image := net_texture.get_image()
	if image.is_compressed():
		assert_eq(image.decompress(), OK, "decompress imported weave for alpha inspection")
	var holes := 0
	for y in range(image.get_height()):
		for x in range(image.get_width()):
			if image.get_pixel(x, y).a < 0.5:
				holes += 1
	var fraction := float(holes) / (image.get_width() * image.get_height())
	assert_true(fraction > 0.35 and fraction < 0.70, "weave contains visible threads and open holes")


func test_required_models_have_world_collision() -> void:
	for name in ["wall_straight", "wall_door", "door", "bunk_bed", "locker", "plastic_stool"]:
		var model := _instance(name)
		if model == null:
			continue
		var shapes := model.find_children("*", "CollisionShape3D", true, false)
		assert_true(not shapes.is_empty(), name + " collision shapes persist in imported scene")
		for node in shapes:
			var collision := node as CollisionShape3D
			assert_not_null(collision.shape, name + " nonempty collision resource")
			assert_false(collision.disabled, name + " collision enabled")
			assert_true(collision.shape is BoxShape3D or collision.shape is ConvexPolygonShape3D,
				name + " uses simple box or convex")
			var body := collision.get_parent() as StaticBody3D
			assert_not_null(body, name + " static body")
			if body != null:
				assert_eq(body.collision_layer, 1, name + " only world layer")
		model.free()


func test_capsule_passes_doorway_but_hits_piers_and_lintel() -> void:
	var model := _instance("wall_door")
	if model == null:
		return
	model.position = Vector3(20, 100, 0)
	model.rotation.y = 0.4
	tree.root.add_child(model)
	await tree.physics_frame
	await tree.physics_frame
	var capsule := CapsuleShape3D.new()
	capsule.radius = 0.3
	capsule.height = 1.75
	var query := PhysicsShapeQueryParameters3D.new()
	query.shape = capsule
	query.collision_mask = 1
	query.margin = 0.001
	var space := model.get_world_3d().direct_space_state
	for direction in [-1.0, 1.0]:
		for x in [-0.14, 0.0, 0.14]:
			query.transform = model.global_transform * Transform3D(Basis.IDENTITY, Vector3(x, 0.885, -2 * direction))
			query.motion = model.global_basis * Vector3(0, 0, 4 * direction)
			var motion := space.cast_motion(query)
			assert_true(motion[0] >= 0.999, "player capsule crosses doorway in both directions")
	for center in [Vector3(-0.725, 0.885, -2), Vector3(0.725, 0.885, -2), Vector3(0, 2.4, -2)]:
		query.transform = model.global_transform * Transform3D(Basis.IDENTITY, center)
		query.motion = model.global_basis * Vector3(0, 0, 4)
		assert_true(space.cast_motion(query)[0] < 0.9, "solid pier/lintel blocks capsule")
	model.queue_free()
	await wait_frames(1)


func test_no_extracted_duplicate_textures() -> void:
	for file in DirAccess.get_files_at("res://assets/models/kit"):
		assert_false(file.ends_with(".png") or file.ends_with(".png.import"),
			"model directory must not contain extracted texture copies: " + file)
