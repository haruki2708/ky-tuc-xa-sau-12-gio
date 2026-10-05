extends SceneTree
## Run with the installed Godot GUI renderer; output stays inside this repo.
var scene: Node3D
var campus: Node3D
var camera: Camera3D


func _initialize() -> void:
	call_deferred("_run")


func triangles(node: Node) -> int:
	var total := 0
	if node is MeshInstance3D and node.mesh:
		total += node.mesh.get_faces().size() / 3
	elif node is MultiMeshInstance3D and node.multimesh and node.multimesh.mesh:
		total += node.multimesh.mesh.get_faces().size() / 3 * node.multimesh.instance_count
	for child in node.get_children():
		total += triangles(child)
	return total


func _run() -> void:
	root.size = Vector2i(1280, 720)
	scene = Node3D.new()
	root.add_child(scene)
	var floor4 := (load("res://scenes/levels/floor4/floor4.tscn") as PackedScene).instantiate()
	scene.add_child(floor4)
	campus = (load("res://scenes/levels/campus/campus.tscn") as PackedScene).instantiate()
	scene.add_child(campus)
	campus.attach_floor4(floor4)
	camera = Camera3D.new()
	camera.far = 650
	camera.fov = 75
	scene.add_child(camera)
	camera.make_current()
	var output := ProjectSettings.globalize_path("res://../art_source/campus/previews")
	DirAccess.make_dir_recursive_absolute(output)
	var stats := {"engine": Engine.get_version_info().string, "gpu": RenderingServer.get_video_adapter_name(), "resolution": "1280x720", "zone_triangles": {}, "actors": {}, "views": {}}
	for zone in ["BuildingB", "Shells", "Garden", "Stadium", "Gate", "Canteen", "Road", "Ground", "Fence"]:
		stats.zone_triangles[zone] = triangles(campus.get_node(zone))
	stats.zone_triangles["ExistingFloor4"] = triangles(floor4)
	var actor_stage := Node3D.new()
	scene.add_child(actor_stage)
	var actor_names: Array[String] = ["nhat", "ngu", "guard"]
	for i in 10:
		actor_names.append("zombie_%02d" % (i + 1))
	for i in actor_names.size():
		var actor := (load("res://assets/models/campus/%s.tscn" % actor_names[i]) as PackedScene).instantiate() as Node3D
		actor_stage.add_child(actor)
		actor.position = Vector3(180 + (i % 7) * 1.25, -9.9, -32 + (i / 7) * 2.4)
		actor.rotation.y = PI
		actor.set_pose([&"idle", &"walk", &"stunned", &"grab", &"sit", &"lie", &"wake"][i % 7])
		actor._process(.8)
		actor.set_process(false)
		stats.actors[actor_names[i]] = triangles(actor)
	var views := {
		"01_building_b": [Vector3(53, 6, 16), Vector3(22, -3.5, 0)],
		"02_stairs": [Vector3(-1.2, 1.6, 1.6), Vector3(-3.8, -2.2, -4.8)],
		"03_manager_window": [Vector3(2.8, -8.3, -2), Vector3(4, -8.3, -7.6)],
		"04_garden": [Vector3(44, 1.5, 3.8), Vector3(22, -9.2, 28)],
		"05_stadium": [Vector3(102, 29, 112), Vector3(198, -9.9, 166)],
		"06_bleachers": [Vector3(151, -4, 209), Vector3(197, -8, 225)],
		"07_road": [Vector3(53, -6.8, -18), Vector3(130, -8.5, -15)],
		"08_gate": [Vector3(220, -4, -21), Vector3(220, -6.4, -58)],
		"09_canteen": [Vector3(190, -7.5, 21), Vector3(190, -8.5, 43)],
		"10_kitchen": [Vector3(193, -8.1, 45), Vector3(192, -8.1, 51.9)],
		"11_shells": [Vector3(110, 25, 145), Vector3(0, -3, 183)],
		"12_actors": [Vector3(184, -6.8, -23), Vector3(184, -8.8, -31)],
	}
	for label: String in views:
		campus.set_stadium_lights(label in ["05_stadium", "06_bleachers"])
		camera.position = views[label][0]
		camera.look_at(views[label][1])
		for frame in 90:
			await process_frame
		var timings: Array[float] = []
		for frame in 120:
			var begin := Time.get_ticks_usec()
			await process_frame
			timings.append((Time.get_ticks_usec() - begin) / 1000.0)
		var average := 0.0
		for value in timings:
			average += value / timings.size()
		timings.sort()
		await RenderingServer.frame_post_draw
		var error := root.get_texture().get_image().save_png(output.path_join(label + ".png"))
		stats.views[label] = {"save_error": error, "draw_calls": Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME), "rendered_primitives": Performance.get_monitor(Performance.RENDER_TOTAL_PRIMITIVES_IN_FRAME), "mean_frame_ms": average, "p95_frame_ms": timings[113], "sample_frames": 120, "stadium_lights_on": label in ["05_stadium", "06_bleachers"]}
		print("CAPTURE: ", label, " error=", error)
	var file := FileAccess.open(output.path_join("../metrics.json"), FileAccess.WRITE)
	file.store_string(JSON.stringify(stats, "\t") + "\n")
	file.close()
	scene.queue_free()
	for i in 3:
		await process_frame
	quit()
