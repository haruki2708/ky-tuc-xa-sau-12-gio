extends Node3D
## T-261 round 2 stills, before and after the stadium (A13) and the garden-to-stadium strip (A16), in chapter 3's real
## scene: director held, lights as the chapter opens, HUD and player hidden, sound muted. Stadium views are shot with
## the floodlights off and on (Stadium/Floodlights.visible, as campus.set_stadium_lights does).
## Copy this file to game/_probe_tmp/ with a scene whose root has it, then (one Godot at a time, Lượt Godot):
##   godot --path game res://_probe_tmp/capture_t261.tscn -- --tag=before   (on main's scenes)
##   godot --path game res://_probe_tmp/capture_t261.tscn -- --tag=after
## Writes art_source/graphics_upgrade/realistic_map/previews/wave4/<tag>_<view>_<off|on>[_torch].jpg (1920 x 1080) and
## prints draw calls, primitives, objects and video memory per shot.
const OUTPUT := "res://../art_source/graphics_upgrade/realistic_map/previews/wave4/"
const RESOLUTION := Vector2i(1920, 1080)
# flood: shoot with the floodlights on too; torch: also a shot with the torch (floodlights off).
const VIEWS := {
	"s1_west_gate": {"eye": Vector3(100.5, -8.3, 167.5), "target": Vector3(150, -8.6, 166), "flood": true, "torch": false},
	"s2_start": {"eye": Vector3(115, -8.3, 166), "target": Vector3(165, -9.0, 190), "flood": true, "torch": false},
	"s3_mid_pitch": {"eye": Vector3(198, -8.3, 176), "target": Vector3(198, -5.6, 222), "flood": true, "torch": false},
	"s4_stand_front": {"eye": Vector3(165, -8.3, 195), "target": Vector3(178, -5.2, 221), "flood": true, "torch": true},
	"s5_stand_top": {"eye": Vector3(196.5, -1.55, 226.6), "target": Vector3(196, -9.6, 172), "flood": true, "torch": false},
	"s6_under_stand": {"eye": Vector3(167.5, -8.3, 231.2), "target": Vector3(162.5, -9.4, 223.5), "flood": true, "torch": true},
	"s7_b02": {"eye": Vector3(146, -8.3, 232), "target": Vector3(160, -6.2, 219), "flood": true, "torch": true},
	"s8_pole": {"eye": Vector3(124, -8.3, 197), "target": Vector3(112, 1.5, 210), "flood": true, "torch": false},
	"s9_south_stand": {"eye": Vector3(198, -8.3, 138), "target": Vector3(198, -8.2, 114), "flood": true, "torch": true},
	"s10_east": {"eye": Vector3(276, -8.3, 182), "target": Vector3(240, -8.6, 160), "flood": true, "torch": false},
	"a1_strip_road": {"eye": Vector3(80, -8.3, 31), "target": Vector3(80.5, -9.0, 70), "flood": false, "torch": true},
	"a2_strip_gate": {"eye": Vector3(88, -8.3, 148), "target": Vector3(110, -8.5, 166), "flood": true, "torch": true},
	"a3_strip_exit": {"eye": Vector3(50, -8.3, 26), "target": Vector3(80, -9.0, 31), "flood": false, "torch": true},
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
	var tag := _arg("tag", "after")
	var only := _arg("views", "")
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUTPUT))
	AudioServer.set_bus_mute(0, true)
	Chapter1Director.resume_checkpoint = &""
	var scene := (load("res://scenes/main/chapter3.tscn") as PackedScene).instantiate() as Node3D
	scene.get_node("Chapter3Director").set("auto_start", false)
	add_child(scene)
	for frame in range(3):
		await get_tree().process_frame
	var player := scene.get_node("Player") as Node3D
	player.visible = false
	player.process_mode = Node.PROCESS_MODE_DISABLED
	for layer: CanvasLayer in scene.find_children("*", "CanvasLayer", false, false):
		layer.visible = layer.name == &"PS1Filter"
	var campus := scene.get_node("Campus")
	camera = Camera3D.new()
	add_child(camera)
	camera.make_current()
	camera.far = 4000.0
	torch = SpotLight3D.new()
	torch.position = Vector3(0.1, -0.08, -0.15)
	torch.light_color = Color(0.9, 0.94, 1.0)
	torch.light_energy = 1.5
	torch.spot_range = 12.0
	torch.spot_angle = 28.0
	torch.shadow_enabled = true
	camera.add_child(torch)
	var count := 0
	for view_name: String in VIEWS:
		if not only.is_empty() and not view_name in only.split(","):
			continue
		var view: Dictionary = VIEWS[view_name]
		camera.global_position = view.eye
		camera.look_at(view.target)
		camera.fov = 75.0
		var shots: Array = [[false, false]]
		if view.torch:
			shots.append([false, true])
		if view.flood:
			shots.append([true, false])
		for shot: Array in shots:
			campus.call("set_stadium_lights", shot[0])
			torch.visible = shot[1]
			for frame in range(24):
				await get_tree().process_frame
			await RenderingServer.frame_post_draw
			var image: Image = get_viewport().get_texture().get_image()
			var file := "%s_%s_%s%s.jpg" % [tag, view_name, "on" if shot[0] else "off", "_torch" if shot[1] else ""]
			image.save_jpg(OUTPUT + file, 0.88)
			print("CAPTURE: %s draws %d prims %d objects %d vram %d MB" % [file,
				int(Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME)),
				int(Performance.get_monitor(Performance.RENDER_TOTAL_PRIMITIVES_IN_FRAME)),
				int(Performance.get_monitor(Performance.RENDER_TOTAL_OBJECTS_IN_FRAME)),
				int(Performance.get_monitor(Performance.RENDER_VIDEO_MEM_USED) / 1048576.0)])
			count += 1
	campus.call("set_stadium_lights", false)
	print("RESULT: t261 capture %d images" % count)
	App.quit()
