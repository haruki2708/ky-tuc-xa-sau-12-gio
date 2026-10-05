extends SceneTree
## T-165 previews: one shot from every camera of the set in each beat pose,
## and every student pose up close. Writes art_source/cctv/previews/.

const BEATS := {"Room102": &"answer", "Room306": &"phone_lit", "Room209": &"cower", "Room106": &"sit_up"}
var destination: String


func _initialize() -> void:
	call_deferred("capture")


func save_shot(shot: String) -> void:
	for i in range(10):
		await process_frame
	await RenderingServer.frame_post_draw
	var error := root.get_texture().get_image().save_png(destination.path_join(shot + ".png"))
	if error != OK:
		push_error("Capture failed: " + shot)
	print("CCTV_PREVIEW: ", shot)


func capture() -> void:
	root.size = Vector2i(960, 540)
	root.content_scale_size = root.size
	destination = ProjectSettings.globalize_path("res://../art_source/cctv/previews")
	DirAccess.make_dir_recursive_absolute(destination)
	var set_scene := load("res://scenes/levels/cctv/cctv_set.tscn").instantiate() as Node3D
	root.add_child(set_scene)
	var report := {}
	for room_name in ["Room102", "Room306", "Room209", "Room106", "Corridor"]:
		var room := set_scene.get_node(room_name)
		var cam := room.get_node("Cam") as Camera3D
		cam.current = true
		var victim := room.get_node_or_null("Victim")
		if victim != null:
			await save_shot("cam_" + room_name.to_lower() + "_lie_awake")
			victim.set_pose(BEATS[room_name])
			await save_shot("cam_" + room_name.to_lower() + "_" + String(BEATS[room_name]))
			victim.set_pose(&"dead")
			await save_shot("cam_" + room_name.to_lower() + "_dead")
			var triangles := 0
			for mesh: MeshInstance3D in victim.find_children("*", "MeshInstance3D", true, false):
				triangles += mesh.mesh.get_faces().size() / 3
			report[String(victim.scene_file_path.get_file())] = triangles
		else:
			await save_shot("cam_corridor")
	# Close-ups of every pose (Room102 student, then the others lying awake).
	var close := Camera3D.new()
	set_scene.add_child(close)
	for room_name in ["Room102", "Room306", "Room209", "Room106"]:
		var victim := set_scene.get_node(room_name + "/Victim") as Node3D
		close.global_position = victim.global_position + Vector3(1.7, 0.75, 0.1)
		close.look_at(victim.global_position + Vector3(0, 0.3, 0.0))
		close.current = true
		for pose: StringName in victim.POSES:
			victim.set_pose(pose)
			await save_shot("pose_" + room_name.substr(4) + "_" + String(pose))
	print("CCTV_TRIANGLES: ", JSON.stringify(report))
	quit(0)
