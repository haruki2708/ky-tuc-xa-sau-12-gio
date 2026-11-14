extends Node3D
## T-258 stills: the main stairwell's east wall at floor 4 against the floor-4 washroom, in chapter 3's real scene
## (director held, lights as the chapter opens, HUD and player hidden, sound muted). The washroom views are T-256's
## (capture_t256.gd: 04_washroom_sinks, a4_mirror, a5_trough) plus the wall's top under the ceiling; the stairwell
## views look at the same wall from floor 4's landing and from flight 4B; one looks from behind building B.
## Copy this file to game/_probe_tmp/ with a scene whose root has it, then (one Godot at a time, Lượt Godot):
##   godot --path game res://_probe_tmp/capture_t258.tscn -- --tag=before
## Writes art_source/graphics_upgrade/realistic_map/previews/floor4_rest/t258_<tag>_<view>.jpg (1920 x 1080).
## The capture camera hangs under a "Head" of its own, so the washroom mirror takes it for the player's eye.
const OUTPUT := "res://../art_source/graphics_upgrade/realistic_map/previews/floor4_rest/"
const RESOLUTION := Vector2i(1920, 1080)
const SETS := {
	"t258": [
		{"id": "w1_sinks", "eye": Vector3(2.4, 1.65, -1), "target": Vector3(0.2, 1.3, -2.3), "torch": true},
		{"id": "w2_mirror", "eye": Vector3(1.55, 1.62, -1.35), "target": Vector3(0.14, 1.55, -2.2), "torch": true},
		{"id": "w3_trough", "eye": Vector3(1.3, 1.45, -0.45), "target": Vector3(0.3, 0.85, -2.6), "torch": true},
		{"id": "w4_wall_top", "eye": Vector3(2.6, 1.6, -2.4), "target": Vector3(0.1, 2.75, -2.6), "torch": true},
		{"id": "s1_landing4", "eye": Vector3(-2.0, 1.65, 3.2), "target": Vector3(-0.1, 1.2, -3.2), "torch": true},
		{"id": "s2_flight4b", "eye": Vector3(-1.4, -0.85, -1.2), "target": Vector3(-0.1, 1.2, -3.8), "torch": true},
		{"id": "s3_wall_end", "eye": Vector3(-2.5, 1.6, 2.5), "target": Vector3(0.0, 1.5, -0.2), "torch": true},
		{"id": "o1_behind_b", "eye": Vector3(3.0, 1.6, -9.5), "target": Vector3(0.1, 1.2, -5.6), "torch": true},
	],
	# Seen on the way (outside T-258): the washroom's back wall from room 401's balcony (--set=found).
	"found": [
		{"id": "f1_balcony401", "eye": Vector3(6.4, 1.6, -8.2), "target": Vector3(2.5, 1.4, -5.1), "torch": true},
		{"id": "f2_balcony401_dark", "eye": Vector3(6.4, 1.6, -8.2), "target": Vector3(2.5, 1.4, -5.1)},
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
	var chapter := _arg("chapter", "3").to_int()
	var set_name := _arg("set", "t258")
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
			if view.has("cam"):
				var source := scene.get_node_or_null(String(view.cam)) as Camera3D
				if source == null:
					push_error("no camera " + String(view.cam))
					continue
				eye_rig.global_position = source.global_position
				camera.position = Vector3.ZERO
				camera.global_basis = source.global_basis
				camera.fov = source.fov
				camera.far = source.far
			else:
				eye_rig.global_position = view.eye
				camera.position = Vector3.ZERO
				camera.look_at(view.target)
				camera.fov = view.get("fov", 75.0)
				camera.far = 4000.0
			torch.visible = view.get("torch", false)
			for frame in range(40):
				await get_tree().process_frame
			await RenderingServer.frame_post_draw
			var image: Image = get_viewport().get_texture().get_image()
			var file := "t258_%s_%s.jpg" % [tag, view.id]
			image.save_jpg(OUTPUT + file, 0.92)
			print("CAPTURE: %s (video memory %d MB)" % [file, int(Performance.get_monitor(Performance.RENDER_VIDEO_MEM_USED) / 1048576.0)])
			count += 1
			if opened:
				fire_door.call("set_open", false)
				for frame in range(20):
					await get_tree().process_frame
	print("RESULT: t258 capture %d images" % count)
	App.quit()
