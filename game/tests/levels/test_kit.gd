extends TestCase
## Validate imported assets, including export basis and animation pivots.

const KIT_NAMES: Array[String] = [
	"wall_straight", "wall_door", "door", "bunk_bed", "locker",
	"ceiling_fan", "plastic_stool",
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
		var limit := 500 if name in ["ceiling_fan", "plastic_stool"] else 1500
		assert_true(faces.size() / 3 < limit, name + " triangle budget")
		assert_true(absf(_bounds(model).position.y) < 0.001, name + " origin at base")
		model.free()


func test_required_dimensions_within_five_percent() -> void:
	var expected := {
		"wall_straight": Vector3(2.0, 3.0, 0.2),
		"wall_door": Vector3(2.0, 3.0, 0.2),
		"bunk_bed": Vector3(0.9, 1.7, 2.0),
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


func test_materials_use_small_nearest_textures() -> void:
	for name in KIT_NAMES:
		var model := _instance(name)
		if model == null:
			continue
		for node in model.find_children("*", "MeshInstance3D", true, false):
			var instance := node as MeshInstance3D
			for surface in range(instance.mesh.get_surface_count()):
				var material := instance.get_active_material(surface) as BaseMaterial3D
				assert_not_null(material, name + " material")
				if material == null:
					continue
				assert_eq(material.texture_filter, BaseMaterial3D.TEXTURE_FILTER_NEAREST,
					name + " nearest sampling")
				var texture := material.albedo_texture
				assert_not_null(texture, name + " albedo texture")
				if texture != null:
					assert_true(texture.get_width() >= 64 and texture.get_width() <= 256,
						name + " texture width 64..256")
					assert_true(texture.get_height() >= 64 and texture.get_height() <= 256,
						name + " texture height 64..256")
		model.free()


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
	instance.queue_free()
	await wait_frames(1)
