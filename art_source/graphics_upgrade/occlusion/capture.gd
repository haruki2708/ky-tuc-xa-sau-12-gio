extends Node3D
## T-260 (HARU; copied to game/_probe_tmp/t260_capture.gd with a t260_capture.tscn whose root Node3D carries it, never
## committed there): the same camera with occlusion culling off then on, in the real chapter scenes (director held,
## player and HUD hidden, sound muted, time all but stopped so fans and flickering lights stand still), 1920 x 1080, the
## survey torch on the camera. Stills go to art_source/graphics_upgrade/occlusion/previews/{off,on}_chN_<view>.jpg.
## With --walk the camera walks fixed paths (0.03 m a frame) once off and once on, every 3rd frame saved at 960 x 540
## to build/haru/t260_walk/.
##   godot --path game res://_probe_tmp/t260_capture.tscn -- --chapter=3 [--walk]
const OUTPUT := "res://../art_source/graphics_upgrade/occlusion/previews/"
const WALK_OUT := "res://../build/haru/t260_walk/"
const RESOLUTION := Vector2i(1920, 1080)
const ALL_DOORS: Array[String] = ["401", "402", "403", "404", "405", "406", "408"]
const VIEWS := {
	1: [
		{"id": "01_corridor_west_doors_shut", "eye": Vector3(1.0, 1.65, 2.0), "target": Vector3(43.0, 1.4, 2.0)},
		{"id": "02_corridor_east_doors_shut", "eye": Vector3(43.0, 1.65, 2.0), "target": Vector3(1.0, 1.4, 2.0)},
		{"id": "03_door_406_open", "eye": Vector3(28.0, 1.65, 3.2), "target": Vector3(28.0, 1.2, -4.0), "open": ["406"]},
		{"id": "04_all_doors_open_west", "eye": Vector3(1.0, 1.65, 2.8), "target": Vector3(43.0, 1.3, 0.0), "open": ALL_DOORS},
		{"id": "05_all_doors_open_east", "eye": Vector3(43.0, 1.65, 2.8), "target": Vector3(1.0, 1.3, 0.0), "open": ALL_DOORS},
		{"id": "06_inside_408", "eye": Vector3(39.0, 1.65, -0.9), "target": Vector3(43.0, 1.1, -5.5), "open": ["408"]},
		{"id": "07_inside_402", "eye": Vector3(12.0, 1.65, -0.8), "target": Vector3(12.0, 1.1, -6.5), "open": ["402"]},
		{"id": "08_inside_406_look_back", "eye": Vector3(28.0, 1.65, -5.6), "target": Vector3(28.0, 1.2, 0.0), "open": ["406"]},
		{"id": "09_balcony_404_along", "eye": Vector3(20.0, 1.65, -7.8), "target": Vector3(40.0, 1.2, -7.8)},
		{"id": "10_room_407_to_door", "eye": Vector3(34.0, 1.65, -5.0), "target": Vector3(32.0, 1.2, 0.0)},
		{"id": "11_room_407_from_door", "eye": Vector3(32.3, 1.65, -0.6), "target": Vector3(35.0, 1.0, -5.0)},
		{"id": "12_washroom_entrance", "eye": Vector3(3.0, 1.65, 2.5), "target": Vector3(3.0, 1.2, -4.0)},
		{"id": "13_corridor_407_door_oblique", "eye": Vector3(36.0, 1.65, 3.5), "target": Vector3(31.0, 1.2, 0.0)},
	],
	3: [
		{"id": "01_corridor_west_doors_shut", "eye": Vector3(1.0, 1.65, 2.0), "target": Vector3(43.0, 1.4, 2.0)},
		{"id": "02_corridor_east_to_campus", "eye": Vector3(43.0, 1.65, 2.5), "target": Vector3(1.0, 1.0, 6.0)},
		{"id": "03_all_doors_open_east", "eye": Vector3(43.0, 1.65, 2.8), "target": Vector3(1.0, 1.3, 0.0), "open": ALL_DOORS},
		{"id": "04_floor4_down_to_garden", "eye": Vector3(22.0, 1.65, 3.5), "target": Vector3(22.0, -9.0, 25.0)},
		{"id": "05_fire_stairs", "eye": Vector3(46.5, 1.65, 2.5), "target": Vector3(45.2, -0.7, -1.4), "fire_door": true},
		{"id": "06_main_stairs", "eye": Vector3(-1.0, 1.65, 2.5), "target": Vector3(-3.8, -0.7, -1.4)},
		{"id": "07_floor3_corridor", "eye": Vector3(40.0, -1.65, 2.0), "target": Vector3(20.0, -2.1, 1.0)},
		{"id": "08_floor3_door_close", "eye": Vector3(33.0, -1.8, 1.8), "target": Vector3(32.0, -2.2, 0.0)},
		{"id": "09_floor2_corridor", "eye": Vector3(4.0, -4.95, 2.5), "target": Vector3(40.0, -5.4, 1.0)},
		{"id": "10_floor1_lobby", "eye": Vector3(10.0, -8.25, 2.2), "target": Vector3(30.0, -8.7, 1.4)},
		{"id": "11_manager_room", "eye": Vector3(4.0, -8.25, -3.2), "target": Vector3(4.0, -9.0, -7.0)},
		{"id": "12_garden_up_to_b", "eye": Vector3(22.0, -8.3, 30.0), "target": Vector3(22.0, -2.0, 0.0)},
		{"id": "13_garden_to_building_a", "eye": Vector3(22.0, -8.3, 20.0), "target": Vector3(22.0, -5.0, 60.0)},
		{"id": "14_garden_west_oblique", "eye": Vector3(-8.0, -8.3, 25.0), "target": Vector3(30.0, -4.0, -2.0)},
		{"id": "15_room_407_from_door", "eye": Vector3(32.3, 1.65, -0.6), "target": Vector3(35.0, 1.0, -5.0)},
	],
}
## Walks: points the eye passes through (straight lines between), looking ahead along the path, doors as listed.
const WALKS := {
	1: [
		{"id": "w1_corridor_into_407", "points": [Vector3(24.0, 1.65, 2.6), Vector3(32.0, 1.65, 2.2), Vector3(32.0, 1.65, -0.8), Vector3(34.5, 1.65, -4.5)], "look_down": 0.15},
		{"id": "w2_corridor_into_402_open", "open": ["402"], "points": [Vector3(4.0, 1.65, 2.8), Vector3(12.0, 1.65, 2.4), Vector3(12.0, 1.65, -1.0), Vector3(12.0, 1.65, -6.0)], "look_down": 0.15},
	],
	3: [
		{"id": "w3_garden_to_lobby", "points": [Vector3(19.25, -8.35, 16.0), Vector3(19.25, -8.35, 4.0), Vector3(19.25, -8.35, -1.5), Vector3(8.0, -8.35, -1.5)], "look_down": 0.1},
		{"id": "w4_main_stairs_down", "points": [Vector3(4.0, 1.65, 2.5), Vector3(-1.2, 1.65, 2.5), Vector3(-1.2, 0.2, -4.6), Vector3(-3.8, -0.5, -5.5), Vector3(-3.8, -1.7, 2.0), Vector3(4.0, -1.65, 2.5)], "look_down": 0.2},
		{"id": "w5_corridor_east_to_fire_stairs", "points": [Vector3(30.0, 1.65, 2.5), Vector3(46.5, 1.65, 2.5), Vector3(46.5, 0.2, -4.6)], "look_down": 0.2, "fire_door": true},
	],
}
const STEP := 0.03

var scene: Node3D
var floor4: Node3D
var campus: Node3D
var camera: Camera3D


func _ready() -> void:
	call_deferred("_run")


func _arg(name: String, fallback: String) -> String:
	for argument: String in OS.get_cmdline_user_args():
		if argument.begins_with("--%s=" % name):
			return argument.trim_prefix("--%s=" % name)
		if argument == "--%s" % name:
			return "true"
	return fallback


func _run() -> void:
	if DisplayServer.get_name() == "headless":
		push_error("Capture needs a window.")
		App.quit(1)
		return
	get_window().mode = Window.MODE_WINDOWED
	get_window().content_scale_size = RESOLUTION
	get_window().size = RESOLUTION
	get_viewport().scaling_3d_scale = 1.0
	var chapter := _arg("chapter", "1").to_int()
	var walk := _arg("walk", "false") == "true"
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUTPUT))
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(WALK_OUT))
	AudioServer.set_bus_mute(0, true)
	Chapter1Director.resume_checkpoint = &""
	scene = (load("res://scenes/main/chapter%d.tscn" % chapter) as PackedScene).instantiate() as Node3D
	scene.get_node("Chapter%dDirector" % chapter).set("auto_start", false)
	add_child(scene)
	for frame in range(3):
		await get_tree().process_frame
	campus = scene.get_node_or_null("Campus") as Node3D
	floor4 = scene.get_node("Floor4") as Node3D
	var player := scene.get_node("Player") as Node3D
	player.visible = false
	player.process_mode = Node.PROCESS_MODE_DISABLED
	for layer: CanvasLayer in scene.find_children("*", "CanvasLayer", false, false):
		layer.visible = layer.name == &"PS1Filter"
	camera = Camera3D.new()
	add_child(camera)
	camera.make_current()
	camera.fov = 75.0
	var torch := SpotLight3D.new()
	torch.position = Vector3(0.1, -0.08, -0.15)
	torch.light_color = Color(0.9, 0.94, 1.0)
	torch.light_energy = 1.5
	torch.spot_range = 12.0
	torch.spot_angle = 34.0
	torch.shadow_enabled = true
	camera.add_child(torch)
	for frame in range(10):
		await get_tree().process_frame
	Engine.time_scale = 0.0001  # not 0: a campus script divides by the frame's delta
	if walk:
		for path: Dictionary in WALKS[chapter]:
			for mode in ["off", "on"]:
				await _walk(chapter, path, mode)
	else:
		for view: Dictionary in VIEWS[chapter]:
			_set_doors(view)
			camera.position = view.eye
			camera.look_at(view.target)
			for mode in ["off", "on"]:
				get_tree().root.use_occlusion_culling = mode == "on"
				for frame in range(30):
					await get_tree().process_frame
				await RenderingServer.frame_post_draw
				var image: Image = get_viewport().get_texture().get_image()
				image.save_jpg(OUTPUT + "%s_ch%d_%s.jpg" % [mode, chapter, view.id], 0.92)
				print("CAPTURE: ch%d %s %s  prims %d  draws %d  objects %d" % [chapter, mode, view.id,
					RenderingServer.get_rendering_info(RenderingServer.RENDERING_INFO_TOTAL_PRIMITIVES_IN_FRAME),
					RenderingServer.get_rendering_info(RenderingServer.RENDERING_INFO_TOTAL_DRAW_CALLS_IN_FRAME),
					RenderingServer.get_rendering_info(RenderingServer.RENDERING_INFO_TOTAL_OBJECTS_IN_FRAME)])
	Engine.time_scale = 1.0
	print("RESULT: t260 capture ch%d %s" % [chapter, "walk" if walk else "stills"])
	App.quit()


func _set_doors(view: Dictionary) -> void:
	for number: String in ALL_DOORS:
		(floor4.get_node("Corridor/LockedDoor_" + number) as RoomDoor).set_open(number in view.get("open", []), 0.01)
	if campus != null:
		campus.call("set_fire_door_open", view.get("fire_door", false))


func _walk(chapter: int, path: Dictionary, mode: String) -> void:
	_set_doors(path)
	get_tree().root.use_occlusion_culling = mode == "on"
	var points: Array = path.points
	camera.position = points[0]
	camera.look_at(points[1] + Vector3.DOWN * float(path.look_down))
	for frame in range(30):
		await get_tree().process_frame
	var index := 0
	for leg in range(points.size() - 1):
		var a: Vector3 = points[leg]
		var b: Vector3 = points[leg + 1]
		var steps := maxi(1, int(a.distance_to(b) / STEP))
		for i in range(steps):
			camera.position = a.lerp(b, float(i + 1) / steps)
			camera.look_at(camera.position + (b - a).normalized() + Vector3.DOWN * float(path.look_down))
			await RenderingServer.frame_post_draw
			if index % 3 == 0:
				var image: Image = get_viewport().get_texture().get_image()
				image.resize(960, 540, Image.INTERPOLATE_BILINEAR)
				image.save_jpg(WALK_OUT + "%s_ch%d_%s_%04d.jpg" % [mode, chapter, path.id, index], 0.9)
			index += 1
	print("WALK: ch%d %s %s frames %d" % [chapter, mode, path.id, index])
