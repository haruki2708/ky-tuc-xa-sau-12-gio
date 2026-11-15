extends Node3D
## T-263 round 1, step 1: dumps every node of the canteen (canteen.tscn with its WestExit instance, as campus.tscn
## places it) and the campus anchors, zones and navigation around it, one row per node: path, type, visible, world
## position, mesh kind and size, world AABB, material (texture or colour), collider shape, light, label text, meta.
## Copy this file to game/_probe_tmp/ with a scene whose root has it, then (headless, short):
##   godot --headless --path game res://_probe_tmp/survey_canteen.tscn
## Writes art_source/graphics_upgrade/realistic_map/wave6/survey/canteen_nodes.tsv and campus_canteen.tsv.
const OUTPUT := "res://../art_source/graphics_upgrade/realistic_map/wave6/survey/"
## x 160..226, z 8..66: campus nodes printed (by mesh or box-collider AABB, else by position).
const BOX := AABB(Vector3(160, -12, 8), Vector3(66, 14, 58))


func _ready() -> void:
	call_deferred("_run")


func _v(v: Vector3) -> String:
	return "(%.3f, %.3f, %.3f)" % [v.x, v.y, v.z]


func _material(mesh_instance: MeshInstance3D) -> String:
	var mat: Material = mesh_instance.material_override
	if mat == null and mesh_instance.mesh != null:
		mat = mesh_instance.get_active_material(0)
	if mat is StandardMaterial3D:
		var std := mat as StandardMaterial3D
		var tex := std.albedo_texture.resource_path.get_file() if std.albedo_texture != null else "-"
		return "%s %s%s" % [tex, std.albedo_color.to_html(true), " emit" if std.emission_enabled else ""]
	return "-" if mat == null else mat.get_class()


func _mesh(mesh: Mesh) -> String:
	if mesh is BoxMesh:
		return "box %s" % _v((mesh as BoxMesh).size)
	if mesh is CylinderMesh:
		var c := mesh as CylinderMesh
		return "cyl r%.3f/%.3f h%.3f" % [c.top_radius, c.bottom_radius, c.height]
	if mesh is PlaneMesh:
		return "plane %s" % (mesh as PlaneMesh).size
	if mesh is QuadMesh:
		return "quad %s" % (mesh as QuadMesh).size
	if mesh is SphereMesh:
		return "sphere r%.3f" % (mesh as SphereMesh).radius
	return "-" if mesh == null else mesh.get_class()


func _row(root: Node, node: Node) -> String:
	var cells: PackedStringArray = [String(root.get_path_to(node)), node.get_class()]
	if node is Node3D:
		var n3 := node as Node3D
		cells.append("vis" if n3.is_visible_in_tree() else "HIDDEN")
		cells.append(_v(n3.global_position))
		cells.append(_v(n3.global_basis.get_euler() * 180.0 / PI))
	else:
		cells.append_array(["-", "-", "-"])
	var extra: PackedStringArray = []
	if node is MeshInstance3D:
		var mi := node as MeshInstance3D
		var aabb := mi.global_transform * mi.get_aabb()
		extra.append(_mesh(mi.mesh))
		extra.append("aabb %s..%s" % [_v(aabb.position), _v(aabb.end)])
		extra.append(_material(mi))
		extra.append("shadow %d" % mi.cast_shadow)
	if node is CollisionShape3D:
		var shape := (node as CollisionShape3D).shape
		if shape is BoxShape3D:
			extra.append("shape box %s" % _v((shape as BoxShape3D).size))
		elif shape != null:
			extra.append("shape %s" % shape.get_class())
	if node is CollisionObject3D:
		extra.append("layer %d mask %d" % [(node as CollisionObject3D).collision_layer, (node as CollisionObject3D).collision_mask])
	if node is OmniLight3D:
		var light := node as OmniLight3D
		extra.append("omni e%.2f r%.1f %s shadow %s" % [light.light_energy, light.omni_range, light.light_color.to_html(false), light.shadow_enabled])
	if node is Label3D:
		var label := node as Label3D
		extra.append("label '%s' size %d px %.4f %s" % [label.text, label.font_size, label.pixel_size, label.modulate.to_html(false)])
	if node is NavigationRegion3D:
		var nav := (node as NavigationRegion3D).navigation_mesh
		if nav != null:
			extra.append("navmesh %d verts %d polys" % [nav.vertices.size(), nav.get_polygon_count()])
	if node is NavigationLink3D:
		var link := node as NavigationLink3D
		extra.append("link %s -> %s bi %s" % [_v(link.global_transform * link.start_position), _v(link.global_transform * link.end_position), link.bidirectional])
	if node is Area3D:
		extra.append("area")
	for meta in node.get_meta_list():
		extra.append("meta %s=%s" % [meta, node.get_meta(meta)])
	cells.append(" | ".join(extra))
	return "\t".join(cells)


func _dump(root: Node, file: String, filter: Callable) -> int:
	var out := FileAccess.open(OUTPUT + file, FileAccess.WRITE)
	out.store_line("path\ttype\tvisible\tposition\trotation_deg\tdetail")
	var count := 0
	var stack: Array[Node] = [root]
	while not stack.is_empty():
		var node: Node = stack.pop_front()
		if filter.call(node):
			out.store_line(_row(root, node))
			count += 1
		var children := node.get_children()
		for i in range(children.size()):
			stack.insert(i, children[i])
	out.close()
	return count


func _near(node: Node) -> bool:
	if node is MeshInstance3D:
		var mi := node as MeshInstance3D
		return BOX.intersects(mi.global_transform * mi.get_aabb())
	if node is CollisionShape3D and (node as CollisionShape3D).shape is BoxShape3D:
		var shape := node as CollisionShape3D
		var size := (shape.shape as BoxShape3D).size
		return BOX.intersects(shape.global_transform * AABB(-size / 2, size))
	if node is Node3D:
		return BOX.has_point((node as Node3D).global_position)
	return false


func _run() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUTPUT))
	var campus := (load("res://scenes/levels/campus/campus.tscn") as PackedScene).instantiate() as Node3D
	add_child(campus)
	await get_tree().process_frame
	var canteen := campus.get_node("Canteen")
	print("SURVEY canteen rows %d" % _dump(canteen, "canteen_nodes.tsv", func(_n: Node) -> bool: return true))
	var wanted := func(node: Node) -> bool:
		if node == campus or canteen.is_ancestor_of(node) or node == canteen:
			return false
		var path := String(campus.get_path_to(node))
		if path.begins_with("Props"):
			return false
		return _near(node) or path.contains("Canteen") or path.contains("canteen") or path.contains("Start_split")
	print("SURVEY campus rows %d" % _dump(campus, "campus_canteen.tsv", wanted))
	print("RESULT: survey_canteen done")
	get_tree().quit()
