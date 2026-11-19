extends Node3D
## T-265 round 1, step 1: dumps what wave 8 touches from main's scenes, one row per node (path, type, visible, world
## position, rotation, mesh kind and size, world AABB, material, collider shape and layers, light, navigation, metas):
## the whole Library tree (library.tscn under campus.tscn), the Shells' LibraryBand*, and every other campus node that
## reaches into wave 8's box (x 39..91, z 189..231: the library and 6 m round it). Also writes plan_geometry.json for
## plan_wave8.py: the library's colliders (world boxes; the stairs' and rails' convex hulls as points), navigation
## polygons and links (the library's and the outdoor ones in the box), chapter 4's anchors, the lights, the use spots.
## Copy this file to game/_probe_tmp/ with a scene whose root has it, then (headless, short):
##   godot --headless --path game res://_probe_tmp/survey_wave8.tscn
## Writes art_source/graphics_upgrade/realistic_map/wave8/survey/*.tsv and plan_geometry.json.
const OUTPUT := "res://../art_source/graphics_upgrade/realistic_map/wave8/survey/"
const BOX := Rect2(39.0, 189.0, 52.0, 42.0)   # x 39..91, z 189..231

var campus: Node3D


func _ready() -> void:
	call_deferred("_run")


func _v(v: Vector3) -> String:
	return "(%.3f, %.3f, %.3f)" % [v.x, v.y, v.z]


func _a(v: Vector3) -> Array:
	return [snappedf(v.x, 0.0001), snappedf(v.y, 0.0001), snappedf(v.z, 0.0001)]


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


func _shape_box(cs: CollisionShape3D) -> AABB:
	var shape := cs.shape
	if shape is BoxShape3D:
		var size := (shape as BoxShape3D).size
		return cs.global_transform * AABB(-size / 2, size)
	if shape is ConvexPolygonShape3D:
		var pts := (shape as ConvexPolygonShape3D).points
		var box := AABB(cs.global_transform * pts[0], Vector3.ZERO)
		for p in pts:
			box = box.expand(cs.global_transform * p)
		return box
	return AABB(cs.global_position, Vector3.ZERO)


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
		var box := mmi.global_transform * mmi.get_aabb()
		extra.append("aabb %s..%s" % [_v(box.position), _v(box.end)])
	if node is CollisionShape3D:
		var cs := node as CollisionShape3D
		var box := _shape_box(cs)
		extra.append("shape %s aabb %s..%s%s" % [cs.shape.get_class() if cs.shape != null else "-", _v(box.position), _v(box.end),
			" DISABLED" if cs.disabled else ""])
		if cs.shape is BoxShape3D:
			extra.append("size %s" % _v((cs.shape as BoxShape3D).size))
	if node is CollisionObject3D:
		extra.append("layer %d mask %d" % [(node as CollisionObject3D).collision_layer, (node as CollisionObject3D).collision_mask])
	if node is Area3D:
		extra.append("area")
	if node is OmniLight3D:
		var light := node as OmniLight3D
		extra.append("omni e%.2f range %.1f %s shadow %s" % [light.light_energy, light.omni_range, light.light_color.to_html(false),
			light.shadow_enabled])
	if node is NavigationRegion3D:
		var nav := (node as NavigationRegion3D).navigation_mesh
		if nav != null:
			var pts: PackedStringArray = []
			for p in nav.vertices:
				pts.append("(%.2f, %.2f, %.2f)" % [(node as Node3D).to_global(p).x, (node as Node3D).to_global(p).y, (node as Node3D).to_global(p).z])
			extra.append("navmesh %d polys r%.2f: %s" % [nav.get_polygon_count(), nav.agent_radius, ", ".join(pts)])
	if node is NavigationLink3D:
		var link := node as NavigationLink3D
		extra.append("link %s -> %s%s" % [_v(link.to_global(link.start_position)), _v(link.to_global(link.end_position)),
			" bidirectional" if link.bidirectional else ""])
	if node.get_script() != null:
		extra.append("script %s" % (node.get_script() as Script).resource_path.get_file())
	if node.get("points") is PackedVector3Array:
		extra.append("points %d" % (node.get("points") as PackedVector3Array).size())
	if node.get("kind") is String:
		extra.append("kind %s" % node.get("kind"))
	if node.get("room") is StringName:
		extra.append("room %s" % node.get("room"))
	if node.scene_file_path != "":
		extra.append("scene %s" % node.scene_file_path.get_file())
	for meta in node.get_meta_list():
		var value = node.get_meta(meta)
		extra.append("meta %s=%s" % [meta, str(value).left(80)])
	cells.append(" | ".join(extra))
	return "\t".join(cells)


func _walk(root: Node, filter: Callable) -> Array[Node]:
	var out: Array[Node] = []
	var stack: Array[Node] = [root]
	while not stack.is_empty():
		var node: Node = stack.pop_front()
		if filter.call(node):
			out.append(node)
		var children := node.get_children()
		for i in range(children.size()):
			stack.insert(i, children[i])
	return out


func _dump(root: Node, file: String, filter: Callable) -> int:
	var out := FileAccess.open(OUTPUT + file, FileAccess.WRITE)
	out.store_line("path\ttype\tvisible\tposition\trotation_deg\tdetail")
	var nodes := _walk(root, filter)
	for node in nodes:
		out.store_line(_row(root, node))
	out.close()
	return nodes.size()


func _rect_of(node: Node) -> Rect2:
	## The node's world footprint (x, z), or an empty Rect2 where it has none.
	var box := AABB()
	var has := false
	if node is MeshInstance3D:
		box = (node as MeshInstance3D).global_transform * (node as MeshInstance3D).get_aabb()
		has = true
	elif node is MultiMeshInstance3D:
		box = (node as MultiMeshInstance3D).global_transform * (node as MultiMeshInstance3D).get_aabb()
		has = true
	elif node is CollisionShape3D and (node as CollisionShape3D).shape != null:
		box = _shape_box(node as CollisionShape3D)
		has = true
	elif node is NavigationRegion3D and (node as NavigationRegion3D).navigation_mesh != null:
		var verts := (node as NavigationRegion3D).navigation_mesh.vertices
		if verts.size() > 0:
			box = AABB((node as Node3D).to_global(verts[0]), Vector3.ZERO)
			for p in verts:
				box = box.expand((node as Node3D).to_global(p))
			has = true
	elif node is Node3D:
		box = AABB((node as Node3D).global_position, Vector3.ZERO)
		has = true
	if not has:
		return Rect2()
	return Rect2(box.position.x, box.position.z, maxf(box.size.x, 0.001), maxf(box.size.z, 0.001))


func _in_box(node: Node) -> bool:
	var path := String(campus.get_path_to(node))
	if path == "Library" or path.begins_with("Library/"):
		return false
	if not node is Node3D:
		return false
	var r := _rect_of(node)
	if r.size == Vector2.ZERO:
		return false
	# Whole-campus nodes (the ground's parents, the props' roots) are listed through their children only.
	if r.size.x > 400.0 or r.size.y > 300.0:
		return false
	return r.intersects(BOX, true)


func _geometry() -> Dictionary:
	var library := campus.get_node("Library") as Node3D
	var colliders: Array = []
	for cs: Node in library.find_children("*", "CollisionShape3D", true, false):
		var shape := cs as CollisionShape3D
		var body := shape.get_parent() as CollisionObject3D
		var entry := {"path": String(library.get_path_to(shape)), "layer": body.collision_layer if body != null else 0,
			"area": body is Area3D}
		if shape.shape is BoxShape3D:
			var size := (shape.shape as BoxShape3D).size
			var corners: Array = []
			for i in 8:
				var c := Vector3(size.x * (0.5 if i & 1 else -0.5), size.y * (0.5 if i & 2 else -0.5), size.z * (0.5 if i & 4 else -0.5))
				corners.append(_a(shape.global_transform * c))
			entry["kind"] = "box"
			entry["points"] = corners
		elif shape.shape is ConvexPolygonShape3D:
			var pts: Array = []
			for p in (shape.shape as ConvexPolygonShape3D).points:
				pts.append(_a(shape.global_transform * p))
			entry["kind"] = "convex"
			entry["points"] = pts
		colliders.append(entry)
	var navs: Array = []
	var nav_root: Array[Node] = []
	nav_root.append_array(library.find_children("*", "NavigationRegion3D", true, false))
	for node in _walk(campus, func(n: Node) -> bool: return n is NavigationRegion3D and _in_box(n)):
		nav_root.append(node)
	for node in nav_root:
		var region := node as NavigationRegion3D
		var mesh := region.navigation_mesh
		if mesh == null:
			continue
		var polys: Array = []
		for i in mesh.get_polygon_count():
			var poly: Array = []
			for idx in mesh.get_polygon(i):
				poly.append(_a(region.to_global(mesh.vertices[idx])))
			polys.append(poly)
		navs.append({"path": String(campus.get_path_to(region)), "polygons": polys, "radius": mesh.agent_radius})
	var links: Array = []
	for node in library.find_children("*", "NavigationLink3D", true, false):
		var link := node as NavigationLink3D
		links.append({"path": String(library.get_path_to(link)), "a": _a(link.to_global(link.start_position)),
			"b": _a(link.to_global(link.end_position))})
	for node in _walk(campus, func(n: Node) -> bool: return n is NavigationLink3D and _in_box(n)):
		var link := node as NavigationLink3D
		links.append({"path": String(campus.get_path_to(link)), "a": _a(link.to_global(link.start_position)),
			"b": _a(link.to_global(link.end_position))})
	var anchors := {}
	for node in campus.get_node("Anchors/Ch4").find_children("*", "Marker3D", true, false):
		var at := (node as Node3D).global_position
		if BOX.has_point(Vector2(at.x, at.z)):
			anchors[String(campus.get_node("Anchors/Ch4").get_path_to(node))] = _a(at)
	var lights := {}
	for node in library.find_children("*", "OmniLight3D", true, false):
		lights[String(library.get_path_to(node))] = _a((node as Node3D).global_position)
	var spots := {}
	for path in ["Counter/IronBar", "MapBoard", "LibrarianChair", "ReadingTable13", "BackDoor", "BackDoor/Hinge", "FrontDoor", "Barricade"]:
		spots[path] = _a((library.get_node(path) as Node3D).global_position)
	var meshes: Array = []
	for node in library.find_children("*", "MeshInstance3D", true, false):
		var mi := node as MeshInstance3D
		var box := mi.global_transform * mi.get_aabb()
		meshes.append({"path": String(library.get_path_to(mi)), "lo": _a(box.position), "hi": _a(box.end), "visible": mi.is_visible_in_tree()})
	return {"colliders": colliders, "navigation": navs, "links": links, "anchors": anchors, "lights": lights, "spots": spots,
		"meshes": meshes, "origin": _a(library.global_position)}


func _run() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUTPUT))
	campus = (load("res://scenes/levels/campus/campus.tscn") as PackedScene).instantiate() as Node3D
	add_child(campus)
	await get_tree().process_frame
	var all := func(_n: Node) -> bool: return true
	var library := campus.get_node("Library")
	print("SURVEY library rows %d" % _dump(library, "library_nodes.tsv", all))
	var bands := func(n: Node) -> bool: return String(n.name).begins_with("LibraryBand") or String(n.get_parent().name).begins_with("LibraryBand")
	print("SURVEY bands rows %d" % _dump(campus.get_node("Shells"), "library_bands.tsv", bands))
	print("SURVEY zone rows %d" % _dump(campus, "zone8_nodes.tsv", _in_box))
	var counts := {}
	for node in _walk(library, all):
		counts[node.get_class()] = int(counts.get(node.get_class(), 0)) + 1
	print("SURVEY library node classes %s" % JSON.stringify(counts))
	var out := FileAccess.open(OUTPUT + "plan_geometry.json", FileAccess.WRITE)
	out.store_string(JSON.stringify(_geometry(), "\t"))
	out.close()
	print("RESULT: survey_wave8 done")
	get_tree().quit()
