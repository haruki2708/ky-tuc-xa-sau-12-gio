extends SceneTree
## Real-renderer capture and wall-clock frame timing; never use --fixed-fps.

const VIEWS: Array[Dictionary] = [
	{"name": "corridor_west", "eye": Vector3(32, 1.6, 1.2), "target": Vector3(3, 1.6, 1.2)},
	{"name": "corridor_east", "eye": Vector3(32, 1.6, 1.2), "target": Vector3(42, 1.6, 1.2)},
	{"name": "room_407", "eye": Vector3(32, 1.6, -.8), "target": Vector3(32, 1.15, -3.7)},
	{"name": "washroom", "eye": Vector3(4.8, 1.6, -.55), "target": Vector3(.5, 1.3, -2.5)},
	{"name": "duty_desk", "eye": Vector3(37.5, 1.6, 2.0), "target": Vector3(40.1, 1.25, .3)},
]


func _initialize() -> void:
	call_deferred("_capture")


func _capture() -> void:
	root.content_scale_size = Vector2i(1280, 720)
	root.size = Vector2i(1280, 720)
	DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
	Engine.max_fps = 0
	var scene := (load("res://scenes/levels/floor4/floor4_playtest.tscn") as PackedScene).instantiate()
	root.add_child(scene)
	var player := scene.get_node("Player") as CharacterBody3D
	player.set_process_unhandled_input(false)
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	scene.get_node("Floor4/Door407").set_open(true)
	var camera := Camera3D.new()
	camera.fov = 75
	scene.add_child(camera)
	camera.make_current()
	var destination := ProjectSettings.globalize_path("res://../art_source/floor4/previews")
	DirAccess.make_dir_recursive_absolute(destination)
	var measurements: Array[Dictionary] = []
	for view in VIEWS:
		camera.global_position = view.eye
		camera.look_at(view.target)
		player.global_position = view.eye - Vector3(0, 1.57, 0)
		player.velocity = Vector3.ZERO
		player.rotation.y = camera.rotation.y
		(player.get_node("Head") as Node3D).rotation.x = camera.rotation.x
		for frame in range(90):
			await process_frame
		await RenderingServer.frame_post_draw
		var frame_times: Array[float] = []
		var start := Time.get_ticks_usec()
		var previous := start
		for frame in range(240):
			await process_frame
			await RenderingServer.frame_post_draw
			var now := Time.get_ticks_usec()
			frame_times.append(float(now - previous) / 1000.0)
			previous = now
		var elapsed := float(Time.get_ticks_usec() - start) / 1000000.0
		frame_times.sort()
		var entry := {"view": view.name, "frames": 240, "mean_fps": 240.0 / elapsed,
			"p95_frame_ms": frame_times[227], "max_frame_ms": frame_times[-1]}
		measurements.append(entry)
		var image := root.get_texture().get_image()
		if image.get_size() != Vector2i(1280, 720) or image.save_png(destination.path_join(view.name + ".png")) != OK:
			push_error("Floor capture failed: " + str(view.name))
			quit(1)
			return
		print("FLOOR4_VIEW: ", JSON.stringify(entry))
	var report := {"godot": Engine.get_version_info().string, "resolution": "1280x720",
		"renderer": ProjectSettings.get_setting("rendering/renderer/rendering_method"),
		"gpu": RenderingServer.get_video_adapter_name(), "cpu": OS.get_processor_name(),
		"vsync": false, "warmup_frames_per_view": 90,
		"scenario": "floor4_playtest; Player physics, HUD, audio zones active; stationary views; door open",
		"views": measurements}
	var file := FileAccess.open(destination.path_join("performance.json"), FileAccess.WRITE)
	file.store_string(JSON.stringify(report, "\t") + "\n")
	file.close()
	print("FLOOR4_CAPTURE_RESULT: PASS 5 views")
	scene.queue_free()
	await create_timer(0.5).timeout
	quit(0)
