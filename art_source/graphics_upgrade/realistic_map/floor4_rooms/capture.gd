extends Node3D
## Static inspection inside the actual chapter scenes; never runs a gameplay bot.
const OUTPUT := "res://../art_source/graphics_upgrade/realistic_map/previews/t252/"
const ROOMS: Array[int] = [401, 402, 403, 404, 405, 406, 408]
var camera: Camera3D
var torch: SpotLight3D
var corridor: Node3D
var chapter: int = 1
var state: String = "before"
var rows: Array[Dictionary] = []


func _ready() -> void:
	_run.call_deferred()


func _run() -> void:
	for arg: String in OS.get_cmdline_user_args():
		if arg.begins_with("--chapter="):
			chapter = arg.get_slice("=", 1).to_int()
		if arg.begins_with("--state="):
			state = arg.get_slice("=", 1)
	get_window().mode = Window.MODE_WINDOWED
	get_window().content_scale_size = Vector2i(1920, 1080)
	get_window().size = Vector2i(1920, 1080)
	get_viewport().scaling_3d_scale = 1.0
	AudioServer.set_bus_mute(0, true)
	Chapter1Director.resume_checkpoint = &""
	var scene := (load("res://scenes/main/chapter%d.tscn" % chapter) as PackedScene).instantiate() as Node3D
	scene.get_node("Chapter%dDirector" % chapter).set("auto_start", false)
	add_child(scene)
	for frame: int in 3:
		await get_tree().process_frame
	corridor = scene.get_node("Floor4/Corridor") as Node3D
	var player := scene.get_node("Player") as Node3D
	player.hide()
	player.process_mode = Node.PROCESS_MODE_DISABLED
	for layer: CanvasLayer in scene.find_children("*", "CanvasLayer", false, false):
		layer.visible = layer.name == &"PS1Filter"
	if state == "before":
		_restore_a03_baseline()
	camera = Camera3D.new()
	camera.fov = 65.0
	add_child(camera)
	camera.make_current()
	torch = SpotLight3D.new()
	torch.position = Vector3(.1, -.08, -.15)
	torch.light_color = Color(.9, .94, 1)
	torch.light_energy = 1.5
	torch.spot_range = 12
	torch.spot_angle = 28
	torch.shadow_enabled = true
	camera.add_child(torch)
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUTPUT))
	await _shot("hall_west_closed", Vector3(5.2, 1.65, 2.7), Vector3(30, 1.45, 1), false, false)
	await _shot("hall_east_closed", Vector3(43.3, 1.65, 3.1), Vector3(12, 1.4, 1.1), false, false)
	# The chapter starts with these doors closed. Open only for an explicitly labelled
	# visual inspection using the existing door API (also used by chapter 3 waves).
	for room: int in ROOMS:
		var door := corridor.get_node("LockedDoor_%d" % room) as Node3D
		door.call("set_open", true)
		await get_tree().create_timer(.4).timeout
		var x := door.position.x
		await _shot("room_%d_inspection_torch" % room, Vector3(x-.12, 1.62, .85), Vector3(x-.28, 1.25, -3.8), true, true)
		door.call("set_open", false)
		await get_tree().create_timer(.4).timeout
	var file := FileAccess.open(OUTPUT + "ch%d_%s.json" % [chapter, state], FileAccess.WRITE)
	file.store_string(JSON.stringify({"chapter": chapter, "state": state, "resolution": [1920,1080],
		"lighting": "Unchanged chapter opening lights; optional camera flashlight 1.5. Director auto_start=false.",
		"door_state": "Hall: actual opening state. Room views: staged open via RoomDoor for visual inspection; not a playthrough.",
		"images": rows}, "\t") + "\n")
	file.close()
	print("RESULT: T-252 chapter %d %s capture %d images PASS" % [chapter, state, rows.size()])
	App.quit()


func _restore_a03_baseline() -> void:
	for room: int in ROOMS:
		var interior := corridor.get_node("RoomInterior_%d" % room)
		var visual := interior.get_node_or_null("T252Visual") as Node3D
		if visual != null:
			visual.hide()
		for mesh: MeshInstance3D in interior.find_children("Mesh", "MeshInstance3D", true, false):
			mesh.show()
		for prefix: String in ["Floor_", "BackWall_", "Ceiling_"]:
			var mesh := corridor.get_node_or_null(prefix + str(room) + "/Mesh") as Node3D
			if mesh != null:
				mesh.show()
	# The furnished 407 already hides RoomPartition_38 in the baseline (D-113).
	for path: String in ["RoomPartition_6", "RoomPartition_10", "RoomPartition_14", "RoomPartition_18", "RoomPartition_22", "RoomPartition_26", "Room408BackWall", "Room408EastWall"]:
		(corridor.get_node(path + "/Mesh") as Node3D).show()


func _shot(id: String, eye: Vector3, target: Vector3, flashlight: bool, staged: bool) -> void:
	camera.position = eye
	camera.look_at(target)
	torch.visible = flashlight
	for frame: int in 30:
		await get_tree().process_frame
	await RenderingServer.frame_post_draw
	var captured := get_viewport().get_texture().get_image()
	assert(captured.get_size() == Vector2i(1920,1080))
	var filename := "ch%d_%s_%s.jpg" % [chapter, state, id]
	assert(captured.save_jpg(OUTPUT + filename, .94) == OK)
	rows.append({"file": filename, "eye": [eye.x, eye.y, eye.z], "target": [target.x,target.y,target.z],
		"fov": camera.fov, "torch": flashlight, "staged_open": staged})
	print("CAPTURE: " + filename)
