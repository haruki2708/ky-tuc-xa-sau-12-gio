extends Node3D
## T-264 round 1 stills: the pilot hung in chapter 3's real scene at run time (no scene file changes), night as the
## chapter opens, same cameras across options, with and without the torch, near and far, occlusion culling on (the
## chapter's own occluders, whose three shell boxes fill each building) and off. The PS1 pieces the pilot covers are
## hidden here only (visible = false; colliders stay): building A's and the gym's shell meshes, windows, bands, doors,
## the three window silhouettes; building B's UpperFloor5/6 meshes and upper windows; four PS1 trees and three lamps of
## the Avenue (their MultiMesh instances scaled to 0), RoadBench2, FallenMoped1; Fence/W's mesh. No light is added (the
## torch is the camera's). Director held, HUD and player hidden, sound muted.
## Copy this file to game/_probe_tmp/ with a scene whose root has it, then (one Godot at a time, Lượt Godot):
##   godot --path game res://_probe_tmp/capture_wave7.tscn [-- --shots=prefix,...]
## Writes art_source/graphics_upgrade/realistic_map/previews/wave7/pilot_<shot>.jpg (1920 x 1080), prints draws per shot.
const OUTPUT := "res://../art_source/graphics_upgrade/realistic_map/previews/wave7/"
const W7 := "res://assets/models/graphics_pilot/realistic_map/wave7/"
const MATS := W7 + "materials/"
const RESOLUTION := Vector2i(1920, 1080)
const G := -9.9
const TREES := [[Vector3(120, G, -7), "bang", 20.0], [Vector3(136, G, -7), "phuong", 70.0], [Vector3(152, G, -7), "xacu", 140.0],
	[Vector3(168, G, -7), "bang", 250.0]]
const LAMPS := [Vector3(120, G, -20), Vector3(140, G, -20), Vector3(160, G, -20)]
const VIEWS := {
	"a_garden": [Vector3(22, -8.2, 30), Vector3(22, -2.5, 54)],
	"a_foot": [Vector3(18.0, -8.3, 49.0), Vector3(21.5, -6.6, 54)],
	"a_window": [Vector3(15.5, -8.2, 46.0), Vector3(18.0, -1.6, 54)],
	"a_corridor4": [Vector3(20, 1.62, 3.3), Vector3(20, 0.0, 54)],
	"gym_corner": [Vector3(12, -8.2, 76), Vector3(-14, -5.0, 92)],
	"gym_door": [Vector3(-27.5, -8.3, 82.5), Vector3(-30, -7.2, 90)],
	"b_upper": [Vector3(22, -8.2, 27), Vector3(22, 4.6, 4)],
	"b_back": [Vector3(19, -8.3, -16.5), Vector3(23, -5.5, -7.7)],
	"road": [Vector3(125, -8.3, -16.2), Vector3(160, -8.4, -12.5)],
	"road_trees": [Vector3(146, -8.3, -13.5), Vector3(136, -5.0, -7)],
	"road_lamp": [Vector3(154, -8.3, -15.5), Vector3(145, -8.4, -21)],
	"fence": [Vector3(-74.5, -8.3, 99), Vector3(-80, -8.0, 115)],
	"w_corridor4": [Vector3(22, 1.62, 3.3), Vector3(22, -4.0, 40)],
	"w_garden": [Vector3(22, -8.2, 26), Vector3(60, -6.0, 62)],
	"w_stand": [Vector3(200, -4.0, 222), Vector3(200, -7.5, 160)],
}
# [shot name, view, torch, state]. State keys: pilot (bool), a (wall/gallery), interior (a/b/c), wall (yellow/grey),
# gym (r1/r2), road (asphalt/slab), verge (grass/pavers), lamp (steel/concrete), fence (w1/b40), b (fake/dark), occ (bool).
const BASE := {"pilot": true, "a": "wall", "interior": "b", "wall": "yellow", "gym": "r1", "road": "asphalt", "verge": "grass",
	"lamp": "steel", "fence": "w1", "b": "fake", "occ": true}

var camera: Camera3D
var torch: SpotLight3D
var campus: Node3D
var pilot := {}
var ps1: Array[Node3D] = []
var hidden_instances: Array = []   # [MultiMesh, index, Transform3D]


func _ready() -> void:
	call_deferred("_run")


func _arg(name: String, fallback: String) -> String:
	for argument: String in OS.get_cmdline_user_args():
		if argument.begins_with("--%s=" % name):
			return argument.trim_prefix("--%s=" % name)
	return fallback


func _shots() -> Array:
	var out: Array = []
	for view in ["a_garden", "a_foot", "a_window", "a_corridor4", "gym_corner", "gym_door", "b_upper", "b_back", "road", "road_trees",
			"road_lamp", "fence", "w_corridor4", "w_garden", "w_stand"]:
		out.append(["before_" + view, view, false, {"pilot": false, "occ": true}])
	for interior in ["a", "b", "c"]:
		for view in ["a_garden", "a_foot", "a_window", "a_corridor4"]:
			out.append(["interior_%s_%s" % [interior, view], view, false, {"interior": interior}])
		out.append(["interior_%s_a_foot_torch" % interior, "a_foot", true, {"interior": interior}])
		for view in ["a_foot", "a_corridor4"]:
			out.append(["interior_%s_%s_occoff" % [interior, view], view, false, {"interior": interior, "occ": false}])
	for view in ["a_garden", "a_foot", "a_corridor4"]:
		out.append(["gallery_%s" % view, view, false, {"a": "gallery"}])
		out.append(["gallery_%s_occoff" % view, view, false, {"a": "gallery", "occ": false}])
	for view in ["a_garden", "gym_corner"]:
		out.append(["grey_%s" % view, view, false, {"wall": "grey"}])
	for roof in ["r1", "r2"]:
		out.append(["gym_%s_gym_corner" % roof, "gym_corner", false, {"gym": roof}])
		out.append(["gym_%s_gym_door_torch" % roof, "gym_door", true, {"gym": roof}])
		out.append(["gym_%s_gym_door_occoff" % roof, "gym_door", false, {"gym": roof, "occ": false}])
	for b in ["fake", "dark"]:
		out.append(["b_%s_b_upper" % b, "b_upper", false, {"b": b}])
		out.append(["b_%s_b_upper_occoff" % b, "b_upper", false, {"b": b, "occ": false}])
		out.append(["b_%s_b_back_torch" % b, "b_back", true, {"b": b}])
	for combo in [["asphalt", "grass", "steel"], ["slab", "pavers", "concrete"]]:
		for view in ["road", "road_trees", "road_lamp"]:
			out.append(["ground_%s_%s" % [combo[0], view], view, false, {"road": combo[0], "verge": combo[1], "lamp": combo[2]}])
		out.append(["ground_%s_road_trees_torch" % combo[0], "road_trees", true, {"road": combo[0], "verge": combo[1], "lamp": combo[2]}])
	for fence in ["w1", "b40"]:
		out.append(["fence_%s" % fence, "fence", false, {"fence": fence}])
		out.append(["fence_%s_torch" % fence, "fence", true, {"fence": fence}])
	for view in ["w_corridor4", "w_garden", "w_stand"]:
		out.append(["after_" + view, view, false, {}])
	return out


func _instance(file: String, at: Vector3 = Vector3(0, G, 0), yaw: float = 0.0) -> Node3D:
	var node := (load(W7 + file) as PackedScene).instantiate() as Node3D
	campus.add_child(node)
	node.global_transform = Transform3D(Basis(Vector3.UP, deg_to_rad(yaw)), at)
	return node


func _hide(path: String) -> void:
	var node := campus.get_node_or_null(path) as Node3D
	if node == null:
		push_error("no " + path)
		return
	ps1.append(node)


func _zero_points(cluster: String, points: Array) -> void:
	var node := campus.get_node(cluster)
	var pts: PackedVector3Array = node.get("points")
	for child in node.get_children():
		if not child is MultiMeshInstance3D:
			continue
		var multi := (child as MultiMeshInstance3D).multimesh
		for i in pts.size():
			for p: Vector3 in points:
				if Vector2(pts[i].x - p.x, pts[i].z - p.z).length() < 0.5:
					hidden_instances.append([multi, i, multi.get_instance_transform(i)])


func _collect_ps1() -> void:
	for path in ["Shells/BuildingA/Shell/Mesh", "Shells/BuildingA/LockedDoor", "Shells/Gym/Shell/Mesh", "Shells/Gym/LockedDoor",
			"Shells/GymBand0", "BuildingB/UpperFloor5/Mesh", "BuildingB/UpperFloor6/Mesh", "Road/RoadBench2", "Road/FallenMoped1", "Fence/W/Mesh"]:
		_hide(path)
	for k in 6:
		_hide("Shells/ABand%d" % k)
	for k in 3:
		_hide("Shells/WindowSilhouette%d" % k)
	for child in campus.get_node("Shells/BuildingA").get_children():
		if String(child.name).begins_with("Window"):
			ps1.append(child as Node3D)
	for child in campus.get_node("Shells/Gym").get_children():
		if String(child.name).begins_with("Window"):
			ps1.append(child as Node3D)
	for child in campus.get_node("BuildingB").get_children():
		if String(child.name).begins_with("UpperWindow"):
			ps1.append(child as Node3D)
	var tree_points: Array = []
	for t: Array in TREES:
		tree_points.append(t[0])
	for cluster in ["Road/Trees_3_-1", "Road/Trees_4_-1"]:
		_zero_points(cluster, tree_points)
	for cluster in ["Road/StreetLights_3_-1", "Road/StreetLights_4_-1"]:
		_zero_points(cluster, LAMPS)
	print("T264_PS1 %d nodes hidden in the pilot, %d MultiMesh instances" % [ps1.size(), hidden_instances.size()])


func _build_pilot() -> void:
	for key in ["bldga_wall", "bldga_gallery", "gym_r1", "gym_r2", "b_outside", "road_asphalt", "road_slab", "verge_grass", "verge_pavers",
			"lamp_steel", "lamp_concrete", "bench", "moped", "fence_w1", "fence_b40"]:
		pilot[key] = _instance(key + ".glb")
	var trees: Array[Node3D] = []
	for t: Array in TREES:
		trees.append(_instance("tree_%s.glb" % t[1], t[0], t[2]))
	pilot["trees"] = trees
	for node: Node3D in [pilot.verge_grass, pilot.verge_pavers, pilot.road_asphalt, pilot.road_slab]:
		for mesh: MeshInstance3D in node.find_children("*", "MeshInstance3D", true, false):
			mesh.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	for tree: Node3D in trees:
		for mesh: MeshInstance3D in tree.find_children("Leaves", "MeshInstance3D", true, false):
			mesh.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	for key in ["bldga_wall", "bldga_gallery", "gym_r1", "gym_r2", "b_outside"]:
		for mesh: MeshInstance3D in (pilot[key] as Node3D).find_children("*", "MeshInstance3D", true, false):
			var n := String(mesh.name)
			if n.begins_with("Fake") or n.begins_with("Glass") or n.begins_with("Curtains") or n in ["Void", "RealRooms", "Lobby", "Silhouette", "Extras"]:
				mesh.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
			if n.begins_with("Fake") or n.begins_with("Curtains") or n in ["RealRooms", "Lobby"]:
				mesh.visibility_range_end = 40.0


func _show_meshes(node: Node3D, names: Array) -> void:
	node.visible = true
	for mesh: MeshInstance3D in node.find_children("*", "MeshInstance3D", true, false):
		var n := String(mesh.name)
		var fill := n.begins_with("Glass") or n.begins_with("Curtains") or n.begins_with("Fake") or n in ["Void", "RealRooms", "Lobby"]
		mesh.visible = (not fill) or n in names


func _swap(node: Node3D, from: String, to: String) -> void:
	for mesh: MeshInstance3D in node.find_children("*", "MeshInstance3D", true, false):
		for i in mesh.mesh.get_surface_count():
			var m := mesh.mesh.surface_get_material(i)
			var name := m.resource_name if m != null else ""
			mesh.set_surface_override_material(i, load(MATS + to + ".tres") if name == from and to != from else null)


func _apply(state: Dictionary) -> void:
	var s := BASE.duplicate()
	s.merge(state, true)
	get_tree().root.use_occlusion_culling = s.occ
	var on: bool = s.pilot
	for node in ps1:
		node.visible = not on
	for entry: Array in hidden_instances:
		(entry[0] as MultiMesh).set_instance_transform(entry[1], Transform3D(Basis.from_scale(Vector3.ZERO), Vector3.ZERO) if on else entry[2])
	for key in pilot:
		if key == "trees":
			for tree: Node3D in pilot.trees:
				tree.visible = on
		else:
			(pilot[key] as Node3D).visible = false
	if not on:
		return
	var fills := {"a": ["GlassClearGround", "RealRooms", "Lobby", "GlassDarkUpper", "CurtainsUpper", "Void"],
		"b": ["GlassClearGround", "GlassClearUpper", "FakeGround", "FakeUpper", "Void"],
		"c": ["Lobby", "GlassDarkGround", "GlassDarkUpper", "CurtainsGround", "CurtainsUpper", "Void"]}
	var a: Node3D = pilot["bldga_" + s.a]
	_show_meshes(a, fills[s.interior])
	_show_meshes(pilot["gym_" + s.gym], fills[s.interior])
	_show_meshes(pilot.b_outside, ["FakeUpper", "GlassClearUpper", "Void"] if s.b == "fake" else ["GlassDarkUpper", "CurtainsUpper", "Void"])
	var colour := "W7WallYellow" if s.wall == "yellow" else "W7WallGrey"
	for node: Node3D in [a, pilot["gym_" + s.gym]]:
		_swap(node, "W7WallYellow", colour)
	for key in ["road_" + s.road, "verge_" + s.verge, "lamp_" + s.lamp, "fence_" + s.fence, "bench", "moped"]:
		(pilot[key] as Node3D).visible = true


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
	campus = scene.get_node("Campus") as Node3D
	_collect_ps1()
	_build_pilot()
	camera = Camera3D.new()
	add_child(camera)
	camera.make_current()
	camera.far = 4000.0
	torch = SpotLight3D.new()
	torch.position = Vector3(0.1, -0.08, -0.15)
	torch.light_color = Color(0.9, 0.94, 1.0)
	torch.light_energy = 1.5
	torch.spot_range = 14.0
	torch.spot_angle = 28.0
	torch.shadow_enabled = true
	camera.add_child(torch)
	var only := _arg("shots", "")
	var count := 0
	for shot: Array in _shots():
		if not only.is_empty():
			var keep := false
			for prefix in only.split(","):
				keep = keep or String(shot[0]).begins_with(prefix)
			if not keep:
				continue
		_apply(shot[3])
		var view: Array = VIEWS[shot[1]]
		camera.make_current()
		camera.global_position = view[0]
		camera.look_at(view[1])
		camera.fov = 75.0
		torch.visible = shot[2]
		for frame in range(20):
			await get_tree().process_frame
		await RenderingServer.frame_post_draw
		var image: Image = get_viewport().get_texture().get_image()
		image.save_jpg(OUTPUT + "pilot_%s.jpg" % shot[0], 0.88)
		print("CAPTURE: %s draws %d prims %d objects %d vram %d MB" % [shot[0],
			RenderingServer.get_rendering_info(RenderingServer.RENDERING_INFO_TOTAL_DRAW_CALLS_IN_FRAME),
			RenderingServer.get_rendering_info(RenderingServer.RENDERING_INFO_TOTAL_PRIMITIVES_IN_FRAME),
			RenderingServer.get_rendering_info(RenderingServer.RENDERING_INFO_TOTAL_OBJECTS_IN_FRAME),
			int(RenderingServer.get_rendering_info(RenderingServer.RENDERING_INFO_VIDEO_MEM_USED) / 1048576.0)])
		count += 1
	print("RESULT: t264 pilot capture %d images" % count)
	App.quit()
