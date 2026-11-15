extends Node3D
## T-263 round 2 stills: before and after, same cameras, in chapter 3's real scene (night as the chapter opens, the
## canteen horde's six idle points filled by the horde's own place_idle, TV off and on) and chapter 4's (the west exit
## from Start_split and from inside). "after" is the branch's scenes as they load; "before" puts main back at run time:
## every PS1 mesh and label of the canteen and its west exit shown, the Real layer, the lit screen and StripCanteen
## hidden, the 18 replaced props.tscn pieces given main's transforms (w6_ps1_props.json). Director held, HUD and player
## hidden, sound muted; no light added (the torch is the camera's, as in waves 4-6).
## Copy this file to game/_probe_tmp/ with a scene whose root has it, then (one Godot at a time, Lượt Godot):
##   godot --path game res://_probe_tmp/capture_wave6_r2.tscn -- [--states=before,after] [--views=door,...]
## Writes art_source/graphics_upgrade/realistic_map/previews/wave6/<state>_<view>[_tv][_torch].jpg (1920 x 1080) and
## prints draw calls, primitives, objects and video memory per shot.
const OUTPUT := "res://../art_source/graphics_upgrade/realistic_map/previews/wave6/"
const PS1_PROPS := "res://../art_source/graphics_upgrade/realistic_map/wave6/w6_ps1_props.json"
const RESOLUTION := Vector2i(1920, 1080)
# torch: also shot with the torch on; tv: also shot with the TV on.
const CH3_VIEWS := {
	"door": {"eye": Vector3(190, -8.3, 20.8), "target": Vector3(180, -8.6, 36), "torch": false, "tv": true},
	"tv": {"eye": Vector3(177.5, -8.3, 34.2), "target": Vector3(170.3, -7.6, 32), "torch": true, "tv": true},
	"counter": {"eye": Vector3(180.5, -8.3, 38.6), "target": Vector3(176.5, -8.7, 42.6), "torch": true},
	"counter_out": {"eye": Vector3(184, -8.3, 40.2), "target": Vector3(192, -8.4, 20), "torch": false},
	"tables": {"eye": Vector3(172.6, -8.3, 29.8), "target": Vector3(184, -9.0, 26.5), "torch": true},
	"east": {"eye": Vector3(201.5, -8.3, 31.5), "target": Vector3(209.6, -8.4, 32.5), "torch": true},
	"kitchen": {"eye": Vector3(192, -8.3, 44.6), "target": Vector3(192, -7.7, 51.8), "torch": true},
	"store": {"eye": Vector3(202, -8.3, 44.4), "target": Vector3(202.5, -8.6, 51.5), "torch": true},
	"store_side": {"eye": Vector3(201.5, -8.3, 50.8), "target": Vector3(208.6, -8.7, 46.5), "torch": true},
	"back_door": {"eye": Vector3(202.5, -8.3, 59.0), "target": Vector3(201.5, -8.4, 52), "torch": true},
	"facade": {"eye": Vector3(190, -8.3, 8.0), "target": Vector3(190, -6.8, 20), "torch": false},
	"facade_side": {"eye": Vector3(176.5, -8.3, 12.5), "target": Vector3(186, -7.0, 20), "torch": true},
	"strip_east": {"eye": Vector3(216.5, -8.3, 14.0), "target": Vector3(211, -8.9, 40), "torch": false},
	"strip_back": {"eye": Vector3(173.5, -8.3, 58.5), "target": Vector3(200, -8.7, 51), "torch": false},
	"strip_west": {"eye": Vector3(167.2, -8.3, 14.5), "target": Vector3(169.5, -8.4, 36), "torch": false},
}
const CH4_VIEWS := {
	"ch4_split": {"eye": Vector3(166.2, -8.3, 40.5), "target": Vector3(172, -8.4, 40.5), "torch": true},
	"ch4_exit_in": {"eye": Vector3(176.5, -8.3, 37.8), "target": Vector3(170, -8.4, 40.5), "torch": true},
	"ch4_wall": {"eye": Vector3(164.5, -8.2, 47.5), "target": Vector3(170, -8.0, 33), "torch": false},
}

var camera: Camera3D
var torch: SpotLight3D
var campus: Node3D
var canteen: Node3D
var ps1: Array[Node3D] = []
var main_props := {}


func _ready() -> void:
	call_deferred("_run")


func _arg(name: String, fallback: String) -> String:
	for argument: String in OS.get_cmdline_user_args():
		if argument.begins_with("--%s=" % name):
			return argument.trim_prefix("--%s=" % name)
	return fallback


func _added(path: String) -> bool:
	return path == "Real" or path.begins_with("Real/") or path.begins_with("TV/Screen/Lit")


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
	canteen = campus.get_node("Canteen") as Node3D
	ps1.clear()
	for node in canteen.find_children("*", "", true, false):
		if (node is MeshInstance3D or node is Label3D) and not _added(String(canteen.get_path_to(node))):
			ps1.append(node as Node3D)
	return scene


func _set_state(before: bool) -> void:
	for node in ps1:
		node.visible = before
	(canteen.get_node("Real") as Node3D).visible = not before
	(canteen.get_node("TV/Screen/Lit") as Node3D).visible = not before
	(campus.get_node("StripCanteen") as Node3D).visible = not before
	# props.tscn: the replaced pieces back to main's transforms, or scaled to 0 again.
	for chunk_name: String in main_props:
		var entry: Dictionary = main_props[chunk_name]
		var chunk := campus.get_node("Props/%s/%s" % [entry.parent, chunk_name])
		var multi := (chunk.find_children("*", "MultiMeshInstance3D", false, false)[0] as MultiMeshInstance3D).multimesh
		var data: Array = entry.data
		var now: PackedFloat32Array = chunk.get("data")
		for i in multi.instance_count:
			var o := i * 16
			var source: Array = data if before else Array(now)
			var basis := Basis(Vector3(source[o], source[o + 1], source[o + 2]), Vector3(source[o + 3], source[o + 4], source[o + 5]),
				Vector3(source[o + 6], source[o + 7], source[o + 8]))
			multi.set_instance_transform(i, Transform3D(basis, Vector3(source[o + 9], source[o + 10], source[o + 11])))


func _shoot(state: String, views: Dictionary, only: String) -> int:
	camera.make_current()   # the chapter's player camera took over when the chapter was added
	var count := 0
	for view_name: String in views:
		if not only.is_empty() and not view_name in only.split(","):
			continue
		var view: Dictionary = views[view_name]
		camera.global_position = view.eye
		camera.look_at(view.target)
		camera.fov = view.get("fov", 75.0)
		var tvs: Array = [false, true] if view.get("tv", false) else [false]
		for tv_on: bool in tvs:
			campus.call("set_canteen_tv", tv_on)
			var lits: Array = [false, true] if view.torch and not tv_on else [false]
			for lit: bool in lits:
				torch.visible = lit
				for frame in range(24):
					await get_tree().process_frame
				await RenderingServer.frame_post_draw
				var image: Image = get_viewport().get_texture().get_image()
				var file := "%s_%s%s%s.jpg" % [state, view_name, "_tv" if tv_on else "", "_torch" if lit else ""]
				image.save_jpg(OUTPUT + file, 0.88)
				print("CAPTURE: %s draws %d prims %d objects %d vram %d MB" % [file,
					int(Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME)),
					int(Performance.get_monitor(Performance.RENDER_TOTAL_PRIMITIVES_IN_FRAME)),
					int(Performance.get_monitor(Performance.RENDER_TOTAL_OBJECTS_IN_FRAME)),
					int(Performance.get_monitor(Performance.RENDER_VIDEO_MEM_USED) / 1048576.0)])
				count += 1
	campus.call("set_canteen_tv", false)
	return count


func _camera() -> void:
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
	main_props = JSON.parse_string(FileAccess.get_file_as_string(PS1_PROPS))
	var only := _arg("views", "")
	var states := _arg("states", "before,after").split(",")
	var count := 0
	_camera()
	var scene := await _load_chapter("res://scenes/main/chapter3.tscn", "Chapter3Director")
	var horde: Node = scene.get_node("Chapter3Director").get("_horde")
	if horde != null:
		horde.call("place_idle", &"Canteen")
	print("T263_PS1 %d meshes and labels; zombies %d" % [ps1.size(), (horde.get("_zones") as Dictionary).get(&"Canteen", []).size() if horde != null else 0])
	for state: String in states:
		_set_state(state == "before")
		count += await _shoot(state, CH3_VIEWS, only)
	scene.queue_free()
	for frame in range(4):
		await get_tree().process_frame
	scene = await _load_chapter("res://scenes/main/chapter4.tscn", "Chapter4Director")
	for state: String in states:
		_set_state(state == "before")
		count += await _shoot(state, CH4_VIEWS, only)
	print("RESULT: t263 round 2 capture %d images" % count)
	App.quit()
