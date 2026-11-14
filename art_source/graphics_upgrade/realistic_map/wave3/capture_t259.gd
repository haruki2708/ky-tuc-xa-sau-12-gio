extends Node3D
## T-259 round 2 stills, before and after the garden (A12), the B-to-garden strip (A16) and the chapter 1-2 view from
## floor 4 (A05), in the chapters' real scenes: director held, lights as the chapter opens, HUD and player hidden, sound
## muted. The garden's six Flicker lights are held on (0.35) so before and after are lit alike.
## Copy this file to game/_probe_tmp/ with a scene whose root has it, then (one Godot at a time, Lượt Godot):
##   godot --path game res://_probe_tmp/capture_t259.tscn -- --chapter=3 --tag=before
##   godot --path game res://_probe_tmp/capture_t259.tscn -- --chapter=1 --tag=before
## Writes art_source/graphics_upgrade/realistic_map/previews/wave3/<tag>_<view>_<dark|torch>.jpg (1920 x 1080) and
## prints draw calls, primitives and video memory per shot.
const OUTPUT := "res://../art_source/graphics_upgrade/realistic_map/previews/wave3/"
const RESOLUTION := Vector2i(1920, 1080)
const VIEWS := {
	3: {
		"c1_entry": {"eye": Vector3(22.6, -8.3, 8.6), "target": Vector3(22, -8.7, 20), "torch": [false, true]},
		"c2_middle": {"eye": Vector3(14.2, -8.3, 17.2), "target": Vector3(27, -8.6, 33), "torch": [false]},
		"c3_ngu_bench": {"eye": Vector3(24.6, -8.3, 25.4), "target": Vector3(21.8, -9.1, 28.4), "torch": [false, true]},
		"c4_fallen_bunk": {"eye": Vector3(10.8, -8.3, 34.2), "target": Vector3(7.6, -9.3, 37), "torch": [false, true]},
		"c5_floor4": {"eye": Vector3(22, 1.6, 3.3), "target": Vector3(22, -9.9, 25), "torch": [false]},
		"c6_strip": {"eye": Vector3(1.5, -8.3, 5.4), "target": Vector3(26, -9.2, 7.4), "torch": [false]},
		"c7_notice_board": {"eye": Vector3(29.6, -8.3, 14.2), "target": Vector3(30.5, -8.5, 11.1), "torch": [false, true]},
		"c8_back_edge": {"eye": Vector3(24, -8.3, 44.5), "target": Vector3(20, -9.5, 50), "torch": [false, true]},
		"c9_bench_back": {"eye": Vector3(4.6, -8.3, 19.6), "target": Vector3(2, -9.2, 22), "torch": [false, true]},
		"c10_lamp": {"eye": Vector3(4.6, -8.3, 27.6), "target": Vector3(1.0, -7.7, 24.0), "torch": [false]},
	},
	1: {
		"f1_floor4": {"eye": Vector3(22, 1.6, 3.3), "target": Vector3(22, -9.9, 25), "torch": [false]},
		"f2_floor4_west": {"eye": Vector3(9, 1.6, 3.4), "target": Vector3(20, -9.9, 30), "torch": [false]},
		"f3_floor4_far": {"eye": Vector3(30, 1.6, 3.4), "target": Vector3(18, -6.0, 40), "torch": [false]},
	},
}

var camera: Camera3D
var torch: SpotLight3D


func _ready() -> void:
	call_deferred("_run")


func _arg(name: String, fallback: String) -> String:
	for argument: String in OS.get_cmdline_user_args():
		if argument.begins_with("--%s=" % name):
			return argument.trim_prefix("--%s=" % name)
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
	var chapter := _arg("chapter", "3").to_int()
	var tag := _arg("tag", "after")
	var only := _arg("views", "")
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUTPUT))
	AudioServer.set_bus_mute(0, true)
	Chapter1Director.resume_checkpoint = &""
	var scene := (load("res://scenes/main/chapter%d.tscn" % chapter) as PackedScene).instantiate() as Node3D
	scene.get_node("Chapter%dDirector" % chapter).set("auto_start", false)
	add_child(scene)
	for frame in range(3):
		await get_tree().process_frame
	var player := scene.get_node("Player") as Node3D
	player.visible = false
	player.process_mode = Node.PROCESS_MODE_DISABLED
	for layer: CanvasLayer in scene.find_children("*", "CanvasLayer", false, false):
		layer.visible = layer.name == &"PS1Filter"
	var garden := scene.get_node_or_null("Campus/Garden")
	if garden != null:
		for i in 6:
			var flicker := garden.get_node("Flicker%d" % i) as OmniLight3D
			flicker.set_process(false)
			flicker.light_energy = 0.35
	camera = Camera3D.new()
	add_child(camera)
	camera.make_current()
	camera.far = 4000.0
	torch = SpotLight3D.new()
	torch.position = Vector3(0.1, -0.08, -0.15)
	torch.light_color = Color(0.9, 0.94, 1.0)
	torch.light_energy = 1.5
	torch.spot_range = 12.0
	torch.spot_angle = 28.0
	torch.shadow_enabled = true
	camera.add_child(torch)
	var count := 0
	for view_name: String in VIEWS[chapter]:
		if not only.is_empty() and not view_name in only.split(","):
			continue
		var view: Dictionary = VIEWS[chapter][view_name]
		camera.global_position = view.eye
		camera.look_at(view.target)
		camera.fov = view.get("fov", 75.0)
		for lit: bool in view.torch:
			torch.visible = lit
			for frame in range(30):
				await get_tree().process_frame
			await RenderingServer.frame_post_draw
			var image: Image = get_viewport().get_texture().get_image()
			var file := "%s_%s_%s.jpg" % [tag, view_name, "torch" if lit else "dark"]
			image.save_jpg(OUTPUT + file, 0.88)
			print("CAPTURE: %s draws %d prims %d objects %d vram %d MB" % [file,
				int(Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME)),
				int(Performance.get_monitor(Performance.RENDER_TOTAL_PRIMITIVES_IN_FRAME)),
				int(Performance.get_monitor(Performance.RENDER_TOTAL_OBJECTS_IN_FRAME)),
				int(Performance.get_monitor(Performance.RENDER_VIDEO_MEM_USED) / 1048576.0)])
			count += 1
	print("RESULT: t259 capture %d images" % count)
	App.quit()
