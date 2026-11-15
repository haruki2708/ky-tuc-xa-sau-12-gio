extends Node3D
## T-263 round 1 stills: the canteen pilot put into chapter 3's real scene at run time, one option set at a time, same
## cameras, night as the chapter opens; the canteen horde's six idle points filled (the horde's own place_idle, asleep,
## as the director does for other zones). canteen.tscn, campus.tscn and props.tscn are not changed in round 1: this
## script hides the PS1 meshes the pilot replaces (visible = false: their colliders and nodes stay) and hangs the wave-6
## glbs under Campus/Canteen; the lit screen hangs under Canteen/TV/Screen, which campus.gd's set_canteen_tv toggles.
## Director held, HUD and player hidden, sound muted. No light is added (the torch is the camera's, as in waves 4-5).
## Copy this file to game/_probe_tmp/ with a scene whose root has it, then (one Godot at a time, Lượt Godot):
##   godot --path game res://_probe_tmp/capture_wave6.tscn -- --configs=before,a,b,c,d [--views=door,...]
## Writes art_source/graphics_upgrade/realistic_map/previews/wave6/pilot_<config>_<view>[_tv][_torch].jpg (1920 x 1080)
## and prints draw calls, primitives, objects and video memory per shot.
const OUTPUT := "res://../art_source/graphics_upgrade/realistic_map/previews/wave6/"
const W6 := "res://assets/models/graphics_pilot/realistic_map/wave6/"
const RESOLUTION := Vector2i(1920, 1080)
const G := -9.9
# torch: also shot with the torch on; tv: also shot with the TV on.
const VIEWS := {
	"door": {"eye": Vector3(190, -8.3, 20.8), "target": Vector3(180, -8.6, 36), "torch": false, "tv": true},
	"door_in": {"eye": Vector3(190, -8.3, 20.6), "target": Vector3(190, -8.5, 44), "torch": false},
	"counter_out": {"eye": Vector3(184, -8.3, 40.2), "target": Vector3(192, -8.4, 20), "torch": false},
	"tv": {"eye": Vector3(177.5, -8.3, 34.2), "target": Vector3(170.3, -7.6, 32), "torch": true, "tv": true},
	"counter": {"eye": Vector3(180.5, -8.3, 38.6), "target": Vector3(176.5, -8.7, 42.6), "torch": true},
	"tables": {"eye": Vector3(172.6, -8.3, 29.8), "target": Vector3(184, -9.0, 26.5), "torch": true},
	"table_close": {"eye": Vector3(175.9, -8.25, 35.0), "target": Vector3(173.6, -9.14, 37), "torch": true},
	"ceiling": {"eye": Vector3(181, -8.4, 27), "target": Vector3(184, -5.9, 33), "torch": false},
	"kitchen": {"eye": Vector3(192, -8.3, 44.6), "target": Vector3(192, -7.7, 51.8), "torch": true},
	"kitchen_side": {"eye": Vector3(196.8, -8.3, 45.2), "target": Vector3(189.5, -8.7, 49.8), "torch": true},
	"facade": {"eye": Vector3(190, -8.3, 8.0), "target": Vector3(190, -6.8, 20), "torch": false},
	"facade_side": {"eye": Vector3(176.5, -8.3, 12.5), "target": Vector3(186, -7.0, 20), "torch": true},
	"west_exit": {"eye": Vector3(176.5, -8.3, 37.8), "target": Vector3(170, -8.4, 40.5), "torch": true},
}
const CONFIGS := {
	"before": {},
	"a": {"walls": "f1", "ceiling": "panels", "tables": "inox", "mess": false, "counter": "inox", "prices": "wood", "kitchen": "k1"},
	"b": {"walls": "f2", "ceiling": "roof", "tables": "stone", "mess": true, "counter": "tiled", "prices": "print", "kitchen": "k2"},
	"c": {"walls": "f1", "ceiling": "panels", "tables": "inox", "mess": true, "counter": "inox", "prices": "wood", "kitchen": "k1"},
	"d": {"walls": "f2", "ceiling": "roof", "tables": "stone", "mess": false, "counter": "tiled", "prices": "print", "kitchen": "k2"},
}
const C_VIEWS := ["door", "tables", "table_close", "counter_out"]   # c (a, messier) and d (b, tidier) are shot here only
const PS1_EXACT := ["Floor/Mesh", "Ceiling/Mesh", "Front178/Mesh", "Front202/Mesh", "Back178/Mesh", "TileW", "TileE", "TileB",
	"Parapet19.4", "Canopy", "Step", "SignBoard", "SignText", "SloganBoard", "SloganText", "Counter/Mesh", "CounterTop", "TrayRail",
	"CardReader", "QueueRail", "TV/Case", "TV/Screen/Mesh", "TVBracket", "KitchenFloor/Mesh", "Cooktop/Mesh", "Hood", "HoodDuct",
	"PrepTable/Mesh", "ChoppingBoard", "Cleaver", "KitchenSink/Mesh", "SinkTap", "WestExit/Jamb39.5", "WestExit/Jamb41.5"]
const PS1_PREFIX := ["Window", "Pilaster", "CanopyPost", "Tube_", "FanHub_", "FanBlades_", "SneezeGlass", "FoodPan", "Food", "Ladle",
	"ServeWindow", "PriceBoard", "PriceText", "RiceBucket", "TrayStack", "QueuePost", "FloorTray", "Spill", "Wok", "Steamer",
	"RiceCooker", "Vegetables", "HangingLadle", "Poster"]

var camera: Camera3D
var torch: SpotLight3D
var campus: Node3D
var canteen: Node3D
var ps1_nodes: Array[Node3D] = []
var pilot := {}


func _ready() -> void:
	call_deferred("_run")


func _arg(name: String, fallback: String) -> String:
	for argument: String in OS.get_cmdline_user_args():
		if argument.begins_with("--%s=" % name):
			return argument.trim_prefix("--%s=" % name)
	return fallback


func _instance(file: String, parent: Node3D = null) -> Node3D:
	var node := (load(W6 + file) as PackedScene).instantiate() as Node3D
	(parent if parent != null else canteen).add_child(node)
	node.global_transform = Transform3D(Basis.IDENTITY, Vector3(0, G, 0))
	node.visible = false
	return node


func _collect_ps1() -> void:
	for path: String in PS1_EXACT:
		ps1_nodes.append(canteen.get_node(path) as Node3D)
	for child in canteen.get_children():
		var name := String(child.name)
		if name.begins_with("Table_"):
			for part in child.get_children():
				if part.name != &"Collision":
					ps1_nodes.append(part as Node3D)
			continue
		for prefix: String in PS1_PREFIX:
			if name.begins_with(prefix) and child is Node3D:
				ps1_nodes.append(child as Node3D)
				break
	var clock := canteen.get_node("KitchenClock")
	for part in clock.get_children():
		ps1_nodes.append(part as Node3D)
	print("T263_PS1: %d nodes hidden in the pilot; KitchenClock stopped_hour %s" % [ps1_nodes.size(), clock.get_meta("stopped_hour")])


func _no_shadow(node: Node3D) -> void:
	for mesh: MeshInstance3D in node.find_children("*", "MeshInstance3D", true, false):
		mesh.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF


func _build_pilot() -> void:
	for key in ["hall_shell", "windows", "ceiling_panels", "ceiling_roof", "lights_fans", "tables_inox", "tables_stone",
			"tables_stone_mess", "tableware", "tableware_mess", "counter_inox", "counter_tiled", "price_boards", "tv",
			"kitchen_room", "kitchen_k1", "kitchen_k2", "clock", "facade"]:
		pilot[key] = _instance(key + ".glb")
	pilot["tv_screen"] = _instance("tv_screen.glb", canteen.get_node("TV/Screen") as Node3D)
	for key in ["tableware", "tableware_mess", "lights_fans", "price_boards", "clock", "tv_screen"]:
		_no_shadow(pilot[key])
	for key in ["kitchen_room", "kitchen_k1", "kitchen_k2", "clock"]:
		for mesh: MeshInstance3D in (pilot[key] as Node3D).find_children("*", "MeshInstance3D", true, false):
			mesh.visibility_range_end = 45.0


func _swap(node: Node3D, swaps: Dictionary) -> void:
	for mesh: MeshInstance3D in node.find_children("*", "MeshInstance3D", true, false):
		for i in mesh.mesh.get_surface_count():
			var m := mesh.mesh.surface_get_material(i)
			var name := m.resource_name if m != null else ""
			mesh.set_surface_override_material(i, load(W6 + "materials/%s.tres" % swaps[name]) if swaps.has(name) else null)


func _apply(config: Dictionary) -> void:
	var on := not config.is_empty()
	for node in ps1_nodes:
		node.visible = not on
	for key: String in pilot:
		(pilot[key] as Node3D).visible = false
	if not on:
		return
	var show: Array[String] = ["hall_shell", "windows", "lights_fans", "price_boards", "tv", "tv_screen", "kitchen_room", "clock", "facade",
		"ceiling_" + config.ceiling, "counter_" + config.counter, "kitchen_" + config.kitchen,
		("tableware_mess" if config.mess else "tableware")]
	if config.tables == "inox":
		show.append("tables_inox")
	else:
		show.append("tables_stone_mess" if config.mess else "tables_stone")
	for key in show:
		(pilot[key] as Node3D).visible = true
	_swap(pilot["hall_shell"], {"W6FloorCeramic": "W6FloorTerrazzo", "W6WallYellow": "W6WallGreen", "W6Wainscot": "W6DadoGreen"}
		if config.walls == "f2" else {})
	_swap(pilot["price_boards"], {"W6PriceWood": "W6PricePrint"} if config.prices == "print" else {})


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
	var director := scene.get_node("Chapter3Director")
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
	canteen = campus.get_node("Canteen") as Node3D
	var horde: Node = director.get("_horde")
	if horde != null:
		horde.call("place_idle", &"Canteen")
	print("T263_ZOMBIES %d in the canteen" % (horde.get("_zones") as Dictionary).get(&"Canteen", []).size() if horde != null else 0)
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
			if config_name in ["c", "d"] and not view_name in C_VIEWS:
				continue
			var view: Dictionary = VIEWS[view_name]
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
					var file := "pilot_%s_%s%s%s.jpg" % [config_name, view_name, "_tv" if tv_on else "", "_torch" if lit else ""]
					image.save_jpg(OUTPUT + file, 0.88)
					print("CAPTURE: %s draws %d prims %d objects %d vram %d MB" % [file,
						int(Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME)),
						int(Performance.get_monitor(Performance.RENDER_TOTAL_PRIMITIVES_IN_FRAME)),
						int(Performance.get_monitor(Performance.RENDER_TOTAL_OBJECTS_IN_FRAME)),
						int(Performance.get_monitor(Performance.RENDER_VIDEO_MEM_USED) / 1048576.0)])
					count += 1
		campus.call("set_canteen_tv", false)
	print("RESULT: t263 pilot capture %d images" % count)
	App.quit()
