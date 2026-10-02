extends TestCase


func test_all_scenes_load_and_instantiate() -> void:
	var paths := _find_scenes("res://scenes")
	assert_false(paths.is_empty(), "scene directory must contain scenes")
	for path: String in paths:
		var packed := load(path) as PackedScene
		assert_not_null(packed, "load " + path)
		if packed == null:
			continue
		var instance := packed.instantiate()
		assert_not_null(instance, "instantiate " + path)
		if instance == null:
			continue
		tree.root.add_child(instance)
		await wait_frames(2)
		assert_true(instance.is_inside_tree(), "enter tree " + path)
		# Stop audio producers before releasing scenes; allow the mixer to drain.
		instance.process_mode = Node.PROCESS_MODE_DISABLED
		var nodes: Array[Node] = [instance]
		nodes.append_array(instance.find_children("*", "", true, false))
		for node: Node in nodes:
			if node.has_method("stop_emitting"):
				node.stop_emitting()
			if node is AudioStreamPlayer or node is AudioStreamPlayer2D or node is AudioStreamPlayer3D:
				node.stop()
		instance.queue_free()
		await tree.create_timer(0.3, true, false, true).timeout


func _find_scenes(directory: String) -> PackedStringArray:
	var paths: PackedStringArray = []
	for file: String in DirAccess.get_files_at(directory):
		if file.ends_with(".tscn"):
			paths.append(directory.path_join(file))
	for sub: String in DirAccess.get_directories_at(directory):
		paths.append_array(_find_scenes(directory.path_join(sub)))
	paths.sort()
	return paths
