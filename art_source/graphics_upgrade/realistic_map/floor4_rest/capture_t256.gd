extends Node3D
## T-256 stills of the floor-4 rest (washroom, corridor props, fire door, CCTV set) in the real chapter scenes (director
## held, lights as the chapter opens, HUD and player hidden, sound muted). Copy this file to game/_probe_tmp/ with a
## scene whose root has it, then (one Godot at a time, Lượt Godot):
##   godot --path game res://_probe_tmp/capture_t256.tscn -- --chapter=1 --set=washroom --tag=after
## Writes art_source/graphics_upgrade/realistic_map/previews/floor4_rest/<tag>_ch<N>_<set>_<view>.jpg (1920 x 1080).
## --old: the parts as main has them (Washroom.upgraded off, ...), for before stills of views main has none of.
## The capture camera hangs under a "Head" of its own, so the washroom mirror takes it for the player's eye.
const OUTPUT := "res://../art_source/graphics_upgrade/realistic_map/previews/floor4_rest/"
const RESOLUTION := Vector2i(1920, 1080)
const SETS := {
	"washroom": [
		{"id": "03_washroom_entry", "eye": Vector3(3, 1.65, 0.8), "target": Vector3(2.5, 1.1, -3.5), "torch": true},
		{"id": "04_washroom_sinks", "eye": Vector3(2.4, 1.65, -1), "target": Vector3(0.2, 1.3, -2.3), "torch": true},
		{"id": "a1_entry_dark", "eye": Vector3(3, 1.65, 0.8), "target": Vector3(2.5, 1.1, -3.5)},
		{"id": "a2_stalls", "eye": Vector3(3.6, 1.6, -1.6), "target": Vector3(2.6, 0.7, -4.4), "torch": true},
		{"id": "a3_stall_gap", "eye": Vector3(3.15, 1.55, -2.75), "target": Vector3(2.95, 0.35, -4.4), "torch": true},
		{"id": "a4_mirror", "eye": Vector3(1.55, 1.62, -1.35), "target": Vector3(0.14, 1.55, -2.2), "torch": true},
		{"id": "a5_trough", "eye": Vector3(1.3, 1.45, -0.45), "target": Vector3(0.3, 0.85, -2.6), "torch": true},
		{"id": "a6_back_east", "eye": Vector3(0.9, 1.7, -3.0), "target": Vector3(5.6, 1.2, -0.8), "torch": true},
	],
	"corridor": [
		{"id": "07_corridor_clothes", "eye": Vector3(24, 1.65, 2.8), "target": Vector3(25.5, 1.7, 3.87), "torch": true},
		{"id": "08_corridor_props", "eye": Vector3(18, 1.65, 1.8), "target": Vector3(19, 0.3, 0.35), "torch": true},
		{"id": "b1_corridor_west", "eye": Vector3(36, 1.65, 2.3), "target": Vector3(6, 1.0, 1.6)},
		{"id": "b2_corridor_east", "eye": Vector3(4, 1.65, 2.0), "target": Vector3(34, 1.0, 1.8)},
		{"id": "b3_rooms_front", "eye": Vector3(13, 1.6, 2.6), "target": Vector3(17, 0.4, 0.3), "torch": true},
	],
	"firedoor": [
		{"id": "c1_handle_rail", "eye": Vector3(41.2, 1.5, 2.6), "target": Vector3(42.2, 1.05, 3.9), "torch": true, "fire_open": true},
		{"id": "c2_door_open", "eye": Vector3(39.5, 1.65, 1.6), "target": Vector3(44, 1.3, 2.4), "torch": true, "fire_open": true},
		{"id": "c3_sign_column", "eye": Vector3(40.5, 1.6, 1.8), "target": Vector3(44, 2.5, 2.5), "torch": true},
	],
}
var camera: Camera3D
var torch: SpotLight3D
var eye_rig: Node3D


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
	var chapter := _arg("chapter", "1").to_int()
	var set_name := _arg("set", "washroom")
	var tag := _arg("tag", "after")
	var only := _arg("only", "")
	var old := _arg("old", "") == "true"
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUTPUT))
	AudioServer.set_bus_mute(0, true)
	Chapter1Director.resume_checkpoint = &""
	var scene := (load("res://scenes/main/chapter%d.tscn" % chapter) as PackedScene).instantiate() as Node3D
	scene.get_node("Chapter%dDirector" % chapter).set("auto_start", false)
	if old:
		scene.get_node("Floor4/Washroom").set("upgraded", false)
	add_child(scene)
	for frame in range(3):
		await get_tree().process_frame
	var floor4 := scene.get_node("Floor4") as Node3D
	var player := scene.get_node("Player") as Node3D
	player.visible = false
	player.process_mode = Node.PROCESS_MODE_DISABLED
	for layer: CanvasLayer in scene.find_children("*", "CanvasLayer", false, false):
		layer.visible = layer.name == &"PS1Filter"
	# The washroom mirror follows this rig; a "body" on it hides the mirror's PS1 stand-in (washroom_real.gd).
	eye_rig = Node3D.new()
	var rig_script := GDScript.new()
	rig_script.source_code = "extends Node3D
var body := true
"
	rig_script.reload()
	eye_rig.set_script(rig_script)
	eye_rig.name = "CaptureEye"
	add_child(eye_rig)
	var head := Node3D.new()
	head.name = "Head"
	eye_rig.add_child(head)
	camera = Camera3D.new()
	head.add_child(camera)
	camera.make_current()
	torch = SpotLight3D.new()
	torch.position = Vector3(0.1, -0.08, -0.15)
	torch.light_color = Color(0.9, 0.94, 1.0)
	torch.light_energy = 1.5
	torch.spot_range = 12.0
	torch.spot_angle = 28.0
	torch.shadow_enabled = true
	camera.add_child(torch)
	var fire_door := scene.get_node_or_null("Campus/BuildingB/FireDoor")
	var count := 0
	for name: String in set_name.split(","):
		for view: Dictionary in SETS[name]:
			if not only.is_empty() and not String(view.id) in only.split(","):
				continue
			var opened := false
			if view.get("fire_open", false) and fire_door != null and fire_door.has_method("set_open"):
				fire_door.call("set_open", true)
				opened = true
			eye_rig.global_position = view.eye
			camera.position = Vector3.ZERO
			camera.look_at(view.target)
			camera.fov = view.get("fov", 75.0)
			torch.visible = view.get("torch", false)
			for frame in range(40):
				await get_tree().process_frame
			await RenderingServer.frame_post_draw
			var image: Image = get_viewport().get_texture().get_image()
			var file := "%s_ch%d_%s_%s.jpg" % [tag, chapter, name, view.id]
			image.save_jpg(OUTPUT + file, 0.92)
			print("CAPTURE: %s (video memory %d MB)" % [file, int(Performance.get_monitor(Performance.RENDER_VIDEO_MEM_USED) / 1048576.0)])
			count += 1
			if opened:
				fire_door.call("set_open", false)
				for frame in range(20):
					await get_tree().process_frame
	print("RESULT: t256 capture %d images" % count)
	App.quit()
