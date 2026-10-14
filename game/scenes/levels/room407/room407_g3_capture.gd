extends Node3D
## T-215 review captures: the playable floor 4 with the furnished room 407, its own environment
## and lights, at 4 a.m. (default lights), with the phone torch and with the ceiling tube on. Story states: corpses,
## blood and slashed bedding; chapter 2 mirror steam and reflection. Opt-in: -- --g3-capture (needs Forward+); otherwise a free view.

const FLOOR := preload("res://scenes/levels/floor4/floor4.tscn")
const OUTPUT := "res://../art_source/graphics_upgrade/room407_furnished/previews/g3/"
const ORIGIN := Vector3(30, 0, 0)
# Room-local eye/target, as room407_furnished_pilot.gd; "story" shows corpses, blood and slashes.
const VIEWS := [
	# The pilot's room_centre view (D-104 reference: room_centre_torch_after / _tube_after).
	{"id": "room_centre", "eye": Vector3(5.6, 1.6, -0.9), "target": Vector3(2.8, 0.35, -3.0), "fov": 75.0},
	{"id": "door_overview", "eye": Vector3(2.1, 1.65, -0.35), "target": Vector3(4.0, 0.9, -4.8), "fov": 80.0},
	{"id": "back_overview", "eye": Vector3(4.7, 1.65, -3.75), "target": Vector3(1.4, 0.8, -1.0), "fov": 80.0},
	{"id": "door_wall", "eye": Vector3(3.6, 1.6, -3.4), "target": Vector3(2.2, 1.2, 0.0), "fov": 75.0},
	{"id": "bunk_a", "eye": Vector3(2.5, 1.5, -1.5), "target": Vector3(0.65, 0.7, -3.0), "fov": 70.0},
	{"id": "bunk_b", "eye": Vector3(5.5, 1.5, -1.5), "target": Vector3(7.35, 0.7, -2.9), "fov": 70.0},
	{"id": "study_desk", "eye": Vector3(2.7, 1.45, -3.2), "target": Vector3(1.6, 0.7, -4.8), "fov": 72.0},
	{"id": "viet_desk", "eye": Vector3(4.3, 1.55, -2.3), "target": Vector3(4.5, 0.8, -0.4), "fov": 72.0},
	{"id": "bathroom", "eye": Vector3(6.0, 1.6, -4.35), "target": Vector3(7.0, 0.7, -6.6), "fov": 82.0},
	{"id": "bath_sink", "eye": Vector3(6.95, 1.55, -4.55), "target": Vector3(5.4, 0.95, -5.4), "fov": 75.0},
	{"id": "balcony_side", "eye": Vector3(4.6, 1.5, -3.5), "target": Vector3(1.8, 0.9, -6.6), "fov": 75.0},
	{"id": "corridor_door", "eye": Vector3(2.6, 1.6, 2.6), "target": Vector3(2.0, 1.2, 0.0), "fov": 75.0},
	{"id": "story_bunk_a", "eye": Vector3(2.5, 1.5, -1.5), "target": Vector3(0.65, 0.7, -3.0), "fov": 70.0, "story": true},
	{"id": "story_bunk_b", "eye": Vector3(5.5, 1.5, -1.5), "target": Vector3(7.35, 0.7, -2.9), "fov": 70.0, "story": true},
	{"id": "story_mirror", "eye": Vector3(6.5, 1.5, -5.0), "target": Vector3(5.4, 1.35, -5.0), "fov": 60.0, "steam": true},
	{"id": "mirror_full", "eye": Vector3(6.2, 1.6, -2.0), "target": Vector3(6.6, 0.9, -3.78), "fov": 70.0},
	{"id": "mirror_bath", "eye": Vector3(6.5, 1.6, -5.0), "target": Vector3(5.4, 1.4, -5.0), "fov": 70.0},
	{"id": "viet_locker_open", "eye": Vector3(2.0, 1.45, -1.2), "target": Vector3(0.35, 0.95, -1.15), "fov": 70.0, "locker_open": true},
]

var floor4: Node3D
var room: Node3D
var camera: Camera3D
## Stands in for the player: the room's mirrors reflect the body that carries Head/Camera3D (D-105).
var rig: Node3D
var torch: SpotLight3D


func _ready() -> void:
	floor4 = FLOOR.instantiate() as Node3D
	add_child(floor4)
	room = floor4.get_node("Room407") as Node3D
	rig = Node3D.new()
	rig.name = "Rig"
	add_child(rig)
	var head := Node3D.new()
	head.name = "Head"
	rig.add_child(head)
	camera = Camera3D.new()
	head.add_child(camera)
	camera.make_current()
	# phone_item.tscn's flashlight; room 407 brightens any "Flashlight" under the camera (D-104).
	torch = SpotLight3D.new()
	torch.name = "Flashlight"
	torch.position = Vector3(0.1, -0.08, -0.15)
	torch.light_color = Color(0.9, 0.94, 1)
	torch.light_energy = 2.5
	torch.shadow_enabled = true
	torch.spot_range = 12.0
	torch.spot_angle = 28.0
	camera.add_child(torch)
	set_view(VIEWS[0], false)
	if "--g3-capture" in OS.get_cmdline_user_args():
		await _capture()


func set_view(view: Dictionary, torch_on: bool, tube_on: bool = false) -> void:
	rig.position = ORIGIN + Vector3(view.eye.x, 0.0, view.eye.z)
	var aim: Vector3 = view.target - view.eye
	rig.rotation.y = atan2(-aim.x, -aim.z)
	(camera.get_parent() as Node3D).position.y = view.eye.y
	camera.fov = view.fov
	camera.look_at(ORIGIN + view.target)
	torch.visible = torch_on
	# The ceiling tube at its flicker peak (the chapters only light it while it flickers).
	var tube := room.get_node("Room407MainLight") as OmniLight3D
	tube.visible = tube_on
	tube.light_energy = tube.flicker_energy if tube_on else 0.0
	var story: bool = view.get("story", false)
	room.set_blood_stage(2 if story else 0)
	room.set_slashed(0.6 if story else 0.0)
	for number in [1, 2, 4]:
		(room.get_node("Anchors/Corpse%d" % number) as Node3D).visible = story
	room.get_node("Anchors/VietLocker").set_open(view.get("locker_open", false))
	# Chapter 2: steam fogs the mirror and the manager shows in it.
	room.set_steam(1.0 if view.get("steam", false) else 0.0)
	(room.get_node("Ch2Bathroom/Reflection") as Node3D).visible = view.get("steam", false)


func _capture() -> void:
	if DisplayServer.get_name() == "headless":
		push_error("G3 capture requires Forward+ renderer")
		App.quit(1)
		return
	get_window().content_scale_size = Vector2i(1280, 720)
	get_window().size = Vector2i(1280, 720)
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUTPUT))
	var report := {"godot": Engine.get_version_info().string,
		"renderer": RenderingServer.get_current_rendering_method(), "gpu": RenderingServer.get_video_adapter_name(),
		"resolution": [1280, 720], "ps1_strength": 0.0, "images": []}
	for view: Dictionary in VIEWS:
		for mode: String in ["night", "torch", "tube"]:
			set_view(view, mode == "torch", mode == "tube")
			var file := "%s_%s.png" % [view.id, mode]
			await _save(file)
			report.images.append({"file": file, "eye": [view.eye.x, view.eye.y, view.eye.z], "fov": view.fov})
	var file := FileAccess.open(OUTPUT + "capture_report.json", FileAccess.WRITE)
	file.store_string(JSON.stringify(report, "\t") + "\n")
	print("RESULT: room407 G3 capture %d images PASS" % report.images.size())
	App.quit()


func _save(file: String) -> void:
	for frame in range(60):
		await get_tree().process_frame
	await RenderingServer.frame_post_draw
	if get_viewport().get_texture().get_image().save_png(OUTPUT + file) != OK:
		push_error("Cannot save G3 capture: " + file)
		App.quit(1)
