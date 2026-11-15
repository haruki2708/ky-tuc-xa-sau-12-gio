extends Node3D
## T-263 stills in chapter 3's real scene: director held, night as the chapter opens, HUD and player hidden, sound muted.
## Round 1, step 0: the six garden corpses whose heads T-259 had hidden (views heads_*), before and after the fix.
## Copy this file to game/_probe_tmp/ with a scene whose root has it, then (one Godot at a time, Lượt Godot):
##   godot --path game res://_probe_tmp/capture_t263.tscn -- --tag=before [--views=a,b]
## Writes art_source/graphics_upgrade/realistic_map/previews/wave6/<view>_<tag>[_torch].jpg (1920 x 1080) and prints
## draw calls, primitives, objects and video memory per shot.
const OUTPUT := "res://../art_source/graphics_upgrade/realistic_map/previews/wave6/"
const RESOLUTION := Vector2i(1920, 1080)
## The six heads of props.tscn Parts/P_paper_box_p0_p0 (#1-3, #10-12), each seen from 1.8 m off, eye 1.7 m up.
const HEADS := [Vector3(11.2119, -9.78, 16.8944), Vector3(29.1026, -9.78, 27.6073), Vector3(14.2825, -9.78, 36.9593),
	Vector3(0.147, -9.78, 7.5621), Vector3(16.5682, -9.78, 18.8205), Vector3(31.0673, -9.78, 30.4178)]
const HEAD_FROM := [Vector3(1.3, 0, -1.3), Vector3(-1.3, 0, -1.3), Vector3(1.3, 0, -1.3), Vector3(1.3, 0, 1.3),
	Vector3(-1.3, 0, -1.3), Vector3(1.3, 0, -1.3)]

var camera: Camera3D
var torch: SpotLight3D


func _ready() -> void:
	call_deferred("_run")


func _arg(name: String, fallback: String) -> String:
	for argument: String in OS.get_cmdline_user_args():
		if argument.begins_with("--%s=" % name):
			return argument.trim_prefix("--%s=" % name)
	return fallback


func _views() -> Dictionary:
	var views := {}
	for i in HEADS.size():
		var head: Vector3 = HEADS[i]
		var eye: Vector3 = head + HEAD_FROM[i] + Vector3(0, 1.58, 0)
		views["heads_%d" % (i + 1)] = {"eye": eye, "target": head + Vector3(0, -0.05, 0), "torch": true, "dark": i < 2}
	return views


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
	var views := _views()
	for view_name: String in views:
		if not only.is_empty() and not view_name in only.split(","):
			continue
		var view: Dictionary = views[view_name]
		camera.global_position = view.eye
		camera.look_at(view.target)
		camera.fov = 75.0
		var modes: Array[bool] = [true]
		if view.get("dark", false):
			modes = [false, true]
		for lit: bool in modes:
			torch.visible = lit
			for frame in range(24):
				await get_tree().process_frame
			await RenderingServer.frame_post_draw
			var image: Image = get_viewport().get_texture().get_image()
			var file := "%s_%s%s.jpg" % [view_name, tag, "_torch" if lit else ""]
			image.save_jpg(OUTPUT + file, 0.88)
			print("CAPTURE: %s draws %d prims %d objects %d vram %d MB" % [file,
				int(Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME)),
				int(Performance.get_monitor(Performance.RENDER_TOTAL_PRIMITIVES_IN_FRAME)),
				int(Performance.get_monitor(Performance.RENDER_TOTAL_OBJECTS_IN_FRAME)),
				int(Performance.get_monitor(Performance.RENDER_VIDEO_MEM_USED) / 1048576.0)])
			count += 1
	print("RESULT: t263 capture %d images" % count)
	App.quit()
