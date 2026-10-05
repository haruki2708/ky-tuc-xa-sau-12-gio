extends SceneTree
## Rendered evidence, not a gameplay bot. Full floor + player/HUD/audio + PS1 filter.
var destination: String
var views: Array[Dictionary] = []


func _initialize() -> void:
	call_deferred("capture")


func save_frame(name: String) -> void:
	var error := root.get_texture().get_image().save_png(destination.path_join(name + ".png"))
	if error != OK:
		push_error("T172 capture failed: " + name)
		root.get_node("App").quit(1)


func capture() -> void:
	root.size = Vector2i(1280, 720)
	root.content_scale_size = root.size
	DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
	Engine.max_fps = 0
	destination = ProjectSettings.globalize_path("res://../art_source/ch2_props/previews")
	DirAccess.make_dir_recursive_absolute(destination)
	var scene := load("res://scenes/levels/room407/room407_test.tscn").instantiate() as Node3D
	root.add_child(scene)
	# Force reproducible video settings in memory; do not save user preferences.
	var filter := scene.get_node("PS1Filter")
	filter.get_node("Screen").material.set_shader_parameter("strength", 1.0)
	filter.get_node("Screen").material.set_shader_parameter("brightness", 1.0)
	RenderingServer.global_shader_parameter_set(&"ps1_strength", 1.0)
	var room := scene.get_node("Playtest/Floor4/Room407") as Node3D
	var player := scene.get_node("Playtest/Player") as CharacterBody3D
	player.global_position = Vector3(32, 0, -1)
	player.set_process_unhandled_input(false)
	var camera := Camera3D.new()
	camera.near = .012
	camera.fov = 70
	scene.add_child(camera)
	camera.make_current()
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	room.set_blood_stage(2)
	room.set_bathroom_door_open(true)
	for number in [1, 2, 4]:
		room.get_node("Anchors/Corpse%d/Body" % number).set_state(&"sit_play")
	var shots: Array = [
		["room_door", Vector3(2,1.6,-.7), Vector3(4,1,-3.5), 0.0],
		["room_center", Vector3(4,1.6,-5.5), Vector3(4,1.25,-1.8), 0.0],
		["bathroom_steam_0", Vector3(6.85,1.55,-4.45), Vector3(6.18,1.25,-6.65), 0.0],
		["bathroom_steam_1", Vector3(6.85,1.55,-4.45), Vector3(6.18,1.25,-6.65), 1.0],
		["stall_steam_0", Vector3(6.18,1.6,-6.15), Vector3(6.18,1.42,-6.8), 0.0],
		["stall_steam_1", Vector3(6.18,1.6,-6.15), Vector3(6.18,1.42,-6.8), 1.0],
		["balcony", Vector3(2.8,1.6,-7.1), Vector3(2.8,1.4,-8.12), 0.0],
		["rag_sink", Vector3(6.35,1.4,-4.6), Vector3(5.65,.88,-5), 0.0],
		["shirt_locker", Vector3(1.2,1.15,-1.35), Vector3(.3,.9,-1.25), 0.0]
	]
	room.get_node("Anchors/VietLocker").set_open(true)
	for entry: Array in shots:
		var name: String = entry[0]
		room.set_water(name.contains("steam"), 43 if entry[3] > 0 else 8)
		room.set_steam(entry[3])
		camera.global_position = room.to_global(entry[1])
		camera.look_at(room.to_global(entry[2]))
		for i in range(90):
			await process_frame
		await RenderingServer.frame_post_draw
		var times: Array[float] = []
		var start := Time.get_ticks_usec()
		var last := start
		for i in range(240):
			await process_frame
			await RenderingServer.frame_post_draw
			var now := Time.get_ticks_usec()
			times.append(float(now-last)/1000.0)
			last = now
		var fps := 240000000.0 / float(Time.get_ticks_usec()-start)
		times.sort()
		views.append({"view": name, "mean_fps": fps, "p95_ms": times[227], "steam": entry[3]})
		save_frame(name)
		print("T172_PREVIEW: ", name, " FPS ", fps)
	room.set_water(false, 0)
	room.set_steam(0.0)
	camera.global_position = room.to_global(Vector3(6.35,1.6,-5))
	camera.look_at(room.to_global(Vector3(5.42,1.55,-5)))
	for i in range(30):
		await process_frame
	await RenderingServer.frame_post_draw
	save_frame("mirror_before")
	await process_frame
	room.flash_reflection()
	await RenderingServer.frame_post_draw
	save_frame("mirror_flash")
	if room.get_node("Ch2Bathroom/Reflection").visible:
		push_error("Reflection did not clear after draw")
		root.get_node("App").quit(1)
		return
	await process_frame
	await RenderingServer.frame_post_draw
	save_frame("mirror_after")
	# A lit model lineup exposes every limb/state without bunk occlusion.
	var studio := Node3D.new()
	studio.position = Vector3(0, 40, 0)
	scene.add_child(studio)
	var lamp := OmniLight3D.new()
	lamp.position = Vector3(1.5, 2, -1.5)
	lamp.light_energy = 3.0
	lamp.omni_range = 8.0
	studio.add_child(lamp)
	var bodies: Array[Node3D] = []
	for i in range(3):
		var who: String = ["phuc", "viet", "dat"][i]
		var body := load("res://scenes/levels/ch1_models/corpse_%s.tscn" % who).instantiate() as Node3D
		body.position.x = i * 1.25
		body.rotation.y = PI / 2.0
		body.seat_side = 1.0
		studio.add_child(body)
		body.set_blood_visible(true)
		bodies.append(body)
	camera.global_position = studio.to_global(Vector3(1.25, 1.6, -3.7))
	camera.look_at(studio.to_global(Vector3(1.25, .4, -.5)))
	for state: StringName in bodies[0].STATES:
		for body in bodies:
			body.set_state(state)
			body.look_at_point(camera.global_position)
			body.set_process(false)
			body._process(.12 if state in [&"talk", &"mumble", &"revive"] else .7)
		for i in range(4):
			await process_frame
		await RenderingServer.frame_post_draw
		save_frame("corpses_" + String(state))
	var cctv := load("res://scenes/levels/cctv/cctv_set.tscn").instantiate() as Node3D
	scene.add_child(cctv)
	(cctv.get_node("Room310/Cam") as Camera3D).make_current()
	for i in range(30):
		await process_frame
	await RenderingServer.frame_post_draw
	save_frame("cctv_room310")
	var report := {"godot": Engine.get_version_info().string, "cpu": OS.get_processor_name(), "gpu": RenderingServer.get_video_adapter_name(), "resolution": "1280x720", "renderer": "Forward+", "vsync": false, "fixed_fps": false, "warmup_frames": 90, "sample_frames": 240, "scenario": "Full floor4, Player physics/HUD/audio active, PS1 strength 1, static preview camera", "views": views}
	var file := FileAccess.open(destination.path_join("performance.json"), FileAccess.WRITE)
	file.store_string(JSON.stringify(report, "\t") + "\n")
	file.close()
	print("RESULT: T172 capture PASS (21 previews, reflection cleared after one draw)")
	root.get_node("App").quit()
