extends Node
## Real-renderer wall-clock frame timing, without fixed-fps or capture overhead.

const MAIN := preload("res://scenes/main/main.tscn")
const VIEWS: Array[Dictionary] = [
	{"name": "bed_1_phuc", "eye": Vector3(32, 1.6, -1), "target": Vector3(30.8, 2.0, -3.5)},
	{"name": "bed_2_viet", "eye": Vector3(32, 1.6, -1), "target": Vector3(30.8, 0.6, -3.5)},
	{"name": "bed_3_trung", "eye": Vector3(32, 1.6, -1), "target": Vector3(33.2, 0.6, -3.5)},
	{"name": "bed_4_dat", "eye": Vector3(32, 1.6, -1), "target": Vector3(33.2, 2.0, -3.5)},
	{"name": "door_407", "eye": Vector3(32, 1.6, -3), "target": Vector3(32, 1.5, 0)},
	{"name": "corridor", "eye": Vector3(32, 1.6, 1.2), "target": Vector3(3, 1.6, 1.2)},
	{"name": "washroom", "eye": Vector3(4.8, 1.6, -0.55), "target": Vector3(0.5, 1.3, -2.5)},
]


static func statistics(frame_ms: Array[float]) -> Dictionary:
	if frame_ms.is_empty():
		return {}
	var sorted := frame_ms.duplicate()
	sorted.sort()
	var total := 0.0
	for value: float in frame_ms:
		if not is_finite(value) or value <= 0:
			return {}
		total += value
	return {"frames": frame_ms.size(), "mean_fps": frame_ms.size() * 1000.0 / total,
		"p95_frame_ms": sorted[ceili(0.95 * sorted.size()) - 1], "max_frame_ms": sorted[-1]}


func _ready() -> void:
	_run.call_deferred()


func _run() -> void:
	var report_path := ""
	var frames := 240
	var warmup := 90
	var profile: Dictionary = {}
	var v2 := "--ch1v2" in OS.get_cmdline_user_args()
	for arg: String in OS.get_cmdline_user_args():
		if arg.begins_with("--report="): report_path = arg.trim_prefix("--report=")
		if arg.begins_with("--perf-frames="): frames = int(arg.trim_prefix("--perf-frames="))
		if arg.begins_with("--warmup-frames="): warmup = int(arg.trim_prefix("--warmup-frames="))
		if arg.begins_with("--chapter-profile="):
			var data: Variant = JSON.parse_string(FileAccess.get_file_as_string(arg.trim_prefix("--chapter-profile=")))
			if data is Dictionary: profile = data
	if DisplayServer.get_name() == "headless" or frames < 20 or warmup < 1 or report_path.is_empty():
		_finish(false, "requires renderer, report path, >=20 samples and >=1 warmup frame")
		return
	var window := get_tree().root
	window.content_scale_size = Vector2i(1280, 720)
	window.size = Vector2i(1280, 720)
	DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
	Engine.max_fps = 0
	var scene := (load("res://scenes/main/chapter1.tscn") as PackedScene).instantiate() if v2 else MAIN.instantiate()
	scene.process_mode = Node.PROCESS_MODE_PAUSABLE
	var director := scene.get_node_or_null("Chapter1Director" if v2 else "StoryDirector")
	if director != null:
		director.set("auto_start", false)
	add_child(scene)
	var player := scene.get_node("Player") as CharacterBody3D
	player.set_process_unhandled_input(false)
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	var camera := Camera3D.new()
	camera.fov = 75
	scene.add_child(camera)
	camera.make_current()
	var measurements: Array[Dictionary] = []
	var skipped: Array[String] = []
	var views: Array[Dictionary] = []
	if not v2: views.assign(VIEWS.duplicate(true))
	var perf: Dictionary = profile.get("performance", {})
	if v2:
		for key in ["door", "bed", "washroom", "balcony", "camera"]:
			var spec: Variant = perf.get("camera_view") if key == "camera" else perf.get("views", {}).get(key)
			if not spec is Dictionary or not spec.get("eye") is Array or not spec.get("target") is Array:
				skipped.append("T-162/T-165 view not bound: " + key)
				continue
			if spec.eye.size() != 3 or spec.target.size() != 3:
				_finish(false, "view requires eye/target XYZ: " + key)
				return
			views.append({"name": key, "eye": Vector3(spec.eye[0], spec.eye[1], spec.eye[2]), "target": Vector3(spec.target[0], spec.target[1], spec.target[2])})
	var helper := preload("res://scripts/debug/ch1v2_actions.gd").new()
	helper.world = scene
	helper.bindings = profile.get("actions", {})
	add_child(helper)
	for view: Dictionary in views:
		if view.name == "camera":
			EventBus.cctv_unlocked.emit()
			var outcome: Dictionary = await helper.execute({"op": "phone", "raised": true})
			if outcome.status == "PASS": outcome = await helper.execute({"op": "camera_tab"})
			if outcome.status == "FAIL":
				_finish(false, outcome.reason)
				return
			if outcome.status == "SKIP":
				skipped.append(outcome.reason)
				continue
			var feeds := active_feeds(scene)
			if feeds < 5:
				skipped.append("Camera tab requires 5 active SubViewports; found %d" % feeds)
				continue
		camera.global_position = view.eye
		camera.look_at(view.target)
		player.global_position = view.eye - Vector3(0, 1.57, 0)
		player.velocity = Vector3.ZERO
		for frame in warmup:
			await get_tree().process_frame
		await RenderingServer.frame_post_draw
		var times: Array[float] = []
		var previous := Time.get_ticks_usec()
		for frame in frames:
			await get_tree().process_frame
			await RenderingServer.frame_post_draw
			var now := Time.get_ticks_usec()
			times.append((now - previous) / 1000.0)
			previous = now
		var entry := statistics(times)
		if entry.is_empty():
			_finish(false, "invalid frame sample")
			return
		entry["view"] = view.name
		entry["eye"] = [view.eye.x, view.eye.y, view.eye.z]
		entry["target"] = [view.target.x, view.target.y, view.target.z]
		entry["target_met"] = float(entry.mean_fps) >= 60.0
		if view.name == "camera": entry["active_subviewports"] = active_feeds(scene)
		measurements.append(entry)
		print("PERFORMANCE_VIEW: ", JSON.stringify(entry))
	var report := {"godot": Engine.get_version_info().string, "cpu": OS.get_processor_name(),
		"gpu": RenderingServer.get_video_adapter_name(), "renderer": RenderingServer.get_current_rendering_method(),
		"resolution": [window.size.x, window.size.y], "vsync": false, "max_fps": Engine.max_fps,
		"warmup_frames_per_view": warmup, "sample_frames_per_view": frames, "views": measurements,
		"skipped": skipped, "status": "PASS" if skipped.is_empty() else "SKIP",
		"scope": "chapter 1 v2 profile; story disabled; fixed views; camera tab uses real UI" if v2 else "current main scene; story disabled; fixed camera; player physics/HUD/audio active; not integrated chapter gameplay"}
	var below_target := false
	for entry: Dictionary in measurements:
		if not entry.target_met: below_target = true
	if below_target: report.status = "FAIL"
	var file := FileAccess.open(report_path, FileAccess.WRITE)
	if file == null:
		_finish(false, "cannot write performance JSON")
		return
	file.store_string(JSON.stringify(report, "\t") + "\n")
	file.close()
	if below_target:
		_finish(false, "mean FPS below 60; " + report_path)
	elif not skipped.is_empty():
		print("PLAYTHROUGH_RESULT: SKIP scenario=performance ", "; ".join(skipped))
		App.quit()
	else:
		_finish(true, "%d views; %s" % [measurements.size(), report_path])


static func active_feeds(scene: Node) -> int:
	var active: Array[SubViewport] = []
	for feed: Node in scene.get_tree().get_nodes_in_group(&"cctv_feed"):
		if not scene.is_ancestor_of(feed): continue
		var nodes: Array[Node] = [feed]
		nodes.append_array(feed.find_children("*", "SubViewport", true, false))
		for node: Node in nodes:
			if node is SubViewport and node not in active and node.render_target_update_mode == SubViewport.UPDATE_ALWAYS and node.get_camera_3d() != null:
				active.append(node)
	return active.size()

func _finish(passed: bool, reason: String) -> void:
	print("PLAYTHROUGH_RESULT: %s scenario=performance %s" % ["PASS" if passed else "FAIL", reason])
	App.quit(0 if passed else 1)
