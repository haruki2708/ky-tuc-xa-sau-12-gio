extends Node
## Offline scene inspection: no gameplay node is added to the tree.

const OUTPUT := "res://../art_source/graphics_upgrade/measured_assets.json"
var textures: Dictionary = {}
var materials: Dictionary = {}
var triangles: int = 0
var meshes: int = 0
var bounds: AABB
var has_bounds: bool = false


func _ready() -> void:
	# Smoke tests instantiate every scene; measurement and exit are opt-in only.
	if "--pilot-measure" not in OS.get_cmdline_user_args():
		return
	var manifest: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://../art_source/graphics_upgrade/asset_manifest.json"))
	var rows: Array = []
	for entry: Dictionary in manifest.assets:
		if entry.get("measurement_node", "").is_empty():
			continue
		var packed: PackedScene = load(entry.current_scene)
		var root := packed.instantiate()
		var node := root.get_node(NodePath(entry.measurement_node)) as Node3D
		textures.clear()
		materials.clear()
		triangles = 0
		meshes = 0
		has_bounds = false
		_scan(node, Transform3D.IDENTITY)
		var world := node.transform
		var parent := node.get_parent()
		while parent is Node3D:
			world = parent.transform * world
			parent = parent.get_parent()
		rows.append({"id": entry.id, "scene": entry.current_scene, "node": entry.measurement_node,
			"position_in_scene_m": _vec(world.origin), "local_rotation_degrees": _vec(node.rotation_degrees),
			"local_scale": _vec(node.scale), "bounds_local_min_m": _vec(bounds.position) if has_bounds else null,
			"bounds_local_size_m": _vec(bounds.size) if has_bounds else null,
			"triangles": triangles, "mesh_instances": meshes, "unique_materials": materials.size(), "albedo_textures": textures.values()})
		root.free()
	var file := FileAccess.open(OUTPUT, FileAccess.WRITE)
	file.store_string(JSON.stringify({"method": "PackedScene instantiated off-tree; all descendant meshes including hidden variants; root-local AABB; no runtime-generated content", "assets": rows}, "\t") + "\n")
	print("RESULT: graphics inventory %d assets measured PASS" % rows.size())
	App.quit()


func _scan(node: Node, relative: Transform3D) -> void:
	if node is MeshInstance3D and node.mesh != null:
		meshes += 1
		var box: AABB = relative * node.get_aabb()
		bounds = bounds.merge(box) if has_bounds else box
		has_bounds = true
		for surface in range(node.mesh.get_surface_count()):
			var arrays: Array = node.mesh.surface_get_arrays(surface)
			var count: int = arrays[Mesh.ARRAY_INDEX].size() if arrays[Mesh.ARRAY_INDEX] != null else 0
			if count == 0:
				count = arrays[Mesh.ARRAY_VERTEX].size()
			triangles += count / 3
			var material: Material = node.get_active_material(surface)
			if material != null:
				materials[material.get_instance_id()] = true
				if material is ShaderMaterial:
					_track_texture(material.get_shader_parameter("albedo_texture"))
				elif material is BaseMaterial3D:
					_track_texture(material.albedo_texture)
	for child in node.get_children():
		_scan(child, relative * child.transform if child is Node3D else relative)


func _track_texture(value: Variant) -> void:
	if value is Texture2D:
		textures[value.resource_path] = {"path": value.resource_path, "width": value.get_width(), "height": value.get_height()}


func _vec(value: Vector3) -> Array:
	return [snappedf(value.x, 0.00001), snappedf(value.y, 0.00001), snappedf(value.z, 0.00001)]
