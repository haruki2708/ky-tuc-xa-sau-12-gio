extends SceneTree
## Offline imported-mesh measurements. Never adds assets to the running tree.


static func measure(model: Node3D) -> Dictionary:
	var data := {"triangles": 0, "surfaces": 0, "materials": {}, "textures": {},
		"nodes": {}, "points": PackedVector3Array(), "unavailable": []}
	_visit(model, model, Transform3D.IDENTITY, data)
	var points: PackedVector3Array = data.points
	if points.is_empty():
		data.unavailable.append("geometry_bounds")
	else:
		var bounds := AABB(points[0], Vector3.ZERO)
		for point in points:
			bounds = bounds.expand(point)
		data["bounds_min_m"] = _vector(bounds.position)
		data["dimensions_m"] = _vector(bounds.size)
	data.erase("points")
	data["material_count"] = data.materials.size()
	data["texture_count"] = data.textures.size()
	data.erase("materials")
	data["root_scale"] = _vector(model.scale)
	data.unavailable.append_array(["animated_bounds", "gpu_texture_memory", "gameplay_collision_nav", "visual_approval"])
	return data


static func _vector(value: Vector3) -> Array:
	return [value.x, value.y, value.z]


static func _texture(value: Variant, data: Dictionary) -> void:
	if value is Texture2D:
		var texture := value as Texture2D
		var key := texture.resource_path
		if key.is_empty():
			key = "embedded:%s" % texture.get_instance_id()
		data.textures[key] = {"width": texture.get_width(), "height": texture.get_height()}


static func _visit(node: Node, model: Node3D, parent_transform: Transform3D, data: Dictionary) -> void:
	var transform := parent_transform
	if node is Node3D:
		transform *= (node as Node3D).transform
		data.nodes[str(model.get_path_to(node))] = {
			"position_m": _vector(transform.origin), "scale": _vector((node as Node3D).scale)}
	if node is MeshInstance3D:
		var instance := node as MeshInstance3D
		if instance.skin != null:
			data.unavailable.append("skinned_pose:" + str(model.get_path_to(node)))
		if instance.mesh != null:
			var faces := instance.mesh.get_faces()
			data.triangles += faces.size() / 3
			for vertex in faces:
				data.points.append(transform * vertex)
			for surface in range(instance.mesh.get_surface_count()):
				data.surfaces += 1
				var material := instance.get_active_material(surface)
				if material == null:
					data.unavailable.append("material:" + str(model.get_path_to(node)))
					continue
				data.materials[str(material.get_instance_id())] = true
				if material is ShaderMaterial:
					var shader_material := material as ShaderMaterial
					if shader_material.shader != null:
						for uniform in shader_material.shader.get_shader_uniform_list():
							_texture(shader_material.get_shader_parameter(uniform.name), data)
				else:
					for property in material.get_property_list():
						_texture(material.get(property.name), data)
	for child in node.get_children():
		_visit(child, model, transform, data)


func _initialize() -> void:
	var paths := OS.get_cmdline_user_args()
	if paths.is_empty():
		print("Usage: --script res://scripts/debug/graphics_asset_probe.gd -- res://assets/models/kit/door.glb")
		quit(2)
		return
	var reports: Array = []
	for path in paths:
		if not path.begins_with("res://assets/models/") or not path.ends_with(".glb") or ".." in path:
			push_error("Probe accepts only trusted repository GLB assets")
			quit(2)
			return
		var scene := load(path) as PackedScene
		if scene == null:
			quit(1)
			return
		var model := scene.instantiate() as Node3D
		if model == null:
			quit(1)
			return
		var report := measure(model)
		report["file"] = "game/" + path.trim_prefix("res://")
		report["sha256"] = FileAccess.get_sha256(path)
		report["engine"] = Engine.get_version_info().string
		report["method"] = "Godot imported Mesh.get_faces; rest pose; root-local transforms"
		reports.append(report)
		model.free()
	print("GRAPHICS_PROBE_JSON=" + JSON.stringify(reports))
	quit()
