extends SceneTree
## T-165 / D-044 end-to-end check: chapter 1 with the real set, camera tab on
## the raised phone. The manager comes down the corridor (hall camera), walks
## in (room camera), kills, leaves; the next room starts with nobody left behind.

var destination: String
var events: Node


func _initialize() -> void:
	call_deferred("capture")


func save_shot(shot: String) -> void:
	for i in range(20):
		await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(destination.path_join(shot + ".png"))
	print("CCTV_PHONE: ", shot)


func wait_seconds(seconds: float) -> void:
	await create_timer(seconds).timeout


func capture() -> void:
	root.size = Vector2i(1280, 720)
	root.content_scale_size = root.size
	destination = ProjectSettings.globalize_path("res://../art_source/cctv/previews")
	events = root.get_node("EventBus")
	var focused: Array[String] = []
	events.cctv_focus_requested.connect(func(id: StringName) -> void: focused.append(String(id)))
	var scene: Node = load("res://scenes/main/chapter1.tscn").instantiate()
	var director: Node = scene.get_node("Chapter1Director")
	director.auto_start = false
	root.add_child(scene)
	for i in range(5):
		await process_frame
	var feeds := get_nodes_in_group(&"cctv_feed")
	print("CCTV_FEEDS: ", feeds.size(), " ", feeds.map(func(f: Node) -> String: return String(f.get("camera_id"))))
	var phone: Node = null
	for node in scene.find_children("*", "", true, false):
		if node.get_script() != null and node.get_script().resource_path.get_file() == "phone_item.gd":
			phone = node
	events.cctv_unlocked.emit()
	if phone != null:
		phone.set_raised(true)
	await process_frame
	scene.get_node("PhoneScreen/Root/Phone/Content/Tools").select_tab(2)
	var room102: Node = director.get_node("CctvSet/Room102")
	director._cctv_scene(&"cam_102", &"answer")
	await wait_seconds(1.2)
	await save_shot("phone_hall_102")
	await wait_seconds(3.0)
	await save_shot("phone_cam_102_manager")
	print("FOCUS after walk-in: ", focused)
	director._cctv_kill(&"cam_102")
	await wait_seconds(1.0)
	await save_shot("phone_cam_102_kill")
	await wait_seconds(9.0)
	print("ROOM102 manager after leaving: ", room102.get_node_or_null("Manager"))
	events.cctv_focus_requested.emit(&"cam_102")
	await save_shot("phone_cam_102_after")
	director._cctv_scene(&"cam_306", &"phone_lit")
	await wait_seconds(1.2)
	await save_shot("phone_hall_306")
	print("ROOM102 manager during 306: ", room102.get_node_or_null("Manager"))
	print("FOCUS all: ", focused)
	quit(0)
