extends "survey_wave10.gd"
## T-267 round 1 pilot stills (card section 2, steps 2-3). Chapter 1's real scene; director._cctv_scene(&"cam_306",
## &"phone_lit") as test_cctv does; the manager is held (process disabled) once in the corridor and once at ManagerSpot,
## and every option is shown on that same frame by switching visibility: the PS1 set as main has it, D1 (wave 2's light
## steel bunk and locker + room 407's bedding, desk, stool, fan and room 306's towel, bucket, desk things), D2 (room
## 407's Tripo bunk and lockers + the same), W1 / W2 (plain back wall / balcony door and window, seen from Room310's
## camera pose inside Room306 on a temporary 320 x 240 viewport), H1 / H2 (corridor in wave 2's floor 1-3 materials /
## in T-256's cctv_corridor ones). The shared kit (shell, corridor, D1) is then put in 102, 209, 106 (chapter 1) and 310
## (chapter 2) with their PS1 sign things left as they are, to read the signs on the feed. Video memory before and after
## (chapter 1 here; chapter 3 with --parts=vram3). Copy next to survey_wave10.gd in game/_probe_tmp/.
## Parts: $env:T267_PARTS = pilot (default) | vram3
const W10 := "res://assets/models/graphics_pilot/realistic_map/wave10/"
const W2 := "res://assets/models/graphics_pilot/realistic_map/wave2/"
const P := "res://assets/models/graphics_pilot/"
const CV := "res://assets/models/graphics_pilot/realistic_map/floor4_rest/materials/"
## Room 407's things in every room [model, position, yaw] (Room<n> local metres, the PS1 set's places).
const COMMON := [
	["room407_batch2/desk.glb", Vector3(1.8, 0.0, -4.55), 180.0],
	["room407_batch1/stool.glb", Vector3(2.95, 0.0, -4.5), 0.0],
	["room407_furnished/ceiling_fan_split.glb", Vector3(2.0, 3.0, -2.5), 0.0],
	["room407_furnished/bunk_mattress.glb", Vector3(0.65, 0.38, -3.0), 0.0],
	["room407_furnished/bunk_mattress.glb", Vector3(0.65, 1.15, -3.0), 0.0],
	["room407_furnished/bunk_mattress.glb", Vector3(3.35, 0.38, -3.0), 0.0],
	["room407_furnished/bunk_mattress.glb", Vector3(3.35, 1.15, -3.0), 0.0],
	["room407_batch2/pillow.glb", Vector3(0.65, 0.43, -2.33), 4.0],
	["room407_batch2/pillow.glb", Vector3(0.65, 1.2, -2.33), -3.0],
	["room407_batch2/pillow.glb", Vector3(3.35, 0.43, -2.33), 2.0],
	["room407_batch2/pillow.glb", Vector3(3.35, 1.2, -2.33), -5.0],
	["room407_batch2/blanket_messy.glb", Vector3(0.65, 0.43, -3.25), 0.0],
	["room407_batch2/blanket_folded.glb", Vector3(0.65, 1.2, -3.68), 3.0],
	["room407_batch2/blanket_messy.glb", Vector3(3.35, 0.43, -3.3), 180.0],
	["room407_batch2/blanket_folded.glb", Vector3(3.35, 1.2, -3.68), -4.0],
]
const D2 := [
	["room407_batch2/bunk_frame.glb", Vector3(0.65, 0.0, -3.0), 0.0],
	["room407_batch2/bunk_frame.glb", Vector3(3.35, 0.0, -3.0), 0.0],
	["room407_batch2/locker_closed.glb", Vector3(0.3, 0.0, -0.45), -90.0],
	["room407_batch2/locker_closed.glb", Vector3(0.3, 0.0, -1.25), -90.0],
	["room407_batch2/locker_closed.glb", Vector3(3.7, 0.0, -0.45), 90.0],
	["room407_batch2/locker_closed.glb", Vector3(3.7, 0.0, -1.25), 90.0],
]
## Room 306's signs from room 407's things (PLAN A25: towel, bucket, things on the desk; same places).
const ITEMS_306 := [
	["room407_batch3/towel_draped.glb", Vector3(3.6, 1.12, -4.84), 180.0],
	["room407_batch1/bucket.glb", Vector3(3.4, 0.0, -4.4), 0.0],
	["room407_batch2/notebook.glb", Vector3(1.45, 0.76, -4.6), -12.0],
	["room407_batch2/books.glb", Vector3(2.25, 0.76, -4.72), 8.0],
	["room407_batch2/noodles.glb", Vector3(2.48, 0.76, -4.42), 30.0],
	["room407_batch3/pen_cup.glb", Vector3(1.12, 0.76, -4.72), 0.0],
]
## PS1 things that carry a room's sign: left drawn in the rooms the pilot does not finish.
const SIGNS := ["Shirt", "Slippers", "Poster", "Book0", "Book1", "Book2", "Book3", "Laundry", "DeskLamp", "DeskItems"]
const REPLACED_306 := ["Towel", "Bucket", "DeskItems"]
## H2: the corridor in T-256's cctv_corridor materials (floor 4) instead of wave 2's floor 1-3 ones.
const H2 := {"W2HallWall": "CVWall", "W2HallDado": "CVWall", "W2HallFloor": "CVFloor", "W2HallCeiling": "CVCeiling",
	"W2Divider": "CVFloor", "W1Terrazzo": "CVSkirting", "W1RailSteel": "CVRail", "W1Concrete": "CVSkirting"}
const B310_POSE := {"position": Vector3(2.0, 2.6, -0.35), "rotation": Vector3(-31.9081069, 0.0, 0.0)}

var ps1_hidden := {}
var probe_feed: SubViewport
var probe_cam: Camera3D


func _run() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUTPUT))
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(SURVEY + "feeds/"))
	AudioServer.set_bus_mute(0, true)
	if not _window():
		App.quit(1)
		return
	_camera()
	var part := _arg("parts", "pilot")
	if part == "vram3":
		await _part_vram3()
	else:
		await _part_pilot()
	_flush("pilot_%s.txt" % part)
	print("RESULT: t267 pilot %s, %d images" % [part, count])
	App.quit()


# ---------------------------------------------------------------- the kit

func _place(parent: Node3D, rows: Array, group: String) -> Node3D:
	var holder := Node3D.new()
	holder.name = group
	parent.add_child(holder)
	for row: Array in rows:
		var model := (load(P + String(row[0])) as PackedScene).instantiate() as Node3D
		holder.add_child(model)
		model.position = row[1]
		model.rotation_degrees.y = row[2]
	return holder


func _instance(parent: Node3D, path: String, name: String) -> Node3D:
	var node := (load(path) as PackedScene).instantiate() as Node3D
	node.name = name
	parent.add_child(node)
	return node


## The PS1 meshes the kit draws instead (nets, people, labels and, outside 306, the sign things stay).
func _ps1_meshes(room: Node3D, number: String) -> Array[MeshInstance3D]:
	var found: Array[MeshInstance3D] = []
	for node: Node in room.find_children("*", "MeshInstance3D", true, false):
		var path := String(room.get_path_to(node))
		var top := path.split("/")[0]
		if top in ["Victim", "Manager", "Real", "Corpse1", "Corpse2", "Corpse4"] or "/Net" in path:
			continue
		if top in SIGNS and not (number == "306" and top in REPLACED_306):
			continue
		found.append(node as MeshInstance3D)
	return found


func _build_kit(room: Node3D, number: String, with_d2: bool) -> Node3D:
	var real := Node3D.new()
	real.name = "Real"
	room.add_child(real)
	var shell := _instance(real, W10 + "cctv_room.glb", "Room")
	var hall := _instance(real, W10 + "cctv_hall.glb", "Hall")
	var floor_one := number.begins_with("1")
	(hall.find_child("Parapet", true, false) as Node3D).visible = floor_one
	(hall.find_child("Balustrade", true, false) as Node3D).visible = not floor_one
	var leaf := _instance(real, W2 + "room_door_leaf.glb", "Leaf")
	leaf.position = Vector3(2.875, 0.0, -0.1)
	leaf.rotation_degrees.y = -90.0
	var d1 := Node3D.new()
	d1.name = "D1"
	real.add_child(d1)
	_instance(d1, W10 + "cctv_light_set.glb", "LightSet")
	_place(real, COMMON, "Common")
	if with_d2:
		_place(real, D2, "D2").visible = false
	if number == "306":
		_place(real, ITEMS_306, "Items")
	if shell != null:
		_set_back(real, "W1")
	return real


func _set_back(real: Node3D, w: String) -> void:
	(real.find_child("BackPlain", true, false) as Node3D).visible = w == "W1"
	(real.find_child("BackBalcony", true, false) as Node3D).visible = w == "W2"


func _set_hall(real: Node3D, h: String) -> void:
	var hall := real.get_node("Hall") as Node3D
	for node: Node in hall.find_children("*", "MeshInstance3D", true, false):
		var mesh := node as MeshInstance3D
		for surface in mesh.mesh.get_surface_count():
			var own := mesh.mesh.surface_get_material(surface)
			var swap: String = H2.get(own.resource_path.get_file().get_basename() if own != null else "", "")
			mesh.set_surface_override_material(surface, load(CV + swap + ".tres") if h == "H2" and not swap.is_empty() else null)


## v: {"real": bool, "d": "D1"|"D2", "w": "W1"|"W2", "h": "H1"|"H2"}
func _variant(room: Node3D, number: String, v: Dictionary) -> void:
	var real := room.get_node("Real") as Node3D
	var key := String(room.name)
	if not ps1_hidden.has(key):
		ps1_hidden[key] = _ps1_meshes(room, number)
	for mesh: MeshInstance3D in ps1_hidden[key]:
		mesh.visible = not v.real
	real.visible = v.real
	if not v.real:
		return
	(real.get_node("D1") as Node3D).visible = v.get("d", "D1") == "D1"
	var d2 := real.get_node_or_null("D2") as Node3D
	if d2 != null:
		d2.visible = v.get("d", "D1") == "D2"
	_set_back(real, v.get("w", "W1"))
	_set_hall(real, v.get("h", "H1"))


func _room_triangles(room: Node3D) -> String:
	var tris := 0
	var meshes := 0
	var materials: Array[Material] = []
	for node: Node in room.find_children("*", "MeshInstance3D", true, false):
		var mesh := node as MeshInstance3D
		if not mesh.is_visible_in_tree() or mesh.mesh == null:
			continue
		var top := String(room.get_path_to(mesh)).split("/")[0]
		if top in ["Victim", "Manager", "Corpse1", "Corpse2", "Corpse4"]:
			continue
		meshes += 1
		tris += triangles(mesh.mesh)
		for material in materials_of(mesh):
			if not materials.has(material):
				materials.append(material)
	return "set %d meshes %d triangles %d materials" % [meshes, tris, materials.size()]


# ---------------------------------------------------------------- shots

func _probe_view(room: Node3D) -> void:
	if probe_feed == null:
		probe_feed = SubViewport.new()
		probe_feed.size = Vector2i(320, 240)
		probe_feed.render_target_update_mode = SubViewport.UPDATE_ALWAYS
		add_child(probe_feed)
		probe_cam = Camera3D.new()
		probe_cam.fov = 66.0
		probe_feed.add_child(probe_cam)
		probe_cam.current = true
	probe_cam.global_transform = room.global_transform * Transform3D(Basis.from_euler(B310_POSE.rotation * PI / 180.0), B310_POSE.position)


func _shoot_probe(stem: String) -> void:
	for frame in range(4):
		await get_tree().process_frame
	await RenderingServer.frame_post_draw
	var image := probe_feed.get_texture().get_image()
	image.save_png(SURVEY + "feeds/%s.png" % stem)
	var big := image.duplicate() as Image
	big.resize(960, 720, Image.INTERPOLATE_NEAREST)
	big.save_jpg(OUTPUT + stem + "_feed.jpg", 0.92)
	_note("FEED: %s probe %s" % [stem, _feed_info(probe_feed)])
	count += 1
	camera.make_current()
	camera.global_transform = probe_cam.global_transform
	camera.fov = probe_cam.fov
	await _snap(stem + "_1080.jpg")


func _look_local(room: Node3D, eye: Vector3, target: Vector3, file: String) -> void:
	camera.make_current()
	camera.global_position = room.global_transform * eye
	camera.look_at(room.global_transform * target)
	camera.fov = 70.0
	await _snap(file)


func _stage(director: Node, room: Node3D, id: StringName, pose: StringName) -> Node3D:
	director.call("_cctv_scene", id, pose)
	var manager := room.get_node_or_null("Manager") as Node3D
	var start := room.get_node("Hall/Start") as Node3D
	var door := room.get_node("Door") as Node3D
	var deadline := Time.get_ticks_msec() + 8000
	while is_instance_valid(manager) and Time.get_ticks_msec() < deadline:
		if manager.global_position.x < start.global_position.x - 0.66 * (start.global_position.x - door.global_position.x):
			break
		await get_tree().process_frame
	return manager


func _to_spot(room: Node3D, manager: Node3D) -> void:
	var spot := room.get_node("ManagerSpot") as Node3D
	var deadline := Time.get_ticks_msec() + 12000
	while is_instance_valid(manager) and Time.get_ticks_msec() < deadline:
		var flat := manager.global_position - spot.global_position
		flat.y = 0.0
		if flat.length() < 0.25:
			break
		await get_tree().process_frame
	for frame in range(20):
		await get_tree().process_frame


func _part_pilot() -> void:
	var scene := await _load_chapter(1)
	var director := scene.get_node("Chapter1Director")
	for frame in range(30):
		await get_tree().process_frame
	await RenderingServer.frame_post_draw
	_note("VRAM ch1 before %d MB" % _vram())
	var set_root := director.get_node("CctvSet") as Node3D
	var rooms := {}
	for number: String in ["102", "306", "209", "106"]:
		var room := set_root.get_node("Room" + number) as Node3D
		rooms[number] = room
		_build_kit(room, number, false)
		_variant(room, number, {"real": false})
	for frame in range(30):
		await get_tree().process_frame
	await RenderingServer.frame_post_draw
	_note("VRAM ch1 kit loaded (hidden) %d MB" % _vram())
	for number: String in rooms:
		_variant(rooms[number], number, {"real": true, "d": "D1"})
	for frame in range(30):
		await get_tree().process_frame
	await RenderingServer.frame_post_draw
	_note("VRAM ch1 D1 in four rooms %d MB" % _vram())
	var room := rooms["306"] as Node3D
	_place(room.get_node("Real") as Node3D, D2, "D2")
	_variant(room, "306", {"real": true, "d": "D2"})
	for frame in range(30):
		await get_tree().process_frame
	await RenderingServer.frame_post_draw
	_note("VRAM ch1 + D2 in 306 %d MB" % _vram())
	for number: String in rooms:
		_variant(rooms[number], number, {"real": false})
	# Room 306: the corridor moment.
	_only_feeds([&"cam_306", &"hall_306"])
	var manager := await _stage(director, room, &"cam_306", &"phone_lit")
	var victim := room.get_node_or_null("Victim")
	_freeze([manager, victim], true)
	var hall_cam := room.get_node("Hall/Cam") as Camera3D
	var hall_rows := [["ps1", {"real": false}], ["h1", {"real": true, "d": "D1", "h": "H1"}], ["h2", {"real": true, "d": "D1", "h": "H2"}]]
	for row: Array in hall_rows:
		_variant(room, "306", row[1])
		await _shoot_feed(&"hall_306", hall_cam, "pilot_306_hall_%s" % row[0])
		_note("  %s %s" % [row[0], _room_triangles(room)])
	_variant(room, "306", {"real": true, "d": "D1"})
	await _look_local(room, Vector3(-0.5, 1.6, 1.9), Vector3(2.45, 1.1, 0.0), "pilot_306_hall_door_1080.jpg")
	_freeze([manager, victim], false)
	_variant(room, "306", {"real": false})
	await _to_spot(room, manager)
	_freeze([manager, victim], true)
	var cam := room.get_node("Cam") as Camera3D
	var room_rows := [["ps1", {"real": false}], ["d1", {"real": true, "d": "D1"}], ["d2", {"real": true, "d": "D2"}]]
	for row: Array in room_rows:
		_variant(room, "306", row[1])
		await _shoot_feed(&"cam_306", cam, "pilot_306_room_%s" % row[0])
		_note("  %s %s" % [row[0], _room_triangles(room)])
		if row[0] != "ps1":
			await _look_local(room, Vector3(2.6, 1.65, -0.45), Vector3(1.2, 0.9, -3.6), "pilot_306_inside_%s_1080.jpg" % row[0])
	# W1 / W2 from Room310's camera pose (the only feed that faces the back wall).
	_probe_view(room)
	for row: Array in [["ps1", {"real": false}], ["w1", {"real": true, "d": "D1", "w": "W1"}], ["w2", {"real": true, "d": "D1", "w": "W2"}],
			["w2_d2", {"real": true, "d": "D2", "w": "W2"}]]:
		_variant(room, "306", row[1])
		await _shoot_probe("pilot_306_back_%s" % row[0])
	probe_feed.render_target_update_mode = SubViewport.UPDATE_DISABLED
	_freeze([manager, victim], false)
	if is_instance_valid(manager):
		manager.queue_free()
	_variant(room, "306", {"real": true, "d": "D1"})
	# The kit in 102, 209, 106: the signs on the feed (their sign things are still PS1).
	for number: String in ["102", "209", "106"]:
		var other := rooms[number] as Node3D
		_variant(other, number, {"real": true, "d": "D1"})
		var pose: StringName = {"102": &"answer", "209": &"cower", "106": &"sit_up"}[number]
		var id := StringName("cam_" + number)
		_only_feeds([id, StringName("hall_" + number)])
		manager = await _stage(director, other, id, pose)
		victim = other.get_node_or_null("Victim")
		_freeze([manager, victim], true)
		await _shoot_feed(StringName("hall_" + number), other.get_node("Hall/Cam") as Camera3D, "pilot_%s_hall_kit" % number)
		_freeze([manager, victim], false)
		await _to_spot(other, manager)
		_freeze([manager, victim], true)
		await _shoot_feed(id, other.get_node("Cam") as Camera3D, "pilot_%s_room_kit" % number)
		_freeze([manager, victim], false)
		if is_instance_valid(manager):
			manager.queue_free()
		await get_tree().process_frame
	scene.queue_free()
	for frame in range(10):
		await get_tree().process_frame
	# Room 310 (chapter 2): the kit without nets (310 has none), the corpses on their decks, then the lunge.
	scene = await _load_chapter(2)
	director = scene.get_node("Chapter2Director")
	for frame in range(30):
		await get_tree().process_frame
	var r310 := director.get_node("CctvSet/Room310") as Node3D
	_build_kit(r310, "310", false)
	_variant(r310, "310", {"real": true, "d": "D1", "w": "W2"})
	_only_feeds([&"cam_310", &"hall_310"])
	await _shoot_feed(&"hall_310", r310.get_node("Hall/Cam") as Camera3D, "pilot_310_hall_kit")
	await _shoot_feed(&"cam_310", r310.get_node("Cam") as Camera3D, "pilot_310_room_kit_before")
	_variant(r310, "310", {"real": true, "d": "D1", "w": "W1"})
	await _shoot_feed(&"cam_310", r310.get_node("Cam") as Camera3D, "pilot_310_room_kit_w1_before")
	_variant(r310, "310", {"real": true, "d": "D1", "w": "W2"})
	director.call("_cctv_310")
	await get_tree().create_timer(1.4).timeout
	await _shoot_feed(&"cam_310", r310.get_node("Cam") as Camera3D, "pilot_310_room_kit")
	scene.queue_free()
	for frame in range(6):
		await get_tree().process_frame


func _part_vram3() -> void:
	var scene := await _load_chapter(3)
	for frame in range(60):
		await get_tree().process_frame
	await RenderingServer.frame_post_draw
	_note("VRAM ch3 before %d MB" % _vram())
	var director := scene.get_node("Chapter3Director")
	var set_root := director.get_node("CctvSet") as Node3D
	for number: String in ["102", "306", "209", "106", "310"]:
		var room := set_root.get_node("Room" + number) as Node3D
		_build_kit(room, number, false)
		_variant(room, number, {"real": true, "d": "D1"})
	for frame in range(60):
		await get_tree().process_frame
	await RenderingServer.frame_post_draw
	_note("VRAM ch3 D1 kit in five rooms %d MB" % _vram())
	var r306 := set_root.get_node("Room306") as Node3D
	_place(r306.get_node("Real") as Node3D, D2, "D2")
	_variant(r306, "306", {"real": true, "d": "D2"})
	for frame in range(30):
		await get_tree().process_frame
	await RenderingServer.frame_post_draw
	_note("VRAM ch3 + D2 in 306 %d MB" % _vram())
	scene.queue_free()
	for frame in range(6):
		await get_tree().process_frame
