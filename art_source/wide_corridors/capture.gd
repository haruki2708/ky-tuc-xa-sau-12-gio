extends SceneTree
## Identical cameras for before/after comparison; no changes to game state.


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var phase := "before"
	for argument in OS.get_cmdline_user_args():
		if argument.begins_with("--phase="):
			phase = argument.trim_prefix("--phase=")
	root.size = Vector2i(1280, 720)
	var scene := Node3D.new()
	root.add_child(scene)
	var floor4 := (load("res://scenes/levels/floor4/floor4.tscn") as PackedScene).instantiate() as Node3D
	scene.add_child(floor4)
	var campus := (load("res://scenes/levels/campus/campus.tscn") as PackedScene).instantiate() as Node3D
	scene.add_child(campus)
	campus.attach_floor4(floor4)
	var camera := Camera3D.new()
	camera.fov = 75
	camera.far = 200
	scene.add_child(camera)
	camera.make_current()
	var folder := ProjectSettings.globalize_path("res://../art_source/wide_corridors/previews")
	DirAccess.make_dir_recursive_absolute(folder)
	var views := {
		"floor4": [Vector3(33, 1.6, 1.9), Vector3(10, 1.2, 1.9)],
		"floor2": [Vector3(33, -5.0, 1.9), Vector3(10, -5.4, 1.9)],
		"building_b": [Vector3(53, 6, 16), Vector3(22, -3.5, 0)],
	}
	for label: String in views:
		camera.position = views[label][0]
		camera.look_at(views[label][1])
		for frame in 50:
			await process_frame
		await RenderingServer.frame_post_draw
		var result := root.get_texture().get_image().save_png(folder.path_join(label + "_" + phase + ".png"))
		print("T187_CAPTURE: ", label, " ", phase, " result=", result)
	var anchors := {}
	for level in [floor4, campus]:
		for marker: Marker3D in level.get_node("Anchors").find_children("*", "Marker3D", true, false):
			var point := marker.global_position
			anchors[String(level.name) + "/" + String(level.get_path_to(marker))] = [snappedf(point.x, .0001), snappedf(point.y, .0001), snappedf(point.z, .0001)]
	var file := FileAccess.open(folder.path_join("../anchors_" + phase + ".json"), FileAccess.WRITE)
	file.store_string(JSON.stringify(anchors, "\t") + "\n")
	file.close()
	scene.queue_free()
	for frame in 3:
		await process_frame
	quit()
