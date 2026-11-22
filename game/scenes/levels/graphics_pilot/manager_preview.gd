extends Node3D
## T-219 (D-118, D-120): the Tripo dorm manager standing in the playable room 407 (D-113 lighting).
## Free view: 1-6 play stand/walk/ask/slash/lunge/kill, L cycles night/torch/tube,
## C cycles cameras, R toggles the door reach (left arm), Space pauses.
## Opt-in captures: -- --manager-capture (needs Forward+).

const FLOOR := preload("res://scenes/levels/floor4/floor4.tscn")
const BODY := preload("res://scenes/entity/manager_body.tscn")
const OUTPUT := "res://../art_source/graphics_upgrade/manager/previews/"
const ORIGIN := Vector3(30, 0, 0)
## Room-local spot on the floor mat between the bunks, facing the door.
const STAND := Vector3(3.6, 0.0, -2.9)
const CLIPS: Array[StringName] = [&"stand", &"walk", &"ask", &"slash", &"lunge", &"kill"]
const LIGHTS: Array[String] = ["night", "torch", "tube"]
## Room-local eyes; targets are offsets from the manager's feet.
const VIEWS := [
	{"id": "full", "eye": Vector3(2.3, 1.6, -0.6), "aim": Vector3(0.0, 0.95, 0.0), "fov": 60.0},
	{"id": "face", "eye": Vector3(3.45, 1.62, -1.95), "aim": Vector3(0.0, 1.58, 0.0), "fov": 45.0},
	{"id": "side", "eye": Vector3(5.6, 1.5, -2.2), "aim": Vector3(0.0, 0.95, 0.0), "fov": 60.0},
	{"id": "low", "eye": Vector3(3.1, 0.55, -1.7), "aim": Vector3(0.0, 1.3, 0.0), "fov": 60.0},
]
## id, view, light, clip, time (s)[, door reach] — the review set.
const SHOTS := [
	["full_tube", "full", "tube", &"stand", 0.0],
	["full_torch", "full", "torch", &"stand", 0.0],
	["full_night", "full", "night", &"stand", 0.0],
	["face_tube", "face", "tube", &"stand", 0.0],
	["face_torch", "face", "torch", &"stand", 0.0],
	["side_tube", "side", "tube", &"stand", 0.0],
	["walk_tube", "full", "tube", &"walk", 0.6],
	["ask_tube", "full", "tube", &"ask", 2.0],
	["slash_windup_tube", "full", "tube", &"slash", 0.62],
	["slash_chop_tube", "full", "tube", &"slash", 1.0],
	["slash_side_torch", "side", "torch", &"slash", 0.62],
	["lunge_tube", "full", "tube", &"lunge", 0.3],
	["kill_low_torch", "low", "torch", &"kill", 1.1],
	["reach_side_tube", "side", "tube", &"stand", 0.0, true],
]

var floor4: Node3D
var room: Node3D
var body: Node3D
var player: AnimationPlayer
var camera: Camera3D
var torch: SpotLight3D
var rig: Node3D
var view_index: int = 0
var light_index: int = 2
var clip_index: int = 0
var reach: bool = false


func _ready() -> void:
	floor4 = FLOOR.instantiate() as Node3D
	add_child(floor4)
	room = floor4.get_node("Room407") as Node3D
	# T-268: --motion=mx puts the pilot's Mixamo walk and slash on him (set before the body is made).
	for arg: String in OS.get_cmdline_user_args():
		if arg.begins_with("--motion="):
			ManagerBody.motion = StringName(arg.trim_prefix("--motion="))
	body = BODY.instantiate() as Node3D
	add_child(body)
	body.position = ORIGIN + STAND
	player = body.find_children("*", "AnimationPlayer", true, false)[0] as AnimationPlayer
	# The camera rig carries Head/Camera3D like the player, so room 407 treats it as the viewer (D-104/D-105).
	rig = Node3D.new()
	rig.name = "Rig"
	add_child(rig)
	var head := Node3D.new()
	head.name = "Head"
	rig.add_child(head)
	camera = Camera3D.new()
	head.add_child(camera)
	camera.make_current()
	torch = SpotLight3D.new()
	torch.name = "Flashlight"
	torch.position = Vector3(0.1, -0.08, -0.15)
	torch.light_color = Color(0.9, 0.94, 1)
	torch.light_energy = 1.5
	torch.shadow_enabled = true
	torch.spot_range = 12.0
	torch.spot_angle = 28.0
	camera.add_child(torch)
	_apply(VIEWS[0], LIGHTS[light_index], CLIPS[0], -1.0)
	if "--manager-capture" in OS.get_cmdline_user_args():
		await _capture()
	elif "--motion-compare" in OS.get_cmdline_user_args():
		await _motion_compare()


func _apply(view: Dictionary, light: String, clip: StringName, time: float, reach_door: bool = false) -> void:
	var target: Vector3 = ORIGIN + STAND + view.aim
	rig.position = ORIGIN + Vector3(view.eye.x, 0.0, view.eye.z)
	var aim: Vector3 = target - (ORIGIN + view.eye)
	rig.rotation.y = atan2(-aim.x, -aim.z)
	(camera.get_parent() as Node3D).position.y = view.eye.y
	camera.fov = view.fov
	camera.look_at(target)
	# The manager faces the camera (the player) as in the chapters; the side view shows his profile
	# while he still faces the door camera. The body scene looks down -Z.
	var facing: Vector3 = (VIEWS[0].eye if view.id == "side" else view.eye) as Vector3
	var to_eye: Vector3 = (ORIGIN + facing) - body.position
	body.rotation.y = atan2(-to_eye.x, -to_eye.z)
	torch.visible = light == "torch"
	# Ceiling tube at its flicker peak (the chapters light it only while it flickers).
	var tube := room.get_node("Room407MainLight") as OmniLight3D
	tube.visible = light == "tube"
	tube.light_energy = tube.flicker_energy if light == "tube" else 0.0
	# What DormManager.open_door tweens (D-120).
	(body.find_child("LeftArm", true, false) as Node3D).rotation.x = PI * 0.45 if reach_door else 0.0
	player.play(clip)
	if time >= 0.0:
		player.seek(time, true)
		player.pause()


func _unhandled_input(event: InputEvent) -> void:
	if not event is InputEventKey or not event.pressed:
		return
	var key: Key = (event as InputEventKey).keycode
	if key >= KEY_1 and key < KEY_1 + CLIPS.size():
		clip_index = key - KEY_1
	elif key == KEY_L:
		light_index = (light_index + 1) % LIGHTS.size()
	elif key == KEY_R:
		reach = not reach
	elif key == KEY_C:
		view_index = (view_index + 1) % VIEWS.size()
	elif key == KEY_SPACE:
		if player.is_playing():
			player.pause()
		else:
			player.play()
		return
	else:
		return
	_apply(VIEWS[view_index], LIGHTS[light_index], CLIPS[clip_index], -1.0, reach)


## T-268 (motion pilot): -- --motion-compare walks him along the floor 4 corridor at chapter 1's
## pace (WALK_SPEED, as manager.gd plays a walk: Tripo at x1, a packed one at its feet's pace), then
## stands and chops six times at the game's 0.45 s a chop (as manager.gd plays slash), seen from
## beside him and from the front. Recorded once as he is and once with --motion=mx, then put side by side.
const WALK_SPEED := 1.3
const CHOP_SECONDS := 0.45
const COMPARE_AT := Vector3(10.0, 0.0, 1.5)


func _motion_compare() -> void:
	var tag: String = "MỚI: Mixamo" if ManagerBody.motion == ManagerBody.MX_MOTION else "CŨ: Tripo"
	var lamp := OmniLight3D.new()
	lamp.light_color = Color(1.0, 0.95, 0.86)
	lamp.light_energy = 2.2
	lamp.omni_range = 7.0
	lamp.shadow_enabled = true
	add_child(lamp)
	(room.get_node("Room407MainLight") as OmniLight3D).visible = false
	torch.visible = false
	camera.fov = 55.0
	var layer := CanvasLayer.new()
	add_child(layer)
	var caption := Label.new()
	caption.position = Vector2(28, 20)
	caption.add_theme_font_size_override("font_size", 30)
	caption.add_theme_color_override("font_outline_color", Color.BLACK)
	caption.add_theme_constant_override("outline_size", 8)
	layer.add_child(caption)
	body.position = COMPARE_AT
	body.rotation.y = -PI / 2.0
	var walk := player.get_animation(&"walk")
	var pace: float = WALK_SPEED / float(walk.get_meta(&"stride_speed")) if walk.has_meta(&"stride_speed") else 1.0
	var slash := player.get_animation(&"slash")
	# step: caption, clip, seconds, playback speed, moves, camera from him (x right, y up, z back: he looks down -Z)
	var steps := [
		["Đứng", &"stand", 1.5, 1.0, false, Vector3(2.4, 1.3, -1.6)],
		["Đi (%.1f m/s)" % WALK_SPEED, &"walk", 4.5, pace, true, Vector3(2.4, 1.3, -1.6)],
		["Đứng", &"stand", 1.0, 1.0, false, Vector3(2.4, 1.3, -1.6)],
		["Chém 6 nhát (%.2f s/nhát), nhìn ngang" % CHOP_SECONDS, &"slash", CHOP_SECONDS * 6.0, slash.length / CHOP_SECONDS, false, Vector3(2.6, 1.3, 0.0)],
		["Đứng", &"stand", 0.8, 1.0, false, Vector3(0.8, 1.4, -2.6)],
		["Chém 6 nhát, nhìn trước mặt", &"slash", CHOP_SECONDS * 6.0, slash.length / CHOP_SECONDS, false, Vector3(0.8, 1.4, -2.6)],
		["Đứng", &"stand", 1.0, 1.0, false, Vector3(0.8, 1.4, -2.6)],
	]
	for step: Array in steps:
		player.play(step[1], 0.3, step[3])
		var left: float = step[2]
		while left > 0.0:
			var delta := get_process_delta_time()
			if step[4]:
				body.position += -body.global_basis.z * WALK_SPEED * delta
			var offset: Vector3 = step[5]
			rig.global_position = body.global_transform * Vector3(offset.x, 0.0, offset.z)
			(camera.get_parent() as Node3D).position.y = offset.y
			camera.look_at(body.global_position + Vector3.UP * 1.0)
			lamp.global_position = body.global_position + Vector3(0.6, 2.3, 0.4)
			caption.text = "%s\n%s\nclip %s, tốc độ phát x%.2f" % [tag, step[0], String(step[1]), float(step[3])]
			await get_tree().process_frame
			left -= delta
	print("MOTION manager walk pace x%.2f, slash x%.2f (length %.2f s)" % [pace, slash.length / CHOP_SECONDS, slash.length])
	print("RESULT: motion compare PASS")
	App.quit()


func _capture() -> void:
	if DisplayServer.get_name() == "headless":
		push_error("Manager capture requires Forward+ renderer")
		App.quit(1)
		return
	get_window().content_scale_size = Vector2i(1920, 1080)
	get_window().size = Vector2i(1920, 1080)
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUTPUT))
	var views := {}
	for view: Dictionary in VIEWS:
		views[view.id] = view
	var report := {"godot": Engine.get_version_info().string,
		"renderer": RenderingServer.get_current_rendering_method(), "gpu": RenderingServer.get_video_adapter_name(),
		"resolution": [1920, 1080], "images": []}
	for shot: Array in SHOTS:
		_apply(views[shot[1]], shot[2], shot[3], shot[4], shot.size() > 5 and shot[5])
		var file := "%s.png" % shot[0]
		for frame in range(45):
			await get_tree().process_frame
		await RenderingServer.frame_post_draw
		if get_viewport().get_texture().get_image().save_png(OUTPUT + file) != OK:
			push_error("Cannot save manager capture: " + file)
			App.quit(1)
			return
		report.images.append({"file": file, "view": shot[1], "light": shot[2], "clip": String(shot[3]), "time": shot[4],
			"door_reach": shot.size() > 5 and shot[5]})
	var out := FileAccess.open(OUTPUT + "capture_report.json", FileAccess.WRITE)
	out.store_string(JSON.stringify(report, "\t") + "\n")
	print("RESULT: manager capture %d images PASS" % report.images.size())
	App.quit()
