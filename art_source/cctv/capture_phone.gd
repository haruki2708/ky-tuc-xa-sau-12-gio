extends SceneTree
## T-165 end-to-end check: chapter 1 with the real set, camera tab on the
## raised phone, each beat shown as the player would see it.

var destination: String


func _initialize() -> void:
	call_deferred("capture")


func save_shot(shot: String) -> void:
	for i in range(20):
		await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(destination.path_join(shot + ".png"))
	print("CCTV_PHONE: ", shot)


func capture() -> void:
	root.size = Vector2i(1280, 720)
	root.content_scale_size = root.size
	destination = ProjectSettings.globalize_path("res://../art_source/cctv/previews")
	var scene: Node = load("res://scenes/main/chapter1.tscn").instantiate()
	var director: Node = scene.get_node("Chapter1Director")
	director.auto_start = false
	root.add_child(scene)
	for i in range(5):
		await process_frame
	var feeds := get_nodes_in_group(&"cctv_feed")
	print("CCTV_FEEDS: ", feeds.size(), " ", feeds.map(func(f: Node) -> String: return String(f.get("camera_id"))))
	var phone: Node = scene.find_child("Phone", true, false)
	for node in scene.find_children("*", "", true, false):
		if node.get_script() != null and node.get_script().resource_path.get_file() == "phone_item.gd":
			phone = node
	root.get_node("EventBus").cctv_unlocked.emit()
	if phone != null and phone.has_method("set_raised"):
		phone.set_raised(true)
	else:
		Input.action_press(&"phone")
		await process_frame
		Input.action_release(&"phone")
	await process_frame
	var tools: Node = scene.get_node("PhoneScreen/Root/Phone/Content/Tools")
	tools.select_tab(2)
	director._cctv_scene(&"cam_102", &"answer")
	await save_shot("phone_cam_102_answer")
	var room: Node = director.get_node("CctvSet/Room102")
	for i in range(900):
		await process_frame
		var m := room.get_node_or_null("Manager") as Node3D
		if i % 150 == 0:
			print("MGR ", i, " ", m.global_position if m else null, " state=", m.get("state") if m else null, " spot=", (room.get_node("ManagerSpot") as Node3D).global_position)
	await save_shot("phone_cam_102_manager")
	director._cctv_kill(&"cam_102")
	for i in range(60):
		await process_frame
	await save_shot("phone_cam_102_kill")
	root.get_node("EventBus").cctv_focus_requested.emit(&"cam_corridor")
	await save_shot("phone_cam_corridor")
	quit(0)
