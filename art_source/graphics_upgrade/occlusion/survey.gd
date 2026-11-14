extends Node3D
## T-260 (HARU, probe, never committed): dump world-space geometry of a real chapter for placing occluders.
##   godot --headless --path game res://_probe_tmp/t260_survey.tscn -- --chapter=3
const OUT := "res://../build/haru/"


func _ready() -> void:
	call_deferred("_run")


func _arg(name: String, fallback: String) -> String:
	for argument: String in OS.get_cmdline_user_args():
		if argument.begins_with("--%s=" % name):
			return argument.trim_prefix("--%s=" % name)
	return fallback


func _v(v: Vector3) -> Array:
	return [snappedf(v.x, 0.001), snappedf(v.y, 0.001), snappedf(v.z, 0.001)]


func _run() -> void:
	var chapter := _arg("chapter", "3").to_int()
	Chapter1Director.resume_checkpoint = &""
	var scene := (load("res://scenes/main/chapter%d.tscn" % chapter) as PackedScene).instantiate() as Node3D
	var director := scene.get_node_or_null("Chapter%dDirector" % chapter)
	if director != null:
		director.set("auto_start", false)
	add_child(scene)
	for frame in range(5):
		await get_tree().process_frame
	var boxes := []
	for shape: CollisionShape3D in scene.find_children("*", "CollisionShape3D", true, false):
		var body := shape.get_parent() as CollisionObject3D
		if not (body is StaticBody3D) or shape.disabled or not (shape.shape is BoxShape3D):
			continue
		var t := shape.global_transform
		boxes.append({"path": str(scene.get_path_to(shape)), "layer": body.collision_layer, "origin": _v(t.origin),
			"size": _v((shape.shape as BoxShape3D).size * t.basis.get_scale()), "rot": _v(t.basis.get_euler() * 180.0 / PI)})
	var meshes := []
	for mi: MeshInstance3D in scene.find_children("*", "MeshInstance3D", true, false):
		if mi.mesh == null or not mi.is_visible_in_tree():
			continue
		var aabb := mi.global_transform * mi.get_aabb()
		var verts := 0
		if mi.mesh is ArrayMesh:
			for s in range(mi.mesh.get_surface_count()):
				verts += maxi((mi.mesh as ArrayMesh).surface_get_array_index_len(s), (mi.mesh as ArrayMesh).surface_get_array_len(s))
		else:
			verts = mi.mesh.get_faces().size()
		meshes.append({"path": str(scene.get_path_to(mi)), "pos": _v(aabb.position), "end": _v(aabb.end), "idx": verts,
			"rot": _v(mi.global_transform.basis.get_euler() * 180.0 / PI)})
	var multis := []
	for mm: MultiMeshInstance3D in scene.find_children("*", "MultiMeshInstance3D", true, false):
		if mm.multimesh == null:
			continue
		var aabb := mm.global_transform * mm.get_aabb()
		multis.append({"path": str(scene.get_path_to(mm)), "pos": _v(aabb.position), "end": _v(aabb.end), "count": mm.multimesh.instance_count})
	var markers := []
	for node: Node3D in scene.find_children("*", "Node3D", true, false):
		var n := String(node.name)
		if n.begins_with("seg") or n.begins_with("Start_") or n.contains("Door") or n.contains("Window") or n.contains("Railing") or n.contains("Balcony"):
			markers.append({"path": str(scene.get_path_to(node)), "class": node.get_class(), "origin": _v(node.global_position)})
	var file := FileAccess.open(OUT + "t260_survey_ch%d.json" % chapter, FileAccess.WRITE)
	file.store_string(JSON.stringify({"boxes": boxes, "meshes": meshes, "multis": multis, "markers": markers}))
	file.close()
	print("RESULT: t260 survey ch%d boxes %d meshes %d multis %d markers %d" % [chapter, boxes.size(), meshes.size(), multis.size(), markers.size()])
	App.quit()
