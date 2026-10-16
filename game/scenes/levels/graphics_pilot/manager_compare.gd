extends Node3D
## T-219 isolated comparison. Production manager.tscn and chapters keep their bodies.
## Opt-in captures / performance must be coordinated with the integrator first.

const FLOOR: PackedScene = preload("res://scenes/levels/floor4/floor4.tscn")
const BODY_C: PackedScene = preload("res://scenes/entity/manager_body_c.tscn")
const OUTPUT: String = "res://../art_source/graphics_upgrade/manager/previews/"
const CLIPS: Array[StringName] = [&"stand", &"walk", &"ask", &"slash", &"lunge", &"kill"]
const POSITIONS: Dictionary = {"A": Vector3(2.0, 0.0, -2.2), "C": Vector3(4.4, 0.0, -2.2)}
const FPS_VIEWS: Array[Dictionary] = [
	{"id": "centre", "eye": Vector3(5.6, 1.6, -0.9), "target": Vector3(2.8, 0.35, -3.0), "fov": 75.0},
	{"id": "door_overview", "eye": Vector3(2.1, 1.65, -0.35), "target": Vector3(4.0, 0.9, -4.8), "fov": 80.0},
]
var room: Node3D
var rig: Node3D
var camera: Camera3D
var torch: SpotLight3D
var tube: OmniLight3D
var bodies: Dictionary = {}
var overlay: CanvasLayer
var light_mode: int = 2
var view_mode: int = 0
var current_clip: StringName = &"stand"
var freeze: bool = false
var automated: bool = false
var light_clock: float = 0.0


func _ready() -> void:
	for language: String in ["vi", "en"]:
		TranslationServer.add_translation(load("res://assets/models/characters/manager/pilot_strings.%s.translation" % language))
	var floor4: Node3D = FLOOR.instantiate() as Node3D
	add_child(floor4)
	room = floor4.get_node("Room407") as Node3D
	for number: int in [1, 2, 4]:
		(room.get_node("Anchors/Corpse%d" % number) as Node3D).hide()
	(room.get_node("Ch2Bathroom/Reflection") as Node3D).hide()
	room.set_blood_stage(0)
	room.set_slashed(0.0)
	room.set_desk_lamp(true)
	tube = room.get_node("Room407MainLight") as OmniLight3D
	tube.set_flicker(false)
	rig = Node3D.new()
	rig.name = "Rig"
	add_child(rig)
	var head: Node3D = Node3D.new()
	head.name = "Head"
	rig.add_child(head)
	camera = Camera3D.new()
	camera.name = "Camera3D"
	head.add_child(camera)
	camera.make_current()
	torch = SpotLight3D.new()
	torch.name = "Flashlight"
	torch.position = Vector3(0.1, -0.08, -0.15)
	torch.light_color = Color(0.9, 0.94, 1.0)
	torch.light_energy = 2.5
	torch.shadow_enabled = true
	torch.spot_range = 12.0
	torch.spot_angle = 28.0
	camera.add_child(torch)
	_add_body("C", BODY_C)
	if ResourceLoader.exists("res://scenes/entity/manager_body_a.tscn"):
		_add_body("A", load("res://scenes/entity/manager_body_a.tscn") as PackedScene)
	_create_overlay()
	get_window().mode = Window.MODE_WINDOWED
	get_window().content_scale_size = Vector2i(1920, 1080)
	get_window().size = Vector2i(1920, 1080)
	set_view(0)
	play_clip(&"stand")
	set_light(2)
	var args: PackedStringArray = OS.get_cmdline_user_args()
	if "--manager-capture" in args or "--manager-fps" in args or "--manager-reference-before" in args or "--manager-reference-after" in args:
		automated = true
		overlay.hide()
		if DisplayServer.get_name() == "headless" or RenderingServer.get_current_rendering_method() != "forward_plus":
			push_error("Manager captures and FPS require Forward+ with a display.")
			App.quit(1)
			return
		DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUTPUT))
		if "--manager-reference-before" in args or "--manager-reference-after" in args:
			await _capture_reference("before" if "--manager-reference-before" in args else "after")
		if "--manager-capture" in args:
			await _capture_set()
			await _capture_review_details()
		if "--manager-fps" in args:
			await _measure_fps()
		App.quit()


func _capture_reference(stage: String) -> void:
	# The reference uses its untouched source rig, bind pose and animation data.
	# It is deliberately excluded from the candidate/FPS dictionary.
	if bodies.has("A"):
		(bodies.A as Node3D).hide()
	set_light(2)
	_freeze_at(&"stand", 0.0)
	for version: String in ["original", "v3_original"]:
		var reference: Node3D = load("res://assets/models/characters/manager/quaternius_%s.glb" % version).instantiate() as Node3D
		room.add_child(reference)
		reference.position = POSITIONS.A
		var player: AnimationPlayer = reference.find_child("AnimationPlayer", true, false) as AnimationPlayer
		player.play(&"Idle")
		player.seek(0.0, true)
		player.pause()
		await _settle(2)
		set_view(0)
		await _save("reference_%s_%s_front.png" % [version, stage])
		reference.queue_free()
		await _settle(2)
	if stage == "after":
		var shared_source: Node3D = load("res://assets/models/characters/manager/manager_motion_source.glb").instantiate() as Node3D
		room.add_child(shared_source)
		shared_source.position = POSITIONS.A
		var source_player: AnimationPlayer = shared_source.find_child("AnimationPlayer", true, false) as AnimationPlayer
		# Play the exact same shared library, including the common spine hunch.
		source_player.remove_animation_library(&"")
		source_player.add_animation_library(&"", load("res://assets/models/characters/manager/manager_shared.tres"))
		source_player.play(&"stand")
		source_player.seek(0.0, true)
		source_player.pause()
		await _settle(2)
		set_view(0)
		await _save("reference_shared_after_front.png")
		shared_source.queue_free()
		await _settle(2)
	if bodies.has("A"):
		(bodies.A as Node3D).show()


func _add_body(id: String, scene: PackedScene) -> void:
	var body: Node3D = scene.instantiate() as Node3D
	body.name = "Candidate" + id
	room.add_child(body)
	body.position = POSITIONS[id]
	body.rotation.y = PI
	bodies[id] = body


func _create_overlay() -> void:
	overlay = CanvasLayer.new()
	add_child(overlay)
	var help: Label = Label.new()
	help.text = tr("UI_MANAGER_PILOT_CONTROLS")
	help.position = Vector2(32, 1015)
	help.add_theme_font_size_override("font_size", 22)
	overlay.add_child(help)
	for id: String in ["A", "C"]:
		var label: Label = Label.new()
		label.text = tr("UI_MANAGER_PILOT_" + id + ("_PENDING" if id == "A" and not bodies.has("A") else ""))
		label.position = Vector2(340 if id == "A" else 1160, 44)
		label.add_theme_font_size_override("font_size", 26)
		overlay.add_child(label)


func play_clip(clip: StringName) -> void:
	current_clip = clip
	freeze = false
	for body: Node3D in bodies.values():
		var player: AnimationPlayer = body.get_node("AnimationPlayer") as AnimationPlayer
		player.stop()
		player.play(clip)
		player.advance(0.0)


func set_light(mode: int) -> void:
	light_mode = mode
	torch.visible = mode == 1
	tube.visible = mode >= 2
	tube.light_energy = tube.get("flicker_energy") if mode >= 2 else 0.0
	light_clock = 0.0


func _process(delta: float) -> void:
	# During performance, mode 2 holds the flicker peak like the D-114 reference.
	if light_mode == 3:
		light_clock += delta
		var pulse: float = 0.15 if fmod(light_clock, 0.33) < 0.055 else 1.0
		tube.light_energy = float(tube.get("flicker_energy")) * pulse


func _aim(eye: Vector3, target: Vector3, fov: float) -> void:
	rig.global_position = room.to_global(Vector3(eye.x, 0.0, eye.z))
	(camera.get_parent() as Node3D).position.y = eye.y
	camera.look_at(room.to_global(target))
	camera.fov = fov


func set_view(mode: int) -> void:
	view_mode = mode % 4
	var c: Vector3 = POSITIONS.C
	match view_mode:
		0: _aim(Vector3(3.2, 1.10, -0.15), Vector3(3.2, 0.95, -2.2), 68.0)
		1:
			var body: Node3D = bodies.C
			var skeleton: Skeleton3D = body.find_child("GeneralSkeleton", true, false) as Skeleton3D
			var head: Vector3 = room.to_local(skeleton.to_global(skeleton.get_bone_global_pose(skeleton.find_bone("Head")).origin)) + Vector3.UP * 0.075
			_aim(head + Vector3(0, 0, 1.0), head, 36.0)
		2: _aim(c + Vector3(-1.8, 1.15, 1.5), c + Vector3(0, 1.1, 0), 55.0)
		3: _aim(FPS_VIEWS[0].eye, FPS_VIEWS[0].target, FPS_VIEWS[0].fov)


func _unhandled_key_input(event: InputEvent) -> void:
	if automated or not event is InputEventKey or not event.pressed or event.echo:
		return
	var key: int = event.physical_keycode
	if key >= KEY_1 and key <= KEY_6:
		play_clip(CLIPS[key - KEY_1])
	match key:
		KEY_L: set_light((light_mode + 1) % 4)
		KEY_V: set_view(view_mode + 1)
		KEY_H: overlay.visible = not overlay.visible
		KEY_P:
			freeze = not freeze
			for body: Node3D in bodies.values():
				var player: AnimationPlayer = body.get_node("AnimationPlayer") as AnimationPlayer
				if freeze: player.pause()
				else: player.play()
		KEY_F12:
			var shown: bool = overlay.visible
			overlay.hide()
			await _save("manual_%d.png" % Time.get_unix_time_from_system())
			overlay.visible = shown
		KEY_ESCAPE: App.quit()


func _settle(frames: int = 60) -> void:
	for index: int in frames:
		await get_tree().process_frame


func _freeze_at(clip: StringName, time: float) -> void:
	play_clip(clip)
	for body: Node3D in bodies.values():
		var player: AnimationPlayer = body.get_node("AnimationPlayer") as AnimationPlayer
		player.seek(time, true)
		player.pause()
	freeze = true


func _save(file: String) -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUTPUT))
	await _settle()
	await RenderingServer.frame_post_draw
	assert(get_viewport().get_texture().get_image().save_png(OUTPUT + file) == OK)
	print("T219_CAPTURE ", file)


func _capture_set() -> void:
	var images: Array[String] = []
	var face_flashlight: Dictionary = {}
	for spec: Dictionary in [
		{"id": "full_body_tube", "view": 0, "light": 2, "clip": &"stand", "time": 0.0},
		{"id": "face_1m_tube", "view": 1, "light": 2, "clip": &"stand", "time": 0.0},
		{"id": "full_body_flashlight", "view": 0, "light": 1, "clip": &"stand", "time": 0.0},
		{"id": "face_1m_flashlight", "view": 1, "light": 1, "clip": &"ask", "time": 0.6},
		{"id": "slash_windup", "view": 2, "light": 2, "clip": &"slash", "time": 0.10},
		{"id": "slash_contact", "view": 2, "light": 2, "clip": &"slash", "time": 0.25},
		{"id": "slash_recovery", "view": 2, "light": 2, "clip": &"slash", "time": 0.38},
		{"id": "tube_flicker", "view": 0, "light": 3, "clip": &"stand", "time": 0.0},
	]:
		set_light(spec.light)
		_freeze_at(spec.clip, spec.time)
		await _settle(2)
		set_view(spec.view)
		var file: String = spec.id + ".png"
		await _save(file)
		if spec.id == "face_1m_flashlight":
			face_flashlight = _flashlight_shadow_report()
		images.append(file)
	var report: Dictionary = _metadata()
	report["images"] = images
	report["a_available"] = bodies.has("A")
	report["face_flashlight_shadow"] = face_flashlight
	_write_json("capture_report.json", report)
	print("RESULT: T219 capture %d images PASS" % images.size())


func _metadata() -> Dictionary:
	return {"godot": Engine.get_version_info().string, "renderer": RenderingServer.get_current_rendering_method(),
		"gpu": RenderingServer.get_video_adapter_name(), "resolution": [get_viewport().get_visible_rect().size.x, get_viewport().get_visible_rect().size.y],
		"scene": scene_file_path, "utc": Time.get_datetime_string_from_system(true)}


func _capture_review_details() -> void:
	set_light(2)
	_freeze_at(&"slash", 0.10)
	await _settle(2)
	var body: Node3D = bodies.C
	var skeleton: Skeleton3D = body.find_child("GeneralSkeleton", true, false) as Skeleton3D
	var elbow: Vector3 = room.to_local(skeleton.to_global(skeleton.get_bone_global_pose(skeleton.find_bone("RightLowerArm")).origin))
	_aim(elbow + Vector3(-0.65, 0.05, 0.60), elbow, 40.0)
	await _save("elbow_windup_close.png")
	var sheet: Image = Image.create(1920, 1080, false, Image.FORMAT_RGB8)
	var frames: Array[Dictionary] = []
	for index: int in CLIPS.size():
		var clip: StringName = CLIPS[index]
		var player: AnimationPlayer = body.get_node("AnimationPlayer") as AnimationPlayer
		var time: float = player.get_animation(clip).length * 0.5
		_freeze_at(clip, time)
		_aim(POSITIONS.C + Vector3(-1.2, 1.1, 1.6), POSITIONS.C + Vector3(0, 0.95, 0), 60.0)
		await _settle()
		await RenderingServer.frame_post_draw
		# Deterministic contact sheet from actual rendered pixels; no art retouching.
		var cell: Image = get_viewport().get_texture().get_image().get_region(Rect2i(320, 0, 1280, 1080))
		cell.resize(640, 540, Image.INTERPOLATE_LANCZOS)
		cell.convert(Image.FORMAT_RGB8)
		sheet.blit_rect(cell, Rect2i(0, 0, 640, 540), Vector2i((index % 3) * 640, (index / 3) * 540))
		frames.append({"clip": clip, "time": time, "row": index / 3, "column": index % 3})
	assert(sheet.save_png(OUTPUT + "six_clips_midpoint.png") == OK)
	var report: Dictionary = _metadata()
	report["cells_left_to_right_top_to_bottom"] = frames
	report["flashlight_shadow"] = _flashlight_shadow_report()
	_write_json("review_capture_report.json", report)
	print("RESULT: T219 elbow and six-clip contact sheet PASS")


func _flashlight_shadow_report() -> Dictionary:
	var phone: Node3D = load("res://scenes/player/phone_item.tscn").instantiate() as Node3D
	var game_torch: SpotLight3D = phone.find_child("Flashlight", true, false) as SpotLight3D
	var room_values: Dictionary = room.get_script().get_script_constant_map()["ROOM_TORCH"]
	var result: Dictionary = {}
	for property: String in ["shadow_enabled", "shadow_bias", "shadow_normal_bias", "shadow_blur", "shadow_opacity", "light_size"]:
		result[property] = {"pilot_in_room407": torch.get(property), "phone_base": game_torch.get(property), "phone_in_room407": room_values.get(property, game_torch.get(property))}
	result["room407_override"] = {"energy": torch.light_energy, "angle": torch.spot_angle, "range": torch.spot_range, "attenuation": torch.spot_angle_attenuation}
	phone.free()
	return result


func _measure_fps() -> void:
	DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
	Engine.max_fps = 0
	set_light(2)
	play_clip(&"slash")
	var rows: Array[Dictionary] = []
	for id: String in bodies:
		for other: String in bodies:
			(bodies[other] as Node3D).visible = other == id
		(bodies[id] as Node3D).position = Vector3(4.1, 0.0, -2.2)
		for view: Dictionary in FPS_VIEWS:
			_aim(view.eye, view.target, view.fov)
			await _settle(90)
			var samples: Array[float] = []
			var previous: int = Time.get_ticks_usec()
			for frame: int in 240:
				await get_tree().process_frame
				var now: int = Time.get_ticks_usec()
				samples.append(float(now - previous) / 1000.0)
				previous = now
			var total: float = 0.0
			for value: float in samples:
				total += value
			var sorted: Array[float] = samples.duplicate()
			sorted.sort()
			rows.append({"variant": id, "view": view.id, "clip": "slash", "light": "tube_peak", "frames": 240,
				"fps": 240000.0 / total, "p95_ms": sorted[227], "frame_ms": samples,
				"visible_candidates": 1})
	var report: Dictionary = _metadata()
	report["rows"] = rows
	report["a_available"] = bodies.has("A")
	report["warmup_frames"] = 90
	report["vsync"] = "disabled"
	report["scope"] = "D-114 isolated floor4, room lights and mirrors; no player/HUD/story, one visible animated manager"
	_write_json("fps_report.json", report)
	for row: Dictionary in rows:
		print("T219_FPS %s %s %.1f FPS p95 %.2f ms" % [row.variant, row.view, row.fps, row.p95_ms])
	print("RESULT: T219 FPS measurement complete")


func _write_json(file: String, data: Dictionary) -> void:
	var output: FileAccess = FileAccess.open(OUTPUT + file, FileAccess.WRITE)
	output.store_string(JSON.stringify(data, "\t") + "\n")
	output.close()
