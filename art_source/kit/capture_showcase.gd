extends SceneTree
## Run with a real renderer; headless cannot supply a rendered viewport image.


func _initialize() -> void:
	call_deferred("_capture")


func _capture() -> void:
	root.content_scale_size = Vector2i(1280, 720)
	root.size = Vector2i(1280, 720)
	var scene := load("res://scenes/levels/kit_showcase.tscn") as PackedScene
	root.add_child(scene.instantiate())
	for frame in range(8):
		await process_frame
	await RenderingServer.frame_post_draw
	var destination := ProjectSettings.globalize_path("res://../art_source/kit/previews/kit_showcase.png")
	var result := root.get_texture().get_image().save_png(destination)
	print("CAPTURE_RESULT: ", "PASS" if result == OK else "FAIL", " ", destination)
	quit(0 if result == OK else 1)
