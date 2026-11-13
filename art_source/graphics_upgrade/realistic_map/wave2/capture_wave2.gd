extends Node3D
## T-253 wave 2 stills, in the real chapter-3 scene (director held, lights as the chapter opens, HUD and player
## hidden, sound muted, PS1 screen filter as the game's default). Copy this file to game/_probe_tmp/ with a scene
## whose root has it, then (one Godot at a time, Lượt Godot):
##   godot --path game res://_probe_tmp/capture_wave2.tscn -- --set=a08,a09,a10,a11 --tag=before
## Writes art_source/graphics_upgrade/realistic_map/previews/wave2/<tag>_<set>_<view>.jpg (1920 x 1080).
## --only=<id,id> takes some views; --alarm_preview puts the wave-2 fire alarm (alarm_preview.tscn, picture only)
## on core's FireAlarm1F marker in place of core's red box.
const OUTPUT := "res://../art_source/graphics_upgrade/realistic_map/previews/wave2/"
const RESOLUTION := Vector2i(1920, 1080)
const ALARM_PREVIEW := "res://_probe_tmp/alarm_preview.tscn"
## Views per set. "torch": the survey flashlight; "open": room doors under BuildingB opened for the picture;
## "main_open": the main door unchained and open; "fov": field of view.
const SETS := {
	"a08": [
		{"id": "1_west", "eye": Vector3(1, -1.65, 2.5), "target": Vector3(30, -2, 1)},
		{"id": "2_east", "eye": Vector3(43, -1.65, 2.6), "target": Vector3(15, -2, 1)},
		{"id": "3_door_torch", "eye": Vector3(21.6, -1.6, 2.7), "target": Vector3(24.75, -2.0, 0)},
		{"id": "4_from_fire_landing", "eye": Vector3(46.4, -1.65, 2.2), "target": Vector3(30, -2.2, 1.4)},
		{"id": "5_lamp", "eye": Vector3(9.5, -1.7, 3.2), "target": Vector3(13.5, -0.35, 2.0), "fov": 65.0},
		{"id": "6_railing_torch", "eye": Vector3(24, -1.65, 1.6), "target": Vector3(27.5, -2.7, 4.1), "torch": true},
		{"id": "7_room_open_torch", "eye": Vector3(18.6, -1.65, 2.6), "target": Vector3(19.4, -2.5, -3.5), "torch": true,
			"open": ["Floor3/Door3"]},
		{"id": "8_wall_base_torch", "eye": Vector3(31.5, -2.0, 2.4), "target": Vector3(33.5, -3.0, 0.0), "torch": true, "fov": 65.0},
	],
	"a09": [
		{"id": "1_west", "eye": Vector3(1, -4.95, 2.5), "target": Vector3(30, -5.3, 1)},
		{"id": "2_door203_torch", "eye": Vector3(15, -4.95, 2.8), "target": Vector3(13.75, -5.5, -0.5), "torch": true},
		{"id": "3_room203_torch", "eye": Vector3(13.8, -4.95, -0.8), "target": Vector3(14.2, -5.3, -4), "torch": true},
		{"id": "4_room203_reverse_torch", "eye": Vector3(14.5, -4.95, -5), "target": Vector3(13.75, -5.4, 0), "torch": true},
		{"id": "5_room203_bed_torch", "eye": Vector3(14.6, -5.1, -2.2), "target": Vector3(12.0, -5.7, -4.8), "torch": true},
		{"id": "6_east", "eye": Vector3(43, -4.95, 2.6), "target": Vector3(15, -5.3, 1)},
		{"id": "7_room207_open_torch", "eye": Vector3(33.6, -4.95, 2.6), "target": Vector3(35.9, -5.7, -3.2), "torch": true,
			"open": ["Floor2/Door6"]},
		{"id": "8_from_fire_landing", "eye": Vector3(46.4, -4.95, 2.2), "target": Vector3(30, -5.5, 1.4)},
	],
	"a10": [
		{"id": "1_lobby_west_torch", "eye": Vector3(19, -8.25, 2.5), "target": Vector3(2.7, -8.7, 0.2), "torch": true},
		{"id": "2_alarm_torch", "eye": Vector3(-0.5, -8.25, 2.4), "target": Vector3(0.2, -8.5, 0.7), "torch": true},
		{"id": "3_manager_room_torch", "eye": Vector3(2.7, -8.25, -0.8), "target": Vector3(2, -8.7, -4), "torch": true},
		{"id": "4_window_torch", "eye": Vector3(3.8, -8.25, -5.3), "target": Vector3(4, -8.7, -7.6), "torch": true},
		{"id": "5_main_door_torch", "eye": Vector3(18.0, -8.25, 0.9), "target": Vector3(19.25, -8.8, 4.1), "torch": true},
		{"id": "6_lobby_east", "eye": Vector3(15.5, -8.25, 1.6), "target": Vector3(40, -8.7, 2.2)},
		{"id": "7_window_outside_torch", "eye": Vector3(4.6, -8.3, -11.6), "target": Vector3(4, -8.6, -7.6), "torch": true},
		{"id": "8_from_main_stairs", "eye": Vector3(-0.6, -8.25, 2.6), "target": Vector3(30, -8.6, 1.6)},
		{"id": "9_desk_knife_torch", "eye": Vector3(2.7, -8.35, -2.1), "target": Vector3(1.4, -9.1, -3.2), "torch": true, "fov": 65.0},
		{"id": "10_room_entry", "eye": Vector3(2.75, -8.25, 2.6), "target": Vector3(2.9, -8.8, -3.5)},
		{"id": "11_alcove_torch", "eye": Vector3(8.0, -8.25, 2.8), "target": Vector3(8.25, -8.9, -3.0), "torch": true},
		{"id": "12_chain_torch", "eye": Vector3(18.7, -8.55, 3.3), "target": Vector3(19.25, -8.85, 4.2), "torch": true, "fov": 60.0},
		{"id": "13_alcove_inside_torch", "eye": Vector3(8.25, -8.3, 0.4), "target": Vector3(6.4, -9.2, -1.6), "torch": true},
	],
	"a11": [
		{"id": "1_extinguisher_torch", "eye": Vector3(45, -4.95, 2.7), "target": Vector3(48.83, -5.5, 2.4), "torch": true},
		{"id": "2_extinguisher_close_torch", "eye": Vector3(47.85, -5.2, 1.85), "target": Vector3(48.86, -5.75, 2.4), "torch": true,
			"fov": 55.0},
		{"id": "3_alarm_close_torch", "eye": Vector3(0.75, -8.4, 1.0), "target": Vector3(0.9, -8.5, 0.12), "torch": true, "fov": 55.0},
	],
}
var camera: Camera3D
var torch: SpotLight3D


func _ready() -> void:
	call_deferred("_run")


func _arg(name: String, fallback: String) -> String:
	for argument: String in OS.get_cmdline_user_args():
		if argument == "--%s" % name:
			return "true"
		if argument.begins_with("--%s=" % name):
			return argument.trim_prefix("--%s=" % name)
	return fallback


func _run() -> void:
	if DisplayServer.get_name() == "headless":
		push_error("Capture needs a window.")
		App.quit(1)
		return
	get_window().mode = Window.MODE_WINDOWED
	get_window().content_scale_size = RESOLUTION
	get_window().size = RESOLUTION
	get_viewport().scaling_3d_scale = 1.0
	var set_name := _arg("set", "a08")
	var tag := _arg("tag", "after")
	var only := _arg("only", "")
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUTPUT))
	AudioServer.set_bus_mute(0, true)
	Chapter1Director.resume_checkpoint = &""
	var scene := (load("res://scenes/main/chapter3.tscn") as PackedScene).instantiate() as Node3D
	scene.get_node("Chapter3Director").set("auto_start", false)
	add_child(scene)
	for frame in range(3):
		await get_tree().process_frame
	var campus := scene.get_node("Campus") as Node3D
	var building := campus.get_node("BuildingB") as Node3D
	var player := scene.get_node("Player") as Node3D
	player.visible = false
	player.process_mode = Node.PROCESS_MODE_DISABLED
	for layer: CanvasLayer in scene.find_children("*", "CanvasLayer", false, false):
		layer.visible = layer.name == &"PS1Filter"
	var alarm := campus.get_node_or_null("Anchors/FireAlarm1F") as Node3D
	if alarm != null and _arg("alarm_preview", "") == "true" and ResourceLoader.exists(ALARM_PREVIEW):
		# Picture only: what the alarm looks like once core puts the wave-2 model on its marker (Yêu cầu thay đổi).
		for child in alarm.get_children():
			if child is MeshInstance3D:
				(child as MeshInstance3D).visible = false
		alarm.add_child((load(ALARM_PREVIEW) as PackedScene).instantiate())
	camera = Camera3D.new()
	add_child(camera)
	camera.make_current()
	torch = SpotLight3D.new()
	torch.position = Vector3(0.1, -0.08, -0.15)
	torch.light_color = Color(0.9, 0.94, 1.0)
	torch.light_energy = 1.5
	torch.spot_range = 12.0
	torch.spot_angle = 28.0
	torch.shadow_enabled = true
	camera.add_child(torch)
	var count := 0
	for name: String in set_name.split(","):
		for view: Dictionary in SETS[name]:
			if not only.is_empty() and not String(view.id) in only.split(","):
				continue
			var opened: Array[Node] = []
			for path: String in view.get("open", []):
				var door := building.get_node_or_null(path)
				if door != null and door.has_method("set_open"):
					door.call("set_open", true)
					opened.append(door)
			if view.get("main_open", false):
				campus.call("set_main_door_chained", false)
			camera.position = view.eye
			camera.look_at(view.target)
			camera.fov = view.get("fov", 75.0)
			torch.visible = view.get("torch", false)
			for frame in range(30):
				await get_tree().process_frame
			await RenderingServer.frame_post_draw
			var image: Image = get_viewport().get_texture().get_image()
			var file := "%s_%s_%s.jpg" % [tag, name, view.id]
			image.save_jpg(OUTPUT + file, 0.92)
			print("CAPTURE: " + file)
			count += 1
			for door in opened:
				door.call("set_open", false)
			if view.get("main_open", false):
				campus.call("set_main_door_chained", true)
	print("RESULT: wave2 capture %d images" % count)
	App.quit()
