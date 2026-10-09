extends SceneTree
## Run before and after the scene edit, with identical cameras and lighting.


func _initialize() -> void:
	call_deferred("_capture")


func _capture() -> void:
	var phase := "after"
	for argument in OS.get_cmdline_user_args():
		if argument.begins_with("--phase="):
			phase = argument.trim_prefix("--phase=")
	if phase not in ["before", "after"]:
		quit(1)
		return
	var scene := Node3D.new()
	root.add_child(scene)
	var floor4 := load("res://scenes/levels/floor4/floor4.tscn").instantiate() as Node3D
	scene.add_child(floor4)
	var camera := Camera3D.new()
	camera.fov = 70
	scene.add_child(camera)
	camera.make_current()
	# App applies saved window settings at startup; fix the viewport afterwards.
	await process_frame
	root.size = Vector2i(1280, 720)
	root.content_scale_size = Vector2i(1280, 720)
	var folder := ProjectSettings.globalize_path("res://../art_source/sealed408/previews")
	DirAccess.make_dir_recursive_absolute(folder)
	for view: Dictionary in [
		{"name": "front", "eye": Vector3(36, 1.6, 2.6), "target": Vector3(36, 1.2, .1)},
		{"name": "oblique", "eye": Vector3(33.8, 1.6, 1.5), "target": Vector3(36, 1.15, .1)}]:
		camera.position = view.eye
		camera.look_at(view.target)
		for frame in 30:
			await process_frame
		await RenderingServer.frame_post_draw
		var result := root.get_texture().get_image().save_png(folder.path_join(view.name + "_" + phase + ".png"))
		if result != OK:
			push_error("Failed to save T-206 comparison image")
			root.get_node("App").quit(1)
			return
	print("RESULT: T206 capture %s 2 images PASS; renderer=%s; panel_z=%.3f" % [phase, RenderingServer.get_current_rendering_method(), floor4.get_node("Corridor/Sealed408").position.z])
	root.get_node("App").quit()
