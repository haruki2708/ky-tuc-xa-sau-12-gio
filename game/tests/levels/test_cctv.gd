extends TestCase
## T-165: the security-camera set and the four students (D-041).

const SET := "res://scenes/levels/cctv/cctv_set.tscn"
const ROOMS := {"102": "hung", "306": "kiet", "209": "bao", "106": "dang"}
const POSES: Array[StringName] = [&"lie_awake", &"sit_up", &"answer", &"phone_lit", &"cower", &"dead"]
var fixtures: Array[Node] = []


func spawn(path: String) -> Node3D:
	var node := (load(path) as PackedScene).instantiate() as Node3D
	fixtures.append(node)
	tree.root.add_child(node)
	return node


func after_each() -> void:
	for node in fixtures:
		node.queue_free()
	fixtures.clear()
	await wait_frames(2)


func test_set_has_rooms_cameras_and_anchors() -> void:
	var set_root := spawn(SET)
	assert_true(set_root.global_position.y <= -50.0, "far below the building;")
	for number: String in ROOMS:
		var room := set_root.get_node_or_null("Room" + number) as Node3D
		assert_not_null(room, "room " + number)
		if room == null:
			continue
		assert_true(room.get_node_or_null("Cam") is Camera3D, number + " Cam")
		assert_true(room.get_node_or_null("Hall/Cam") is Camera3D, number + " hall Cam")
		assert_true(room.get_node_or_null("Hall/Start") is Marker3D, number + " hall Start")
		for anchor in ["Door", "VictimBed", "ManagerSpot"]:
			assert_true(room.get_node_or_null(anchor) is Marker3D, number + " " + anchor)
		var victim := room.get_node_or_null("Victim")
		assert_not_null(victim, number + " victim")
		if victim != null:
			assert_eq(victim.scene_file_path, "res://scenes/levels/cctv/student_%s.tscn" % ROOMS[number], number + " student;")
	assert_true(set_root.get_node_or_null("Corridor/Cam") is Camera3D, "corridor camera")
	# Only room 106 has its desk lamp on (card).
	assert_not_null(set_root.get_node_or_null("Room106/DeskLamp"), "106 lamp")
	assert_true(set_root.get_node_or_null("Room102/DeskLamp") == null, "102 dark")


func test_cameras_see_the_victim_bed() -> void:
	var set_root := spawn(SET)
	await wait_frames(1)
	for number: String in ROOMS:
		var cam := set_root.get_node("Room%s/Cam" % number) as Camera3D
		var bed := set_root.get_node("Room%s/VictimBed" % number) as Node3D
		assert_false(cam.is_position_behind(bed.global_position), number + " bed in front of the camera")
		var to_bed := (bed.global_position - cam.global_position).normalized()
		var facing := -cam.global_basis.z
		assert_true(rad_to_deg(facing.angle_to(to_bed)) < cam.fov * 0.5, number + " bed inside the view")


func test_students_have_all_poses_and_stay_low_poly() -> void:
	for who: String in ROOMS.values():
		var student := spawn("res://scenes/levels/cctv/student_%s.tscn" % who)
		await wait_frames(1)
		assert_eq(student.POSES, POSES, who + " poses;")
		for pose in POSES:
			assert_true(student.set_pose(pose), who + " " + pose)
		assert_false(student.set_pose(&"dance"), who + " unknown pose rejected")
		var triangles := 0
		for mesh: MeshInstance3D in student.find_children("*", "MeshInstance3D", true, false):
			triangles += mesh.mesh.get_faces().size() / 3
		assert_true(triangles < 1500, "%s under 1500 triangles (%d)" % [who, triangles])
		student.set_pose(&"dead")
		await wait_frames(1)
		assert_true((student.find_child("Blood", true, false) as Node3D).visible, who + " bleeds when dead")
		student.set_pose(&"phone_lit")
		await wait_frames(1)
		assert_true((student.find_child("Phone", true, false) as Node3D).visible, who + " phone lit")
		student.set_pose(&"lie_awake")
		await wait_frames(1)
		assert_false((student.find_child("Phone", true, false) as Node3D).visible, who + " phone away")


func test_chapter_builds_five_feeds() -> void:
	var scene := spawn("res://scenes/main/chapter1.tscn")
	scene.get_node("Chapter1Director").set("auto_start", false)
	await wait_frames(3)
	var ids: Array = []
	for feed in tree.get_nodes_in_group(&"cctv_feed"):
		if scene.is_ancestor_of(feed):
			ids.append(String(feed.get("camera_id")))
			assert_true(feed is SubViewport, "feed is a viewport")
			assert_true(tr(String(feed.get("label_key"))) != String(feed.get("label_key")), "label translated")
	ids.sort()
	assert_eq(ids, ["cam_102", "cam_106", "cam_209", "cam_306", "cam_corridor", "hall_102", "hall_106", "hall_209", "hall_306"], "room, hall and floor-4 feeds (D-044);")


func test_manager_comes_down_the_hall_and_leaves_no_one_behind() -> void:
	var scene := spawn("res://scenes/main/chapter1.tscn")
	var director := scene.get_node("Chapter1Director")
	director.set("auto_start", false)
	await wait_frames(3)
	var focused: Array[StringName] = []
	var listen := func(id: StringName) -> void: focused.append(id)
	EventBus.cctv_focus_requested.connect(listen)
	director._cctv_scene(&"cam_102", &"answer")
	var room102 := director.get_node("CctvSet/Room102") as Node3D
	var manager := room102.get_node_or_null("Manager") as Node3D
	assert_not_null(manager, "manager staged")
	if manager != null:
		assert_true(manager.global_position.z > room102.global_position.z + 0.5, "starts in the corridor")
	assert_eq(focused, [&"hall_102"] as Array[StringName], "phone shows the corridor first;")
	var deadline := Time.get_ticks_msec() + 8000
	while focused.size() < 2 and Time.get_ticks_msec() < deadline:
		await wait_frames(1)
	assert_eq(focused, [&"hall_102", &"cam_102"] as Array[StringName], "then the room once he is through the door;")
	# Next room: nobody left standing in 102.
	director._cctv_scene(&"cam_306", &"phone_lit")
	await wait_frames(2)
	assert_true(room102.get_node_or_null("Manager") == null, "102 empty once he goes to 306")
	EventBus.cctv_focus_requested.disconnect(listen)
