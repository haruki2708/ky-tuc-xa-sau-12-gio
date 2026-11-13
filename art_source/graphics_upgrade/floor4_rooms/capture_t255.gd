extends Node3D
## T-255 stills of the floor-4 rooms 401-406, 408, in the real chapter scenes (director held, lights as the chapter
## opens, HUD and player hidden, sound muted). Copy this file to game/_probe_tmp/ with a scene whose root has it,
## then (one Godot at a time, Lượt Godot):
##   godot --path game res://_probe_tmp/capture_t255.tscn -- --chapter=1 --set=rooms --tag=before
## Writes art_source/graphics_upgrade/floor4_rooms/previews/<tag>_ch<N>_<set>_<view>.jpg (1920 x 1080).
## A view's "open" lists the rooms whose door is swung open for the picture (RoomDoor.set_open, picture only).
const OUTPUT := "res://../art_source/graphics_upgrade/floor4_rooms/previews/"
const RESOLUTION := Vector2i(1920, 1080)
const SETS := {
	"rooms": [
		{"id": "01_corridor_401", "eye": Vector3(9.4, 1.65, 2.9), "target": Vector3(8.0, 1.2, -2.5), "open": ["401"], "torch": true},
		{"id": "02_in_401", "eye": Vector3(8.0, 1.6, -0.4), "target": Vector3(8.0, 1.0, -6.5), "open": ["401"], "torch": true},
		{"id": "03_in_401_back", "eye": Vector3(7.5, 1.6, -6.3), "target": Vector3(8.6, 1.1, -0.5), "open": ["401"], "torch": true},
		{"id": "04_in_402", "eye": Vector3(12.0, 1.6, -0.4), "target": Vector3(12.0, 1.0, -6.5), "open": ["402"], "torch": true},
		{"id": "05_in_403", "eye": Vector3(16.0, 1.6, -0.4), "target": Vector3(16.0, 1.0, -6.5), "open": ["403"], "torch": true},
		{"id": "06_in_404", "eye": Vector3(20.0, 1.6, -0.4), "target": Vector3(20.0, 1.0, -6.5), "open": ["404"], "torch": true},
		{"id": "07_in_405", "eye": Vector3(24.0, 1.6, -0.4), "target": Vector3(24.0, 1.0, -6.5), "open": ["405"], "torch": true},
		{"id": "08_in_406", "eye": Vector3(28.0, 1.6, -0.4), "target": Vector3(28.0, 1.0, -6.5), "open": ["406"], "torch": true},
		{"id": "09_in_408", "eye": Vector3(42.0, 1.6, -0.4), "target": Vector3(40.4, 1.0, -6.5), "open": ["408"], "torch": true},
		{"id": "10_bath_401", "eye": Vector3(8.7, 1.65, -3.3), "target": Vector3(9.4, 0.9, -6.6), "open": ["401"], "bath": ["401"], "torch": true},
		{"id": "11_balcony_401", "eye": Vector3(7.35, 1.6, -7.5), "target": Vector3(9.6, 1.0, -8.3), "open": ["401"], "balcony": ["401"], "torch": true},
		{"id": "12_corridor_west", "eye": Vector3(36.0, 1.65, 2.5), "target": Vector3(6.0, 1.2, 1.0), "open": ["405", "403"]},
		{"id": "13_facade_from_407", "eye": Vector3(30.8, 1.6, -8.25), "target": Vector3(18.0, 0.8, -7.8)},
		{"id": "14_facade_outside", "eye": Vector3(24.0, -6.5, -24.0), "target": Vector3(24.0, 1.2, -7.5), "fov": 60.0},
		{"id": "15_in_402_back", "eye": Vector3(13.4, 1.6, -6.3), "target": Vector3(11.4, 1.1, -0.5), "open": ["402"], "torch": true},
		{"id": "16_in_408_back", "eye": Vector3(41.5, 1.6, -6.4), "target": Vector3(40.0, 1.1, -0.8), "open": ["408"], "torch": true},
		{"id": "17_bath_408", "eye": Vector3(40.0, 1.65, -3.3), "target": Vector3(38.6, 0.9, -6.6), "open": ["408"], "bath": ["408"], "torch": true},
		{"id": "18_in_404_back", "eye": Vector3(21.0, 1.6, -6.3), "target": Vector3(19.4, 1.1, -0.5), "open": ["404"], "torch": true},
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
	var chapter := _arg("chapter", "1").to_int()
	var set_name := _arg("set", "rooms")
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
			if chapter < 3 and String(view.id) == "14_facade_outside":
				continue
			var opened: Array[Node] = []
			for room: String in view.get("open", []):
				var door := floor4.get_node_or_null("Corridor/LockedDoor_" + room)
				if door != null and door.has_method("set_open"):
					door.call("set_open", true)
					opened.append(door)
			for key: String in ["bath", "balcony"]:
				for room: String in view.get(key, []):
					var part := "Interior/BathroomDoor" if key == "bath" else "Outdoor/BalconyDoor"
					var hinged := floor4.get_node_or_null("Rooms/Room%s/%s" % [room, part])
					if hinged != null:
						hinged.call("set_open", true)
						opened.append(hinged)
			camera.position = view.eye
			camera.look_at(view.target)
			camera.fov = view.get("fov", 75.0)
			torch.visible = view.get("torch", false)
			for frame in range(40):
				await get_tree().process_frame
			await RenderingServer.frame_post_draw
			var image: Image = get_viewport().get_texture().get_image()
			var file := "%s_ch%d_%s_%s.jpg" % [tag, chapter, name, view.id]
			image.save_jpg(OUTPUT + file, 0.92)
			print("CAPTURE: " + file)
			count += 1
			for door in opened:
				door.call("set_open", false)
			for frame in range(20):
				await get_tree().process_frame
	print("RESULT: t255 capture %d images" % count)
	App.quit()
