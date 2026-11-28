extends Node3D
## T-273 (R0 of docs/design/MAP_REALISM_PLAN.md): FPS with the reference-picture look (rendering/map_look.gd) off
## and on. From the T-260 script (art_source/graphics_upgrade/occlusion/fps.gd), same views plus the R0 pilot
## views. MapLook cannot be switched back off inside a run (it scales lights in place), so each Godot measures
## one mode: no argument for off, `--look=1` for on. Occlusion culling stays as the game ships it (on, D-174).
## Copy to game/_probe_tmp/t273_fps.gd with a t273_fps.tscn whose root Node3D carries it (never commit there):
##   godot --path game res://_probe_tmp/t273_fps.tscn -- --chapter=1|3 [--look=1] --out=<json>
## Real chapter scene, director held, HUD and player hidden, sound muted, 1920 x 1080, vsync off. A first pass
## shows every view for a moment so shaders compile before anything is timed (each run starts cold, and the
## look adds SSAO, glow and a sky shader); then each view: 90 frames to settle, 240 measured.
const RESOLUTION := Vector2i(1920, 1080)
const PREPASS := 30
const FIRST_WARMUP := 300
const WARMUP := 90
const SAMPLES := 240
const ALL_DOORS: Array[String] = ["401", "402", "403", "404", "405", "406", "408"]
## The T-260 views (floor 4, then campus in chapter 3), then the R0 pilot views ("p..."). "campus": chapter 3+.
const VIEWS := [
	{"id": "01_corridor_west_doors_shut", "eye": Vector3(1.0, 1.65, 2.0), "target": Vector3(43.0, 1.4, 2.0), "open": []},
	{"id": "02_corridor_east_doors_shut", "eye": Vector3(43.0, 1.65, 2.0), "target": Vector3(1.0, 1.4, 2.0), "open": []},
	{"id": "03_door_406_open_torch", "eye": Vector3(28.0, 1.65, 3.2), "target": Vector3(28.0, 1.2, -4.0), "open": ["406"], "torch": true},
	{"id": "04_doors_405_406_open_torch", "eye": Vector3(26.0, 1.65, 3.5), "target": Vector3(26.0, 1.2, -3.0), "open": ["405", "406"], "torch": true},
	{"id": "05_all_doors_open_west", "eye": Vector3(1.0, 1.65, 2.8), "target": Vector3(43.0, 1.3, 0.0), "open": ALL_DOORS},
	{"id": "06_all_doors_open_east_torch", "eye": Vector3(43.0, 1.65, 2.8), "target": Vector3(1.0, 1.3, 0.0), "open": ALL_DOORS, "torch": true},
	{"id": "07_inside_408_torch", "eye": Vector3(39.0, 1.65, -0.9), "target": Vector3(43.0, 1.1, -5.5), "open": ["408"], "torch": true},
	{"id": "08_inside_402_torch", "eye": Vector3(12.0, 1.65, -0.8), "target": Vector3(12.0, 1.1, -6.5), "open": ["402"], "torch": true},
	{"id": "09_inside_406_look_back_torch", "eye": Vector3(28.0, 1.65, -5.6), "target": Vector3(28.0, 1.2, 0.0), "open": ["406"], "torch": true},
	{"id": "10_balcony_404_along_torch", "eye": Vector3(20.0, 1.65, -7.8), "target": Vector3(40.0, 1.2, -7.8), "open": [], "torch": true},
	{"id": "11_room_407_to_door_torch", "eye": Vector3(34.0, 1.65, -5.0), "target": Vector3(32.0, 1.2, 0.0), "open": [], "torch": true},
	{"id": "12_corridor_407_door_oblique", "eye": Vector3(36.0, 1.65, 3.5), "target": Vector3(31.0, 1.2, 0.0), "open": []},
	{"id": "c1_corridor_east_to_campus", "eye": Vector3(43.0, 1.65, 2.5), "target": Vector3(1.0, 1.0, 6.0), "open": [], "campus": true},
	{"id": "c2_floor4_down_to_garden", "eye": Vector3(22.0, 1.65, 3.5), "target": Vector3(22.0, -9.0, 25.0), "open": [], "campus": true},
	{"id": "c3_floor3_corridor", "eye": Vector3(40.0, -1.65, 2.0), "target": Vector3(20.0, -2.1, 1.0), "open": [], "campus": true, "torch": true},
	{"id": "c4_floor1_lobby", "eye": Vector3(10.0, -8.25, 2.2), "target": Vector3(30.0, -8.7, 1.4), "open": [], "campus": true, "torch": true},
	{"id": "c5_garden_up_to_b", "eye": Vector3(22.0, -8.3, 30.0), "target": Vector3(22.0, -2.0, 0.0), "open": [], "campus": true},
	{"id": "c6_garden_to_building_a", "eye": Vector3(22.0, -8.3, 20.0), "target": Vector3(22.0, -5.0, 60.0), "open": [], "campus": true},
	{"id": "c7_garden_west_oblique", "eye": Vector3(-8.0, -8.3, 25.0), "target": Vector3(30.0, -4.0, -2.0), "open": [], "campus": true},
	{"id": "p1_corridor_west", "eye": Vector3(36.0, 1.65, 2.3), "target": Vector3(6.0, 1.0, 1.6), "open": []},
	{"id": "p2_duty_desk", "eye": Vector3(37.3, 1.65, 3.1), "target": Vector3(40.0, 1.25, 0.4), "open": []},
	{"id": "p3_washroom_door", "eye": Vector3(3.0, 1.65, 0.8), "target": Vector3(2.5, 1.1, -3.5), "open": []},
	{"id": "p4_washroom_basin_torch", "eye": Vector3(2.4, 1.65, -1.0), "target": Vector3(0.2, 1.3, -2.3), "open": [], "torch": true},
	{"id": "p5_building_b_front", "eye": Vector3(22.0, -8.2, 27.0), "target": Vector3(22.0, 4.6, 4.0), "open": [], "campus": true},
	{"id": "p6_building_b_back", "eye": Vector3(19.0, -8.3, -16.5), "target": Vector3(23.0, -5.5, -7.7), "open": [], "campus": true},
	{"id": "p7_road_torch", "eye": Vector3(152.0, -8.2, -13.5), "target": Vector3(140.0, -9.0, -21.5), "open": [], "campus": true, "torch": true},
	{"id": "p8_stadium", "eye": Vector3(115.0, -8.3, 166.0), "target": Vector3(165.0, -9.0, 190.0), "open": [], "campus": true},
]

var camera: Camera3D
var torch: SpotLight3D
var floor4: Node3D


func _ready() -> void:
	call_deferred("_run")


func _arg(name: String, fallback: String) -> String:
	for argument: String in OS.get_cmdline_user_args():
		if argument.begins_with("--%s=" % name):
			return argument.trim_prefix("--%s=" % name)
	return fallback


func _place(view: Dictionary) -> void:
	for number: String in ALL_DOORS:
		var door := floor4.get_node("Corridor/LockedDoor_" + number) as RoomDoor
		door.set_open(number in view.open, 0.01)
	camera.position = view.eye
	camera.look_at(view.target)
	camera.fov = 75.0
	torch.visible = view.get("torch", false)


func _frames(count: int) -> void:
	for frame in range(count):
		await get_tree().process_frame


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
	var look := _arg("look", "0").to_int() != 0
	var out := _arg("out", "")
	AudioServer.set_bus_mute(0, true)
	Chapter1Director.resume_checkpoint = &""
	var scene := (load("res://scenes/main/chapter%d.tscn" % chapter) as PackedScene).instantiate() as Node3D
	scene.get_node("Chapter%dDirector" % chapter).set("auto_start", false)
	floor4 = scene.get_node("Floor4") as Node3D
	add_child(scene)
	await _frames(3)
	var player := scene.get_node("Player") as Node3D
	player.visible = false
	player.process_mode = Node.PROCESS_MODE_DISABLED
	for layer: CanvasLayer in scene.find_children("*", "CanvasLayer", false, false):
		layer.visible = layer.name == &"PS1Filter"
	camera = Camera3D.new()
	add_child(camera)
	camera.make_current()
	# Named like the phone's torch: MapLook retunes the spot called Flashlight, room 407 blends it.
	torch = SpotLight3D.new()
	torch.name = "Flashlight"
	torch.position = Vector3(0.1, -0.08, -0.15)
	torch.light_color = Color(0.9, 0.94, 1.0)
	torch.light_energy = 1.5
	torch.spot_range = 12.0
	torch.spot_angle = 28.0
	torch.shadow_enabled = true
	camera.add_child(torch)
	var views: Array = VIEWS.filter(func(view: Dictionary) -> bool: return chapter >= 3 or not view.get("campus", false))
	# Compile pipelines everywhere first, so no view pays for a cold start.
	for view: Dictionary in views:
		_place(view)
		await _frames(PREPASS)
	var results: Array[Dictionary] = []
	var first := true
	for view: Dictionary in views:
		_place(view)
		await _frames(FIRST_WARMUP if first else WARMUP)
		first = false
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
			"view": view.id, "chapter": chapter, "look": look,
			"mean_fps": snappedf(1000.0 * SAMPLES / total, 0.1),
			"mean_ms": snappedf(total / SAMPLES, 0.01),
			"low1_fps": snappedf(1000.0 / (worst_total / worst.size()), 0.1),
			"p95_ms": snappedf(float(sorted[int(SAMPLES * 0.95)]), 0.01),
			"max_ms": snappedf(float(sorted[-1]), 0.01),
			"objects": int(RenderingServer.get_rendering_info(RenderingServer.RENDERING_INFO_TOTAL_OBJECTS_IN_FRAME)),
			"primitives": int(RenderingServer.get_rendering_info(RenderingServer.RENDERING_INFO_TOTAL_PRIMITIVES_IN_FRAME)),
			"draw_calls": int(RenderingServer.get_rendering_info(RenderingServer.RENDERING_INFO_TOTAL_DRAW_CALLS_IN_FRAME)),
			"vram_mb": int(Performance.get_monitor(Performance.RENDER_VIDEO_MEM_USED) / 1048576.0),
		}
		results.append(row)
		print("FPS ch%d look=%s %s: mean %.1f  1%%low %.1f  p95 %.2f ms  max %.2f ms  draws %d  vram %d MB" % [
			chapter, "on" if look else "off", row.view, row.mean_fps, row.low1_fps, row.p95_ms, row.max_ms,
			row.draw_calls, row.vram_mb])
	if not out.is_empty():
		var file := FileAccess.open(out, FileAccess.WRITE)
		file.store_string(JSON.stringify({"gpu": RenderingServer.get_video_adapter_name(), "look": look,
			"window": [get_window().size.x, get_window().size.y], "results": results}, "\t"))
		file.close()
	print("RESULT: t273 fps ch%d look=%s %d rows" % [chapter, "on" if look else "off", results.size()])
	App.quit()
