extends SceneTree
## Render the actual integrated scenes with two room doors open for review.


func _initialize() -> void:
	call_deferred("_capture")


func _capture() -> void:
	root.size = Vector2i(1280, 720)
	var fixture := Node3D.new()
	root.add_child(fixture)
	var floor4 := (load("res://scenes/levels/floor4/floor4.tscn") as PackedScene).instantiate() as Node3D
	var campus := (load("res://scenes/levels/campus/campus.tscn") as PackedScene).instantiate() as Node3D
	fixture.add_child(floor4)
	fixture.add_child(campus)
	var camera := Camera3D.new()
	camera.fov = 75
	fixture.add_child(camera)
	camera.make_current()
	floor4.get_node("Corridor/LockedDoor_401").set_open(true)
	floor4.get_node("Corridor/LockedDoor_408").set_open(true)
	var views := {
		"room401_open": [Vector3(9.7, 1.6, 3.1), Vector3(8, 1.2, -1.7)],
		"room408_open": [Vector3(40.4, 1.6, 3.1), Vector3(42, 1.2, -1.6)],
	}
	var folder := ProjectSettings.globalize_path("res://../art_source/campus/previews")
	for label: String in views:
		camera.position = views[label][0]
		camera.look_at(views[label][1])
		for frame in 90:
			await process_frame
		await RenderingServer.frame_post_draw
		var result := root.get_texture().get_image().save_png(folder.path_join(label + ".png"))
		print("T190_CAPTURE: ", label, " result=", result)
	fixture.queue_free()
	await create_timer(.4).timeout
	quit()
