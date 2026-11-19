extends Node3D
## T-265 round 1 stills: the library pilot put into chapter 4's real scene at run time (director held, night as the
## chapter, HUD and player hidden, sound muted), one option set at a time, same cameras, with and without the torch (the
## camera's, as in waves 4-7; no light is added to the scene). library.tscn, shells.tscn, campus.tscn are not changed in
## round 1: this script hides the library's PS1 meshes (visible = false: colliders, nodes, navigation stay; the iron bar's
## own model stays) and the Shells' LibraryBand*, and hangs the wave-8 glbs under a node "PilotWave8" of Campus/Library:
## world pieces at (0, G, 0), each shelf's frame and books at its Shelf node, each table at its ReadingTable node, the new
## leaf under BackDoor/Hinge (so set_open swings it). Then: top-down plans of floors 1 and 3 per fill level (M1/M2/M3:
## an orthographic camera, the floors above and the roof hidden, a plan light added for these diagnostic stills only),
## the far views from the stadium in chapter 3, and two stills of the canteen's west exit from Start_split (chapter 4).
## Copy this file to game/_probe_tmp/ with a scene whose root has it, then (one Godot at a time, Lượt Godot):
##   godot --path game res://_probe_tmp/capture_wave8.tscn -- [--configs=before,a,b,c] [--views=f1_backdoor,...] [--parts=main,plan,far,west]
## Writes art_source/graphics_upgrade/realistic_map/previews/wave8/*.jpg (1600 x 900) and prints draw calls, primitives,
## objects and video memory per shot.
const OUTPUT := "res://../art_source/graphics_upgrade/realistic_map/previews/wave8/"
const W8 := "res://assets/models/graphics_pilot/realistic_map/wave8/"
const RESOLUTION := Vector2i(1600, 900)
const G := -9.9
const LEVELS := [-9.9, -6.6, -3.3]
# torch: also shot with the torch on; open: the back door open; level: the floor the camera stands on (the pilot of the
# floors above is kept, as in play).
const VIEWS := {
	"f1_backdoor": {"eye": Vector3(65.0, -8.3, 224.2), "target": Vector3(58.5, -9.0, 206.5), "torch": true},
	"f1_wide": {"eye": Vector3(80.5, -8.25, 213.6), "target": Vector3(52.0, -8.9, 205.0), "torch": true, "fov": 80.0},
	"f1_counter": {"eye": Vector3(61.4, -8.35, 209.4), "target": Vector3(57.4, -9.1, 206.1), "torch": true},
	"f1_map": {"eye": Vector3(47.25, -8.3, 211.0), "target": Vector3(45.2, -8.15, 211.0), "torch": true},
	"f1_shelf": {"eye": Vector3(54.2, -8.3, 214.0), "target": Vector3(51.0, -8.9, 218.0), "torch": true},
	"f1_front_door": {"eye": Vector3(66.2, -8.3, 201.0), "target": Vector3(65.0, -8.9, 195.3), "torch": true},
	"f2_table": {"eye": Vector3(61.2, -5.0, 213.0), "target": Vector3(57.8, -5.8, 216.2), "torch": true},
	"f2_shelf_window": {"eye": Vector3(54.6, -5.0, 207.4), "target": Vector3(52.5, -5.3, 199.0), "torch": true},
	"stairs": {"eye": Vector3(77.7, -8.3, 196.4), "target": Vector3(82.0, -6.9, 206.5), "torch": true},
	"f3_wide": {"eye": Vector3(80.6, -1.7, 213.4), "target": Vector3(54.0, -2.6, 219.0), "torch": true, "fov": 80.0},
	"f3_scare": {"eye": Vector3(60.6, -1.7, 214.6), "target": Vector3(57.0, -2.3, 218.0), "torch": true},
	"back_out": {"eye": Vector3(66.0, -8.3, 231.0), "target": Vector3(65.0, -8.5, 225.0), "torch": true},
	"back_in_open": {"eye": Vector3(65.3, -8.3, 218.0), "target": Vector3(65.0, -8.7, 226.0), "torch": true, "open": true},
	"facade": {"eye": Vector3(59.0, -8.3, 180.5), "target": Vector3(66.0, -5.0, 195.0), "torch": false, "fov": 80.0},
	"facade_side": {"eye": Vector3(92.0, -8.3, 186.0), "target": Vector3(70.0, -4.8, 200.0), "torch": false},
}
const C_VIEWS := ["f1_backdoor", "f1_wide", "f1_shelf", "f2_table", "f3_wide", "f3_scare", "facade"]
const FILL_VIEWS := ["f1_backdoor", "f1_wide", "f3_wide"]
const FAR_VIEWS := {
	"far_stand": {"eye": Vector3(114.0, -4.5, 196.0), "target": Vector3(66.0, -5.0, 210.0), "fov": 60.0},
	"far_track": {"eye": Vector3(124.0, -8.3, 176.0), "target": Vector3(70.0, -4.6, 206.0), "fov": 60.0},
}
const WEST_VIEWS := {
	"westexit_door": {"eye": Vector3(166.2, -8.3, 40.5), "target": Vector3(172.0, -8.4, 40.5), "torch": true},
	"westexit_wall": {"eye": Vector3(164.5, -8.2, 47.5), "target": Vector3(170.0, -8.0, 33.0), "torch": false},
}
# a: F1 walls and floors, C2 panels, Q1 counter, printed map, steel shelves full, T1 tables, dark glass and curtains, E1
# with fake rooms, M1, tidy. b: F2, C1 with fans, Q2, drawn map, wood shelves part full, T2, shutters, E2 with dark glass,
# M1, messy. c (recommended): a with M2, the top floor as the store (cement floor, old wood shelves, tipped rows), messy.
const CONFIGS := {
	"before": {},
	"a": {"walls": "F1", "floor3": "", "ceiling": "c2", "counter": "q1", "map": "print", "shelf": "steel", "books": "full", "shelf3": "",
		"books3": "", "table": "t1", "window": "glass", "facade": "e1", "outside": "fake", "fill": "m1", "mess": false},
	"b": {"walls": "F2", "floor3": "", "ceiling": "c1", "counter": "q2", "map": "drawn", "shelf": "wood", "books": "sparse", "shelf3": "",
		"books3": "", "table": "t2", "window": "shutter", "facade": "e2", "outside": "dark", "fill": "m1", "mess": true},
	"c": {"walls": "F1", "floor3": "F3", "ceiling": "c2", "counter": "q1", "map": "print", "shelf": "steel", "books": "full", "shelf3": "wood",
		"books3": "tipped", "table": "t1", "window": "glass", "facade": "e1", "outside": "fake", "fill": "m2", "mess": true},
}

var camera: Camera3D
var torch: SpotLight3D
var campus: Node3D
var library: Node3D
var ps1: Array[Node3D] = []
var pilot: Node3D
var nodes := {}
var count := 0


func _ready() -> void:
	call_deferred("_run")


func _arg(name: String, fallback: String) -> String:
	for argument: String in OS.get_cmdline_user_args():
		if argument.begins_with("--%s=" % name):
			return argument.trim_prefix("--%s=" % name)
	return fallback


func _glb(file: String, parent: Node, at: Transform3D = Transform3D(Basis.IDENTITY, Vector3(0, G, 0)), global := true) -> Node3D:
	var node := (load(W8 + file) as PackedScene).instantiate() as Node3D
	parent.add_child(node)
	if global:
		node.global_transform = at
	node.visible = false
	return node


func _no_shadow(node: Node3D) -> void:
	for mesh: MeshInstance3D in node.find_children("*", "MeshInstance3D", true, false):
		mesh.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF


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
	for node in library.find_children("*", "MeshInstance3D", true, false):
		var rel := String(library.get_path_to(node))
		if rel.begins_with("Counter/IronBar"):
			continue
		ps1.append(node as Node3D)
	for band in ["LibraryBand0", "LibraryBand1", "LibraryBand2"]:
		ps1.append(campus.get_node("Shells/%s/Mesh" % band) as Node3D)
	_build_pilot()
	return scene


func _build_pilot() -> void:
	nodes.clear()
	pilot = Node3D.new()
	pilot.name = "PilotWave8"
	library.add_child(pilot)
	for file in ["shell_f1", "shell_f2", "shell_f3", "stairs", "counter_q1", "counter_q2", "librarian_chair", "map_print", "map_drawn",
			"back_frame", "front_door", "barricade", "facade_e1", "facade_e2", "strip", "fill_m2", "fill_m3", "mess"]:
		nodes[file] = _glb(file + ".glb", pilot)
	for key in ["mess", "map_print", "map_drawn", "counter_q1", "counter_q2", "librarian_chair"]:
		_no_shadow(nodes[key])
	for child in library.get_children():
		var name := String(child.name)
		if name.begins_with("Shelf"):
			var xf := (child as Node3D).global_transform
			for kind in ["shelf_steel", "shelf_wood", "books_full", "books_sparse", "books_tipped"]:
				nodes["%s/%s" % [name, kind]] = _glb(kind + ".glb", pilot, xf)
				if kind.begins_with("books"):
					_no_shadow(nodes["%s/%s" % [name, kind]])
		elif name.begins_with("ReadingTable"):
			var xf := (child as Node3D).global_transform
			for kind in ["table_t1", "table_t2"]:
				nodes["%s/%s" % [name, kind]] = _glb(kind + ".glb", pilot, xf)
			if name == "ReadingTable13":
				nodes["rule_book"] = _glb("rule_book.glb", pilot, xf)
	var hinge := library.get_node("BackDoor/Hinge") as Node3D
	nodes["back_leaf"] = _glb("back_leaf.glb", hinge, Transform3D.IDENTITY, false)
	nodes["back_leaf"].transform = Transform3D.IDENTITY


func _part(file: String, part: String) -> Node3D:
	return (nodes[file] as Node3D).find_child(part, true, false) as Node3D


func _set_parts(file: String, show: Array) -> void:
	var root := nodes[file] as Node3D
	root.visible = true
	for child in root.find_children("*", "MeshInstance3D", true, false):
		var on := false
		for key: String in show:
			if String(child.name).begins_with(key):
				on = true
		(child as Node3D).visible = on


func _apply(config: Dictionary) -> void:
	var on := not config.is_empty()
	for node in ps1:
		node.visible = not on
	for key: String in nodes:
		(nodes[key] as Node3D).visible = false
	if not on:
		return
	for level in range(3):
		var floor_key: String = "Floor_" + (config.floor3 if level == 2 and config.floor3 != "" else config.walls)
		var show := [floor_key, "Walls_" + config.walls, "Sills", "WellEdge", "Battens", "WinGlass" if config.window == "glass" else "WinShutter"]
		if config.ceiling == "c2":
			show.append("CeilPanels")
		else:
			show.append_array(["CeilConcrete", "Fans"])
		_set_parts("shell_f%d" % (level + 1), show)
	for key in ["stairs", "librarian_chair", "back_frame", "front_door", "barricade", "strip", "back_leaf", "rule_book"]:
		(nodes[key] as Node3D).visible = true
	(nodes["counter_" + config.counter] as Node3D).visible = true
	(nodes["map_" + config.map] as Node3D).visible = true
	_set_parts("facade_" + config.facade, ["Walls", "Bands", "Fins", "Frames", "Grilles", "Glass", "Roof", "Extras",
		"FakeRooms" if config.outside == "fake" else "DarkGlass"])
	for key: String in nodes:
		if key.contains("/"):
			var shelf: String = key.get_slice("/", 0)
			var kind: String = key.get_slice("/", 1)
			var level := int(shelf.trim_prefix("Shelf").get_slice("_", 0)) if shelf.begins_with("Shelf") else -1
			if shelf.begins_with("Shelf"):
				var s: String = config.shelf3 if level == 2 and config.shelf3 != "" else config.shelf
				var b: String = config.books3 if level == 2 and config.books3 != "" else config.books
				(nodes[key] as Node3D).visible = kind == "shelf_" + s or kind == "books_" + b
			elif shelf.begins_with("ReadingTable"):
				(nodes[key] as Node3D).visible = kind == "table_" + config.table
	if config.fill != "m1":
		(nodes["fill_" + config.fill] as Node3D).visible = true
	(nodes["mess"] as Node3D).visible = config.mess


func _stats(file: String) -> void:
	print("CAPTURE: %s draws %d prims %d objects %d vram %d MB" % [file,
		int(Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME)),
		int(Performance.get_monitor(Performance.RENDER_TOTAL_PRIMITIVES_IN_FRAME)),
		int(Performance.get_monitor(Performance.RENDER_TOTAL_OBJECTS_IN_FRAME)),
		int(Performance.get_monitor(Performance.RENDER_VIDEO_MEM_USED) / 1048576.0)])


func _snap(file: String) -> void:
	for frame in range(24):
		await get_tree().process_frame
	await RenderingServer.frame_post_draw
	var image: Image = get_viewport().get_texture().get_image()
	image.save_jpg(OUTPUT + file, 0.86)
	_stats(file)
	count += 1


func _shoot(prefix: String, views: Dictionary, only: String) -> void:
	camera.make_current()   # the chapter's player camera took over when the chapter was added
	camera.projection = Camera3D.PROJECTION_PERSPECTIVE
	var door := library.get_node("BackDoor")
	for view_name: String in views:
		if not only.is_empty() and not view_name in only.split(","):
			continue
		var view: Dictionary = views[view_name]
		var open: bool = view.get("open", false)
		if bool(door.get("is_open")) != open:
			door.call("set_open", open)
			await get_tree().create_timer(0.5).timeout
		camera.global_position = view.eye
		camera.look_at(view.target)
		camera.fov = view.get("fov", 75.0)
		var lits: Array = [false, true] if view.get("torch", false) else [false]
		for lit: bool in lits:
			torch.visible = lit
			await _snap("%s_%s%s.jpg" % [prefix, view_name, "_torch" if lit else ""])
	if bool(door.get("is_open")):
		door.call("set_open", false)
		await get_tree().create_timer(0.5).timeout


## Top-down: the floors above, the ceilings and the roof hidden; an orthographic camera; a plan light (diagnostic only).
func _plan(prefix: String, level: int) -> void:
	var hidden: Array[Node3D] = []
	for l in range(level, 3):
		var shell := nodes["shell_f%d" % (l + 1)] as Node3D
		for part: Node in shell.find_children("*", "MeshInstance3D", true, false):
			var name := String(part.name)
			if l > level or name.begins_with("Ceil") or name.begins_with("Fans") or name.begins_with("Battens"):
				if (part as Node3D).visible:
					(part as Node3D).visible = false
					hidden.append(part as Node3D)
	for key: String in nodes:
		var node := nodes[key] as Node3D
		if not node.visible or key.begins_with("shell_"):
			continue
		if key.begins_with("facade_"):
			for part: Node in node.find_children("*", "MeshInstance3D", true, false):
				(part as Node3D).visible = false
				hidden.append(part as Node3D)
			continue
		if key.begins_with("Shelf") and int(key.trim_prefix("Shelf").get_slice("_", 0)) > level:
			node.visible = false
			hidden.append(node)
		if key.begins_with("ReadingTable") and level != 1:
			node.visible = false
			hidden.append(node)
		if key == "rule_book" and level != 1:
			node.visible = false
			hidden.append(node)
		if key == "stairs" and level == 0:
			pass
	# Fill and mess meshes of other floors.
	for key in ["fill_m2", "fill_m3", "mess"]:
		var node := nodes[key] as Node3D
		for part: Node in node.find_children("*", "MeshInstance3D", true, false):
			var name := String(part.name)
			var floor_n := int(name.right(1)) if name.right(1).is_valid_int() else 0
			if floor_n > level + 1 and (part as Node3D).visible:
				(part as Node3D).visible = false
				hidden.append(part as Node3D)
	# PS1 above (in "before" the PS1 is shown): every library mesh whose top is over this floor's 2.6 m.
	for node in ps1:
		if node.visible and node is MeshInstance3D:
			var box := (node as MeshInstance3D).global_transform * (node as MeshInstance3D).get_aabb()
			if box.position.y > LEVELS[level] + 2.6 or box.end.y > LEVELS[level] + 3.2:
				node.visible = false
				hidden.append(node)
	var sun := DirectionalLight3D.new()
	sun.light_energy = 0.55
	sun.light_color = Color(0.95, 0.95, 1.0)
	add_child(sun)
	sun.look_at_from_position(Vector3(65, 30, 211), Vector3(66, 0, 212), Vector3(0, 0, -1))
	camera.make_current()
	camera.projection = Camera3D.PROJECTION_ORTHOGONAL
	camera.size = 32.0
	camera.global_position = Vector3(65.0, LEVELS[level] + 6.0, 210.0)
	camera.look_at(Vector3(65.0, LEVELS[level], 210.0), Vector3(0, 0, -1))
	torch.visible = false
	await _snap("%s_floor%d.jpg" % [prefix, level + 1])
	sun.queue_free()
	camera.projection = Camera3D.PROJECTION_PERSPECTIVE
	for node in hidden:
		node.visible = true


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
	var configs := _arg("configs", "before,a,b,c").split(",")
	var parts := _arg("parts", "main,plan,far,west").split(",")
	_camera()
	var scene := await _load_chapter("res://scenes/main/chapter4.tscn", "Chapter4Director")
	print("T265_PS1 %d meshes hidden in the pilot configs" % ps1.size())
	if "main" in parts:
		for config_name: String in configs:
			_apply(CONFIGS[config_name])
			var views := {}
			for view_name: String in VIEWS:
				if config_name == "c" and not view_name in C_VIEWS:
					continue
				views[view_name] = VIEWS[view_name]
			await _shoot("pilot_" + config_name if config_name != "before" else "before", views, only)
		# M2 and M3 in perspective (config a with each fill).
		for fill: String in ["m2", "m3"]:
			var cfg: Dictionary = (CONFIGS["a"] as Dictionary).duplicate()
			cfg.fill = fill
			_apply(cfg)
			var views := {}
			for view_name: String in FILL_VIEWS:
				views[view_name] = VIEWS[view_name]
			await _shoot("options_fill_" + fill, views, only)
	if "plan" in parts:
		for fill: String in ["m1", "m2", "m3"]:
			var cfg: Dictionary = (CONFIGS["c"] as Dictionary).duplicate()
			cfg.fill = fill
			cfg.mess = false
			_apply(cfg)
			for level: int in [0, 2]:
				await _plan("options_top_" + fill, level)
		_apply({})
		for level: int in [0, 2]:
			await _plan("options_top_before", level)
	if "west" in parts:
		_apply({})
		await _shoot("ch4", WEST_VIEWS, "")
	scene.queue_free()
	for frame in range(6):
		await get_tree().process_frame
	if "far" in parts:
		scene = await _load_chapter("res://scenes/main/chapter3.tscn", "Chapter3Director")
		for config_name: String in ["before", "a", "b"]:
			_apply(CONFIGS[config_name])
			await _shoot("ch3_" + config_name, FAR_VIEWS, "")
	print("RESULT: t265 pilot capture %d images" % count)
	App.quit()
