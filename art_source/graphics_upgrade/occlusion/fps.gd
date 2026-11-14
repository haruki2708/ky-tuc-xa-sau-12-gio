extends Node3D
## T-260 (HARU; from the integrator's T-255 FPS script; copied to game/_probe_tmp/t260_fps.gd with a t260_fps.tscn
## whose root Node3D carries it, never committed there): FPS with occlusion culling off and on, in the real chapter
## scenes (director held, lights as the chapter opens, HUD and player hidden, sound muted), 1920 x 1080, vsync off.
## Each view: 90 frames to settle, 240 measured, for each mode in --order (off,on or on,off). The T-255 views of
## floor 4 plus campus views in chapter 3. Also the objects, primitives and draw calls of the last frame.
##   godot --path game res://_probe_tmp/t260_fps.tscn -- --chapter=3 --order=off,on --out=<json>
const RESOLUTION := Vector2i(1920, 1080)
const WARMUP := 90
const SAMPLES := 240
const ALL_DOORS: Array[String] = ["401", "402", "403", "404", "405", "406", "408"]
## "open": room doors standing open; "both": also measured with the PS1 rooms.
const VIEWS := [
	{"id": "01_corridor_west_doors_shut", "eye": Vector3(1.0, 1.65, 2.0), "target": Vector3(43.0, 1.4, 2.0), "open": [], "both": true},
	{"id": "02_corridor_east_doors_shut", "eye": Vector3(43.0, 1.65, 2.0), "target": Vector3(1.0, 1.4, 2.0), "open": [], "both": true},
	{"id": "03_door_406_open_torch", "eye": Vector3(28.0, 1.65, 3.2), "target": Vector3(28.0, 1.2, -4.0), "open": ["406"], "torch": true, "both": true},
	{"id": "04_doors_405_406_open_torch", "eye": Vector3(26.0, 1.65, 3.5), "target": Vector3(26.0, 1.2, -3.0), "open": ["405", "406"], "torch": true, "both": true},
	{"id": "05_all_doors_open_west", "eye": Vector3(1.0, 1.65, 2.8), "target": Vector3(43.0, 1.3, 0.0), "open": ALL_DOORS, "both": true},
	{"id": "06_all_doors_open_east_torch", "eye": Vector3(43.0, 1.65, 2.8), "target": Vector3(1.0, 1.3, 0.0), "open": ALL_DOORS, "torch": true, "both": true},
	{"id": "07_inside_408_torch", "eye": Vector3(39.0, 1.65, -0.9), "target": Vector3(43.0, 1.1, -5.5), "open": ["408"], "torch": true},
	{"id": "08_inside_402_torch", "eye": Vector3(12.0, 1.65, -0.8), "target": Vector3(12.0, 1.1, -6.5), "open": ["402"], "torch": true},
	{"id": "09_inside_406_look_back_torch", "eye": Vector3(28.0, 1.65, -5.6), "target": Vector3(28.0, 1.2, 0.0), "open": ["406"], "torch": true},
	{"id": "10_balcony_404_along_torch", "eye": Vector3(20.0, 1.65, -7.8), "target": Vector3(40.0, 1.2, -7.8), "open": [], "torch": true},
	{"id": "11_room_407_to_door_torch", "eye": Vector3(34.0, 1.65, -5.0), "target": Vector3(32.0, 1.2, 0.0), "open": [], "torch": true, "both": true},
	{"id": "12_corridor_407_door_oblique", "eye": Vector3(36.0, 1.65, 3.5), "target": Vector3(31.0, 1.2, 0.0), "open": []},
	{"id": "c1_corridor_east_to_campus", "eye": Vector3(43.0, 1.65, 2.5), "target": Vector3(1.0, 1.0, 6.0), "open": [], "campus": true},
	{"id": "c2_floor4_down_to_garden", "eye": Vector3(22.0, 1.65, 3.5), "target": Vector3(22.0, -9.0, 25.0), "open": [], "campus": true},
	{"id": "c3_floor3_corridor", "eye": Vector3(40.0, -1.65, 2.0), "target": Vector3(20.0, -2.1, 1.0), "open": [], "campus": true, "torch": true},
	{"id": "c4_floor1_lobby", "eye": Vector3(10.0, -8.25, 2.2), "target": Vector3(30.0, -8.7, 1.4), "open": [], "campus": true, "torch": true},
	{"id": "c5_garden_up_to_b", "eye": Vector3(22.0, -8.3, 30.0), "target": Vector3(22.0, -2.0, 0.0), "open": [], "campus": true},
	{"id": "c6_garden_to_building_a", "eye": Vector3(22.0, -8.3, 20.0), "target": Vector3(22.0, -5.0, 60.0), "open": [], "campus": true},
	{"id": "c7_garden_west_oblique", "eye": Vector3(-8.0, -8.3, 25.0), "target": Vector3(30.0, -4.0, -2.0), "open": [], "campus": true},
]


func _ready() -> void:
	call_deferred("_run")


func _arg(name: String, fallback: String) -> String:
	for argument: String in OS.get_cmdline_user_args():
		if argument.begins_with("--%s=" % name):
			return argument.trim_prefix("--%s=" % name)
	return fallback


func _run() -> void:
	if DisplayServer.get_name() == "headless":
		push_error("FPS needs a window.")
		App.quit(1)
		return
	DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
	Engine.max_fps = 0
	get_window().mode = Window.MODE_WINDOWED
	get_window().content_scale_size = RESOLUTION
	get_window().size = RESOLUTION
	get_viewport().scaling_3d_scale = 1.0
	var chapter := _arg("chapter", "3").to_int()
	var order := _arg("order", "off,on").split(",")
	var out := _arg("out", "")
	AudioServer.set_bus_mute(0, true)
	Chapter1Director.resume_checkpoint = &""
	var scene := (load("res://scenes/main/chapter%d.tscn" % chapter) as PackedScene).instantiate() as Node3D
	scene.get_node("Chapter%dDirector" % chapter).set("auto_start", false)
	var floor4 := scene.get_node("Floor4") as Node3D
	add_child(scene)
	for frame in range(3):
		await get_tree().process_frame
	var player := scene.get_node("Player") as Node3D
	player.visible = false
	player.process_mode = Node.PROCESS_MODE_DISABLED
	for layer: CanvasLayer in scene.find_children("*", "CanvasLayer", false, false):
		layer.visible = layer.name == &"PS1Filter"
	var camera := Camera3D.new()
	add_child(camera)
	camera.make_current()
	var torch := SpotLight3D.new()
	torch.position = Vector3(0.1, -0.08, -0.15)
	torch.light_color = Color(0.9, 0.94, 1.0)
	torch.light_energy = 1.5
	torch.spot_range = 12.0
	torch.spot_angle = 28.0
	torch.shadow_enabled = true
	camera.add_child(torch)
	var results: Array[Dictionary] = []
	for view: Dictionary in VIEWS:
		if view.get("campus", false) and chapter < 3:
			continue
		for number: String in ALL_DOORS:
			var door := floor4.get_node("Corridor/LockedDoor_" + number) as RoomDoor
			door.set_open(number in view.open, 0.01)
		camera.position = view.eye
		camera.look_at(view.target)
		camera.fov = 75.0
		torch.visible = view.get("torch", false)
		for mode: String in order:
			get_tree().root.use_occlusion_culling = mode == "on"
			for frame in range(WARMUP):
				await get_tree().process_frame
			var times := PackedFloat64Array()
			var last := Time.get_ticks_usec()
			for frame in range(SAMPLES):
				await get_tree().process_frame
				var now := Time.get_ticks_usec()
				times.append(float(now - last) / 1000.0)
				last = now
			var total := 0.0
			for ms: float in times:
				total += ms
			var sorted := Array(times)
			sorted.sort()
			var worst: Array = sorted.slice(sorted.size() - maxi(1, SAMPLES / 100))
			var worst_total := 0.0
			for ms: float in worst:
				worst_total += ms
			var row := {
				"view": view.id, "chapter": chapter, "occlusion": mode,
				"mean_fps": snappedf(1000.0 * SAMPLES / total, 0.1),
				"mean_ms": snappedf(total / SAMPLES, 0.01),
				"low1_fps": snappedf(1000.0 / (worst_total / worst.size()), 0.1),
				"p95_ms": snappedf(float(sorted[int(SAMPLES * 0.95)]), 0.01),
				"max_ms": snappedf(float(sorted[-1]), 0.01),
				"objects": int(RenderingServer.get_rendering_info(RenderingServer.RENDERING_INFO_TOTAL_OBJECTS_IN_FRAME)),
				"primitives": int(RenderingServer.get_rendering_info(RenderingServer.RENDERING_INFO_TOTAL_PRIMITIVES_IN_FRAME)),
				"draw_calls": int(RenderingServer.get_rendering_info(RenderingServer.RENDERING_INFO_TOTAL_DRAW_CALLS_IN_FRAME)),
			}
			results.append(row)
			print("FPS ch%d %s %s: mean %.1f  1%%low %.1f  p95 %.2f ms  max %.2f ms  objects %d  prims %d  draws %d" % [
				chapter, mode, row.view, row.mean_fps, row.low1_fps, row.p95_ms, row.max_ms, row.objects,
				row.primitives, row.draw_calls])
	if not out.is_empty():
		var file := FileAccess.open(out, FileAccess.WRITE)
		file.store_string(JSON.stringify({"gpu": RenderingServer.get_video_adapter_name(),
			"window": [get_window().size.x, get_window().size.y], "results": results}, "\t"))
		file.close()
	print("RESULT: t260 fps %d rows" % results.size())
	App.quit()
