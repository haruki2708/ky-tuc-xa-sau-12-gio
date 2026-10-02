extends SceneTree
## Run with a real renderer; headless cannot supply a rendered viewport image.


func _initialize() -> void:
	call_deferred("_capture")


func _capture() -> void:
	root.content_scale_size = Vector2i(1280, 720)
	root.size = Vector2i(1280, 720)
	var scene := load("res://scenes/levels/kit_showcase.tscn") as PackedScene
	var showcase := scene.instantiate()
	root.add_child(showcase)
	for frame in range(8):
		await process_frame
	await RenderingServer.frame_post_draw
	var destination := ProjectSettings.globalize_path("res://../art_source/kit/previews/kit_showcase_overview.png")
	var result := root.get_texture().get_image().save_png(destination)
	print("CAPTURE_RESULT: ", "PASS" if result == OK else "FAIL", " ", destination)
	if result != OK:
		quit(1)
		return
	var bed := showcase.get_node("Models/BunkBed") as Node3D
	var camera := Camera3D.new()
	showcase.add_child(camera)
	camera.global_position = bed.to_global(Vector3(-2.8, 1.7, -3.2))
	camera.look_at(bed.to_global(Vector3(0, 0.95, 0)))
	camera.fov = 38
	camera.make_current()
	for frame in range(8):
		await process_frame
	await RenderingServer.frame_post_draw
	destination = ProjectSettings.globalize_path("res://../art_source/kit/previews/kit_showcase.png")
	result = root.get_texture().get_image().save_png(destination)
	print("CAPTURE_DETAIL_RESULT: ", "PASS" if result == OK else "FAIL", " ", destination)
	quit(0 if result == OK else 1)
