extends SceneTree


func _initialize() -> void:
	call_deferred("capture")


func capture() -> void:
	root.size = Vector2i(1280,720)
	root.content_scale_size = root.size
	DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
	Engine.max_fps = 0
	var scene := load("res://scenes/levels/room407/room407_test.tscn").instantiate() as Node3D
	root.add_child(scene)
	var player := scene.get_node("Playtest/Player") as CharacterBody3D
	player.set_process_unhandled_input(false)
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	var camera := player.get_node("Head/Camera3D") as Camera3D
	var room := scene.get_node("Playtest/Floor4/Room407") as Node3D
	var destination := ProjectSettings.globalize_path("res://../art_source/room407/previews")
	DirAccess.make_dir_recursive_absolute(destination)
	var measurements: Array[Dictionary] = []
	for entry: Dictionary in [
		{"name":"room_clean", "blood":0,"slash":0.0,"eye":Vector3(32,1.60,-.80),"target":Vector3(32,1.15,-3.4)},
		{"name":"room_blood", "blood":2,"slash":0.0,"eye":Vector3(32,1.60,-.80),"target":Vector3(32,1.15,-3.4)},
		{"name":"bed_slashed", "blood":2,"slash":1.0,"eye":Vector3(32,1.60,-2.0),"target":Vector3(33.35,.50,-3.1)},
		{"name":"desk_details", "blood":0,"slash":0.0,"eye":Vector3(32,1.60,-3.4),"target":Vector3(31.8,.8,-4.55)},
		{"name":"personal_items", "blood":0,"slash":0.0,"eye":Vector3(32,1.55,-.9),"target":Vector3(30.3,1.5,-1.85)}]:
		room.set_blood_stage(entry.blood)
		room.set_slashed(entry.slash)
		player.global_position = entry.eye - Vector3(0,1.60,0)
		player.velocity = Vector3.ZERO
		camera.look_at(entry.target)
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
		var measured := {"view":entry.name,"mean_fps":240.0/elapsed,"p95_frame_ms":times[227],"max_frame_ms":times[-1]}
		measurements.append(measured)
		var picture := root.get_texture().get_image()
		if picture.save_png(destination.path_join(entry.name + ".png")) != OK:
			push_error("Cannot save room capture")
			root.get_node("App").quit(1)
			return
		print("ROOM407_VIEW: ", JSON.stringify(measured))
	var report := {"godot":Engine.get_version_info().string,"cpu":OS.get_processor_name(),"gpu":RenderingServer.get_video_adapter_name(),"resolution":"1280x720","renderer":"Forward+ Vulkan","warmup_frames":90,"sample_frames":240,"vsync":false,"fixed_fps":false,"ps1_strength":1,"scenario":"Full floor4, Player physics/HUD/audio; stationary views; room main energy=0, desk/window/slit lights on","views":measurements}
	var file := FileAccess.open(destination.path_join("performance.json"),FileAccess.WRITE)
	file.store_string(JSON.stringify(report,"\t") + "\n")
	file.close()
	print("ROOM407_CAPTURE_RESULT: PASS 5 views")
	root.get_node("App").quit()
