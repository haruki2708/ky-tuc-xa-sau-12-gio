extends Node3D
## T-265 round 2 stills (card section 7): the chapter's real scene as patched (after) and, at run time only, as main had it
## (before: the library's PS1 meshes and the Shells' LibraryBand* shown again, Real, the new leaf and StripLibrary hidden).
## Night as the chapter opens, same cameras before and after, with and without the torch (the phone's: 12 m, 28 degrees);
## no light added but the torch. Director held, HUD and player hidden, sound muted. Chapter 4: the library's views, the
## draws at card section 6's angles, a few views with occlusion culling off; chapter 3: the library from the stadium and
## wave 7's three panoramas (their draws may not rise).
## Copy this file to game/_probe_tmp/ with a scene whose root has it, then (one Godot at a time, Lượt Godot):
##   godot --path game res://_probe_tmp/capture_wave8_r2.tscn [-- --parts=ch4,ch3] [--views=f1_backdoor,...]
## Writes art_source/graphics_upgrade/realistic_map/previews/wave8/<before|after|occl_off>_<view>[_torch].jpg (1600 x 900)
## and prints draws, primitives, objects and video memory per shot.
const OUTPUT := "res://../art_source/graphics_upgrade/realistic_map/previews/wave8/"
const RESOLUTION := Vector2i(1600, 900)
const VIEWS := {
	"back_out": {"eye": Vector3(66.0, -8.3, 231.0), "target": Vector3(65.0, -8.5, 225.0), "torch": true},
	"f1_backdoor": {"eye": Vector3(65.0, -8.3, 224.2), "target": Vector3(58.5, -9.0, 206.5), "torch": true, "open": true},
	"f1_wide": {"eye": Vector3(80.5, -8.25, 213.6), "target": Vector3(52.0, -8.9, 205.0), "torch": true, "fov": 80.0},
	"f1_north": {"eye": Vector3(66.5, -8.3, 212.5), "target": Vector3(50.0, -8.9, 220.0), "torch": true, "fov": 80.0},
	"f1_counter": {"eye": Vector3(61.4, -8.35, 209.4), "target": Vector3(57.4, -9.1, 206.1), "torch": true},
	"f1_map": {"eye": Vector3(47.25, -8.3, 211.0), "target": Vector3(45.2, -8.15, 211.0), "torch": true},
	"f1_front_door": {"eye": Vector3(66.2, -8.3, 201.0), "target": Vector3(65.0, -8.9, 195.3), "torch": true},
	"stairs": {"eye": Vector3(77.7, -8.3, 196.4), "target": Vector3(82.0, -6.9, 206.5), "torch": true},
	"stair_top": {"eye": Vector3(81.0, -5.0, 210.6), "target": Vector3(60.0, -5.6, 214.0), "torch": true, "fov": 80.0},
	"f2_well": {"eye": Vector3(75.5, -5.0, 211.5), "target": Vector3(80.0, -6.0, 202.0), "torch": true},
	"f2_table": {"eye": Vector3(61.2, -5.0, 213.0), "target": Vector3(57.8, -5.8, 216.2), "torch": true},
	"f2_wide": {"eye": Vector3(66.0, -5.0, 210.0), "target": Vector3(50.0, -5.6, 200.0), "torch": true, "fov": 80.0},
	"f3_wide": {"eye": Vector3(80.6, -1.7, 213.4), "target": Vector3(54.0, -2.6, 219.0), "torch": true, "fov": 80.0},
	"f3_south": {"eye": Vector3(65.0, -1.7, 210.0), "target": Vector3(50.0, -2.4, 199.0), "torch": true, "fov": 80.0},
	"f3_scare": {"eye": Vector3(57.7, -1.7, 213.6), "target": Vector3(57.0, -2.3, 218.0), "torch": true},
	"f3_scare2": {"eye": Vector3(73.1, -1.7, 213.0), "target": Vector3(73.0, -1.6, 218.0), "torch": true},
	"facade": {"eye": Vector3(59.0, -8.3, 180.5), "target": Vector3(66.0, -5.0, 195.0), "torch": false, "fov": 80.0},
	"facade_side": {"eye": Vector3(92.0, -8.3, 186.0), "target": Vector3(70.0, -4.8, 200.0), "torch": false},
	"facade_east": {"eye": Vector3(98.0, -8.3, 203.0), "target": Vector3(85.0, -5.5, 213.0), "torch": false, "fov": 80.0},
	"strip_west": {"eye": Vector3(40.5, -8.3, 230.0), "target": Vector3(44.0, -9.3, 205.0), "torch": true},
}
const DRAW_VIEWS := ["f1_backdoor", "f2_wide", "f3_wide", "stair_top", "facade"]
const OCCLUSION_VIEWS := ["f1_backdoor", "f1_wide", "facade", "facade_side"]
const CH3_VIEWS := {
	"far_stand": {"eye": Vector3(114.0, -4.5, 196.0), "target": Vector3(66.0, -5.0, 210.0), "fov": 60.0},
	"far_track": {"eye": Vector3(124.0, -8.3, 176.0), "target": Vector3(70.0, -4.6, 206.0), "fov": 60.0},
	"w_corridor4": {"eye": Vector3(37, 1.62, 3.3), "target": Vector3(22, -4.0, 40)},
	"w_garden": {"eye": Vector3(22, -8.2, 26), "target": Vector3(60, -6.0, 62)},
	"w_stand": {"eye": Vector3(200, -4.0, 222), "target": Vector3(200, -7.5, 160)},
}

var camera: Camera3D
var torch: SpotLight3D
var campus: Node3D
var library: Node3D
var ps1: Array[Node3D] = []
var real: Array[Node3D] = []
var count := 0


func _ready() -> void:
	call_deferred("_run")


func _arg(name: String, fallback: String) -> String:
	for argument: String in OS.get_cmdline_user_args():
		if argument.begins_with("--%s=" % name):
			return argument.trim_prefix("--%s=" % name)
	return fallback


func _load_chapter(path: String, director_name: String) -> Node3D:
	Chapter1Director.resume_checkpoint = &""
	var scene := (load(path) as PackedScene).instantiate() as Node3D
	scene.get_node(director_name).set("auto_start", false)
	add_child(scene)
	for frame in range(3):
		await get_tree().process_frame
	var player := scene.get_node("Player") as Node3D
	player.visible = false
	player.process_mode = Node.PROCESS_MODE_DISABLED
	for layer: CanvasLayer in scene.find_children("*", "CanvasLayer", false, false):
		layer.visible = layer.name == &"PS1Filter"
	campus = scene.get_node("Campus") as Node3D
	library = campus.get_node("Library") as Node3D
	ps1.clear()
	real.clear()
	for node in library.find_children("*", "MeshInstance3D", true, false):
		var rel := String(library.get_path_to(node))
		if rel.begins_with("Counter/IronBar") or rel.begins_with("Real") or rel.begins_with("BackDoor/Hinge/LeafReal"):
			continue
		ps1.append(node as Node3D)
	for band in ["LibraryBand0", "LibraryBand1", "LibraryBand2"]:
		ps1.append(campus.get_node("Shells/%s/Mesh" % band) as Node3D)
	for rel in ["Real", "BackDoor/Hinge/LeafReal"]:
		real.append(library.get_node(rel) as Node3D)
	real.append(campus.get_node("StripLibrary") as Node3D)
	return scene


func _apply(after: bool) -> void:
	for node in ps1:
		node.visible = not after
	for node in real:
		node.visible = after


func _snap(file: String) -> void:
	for frame in range(24):
		await get_tree().process_frame
	await RenderingServer.frame_post_draw
	var image: Image = get_viewport().get_texture().get_image()
	image.save_jpg(OUTPUT + file, 0.86)
	print("CAPTURE: %s draws %d prims %d objects %d vram %d MB" % [file,
		int(Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME)),
		int(Performance.get_monitor(Performance.RENDER_TOTAL_PRIMITIVES_IN_FRAME)),
		int(Performance.get_monitor(Performance.RENDER_TOTAL_OBJECTS_IN_FRAME)),
		int(Performance.get_monitor(Performance.RENDER_VIDEO_MEM_USED) / 1048576.0)])
	count += 1


func _shoot(prefix: String, views: Dictionary, names: Array, torch_too: bool) -> void:
	camera.make_current()
	var door := library.get_node("BackDoor")
	for view_name: String in names:
		var view: Dictionary = views[view_name]
		var open: bool = view.get("open", false)
		if bool(door.get("is_open")) != open:
			door.call("set_open", open)
			await get_tree().create_timer(0.5).timeout
		camera.global_position = view.eye
		camera.look_at(view.target)
		camera.fov = view.get("fov", 75.0)
		var lits: Array = [false, true] if torch_too and view.get("torch", false) else [false]
		for lit: bool in lits:
			torch.visible = lit
			await _snap("%s_%s%s.jpg" % [prefix, view_name, "_torch" if lit else ""])
	if bool(door.get("is_open")):
		door.call("set_open", false)
		await get_tree().create_timer(0.5).timeout


func _camera() -> void:
	camera = Camera3D.new()
	add_child(camera)
	camera.make_current()
	camera.far = 4000.0
	camera.near = 0.05
	torch = SpotLight3D.new()
	torch.position = Vector3(0.1, -0.08, -0.15)
	torch.light_color = Color(0.9, 0.94, 1.0)
	torch.light_energy = 1.5
	torch.spot_range = 12.0
	torch.spot_angle = 28.0
	torch.shadow_enabled = true
	camera.add_child(torch)


func _pick(views: Dictionary, only: String) -> Array:
	var out: Array = []
	for name: String in views:
		if only.is_empty() or name in only.split(","):
			out.append(name)
	return out


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
	var only := _arg("views", "")
	var parts := _arg("parts", "ch4,ch3").split(",")
	_camera()
	if "ch4" in parts:
		var scene := await _load_chapter("res://scenes/main/chapter4.tscn", "Chapter4Director")
		print("T265_R2 %d PS1 meshes shown for before" % ps1.size())
		var names := _pick(VIEWS, only)
		for after: bool in [false, true]:
			_apply(after)
			await _shoot("after" if after else "before", VIEWS, names, true)
		_apply(true)
		get_tree().root.use_occlusion_culling = false
		await _shoot("occl_off", VIEWS, _pick(VIEWS, ",".join(OCCLUSION_VIEWS) if only.is_empty() else only).filter(func(n): return n in OCCLUSION_VIEWS), false)
		get_tree().root.use_occlusion_culling = true
		scene.queue_free()
		for frame in range(6):
			await get_tree().process_frame
	if "ch3" in parts:
		var scene := await _load_chapter("res://scenes/main/chapter3.tscn", "Chapter3Director")
		for after: bool in [false, true]:
			_apply(after)
			await _shoot("ch3_after" if after else "ch3_before", CH3_VIEWS, _pick(CH3_VIEWS, ""), false)
		scene.queue_free()
	print("RESULT: t265 round 2 capture %d images" % count)
	App.quit()
