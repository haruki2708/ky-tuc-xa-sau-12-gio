extends Node
## Short renderer benchmark on the real campus and lane A zombies, no story.

const POLICY := preload("res://scripts/debug/ch3_policy.gd")
var profile: Dictionary = {}
var frames: int = 240
var warmup: int = 90
var samples: Array[Dictionary] = []
var failures: Array[String] = []
var skipped: Array[String] = []


func _ready() -> void:
	_run.call_deferred()


func _run() -> void:
	var began := Time.get_ticks_msec()
	var report_path := ""
	for arg: String in OS.get_cmdline_user_args():
		if arg.begins_with("--report="): report_path = arg.trim_prefix("--report=")
		if arg.begins_with("--perf-frames="): frames = int(arg.trim_prefix("--perf-frames="))
		if arg.begins_with("--warmup-frames="): warmup = int(arg.trim_prefix("--warmup-frames="))
		if arg.begins_with("--chapter-profile="):
			var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(arg.trim_prefix("--chapter-profile=")))
			if parsed is Dictionary: profile = parsed
	if frames < 20 or warmup < 1 or DisplayServer.get_name() == "headless": failures.append("requires renderer and valid sample counts")
	if not preload("res://scripts/debug/qa_menu.gd").isolated(): failures.append("requires isolated userdata")
	get_tree().root.size = Vector2i(1280, 720)
	get_tree().root.content_scale_size = Vector2i(1280, 720)
	DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
	Engine.max_fps = 0
	if failures.is_empty():
		for count in [0, 20, 40]:
			var missing := POLICY.preflight(profile, true, count)
			if not missing.is_empty():
				skipped.append("%d zombies: %s" % [count, "; ".join(missing)])
				continue
			await _measure(count)
	var status := "FAIL" if not failures.is_empty() else "SKIP" if not skipped.is_empty() else "PASS"
	var report := {"chapter": 3, "status": status, "measurements": samples, "skipped": skipped, "failures": failures,
		"resolution": [1280, 720], "gpu": RenderingServer.get_video_adapter_name(), "cpu": OS.get_processor_name(),
		"renderer": RenderingServer.get_current_rendering_method(), "godot": Engine.get_version_info().string,
		"real_seconds": (Time.get_ticks_msec() - began) / 1000.0, "frames_per_leg": frames, "warmup_frames": warmup,
		"scope": "Floor4 + Campus; moving camera/AI target; real active zombies; no chapter story or player simulation",
		"target_fps": 60, "minimum_fps": 30, "vsync": false, "max_fps": 0}
	var file := FileAccess.open(report_path, FileAccess.WRITE)
	if file == null: status = "FAIL"; failures.append("cannot write performance JSON")
	else: file.store_string(JSON.stringify(report, "\t") + "\n")
	print("PLAYTHROUGH_RESULT: %s scenario=performance %s %s" % [status, "; ".join(failures), "; ".join(skipped)])
	App.quit(1 if status == "FAIL" else 0)


func _measure(count: int) -> void:
	var world := Node3D.new()
	add_child(world)
	var campus := (load(profile.campus_scene) as PackedScene).instantiate()
	campus.name = "Campus"
	world.add_child(campus)
	var floor_scene := (load(profile.floor4_scene) as PackedScene).instantiate()
	floor_scene.name = "Floor4"
	world.add_child(floor_scene)
	var camera := Camera3D.new()
	world.add_child(camera)
	camera.make_current()
	var target := Node3D.new()
	world.add_child(target)
	var perf: Dictionary = profile.performance
	var route: Array = perf.route
	var points: Array[Vector3] = []
	for point: Dictionary in route:
		var anchor := world.get_node_or_null(str(point.anchor)) as Node3D
		if anchor == null:
			skipped.append("route anchor missing: " + str(point.anchor))
			world.queue_free()
			await get_tree().process_frame
			return
		points.append(anchor.global_position)
	if points.size() < 2:
		failures.append("benchmark requires at least two route anchors")
		world.queue_free()
		await get_tree().process_frame
		return
	target.global_position = points[0]
	camera.global_position = points[0] + Vector3.UP * 1.6
	var zombies: Array[Node3D] = []
	if count > 0:
		var spawn_paths: Array = perf.spawn_paths
		if spawn_paths.size() < count:
			skipped.append("need %d distinct real spawn anchors" % count)
		else:
			for i in count:
				var spawn := world.get_node_or_null(str(spawn_paths[i])) as Node3D
				if spawn == null:
					skipped.append("spawn anchor missing: " + str(spawn_paths[i]))
					break
				var zombie := (load(profile.zombie_scene) as PackedScene).instantiate() as Node3D
				world.add_child(zombie)
				if not zombie.has_method("wake") or not zombie.has_method("set_target"):
					skipped.append("T-182 wake/set_target unavailable")
					break
				zombie.global_position = spawn.global_position
				zombie.set_target(target)
				zombie.wake()
				zombies.append(zombie)
	if zombies.size() == count:
		for frame in warmup: await get_tree().process_frame
		var total: Array[float] = []
		for leg in range(1, points.size()):
			var map := world.get_world_3d().navigation_map
			var path := NavigationServer3D.map_get_path(map, points[leg - 1], points[leg], true)
			if not POLICY.path_reaches(path, points[leg]):
				failures.append("navmesh cannot reach benchmark anchor: " + str(route[leg].anchor))
				break
			var times: Array[float] = []
			var stable := true
			await RenderingServer.frame_post_draw
			var previous := Time.get_ticks_usec()
			for frame in frames:
				var before := target.global_position
				target.global_position = POLICY.path_point(path, float(frame + 1) / frames)
				camera.global_position = target.global_position + Vector3.UP * 1.6
				var toward := target.global_position - before
				if toward.length() > 0.01: camera.look_at(camera.global_position + toward)
				await get_tree().process_frame
				await RenderingServer.frame_post_draw
				var now := Time.get_ticks_usec()
				times.append((now - previous) / 1000.0)
				previous = now
				for zombie: Node3D in zombies:
					if not is_instance_valid(zombie) or zombie.get(str(perf.active_property)) != perf.active_value: stable = false
			if not stable:
				failures.append("active zombie count changed at %s (%d expected)" % [route[leg].zone, count])
				break
			var summary := POLICY.summary(times)
			summary.merge({"zone": route[leg].zone, "anchor": route[leg].anchor, "zombies": count})
			samples.append(summary)
			total.append_array(times)
			if not summary.target_met:
				var warning := "zone=%s zombies=%d mean=%.1f min=%.1f FPS" % [route[leg].zone, count, summary.mean_fps, summary.min_fps]
				print("CH3_PERF_ALERT: ", warning)
				failures.append(warning)
		if not total.is_empty():
			var summary := POLICY.summary(total)
			summary.merge({"zone": "whole_route", "zombies": count})
			samples.append(summary)
	world.queue_free()
	await get_tree().create_timer(0.3).timeout
