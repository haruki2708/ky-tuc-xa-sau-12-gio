extends Node3D
## T-264 round 3 stills: the chapter's real scene as patched (after) and, at run time only, as main had it (before: main's
## props.tscn hung in place of the patched one, the PS1 tiles, roads, fences, benches, mopeds, tree and lamp shapes shown
## again, StripRest hidden, the floor-4 balconies' old outside colour). Night as the chapter opens, same cameras before and
## after, with and without the torch (the phone's: 12 m, 28 degrees). No light added but the torch. Director held, HUD and
## player hidden, sound muted.
## Copy this file and main's props.tscn (git show origin/main:game/scenes/levels/campus/props.tscn) to game/_probe_tmp/
## (props_main.tscn) with a scene whose root has this script, then (one Godot at a time, Lượt Godot):
##   godot --path game res://_probe_tmp/capture_wave7_r3.tscn [-- --chapter=4] [--shots=prefix,...]
## Writes art_source/graphics_upgrade/realistic_map/previews/wave7/r3_<shot>.jpg (1920 x 1080), prints draws per shot.
const OUTPUT := "res://../art_source/graphics_upgrade/realistic_map/previews/wave7/"
const RESOLUTION := Vector2i(1920, 1080)
const VIEWS := {
	"w_corridor4": [Vector3(37, 1.62, 3.3), Vector3(22, -4.0, 40)],
	"w_garden": [Vector3(22, -8.2, 26), Vector3(60, -6.0, 62)],
	"w_stand": [Vector3(200, -4.0, 222), Vector3(200, -7.5, 160)],
	"road": [Vector3(125, -8.3, -16.2), Vector3(160, -8.4, -12.5)],
	"road_props": [Vector3(152, -8.2, -13.5), Vector3(140, -9.0, -21.5)],
	"road_west": [Vector3(45, -8.2, -15.5), Vector3(85, -8.6, -22)],
	"trees_b": [Vector3(-2, -8.2, -24), Vector3(-14, -4.0, -10)],
	"shelter": [Vector3(32, -8.2, -18.5), Vector3(30, -8.4, -27)],
	"kiosk": [Vector3(213, -8.2, 9.5), Vector3(219, -8.5, 17)],
	"east_branch": [Vector3(310, -8.2, 40), Vector3(310, -8.5, 120)],
	"north_loop": [Vector3(140, -8.2, 250), Vector3(220, -8.5, 246)],
	"fence_w": [Vector3(-74.5, -8.3, 99), Vector3(-80, -8.0, 115)],
	"fence_n": [Vector3(100, -8.2, 283), Vector3(125, -8.2, 290)],
	"lecture_fc": [Vector3(-10, -8.2, 160), Vector3(-10, -7.0, 180)],
	"gym_fc": [Vector3(-22, -8.2, 70), Vector3(-30, -7.5, 90)],
	"b_back": [Vector3(19, -8.3, -16.5), Vector3(23, 1.0, -7.7)],
}
const CH4_VIEWS := {
	"ch4_lecture": [Vector3(-10, -8.2, 160), Vector3(-10, -7.0, 180)],
	"ch4_library_way": [Vector3(15, -8.2, 168), Vector3(55, -8.0, 196)],
}

var camera: Camera3D
var torch: SpotLight3D
var campus: Node3D
var ps1: Array[Node3D] = []         # hidden in the scene, shown for "before"
var props_main: Node3D
var balcony_before := {}
var balcony_after := {}


func _ready() -> void:
	call_deferred("_run")


func _arg(name: String, fallback: String) -> String:
	for argument: String in OS.get_cmdline_user_args():
		if argument.begins_with("--%s=" % name):
			return argument.trim_prefix("--%s=" % name)
	return fallback


func _shots(views: Dictionary) -> Array:
	var out: Array = []
	for view: String in views:
		out.append(["before_" + view, view, false, false])
		out.append(["after_" + view, view, true, false])
	for view in ["road_props", "fence_w", "shelter", "trees_b"]:
		if views.has(view):
			out.append(["after_%s_torch" % view, view, true, true])
	return out


func _collect() -> void:
	# Only what this round hid (WestBranch, StadiumWestAccess and Fence/S were hidden by earlier waves).
	for tile in campus.get_node("Ground").get_children():
		if not (tile.get_node("Mesh") as Node3D).visible:
			ps1.append(tile.get_node("Mesh"))
	for path in ["Road/Avenue/Mesh", "Road/EastBranch/Mesh", "Road/StadiumEastAccess/Mesh", "Fence/N/Mesh", "Fence/E/Mesh", "Fence/W/Mesh",
			"Road/RoadBench0", "Road/RoadBench1", "Road/RoadBench2", "Road/FallenMoped0", "Road/FallenMoped1", "Road/FallenMoped2"]:
		ps1.append(campus.get_node(path))
	for path in ["Props/Trees"]:
		for cluster in campus.get_node(path).get_children():
			for child in cluster.get_children():
				if child is MultiMeshInstance3D and not (child as Node3D).visible:
					ps1.append(child)
	props_main = (load("res://_probe_tmp/props_main.tscn") as PackedScene).instantiate() as Node3D
	campus.add_child(props_main)
	props_main.transform = (campus.get_node("Props") as Node3D).transform
	# The balconies: rooms 401-408 (F4Exterior) and room 407 (its ShellExterior look), old and new parameters.
	var exterior := load("res://assets/models/graphics_pilot/floor4_rooms/materials/F4Exterior.tres") as ShaderMaterial
	balcony_after = {"m": exterior, "base_albedo": exterior.get_shader_parameter("base_albedo"),
		"base_normal": exterior.get_shader_parameter("base_normal"), "base_arm": exterior.get_shader_parameter("base_arm"),
		"base_tint": exterior.get_shader_parameter("base_tint")}
	var shell := "res://assets/textures/graphics_pilot/room407_shell/plastered_wall_02_"
	balcony_before = {"m": exterior, "base_albedo": load(shell + "color.jpg"), "base_normal": load(shell + "normal.jpg"),
		"base_arm": load(shell + "arm.jpg"), "base_tint": Color(1.0, 0.9, 0.66)}
	print("T264_R3 %d PS1 nodes to show for before" % ps1.size())


func _apply(after: bool) -> void:
	for node in ps1:
		node.visible = not after
	(campus.get_node("StripRest") as Node3D).visible = after
	(campus.get_node("Props") as Node3D).visible = after
	props_main.visible = not after
	var look: Dictionary = balcony_after if after else balcony_before
	for key in ["base_albedo", "base_normal", "base_arm", "base_tint"]:
		(look.m as ShaderMaterial).set_shader_parameter(key, look[key])
	var furnish := load("res://scenes/levels/room407/room407_furnish.gd")
	var shell407: ShaderMaterial = furnish.shell_material("ShellExterior")
	for key in ["base_albedo", "base_normal", "base_arm", "base_tint"]:
		shell407.set_shader_parameter(key, look[key])


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
	campus = scene.get_node("Campus") as Node3D
	# The PS1 shapes of the tree and lamp clusters were hidden by StripRest on load: show them for "before".
	for cluster in campus.get_node("Road").get_children():
		for child in cluster.get_children():
			if child is MultiMeshInstance3D and not (child as Node3D).visible:
				ps1.append(child)
	_collect()
	var views := VIEWS if chapter == "3" else CH4_VIEWS
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
	for shot: Array in _shots(views):
		if not only.is_empty():
			var keep := false
			for prefix in only.split(","):
				keep = keep or String(shot[0]).begins_with(prefix)
			if not keep:
				continue
		_apply(shot[2])
		var view: Array = views[shot[1]]
		camera.make_current()
		camera.global_position = view[0]
		camera.look_at(view[1])
		camera.fov = 75.0
		torch.visible = shot[3]
		for frame in range(24):
			await get_tree().process_frame
		await RenderingServer.frame_post_draw
		var image: Image = get_viewport().get_texture().get_image()
		image.save_jpg(OUTPUT + "r3_%s.jpg" % shot[0], 0.88)
		print("CAPTURE: %s draws %d prims %d objects %d vram %d MB" % [shot[0],
			RenderingServer.get_rendering_info(RenderingServer.RENDERING_INFO_TOTAL_DRAW_CALLS_IN_FRAME),
			RenderingServer.get_rendering_info(RenderingServer.RENDERING_INFO_TOTAL_PRIMITIVES_IN_FRAME),
			RenderingServer.get_rendering_info(RenderingServer.RENDERING_INFO_TOTAL_OBJECTS_IN_FRAME),
			int(RenderingServer.get_rendering_info(RenderingServer.RENDERING_INFO_VIDEO_MEM_USED) / 1048576.0)])
		count += 1
	print("RESULT: t264 round 3 capture %d images" % count)
	App.quit()
