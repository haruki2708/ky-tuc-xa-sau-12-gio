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
	for arg: String in OS.get_cmdline_user_args():
		if arg.begins_with("--report="): report_path = arg.trim_prefix("--report=")
		if arg.begins_with("--perf-frames="): frames = int(arg.trim_prefix("--perf-frames="))
		if arg.begins_with("--warmup-frames="): warmup = int(arg.trim_prefix("--warmup-frames="))
	if DisplayServer.get_name() == "headless" or frames < 20 or warmup < 1 or report_path.is_empty():
		_finish(false, "requires renderer, report path, >=20 samples and >=1 warmup frame")
		return
	var window := get_tree().root
	window.content_scale_size = Vector2i(1280, 720)
	window.size = Vector2i(1280, 720)
	DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
	Engine.max_fps = 0
	var scene := MAIN.instantiate()
	scene.process_mode = Node.PROCESS_MODE_PAUSABLE
	var director := scene.get_node_or_null("StoryDirector")
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
	for view: Dictionary in VIEWS:
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
		measurements.append(entry)
		print("PERFORMANCE_VIEW: ", JSON.stringify(entry))
	var report := {"godot": Engine.get_version_info().string, "cpu": OS.get_processor_name(),
		"gpu": RenderingServer.get_video_adapter_name(), "renderer": RenderingServer.get_current_rendering_method(),
		"resolution": [window.size.x, window.size.y], "vsync": false, "max_fps": Engine.max_fps,
		"warmup_frames_per_view": warmup, "sample_frames_per_view": frames, "views": measurements,
		"scope": "current main scene; story disabled; fixed camera; player physics/HUD/audio active; not integrated chapter gameplay"}
	var file := FileAccess.open(report_path, FileAccess.WRITE)
	if file == null:
		_finish(false, "cannot write performance JSON")
		return
	file.store_string(JSON.stringify(report, "\t") + "\n")
	file.close()
	_finish(true, "7 views; " + report_path)


func _finish(passed: bool, reason: String) -> void:
	print("PLAYTHROUGH_RESULT: %s scenario=performance %s" % ["PASS" if passed else "FAIL", reason])
	App.quit(0 if passed else 1)
