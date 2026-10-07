extends Node3D
## Offline art review only: no bot, performance run or chapter progression.


func _ready() -> void:
	await get_tree().process_frame
	if DisplayServer.get_name() == "headless" or get_tree().current_scene != self:
		return
	var floor4: Node3D = load("res://scenes/levels/floor4/floor4.tscn").instantiate()
	floor4.name = "Floor4"
	add_child(floor4)
	var campus: Node3D = load("res://scenes/levels/campus/campus.tscn").instantiate()
	add_child(campus)
	var camera := Camera3D.new()
	add_child(camera)
	camera.current = true
	camera.fov = 78
	await get_tree().create_timer(.5).timeout
	var output := ProjectSettings.globalize_path("res://../build/t196/review")
	DirAccess.make_dir_recursive_absolute(output)
	for shot in [
		["library_lobby",Vector3(66,-8.25,220),Vector3(53,-8.6,207)],
		["library_reading",Vector3(65,-4.95,210),Vector3(57,-5.2,216)],
		["library_storage",Vector3(65,-1.65,210),Vector3(59,-2,218)],
		["library_stairs",Vector3(77,-8.25,197),Vector3(82,-6.6,206)],
		["library_map",Vector3(47,-8.1,211),Vector3(45,-8.1,211)],
		["library_back",Vector3(69,-8.25,230),Vector3(65,-8.6,224)],
	]:
		camera.position = shot[1]
		camera.look_at(shot[2])
		await _capture(output.path_join(shot[0]+".png"))
	campus.get_node("Anchors/Ch4/Room407/Door").set_damage_fraction(.85)
	EventBus.bed_slat_flipped.emit(1)
	await get_tree().create_timer(.6).timeout
	camera.position = Vector3(32.6,1.6,-2.3)
	camera.look_at(Vector3(32,1.05,0))
	await _capture(output.path_join("door407.png"))
	camera.position = Vector3(32.3,1.65,-2.3)
	camera.look_at(Vector3(30.65,1.35,-3))
	await _capture(output.path_join("slat1.png"))
	campus.queue_free()
	floor4.queue_free()
	await get_tree().process_frame
	var hospital: Node3D = load("res://scenes/levels/hospital/hospital_room.tscn").instantiate()
	add_child(hospital)
	camera.current = true
	camera.position = Vector3(0,2.4,2.7)
	camera.look_at(Vector3(0,.7,-.4))
	await _capture(output.path_join("hospital.png"))
	hospital.queue_free()
	camera.queue_free()
	for frame in 3:
		await get_tree().process_frame
	get_tree().quit()


func _capture(path: String) -> void:
	for frame in 8:
		await get_tree().process_frame
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png(path)
