extends Node3D
## T-262 round 1 stills: the gate pilot put into chapter 3's real scene at run time, one option set at a time, same
## cameras, night as the chapter opens, the twelve guards standing where the director puts them (_place_guards in its
## _ready). gate.tscn, campus.tscn and props.tscn are not changed in round 1: this script hides the PS1 meshes the pilot
## replaces (visible = false; the two barriers' and the cones' MultiMesh instances scaled to 0; Fence/S/Mesh swapped
## for two PS1 boxes either side of the pilot's wall section x 186..262) and hangs the wave-5 glbs under Campus/Gate.
## Director held, HUD and player hidden, sound muted. No light is added (the torch is the camera's, as in wave 4).
## Copy this file to game/_probe_tmp/ with a scene whose root has it, then (one Godot at a time, Lượt Godot):
##   godot --path game res://_probe_tmp/capture_wave5.tscn -- --configs=before,a,b,c,d [--views=start,...]
## Writes art_source/graphics_upgrade/realistic_map/previews/wave5/pilot_<config>_<view>[_torch].jpg (1920 x 1080) and
## prints draw calls, primitives, objects and video memory per shot.
const OUTPUT := "res://../art_source/graphics_upgrade/realistic_map/previews/wave5/"
const A16_LIST := "res://../art_source/graphics_upgrade/realistic_map/wave5/a16_box_nodes.json"
const W5 := "res://assets/models/graphics_pilot/realistic_map/wave5/"
const RESOLUTION := Vector2i(1920, 1080)
const G := -9.9
const WALL_SECTION := Vector2(186.0, 262.0)
const BARRIERS := [Vector3(213.0, -49.5, 8.0), Vector3(227.0, -49.5, -6.0)]
# torch: shots with the torch on (always also one without).
const VIEWS := {
	"start": {"eye": Vector3(220, -8.3, -25), "target": Vector3(220, -7.4, -57), "torch": false},
	"approach": {"eye": Vector3(205, -8.3, -16), "target": Vector3(229, -8.2, -55), "torch": false},
	"pillar_west": {"eye": Vector3(203.5, -8.3, -49.5), "target": Vector3(209.5, -6.2, -58.6), "torch": true},
	"sign": {"eye": Vector3(219, -8.3, -46), "target": Vector3(217.5, -5.4, -59), "torch": true},
	"barrier": {"eye": Vector3(209.5, -8.3, -43.5), "target": Vector3(214, -9.3, -49.5), "torch": true},
	"booth": {"eye": Vector3(233.5, -8.3, -45), "target": Vector3(240, -8.2, -53.8), "torch": true},
	"booth_window": {"eye": Vector3(240.4, -8.15, -50.5), "target": Vector3(240.1, -9.0, -53.3), "torch": true},
	"wall_east": {"eye": Vector3(252, -8.3, -51.5), "target": Vector3(238, -8.4, -59.8), "torch": true},
	"wall_west": {"eye": Vector3(191, -8.3, -51), "target": Vector3(206, -8.3, -59.8), "torch": true},
	"court": {"eye": Vector3(226, -8.4, -39), "target": Vector3(219, -9.9, -50), "torch": true},
	"gate_out": {"eye": Vector3(220.5, -8.3, -43), "target": Vector3(220, -8.3, -72), "torch": false},
}
const CONFIGS := {
	"before": {},
	"a": {"court": "Pavers", "pillars": "plaster", "gate": "swing", "sign": "arch", "text": true, "booth": "masonry", "wall": "plaster"},
	"b": {"court": "Asphalt", "pillars": "brick", "gate": "folding", "sign": "band", "text": true, "booth": "prefab", "wall": "brick"},
	"c": {"court": "Pavers", "pillars": "plaster", "gate": "swing", "sign": "arch", "text": false, "booth": "masonry", "wall": "plaster"},
	"d": {"court": "Asphalt", "pillars": "brick", "gate": "folding", "sign": "band", "text": false, "booth": "prefab", "wall": "brick"},
}
const SIGN_VIEWS := ["start", "pillar_west", "sign"]  # c and d (the "no text" signs) are shot here only

var camera: Camera3D
var torch: SpotLight3D
var campus: Node3D
var gate: Node3D
var ps1_nodes: Array[Node3D] = []
var ps1_instances: Array = []  # [MultiMesh, index, original Transform3D]
var fence_mesh: MeshInstance3D
var fence_split: Array[MeshInstance3D] = []
var pilot := {}
var cone_xforms: Array[Transform3D] = []


func _ready() -> void:
	call_deferred("_run")


func _arg(name: String, fallback: String) -> String:
	for argument: String in OS.get_cmdline_user_args():
		if argument.begins_with("--%s=" % name):
			return argument.trim_prefix("--%s=" % name)
	return fallback


func _instance(path: String, xform: Transform3D = Transform3D(Basis.IDENTITY, Vector3(0, G, 0))) -> Node3D:
	var node := (load(W5 + path) as PackedScene).instantiate() as Node3D
	gate.add_child(node)
	node.transform = xform
	node.visible = false
	return node


func _surface(node: Node3D, material_name: String) -> Array:
	for mesh: MeshInstance3D in node.find_children("*", "MeshInstance3D", true, false):
		for i in mesh.mesh.get_surface_count():
			var m := mesh.mesh.surface_get_material(i)
			if m != null and m.resource_name == material_name:
				return [mesh, i]
	return []


func _collect_ps1() -> void:
	for path in ["Court/Mesh", "Pillar209/Mesh", "Pillar231/Mesh", "Booth/Mesh", "HalfFallenSign", "BoothWindow", "BoothRoof",
			"PillarCrack", "GateCross0.5", "GateCross3.4"]:
		ps1_nodes.append(gate.get_node(path) as Node3D)
	for child in gate.get_children():
		var name := String(child.name)
		if name.begins_with("GateBar") or name.begins_with("SignScar") or name.begins_with("RoadCrack"):
			ps1_nodes.append(child as Node3D)
	# The barriers and cones: their MultiMesh instances (indices from list_a16_box.py, run on main's props.tscn).
	var data: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(A16_LIST))
	var props: Dictionary = data["props.tscn"]
	for path: String in props:
		var holder := campus.get_node(path) as Node3D
		var multi := holder.find_children("*", "MultiMeshInstance3D", true, false)[0] as MultiMeshInstance3D
		for hit: Dictionary in props[path]["in_box"]:
			if hit["kind"] in ["barrier", "cone"]:
				var index := int(hit["index"])
				var t := multi.multimesh.get_instance_transform(index)
				ps1_instances.append([multi.multimesh, index, t])
				if path.contains("white_cone"):
					# The PS1 cone is a unit cone scaled (.36, .7, .36) about its middle: the new one stands on its base.
					var b := t.basis.orthonormalized()
					cone_xforms.append(Transform3D(b, t.origin - b.y * 0.35))
	fence_mesh = campus.get_node("Fence/S/Mesh") as MeshInstance3D
	var box := fence_mesh.mesh as BoxMesh
	for span: Vector2 in [Vector2(-80.0, WALL_SECTION.x), Vector2(WALL_SECTION.y, 420.0)]:
		var part := MeshInstance3D.new()
		var mesh := box.duplicate() as BoxMesh
		mesh.size = Vector3(span.y - span.x, box.size.y, box.size.z)
		part.mesh = mesh
		campus.get_node("Fence/S").add_child(part)
		part.global_position = Vector3((span.x + span.y) * 0.5, fence_mesh.global_position.y, fence_mesh.global_position.z)
		part.visible = false
		fence_split.append(part)
	print("T262_PS1: %d nodes, %d MultiMesh instances hidden in the pilot, %d cones" % [ps1_nodes.size(), ps1_instances.size(), cone_xforms.size()])


func _build_pilot() -> void:
	pilot["court"] = [_instance("court.glb")]
	pilot["outside"] = [_instance("outside.glb")]
	pilot["cracks"] = [_instance("court_cracks.glb")]
	for kind in ["plaster", "brick"]:
		pilot["pillars_" + kind] = [_instance("pillars_%s.glb" % kind)]
		pilot["wall_" + kind] = [_instance("wall_%s.glb" % kind)]
	for kind in ["swing", "folding"]:
		pilot["gate_" + kind] = [_instance("gate_%s.glb" % kind)]
	pilot["sign_arch"] = [_instance("sign_arch.glb")]
	pilot["sign_band"] = [_instance("sign_band.glb")]
	pilot["letters"] = [_instance("sign_letters.glb")]
	for kind in ["masonry", "prefab"]:
		pilot["booth_" + kind] = [_instance("booth_%s.glb" % kind)]
	var interior := _instance("booth_interior.glb")
	for mesh: MeshInstance3D in interior.find_children("*", "MeshInstance3D", true, false):
		mesh.visibility_range_end = 30.0  # only seen through the window from close by (card section 5)
		mesh.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	pilot["interior"] = [interior]
	var furniture: Array = []
	for b: Vector3 in BARRIERS:
		furniture.append(_instance("barrier.glb", Transform3D(Basis(Vector3.UP, deg_to_rad(b.z)), Vector3(b.x, G, b.y))))
	for t: Transform3D in cone_xforms:
		furniture.append(_instance("cone.glb", t))
	pilot["furniture"] = furniture
	for key in ["cracks"]:
		for node: Node3D in pilot[key]:
			for mesh: MeshInstance3D in node.find_children("*", "MeshInstance3D", true, false):
				mesh.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF


func _apply(config: Dictionary) -> void:
	var on := not config.is_empty()
	for node in ps1_nodes:
		node.visible = not on
	for entry: Array in ps1_instances:
		var t: Transform3D = entry[2]
		(entry[0] as MultiMesh).set_instance_transform(entry[1], Transform3D(Basis().scaled(Vector3.ZERO), t.origin) if on else t)
	fence_mesh.visible = not on
	for part in fence_split:
		part.visible = on
	for key: String in pilot:
		for node: Node3D in pilot[key]:
			node.visible = false
	if not on:
		return
	var show: Array[String] = ["court", "outside", "cracks", "interior", "furniture", "pillars_" + config.pillars, "wall_" + config.wall,
		"gate_" + config.gate, "sign_" + config.sign, "booth_" + config.booth]
	if config.sign == "band" and config.text:
		show.append("letters")
	for key in show:
		for node: Node3D in pilot[key]:
			node.visible = true
	var court: Node3D = pilot["court"][0]
	for mesh: MeshInstance3D in court.find_children("*", "MeshInstance3D", true, false):
		mesh.visible = String(mesh.name) == config.court
	if config.sign == "arch":
		var found := _surface(pilot["sign_arch"][0], "W5SignText")
		(found[0] as MeshInstance3D).set_surface_override_material(found[1], null if config.text else load(W5 + "materials/W5SignBlank.tres"))
	else:
		var found := _surface(pilot["sign_band"][0], "W5Band")
		(found[0] as MeshInstance3D).set_surface_override_material(found[1], null if config.text else load(W5 + "materials/W5BandBlank.tres"))


func _run() -> void:
	if DisplayServer.get_name() == "headless":
		push_error("Capture needs a window.")
		App.quit(1)
		return
	get_window().mode = Window.MODE_WINDOWED
	get_window().content_scale_size = RESOLUTION
	get_window().size = RESOLUTION
	get_viewport().scaling_3d_scale = 1.0
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
	campus = scene.get_node("Campus") as Node3D
	gate = campus.get_node("Gate") as Node3D
	var guards := scene.get_node("Chapter3Director").find_children("Guard*", "Node3D", false, false)
	print("T262_GUARDS %d standing" % guards.size())
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
	torch.spot_range = 12.0
	torch.spot_angle = 28.0
	torch.shadow_enabled = true
	camera.add_child(torch)
	var count := 0
	for config_name: String in _arg("configs", "before,a,b,c,d").split(","):
		_apply(CONFIGS[config_name])
		for view_name: String in VIEWS:
			if not only.is_empty() and not view_name in only.split(","):
				continue
			if config_name in ["c", "d"] and not view_name in SIGN_VIEWS:
				continue
			var view: Dictionary = VIEWS[view_name]
			camera.global_position = view.eye
			camera.look_at(view.target)
			camera.fov = view.get("fov", 75.0)
			var lits: Array = [false, true] if view.torch else [false]
			for lit: bool in lits:
				torch.visible = lit
				for frame in range(24):
					await get_tree().process_frame
				await RenderingServer.frame_post_draw
				var image: Image = get_viewport().get_texture().get_image()
				var file := "pilot_%s_%s%s.jpg" % [config_name, view_name, "_torch" if lit else ""]
				image.save_jpg(OUTPUT + file, 0.88)
				print("CAPTURE: %s draws %d prims %d objects %d vram %d MB" % [file,
					int(Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME)),
					int(Performance.get_monitor(Performance.RENDER_TOTAL_PRIMITIVES_IN_FRAME)),
					int(Performance.get_monitor(Performance.RENDER_TOTAL_OBJECTS_IN_FRAME)),
					int(Performance.get_monitor(Performance.RENDER_VIDEO_MEM_USED) / 1048576.0)])
				count += 1
	print("RESULT: t262 capture %d images" % count)
	App.quit()
