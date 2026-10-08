extends Node3D
## Reproducible T-203 review images; inspection light belongs only to this fixture.


func _ready() -> void:
	var floor_scene := preload("res://scenes/levels/floor4/floor4.tscn").instantiate()
	add_child(floor_scene)
	var environment := WorldEnvironment.new()
	environment.environment = Environment.new()
	environment.environment.background_mode = Environment.BG_COLOR
	environment.environment.background_color = Color(.035, .045, .055)
	environment.environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	environment.environment.ambient_light_color = Color(.7, .75, .8)
	environment.environment.ambient_light_energy = .55
	add_child(environment)
	var camera := Camera3D.new()
	camera.fov = 65
	add_child(camera)
	camera.make_current()
	var light := OmniLight3D.new()
	light.light_energy = .6
	light.omni_range = 5.0
	camera.add_child(light)
	var destination := ProjectSettings.globalize_path("res://../art_source/room407_fixes/previews")
	DirAccess.make_dir_recursive_absolute(destination)
	for view: Dictionary in [
		{"name": "bunk_b", "eye": Vector3(35.8, 1.55, -1.4), "target": Vector3(37.35, .9, -2.7)},
		{"name": "bunk_a", "eye": Vector3(32.15, 1.55, -1.7), "target": Vector3(30.65, .9, -3)},
		{"name": "khoa_outlet", "eye": Vector3(30.95, .66, -1.95), "target": Vector3(30.12, .27, -1.8)}]:
		camera.global_position = view.eye
		camera.look_at(view.target)
		for frame in range(30):
			await get_tree().process_frame
		await RenderingServer.frame_post_draw
		var result := get_viewport().get_texture().get_image().save_png(destination.path_join(view.name + ".png"))
		if result != OK:
			push_error("Cannot save T-203 review image")
			App.quit(1)
			return
	print("RESULT: room407 capture 3 images PASS")
	App.quit()
