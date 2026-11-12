extends Node3D
## T-250 wave 1 stills, in the real chapter scenes (director held, lights as the chapter opens, HUD and player
## hidden, sound muted, PS1 screen filter as the game's default). Copy this file to game/_probe_tmp/ with a scene
## whose root has it, then (one Godot at a time, Lượt Godot):
##   godot --path game res://_probe_tmp/capture_wave1.tscn -- --chapter=3 --set=a01 --tag=before
## Writes art_source/graphics_upgrade/realistic_map/previews/wave1/<tag>_ch<N>_<set>_<view>.jpg (1920 x 1080).
const OUTPUT := "res://../art_source/graphics_upgrade/realistic_map/previews/wave1/"
const RESOLUTION := Vector2i(1920, 1080)
## Views per set. "ch": chapters it is taken in; "torch": the survey flashlight; "door": fire door open;
## "drawer": key drawer pulled out by that fraction (only when the desk has its KeyDrawer).
const SETS := {
	"a01": [
		{"id": "1_overview", "eye": Vector3(37.3, 1.65, 3.1), "target": Vector3(40, 1.25, 0.4), "ch": [1, 3]},
		{"id": "2_overview_torch", "eye": Vector3(37.3, 1.65, 3.1), "target": Vector3(40, 1.25, 0.4), "torch": true, "ch": [1, 3]},
		{"id": "3_key_torch", "eye": Vector3(40.6, 1.4, 1.7), "target": Vector3(39.8, 0.66, 0.42), "torch": true, "ch": [1, 3]},
		{"id": "4_desk_top", "eye": Vector3(40.25, 1.5, 1.35), "target": Vector3(40.0, 0.8, 0.4), "fov": 65.0, "ch": [1, 3]},
		{"id": "5_wall", "eye": Vector3(40.9, 1.6, 2.6), "target": Vector3(39.0, 2.0, 0.1), "ch": [1, 3]},
		{"id": "6_clock", "eye": Vector3(39.4, 1.65, 1.9), "target": Vector3(40, 2.05, 0.18), "fov": 60.0, "ch": [3]},
		{"id": "7_drawer_open_torch", "eye": Vector3(40.25, 1.35, 1.45), "target": Vector3(39.85, 0.66, 0.55), "fov": 60.0,
			"torch": true, "drawer": 0.75, "ch": [1, 3]},
		{"id": "8_from_408", "eye": Vector3(42.6, 1.65, 2.4), "target": Vector3(39.5, 1.0, 0.4), "ch": [1, 3]},
	],
	"a07": [
		{"id": "1_door_shut", "eye": Vector3(41.5, 1.65, 2.4), "target": Vector3(44, 1.1, 2), "ch": [3]},
		{"id": "2_door_shut_torch", "eye": Vector3(41.5, 1.65, 2.4), "target": Vector3(44, 1.1, 2), "torch": true, "ch": [3]},
		{"id": "3_lock_torch", "eye": Vector3(43.1, 1.5, 2.3), "target": Vector3(44, 1.05, 1.95), "fov": 60.0, "torch": true, "ch": [3]},
		{"id": "4_door_open_torch", "eye": Vector3(40.4, 1.65, 2.9), "target": Vector3(45.0, 1.0, 1.6), "fov": 70.0,
			"torch": true, "door": true, "ch": [3]},
		{"id": "5_landing4_torch", "eye": Vector3(46.5, 1.65, 2.5), "target": Vector3(45.2, -0.7, -1.4), "torch": true,
			"door": true, "ch": [3]},
		{"id": "6_flight_mid_torch", "eye": Vector3(45.2, 0.85, -2.0), "target": Vector3(45.6, -1.2, -5.6), "torch": true,
			"door": true, "ch": [3]},
		{"id": "7_turn_torch", "eye": Vector3(45.4, -0.05, -5.4), "target": Vector3(47.8, -2.0, -1.5), "torch": true,
			"door": true, "ch": [3]},
		{"id": "8_floor3_torch", "eye": Vector3(47.8, -1.65, 1.5), "target": Vector3(45.2, -3.3, -2.5), "torch": true,
			"door": true, "ch": [3]},
		{"id": "9_collapse_torch", "eye": Vector3(47.5, -4.95, 1.8), "target": Vector3(46, -7.2, -1.5), "torch": true,
			"door": true, "ch": [3]},
		{"id": "10_collapse_from_landing_torch", "eye": Vector3(47.8, -4.95, 2.8), "target": Vector3(45.3, -5.8, -1.0),
			"torch": true, "door": true, "ch": [3]},
		{"id": "11_crack_torch", "eye": Vector3(47.3, -2.4, -1.4), "target": Vector3(48.9, -2.0, -3.0), "fov": 65.0,
			"torch": true, "door": true, "ch": [3]},
		{"id": "12_upper_block_torch", "eye": Vector3(46.0, 1.65, 2.6), "target": Vector3(46.8, 3.6, -1.0), "torch": true,
			"door": true, "ch": [3]},
	],
	"a06": [
		{"id": "1_top_torch", "eye": Vector3(-1, 1.65, 2.5), "target": Vector3(-3.8, -0.7, -1.4), "torch": true, "ch": [3]},
		{"id": "2_bottom_torch", "eye": Vector3(-1, -8.25, 2.6), "target": Vector3(-3.7, -7.7, -1.5), "torch": true, "ch": [3]},
		{"id": "3_flight_mid_torch", "eye": Vector3(-3.8, 0.85, -2.0), "target": Vector3(-3.4, -1.2, -5.6), "torch": true, "ch": [3]},
		{"id": "4_turn_torch", "eye": Vector3(-3.6, -0.05, -5.4), "target": Vector3(-1.2, -2.0, -1.5), "torch": true, "ch": [3]},
		{"id": "5_floor2_torch", "eye": Vector3(-1.2, -4.95, 2.8), "target": Vector3(-3.6, -6.6, -2.0), "torch": true, "ch": [3]},
		{"id": "6_up_from_floor1_torch", "eye": Vector3(-3.8, -8.25, 1.2), "target": Vector3(-3.0, -6.0, -4.0), "torch": true, "ch": [3]},
		{"id": "7_upper_block_torch", "eye": Vector3(-2.5, 1.65, 2.6), "target": Vector3(-2.0, 3.6, -1.0), "torch": true, "ch": [3]},
		{"id": "8_landing_floor3", "eye": Vector3(0.6, -1.65, 2.2), "target": Vector3(-3.5, -2.6, 0.0), "ch": [3]},
	],
}
var camera: Camera3D
var torch: SpotLight3D


func _ready() -> void:
	call_deferred("_run")


func _arg(name: String, fallback: String) -> String:
	for argument: String in OS.get_cmdline_user_args():
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
	var chapter := _arg("chapter", "3").to_int()
	var set_name := _arg("set", "a01")
	var tag := _arg("tag", "after")
	var only := _arg("only", "")
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUTPUT))
	AudioServer.set_bus_mute(0, true)
	Chapter1Director.resume_checkpoint = &""
	var scene := (load("res://scenes/main/chapter%d.tscn" % chapter) as PackedScene).instantiate() as Node3D
	scene.get_node("Chapter%dDirector" % chapter).set("auto_start", false)
	add_child(scene)
	for frame in range(3):
		await get_tree().process_frame
	var campus := scene.get_node_or_null("Campus") as Node3D
	var floor4 := scene.get_node("Floor4") as Node3D
	var player := scene.get_node("Player") as Node3D
	player.visible = false
	player.process_mode = Node.PROCESS_MODE_DISABLED
	for layer: CanvasLayer in scene.find_children("*", "CanvasLayer", false, false):
		layer.visible = layer.name == &"PS1Filter"
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
	var desk := floor4.get_node("DutyDesk")
	var count := 0
	var views: Array[Dictionary] = []
	for name: String in set_name.split(","):
		for view: Dictionary in SETS[name]:
			var tagged := view.duplicate()
			tagged["set"] = name
			views.append(tagged)
	for view: Dictionary in views:
		if not chapter in view.get("ch", [3]):
			continue
		if not only.is_empty() and not String(view.id) in only.split(","):
			continue
		if view.has("drawer") and not desk.has_method("set_drawer_open"):
			continue
		if desk.has_method("set_drawer_open"):
			desk.call("set_drawer_open", view.get("drawer", 0.0))
			# Still only a picture: the key (building_b's KeyStem) rides out with the drawer, as T-247 row 5 will
			# make it; the scene is never saved.
			var key := campus.get_node_or_null("BuildingB/KeyStem") as Node3D if campus != null else null
			if key != null:
				if not key.has_meta(&"shut_z"):
					key.set_meta(&"shut_z", key.position.z)
				key.position.z = float(key.get_meta(&"shut_z")) + 0.34 * float(view.get("drawer", 0.0))
		if campus != null:
			campus.call("set_fire_door_open", view.get("door", false))
		camera.position = view.eye
		camera.look_at(view.target)
		camera.fov = view.get("fov", 75.0)
		torch.visible = view.get("torch", false)
		for frame in range(30):
			await get_tree().process_frame
		await RenderingServer.frame_post_draw
		var image: Image = get_viewport().get_texture().get_image()
		var file := "%s_ch%d_%s_%s.jpg" % [tag, chapter, view.set, view.id]
		image.save_jpg(OUTPUT + file, 0.92)
		print("CAPTURE: " + file)
		count += 1
	print("RESULT: wave1 capture %d images" % count)
	App.quit()
