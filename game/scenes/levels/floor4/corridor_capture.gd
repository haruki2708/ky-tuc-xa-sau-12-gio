extends Node3D
## T-229: static survey cameras only; no player, director, bot or performance sampling.
## T-233, T-235: "-- --g5" captures the upgraded corridor (corridor_g5_pilot.gd) instead: before_* (PS1) and
## after_* from the same cameras, and variant views.
## T-237: "-- --chapter=1" (or 3) captures the corridor inside that chapter's real scene (chapter director held,
## its PS1 screen filter on, the HUD hidden) to previews/round3_playable/.
const FLOOR := preload("res://scenes/levels/floor4/floor4.tscn")
const PILOT := preload("res://scenes/levels/floor4/corridor_g5_pilot.gd")
const CAMPUS := preload("res://scenes/levels/campus/campus.tscn")
const OUTPUT := "res://../art_source/graphics_upgrade/floor4_corridor/previews/"
const RESOLUTION := Vector2i(1920, 1080)
const VIEWS: Array[Dictionary] = [
	{"id": "01_west_night", "eye": Vector3(0.7, 1.65, 2.7), "target": Vector3(32, 1.4, 1.2)},
	{"id": "02_east_night", "eye": Vector3(43.3, 1.65, 3.1), "target": Vector3(12, 1.4, 1.1)},
	{"id": "03_door407_night", "eye": Vector3(33.5, 1.65, 3.1), "target": Vector3(32, 1.25, 0)},
	{"id": "04_door407_torch", "eye": Vector3(33.5, 1.65, 3.1), "target": Vector3(32, 1.25, 0), "torch": true},
	{"id": "05_desk_night", "eye": Vector3(37.3, 1.65, 3.1), "target": Vector3(40, 1.25, 0.4)},
	{"id": "06_desk_torch", "eye": Vector3(37.3, 1.65, 3.1), "target": Vector3(40, 1.25, 0.4), "torch": true},
	{"id": "07_washroom_night", "eye": Vector3(3.0, 1.65, 0.8), "target": Vector3(2.5, 1.1, -3.5)},
	{"id": "08_washroom_torch", "eye": Vector3(2.4, 1.65, -1.0), "target": Vector3(0.2, 1.3, -2.3), "torch": true},
	{"id": "09_sealed_old408_night", "eye": Vector3(35, 1.65, 2.8), "target": Vector3(36, 1.15, 0.13)},
	{"id": "10_door408_torch", "eye": Vector3(43, 1.65, 2.8), "target": Vector3(42, 1.3, 0), "torch": true},
	{"id": "11_main_stairs_torch", "eye": Vector3(-1.0, 1.65, 2.5), "target": Vector3(-3.8, -0.7, -1.4), "torch": true, "campus": true},
	{"id": "12_fire_stairs_torch", "eye": Vector3(46.5, 1.65, 2.5), "target": Vector3(45.2, -0.7, -1.4), "torch": true, "campus": true},
]
## T-235 views ("-- --g5"), written to previews/round2/ so round 1's images stay as they were. Every view is taken
## before (the PS1 corridor, same camera) and after, except the variants. 01, 02, 09 and 10 reuse T-229's
## cameras. "door_open" swings that RoomDoor open first; "plates" and "seal" pick a variant; "campus" adds the
## campus (its stairs replace the end caps) for this and every later view.
const G5_OUTPUT := OUTPUT + "round2/"
const G5_VIEWS: Array[Dictionary] = [
	{"id": "01_west_night", "eye": Vector3(0.7, 1.65, 2.7), "target": Vector3(32, 1.4, 1.2)},
	{"id": "02_east_night", "eye": Vector3(43.3, 1.65, 3.1), "target": Vector3(12, 1.4, 1.1)},
	{"id": "03_door407_night", "eye": Vector3(33.5, 1.65, 3.1), "target": Vector3(32, 1.25, 0)},
	{"id": "09_sealed_old408_night", "eye": Vector3(35, 1.65, 2.8), "target": Vector3(36, 1.15, 0.13)},
	{"id": "10_door408_torch", "eye": Vector3(43, 1.65, 2.8), "target": Vector3(42, 1.3, 0), "torch": true},
	{"id": "13_door403_night", "eye": Vector3(14.7, 1.6, 2.3), "target": Vector3(16.0, 1.05, 0.1), "fov": 65.0},
	{"id": "14_door403_open_torch", "eye": Vector3(14.4, 1.6, 2.7), "target": Vector3(16.3, 1.0, 0.3), "fov": 70.0,
		"torch": true, "door_open": "403"},
	{"id": "15_door408_night", "eye": Vector3(40.4, 1.6, 2.6), "target": Vector3(42.0, 1.05, 0.1), "fov": 65.0},
	{"id": "16_seal_night", "eye": Vector3(36.0, 1.5, 3.3), "target": Vector3(36.0, 1.15, 0.1), "fov": 60.0},
	{"id": "16b_seal_boarded_night", "eye": Vector3(36.0, 1.5, 3.3), "target": Vector3(36.0, 1.15, 0.1), "fov": 60.0,
		"seal": "boarded", "before": false},
	{"id": "17_plate_night", "eye": Vector3(23.3, 1.65, 1.6), "target": Vector3(24.0, 2.3, 0.1), "fov": 45.0},
	{"id": "17b_plate_enamel_night", "eye": Vector3(23.3, 1.65, 1.6), "target": Vector3(24.0, 2.3, 0.1), "fov": 45.0,
		"plates": "enamel", "before": false},
	{"id": "18_plate_torch", "eye": Vector3(23.3, 1.65, 1.6), "target": Vector3(24.0, 2.3, 0.1), "fov": 45.0, "torch": true},
	{"id": "18b_plate_enamel_torch", "eye": Vector3(23.3, 1.65, 1.6), "target": Vector3(24.0, 2.3, 0.1), "fov": 45.0,
		"torch": true, "plates": "enamel", "before": false},
	{"id": "19_west_end_night", "eye": Vector3(5.6, 1.65, 2.7), "target": Vector3(0.0, 1.3, 1.6), "fov": 70.0},
	{"id": "20_east_end_night", "eye": Vector3(38.4, 1.65, 2.9), "target": Vector3(44.0, 1.3, 1.8), "fov": 70.0},
	{"id": "21_west_end_campus_torch", "eye": Vector3(4.2, 1.65, 2.6), "target": Vector3(-1.5, 0.7, 2.0), "fov": 70.0,
		"torch": true, "campus": true},
	{"id": "22_east_end_campus_torch", "eye": Vector3(39.8, 1.65, 2.6), "target": Vector3(45.5, 0.7, 2.0), "fov": 70.0,
		"torch": true, "campus": true},
]
const G5_DOORS: Array[String] = ["401", "402", "403", "404", "405", "406", "408"]
## T-237 views in the chapter scenes: along the corridor, at door 407, both ends; with Campus (chapter 3) the
## ends open onto the stairs, and the fire door is shown open.
const CHAPTER_OUTPUT := OUTPUT + "round3_playable/"
const CHAPTER_VIEWS: Array[Dictionary] = [
	{"id": "01_west_night", "eye": Vector3(0.7, 1.65, 2.7), "target": Vector3(32, 1.4, 1.2)},
	{"id": "02_east_night", "eye": Vector3(43.3, 1.65, 3.1), "target": Vector3(12, 1.4, 1.1)},
	{"id": "03_door407_night", "eye": Vector3(33.5, 1.65, 3.1), "target": Vector3(32, 1.25, 0)},
	{"id": "04_door407_torch", "eye": Vector3(33.5, 1.65, 3.1), "target": Vector3(32, 1.25, 0), "torch": true},
	{"id": "19_west_end_night", "eye": Vector3(5.6, 1.65, 2.7), "target": Vector3(0.0, 1.3, 1.6), "fov": 70.0},
	{"id": "20_east_end_night", "eye": Vector3(38.4, 1.65, 2.9), "target": Vector3(44.0, 1.3, 1.8), "fov": 70.0},
	{"id": "21_west_end_torch", "eye": Vector3(4.2, 1.65, 2.6), "target": Vector3(-1.5, 0.7, 2.0), "fov": 70.0,
		"torch": true},
	{"id": "22_east_end_torch", "eye": Vector3(39.8, 1.65, 2.6), "target": Vector3(45.5, 0.7, 2.0), "fov": 70.0,
		"torch": true},
	{"id": "11_main_stairs_torch", "eye": Vector3(-1.0, 1.65, 2.5), "target": Vector3(-3.8, -0.7, -1.4),
		"torch": true, "campus": true},
	{"id": "12_fire_stairs_torch", "eye": Vector3(46.5, 1.65, 2.5), "target": Vector3(45.2, -0.7, -1.4),
		"torch": true, "campus": true, "fire_door": true},
	{"id": "23_fire_door_open_torch", "eye": Vector3(40.4, 1.65, 2.9), "target": Vector3(45.0, 1.0, 1.6),
		"fov": 70.0, "torch": true, "campus": true, "fire_door": true},
]
var camera: Camera3D
var torch: SpotLight3D
var campus: Node3D
var floor4: Node3D


func _ready() -> void:
	call_deferred("_run_capture_scene")


func _run_capture_scene() -> void:
	# Smoke tests instantiate this scene as a child; only the launch scene captures.
	if get_tree().current_scene != self:
		return
	if DisplayServer.get_name() == "headless" or RenderingServer.get_current_rendering_method() != "forward_plus":
		_fail("Capture requires a window and Forward+.")
		return
	get_window().mode = Window.MODE_WINDOWED
	get_window().content_scale_size = RESOLUTION
	get_window().size = RESOLUTION
	get_viewport().scaling_3d_scale = 1.0
	var chapter := _chapter_argument()
	if chapter > 0:
		await _capture_chapter(chapter)
		return
	floor4 = FLOOR.instantiate() as Node3D
	# The T-229 survey stays the PS1 baseline; the g5 views switch the corridor themselves.
	floor4.set("upgraded_corridor", "--g5" in OS.get_cmdline_user_args())
	add_child(floor4)
	_add_camera()
	if "--g5" in OS.get_cmdline_user_args():
		PILOT.add_variants(floor4)
		await _capture_g5()
	else:
		await _capture()


## T-235: the whole corridor, same renderer, lights and cameras as the T-229 survey.
func _capture_g5() -> void:
	if DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(G5_OUTPUT)) != OK:
		_fail("Cannot create output directory.")
		return
	var report: Dictionary = {
		"task": "T-235", "godot": Engine.get_version_info().string,
		"renderer": RenderingServer.get_current_rendering_method(), "gpu": RenderingServer.get_video_adapter_name(),
		"resolution": [RESOLUTION.x, RESOLUTION.y], "images": [],
		"lighting": "Unmodified scene lights and environment; optional camera flashlight",
		"capture_kind": "Whole corridor x 0..44 over floor4.tscn, no chapter director or player",
	}
	for view: Dictionary in G5_VIEWS:
		if view.get("campus", false) and campus == null:
			campus = CAMPUS.instantiate() as Node3D
			add_child(campus)
			await get_tree().process_frame
		camera.position = view.eye
		camera.look_at(view.target)
		camera.fov = view.get("fov", 75.0)
		torch.visible = view.get("torch", false)
		PILOT.set_plates(floor4, view.get("plates", "alu"))
		PILOT.set_seal(floor4, view.get("seal", "walled"))
		var swung := false
		for room: String in G5_DOORS:
			var door := floor4.get_node("Corridor/LockedDoor_" + room) as RoomDoor
			var open: bool = view.get("door_open", "") == room
			if door.is_open != open:
				door.set_open(open)
				swung = true
		if swung:
			await get_tree().create_timer(0.5).timeout  # RoomDoor swings over 0.3 s
		var states: Array[String] = ["after"]
		if view.get("before", true):
			states = ["before", "after"]
		for state: String in states:
			Floor4CorridorShell.set_upgraded(floor4, state == "after")
			for frame in range(30):
				await get_tree().process_frame
			await RenderingServer.frame_post_draw
			var captured: Image = get_viewport().get_texture().get_image()
			if captured.get_size() != RESOLUTION:
				_fail("Unexpected capture resolution: %s" % captured.get_size())
				return
			var filename: String = "%s_%s.jpg" % [state, view.id]
			if captured.save_jpg(G5_OUTPUT + filename, 0.94) != OK:
				_fail("Cannot write " + filename)
				return
			report.images.append({"file": filename, "eye": _coords(view.eye), "target": _coords(view.target),
				"fov": camera.fov, "torch": torch.visible, "corridor": state == "after", "campus": campus != null,
				"plates": view.get("plates", "alu"), "seal": view.get("seal", "walled"),
				"door_open": view.get("door_open", "")})
			print("CAPTURE: " + filename)
	var manifest := FileAccess.open(G5_OUTPUT + "g5_capture_report.json", FileAccess.WRITE)
	if manifest == null:
		_fail("Cannot write capture report.")
		return
	manifest.store_string(JSON.stringify(report, "	") + "
")
	manifest.close()
	print("RESULT: corridor g5 capture %d images PASS" % report.images.size())
	App.quit()


func _add_camera() -> void:
	camera = Camera3D.new()
	camera.fov = 75.0
	add_child(camera)
	camera.make_current()
	torch = SpotLight3D.new()
	torch.name = "Flashlight"
	torch.position = Vector3(0.1, -0.08, -0.15)
	torch.light_color = Color(0.9, 0.94, 1.0)
	torch.light_energy = 1.5
	torch.spot_range = 12.0
	torch.spot_angle = 28.0
	torch.shadow_enabled = true
	camera.add_child(torch)


func _chapter_argument() -> int:
	for argument: String in OS.get_cmdline_user_args():
		if argument.begins_with("--chapter="):
			return argument.trim_prefix("--chapter=").to_int()
	return 0


## T-237: the playable corridor as a chapter shows it. The director never starts (lights as the chapter opens);
## the player is hidden and held; sound is muted.
func _capture_chapter(chapter: int) -> void:
	if not chapter in [1, 2, 3, 4]:
		_fail("Unknown chapter %d." % chapter)
		return
	if DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(CHAPTER_OUTPUT)) != OK:
		_fail("Cannot create output directory.")
		return
	AudioServer.set_bus_mute(0, true)
	Chapter1Director.resume_checkpoint = &""
	var scene := (load("res://scenes/main/chapter%d.tscn" % chapter) as PackedScene).instantiate() as Node3D
	scene.get_node("Chapter%dDirector" % chapter).set("auto_start", false)
	add_child(scene)
	for frame in range(3):
		await get_tree().process_frame
	floor4 = scene.get_node("Floor4") as Node3D
	campus = scene.get_node_or_null("Campus") as Node3D
	var player := scene.get_node("Player") as Node3D
	player.visible = false
	player.process_mode = Node.PROCESS_MODE_DISABLED
	for layer: CanvasLayer in scene.find_children("*", "CanvasLayer", false, false):
		layer.visible = layer.name == &"PS1Filter"
	_add_camera()
	var report: Dictionary = {
		"task": "T-237", "chapter": chapter, "godot": Engine.get_version_info().string,
		"renderer": RenderingServer.get_current_rendering_method(), "gpu": RenderingServer.get_video_adapter_name(),
		"resolution": [RESOLUTION.x, RESOLUTION.y], "images": [],
		"lighting": "Chapter scene lights and environment as it opens (director not started); optional camera flashlight",
		"capture_kind": "res://scenes/main/chapter%d.tscn with its PS1 screen filter, HUD and player hidden" % chapter,
		"corridor": floor4.has_node(Floor4CorridorShell.ROOT), "campus": campus != null,
	}
	for view: Dictionary in CHAPTER_VIEWS:
		if view.get("campus", false) and campus == null:
			continue
		if campus != null:
			campus.call("set_fire_door_open", view.get("fire_door", false))
		camera.position = view.eye
		camera.look_at(view.target)
		camera.fov = view.get("fov", 75.0)
		torch.visible = view.get("torch", false)
		for frame in range(30):
			await get_tree().process_frame
		await RenderingServer.frame_post_draw
		var captured: Image = get_viewport().get_texture().get_image()
		if captured.get_size() != RESOLUTION:
			_fail("Unexpected capture resolution: %s" % captured.get_size())
			return
		var filename: String = "ch%d_%s.jpg" % [chapter, view.id]
		if captured.save_jpg(CHAPTER_OUTPUT + filename, 0.92) != OK:
			_fail("Cannot write " + filename)
			return
		report.images.append({"file": filename, "eye": _coords(view.eye), "target": _coords(view.target),
			"fov": camera.fov, "torch": torch.visible, "fire_door_open": view.get("fire_door", false)})
		print("CAPTURE: " + filename)
	var manifest := FileAccess.open(CHAPTER_OUTPUT + "ch%d_capture_report.json" % chapter, FileAccess.WRITE)
	if manifest == null:
		_fail("Cannot write capture report.")
		return
	manifest.store_string(JSON.stringify(report, "\t") + "\n")
	manifest.close()
	print("RESULT: corridor chapter %d capture %d images PASS" % [chapter, report.images.size()])
	App.quit()


func _capture() -> void:
	if DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUTPUT)) != OK:
		_fail("Cannot create output directory.")
		return
	var report: Dictionary = {
		"baseline_commit": "2773a3f608f33a2bda719a3dcfbf74900cfe07c0",
		"godot": Engine.get_version_info().string,
		"renderer": RenderingServer.get_current_rendering_method(),
		"gpu": RenderingServer.get_video_adapter_name(),
		"resolution": [1920, 1080], "images": [],
		"lighting": "Unmodified scene lights and environment; optional camera flashlight",
		"capture_kind": "Static geometry survey, no chapter director or player",
	}
	for view: Dictionary in VIEWS:
		if view.get("campus", false) and campus == null:
			campus = CAMPUS.instantiate() as Node3D
			add_child(campus)
			await get_tree().process_frame
		camera.position = view.eye
		camera.look_at(view.target)
		torch.visible = view.get("torch", false)
		for frame in range(30):
			await get_tree().process_frame
		await RenderingServer.frame_post_draw
		var captured: Image = get_viewport().get_texture().get_image()
		if captured.get_size() != RESOLUTION:
			_fail("Unexpected capture resolution: %s" % captured.get_size())
			return
		var filename: String = "before_%s.jpg" % view.id
		if captured.save_jpg(OUTPUT + filename, 0.94) != OK:
			_fail("Cannot write " + filename)
			return
		report.images.append({"file": filename, "eye": _coords(view.eye), "target": _coords(view.target),
			"fov": camera.fov, "torch": torch.visible, "campus": campus != null})
		print("CAPTURE: " + filename)
	var manifest := FileAccess.open(OUTPUT + "capture_report.json", FileAccess.WRITE)
	if manifest == null:
		_fail("Cannot write capture report.")
		return
	manifest.store_string(JSON.stringify(report, "\t") + "\n")
	manifest.close()
	print("RESULT: corridor capture %d images PASS" % report.images.size())
	App.quit()


func _coords(value: Vector3) -> Array[float]:
	return [value.x, value.y, value.z]


func _fail(message: String) -> void:
	push_error(message)
	App.quit(1)
