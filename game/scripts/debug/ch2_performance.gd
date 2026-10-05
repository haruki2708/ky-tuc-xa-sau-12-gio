extends "res://scripts/debug/performance_bot.gd"
## Measure the real shower, not a substitute particle scene. Fixture API
## and measured state must both be bound before collecting any FPS samples.


func _run() -> void:
	var began := Time.get_ticks_msec()
	var path := ""
	var data: Dictionary = {}
	var frames := 240
	var warmup := 90
	for arg: String in OS.get_cmdline_user_args():
		if arg.begins_with("--report="): path = arg.trim_prefix("--report=")
		if arg.begins_with("--perf-frames="): frames = int(arg.trim_prefix("--perf-frames="))
		if arg.begins_with("--warmup-frames="): warmup = int(arg.trim_prefix("--warmup-frames="))
		if arg.begins_with("--chapter-profile="):
			var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(arg.trim_prefix("--chapter-profile=")))
			if parsed is Dictionary: data = parsed
	var report := {"chapter": 2, "status": "SKIP", "views": [], "skipped": [],
		"scope": "real chapter 2 bathroom; story disabled; hot water active at steam 0 and 1",
		"godot": Engine.get_version_info().string, "cpu": OS.get_processor_name(), "gpu": RenderingServer.get_video_adapter_name(),
		"renderer": RenderingServer.get_current_rendering_method(), "resolution": [1280, 720], "vsync": false,
		"max_fps": 0, "sample_frames_per_view": frames, "warmup_frames_per_view": warmup}
	var reason := ""
	var missing: Array[String] = []
	if not preload("res://scripts/debug/qa_menu.gd").isolated(): reason = "requires isolated tools/playthrough.ps1 launch"
	if DisplayServer.get_name() == "headless" or frames < 20 or warmup < 1: reason = "requires real renderer and valid sample counts"
	if not data.get("scene") is String or not ResourceLoader.exists(str(data.get("scene", ""))): missing.append("T-170 chapter 2 scene not integrated")
	var perf: Dictionary = data.get("performance", {})
	for key in ["view", "setup", "hot_water", "steam_0", "steam_1"]:
		if perf.get(key) == null: missing.append("T-172/T-174 performance binding missing: " + key)
	var scene: Node
	if missing.is_empty() and reason.is_empty():
		var point: Dictionary = perf.view
		var action_class := preload("res://scripts/debug/chapter_actions.gd")
		if not action_class.valid({"op": "goto", "position": point.get("eye")}) or not action_class.valid({"op": "goto", "position": point.get("target")}) or point.eye == point.target:
			reason = "invalid bathroom eye/target coordinates"
		else:
			scene = (load(data.scene) as PackedScene).instantiate()
			scene.process_mode = Node.PROCESS_MODE_PAUSABLE
			var director := scene.get_node_or_null(str(data.get("director", "Chapter2Director")))
			if director == null or not "auto_start" in director:
				missing.append("T-170 auto_start not available for repeatable performance fixture")
			else:
				director.auto_start = false
				add_child(scene)
				var window := get_tree().root
				window.content_scale_size = Vector2i(1280, 720)
				window.size = Vector2i(1280, 720)
				DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
				Engine.max_fps = 0
				var helper := preload("res://scripts/debug/ch2_actions.gd").new()
				helper.profile = {"actions": perf}
				helper.world = scene
				add_child(helper)
				var camera := Camera3D.new()
				camera.fov = 75
				scene.add_child(camera)
				camera.global_position = Vector3(point.eye[0], point.eye[1], point.eye[2])
				camera.look_at(Vector3(point.target[0], point.target[1], point.target[2]))
				camera.make_current()
				for key in ["setup", "hot_water", "steam_0", "steam_1"]:
					var outcome: Dictionary = await helper.physical(key)
					if outcome.status != "PASS":
						if outcome.status == "FAIL": reason = outcome.reason
						else: missing.append(outcome.reason)
						break
					if key in ["setup", "hot_water"]: continue
					for frame in warmup: await get_tree().process_frame
					await RenderingServer.frame_post_draw
					var times: Array[float] = []
					var previous := Time.get_ticks_usec()
					var stable := true
					for frame in frames:
						await get_tree().process_frame
						await RenderingServer.frame_post_draw
						var now := Time.get_ticks_usec()
						times.append((now - previous) / 1000.0)
						previous = now
						if not helper.acknowledged("hot_water") or not helper.acknowledged(key): stable = false
					if not stable:
						reason = "water/steam state changed while sampling " + key
						break
					var summary := statistics(times)
					summary["view"] = key + "_hot_water"
					summary["target_met"] = float(summary.get("mean_fps", 0.0)) >= 60.0
					summary["eye"] = point.eye
					summary["target"] = point.target
					summary["steam_level"] = 0 if key == "steam_0" else 1
					summary["hot_water_running"] = true
					report.views.append(summary)
					if not summary.target_met: reason = "mean FPS below 60"
	if is_instance_valid(scene) and not scene.is_inside_tree(): scene.free()
	report.skipped = missing
	report["reason"] = reason
	report["real_seconds"] = (Time.get_ticks_msec() - began) / 1000.0
	report.status = "FAIL" if not reason.is_empty() else "SKIP" if not missing.is_empty() else "PASS"
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		report.status = "FAIL"
		report.reason = "cannot write performance report"
	else:
		file.store_string(JSON.stringify(report, "\t") + "\n")
		file.close()
	print("PLAYTHROUGH_RESULT: %s scenario=performance %s %s" % [report.status, report.reason, "; ".join(missing)])
	App.quit(1 if report.status == "FAIL" else 0)
