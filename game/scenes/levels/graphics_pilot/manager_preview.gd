extends Node3D
## T-219 (D-118): the Tripo dorm manager standing in the playable room 407 (D-113 lighting).
## Free view: 1-7 play stand/walk/ask/wait/slash/lunge/kill, L cycles night/torch/tube,
## C cycles cameras, Space pauses. Opt-in captures: -- --manager-capture (needs Forward+).

const FLOOR := preload("res://scenes/levels/floor4/floor4.tscn")
const BODY := preload("res://scenes/entity/manager_body.tscn")
const OUTPUT := "res://../art_source/graphics_upgrade/manager/previews/"
const ORIGIN := Vector3(30, 0, 0)
## Room-local spot on the floor mat between the bunks, facing the door.
const STAND := Vector3(3.6, 0.0, -2.9)
const CLIPS: Array[StringName] = [&"stand", &"walk", &"ask", &"wait", &"slash", &"lunge", &"kill"]
const LIGHTS: Array[String] = ["night", "torch", "tube"]
## Room-local eyes; targets are offsets from the manager's feet.
const VIEWS := [
	{"id": "full", "eye": Vector3(2.3, 1.6, -0.6), "aim": Vector3(0.0, 0.95, 0.0), "fov": 60.0},
	{"id": "face", "eye": Vector3(3.45, 1.62, -1.95), "aim": Vector3(0.0, 1.58, 0.0), "fov": 45.0},
	{"id": "side", "eye": Vector3(5.6, 1.5, -2.2), "aim": Vector3(0.0, 0.95, 0.0), "fov": 60.0},
	{"id": "low", "eye": Vector3(3.1, 0.55, -1.7), "aim": Vector3(0.0, 1.3, 0.0), "fov": 60.0},
]
## id, view, light, clip, time (s) — the review set.
const SHOTS := [
	["full_tube", "full", "tube", &"stand", 0.0],
	["full_torch", "full", "torch", &"stand", 0.0],
	["full_night", "full", "night", &"stand", 0.0],
	["face_tube", "face", "tube", &"stand", 0.0],
	["face_torch", "face", "torch", &"stand", 0.0],
	["side_tube", "side", "tube", &"stand", 0.0],
	["walk_tube", "full", "tube", &"walk", 0.6],
	["ask_tube", "full", "tube", &"ask", 2.8],
	["wait_tube", "full", "tube", &"wait", 2.0],
	["slash_windup_tube", "full", "tube", &"slash", 0.62],
	["slash_chop_tube", "full", "tube", &"slash", 1.0],
	["slash_side_torch", "side", "torch", &"slash", 0.62],
	["lunge_tube", "full", "tube", &"lunge", 0.3],
	["kill_low_torch", "low", "torch", &"kill", 1.1],
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


func _ready() -> void:
	floor4 = FLOOR.instantiate() as Node3D
	add_child(floor4)
	room = floor4.get_node("Room407") as Node3D
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
	torch.light_energy = 2.5
	torch.shadow_enabled = true
	torch.spot_range = 12.0
	torch.spot_angle = 28.0
	camera.add_child(torch)
	_apply(VIEWS[0], LIGHTS[light_index], CLIPS[0], -1.0)
	if "--manager-capture" in OS.get_cmdline_user_args():
		await _capture()


func _apply(view: Dictionary, light: String, clip: StringName, time: float) -> void:
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
	_apply(VIEWS[view_index], LIGHTS[light_index], CLIPS[clip_index], -1.0)


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
		_apply(views[shot[1]], shot[2], shot[3], shot[4])
		var file := "%s.png" % shot[0]
		for frame in range(45):
			await get_tree().process_frame
		await RenderingServer.frame_post_draw
		if get_viewport().get_texture().get_image().save_png(OUTPUT + file) != OK:
			push_error("Cannot save manager capture: " + file)
			App.quit(1)
			return
		report.images.append({"file": file, "view": shot[1], "light": shot[2], "clip": String(shot[3]), "time": shot[4]})
	var out := FileAccess.open(OUTPUT + "capture_report.json", FileAccess.WRITE)
	out.store_string(JSON.stringify(report, "\t") + "\n")
	print("RESULT: manager capture %d images PASS" % report.images.size())
	App.quit()
