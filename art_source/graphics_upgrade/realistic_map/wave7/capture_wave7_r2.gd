extends Node3D
## T-264 round 2 stills: the chapter's real scene as patched (after) and, at run time only, as main had it (before: the
## PS1 meshes shown again, Real and the figures hidden, WindowSilhouette2 back at x 31). Night as the chapter opens, same
## cameras before and after, with and without the torch (the phone's: 12 m, 28 degrees), occlusion culling on (the
## chapter's occluders) and off. No light added but the torch. Director held, HUD and player hidden, sound muted.
## --chapter=1 takes chapters 1-2's light building A from floor 4's corridor instead (before: the backdrop's BuildingA
## hidden).
## Copy this file to game/_probe_tmp/ with a scene whose root has it, then (one Godot at a time, Lượt Godot):
##   godot --path game res://_probe_tmp/capture_wave7_r2.tscn [-- --chapter=1] [--shots=prefix,...]
## Writes art_source/graphics_upgrade/realistic_map/previews/wave7/r2_<shot>.jpg (1920 x 1080), prints draws per shot.
const OUTPUT := "res://../art_source/graphics_upgrade/realistic_map/previews/wave7/"
const RESOLUTION := Vector2i(1920, 1080)
const VIEWS := {
	"a_garden": [Vector3(22, -8.2, 30), Vector3(22, -2.5, 54)],
	"a_foot": [Vector3(18.0, -8.3, 49.0), Vector3(21.5, -6.6, 54)],
	"a_window": [Vector3(15.5, -8.2, 46.0), Vector3(18.0, -1.6, 54)],
	"a_window2": [Vector3(30.0, -8.2, 46.0), Vector3(32.0, -1.6, 54)],
	"a_corner": [Vector3(52, -8.2, 44), Vector3(30, -4.0, 56)],
	"a_corridor4": [Vector3(37, 1.62, 3.3), Vector3(22, -1.0, 54)],
	"lecture": [Vector3(-10, -8.2, 158), Vector3(-10, -3.0, 180)],
	"lecture_corner": [Vector3(42, -8.2, 170), Vector3(10, -3.0, 182)],
	"gym_corner": [Vector3(12, -8.2, 76), Vector3(-14, -5.0, 92)],
	"gym_door": [Vector3(-27.5, -8.3, 82.5), Vector3(-30, -7.2, 90)],
	"b_upper": [Vector3(22, -8.2, 27), Vector3(22, 4.6, 4)],
	"b_upper_near": [Vector3(10, -8.2, 12), Vector3(18, 5.0, 3)],
	"b_upper_eye": [Vector3(22, 5.0, 14), Vector3(22, 4.6, 0)],
	"b_back": [Vector3(19, -8.3, -16.5), Vector3(23, -5.5, -7.7)],
	"b_back_wide": [Vector3(30, -8.0, -30), Vector3(20, 0.0, -7.7)],
	"w_corridor4": [Vector3(37, 1.62, 3.3), Vector3(22, -4.0, 40)],
	"w_garden": [Vector3(22, -8.2, 26), Vector3(60, -6.0, 62)],
	"w_stand": [Vector3(200, -4.0, 222), Vector3(200, -7.5, 160)],
}
const CH1_VIEWS := {
	"ch1_corridor4": [Vector3(37, 1.62, 3.3), Vector3(22, -1.0, 54)],
	"ch1_corridor4_wide": [Vector3(20, 1.62, 3.3), Vector3(22, -3.0, 40)],
}

var camera: Camera3D
var torch: SpotLight3D
var shown_ps1: Array[Node3D] = []   # hidden in the scene, shown for "before"
var real: Array[Node3D] = []        # this wave's layers, hidden for "before"
var silhouette2: Node3D


func _ready() -> void:
	call_deferred("_run")


func _arg(name: String, fallback: String) -> String:
	for argument: String in OS.get_cmdline_user_args():
		if argument.begins_with("--%s=" % name):
			return argument.trim_prefix("--%s=" % name)
	return fallback


func _shots() -> Array:
	var out: Array = []
	for view in ["a_garden", "a_foot", "a_window", "a_window2", "a_corner", "a_corridor4", "lecture", "lecture_corner", "gym_corner",
			"gym_door", "b_upper", "b_upper_near", "b_upper_eye", "b_back", "b_back_wide", "w_corridor4", "w_garden", "w_stand"]:
		out.append(["before_" + view, view, false, false, true])
		out.append(["after_" + view, view, true, false, true])
	for view in ["a_foot", "a_window", "gym_door", "b_back", "a_corridor4"]:
		out.append(["after_%s_torch" % view, view, true, true, true])
	for view in ["a_foot", "a_corridor4", "lecture", "gym_door", "b_upper", "b_upper_near"]:
		out.append(["after_%s_occoff" % view, view, true, false, false])
	return out


func _ch1_shots() -> Array:
	var out: Array = []
	for view in CH1_VIEWS:
		out.append(["before_" + view, view, false, false, true])
		out.append(["after_" + view, view, true, false, true])
	return out


func _collect(campus: Node) -> void:
	var shells := campus.get_node("Shells")
	for mesh: MeshInstance3D in shells.find_children("*", "MeshInstance3D", true, false):
		var path := String(shells.get_path_to(mesh))
		if not mesh.visible and not path.begins_with("Real") and not path.contains("Figure"):
			shown_ps1.append(mesh)
	real.append(shells.get_node("Real") as Node3D)
	for k in 3:
		real.append(shells.get_node("WindowSilhouette%d/Figure" % k) as Node3D)
	silhouette2 = shells.get_node("WindowSilhouette2") as Node3D
	var b := campus.get_node("BuildingB")
	for mesh: MeshInstance3D in b.find_children("*", "MeshInstance3D", true, false):
		var path := String(b.get_path_to(mesh))
		if not mesh.visible and path.begins_with("Upper"):
			shown_ps1.append(mesh)
	real.append(b.get_node("Real") as Node3D)
	print("T264_R2 %d PS1 meshes to show for before, %d layers" % [shown_ps1.size(), real.size()])


func _apply(after: bool) -> void:
	for node in shown_ps1:
		node.visible = not after
	for node in real:
		node.visible = after
	if silhouette2 != null:
		silhouette2.position.x = 32.0 if after else 31.0


func _run() -> void:
	if DisplayServer.get_name() == "headless":
		push_error("Capture needs a window.")
		App.quit(1)
		return
	get_window().mode = Window.MODE_WINDOWED
	get_window().content_scale_size = RESOLUTION
	get_window().size = RESOLUTION
	get_viewport().scaling_3d_scale = 1.0
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUTPUT))
	AudioServer.set_bus_mute(0, true)
	Chapter1Director.resume_checkpoint = &""
	var chapter := _arg("chapter", "3")
	var scene := (load("res://scenes/main/chapter%s.tscn" % chapter) as PackedScene).instantiate() as Node3D
	var director := scene.get_node_or_null("Chapter%sDirector" % chapter)
	if director != null:
		director.set("auto_start", false)
	add_child(scene)
	for frame in range(3):
		await get_tree().process_frame
	var player := scene.get_node("Player") as Node3D
	player.visible = false
	player.process_mode = Node.PROCESS_MODE_DISABLED
	for layer: CanvasLayer in scene.find_children("*", "CanvasLayer", false, false):
		layer.visible = layer.name == &"PS1Filter"
	var views := VIEWS
	var shots: Array
	if chapter == "3":
		_collect(scene.get_node("Campus"))
		shots = _shots()
	else:
		real.append(scene.get_node("Floor4/Corridor/GardenBackdrop/BuildingA") as Node3D)
		views = CH1_VIEWS
		shots = _ch1_shots()
	camera = Camera3D.new()
	add_child(camera)
	camera.far = 4000.0
	torch = SpotLight3D.new()
	torch.position = Vector3(0.1, -0.08, -0.15)
	torch.light_color = Color(0.9, 0.94, 1.0)
	torch.light_energy = 1.5
	torch.spot_range = 12.0
	torch.spot_angle = 28.0
	torch.shadow_enabled = true
	camera.add_child(torch)
	var only := _arg("shots", "")
	var count := 0
	for shot: Array in shots:
		if not only.is_empty():
			var keep := false
			for prefix in only.split(","):
				keep = keep or String(shot[0]).begins_with(prefix)
			if not keep:
				continue
		_apply(shot[2])
		get_tree().root.use_occlusion_culling = shot[4]
		var view: Array = views[shot[1]]
		camera.make_current()
		camera.global_position = view[0]
		camera.look_at(view[1])
		camera.fov = 75.0
		torch.visible = shot[3]
		for frame in range(20):
			await get_tree().process_frame
		await RenderingServer.frame_post_draw
		var image: Image = get_viewport().get_texture().get_image()
		image.save_jpg(OUTPUT + "r2_%s.jpg" % shot[0], 0.88)
		print("CAPTURE: %s draws %d prims %d objects %d vram %d MB" % [shot[0],
			RenderingServer.get_rendering_info(RenderingServer.RENDERING_INFO_TOTAL_DRAW_CALLS_IN_FRAME),
			RenderingServer.get_rendering_info(RenderingServer.RENDERING_INFO_TOTAL_PRIMITIVES_IN_FRAME),
			RenderingServer.get_rendering_info(RenderingServer.RENDERING_INFO_TOTAL_OBJECTS_IN_FRAME),
			int(RenderingServer.get_rendering_info(RenderingServer.RENDERING_INFO_VIDEO_MEM_USED) / 1048576.0)])
		count += 1
	print("RESULT: t264 round 2 capture %d images" % count)
	App.quit()
