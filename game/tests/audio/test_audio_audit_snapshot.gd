extends TestCase
## T-234: inventory real chapter instances without starting a chapter or moving emitters.
## Evidence goes to ignored build output. Alignment findings are not gameplay assertions.

var _chapter: Node3D
var _mouse_mode: Input.MouseMode
var _resume: StringName


func before_each() -> void:
	_mouse_mode = Input.mouse_mode
	_resume = Chapter1Director.resume_checkpoint
	Chapter1Director.resume_checkpoint = &""
	GameState.reset()
	RuleSystem.reset()


func after_each() -> void:
	if is_instance_valid(_chapter):
		_chapter.free()
	await wait_frames(2)
	GameState.reset()
	RuleSystem.reset()
	Chapter1Director.resume_checkpoint = _resume
	Input.mouse_mode = _mouse_mode


func test_inventory_four_chapters_without_starting_story() -> void:
	var chapters: Array[Dictionary] = []
	for number in range(1, 5):
		var path := "res://scenes/main/chapter%d.tscn" % number
		_chapter = (load(path) as PackedScene).instantiate() as Node3D
		var director := _chapter.get_node("Chapter%dDirector" % number) as Chapter1Director
		director.auto_start = false
		tree.root.add_child(_chapter)
		await wait_frames(3)
		assert_false(director.auto_start, "chapter %d story disabled" % number)
		assert_false(director.get("_rules_live"), "chapter %d rules have not started" % number)
		var data: Dictionary = {"chapter": number, "scene": path, "nodes": [], "sources": [], "zones": [], "meshes": []}
		_visit(_chapter, data)
		assert_true(data.sources.size() > 0, "actual audio sources inventoried")
		assert_true(data.zones.size() > 0, "actual audio zones inventoried")
		assert_true(data.meshes.size() > 0, "visible floor 4 meshes inventoried")
		chapters.append(data)
		_chapter.free()
		await wait_frames(3)
		GameState.reset()
		RuleSystem.reset()
	var directory := ProjectSettings.globalize_path("res://../build/t234")
	assert_eq(DirAccess.make_dir_recursive_absolute(directory), OK, "create evidence directory")
	var file := FileAccess.open(directory.path_join("spatial_raw.json"), FileAccess.WRITE)
	assert_not_null(file, "open evidence file")
	if file != null:
		file.store_string(JSON.stringify({"schema": 1, "method": "auto_start=false; three process frames; no input or audio API calls", "chapters": chapters}, "\t") + "\n")
		file.close()


func _vector(value: Vector3) -> Array[float]:
	return [value.x, value.y, value.z]


func _finite(value: float) -> Variant:
	return value if is_finite(value) else null


func _visit(node: Node, data: Dictionary) -> void:
	var path := String(_chapter.get_path_to(node))
	var script_path := ""
	if node.get_script() != null:
		script_path = node.get_script().resource_path
	if node is Node3D:
		var spatial := node as Node3D
		# Include anchors outside Floor4: scene-root rigs are often moved by the director later.
		data.nodes.append({"path": path, "position": _vector(spatial.global_position),
			"visible": spatial.is_visible_in_tree(), "script": script_path})
	if node is AudioStreamPlayer3D:
		var player := node as AudioStreamPlayer3D
		var streams: Array[String] = []
		if player.stream != null and not player.stream.resource_path.is_empty():
			streams.append(player.stream.resource_path)
		if player is AmbientEmitter:
			for clip in (player as AmbientEmitter).clips:
				if clip != null:
					streams.append(clip.resource_path)
		data.sources.append({"path": path, "script": script_path, "position": _vector(player.global_position),
			"bus": String(player.bus), "volume_db": _finite(player.volume_db),
			"bus_chain": _bus_chain(player.bus),
			"base_volume_db": (player as AmbientEmitter).get("_base_volume") if player is AmbientEmitter else player.volume_db,
			"zone_gains": (player as AmbientEmitter).get("_zone_gains").values() if player is AmbientEmitter else [],
			"variation_db": (player as AmbientEmitter).volume_variation_db if player is AmbientEmitter else 0.0,
			"unit_size": player.unit_size, "max_distance": player.max_distance, "max_db": player.max_db,
			"attenuation_model": player.attenuation_model, "pitch_scale": player.pitch_scale,
			"playing": player.playing, "streams": streams})
	if node is AmbientZone or node is ReverbZone:
		var shapes: Array[Dictionary] = []
		for child in node.get_children():
			if child is CollisionShape3D and child.shape is BoxShape3D:
				var box: AABB = child.global_transform * AABB(-child.shape.size / 2.0, child.shape.size)
				shapes.append({"min": _vector(box.position), "max": _vector(box.end)})
		data.zones.append({"path": path, "script": script_path, "position": _vector((node as Node3D).global_position),
			"shapes": shapes, "emitters": node.get("emitters") if node is AmbientZone else [],
			"preset": node.get("preset") if node is ReverbZone else null})
	if node is MeshInstance3D and path.begins_with("Floor4/"):
		var mesh := node as MeshInstance3D
		if mesh.mesh != null and mesh.is_visible_in_tree():
			var box: AABB = mesh.global_transform * mesh.get_aabb()
			data.meshes.append({"path": path, "min": _vector(box.position), "max": _vector(box.end),
				"mesh": mesh.mesh.resource_path})
	for child in node.get_children():
		_visit(child, data)


func _bus_chain(bus: StringName) -> Array[Dictionary]:
	var chain: Array[Dictionary] = []
	var seen: Array[StringName] = []
	while not seen.has(bus):
		seen.append(bus)
		var index := AudioServer.get_bus_index(bus)
		if index < 0:
			break
		var effects: Array[String] = []
		for effect_index in AudioServer.get_bus_effect_count(index):
			if AudioServer.is_bus_effect_enabled(index, effect_index):
				effects.append(AudioServer.get_bus_effect(index, effect_index).get_class())
		chain.append({"name": String(bus), "gain_db": AudioServer.get_bus_volume_db(index),
			"mute": AudioServer.is_bus_mute(index), "effects": effects})
		if index == 0:
			break
		bus = AudioServer.get_bus_send(index)
	return chain
