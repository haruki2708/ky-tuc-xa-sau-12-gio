extends Node3D
## T-259 round 1 stills: the pilot corner round Ngư's bench (Bed1_1, Bed2_1, NguBench, the paving, the lamps at
## x 1, z 10 and 24) put into chapter 3's real scene at run time, one option at a time, same cameras. garden.tscn
## is not changed in round 1: this script hides the PS1 meshes of those pieces (visible = false) and hangs the wave-3
## glbs under Campus/Garden. Director held, lights as the chapter opens, HUD and player hidden, sound muted; the six
## garden Flicker lights are held on (0.35) so every option is lit alike.
## Copy this file to game/_probe_tmp/ with a scene whose root has it, then (one Godot at a time, Lượt Godot):
##   godot --path game res://_probe_tmp/capture_wave3.tscn -- --configs=before,t1,t2,t3 [--views=bench_wide,...]
##   (other options: --configs=f2 --extra="f2:plumeria/b/block/white"; tree "a+b" puts species a in Bed1_1, b in Bed2_1)
## Writes art_source/graphics_upgrade/realistic_map/previews/wave3/pilot_<config>_<view>_<torch|dark>.jpg (1920 x 1080)
## and prints draw calls, primitives and video memory per shot.
const OUTPUT := "res://../art_source/graphics_upgrade/realistic_map/previews/wave3/"
const W3 := "res://assets/models/graphics_pilot/realistic_map/wave3/"
const RESOLUTION := Vector2i(1920, 1080)
const BEDS := {"1_1": Vector3(22, -9.9, 22), "2_1": Vector3(22, -9.9, 32)}
const TREE_TURN := {"1_1": 0.0, "2_1": 2.2}
const LAMPS := [Vector3(1, -9.9, 10), Vector3(1, -9.9, 24)]
const FAR_FROM := 40.0
const VIEWS := {
	"bench_wide": {"eye": Vector3(30.5, -8.3, 27.2), "target": Vector3(22, -8.4, 27.4), "torch": [false, true]},
	"bench_close": {"eye": Vector3(24.6, -8.3, 25.4), "target": Vector3(21.8, -9.1, 28.4), "torch": [false, true]},
	"bed_close": {"eye": Vector3(24.8, -8.3, 17.4), "target": Vector3(22.0, -8.5, 22.0), "torch": [false, true]},
	"entry": {"eye": Vector3(15.5, -8.3, 15.5), "target": Vector3(22.5, -8.0, 27.5), "torch": [false]},
	"lamp": {"eye": Vector3(4.6, -8.3, 27.6), "target": Vector3(1.0, -7.7, 24.0), "torch": [false, true]},
	"floor4": {"eye": Vector3(22, 1.6, 3.3), "target": Vector3(22, -9.9, 25), "torch": [false]},
}
const CONFIGS := {
	"before": {},
	"t1": {"tree": "plumeria", "planting": "a", "paving": "block", "kerb": "white"},
	"t2": {"tree": "mantaly", "planting": "a", "paving": "block", "kerb": "white"},
	"t3": {"tree": "lagerstroemia", "planting": "a", "paving": "block", "kerb": "white"},
}

var camera: Camera3D
var torch: SpotLight3D
var garden: Node3D
var ps1: Array[Node3D] = []
var pilot := {}
var globes: Array = []


func _ready() -> void:
	call_deferred("_run")


func _arg(name: String, fallback: String) -> String:
	for argument: String in OS.get_cmdline_user_args():
		if argument == "--%s" % name:
			return "true"
		if argument.begins_with("--%s=" % name):
			return argument.trim_prefix("--%s=" % name)
	return fallback


func _config(name: String) -> Dictionary:
	# Extra configs from the command line: --extra=name:tree/planting/paving/kerb;...
	if CONFIGS.has(name):
		return CONFIGS[name]
	for item: String in _arg("extra", "").split(";", false):
		var parts := item.split(":")
		if parts[0] == name:
			var v := parts[1].split("/")
			return {"tree": v[0], "planting": v[1], "paving": v[2], "kerb": v[3]}
	push_error("no config " + name)
	return {}


func _instance(path: String, at: Vector3, turn: float = 0.0) -> Node3D:
	var node := (load(W3 + path) as PackedScene).instantiate() as Node3D
	garden.add_child(node)
	node.global_position = at
	node.rotation.y = turn
	node.visible = false
	for mesh: MeshInstance3D in node.find_children("*", "MeshInstance3D", true, false):
		var name := String(mesh.name)
		if name.begins_with("Leaves") or name.begins_with("Planting"):
			mesh.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		if name.ends_with("Far"):
			mesh.visibility_range_begin = FAR_FROM
		elif name == "Bark" or name == "Leaves":
			mesh.visibility_range_end = FAR_FROM
	return node


func _build_pilot() -> void:
	for path in ["Paving/Mesh", "Bed1_1/Mesh", "Bed1_1/Soil/Mesh", "Bed2_1/Mesh", "Bed2_1/Soil/Mesh", "LowTrunk1_1",
			"LowCrown1_1", "LowTrunk2_1", "LowCrown2_1", "NguBench/Mesh", "NguBenchLeg21.15", "NguBenchLeg22.85",
			"GardenLights_0_0"]:
		ps1.append(garden.get_node(path) as Node3D)
	for child in garden.get_children():
		var name := String(child.name)
		if name.begins_with("Bush1_1_") or name.begins_with("Bush2_1_") or name.begins_with("Flower1_1_") or name.begins_with("Flower2_1_"):
			ps1.append(child as Node3D)
	var origin := Vector3(0, -9.9, 0)
	for option in ["block", "red"]:
		pilot["paving_" + option] = [_instance("paving_%s.glb" % option, origin)]
	for option in ["a", "b"]:
		pilot["planting_" + option] = [_instance("planting_%s.glb" % option, origin)]
	pilot["beds"] = [_instance("beds_pilot.glb", origin)]
	for species in ["plumeria", "mantaly", "lagerstroemia"]:
		var trees: Array = []
		for bed: String in BEDS:
			trees.append(_instance("tree_%s.glb" % species, BEDS[bed], TREE_TURN[bed]))
		pilot["tree_" + species] = trees
	pilot["bench"] = [_instance("bench_ngu.glb", Vector3(22, -9.9, 28))]
	var lamps: Array = []
	for i in LAMPS.size():
		var lamp := _instance("garden_lamp.glb", LAMPS[i])
		lamps.append(lamp)
		var light := garden.get_node("Flicker%d" % i) as OmniLight3D
		var globe := lamp.find_child("Globe", true, false) as MeshInstance3D
		var source := globe.mesh.surface_get_material(0) as StandardMaterial3D
		var material := source.duplicate() as StandardMaterial3D
		globe.set_surface_override_material(0, material)
		globes.append([light, material, source.emission_energy_multiplier])
	pilot["lamps"] = lamps


func _apply(config: Dictionary) -> void:
	var on := not config.is_empty()
	for node in ps1:
		node.visible = not on
	for key: String in pilot:
		for node: Node3D in pilot[key]:
			node.visible = false
	if not on:
		return
	for key in ["paving_" + config.paving, "planting_" + config.planting, "beds", "bench", "lamps"]:
		for node: Node3D in pilot[key]:
			node.visible = true
	# "a+b": Bed1_1 gets species a, Bed2_1 species b.
	var species := String(config.tree).split("+")
	for i in BEDS.size():
		(pilot["tree_" + species[mini(i, species.size() - 1)]][i] as Node3D).visible = true
	var kerb_material: Material = load(W3 + "materials/%s.tres" % ("W3KerbWhite" if config.kerb == "white" else "W3Kerb"))
	for mesh: MeshInstance3D in pilot["beds"][0].find_children("Kerb_*", "MeshInstance3D", true, false):
		mesh.set_surface_override_material(0, kerb_material)


func _process(_delta: float) -> void:
	for entry: Array in globes:
		var light := entry[0] as OmniLight3D
		(entry[1] as StandardMaterial3D).emission_energy_multiplier = entry[2] * light.light_energy / 0.35 if light.is_visible_in_tree() else 0.0


func _run() -> void:
	if DisplayServer.get_name() == "headless":
		push_error("Capture needs a window.")
		App.quit(1)
		return
	get_window().mode = Window.MODE_WINDOWED
	get_window().content_scale_size = RESOLUTION
	get_window().size = RESOLUTION
	get_viewport().scaling_3d_scale = 1.0
	var configs := _arg("configs", "before,t1").split(",", false)
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
	garden = scene.get_node("Campus/Garden") as Node3D
	for i in 6:
		var flicker := garden.get_node("Flicker%d" % i) as OmniLight3D
		flicker.set_process(false)
		flicker.light_energy = 0.35
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
	for config_name: String in configs:
		_apply(_config(config_name))
		for view_name: String in VIEWS:
			if not only.is_empty() and not view_name in only.split(","):
				continue
			var view: Dictionary = VIEWS[view_name]
			camera.global_position = view.eye
			camera.look_at(view.target)
			camera.fov = view.get("fov", 75.0)
			for lit: bool in view.torch:
				torch.visible = lit
				for frame in range(30):
					await get_tree().process_frame
				await RenderingServer.frame_post_draw
				var image: Image = get_viewport().get_texture().get_image()
				var file := "pilot_%s_%s_%s.jpg" % [config_name, view_name, "torch" if lit else "dark"]
				image.save_jpg(OUTPUT + file, 0.88)
				print("CAPTURE: %s draws %d prims %d objects %d vram %d MB" % [file,
					int(Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME)),
					int(Performance.get_monitor(Performance.RENDER_TOTAL_PRIMITIVES_IN_FRAME)),
					int(Performance.get_monitor(Performance.RENDER_TOTAL_OBJECTS_IN_FRAME)),
					int(Performance.get_monitor(Performance.RENDER_VIDEO_MEM_USED) / 1048576.0)])
				count += 1
	print("RESULT: t259 capture %d images" % count)
	App.quit()
