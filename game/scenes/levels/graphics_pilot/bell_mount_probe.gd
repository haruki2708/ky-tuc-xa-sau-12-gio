extends Node3D
## Opt-in static mount survey; no gameplay, audio, collision or production marker.

const PILOT := preload("res://scenes/levels/graphics_pilot/material_pilot.gd")
const BUILDING := preload("res://scenes/levels/campus/building_b.tscn")
const OUTPUT := "res://../art_source/graphics_upgrade/review_d080"
const SOUND_POINT := Vector3(42, -7.7, 0.2)


func _ready() -> void:
	if "--bell-mount-capture" not in OS.get_cmdline_user_args():
		return
	if DisplayServer.get_name() == "headless":
		push_error("Mount survey requires a real renderer")
		App.quit(1)
		return
	var source := BUILDING.instantiate()
	add_child(PILOT.snapshot(source))
	source.free()
	var world := WorldEnvironment.new()
	world.environment = Environment.new()
	world.environment.background_mode = Environment.BG_COLOR
	world.environment.background_color = Color(0.12, 0.12, 0.12)
	world.environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	world.environment.ambient_light_color = Color.WHITE
	world.environment.ambient_light_energy = 0.7
	add_child(world)
	var override := ShaderGlobalsOverride.new()
	add_child(override)
	override.set("params/ps1_strength", 0.0)
	var camera := Camera3D.new()
	camera.fov = 55
	add_child(camera)
	camera.make_current()
	var lamp := OmniLight3D.new()
	lamp.light_energy = 0.5
	lamp.omni_range = 8
	camera.add_child(lamp)
	# Red disk marks a proposed envelope, not an approved bell asset.
	var disk := MeshInstance3D.new()
	var cylinder := CylinderMesh.new()
	cylinder.top_radius = 0.14
	cylinder.bottom_radius = 0.14
	cylinder.height = 0.12
	disk.mesh = cylinder
	disk.position = SOUND_POINT
	disk.rotation.x = PI / 2.0
	disk.material_override = _material(Color(0.8, 0.05, 0.03))
	add_child(disk)
	# Proposed support stays on the facade; the acoustic point stays unchanged.
	_box(Vector3(42.3, -7.7, 0.09), Vector3(0.1, 0.3, 0.02))
	_box(Vector3(42.15, -7.7, 0.13), Vector3(0.3, 0.04, 0.04))
	_box(Vector3(42.3, -7.7, 0.115), Vector3(0.04, 0.04, 0.05))
	get_window().content_scale_size = Vector2i(1280, 720)
	get_window().size = Vector2i(1280, 720)
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUTPUT))
	var report := {"scope": "Proposed support only; not approved or installed", "images": [],
		"sound_point": [42, -7.7, 0.2], "noise_point": [42, -9.9, 2],
		"renderer": RenderingServer.get_current_rendering_method(),
		"gpu": RenderingServer.get_video_adapter_name(), "godot": Engine.get_version_info().string}
	for view: Dictionary in [
		{"id": "bell_front", "eye": Vector3(42, -7.7, 2.6)},
		{"id": "bell_side", "eye": Vector3(43.2, -7.25, 1.65)}]:
		camera.position = view.eye
		camera.look_at(SOUND_POINT)
		for frame in range(12):
			await get_tree().process_frame
		await RenderingServer.frame_post_draw
		var capture := get_viewport().get_texture().get_image()
		if capture.save_png(OUTPUT.path_join(view.id + ".png")) != OK:
			push_error("Cannot save mount survey")
			App.quit(1)
			return
		report.images.append({"file": view.id + ".png", "eye": [view.eye.x, view.eye.y, view.eye.z],
			"target": [42, -7.7, 0.2], "fov": camera.fov, "size": [capture.get_width(), capture.get_height()]})
	var file := FileAccess.open(OUTPUT.path_join("capture_report.json"), FileAccess.WRITE)
	file.store_string(JSON.stringify(report, "\t") + "\n")
	print("RESULT: bell mount survey 2 images PASS")
	App.quit()


func _box(center: Vector3, size: Vector3) -> void:
	var instance := MeshInstance3D.new()
	var mesh := BoxMesh.new()
	mesh.size = size
	instance.mesh = mesh
	instance.position = center
	instance.material_override = _material(Color(0.13, 0.14, 0.15))
	add_child(instance)


func _material(color: Color) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = 0.65
	return material
