extends Node3D
## T-264 round 1, step 1: dumps what wave 7 touches, one row per node (path, type, visible, world position, rotation,
## mesh kind and size, world AABB, material, collider shape and layers, light, metas): the background buildings
## (Shells: BuildingA, Lecture, Gym, the LibraryBands left for wave 8), building B's whole tree (its outside is picked
## from it offline), and campus.tscn's Ground, Road, Fence, Zones, the road anchors (Paths, ZombieIdle/Road,
## ZombieSpawns/Road, Ch4, starts), Library (summary) and the occluders chapter 3 adds.
## Copy this file to game/_probe_tmp/ with a scene whose root has it, then (headless, short):
##   godot --headless --path game res://_probe_tmp/survey_wave7.tscn
## Writes art_source/graphics_upgrade/realistic_map/wave7/survey/*.tsv.
const OUTPUT := "res://../art_source/graphics_upgrade/realistic_map/wave7/survey/"


func _ready() -> void:
	call_deferred("_run")


func _v(v: Vector3) -> String:
	return "(%.3f, %.3f, %.3f)" % [v.x, v.y, v.z]


func _material(mesh_instance: MeshInstance3D) -> String:
	var mat: Material = mesh_instance.material_override
	if mat == null and mesh_instance.mesh != null and mesh_instance.mesh.get_surface_count() > 0:
		mat = mesh_instance.get_active_material(0)
	if mat is StandardMaterial3D:
		var std := mat as StandardMaterial3D
		var tex := std.albedo_texture.resource_path.get_file() if std.albedo_texture != null else "-"
		return "%s %s%s" % [tex, std.albedo_color.to_html(true), " emit" if std.emission_enabled else ""]
	if mat != null and mat.resource_path != "":
		return mat.resource_path.get_file()
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
	return "-" if mesh == null else "%s %d tris" % [mesh.get_class(), mesh.get_faces().size() / 3]


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
		if mi.visibility_range_end > 0.0:
			extra.append("range %.0f" % mi.visibility_range_end)
	if node is MultiMeshInstance3D:
		var mmi := node as MultiMeshInstance3D
		extra.append("multimesh %d x %s" % [mmi.multimesh.instance_count, _mesh(mmi.multimesh.mesh)])
		extra.append("aabb %s..%s" % [_v((mmi.global_transform * mmi.get_aabb()).position), _v((mmi.global_transform * mmi.get_aabb()).end)])
	if node is CollisionShape3D:
		var cs := node as CollisionShape3D
		var shape := cs.shape
		if shape is BoxShape3D:
			var size := (shape as BoxShape3D).size
			var box := cs.global_transform * AABB(-size / 2, size)
			extra.append("shape box %s aabb %s..%s" % [_v(size), _v(box.position), _v(box.end)])
		elif shape is CylinderShape3D:
			extra.append("shape cyl r%.3f h%.3f" % [(shape as CylinderShape3D).radius, (shape as CylinderShape3D).height])
		elif shape != null:
			extra.append("shape %s" % shape.get_class())
	if node is CollisionObject3D:
		extra.append("layer %d mask %d" % [(node as CollisionObject3D).collision_layer, (node as CollisionObject3D).collision_mask])
	if node is OmniLight3D or node is SpotLight3D:
		var light := node as Light3D
		extra.append("light e%.2f %s shadow %s" % [light.light_energy, light.light_color.to_html(false), light.shadow_enabled])
	if node is OccluderInstance3D:
		var occ := (node as OccluderInstance3D).occluder
		if occ is BoxOccluder3D:
			var size := (occ as BoxOccluder3D).size
			var box := (node as Node3D).global_transform * AABB(-size / 2, size)
			extra.append("occluder box %s aabb %s..%s" % [_v(size), _v(box.position), _v(box.end)])
	if node is NavigationRegion3D:
		var nav := (node as NavigationRegion3D).navigation_mesh
		if nav != null:
			extra.append("navmesh %d verts %d polys" % [nav.vertices.size(), nav.get_polygon_count()])
	if node.get_script() != null:
		extra.append("script %s" % (node.get_script() as Script).resource_path.get_file())
	if node.get("points") is PackedVector3Array:
		extra.append("points %d" % (node.get("points") as PackedVector3Array).size())
	if node.get("kind") is String:
		extra.append("kind %s" % node.get("kind"))
	for meta in node.get_meta_list():
		var value = node.get_meta(meta)
		extra.append("meta %s=%s" % [meta, str(value).left(80)])
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


func _run() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUTPUT))
	var campus := (load("res://scenes/levels/campus/campus.tscn") as PackedScene).instantiate() as Node3D
	add_child(campus)
	await get_tree().process_frame
	var all := func(_n: Node) -> bool: return true
	print("SURVEY shells rows %d" % _dump(campus.get_node("Shells"), "shells_nodes.tsv", all))
	print("SURVEY building_b rows %d" % _dump(campus.get_node("BuildingB"), "building_b_nodes.tsv", all))
	var rest := func(node: Node) -> bool:
		var path := String(campus.get_path_to(node))
		for head in ["Ground", "Road", "Fence", "Zones", "Anchors/Paths", "Anchors/ZombieIdle", "Anchors/ZombieSpawns", "Anchors/Ch4",
				"Anchors/Start", "Anchors/NguBench", "Anchors/BarSpawns", "Navigation/Outdoor", "Props/Lights", "Props/Solids"]:
			if path == head or path.begins_with(head + "/") or (head == "Anchors/Start" and path.begins_with(head)):
				return true
		return path == "Library" or path == "Props" or path.begins_with("Props/Trees")
	print("SURVEY campus rows %d" % _dump(campus, "campus_rest.tsv", rest))
	var library := campus.get_node("Library")
	print("SURVEY library rows %d" % _dump(library, "library_nodes.tsv", all))
	var occluders := (load("res://scenes/main/occlusion/occluders_campus.tscn") as PackedScene).instantiate()
	add_child(occluders)
	await get_tree().process_frame
	print("SURVEY occluders rows %d" % _dump(occluders, "occluders_campus.tsv", all))
	print("RESULT: survey_wave7 done")
	get_tree().quit()
