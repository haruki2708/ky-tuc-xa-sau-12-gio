extends Node3D
## T-267 round 1 survey (card section 2, step 1): the five CCTV rooms as main has them, and room 407's small things (A30).
## Parts (--parts=… or $env:T267_PARTS, PowerShell drops the "--"; one Godot at a time, Lượt Godot):
##   list    headless is fine: per chapter 1-4, every visible mesh inside room 407 outside the furnished tree (file,
##           triangles, materials); per CCTV room: meshes, triangles, materials; each room's collider print (md5).
##   feeds   window: chapter 1, director._cctv_scene() for 102/306/209/106 as test_cctv does, the room's two feeds set to
##           UPDATE_ALWAYS (all others disabled), captured straight from the 320 x 240 SubViewport when the manager is
##           in the corridor and when he stands at ManagerSpot, then the same camera at 1920 x 1080; chapter 2,
##           director._cctv_310(). Per-feed draws (RenderingServer viewport render info), video memory.
##   a30     window: close-ups at 0.3-0.6 m of room 407's small things with the player's torch (12 m, 28 degrees).
##   vram    window: video memory of chapters 1 and 3 at their start (one chapter per run: --chapter=1|3).
## Writes previews/wave10/survey_*.jpg, raw feeds wave10/survey/feeds/*.png, logs wave10/survey/*.txt.
const OUTPUT := "res://../art_source/graphics_upgrade/realistic_map/previews/wave10/"
const SURVEY := "res://../art_source/graphics_upgrade/realistic_map/wave10/survey/"
const RESOLUTION := Vector2i(1920, 1080)
const CH1_SCENES := [[&"cam_102", &"answer", "102"], [&"cam_306", &"phone_lit", "306"], [&"cam_209", &"cower", "209"],
	[&"cam_106", &"sit_up", "106"]]
const ROOMS := ["102", "306", "209", "106", "310"]
## Room 407 (room_407.tscn local metres) including the bathroom and the balcony.
const ROOM407_BOX := AABB(Vector3(-0.3, -0.2, -8.6), Vector3(8.6, 3.6, 8.9))
## Close-ups (room 407 local): [chapter, node path under the chapter scene, eye offset from the thing's centre].
const CLOSE_UPS := {
	"notebook": [1, "Floor4/Room407/Anchors/DatNote", Vector3(0.0, 0.38, 0.3)],
	"songbook": [1, "Floor4/Room407/Anchors/GuitarSongbook", Vector3(0.05, 0.38, -0.3)],
	"charger": [1, "Floor4/Room407/Anchors/DatLocker/Charger", Vector3(-0.5, 0.12, 0.0)],
	"outlet": [1, "Floor4/Room407/Anchors/KhoaOutlet", Vector3(0.45, 0.18, 0.06)],
	"khoa_note": [1, "Ch1KhoaNote", Vector3(0.22, 0.4, 0.1)],
	"router_led": [1, "Floor4/Room407/Anchors/Router/Model/LED", Vector3(-0.05, 0.08, -0.45)],
	"trash_paper": [1, "Floor4/Room407/Anchors/TrashBin", Vector3(0.0, 0.42, 0.25)],
	"rules_paper": [1, "Floor4/Door407/Pivot/RulesPaper", Vector3(0.05, 0.05, -0.5)],
	"power_strip": [1, "Floor4/Room407/Anchors/PowerStrip", Vector3(0.0, 0.35, 0.3)],
	"shower_buttons": [2, "Floor4/Room407/Anchors/ShowerYes", Vector3(0.45, 0.12, -0.11)],
}

var camera: Camera3D
var torch: SpotLight3D
var count := 0
var log_lines: PackedStringArray = []


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	call_deferred("_run")


func _arg(name: String, fallback: String) -> String:
	for argument: String in OS.get_cmdline_user_args():
		if argument.begins_with("--%s=" % name):
			return argument.trim_prefix("--%s=" % name)
	var from_env := OS.get_environment("T267_" + name.to_upper())
	return from_env if not from_env.is_empty() else fallback


func _note(text: String) -> void:
	log_lines.append(text)
	print(text)


func _flush(file_name: String) -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(SURVEY))
	var file := FileAccess.open(SURVEY + file_name, FileAccess.WRITE)
	file.store_string("\n".join(log_lines) + "\n")
	file.close()


func _load_chapter(chapter: int) -> Node3D:
	Chapter1Director.resume_checkpoint = &""
	GameState.reset()
	var scene := (load("res://scenes/main/chapter%d.tscn" % chapter) as PackedScene).instantiate() as Node3D
	scene.get_node("Chapter%dDirector" % chapter).set("auto_start", false)
	add_child(scene)
	for frame in range(3):
		await get_tree().process_frame
	var player := scene.get_node("Player") as Node3D
	player.visible = false
	player.process_mode = Node.PROCESS_MODE_DISABLED
	for layer: CanvasLayer in scene.find_children("*", "CanvasLayer", false, false):
		layer.visible = false
	return scene


func _vram() -> int:
	return int(Performance.get_monitor(Performance.RENDER_VIDEO_MEM_USED) / 1048576.0)


func _main_draws() -> String:
	return "draws %d prims %d objects %d vram %d MB" % [
		int(Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME)),
		int(Performance.get_monitor(Performance.RENDER_TOTAL_PRIMITIVES_IN_FRAME)),
		int(Performance.get_monitor(Performance.RENDER_TOTAL_OBJECTS_IN_FRAME)), _vram()]


func _snap(file: String) -> void:
	for frame in range(20):
		await get_tree().process_frame
	await RenderingServer.frame_post_draw
	var image: Image = get_viewport().get_texture().get_image()
	image.save_jpg(OUTPUT + file, 0.9)
	_note("CAPTURE: %s %s" % [file, _main_draws()])
	count += 1


func _camera() -> void:
	camera = Camera3D.new()
	add_child(camera)
	camera.near = 0.05
	torch = SpotLight3D.new()
	torch.name = "Flashlight"
	torch.position = Vector3(0.1, -0.08, -0.15)
	torch.light_color = Color(0.9, 0.94, 1.0)
	torch.light_energy = 1.5
	torch.spot_range = 12.0
	torch.spot_angle = 28.0
	torch.shadow_enabled = true
	torch.visible = false
	camera.add_child(torch)


func _window() -> bool:
	if DisplayServer.get_name() == "headless":
		push_error("This part needs a window.")
		return false
	get_window().mode = Window.MODE_WINDOWED
	get_window().content_scale_size = RESOLUTION
	get_window().size = RESOLUTION
	get_viewport().scaling_3d_scale = 1.0
	return true


func _run() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUTPUT))
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(SURVEY + "feeds/"))
	AudioServer.set_bus_mute(0, true)
	var part := _arg("parts", "list")
	if part != "list" and not _window():
		App.quit(1)
		return
	_camera()
	match part:
		"list":
			await _part_list()
		"feeds":
			await _part_feeds()
		"a30":
			await _part_a30()
		"vram":
			await _part_vram(int(_arg("chapter", "1")))
	_flush("%s%s.txt" % [part, "" if part != "vram" else "_ch" + _arg("chapter", "1")])
	print("RESULT: t267 survey %s, %d images" % [part, count])
	App.quit()


# ---------------------------------------------------------------- list

static func triangles(mesh: Mesh) -> int:
	return mesh.get_faces().size() / 3 if mesh != null else 0


static func materials_of(node: MeshInstance3D) -> Array[Material]:
	var found: Array[Material] = []
	if node.mesh == null:
		return found
	for surface in node.mesh.get_surface_count():
		var material := node.get_active_material(surface)
		if material != null and not found.has(material):
			found.append(material)
	return found


## The nearest scene file the mesh comes from, and whether code made the mesh or instanced that scene at run time.
static func owner_file(node: Node, scene_root: Node) -> String:
	var at := node
	while at != null:
		if not at.scene_file_path.is_empty():
			var how := ""
			if node.owner == null:
				how = " [mesh made at run time]"
			elif at.owner == null and at != scene_root:
				how = " [instanced at run time under %s]" % scene_root.get_path_to(at.get_parent())
			return at.scene_file_path.trim_prefix("res://") + how
		at = at.get_parent()
	return "?"


## Every collision shape under root, in root's space (test_t256_floor4_rest.collider_print, same rows).
static func collider_print(root: Node3D) -> String:
	var auto_name := RegEx.create_from_string("@[A-Za-z0-9_]+@[0-9]+")
	var rows: Array[String] = []
	var to_root := root.global_transform.affine_inverse()
	for node: Node in root.find_children("*", "CollisionShape3D", true, false):
		var shape_node := node as CollisionShape3D
		var body := shape_node.get_parent() as CollisionObject3D
		var shape := shape_node.shape
		var size := ""
		if shape is BoxShape3D:
			size = str((shape as BoxShape3D).size.snapped(Vector3.ONE * 0.0001))
		elif shape is CapsuleShape3D:
			size = "%.4f %.4f" % [(shape as CapsuleShape3D).radius, (shape as CapsuleShape3D).height]
		elif shape is CylinderShape3D:
			size = "%.4f %.4f" % [(shape as CylinderShape3D).radius, (shape as CylinderShape3D).height]
		elif shape is ConcavePolygonShape3D:
			size = "faces %d" % (shape as ConcavePolygonShape3D).get_faces().size()
		elif shape is ConvexPolygonShape3D:
			size = "points %d" % (shape as ConvexPolygonShape3D).points.size()
		var xform: Transform3D = to_root * shape_node.global_transform
		var path := auto_name.sub(String(root.get_path_to(shape_node)), "@", true)
		rows.append("%s|%s|%s|%s|%s|%s|%d|%d" % [path, shape.get_class() if shape else "-", size,
			str(xform.origin.snapped(Vector3.ONE * 0.0001)), str(xform.basis.get_euler().snapped(Vector3.ONE * 0.001)),
			shape_node.disabled, body.collision_layer if body else -1, body.collision_mask if body else -1])
	rows.sort()
	return "\n".join(rows)


func _room_stats(room: Node3D, label: String) -> void:
	var meshes := 0
	var tris := 0
	var materials: Array[Material] = []
	var by_kind := {}
	for node: Node in room.find_children("*", "MeshInstance3D", true, false):
		var mesh := node as MeshInstance3D
		if not mesh.is_visible_in_tree() or mesh.mesh == null:
			continue
		meshes += 1
		var t := triangles(mesh.mesh)
		tris += t
		for material in materials_of(mesh):
			if not materials.has(material):
				materials.append(material)
		var top := String(room.get_path_to(mesh)).split("/")[0]
		by_kind[top] = by_kind.get(top, 0) + t
	var parts := PackedStringArray()
	for key: String in by_kind:
		parts.append("%s %d" % [key, by_kind[key]])
	_note("ROOM %s: %d meshes, %d triangles, %d materials | %s" % [label, meshes, tris, materials.size(), ", ".join(parts)])


func _part_list() -> void:
	# The CCTV set alone: stats, collider prints, the contract nodes.
	var set_root := (load("res://scenes/levels/cctv/cctv_set.tscn") as PackedScene).instantiate() as Node3D
	add_child(set_root)
	for frame in range(2):
		await get_tree().process_frame
	for number: String in ROOMS:
		var room := set_root.get_node("Room" + number) as Node3D
		_room_stats(room, number)
		_room_stats(room.get_node("Hall") as Node3D, number + "/Hall")
		var print_text := collider_print(room)
		_note("COLLIDERS %s: %d shapes md5 %s" % [number, print_text.count("\n") + 1, print_text.md5_text()])
		for path: String in ["Cam", "Hall/Cam", "Hall/Start", "Hall/Tube", "Door", "ManagerSpot", "VictimBed", "Victim",
				"NumberInside", "NumberOutside", "NightLight", "DeskLamp", "Corpse1", "Corpse2", "Corpse4"]:
			var node := room.get_node_or_null(path) as Node3D
			if node == null:
				continue
			var extra := ""
			if node is Camera3D:
				extra = " fov %.1f far %.1f" % [(node as Camera3D).fov, (node as Camera3D).far]
			_note("  CONTRACT %s/%s %s pos %s rot %s%s" % [number, path, node.get_class(), node.position, node.rotation_degrees, extra])
	set_root.queue_free()
	await get_tree().process_frame
	# Room 407's small things, chapter by chapter.
	for chapter in [1, 2, 3, 4]:
		var scene := await _load_chapter(chapter)
		var director := scene.get_node("Chapter%dDirector" % chapter)
		if chapter == 1 and director.has_method("_place_khoa_note"):
			director.call("_place_khoa_note", null)
			await get_tree().process_frame
		await _list_407(scene, chapter)
		scene.queue_free()
		for frame in range(6):
			await get_tree().process_frame


func _list_407(scene: Node3D, chapter: int) -> void:
	var room := scene.get_node("Floor4/Room407") as Node3D
	var furnished := room.get_node_or_null("Furnished")
	var to_room := room.global_transform.affine_inverse()
	var total := 0
	var all_materials: Array[Material] = []
	for node: Node in scene.find_children("*", "MeshInstance3D", true, false):
		var mesh := node as MeshInstance3D
		if not mesh.is_visible_in_tree() or mesh.mesh == null:
			continue
		if furnished != null and furnished.is_ancestor_of(mesh):
			continue
		var centre := to_room * (mesh.global_transform * mesh.get_aabb().get_center())
		if not ROOM407_BOX.has_point(centre):
			continue
		var path := String(scene.get_path_to(mesh))
		var t := triangles(mesh.mesh)
		var mats := materials_of(mesh)
		var names := PackedStringArray()
		for material in mats:
			names.append(material.resource_name if not material.resource_name.is_empty() else material.get_class())
			if not all_materials.has(material):
				all_materials.append(material)
		total += t
		var size := (mesh.global_transform.basis * mesh.get_aabb().size).abs()
		_note("A30 ch%d | %s | %s | tris %d | mats %d [%s] | size %s | at %s | %s" % [chapter, path, mesh.mesh.get_class(), t,
			mats.size(), ", ".join(names), size.snapped(Vector3.ONE * 0.001), centre.snapped(Vector3.ONE * 0.01), owner_file(mesh, scene)])
	_note("A30 ch%d total %d triangles, %d materials" % [chapter, total, all_materials.size()])


# ---------------------------------------------------------------- feeds

func _feeds() -> Array[SubViewport]:
	var found: Array[SubViewport] = []
	for node: Node in get_tree().get_nodes_in_group(&"cctv_feed"):
		found.append(node as SubViewport)
	return found


func _feed(id: StringName) -> SubViewport:
	for feed in _feeds():
		if feed.get("camera_id") == id:
			return feed
	return null


func _only_feeds(ids: Array) -> void:
	for feed in _feeds():
		feed.render_target_update_mode = SubViewport.UPDATE_ALWAYS if feed.get("camera_id") in ids else SubViewport.UPDATE_DISABLED


func _feed_info(feed: SubViewport) -> String:
	var rid := feed.get_viewport_rid()
	var visible_type := RenderingServer.VIEWPORT_RENDER_INFO_TYPE_VISIBLE
	var shadow_type := RenderingServer.VIEWPORT_RENDER_INFO_TYPE_SHADOW
	return "feed draws %d prims %d objects %d (shadow draws %d)" % [
		RenderingServer.viewport_get_render_info(rid, visible_type, RenderingServer.VIEWPORT_RENDER_INFO_DRAW_CALLS_IN_FRAME),
		RenderingServer.viewport_get_render_info(rid, visible_type, RenderingServer.VIEWPORT_RENDER_INFO_PRIMITIVES_IN_FRAME),
		RenderingServer.viewport_get_render_info(rid, visible_type, RenderingServer.VIEWPORT_RENDER_INFO_OBJECTS_IN_FRAME),
		RenderingServer.viewport_get_render_info(rid, shadow_type, RenderingServer.VIEWPORT_RENDER_INFO_DRAW_CALLS_IN_FRAME)]


## The feed as the phone gets it (320 x 240), saved raw and at x3 with nearest-neighbour pixels; then the same camera
## (transform and fov) at 1920 x 1080 in the main viewport.
func _shoot_feed(id: StringName, source: Camera3D, stem: String) -> void:
	var feed := _feed(id)
	if feed == null:
		_note("NO FEED %s" % id)
		return
	for frame in range(4):
		await get_tree().process_frame
	await RenderingServer.frame_post_draw
	var image := feed.get_texture().get_image()
	image.save_png(SURVEY + "feeds/%s.png" % stem)
	var big := image.duplicate() as Image
	big.resize(image.get_width() * 3, image.get_height() * 3, Image.INTERPOLATE_NEAREST)
	big.save_jpg(OUTPUT + stem + "_feed.jpg", 0.92)
	_note("FEED: %s %s %dx%d %s" % [stem, id, image.get_width(), image.get_height(), _feed_info(feed)])
	count += 1
	camera.make_current()
	camera.global_transform = source.global_transform
	camera.fov = source.fov
	await _snap(stem + "_1080.jpg")


func _freeze(nodes: Array, frozen: bool) -> void:
	for node: Node in nodes:
		if is_instance_valid(node):
			node.process_mode = Node.PROCESS_MODE_DISABLED if frozen else Node.PROCESS_MODE_INHERIT


func _part_feeds() -> void:
	var scene := await _load_chapter(1)
	var director := scene.get_node("Chapter1Director")
	for frame in range(30):
		await get_tree().process_frame
	_note("VRAM ch1 start %d MB" % _vram())
	var set_root := director.get_node("CctvSet") as Node3D
	for row: Array in CH1_SCENES:
		var id: StringName = row[0]
		var number: String = row[2]
		var room := set_root.get_node("Room" + number) as Node3D
		var hall_id := StringName("hall_" + number)
		_only_feeds([id, hall_id])
		director.call("_cctv_scene", id, row[1])
		var manager := room.get_node_or_null("Manager") as Node3D
		var start := room.get_node("Hall/Start") as Node3D
		var door := room.get_node("Door") as Node3D
		var spot := room.get_node("ManagerSpot") as Node3D
		var deadline := Time.get_ticks_msec() + 8000
		# In the corridor, two thirds of the way from Start to the door.
		while is_instance_valid(manager) and Time.get_ticks_msec() < deadline:
			if manager.global_position.x < start.global_position.x - 0.66 * (start.global_position.x - door.global_position.x):
				break
			await get_tree().process_frame
		_freeze([manager, room.get_node_or_null("Victim")], true)
		await _shoot_feed(hall_id, room.get_node("Hall/Cam") as Camera3D, "survey_%s_hall" % number)
		_freeze([manager, room.get_node_or_null("Victim")], false)
		deadline = Time.get_ticks_msec() + 12000
		while is_instance_valid(manager) and Time.get_ticks_msec() < deadline:
			var flat := manager.global_position - spot.global_position
			flat.y = 0.0
			if flat.length() < 0.25:
				break
			await get_tree().process_frame
		for frame in range(20):
			await get_tree().process_frame
		_freeze([manager, room.get_node_or_null("Victim")], true)
		await _shoot_feed(id, room.get_node("Cam") as Camera3D, "survey_%s_room" % number)
		_freeze([manager, room.get_node_or_null("Victim")], false)
		if manager != null and is_instance_valid(manager):
			manager.queue_free()
		await get_tree().process_frame
	_note("VRAM ch1 after feeds %d MB" % _vram())
	scene.queue_free()
	for frame in range(10):
		await get_tree().process_frame
	# Chapter 2: room 310 loses the game (D-046).
	scene = await _load_chapter(2)
	director = scene.get_node("Chapter2Director")
	for frame in range(30):
		await get_tree().process_frame
	set_root = director.get_node("CctvSet") as Node3D
	var r310 := set_root.get_node("Room310") as Node3D
	_only_feeds([&"cam_310", &"hall_310"])
	await _shoot_feed(&"hall_310", r310.get_node("Hall/Cam") as Camera3D, "survey_310_hall")
	await _shoot_feed(&"cam_310", r310.get_node("Cam") as Camera3D, "survey_310_room_before")
	director.call("_cctv_310")
	await get_tree().create_timer(1.4).timeout
	await _shoot_feed(&"cam_310", r310.get_node("Cam") as Camera3D, "survey_310_room")
	_note("VRAM ch2 %d MB" % _vram())
	scene.queue_free()
	for frame in range(6):
		await get_tree().process_frame


# ---------------------------------------------------------------- a30

func _part_a30() -> void:
	for chapter in [1, 2]:
		var scene := await _load_chapter(chapter)
		var director := scene.get_node("Chapter%dDirector" % chapter)
		if chapter == 1 and director.has_method("_place_khoa_note"):
			director.call("_place_khoa_note", null)
		for frame in range(20):
			await get_tree().process_frame
		var room := scene.get_node("Floor4/Room407") as Node3D
		for key: String in CLOSE_UPS:
			var row: Array = CLOSE_UPS[key]
			if int(row[0]) != chapter:
				continue
			var thing := scene.get_node_or_null(String(row[1])) as Node3D
			if thing == null:
				_note("MISSING %s %s" % [key, row[1]])
				continue
			var centre := _centre(thing)
			var eye: Vector3 = centre + room.global_basis * (row[2] as Vector3)
			camera.make_current()
			camera.global_position = eye
			camera.look_at(centre, Vector3.UP if absf((centre - eye).normalized().y) < 0.95 else room.global_basis.z)
			camera.fov = 60.0
			torch.visible = true
			await _snap("survey_a30_%s_torch.jpg" % key)
		scene.queue_free()
		for frame in range(6):
			await get_tree().process_frame


func _centre(thing: Node3D) -> Vector3:
	var box := AABB()
	var first := true
	for node: Node in [thing] + thing.find_children("*", "MeshInstance3D", true, false):
		var mesh := node as MeshInstance3D
		if mesh == null or mesh.mesh == null or not mesh.is_visible_in_tree():
			continue
		var world := mesh.global_transform * mesh.get_aabb()
		box = world if first else box.merge(world)
		first = false
	return box.get_center() if not first else thing.global_position


# ---------------------------------------------------------------- vram

func _part_vram(chapter: int) -> void:
	var scene := await _load_chapter(chapter)
	for frame in range(60):
		await get_tree().process_frame
	await RenderingServer.frame_post_draw
	_note("VRAM ch%d start %d MB (main camera, player's view)" % [chapter, _vram()])
	scene.queue_free()
	for frame in range(6):
		await get_tree().process_frame
