extends "survey_wave10.gd"
## T-267 round 2 stills (card section 2, steps 5-8; D-188). Copy next to survey_wave10.gd in game/_probe_tmp/ with a
## .tscn whose root Node3D carries this script. Parts ($env:T267_PARTS; one Godot at a time, Lượt Godot):
##   cctv   window: chapter 1, director._cctv_scene() for 102/306/209/106 as test_cctv does; chapter 2, room 310 and
##          director._cctv_310(). The manager and the victim are held (process off) and time is all but stopped
##          (after the chapter has run 3 s, as the library occluders' check did); on that same frame each feed is shot
##          before (the PS1 set as main has it: Real hidden, its PS1 meshes shown, no occluder) and after (wave 10),
##          then after with the occluders off: occluders on and off must give the same pixels. Feeds straight from
##          their 320 x 240 SubViewport (x3 nearest), and the same camera at 1920 x 1080. Draws per feed, each state.
##   vram   window: one chapter ($env:T267_CHAPTER = 1|3): the chapter starts with every Real off (its PS1 set as
##          main), video memory; then the rooms are furnished (Real._ready() again with upgraded on), video memory.
##          The player's view down onto the set's place, draws before and after (Real draws only near its cameras).
##   a30    window: room 407's small things in chapters 1 and 2 from round 1's torch close-ups (survey_a30_*_torch.jpg
##          are their before), a30_<thing>_after.jpg; the rules paper from the corridor, before (its old z put back for
##          the frame) and after.
##   sync   window: the same four views in chapters 1-4 (room 407 from its door, opened for the still, the floor-4 corridor from the stairs'
##          end, the shared washroom, room 403 through its door, opened for the still): sync_ch<N>_<view>.jpg.
## Writes previews/wave10/{before,after}_*.jpg, wave10/survey/feeds/r2_*.png, wave10/survey/r2_*.txt.
const SCENES := [[&"cam_102", &"answer", "102"], [&"cam_306", &"phone_lit", "306"], [&"cam_209", &"cower", "209"],
	[&"cam_106", &"sit_up", "106"]]
## Per-channel tolerance (6/255) for the occluder check, as the library occluders' check used; exact counts too.
const TOLERANCE := 6.0 / 255.0
var hold_real := false


func _run() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUTPUT))
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(SURVEY + "feeds/"))
	AudioServer.set_bus_mute(0, true)
	if not _window():
		App.quit(1)
		return
	_camera()
	var part := _arg("parts", "cctv")
	match part:
		"cctv":
			await _part_cctv()
		"cctv310":
			await _part_cctv310()
		"vram":
			await _part_vram2(int(_arg("chapter", "1")))
		"a30":
			await _part_a30_after()
		"sync":
			await _part_sync()
	_flush("r2_%s%s.txt" % [part, "" if part != "vram" else "_ch" + _arg("chapter", "1")])
	print("RESULT: t267 round 2 %s, %d images" % [part, count])
	App.quit()


# ---------------------------------------------------------------- states

func _reals(set_root: Node3D) -> Array[Node3D]:
	var found: Array[Node3D] = []
	for number: String in ROOMS:
		found.append(set_root.get_node("Room%s/Real" % number) as Node3D)
	return found


## "before": the PS1 set as main has it (no wave 10; occlusion culling off, which is what main's feeds do with no
## occluder in the set); "after": wave 10 with its occluders; "after_no_occ": wave 10, occlusion culling off.
## The occluders stay in place and the viewports' use_occlusion_culling is switched: in Godot 4.7.2 an
## OccluderInstance3D hidden (or taken out of the tree) and shown again does not occlude until a viewport's culling is
## switched (wave10/survey/r2_occ_probe.txt); in the game the occluders never move.
func _state(set_root: Node3D, state: String) -> void:
	for real: Node3D in _reals(set_root):
		var upgraded := state != "before"
		real.visible = upgraded
		for mesh: MeshInstance3D in real.get("replaced"):
			mesh.visible = not upgraded
	var culling := state == "after"
	for feed in _feeds():
		feed.use_occlusion_culling = culling
	get_viewport().use_occlusion_culling = culling


func _settle() -> void:
	for frame in range(6):
		await get_tree().process_frame
	await RenderingServer.frame_post_draw


func _raw(id: StringName) -> Image:
	return _feed(id).get_texture().get_image()


## The same frame in three states: before / after (1080p too), after without occluders (feed only, compared).
func _three(set_root: Node3D, id: StringName, source: Camera3D, stem: String) -> void:
	var feed := _feed(id)
	if feed == null:
		_note("NO FEED %s" % id)
		return
	var images := {}
	var info := {}
	for state: String in ["before", "after", "after_no_occ", "after"]:
		_state(set_root, state)
		await _settle()
		var key := state if not images.has(state) else state + "_again"
		images[key] = _raw(id)
		info[key] = _feed_info(feed)
	for state: String in ["before", "after"]:
		var image: Image = images[state]
		image.save_png(SURVEY + "feeds/r2_%s_%s.png" % [state, stem])
		var big := image.duplicate() as Image
		big.resize(image.get_width() * 3, image.get_height() * 3, Image.INTERPOLATE_NEAREST)
		big.save_jpg(OUTPUT + "%s_%s_feed.jpg" % [state, stem], 0.92)
		count += 1
	(images["after_no_occ"] as Image).save_png(SURVEY + "feeds/r2_after_no_occ_%s.png" % stem)
	var off := _diff(images["after"], images["after_no_occ"])
	var again := _diff(images["after"], images["after_again"])
	_note("FEED %s %s | before %s | after %s | after, occluders off %s" % [stem, id, info["before"], info["after"], info["after_no_occ"]])
	_note("OCCLUDERS %s %s: on/off differ in %d pixels (%d over 6/255); on/on again %d (%d)" % [stem, id, off[0], off[1], again[0], again[1]])
	for state: String in ["before", "after"]:
		_state(set_root, state)
		camera.make_current()
		camera.global_transform = source.global_transform
		camera.fov = source.fov
		await _snap("%s_%s_1080.jpg" % [state, stem])
	_state(set_root, "after")


## [pixels that differ at all, pixels where a channel differs by more than TOLERANCE]
func _diff(a: Image, b: Image) -> Array[int]:
	var exact := 0
	var over := 0
	if a.get_size() != b.get_size():
		return [-1, -1]
	for y in a.get_height():
		for x in a.get_width():
			var ca := a.get_pixel(x, y)
			var cb := b.get_pixel(x, y)
			if ca != cb:
				exact += 1
				if absf(ca.r - cb.r) > TOLERANCE or absf(ca.g - cb.g) > TOLERANCE or absf(ca.b - cb.b) > TOLERANCE:
					over += 1
	return [exact, over]


func _hold(frozen: bool, nodes: Array) -> void:
	_freeze(nodes, frozen)
	Engine.time_scale = 0.001 if frozen else 1.0


# ---------------------------------------------------------------- cctv

func _part_cctv() -> void:
	var scene := await _load_chapter(1)
	var director := scene.get_node("Chapter1Director")
	await get_tree().create_timer(3.0).timeout
	_note("VRAM ch1 %d MB" % _vram())
	var set_root := director.get_node("CctvSet") as Node3D
	for number: String in ROOMS:
		_room_stats(set_root.get_node("Room" + number) as Node3D, number + " after")
	# The floor-4 feed first (nothing of wave 10 stands in it).
	_only_feeds([&"cam_corridor"])
	_hold(true, [])
	await _three(set_root, &"cam_corridor", set_root.get_node("Corridor/Cam") as Camera3D, "corridor_cam")
	_hold(false, [])
	for row: Array in SCENES:
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
		while is_instance_valid(manager) and Time.get_ticks_msec() < deadline:
			if manager.global_position.x < start.global_position.x - 0.66 * (start.global_position.x - door.global_position.x):
				break
			await get_tree().process_frame
		var held := [manager, room.get_node_or_null("Victim")]
		_hold(true, held)
		await _three(set_root, hall_id, room.get_node("Hall/Cam") as Camera3D, "%s_hall" % number)
		_hold(false, held)
		deadline = Time.get_ticks_msec() + 12000
		while is_instance_valid(manager) and Time.get_ticks_msec() < deadline:
			var flat := manager.global_position - spot.global_position
			flat.y = 0.0
			if flat.length() < 0.25:
				break
			await get_tree().process_frame
		for frame in range(20):
			await get_tree().process_frame
		_hold(true, held)
		await _three(set_root, id, room.get_node("Cam") as Camera3D, "%s_room" % number)
		_hold(false, held)
		if is_instance_valid(manager):
			manager.queue_free()
		await get_tree().process_frame
	scene.queue_free()
	for frame in range(10):
		await get_tree().process_frame
	await _part_cctv310()


## Chapter 2: room 310 before and after it loses the game (D-046).
func _part_cctv310() -> void:
	var scene := await _load_chapter(2)
	var director := scene.get_node("Chapter2Director")
	await get_tree().create_timer(3.0).timeout
	var set_root := director.get_node("CctvSet") as Node3D
	var r310 := set_root.get_node("Room310") as Node3D
	_only_feeds([&"cam_310", &"hall_310"])
	# The three bodies play cards (sit_play): held too, so the frame stands still.
	var corpses := [r310.get_node_or_null("Victim"), r310.get_node_or_null("Corpse1"), r310.get_node_or_null("Corpse2"),
		r310.get_node_or_null("Corpse4")]
	# The director turns the players' heads while they play: held as well for these two shots.
	director.process_mode = Node.PROCESS_MODE_DISABLED
	_hold(true, corpses)
	await _three(set_root, &"hall_310", r310.get_node("Hall/Cam") as Camera3D, "310_hall")
	await _three(set_root, &"cam_310", r310.get_node("Cam") as Camera3D, "310_room_before_lunge")
	_hold(false, corpses)
	director.process_mode = Node.PROCESS_MODE_INHERIT
	director.call("_cctv_310")
	await get_tree().create_timer(1.4).timeout
	_hold(true, corpses)
	await _three(set_root, &"cam_310", r310.get_node("Cam") as Camera3D, "310_room")
	_hold(false, corpses)
	_note("VRAM ch2 %d MB" % _vram())
	scene.queue_free()
	for frame in range(6):
		await get_tree().process_frame


# ---------------------------------------------------------------- vram

func _on_node_added(node: Node) -> void:
	if hold_real and node.name == &"Real" and node.get_script() != null and String(node.get_script().resource_path).ends_with("cctv_room_real.gd"):
		node.set("upgraded", false)


func _part_vram2(chapter: int) -> void:
	hold_real = true
	get_tree().node_added.connect(_on_node_added)
	var scene := await _load_chapter(chapter)
	var director := scene.get_node("Chapter%dDirector" % chapter)
	hold_real = false
	for frame in range(60):
		await get_tree().process_frame
	await RenderingServer.frame_post_draw
	var set_root := director.get_node("CctvSet") as Node3D
	var reals := _reals(set_root)
	for real: Node3D in reals:
		assert((real.get("replaced") as Array).is_empty())
	_note("VRAM ch%d start, PS1 set (as main) %d MB" % [chapter, _vram()])
	var look := _look_down(set_root)
	await _snap("r2_vram_ch%d_down_before.jpg" % chapter)
	for real: Node3D in reals:
		real.set("upgraded", true)
		real.call("_ready")
	scene.get_node("Player").process_mode = Node.PROCESS_MODE_DISABLED
	for frame in range(60):
		await get_tree().process_frame
	await RenderingServer.frame_post_draw
	_note("VRAM ch%d wave 10 in the five rooms %d MB" % [chapter, _vram()])
	camera.global_transform = look
	await _snap("r2_vram_ch%d_down_after.jpg" % chapter)
	scene.queue_free()
	for frame in range(6):
		await get_tree().process_frame


## Floor-4 metres: [eye, target, torch].
const SYNC := {
	"room407_door": [Vector3(31.95, 1.6, 0.3), Vector3(34.6, 0.9, -4.6), true],
	"corridor_stairs": [Vector3(0.6, 1.65, 2.0), Vector3(22.0, 1.25, 1.9), false],
	"washroom": [Vector3(3.0, 1.65, 0.8), Vector3(2.5, 1.1, -3.5), true],
	"room403_open": [Vector3(17.2, 1.6, 2.6), Vector3(15.6, 0.9, -3.0), true],
}
const A30_KEYS := ["notebook", "songbook", "outlet", "trash_paper", "shower_buttons"]
const RULES_BEFORE_Z := -0.025


func _view(floor4: Node3D, eye: Vector3, target: Vector3, torch_on: bool, file: String) -> void:
	camera.make_current()
	camera.fov = 70.0
	camera.global_position = floor4.to_global(eye)
	camera.look_at(floor4.to_global(target), Vector3.UP)
	torch.visible = torch_on
	await _snap(file)


func _part_a30_after() -> void:
	for chapter in [1, 2]:
		var scene := await _load_chapter(chapter)
		var director := scene.get_node("Chapter%dDirector" % chapter)
		if chapter == 1 and director.has_method("_place_khoa_note"):
			director.call("_place_khoa_note", null)
		await get_tree().create_timer(3.0).timeout
		var room := scene.get_node("Floor4/Room407") as Node3D
		for key: String in A30_KEYS:
			var row: Array = CLOSE_UPS[key]
			if int(row[0]) != chapter:
				continue
			var thing := scene.get_node_or_null(String(row[1])) as Node3D
			if thing == null:
				_note("MISSING %s %s" % [key, row[1]])
				continue
			var centre := _centre(thing)
			camera.make_current()
			camera.global_position = centre + room.global_basis * (row[2] as Vector3)
			camera.look_at(centre, Vector3.UP if absf((centre - camera.global_position).normalized().y) < 0.95 else room.global_basis.z)
			camera.fov = 60.0
			torch.visible = true
			await _snap("a30_%s_after.jpg" % key)
		if chapter == 1:
			# The rules paper from the corridor (round 1 looked from the room, where the Tripo leaf hides it).
			var paper := scene.get_node("Floor4/Door407/Pivot/RulesPaper") as Node3D
			var anchor := scene.get_node("Floor4/Anchors/RulesPaper407") as Node3D
			var now := paper.position
			for state: String in ["before", "after"]:
				paper.position = Vector3(now.x, now.y, RULES_BEFORE_Z) if state == "before" else now
				scene.get_node("Floor4").call("sync_door_anchor")
				var centre := paper.global_position
				for side: Array in [["corridor", Vector3(0.12, 0.05, 0.55)], ["edge", Vector3(0.45, -0.05, 0.25)]]:
					camera.make_current()
					camera.global_position = centre + (side[1] as Vector3)
					camera.look_at(centre, Vector3.UP)
					camera.fov = 55.0
					torch.visible = true
					await _snap("a30_rules_paper_%s_%s.jpg" % [side[0], state])
			_note("RULES_PAPER z %.3f, anchor %s" % [paper.position.z, anchor.global_position])
		scene.queue_free()
		for frame in range(6):
			await get_tree().process_frame


func _part_sync() -> void:
	for chapter in [1, 2, 3, 4]:
		var scene := await _load_chapter(chapter)
		await get_tree().create_timer(3.0).timeout
		var floor4 := scene.find_child("Floor4", true, false) as Node3D
		if floor4 == null:
			_note("NO FLOOR4 in chapter %d" % chapter)
			scene.queue_free()
			continue
		# Room 403's and room 407's doors opened for the stills (a room's inside draws only while its door is open).
		for node: Node in floor4.find_children("*", "", true, false):
			if (String(node.name).contains("403") or String(node.name) == "Door407") and node.has_method("set_open") and node.get("is_open") != true:
				node.call("set_open", true, 0.0)
		for frame in range(10):
			await get_tree().process_frame
		for view: String in SYNC:
			var row: Array = SYNC[view]
			await _view(floor4, row[0], row[1], row[2], "sync_ch%d_%s.jpg" % [chapter, view])
		_note("SYNC ch%d Floor4 at %s, VRAM %d MB" % [chapter, floor4.global_position, _vram()])
		scene.queue_free()
		for frame in range(10):
			await get_tree().process_frame


## The player's height over the set's middle, looking straight down (the set 60 m under it).
func _look_down(set_root: Node3D) -> Transform3D:
	camera.make_current()
	camera.fov = 75.0
	camera.far = 4000.0
	var over := set_root.to_global(Vector3(22.0, 0.0, -1.0))
	camera.global_position = Vector3(over.x, 11.0, over.z)
	camera.look_at(camera.global_position + Vector3.DOWN, Vector3.FORWARD)
	return camera.global_transform
