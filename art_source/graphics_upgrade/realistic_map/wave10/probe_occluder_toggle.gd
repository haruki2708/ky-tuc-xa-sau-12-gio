extends "survey_wave10.gd"
## Temporary: why do the feeds draw the same with the occluders on and off?


func _run() -> void:
	AudioServer.set_bus_mute(0, true)
	if not _window():
		App.quit(1)
		return
	_camera()
	var scene := await _load_chapter(1)
	var director := scene.get_node("Chapter1Director")
	await get_tree().create_timer(3.0).timeout
	var set_root := director.get_node("CctvSet") as Node3D
	var feed := _feed(&"hall_102")
	_only_feeds([&"hall_102"])
	_note("feed use_occlusion_culling %s, project %s, feed size %s, own world %s, world same %s" % [feed.use_occlusion_culling,
		ProjectSettings.get_setting("rendering/occlusion_culling/use_occlusion_culling"), feed.size, feed.own_world_3d,
		feed.find_world_3d() == get_viewport().find_world_3d()])
	var occ := []
	for number: String in ROOMS:
		occ.append(set_root.get_node("Room%s/Occluders" % number))
	var src := set_root.get_node("Room102/Hall/Cam") as Camera3D
	camera.make_current()
	camera.global_transform = src.global_transform
	camera.fov = src.fov
	camera.far = 30.0
	var mine := SubViewport.new()
	mine.size = Vector2i(320, 240)
	mine.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	add_child(mine)
	var cam2 := Camera3D.new()
	cam2.fov = src.fov
	cam2.far = 30.0
	mine.add_child(cam2)
	cam2.global_transform = src.global_transform
	cam2.current = true
	mine.use_occlusion_culling = true
	var parents := []
	for node: Node3D in occ:
		parents.append(node.get_parent())
	for row: Array in [[true, true], [false, true], [true, true], [false, true], [true, true], [true, false], [true, true]]:
		for k in occ.size():
			var node: Node3D = occ[k]
			if row[0] and not node.is_inside_tree():
				(parents[k] as Node).add_child(node)
			elif not row[0] and node.is_inside_tree():
				(parents[k] as Node).remove_child(node)
		feed.use_occlusion_culling = row[1]
		for frame in range(8):
			await get_tree().process_frame
		await RenderingServer.frame_post_draw
		_note("occluders %s feed culling %s | %s | mine %s | main %s" % [row[0], row[1], _feed_info(feed), _feed_info(mine), _main_draws()])
	_flush("r2_occ_probe.txt")
	App.quit()
