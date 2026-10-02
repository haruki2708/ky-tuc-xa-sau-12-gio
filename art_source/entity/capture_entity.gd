extends SceneTree
## Actual Forward+ viewport capture, real elapsed time, no --fixed-fps.

var scene: Node3D
var destination: String
var measurements: Array[Dictionary] = []


func _initialize() -> void:
	call_deferred("_capture")


func _capture() -> void:
	root.content_scale_size = Vector2i(1280, 720)
	root.size = Vector2i(1280, 720)
	DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
	Engine.max_fps = 0
	scene = (load("res://scenes/levels/entity/mirror_test.tscn") as PackedScene).instantiate()
	root.add_child(scene)
	scene.player.set_process_unhandled_input(false)
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	destination = ProjectSettings.globalize_path("res://../art_source/entity/previews")
	DirAccess.make_dir_recursive_absolute(destination)
	await _view("mirror_normal")
	# Preserve a side-facing torso, then turn the real player to the glass.
	scene.player.rotation.y = 0.0
	await process_frame
	await process_frame
	scene.mirror.set_lag(0.5)
	scene.mirror.stare()
	scene.player.rotation.y = PI / 2.0
	await create_timer(0.7).timeout
	await _view("mirror_stare")
	scene.show_corridor()
	await _view("silhouette_corridor")
	var report := {"godot": Engine.get_version_info().string, "resolution": "1280x720",
		"mirror_resolution": "560x190", "renderer": "Forward+ Vulkan",
		"cpu": OS.get_processor_name(), "gpu": RenderingServer.get_video_adapter_name(),
		"warmup_frames": 90, "vsync": false, "fixed_fps": false,
		"scenario": "Full floor4 playtest, Player physics/HUD/audio and PS1 strength=1; stationary views",
		"views": measurements}
	var file := FileAccess.open(destination.path_join("performance.json"), FileAccess.WRITE)
	file.store_string(JSON.stringify(report, "\t") + "\n")
	file.close()
	print("ENTITY_CAPTURE_RESULT: PASS 3 views")
	root.get_node("App").quit()


func _view(view_name: String) -> void:
	for frame in range(90):
		await process_frame
	await RenderingServer.frame_post_draw
	var times: Array[float] = []
	var start := Time.get_ticks_usec()
	var previous := start
	for frame in range(240):
		await process_frame
		await RenderingServer.frame_post_draw
		var now := Time.get_ticks_usec()
		times.append(float(now - previous) / 1000.0)
		previous = now
	var elapsed := float(Time.get_ticks_usec() - start) / 1000000.0
	times.sort()
	var entry := {"view": view_name, "frames": 240, "mean_fps": 240.0 / elapsed,
		"p95_frame_ms": times[227], "max_frame_ms": times[-1],
		"mirror_active": scene.mirror.rendering_active}
	measurements.append(entry)
	var picture := root.get_texture().get_image()
	if picture.save_png(destination.path_join(view_name + ".png")) != OK:
		push_error("Failed to save " + view_name)
		root.get_node("App").quit(1)
		return
	print("ENTITY_VIEW: ", JSON.stringify(entry))
