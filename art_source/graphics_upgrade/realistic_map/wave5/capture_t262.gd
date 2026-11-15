extends Node3D
## T-262 round 2 stills, before and after the gate (A14), the whole south wall (Fence/S) and the A16 gate strip, in
## chapter 3's real scene: director held (the twelve guards stand where its _ready puts them), night as the chapter
## opens, HUD and player hidden, sound muted. Near views are also shot with the torch.
## Copy this file to game/_probe_tmp/ with a scene whose root has it, then (one Godot at a time, Lượt Godot):
##   godot --path game res://_probe_tmp/capture_t262.tscn -- --tag=before   (on main's scenes)
##   godot --path game res://_probe_tmp/capture_t262.tscn -- --tag=after
## Writes art_source/graphics_upgrade/realistic_map/previews/wave5/<tag>_<view>[_torch].jpg (1920 x 1080) and prints
## draw calls, primitives, objects and video memory per shot.
const OUTPUT := "res://../art_source/graphics_upgrade/realistic_map/previews/wave5/"
const RESOLUTION := Vector2i(1920, 1080)
const VIEWS := {
	"g1_start": {"eye": Vector3(220, -8.3, -25), "target": Vector3(220, -7.4, -57), "torch": false},
	"g2_approach": {"eye": Vector3(205, -8.3, -16), "target": Vector3(229, -8.2, -55), "torch": false},
	"g3_pillar_west": {"eye": Vector3(203.5, -8.3, -49.5), "target": Vector3(209.5, -6.2, -58.6), "torch": true},
	"g4_sign": {"eye": Vector3(219, -8.3, -46), "target": Vector3(217.5, -5.4, -59), "torch": true},
	"g5_booth": {"eye": Vector3(233.5, -8.3, -45), "target": Vector3(240, -8.2, -53.8), "torch": true},
	"g6_booth_window": {"eye": Vector3(240.4, -8.15, -50.5), "target": Vector3(240.1, -9.0, -53.3), "torch": true},
	"g7_barrier": {"eye": Vector3(209.5, -8.3, -43.5), "target": Vector3(214, -9.3, -49.5), "torch": true},
	"g8_wall_east": {"eye": Vector3(252, -8.3, -51.5), "target": Vector3(238, -8.4, -59.8), "torch": true},
	"g9_gate_out": {"eye": Vector3(220.5, -8.3, -43), "target": Vector3(220, -8.3, -72), "torch": false},
	"g10_to_canteen": {"eye": Vector3(220, -8.3, -42), "target": Vector3(198, -8.6, 18), "torch": false},
	"a1_avenue": {"eye": Vector3(172, -8.3, -15), "target": Vector3(222, -8.9, -28), "torch": false},
	"a2_walk_canteen": {"eye": Vector3(221, -8.3, -14), "target": Vector3(192, -8.9, 16), "torch": true},
	"a3_cars": {"eye": Vector3(214, -8.3, -29), "target": Vector3(208, -9.2, -37.5), "torch": true},
	"a4_court_east": {"eye": Vector3(246, -8.3, -24), "target": Vector3(236, -9.0, -34), "torch": true},
	"w1_wall_behind_b": {"eye": Vector3(22, -8.3, -44), "target": Vector3(4, -8.2, -60), "torch": true},
	"w2_wall_far": {"eye": Vector3(120, -8.3, -30), "target": Vector3(60, -8.6, -60), "torch": false},
	"w3_wall_east_end": {"eye": Vector3(300, -8.3, -42), "target": Vector3(330, -8.2, -60), "torch": false},
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
	var tag := _arg("tag", "after")
	var only := _arg("views", "")
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUTPUT))
	AudioServer.set_bus_mute(0, true)
	Chapter1Director.resume_checkpoint = &""
	var scene := (load("res://scenes/main/chapter3.tscn") as PackedScene).instantiate() as Node3D
	scene.get_node("Chapter3Director").set("auto_start", false)
	add_child(scene)
	for frame in range(3):
		await get_tree().process_frame
	var player := scene.get_node("Player") as Node3D
	player.visible = false
	player.process_mode = Node.PROCESS_MODE_DISABLED
	for layer: CanvasLayer in scene.find_children("*", "CanvasLayer", false, false):
		layer.visible = layer.name == &"PS1Filter"
	print("T262_GUARDS %d standing" % scene.get_node("Chapter3Director").find_children("Guard*", "Node3D", false, false).size())
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
	for view_name: String in VIEWS:
		if not only.is_empty() and not view_name in only.split(","):
			continue
		var view: Dictionary = VIEWS[view_name]
		camera.global_position = view.eye
		camera.look_at(view.target)
		camera.fov = 75.0
		for lit: bool in ([false, true] if view.torch else [false]):
			torch.visible = lit
			for frame in range(24):
				await get_tree().process_frame
			await RenderingServer.frame_post_draw
			var image: Image = get_viewport().get_texture().get_image()
			var file := "%s_%s%s.jpg" % [tag, view_name, "_torch" if lit else ""]
			image.save_jpg(OUTPUT + file, 0.88)
			print("CAPTURE: %s draws %d prims %d objects %d vram %d MB" % [file,
				int(Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME)),
				int(Performance.get_monitor(Performance.RENDER_TOTAL_PRIMITIVES_IN_FRAME)),
				int(Performance.get_monitor(Performance.RENDER_TOTAL_OBJECTS_IN_FRAME)),
				int(Performance.get_monitor(Performance.RENDER_VIDEO_MEM_USED) / 1048576.0)])
			count += 1
	print("RESULT: t262 capture %d images" % count)
	App.quit()
