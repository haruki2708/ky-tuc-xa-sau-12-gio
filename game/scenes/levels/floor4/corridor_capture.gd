extends Node3D
## T-229: static survey cameras only; no player, director, bot or performance sampling.
## T-233: "-- --g5" captures the pilot segment (corridor_g5_pilot.gd) instead: after_* for every G5 view,
## before_* (the same camera, segment off) for the views T-229 had not taken, and variant views.
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
## T-233 views. 01-04 reuse T-229's cameras (their before_* are T-229's); "before" also renders the PS1
## corridor; "railing" picks the railing variant; "door406_open" swings RoomDoor 406 open first.
const G5_VIEWS: Array[Dictionary] = [
	{"id": "01_west_night", "eye": Vector3(0.7, 1.65, 2.7), "target": Vector3(32, 1.4, 1.2)},
	{"id": "02_east_night", "eye": Vector3(43.3, 1.65, 3.1), "target": Vector3(12, 1.4, 1.1)},
	{"id": "03_door407_night", "eye": Vector3(33.5, 1.65, 3.1), "target": Vector3(32, 1.25, 0)},
	{"id": "04_door407_torch", "eye": Vector3(33.5, 1.65, 3.1), "target": Vector3(32, 1.25, 0), "torch": true},
	{"id": "13_door406_night", "eye": Vector3(26.7, 1.55, 1.25), "target": Vector3(27.75, 1.0, 0.1), "fov": 60.0, "before": true},
	{"id": "14_door406_torch", "eye": Vector3(26.7, 1.55, 1.25), "target": Vector3(27.75, 1.0, 0.1), "fov": 60.0, "before": true, "torch": true},
	{"id": "15_railing_night", "eye": Vector3(29.6, 1.5, 2.4), "target": Vector3(31.2, 0.55, 3.99), "fov": 65.0, "before": true},
	{"id": "16_railing_torch", "eye": Vector3(29.6, 1.5, 2.4), "target": Vector3(31.2, 0.55, 3.99), "fov": 65.0, "before": true, "torch": true},
	{"id": "17_wall_base_torch", "eye": Vector3(30.7, 0.95, 1.15), "target": Vector3(29.9, 0.1, 0.1), "fov": 65.0, "before": true, "torch": true},
	{"id": "18_ceiling_lamp_night", "eye": Vector3(29.8, 1.6, 2.7), "target": Vector3(32.0, 2.95, 1.9), "fov": 70.0, "before": true},
	{"id": "19_door406_open_torch", "eye": Vector3(26.3, 1.6, 2.5), "target": Vector3(28.2, 1.0, 0.3), "fov": 70.0, "before": true, "torch": true, "door406_open": true},
	{"id": "20_railing_night_classic", "eye": Vector3(29.6, 1.5, 2.4), "target": Vector3(31.2, 0.55, 3.99), "fov": 65.0, "railing": "classic"},
	# Closer than 01: the segment between PS1 corridor on both sides.
	{"id": "21_segment_in_corridor_night", "eye": Vector3(19.5, 1.65, 3.0), "target": Vector3(34.0, 1.3, 0.9), "before": true},
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
	floor4 = FLOOR.instantiate() as Node3D
	add_child(floor4)
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
	if "--g5" in OS.get_cmdline_user_args():
		PILOT.build(floor4)
		await _capture_g5()
	else:
		await _capture()


## T-233: the pilot segment, same renderer, lights and cameras as the T-229 survey.
func _capture_g5() -> void:
	if DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUTPUT)) != OK:
		_fail("Cannot create output directory.")
		return
	var report: Dictionary = {
		"task": "T-233", "godot": Engine.get_version_info().string,
		"renderer": RenderingServer.get_current_rendering_method(), "gpu": RenderingServer.get_video_adapter_name(),
		"resolution": [RESOLUTION.x, RESOLUTION.y], "images": [],
		"lighting": "Unmodified scene lights and environment; optional camera flashlight",
		"capture_kind": "Pilot segment x 26..34 over floor4.tscn, no chapter director or player",
	}
	var door := floor4.get_node("Corridor/LockedDoor_406") as RoomDoor
	for view: Dictionary in G5_VIEWS:
		camera.position = view.eye
		camera.look_at(view.target)
		camera.fov = view.get("fov", 75.0)
		torch.visible = view.get("torch", false)
		PILOT.set_railing(floor4, view.get("railing", "dense"))
		var open: bool = view.get("door406_open", false)
		if door.is_open != open:
			door.set_open(open)
			await get_tree().create_timer(0.5).timeout  # RoomDoor swings over 0.3 s
		var states: Array[String] = ["after"]
		if view.get("before", false):
			states = ["before", "after"]
		for state: String in states:
			PILOT.set_upgraded(floor4, state == "after")
			for frame in range(30):
				await get_tree().process_frame
			await RenderingServer.frame_post_draw
			var captured: Image = get_viewport().get_texture().get_image()
			if captured.get_size() != RESOLUTION:
				_fail("Unexpected capture resolution: %s" % captured.get_size())
				return
			var filename: String = "%s_%s.jpg" % [state, view.id]
			if captured.save_jpg(OUTPUT + filename, 0.94) != OK:
				_fail("Cannot write " + filename)
				return
			report.images.append({"file": filename, "eye": _coords(view.eye), "target": _coords(view.target),
				"fov": camera.fov, "torch": torch.visible, "segment": state == "after",
				"railing": view.get("railing", "dense"), "door406_open": view.get("door406_open", false)})
			print("CAPTURE: " + filename)
	var manifest := FileAccess.open(OUTPUT + "g5_capture_report.json", FileAccess.WRITE)
	if manifest == null:
		_fail("Cannot write capture report.")
		return
	manifest.store_string(JSON.stringify(report, "\t") + "\n")
	manifest.close()
	print("RESULT: corridor g5 capture %d images PASS" % report.images.size())
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
