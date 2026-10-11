extends SceneTree
## Offline imported-mesh measurements. Never adds assets to the running tree.


static func measure(model: Node3D) -> Dictionary:
	var data := {"triangles": 0, "surfaces": 0, "materials": {}, "textures": {},
		"nodes": {}, "points": PackedVector3Array(), "unavailable": [], "resource_paths": {}}
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
	data["coordinate_space"] = "selected_root_local"
	data["pose"] = "rest"
	data["visibility_policy"] = "include_hidden"
	data["root_placement"] = {"position_m": _vector(model.position),
		"rotation_degrees": _vector(model.rotation_degrees), "scale": _vector(model.scale)}
	data.unavailable.append_array(["animated_bounds", "gpu_texture_memory", "gameplay_collision_nav", "visual_approval"])
	return data


static func _vector(value: Vector3) -> Array:
	return [value.x, value.y, value.z]


static func _texture(value: Variant, data: Dictionary) -> void:
	if value is Texture2D:
		var texture := value as Texture2D
		var key := texture.resource_path
		if not key.is_empty():
			data.resource_paths[key.get_slice("::", 0)] = true
		if key.is_empty():
			key = "embedded:%s" % texture.get_instance_id()
		data.textures[key] = {"width": texture.get_width(), "height": texture.get_height()}


static func _visit(node: Node, model: Node3D, parent_transform: Transform3D, data: Dictionary) -> void:
	var transform := parent_transform
	if node is Node3D:
		# Placement belongs to the scene, not to the selected root's local bounds.
		if node != model:
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
						data.resource_paths[shader_material.shader.resource_path.get_slice("::", 0)] = true
						for uniform in shader_material.shader.get_shader_uniform_list():
							_texture(shader_material.get_shader_parameter(uniform.name), data)
				else:
					for property in material.get_property_list():
						_texture(material.get(property.name), data)
	for child in node.get_children():
		_visit(child, model, transform, data)


static func _hash_file(path: String, hashes: Dictionary, missing: Array) -> void:
	if not path.begins_with("res://") or ".." in path:
		missing.append("unsupported_dependency:" + path)
		return
	if not FileAccess.file_exists(path):
		missing.append("missing_dependency:" + path)
		return
	hashes["game/" + path.trim_prefix("res://")] = FileAccess.get_sha256(path)


static func _dependencies(path: String, hashes: Dictionary, missing: Array, visited: Dictionary) -> void:
	if path.is_empty() or visited.has(path):
		return
	visited[path] = true
	_hash_file(path, hashes, missing)
	if not path.begins_with("res://") or ".." in path or not FileAccess.file_exists(path):
		return
	if FileAccess.file_exists(path + ".import"):
		_hash_file(path + ".import", hashes, missing)
		var config := ConfigFile.new()
		if config.load(path + ".import") == OK:
			for destination: String in config.get_value("deps", "dest_files", []):
				_dependencies(destination, hashes, missing, visited)
			var importer: String = config.get_value("params", "import_script/path", "")
			if not importer.is_empty():
				_dependencies(importer, hashes, missing, visited)
		else:
			missing.append("unreadable_import:" + path)
	for dependency in ResourceLoader.get_dependencies(path):
		var dependency_path := dependency.get_slice("::", 2) if "::" in dependency else dependency
		_dependencies(dependency_path, hashes, missing, visited)
	# ResourceLoader omits GDScript extends/preload paths. Conservatively include
	# literal resource paths in source, including references in inactive branches.
	if path.get_extension() in ["gd", "gdshader", "gdshaderinc"]:
		var references := RegEx.new()
		references.compile("[\"'](res://[^\"'\\r\\n]+)[\"']")
		for reference in references.search_all(FileAccess.get_file_as_string(path)):
			_dependencies(reference.get_string(1), hashes, missing, visited)


static func report_for(model: Node3D, path: String) -> Dictionary:
	var report := measure(model)
	var hashes := {}
	var missing: Array = []
	var visited := {}
	_dependencies(path, hashes, missing, visited)
	for resource_path: String in report.resource_paths:
		_dependencies(resource_path, hashes, missing, visited)
	_hash_file("res://project.godot", hashes, missing)
	_hash_file("res://scripts/debug/graphics_asset_probe.gd", hashes, missing)
	report.erase("resource_paths")
	report["file"] = "game/" + path.trim_prefix("res://")
	report["sha256"] = FileAccess.get_sha256(path)
	report["engine"] = Engine.get_version_info().string
	report["dependency_hashes"] = hashes
	report["dependency_unavailable"] = missing
	report["method"] = "Godot imported Mesh.get_faces; selected root local; rest pose; includes hidden meshes"
	return report


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
		var report := report_for(model, path)
		reports.append(report)
		model.free()
	print("GRAPHICS_PROBE_JSON=" + JSON.stringify(reports))
	quit()
