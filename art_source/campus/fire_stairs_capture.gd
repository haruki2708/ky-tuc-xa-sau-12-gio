extends SceneTree
## T-188: actual Floor4 + Campus view from the floor2 landing toward the collapse.


func _initialize() -> void:
	call_deferred("_capture")


func _capture() -> void:
	root.size = Vector2i(1280, 720)
	var fixture := Node3D.new()
	root.add_child(fixture)
	var floor4 := load("res://scenes/levels/floor4/floor4.tscn").instantiate() as Node3D
	var campus := load("res://scenes/levels/campus/campus.tscn").instantiate() as Node3D
	fixture.add_child(floor4)
	fixture.add_child(campus)
	campus.set_fire_door_open(true)
	var camera := Camera3D.new()
	camera.fov = 75.0
	fixture.add_child(camera)
	camera.position = Vector3(47.6, -5.0, 2.3)
	camera.look_at(Vector3(45.9, -5.9, -2.0))
	camera.make_current()
	for frame in 60:
		await process_frame
	await RenderingServer.frame_post_draw
	var path := ProjectSettings.globalize_path("res://../art_source/campus/previews/fire_stairs_floor2_fixed.png")
	var result := root.get_texture().get_image().save_png(path)
	print("T188_CAPTURE: floor2 landing -> collapsed flight, result=", result)
	fixture.queue_free()
	for frame in 3:
		await process_frame
	quit(0 if result == OK else 1)
