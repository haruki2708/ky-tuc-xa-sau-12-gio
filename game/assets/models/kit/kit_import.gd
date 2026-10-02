@tool
extends EditorScenePostImport
## Bake PS1 surface materials (T-118) and simple world collision (T-121)
## into PackedScenes; no runtime script or plugin.

const SURFACE_SHADER := preload("res://rendering/ps1_surface.gdshader")
const CUTOUT_SHADER := preload("res://rendering/ps1_surface_cutout.gdshader")
const COLLIDERS: Array[String] = ["wall_straight", "wall_door", "door", "bunk_bed", "locker", "plastic_stool"]


func _post_import(scene: Node) -> Object:
	var model_name := get_source_file().get_file().get_basename()
	_convert_materials(scene)
	if model_name not in COLLIDERS:
		return scene
	var body := StaticBody3D.new()
	body.name = "WorldCollision"
	body.collision_layer = 1
	body.collision_mask = 0
	scene.add_child(body)
	body.owner = scene
	if model_name == "wall_door":
		_add_box(scene, body, "LeftPier", Vector3(-0.725, 1.05, 0), Vector3(0.55, 2.1, 0.2))
		_add_box(scene, body, "RightPier", Vector3(0.725, 1.05, 0), Vector3(0.55, 2.1, 0.2))
		_add_box(scene, body, "Lintel", Vector3(0, 2.55, 0), Vector3(2, 0.9, 0.2))
	else:
		var points := _points(scene)
		if points.is_empty():
			push_error("Kit collision requires mesh vertices: " + model_name)
			return scene
		if model_name == "plastic_stool":
			var shape := ConvexPolygonShape3D.new()
			shape.points = points
			var collision := CollisionShape3D.new()
			collision.name = "StoolHull"
			collision.shape = shape
			body.add_child(collision)
			collision.owner = scene
		else:
			var bounds := AABB(points[0], Vector3.ZERO)
			for point in points:
				bounds = bounds.expand(point)
			_add_box(scene, body, "Bounds", bounds.get_center(), bounds.size)
	return scene


func _add_box(scene: Node, body: StaticBody3D, shape_name: String, center: Vector3, size: Vector3) -> void:
	var shape := BoxShape3D.new()
	shape.size = size
	var collision := CollisionShape3D.new()
	collision.name = shape_name
	collision.position = center
	collision.shape = shape
	body.add_child(collision)
	collision.owner = scene


func _points(node: Node, parent_transform: Transform3D = Transform3D.IDENTITY) -> PackedVector3Array:
	var result := PackedVector3Array()
	var transform := parent_transform
	if node is Node3D:
		transform *= (node as Node3D).transform
	if node is MeshInstance3D:
		for point in (node as MeshInstance3D).mesh.get_faces():
			result.append(transform * point)
	for child in node.get_children():
		result.append_array(_points(child, transform))
	return result


## Replaces imported StandardMaterial3D surfaces with PS1 shader materials that
## keep the same texture, colour and roughness; alpha-scissor stays cutout.
func _convert_materials(node: Node) -> void:
	if node is MeshInstance3D:
		var mesh := (node as MeshInstance3D).mesh
		for surface in range(mesh.get_surface_count()):
			var source := mesh.surface_get_material(surface) as BaseMaterial3D
			if source == null:
				continue
			var cutout := source.transparency == BaseMaterial3D.TRANSPARENCY_ALPHA_SCISSOR
			var material := ShaderMaterial.new()
			material.resource_name = source.resource_name
			material.shader = CUTOUT_SHADER if cutout else SURFACE_SHADER
			material.set_shader_parameter("albedo_texture", source.albedo_texture)
			material.set_shader_parameter("albedo_color", source.albedo_color)
			material.set_shader_parameter("roughness", source.roughness)
			material.set_shader_parameter("metallic", source.metallic)
			mesh.surface_set_material(surface, material)
	for child in node.get_children():
		_convert_materials(child)
