extends Node3D
## Opt-in facing inspection of the unchanged, imported CC0 backpack.

const MODEL := preload("res://assets/models/room407/backpack.glb")
const FLOOR := preload("res://scenes/levels/floor4/floor4.tscn")
const PROBE := preload("res://scripts/debug/graphics_asset_probe.gd")
const OUTPUT := "res://../art_source/graphics_upgrade/backpack_g1"
const BINDING := "Room407/Details/Trung/Backpack"


func _ready() -> void:
	if "--backpack-facing-capture" not in OS.get_cmdline_user_args():
		return
	if DisplayServer.get_name() == "headless":
		push_error("Facing capture requires a real renderer")
		App.quit(1)
		return
	var floor_root := FLOOR.instantiate()
	var selected := floor_root.get_node(BINDING) as Node3D
	var placement := selected.transform
	var ancestor := selected.get_parent()
	while ancestor is Node3D:
		placement = ancestor.transform * placement
		ancestor = ancestor.get_parent()
	var report := {"asset_id": "room407_backpack", "owner": "B (T-207 contract section 2.1)",
		"binding": BINDING, "root_class": selected.get_class(), "scene_file_path": selected.scene_file_path,
		"placement_position_m": _vec(placement.origin), "placement_rotation_degrees": _vec(placement.basis.get_euler() * 180.0 / PI),
		"placement_scale": _vec(placement.basis.get_scale()), "bound_node_measurement": PROBE.measure(selected),
		"front": [0, 0, -1], "up": [0, 1, 0], "pivot": [0, 0, 0], "images": []}
	floor_root.free()
	var model := MODEL.instantiate() as Node3D
	report["glb_measurement"] = PROBE.measure(model)
	report["source_sha256"] = FileAccess.get_sha256("res://assets/models/room407/backpack.glb")
	add_child(model)
	var override := ShaderGlobalsOverride.new()
	add_child(override)
	override.set("params/ps1_strength", 0.0)
	var world := WorldEnvironment.new()
	world.environment = Environment.new()
	world.environment.background_mode = Environment.BG_COLOR
	world.environment.background_color = Color(0.18, 0.18, 0.18)
	world.environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	world.environment.ambient_light_color = Color.WHITE
	world.environment.ambient_light_energy = 0.8
	add_child(world)
	# Fixed opposing neutral lights; only the camera changes between views.
	for position: Vector3 in [Vector3(-1, 1, -1), Vector3(1, -1, 1)]:
		var light := OmniLight3D.new()
		light.position = position
		light.light_energy = 0.6
		light.omni_range = 5.0
		add_child(light)
	var camera := Camera3D.new()
	camera.projection = Camera3D.PROJECTION_ORTHOGONAL
	camera.size = 0.7
	add_child(camera)
	camera.make_current()
	get_window().content_scale_size = Vector2i(1280, 720)
	get_window().size = Vector2i(1280, 720)
	var target := Vector3(0, 0.23818, 0.01887)
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUTPUT))
	report["renderer"] = RenderingServer.get_current_rendering_method()
	report["gpu"] = RenderingServer.get_video_adapter_name()
	report["godot"] = Engine.get_version_info().string
	report["lighting"] = {"ambient_energy": 0.8, "omni_energy_each": 0.6,
		"omni_positions": [[-1, 1, -1], [1, -1, 1]], "color": "white", "fixed_across_views": true}
	for view: Dictionary in [
		{"file": "front_neg_z_up_pos_y.png", "offset": Vector3(0, 0, -1.2), "up": Vector3.UP},
		{"file": "back_pos_z_up_pos_y.png", "offset": Vector3(0, 0, 1.2), "up": Vector3.UP},
		{"file": "side_pos_x_up_pos_y.png", "offset": Vector3(1.2, 0, 0), "up": Vector3.UP},
		{"file": "underside_neg_y_screen_up_neg_z.png", "offset": Vector3(0, -1.2, 0), "up": Vector3.FORWARD}]:
		camera.position = target + view.offset
		camera.look_at(target, view.up)
		for frame in range(12):
			await get_tree().process_frame
		await RenderingServer.frame_post_draw
		var capture := get_viewport().get_texture().get_image()
		if capture.save_png(OUTPUT.path_join(view.file)) != OK:
			push_error("Cannot save facing reference")
			App.quit(1)
			return
		report.images.append({"file": view.file, "eye": _vec(camera.position), "target": _vec(target),
			"camera_up": _vec(view.up), "orthographic_size": camera.size, "size": [capture.get_width(), capture.get_height()]})
	var file := FileAccess.open(OUTPUT.path_join("facing_report.json"), FileAccess.WRITE)
	file.store_string(JSON.stringify(report, "\t") + "\n")
	print("RESULT: backpack facing 4 images PASS")
	App.quit()


func _vec(value: Vector3) -> Array:
	return [value.x, value.y, value.z]
