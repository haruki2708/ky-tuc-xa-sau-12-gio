extends "res://_probe_tmp/capture_wave9.gd"
## T-266 round 2 stills (card section 6, D-187): before / after with the same camera in chapter 4's real scene
## (director.run_from(&"room407"), no bot: the player held and hidden, HUD hidden, sound muted, the torch the camera's own).
## "before" is main's look rebuilt in the same run: the PS1 boards, ink planes, ceiling panel, vent boxes and damage boxes
## shown, the wave-9 pieces hidden (Real, Wave9Fixtures), the slats at main's 70 degrees with the bedding left on the beds,
## and the Tripo leaf left visible at 60/80 % (main's bug). The ward's "before" are round 1's survey_ward_* (main itself).
## Parts ($env:T266_PARTS, comma separated; PowerShell drops the "--" before user arguments):
##   r407   room 407 from the door (not flipped, flipped 1-2-4 and 2-1-4), each bed, mid-fall, the floor, the decoys
##          closed and searched, the door at 0/30/60/80 % from inside
##   crowd  a fresh room407 stage whose four corpses walk to the door: frozen there, the door at 60/80 % from the corridor
##   ch1    room 407 in chapter 1 (C2), same cameras
##   ward   the ending's frame (Camera_Wake, K2) in both endings at brightness 1.0 and 1.45, a corner view, the cards
## Copy this file and capture_wave9.gd to game/_probe_tmp/ with a scene whose root has this one, then (Lượt Godot):
##   $env:T266_PARTS = "r407,crowd,ch1,ward"; godot --path game res://_probe_tmp/capture_wave9_r2.tscn
## Writes previews/wave9/before_* and after_*.jpg (1600 x 900) and wave9/survey/capture_r2.txt (draws, primitives, VRAM).
const R2_VIEWS := {
	"bunkA_wide": {"eye": Vector3(33.2, 1.65, -0.9), "target": Vector3(31.0, 0.75, -3.0), "fov": 78.0},
	"bunkB_wide": {"eye": Vector3(34.9, 1.65, -0.9), "target": Vector3(37.0, 0.75, -2.8), "fov": 78.0},
	"floor_top": {"eye": Vector3(34.2, 2.75, -0.45), "target": Vector3(32.4, 0.0, -2.7), "fov": 80.0},
	"bed1_read": {"eye": Vector3(31.95, 1.6, -2.95), "target": Vector3(30.42, 1.5, -3.0), "fov": 70.0},
	"bed2_read": {"eye": Vector3(31.55, 1.0, -2.95), "target": Vector3(30.4, 0.7, -3.0), "fov": 70.0},
	"bed4_read": {"eye": Vector3(36.05, 1.6, -2.65), "target": Vector3(37.58, 1.5, -2.7), "fov": 70.0},
	"door_close": {"eye": Vector3(32.35, 1.55, -1.35), "target": Vector3(31.95, 1.12, -0.05), "fov": 70.0},
	"corridor_close": {"eye": Vector3(31.2, 1.55, 1.75), "target": Vector3(31.95, 1.0, 0.0), "fov": 70.0},
}
const PS1_SHOWN_BEFORE := ["CeilingPanel", "VentFrame", "VentSlat0", "VentSlat1", "VentSlat2", "VentSlat3", "VentSlat4", "VentSlat5"]


func _run() -> void:
	if DisplayServer.get_name() == "headless":
		push_error("Capture needs a window.")
		App.quit(1)
		return
	get_window().mode = Window.MODE_WINDOWED
	get_window().content_scale_size = RESOLUTION
	get_window().size = RESOLUTION
	get_viewport().scaling_3d_scale = 1.0
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUTPUT))
	AudioServer.set_bus_mute(0, true)
	var parts := _arg("parts", "r407,crowd,ch1,ward").split(",")
	_camera()
	if "r407" in parts or "ward" in parts:
		var scene := await _load_chapter("res://scenes/main/chapter4.tscn", "Chapter4Director")
		if "r407" in parts:
			await _room(scene)
		if "ward" in parts:
			await _ward_shots(scene)
		scene.queue_free()
		for frame in range(6):
			await get_tree().process_frame
	if "crowd" in parts:
		var scene := await _load_chapter("res://scenes/main/chapter4.tscn", "Chapter4Director")
		await _crowd(scene)
		scene.queue_free()
		for frame in range(6):
			await get_tree().process_frame
	if "ch1" in parts:
		var scene := await _load_chapter("res://scenes/main/chapter1.tscn", "Chapter1Director")
		var fixtures := scene.get_node("Floor4/Room407/Wave9Fixtures") as Node3D
		for look: String in ["before", "after"]:
			fixtures.visible = look == "after"
			await _shoot("%s_ch1_vent_ceiling_torch.jpg" % look, VIEWS.vent_ceiling, true)
			await _shoot("%s_ch1_room_door_torch.jpg" % look, VIEWS.room_door, true)
		scene.queue_free()
		for frame in range(6):
			await get_tree().process_frame
	var file := FileAccess.open(OUTPUT + "../../wave9/survey/capture_r2.txt", FileAccess.WRITE)
	file.store_string("\n".join(log_lines) + "\n")
	file.close()
	print("RESULT: t266 round 2 capture %d images" % count)
	App.quit()


# ------------------------------------------------------------------------------------------------ main's look

## Main's look (before) or round 2's (after), on the same nodes.
func _look_as(anchors: Node3D, room: Node3D, before: bool) -> void:
	for bed in [1, 2, 4]:
		var hinge := anchors.get_node("Slat%d/Hinge" % bed)
		(hinge.get_node("Real") as Node3D).visible = not before
		(hinge.get_node("Board/Mesh") as Node3D).visible = before
		(hinge.get_node("Ink") as Node3D).visible = before
	for node_name: String in PS1_SHOWN_BEFORE:
		(anchors.get_node(node_name) as Node3D).visible = before
	var damage := anchors.get_node("Door/Damage")
	for layer in ["Cracks", "Hole", "Hand"]:
		for child: Node in damage.get_node(layer).get_children():
			(child as Node3D).visible = before != (child.name == &"Real")
	(room.get_node("Wave9Fixtures") as Node3D).visible = not before


## Flip `beds` in order and let them land; before: main's 70 degrees and the bedding where it was.
func _flip(anchors: Node3D, beds: Array, before: bool) -> void:
	for bed: int in beds:
		var slat := anchors.get_node("Slat%d" % bed)
		slat.call("set_flipped", true)
		await get_tree().create_timer(0.65).timeout
		if before:
			(slat.get_node("Hinge") as Node3D).rotation.z = deg_to_rad(-70.0 if bed == 4 else 70.0)
			slat.call("_restore_bedding")


func _unflip(anchors: Node3D) -> void:
	for bed in [1, 2, 4]:
		anchors.get_node("Slat%d" % bed).call("set_flipped", false)
	await get_tree().create_timer(0.6).timeout


## Pose a bed mid-way through its flip at time `t` of its 0.55 s (the panel and each thing as slat_visual.gd plays them).
func _pose_mid(anchors: Node3D, room: Node3D, bed: int, t: float) -> void:
	var slat := anchors.get_node("Slat%d" % bed)
	slat.call("set_flipped", true)
	await get_tree().process_frame
	var turning: Tween = slat.get("_turn")
	if turning != null and turning.is_valid():
		turning.kill()
	slat.call("_restore_bedding")
	var seconds := t * 0.55
	var turn := clampf((seconds - 0.08) / 0.42, 0.0, 1.0)
	turn = (1.0 - cos(PI * turn)) / 2.0
	(slat.get_node("Hinge") as Node3D).rotation.z = deg_to_rad({1: 70.0, 2: 62.0, 4: -70.0}[bed]) * turn
	var inverse := room.global_transform.affine_inverse()
	for thing: Dictionary in slat.get("_things"):
		var node := thing.node as Node3D
		var keys: Array = slat.call("fall_keys", thing.name, inverse * node.global_transform)
		node.global_transform = room.global_transform * (slat.call("pose_at", keys, t) as Transform3D)


# ------------------------------------------------------------------------------------------------ room 407

func _room(scene: Node3D) -> void:
	await _start_407(scene)
	var anchors := scene.get_node("Campus/Anchors/Ch4/Room407") as Node3D
	var room := scene.get_node("Floor4/Room407") as Node3D
	var room_door := scene.get_node("Floor4/Door407/Pivot/RoomDoor") as Node3D
	await get_tree().create_timer(0.8).timeout
	for look: String in ["before", "after"]:
		var before := look == "before"
		_look_as(anchors, room, before)
		await _shoot("%s_407_room_torch.jpg" % look, VIEWS.room_door, true)
		await _shoot("%s_407_bunkA_torch.jpg" % look, R2_VIEWS.bunkA_wide, true)
		for spot in ["fake_ceiling", "fake_vent", "fake_locker"]:
			await _shoot("%s_407_%s_torch.jpg" % [look, spot], VIEWS[spot], true)
		await _flip(anchors, [1, 2, 4], before)
		var suffix := "flipped" if before else "flipped_124"
		await _shoot("%s_407_room_%s_torch.jpg" % [look, suffix], VIEWS.room_door, true)
		await _shoot("%s_407_bunkA_%s_torch.jpg" % [look, suffix], R2_VIEWS.bunkA_wide, true)
		await _shoot("%s_407_bunkB_%s_torch.jpg" % [look, suffix], R2_VIEWS.bunkB_wide, true)
		await _shoot("%s_407_floor_%s_torch.jpg" % [look, suffix], R2_VIEWS.floor_top, true)
		for bed in [1, 2, 4]:
			await _shoot("%s_407_bed%d_read_torch.jpg" % [look, bed], R2_VIEWS["bed%d_read" % bed], true)
		await _shoot("%s_407_bed2_low_torch.jpg" % look, VIEWS.bed2_low, true)
		await _unflip(anchors)
		if not before:
			await _flip(anchors, [2, 1, 4], false)
			await _shoot("after_407_room_flipped_214_torch.jpg", VIEWS.room_door, true)
			await _shoot("after_407_bunkA_flipped_214_torch.jpg", R2_VIEWS.bunkA_wide, true)
			await _shoot("after_407_floor_flipped_214_torch.jpg", R2_VIEWS.floor_top, true)
			await _unflip(anchors)
			for step: float in [0.2, 0.4, 0.65]:
				for bed in [1, 2]:
					await _pose_mid(anchors, room, bed, step)
				await _pose_mid(anchors, room, 4, step)
				await _shoot("after_407_bunkA_fall_%02d_torch.jpg" % int(step * 100.0), R2_VIEWS.bunkA_wide, true)
				await _shoot("after_407_bunkB_fall_%02d_torch.jpg" % int(step * 100.0), R2_VIEWS.bunkB_wide, true)
				await _unflip(anchors)
			# the decoys searched (the hold finished: EventBus.interacted)
			for spot in ["Ceiling", "Vent"]:
				var search := anchors.get_node("Fake%s/Search%s" % [spot, spot])
				search.call("_finish")
			await get_tree().create_timer(0.6).timeout
			await _shoot("after_407_fake_ceiling_searched_torch.jpg", VIEWS.fake_ceiling, true)
			await _shoot("after_407_fake_vent_searched_torch.jpg", VIEWS.fake_vent, true)
			await _shoot("after_407_vent_ceiling_searched_torch.jpg", VIEWS.vent_ceiling, true)
		var proxy := anchors.get_node("Door")
		for level: float in DOOR_LEVELS:
			proxy.call("set_damage_fraction", level)
			if before:
				room_door.visible = true
			await _shoot("%s_407_door_%02d_torch.jpg" % [look, int(level * 100.0)], VIEWS.door_in, true)
			if level >= 0.6:
				await _shoot("%s_407_door_%02d_close_torch.jpg" % [look, int(level * 100.0)], R2_VIEWS.door_close, true)
		# draws from the door with all three lifted and the door at 80 % (card section 5)
		await _flip(anchors, [1, 2, 4], before)
		await _shoot("%s_407_room_flipped_door80_torch.jpg" % look, VIEWS.room_door, true)
		await _unflip(anchors)
		proxy.call("set_damage_fraction", 0.0)
	_look_as(anchors, room, false)


## A fresh room407 stage, its four corpses left to walk to the door; frozen there, then the door from the corridor.
func _crowd(scene: Node3D) -> void:
	var director := scene.get_node("Chapter4Director") as Chapter4Director
	director.run_from(&"room407")
	var proxy := scene.get_node("Campus/Anchors/Ch4/Room407/Door") as Node3D
	var anchors := scene.get_node("Campus/Anchors/Ch4/Room407") as Node3D
	var room := scene.get_node("Floor4/Room407") as Node3D
	var room_door := scene.get_node("Floor4/Door407/Pivot/RoomDoor") as Node3D
	var door_at := proxy.global_position + Vector3(-0.44, 0.0, 0.0)
	var waited := 0.0
	while waited < 30.0:
		await get_tree().create_timer(0.5).timeout
		waited += 0.5
		var near := 0
		for track: Dictionary in director._door_tracks:
			if is_instance_valid(track.zombie) and (track.zombie as Node3D).global_position.distance_to(door_at) < 1.3:
				near += 1
		if near >= 4 or (waited > 20.0 and near >= 2):
			break
	for track: Dictionary in director._door_tracks:
		if is_instance_valid(track.zombie):
			var zombie := track.zombie as Node3D
			zombie.process_mode = Node.PROCESS_MODE_DISABLED
			_note("corpse at %s (%.2f m from the door's middle) after %.1f s" % [zombie.global_position, zombie.global_position.distance_to(door_at), waited])
	director.process_mode = Node.PROCESS_MODE_DISABLED
	var adapter: Node = director._doors.get(&"407")
	if adapter != null:
		adapter.process_mode = Node.PROCESS_MODE_DISABLED
	for look: String in ["before", "after"]:
		_look_as(anchors, room, look == "before")
		for level: float in [0.6, 0.8]:
			proxy.call("set_damage_fraction", level)
			if look == "before":
				room_door.visible = true
			await _shoot("%s_407_door_%02d_corridor_crowd.jpg" % [look, int(level * 100.0)], VIEWS.door_corridor, false)
			await _shoot("%s_407_door_%02d_corridor_close.jpg" % [look, int(level * 100.0)], R2_VIEWS.corridor_close, false)
	_look_as(anchors, room, false)


# ------------------------------------------------------------------------------------------------ ward

func _ward_shots(scene: Node3D) -> void:
	var director := scene.get_node("Chapter4Director") as Chapter4Director
	for kind: StringName in [&"all", &"alone"]:
		if director._hospital != null:
			director._hospital.queue_free()
			director._hospital = null
			await get_tree().process_frame
		GameState.set_flag(&"ch4_ending", String(kind))
		director._ending_kind = kind
		director._show_hospital()
		EventBus.ch4_ending.emit(kind)
		for frame in range(3):
			await get_tree().process_frame
		var ward := director._hospital
		var wake := ward.get_node("Camera_Wake") as Camera3D
		for level: float in [1.0, 1.45]:
			_brightness(level)
			wake.make_current()
			await get_tree().create_timer(0.4).timeout
			await _snap("after_ward_%s_wake_%s.jpg" % [kind, "145" if level > 1.0 else "100"])
		_brightness(1.0)
		camera.environment = (ward.get_node("Environment") as WorldEnvironment).environment
		var corner := {"eye": WARD_CORNER.eye + Vector3(0, WARD_Y, 0), "target": WARD_CORNER.target + Vector3(0, WARD_Y, 0), "fov": WARD_CORNER.fov}
		await _shoot("after_ward_%s_corner.jpg" % kind, corner, false)
		var foot := {"eye": Vector3(-0.82, 1.45, 1.0) + Vector3(0, WARD_Y, 0), "target": Vector3(0.15, 0.68, -0.25) + Vector3(0, WARD_Y, 0), "fov": 70.0}
		await _shoot("after_ward_%s_side.jpg" % kind, foot, false)
		camera.environment = null
