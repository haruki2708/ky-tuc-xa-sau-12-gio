extends Node3D
## Opt-in G2 capture for the Tripo backpack prototype (D-084, D-085).
## Writes four facing images with lane B's backpack_g1 camera/light setup and
## before/after pairs in room 407 (same camera, old CC0 visual vs Tripo visual).
## The playable scenes are untouched: the swap happens on an off-line instance.
## Run: <godot> --path game res://scenes/levels/graphics_pilot/backpack_g2_capture.tscn -- --backpack-g2-capture

const TRIPO := preload("res://assets/models/graphics_pilot/room407_backpack_tripo.glb")
const FLOOR := preload("res://scenes/levels/floor4/floor4.tscn")
const PROBE := preload("res://scripts/debug/graphics_asset_probe.gd")
const OUTPUT := "res://../art_source/graphics_upgrade/tripo/room407_backpack/g2"
const BINDING := "Room407/Details/Trung/Backpack"
const FACING_TARGET := Vector3(0, 0.23818, 0.01887)
## Room views as offsets from the backpack root in world space (its front faces world -X).
const ROOM_VIEWS := [
	{"name": "room_far", "eye": Vector3(-1.6, 1.55, 0.5), "look": Vector3(0, 0.22, 0)},
	{"name": "room_near", "eye": Vector3(-0.75, 0.95, 0.25), "look": Vector3(0, 0.22, 0)},
]


func _ready() -> void:
	if "--backpack-g2-capture" not in OS.get_cmdline_user_args():
		return
	if DisplayServer.get_name() == "headless":
		push_error("G2 capture requires a real renderer")
		App.quit(1)
		return
	get_window().content_scale_size = Vector2i(1280, 720)
	get_window().size = Vector2i(1280, 720)
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUTPUT))
	var report := {"asset_id": "room407_backpack", "file": "res://assets/models/graphics_pilot/room407_backpack_tripo.glb",
		"source_sha256": FileAccess.get_sha256("res://assets/models/graphics_pilot/room407_backpack_tripo.glb"),
		"renderer": RenderingServer.get_current_rendering_method(), "gpu": RenderingServer.get_video_adapter_name(),
		"godot": Engine.get_version_info().string, "front": [0, 0, -1], "up": [0, 1, 0], "pivot": [0, 0, 0],
		"facing_images": [], "room_images": []}
	await _capture_facing(report)
	await _capture_room(report)
	var file := FileAccess.open(OUTPUT.path_join("g2_capture_report.json"), FileAccess.WRITE)
	file.store_string(JSON.stringify(report, "\t") + "\n")
	print("RESULT: backpack G2 capture %d images PASS" % (report.facing_images.size() + report.room_images.size()))
	App.quit()


## Same camera, lights and environment as backpack_facing_probe.gd (lane B, D-085).
func _capture_facing(report: Dictionary) -> void:
	var stage := Node3D.new()
	add_child(stage)
	var model := TRIPO.instantiate() as Node3D
	report["glb_measurement"] = PROBE.measure(model)
	stage.add_child(model)
	var world := WorldEnvironment.new()
	world.environment = Environment.new()
	world.environment.background_mode = Environment.BG_COLOR
	world.environment.background_color = Color(0.18, 0.18, 0.18)
	world.environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	world.environment.ambient_light_color = Color.WHITE
	world.environment.ambient_light_energy = 0.8
	stage.add_child(world)
	for position: Vector3 in [Vector3(-1, 1, -1), Vector3(1, -1, 1)]:
		var light := OmniLight3D.new()
		light.position = position
		light.light_energy = 0.6
		light.omni_range = 5.0
		stage.add_child(light)
	var camera := Camera3D.new()
	camera.projection = Camera3D.PROJECTION_ORTHOGONAL
	camera.size = 0.7
	stage.add_child(camera)
	camera.make_current()
	for view: Dictionary in [
		{"file": "front_neg_z_up_pos_y.png", "offset": Vector3(0, 0, -1.2), "up": Vector3.UP},
		{"file": "back_pos_z_up_pos_y.png", "offset": Vector3(0, 0, 1.2), "up": Vector3.UP},
		{"file": "side_pos_x_up_pos_y.png", "offset": Vector3(1.2, 0, 0), "up": Vector3.UP},
		{"file": "underside_neg_y_screen_up_neg_z.png", "offset": Vector3(0, -1.2, 0), "up": Vector3.FORWARD}]:
		camera.position = FACING_TARGET + view.offset
		camera.look_at(FACING_TARGET, view.up)
		await _save(view.file)
		report.facing_images.append({"file": view.file, "eye": _vec(camera.position), "target": _vec(FACING_TARGET),
			"camera_up": _vec(view.up), "orthographic_size": camera.size})
	stage.queue_free()
	await get_tree().process_frame


## Room 407 with its own geometry; a fixed dim ambient and a torch-like light at
## the camera, identical for the old and the Tripo visual.
func _capture_room(report: Dictionary) -> void:
	var floor_root := FLOOR.instantiate() as Node3D
	add_child(floor_root)
	var slot := floor_root.get_node(BINDING) as Node3D
	var world := WorldEnvironment.new()
	world.environment = Environment.new()
	world.environment.background_mode = Environment.BG_COLOR
	world.environment.background_color = Color(0.02, 0.02, 0.03)
	world.environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	world.environment.ambient_light_color = Color(0.75, 0.78, 0.85)
	world.environment.ambient_light_energy = 0.35
	add_child(world)
	var camera := Camera3D.new()
	camera.fov = 70.0
	add_child(camera)
	camera.make_current()
	var torch := OmniLight3D.new()
	torch.light_energy = 1.4
	torch.omni_range = 6.0
	add_child(torch)
	var base := slot.global_position
	var old_visuals: Array[Node] = slot.get_children()
	var tripo := TRIPO.instantiate() as Node3D
	tripo.visible = false
	slot.add_child(tripo)
	for view: Dictionary in ROOM_VIEWS:
		camera.global_position = base + view.eye
		camera.look_at(base + view.look, Vector3.UP)
		torch.global_position = camera.global_position + Vector3(0, -0.1, 0)
		for pass_name: String in ["before_cc0", "after_tripo"]:
			var show_tripo := pass_name == "after_tripo"
			tripo.visible = show_tripo
			for node in old_visuals:
				if node is Node3D:
					node.visible = not show_tripo
			var file_name := "%s_%s.png" % [view.name, pass_name]
			await _save(file_name)
			report.room_images.append({"file": file_name, "eye": _vec(camera.global_position),
				"target": _vec(base + view.look), "fov": camera.fov, "visual": pass_name})
	floor_root.queue_free()


func _save(file_name: String) -> void:
	for frame in range(12):
		await get_tree().process_frame
	await RenderingServer.frame_post_draw
	var capture := get_viewport().get_texture().get_image()
	if capture.save_png(OUTPUT.path_join(file_name)) != OK:
		push_error("Cannot save " + file_name)
		App.quit(1)


func _vec(value: Vector3) -> Array:
	return [value.x, value.y, value.z]
