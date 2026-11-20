extends "res://_probe_tmp/capture_wave9.gd"
## T-266 round 1 stills, pilot part (card section 2, step 2 and the options of step 3). Nothing in the game's scenes is changed:
## this script puts the wave-9 glbs into chapter 4's real scene at run time (director.run_from(&"room407"), the door's crowd
## freed, player and HUD hidden, sound muted, the torch the camera's own as in capture_wave9.gd) and hides the PS1 pieces they
## stand for (visible = false; nodes, colliders, markers stay):
##   bed 2: Slat2/Hinge/Board and Ink hidden, slat_v1|v2_bed2.glb under Slat2/Hinge; flipped by set_flipped(true), then the hinge
##     set to 62 degrees (bed 2's clearance under the upper bunk; round 2 puts it in slat_visual.gd). N1: Viet's mattress,
##     blanket and pillow carried by the hinge; N2: laid on the floor beside the bed. W9SlatUnder's texture swapped per hand.
##   vent / hatch: VentFrame, VentSlat0..5 or CeilingPanel hidden, vent[_open].glb or hatch_h1[_open]|h2.glb under Room407.
##   door: Damage's PS1 children hidden; door_cracks.glb under Damage/Cracks, door_broken.glb under Damage/Hole, zombie_hand.glb
##     under Damage/Hand, each at the room door leaf's (Door407/Pivot/RoomDoor) transform; from 60 % the leaf and CracksInner hide.
##   ward: every PS1 mesh of HospitalRoom hidden (the lane-D cards under the Card markers stay), ward_shell + footwall[_door],
##     ward_bed under each Bed_*, iv under each IV_*, patient_t1|t2 under Bed_Trung/Patient, patient_side under the other two
##     Patients (set_companions_visible still toggles them), bed_empty|bed_rolled for the lonely ending, curtain_y1 for Y1.
## Copy this file and capture_wave9.gd to game/_probe_tmp/ with a scene whose root has this one, then (Lượt Godot):
##   godot --path game res://_probe_tmp/capture_wave9_pilot.tscn -- [--parts=p407,pward]
## Writes previews/wave9/pilot_*.jpg and options_*.jpg sources (1600 x 900), CAPTURE lines to wave9/survey/capture_pilot.txt.
const W9 := "res://assets/models/graphics_pilot/realistic_map/wave9/"
const T9 := "res://assets/textures/graphics_pilot/realistic_map/wave9/"
const PILOT_VIEWS := {
	"bed2_read": {"eye": Vector3(31.55, 1.0, -2.95), "target": Vector3(30.4, 0.7, -3.0), "fov": 70.0},
	"bed2_side": {"eye": Vector3(31.9, 1.0, -1.65), "target": Vector3(30.55, 0.6, -3.1), "fov": 70.0},
	"door_close": {"eye": Vector3(32.35, 1.55, -1.35), "target": Vector3(31.95, 1.12, -0.05), "fov": 70.0},
}
const HAND_STYLES := ["loang", "bi", "khac", "phieu"]

var pilot_log: PackedStringArray = []


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
	var parts := _arg("parts", "p407,pward").split(",")
	_camera()
	var scene := await _load_chapter("res://scenes/main/chapter4.tscn", "Chapter4Director")
	if "p407" in parts:
		await _pilot_407(scene)
	if "pward" in parts:
		await _pilot_ward(scene)
	var file := FileAccess.open(OUTPUT + "../../wave9/survey/capture_pilot.txt", FileAccess.WRITE)
	file.store_string("\n".join(log_lines) + "\n")
	file.close()
	print("RESULT: t266 pilot capture %d images" % count)
	App.quit()


func _glb(name: String, parent: Node, xform: Transform3D = Transform3D.IDENTITY) -> Node3D:
	var node := (load(W9 + name) as PackedScene).instantiate() as Node3D
	node.name = "Pilot_" + name.get_basename()
	parent.add_child(node)
	node.transform = xform
	return node


func _hide_meshes(root: Node) -> void:
	for mesh: Node in root.find_children("*", "MeshInstance3D", true, false):
		(mesh as Node3D).visible = false
	if root is MeshInstance3D:
		(root as Node3D).visible = false


func _snap_wait(file: String) -> void:
	await get_tree().create_timer(0.45).timeout
	await _snap(file)


# ------------------------------------------------------------------------------------------------ room 407

func _pilot_407(scene: Node3D) -> void:
	await _start_407(scene)
	var anchors := scene.get_node("Campus/Anchors/Ch4/Room407") as Node3D
	var room := scene.get_node("Floor4/Room407") as Node3D
	var pivot := scene.get_node("Floor4/Door407/Pivot") as Node3D
	var leaf := pivot.get_node("RoomDoor") as Node3D
	_note("RoomDoor in Pivot space: %s (aabb %s)" % [leaf.transform, (leaf as MeshInstance3D).get_aabb()])
	var rules := pivot.get_node_or_null("RulesPaper") as Node3D
	if rules != null:
		_note("RulesPaper at %s" % rules.transform.origin)
	var sections := _arg("sections", "bed,spots,door")
	# Overview before (PS1 as main), let the room's light settle first.
	await get_tree().create_timer(0.8).timeout
	if "bed" in sections:
		await _shoot("pilot_407_room_before_torch.jpg", VIEWS.room_door, true)
	# --- bed 2
	var slat := anchors.get_node("Slat2") as Node3D
	var hinge := slat.get_node("Hinge") as Node3D
	_hide_meshes(hinge.get_node("Board"))
	(hinge.get_node("Ink") as Node3D).visible = false
	var under: StandardMaterial3D = load(W9 + "materials/W9SlatUnder.tres")
	var props := room.call("furnished_prop", "MattressViet").get_parent() as Node3D
	var bedding := {}
	for prop_name in ["MattressViet", "BlanketViet", "PillowViet"]:
		var prop := props.get_node(prop_name) as Node3D
		bedding[prop_name] = {"node": prop, "parent": prop.get_parent(), "xform": prop.global_transform}
	for kind: String in _arg("slats", "v1,v2").split(","):
		if not "bed" in sections:
			_glb("slat_v2_bed2.glb", hinge)
			break
		var piece := _glb("slat_%s_bed2.glb" % kind, hinge)
		slat.call("set_flipped", false)
		await get_tree().create_timer(0.6).timeout
		hinge.rotation.z = 0.0
		await _shoot("pilot_bed2_%s_before_torch.jpg" % kind, VIEWS.bed2_low, true)
		await _shoot("pilot_bed2_%s_before_stand_torch.jpg" % kind, VIEWS.bed2, true)
		for n_option in ["n0", "n1", "n2"]:
			_bedding(bedding, n_option, hinge)
			slat.call("set_flipped", true)
			await get_tree().create_timer(0.6).timeout
			hinge.rotation.z = deg_to_rad(62.0)
			await _shoot("pilot_bed2_%s_%s_after_torch.jpg" % [kind, n_option], VIEWS.bed2_low, true)
			if n_option != "n0":
				await _shoot("pilot_bed2_%s_%s_side_torch.jpg" % [kind, n_option], PILOT_VIEWS.bed2_side, true)
			if kind != "v1" and n_option == "n1":
				for style: String in HAND_STYLES:
					under.albedo_texture = load(T9 + "slat_2_%s.png" % style)
					await _shoot("pilot_bed2_%sread_%s_torch.jpg" % ["" if kind == "v2" else kind + "_", style], PILOT_VIEWS.bed2_read, true)
				under.albedo_texture = load(T9 + "slat_2_loang.png")
			_bedding(bedding, "back", hinge)
			slat.call("set_flipped", false)
			await get_tree().create_timer(0.6).timeout
		if kind == "v1":
			piece.queue_free()
	# --- vent, hatch
	for node_name in ["VentFrame", "VentSlat0", "VentSlat1", "VentSlat2", "VentSlat3", "VentSlat4", "VentSlat5", "CeilingPanel"]:
		_hide_meshes(anchors.get_node(node_name))
	for kind in (["vent", "vent_open"] if "spots" in sections else []):
		var vent := _glb(kind + ".glb", anchors)
		await _shoot("pilot_%s_torch.jpg" % kind, VIEWS.fake_vent, true)
		vent.queue_free()
	for kind in (["hatch_h1", "hatch_h2", "hatch_h1_open"] if "spots" in sections else []):
		var hatch := _glb(kind + ".glb", anchors)
		await _shoot("pilot_%s_torch.jpg" % kind, VIEWS.fake_ceiling, true)
		hatch.queue_free()
	var vent_keep := _glb("vent.glb", anchors)
	var hatch_keep := _glb("hatch_h1.glb", anchors)
	if "spots" in sections:
		await _shoot("pilot_vent_ceiling_torch.jpg", VIEWS.vent_ceiling, true)
	# --- door
	var proxy := anchors.get_node("Door") as Node3D
	var damage := proxy.get_node("Damage") as Node3D
	for child in ["Cracks", "Hole", "Hand"]:
		for item: Node in damage.get_node(child).get_children():
			_hide_meshes(item)
	var cracks := _glb("door_cracks.glb", damage.get_node("Cracks"), leaf.transform)
	_glb("door_broken.glb", damage.get_node("Hole"), leaf.transform)
	_glb("zombie_hand.glb", damage.get_node("Hand"), leaf.transform)
	var inner := cracks.find_child("CracksInner", true, false) as Node3D
	for level: float in DOOR_LEVELS:
		proxy.call("set_damage_fraction", level)
		leaf.visible = level < 0.6
		if inner != null:
			inner.visible = level < 0.6
		await _shoot("pilot_door_%02d_torch.jpg" % int(level * 100.0), VIEWS.door_in, true)
		if level > 0.0:
			await _shoot("pilot_door_%02d_close_torch.jpg" % int(level * 100.0), PILOT_VIEWS.door_close, true)
	await _shoot("pilot_door_80_corridor.jpg", VIEWS.door_corridor, false)
	# overview with bed 2 lifted (V2, N1), the vent, H1 and the door at 80 % (draws for the card's section 5)
	_bedding(bedding, "n1", hinge)
	slat.call("set_flipped", true)
	await get_tree().create_timer(0.6).timeout
	hinge.rotation.z = deg_to_rad(62.0)
	await _shoot("pilot_407_room_after_torch.jpg", VIEWS.room_door, true)
	_bedding(bedding, "back", hinge)
	proxy.call("set_damage_fraction", 0.0)
	leaf.visible = true
	vent_keep.queue_free()
	hatch_keep.queue_free()


## N0: the bedding stays (the board turns through it, as main). N1: carried by the hinge, so it leans with the panel against the
## wall. N2: thrown down on the floor beside the bed (no collider: walked through).
func _bedding(bedding: Dictionary, option: String, hinge: Node3D) -> void:
	for prop_name: String in bedding:
		var entry: Dictionary = bedding[prop_name]
		var prop := entry.node as Node3D
		if option == "n1":
			prop.reparent(hinge, true)
		else:
			if prop.get_parent() != entry.parent:
				prop.reparent(entry.parent as Node, false)
			prop.global_transform = entry.xform
		if option == "n2":
			var floor_at := {"MattressViet": Transform3D(Basis.from_euler(Vector3(0.0, deg_to_rad(9.0), deg_to_rad(4.0))), Vector3(31.55, 0.02, -3.05)),
				"BlanketViet": Transform3D(Basis.from_euler(Vector3(0.0, deg_to_rad(-25.0), 0.0)), Vector3(31.75, 0.04, -2.75)),
				"PillowViet": Transform3D(Basis.from_euler(Vector3(deg_to_rad(12.0), deg_to_rad(40.0), 0.0)), Vector3(31.35, 0.07, -2.2))}
			prop.global_transform = floor_at[prop_name]


# ------------------------------------------------------------------------------------------------ ward

func _pilot_ward(scene: Node3D) -> void:
	var director := scene.get_node("Chapter4Director") as Chapter4Director
	var configs := [
		{"tag": "y1", "curtain": true, "door": false, "t": "t1"},
		{"tag": "y2", "curtain": false, "door": true, "t": "t1"},
		{"tag": "y3", "curtain": false, "door": false, "t": "t1"},
		{"tag": "t2", "curtain": true, "door": false, "t": "t2"},
	]
	for config: Dictionary in configs:
		for kind: StringName in [&"all", &"alone"]:
			if config.tag in ["y3", "t2"] and kind == &"alone":
				continue
			var ward := await _ward(director, kind)
			_dress_ward(ward, config, kind, "empty")
			await get_tree().process_frame
			var wake := ward.get_node("Camera_Wake") as Camera3D
			for pitch: float in [24.0, 11.0]:
				wake.rotation_degrees.x = pitch
				for level: float in [1.0, 1.45]:
					if config.tag in ["y3", "t2"] and level > 1.0:
						continue
					if config.tag == "t2" and pitch > 20.0:
						continue
					_brightness(level)
					wake.make_current()
					await _snap_wait("pilot_ward_%s_%s_k%d_%s.jpg" % [config.tag, kind, 1 if pitch > 20.0 else 2, "145" if level > 1.0 else "100"])
			wake.rotation_degrees.x = 24.0
			_brightness(1.0)
			if config.tag in ["y1", "y2"]:
				camera.environment = (ward.get_node("Environment") as WorldEnvironment).environment
				var corner := {"eye": WARD_CORNER.eye + Vector3(0, WARD_Y, 0), "target": WARD_CORNER.target + Vector3(0, WARD_Y, 0), "fov": WARD_CORNER.fov}
				await _shoot("pilot_ward_%s_%s_corner.jpg" % [config.tag, kind], corner, false)
				var foot := {"eye": Vector3(-0.82, 1.45, 1.0) + Vector3(0, WARD_Y, 0), "target": Vector3(0.15, 0.68, -0.25) + Vector3(0, WARD_Y, 0), "fov": 70.0}
				if kind == &"all":
					await _shoot("pilot_ward_%s_side.jpg" % config.tag, foot, false)
				camera.environment = null
	# the lonely ending's other look: the mattresses rolled at the head
	var ward := await _ward(director, &"alone")
	_dress_ward(ward, configs[0], &"alone", "rolled")
	var wake := ward.get_node("Camera_Wake") as Camera3D
	wake.rotation_degrees.x = 11.0
	wake.make_current()
	await _snap_wait("pilot_ward_rolled_alone_k2_100.jpg")
	camera.environment = (ward.get_node("Environment") as WorldEnvironment).environment
	var corner := {"eye": WARD_CORNER.eye + Vector3(0, WARD_Y, 0), "target": WARD_CORNER.target + Vector3(0, WARD_Y, 0), "fov": WARD_CORNER.fov}
	await _shoot("pilot_ward_rolled_alone_corner.jpg", corner, false)
	camera.environment = null


func _ward(director: Chapter4Director, kind: StringName) -> Node3D:
	if director._hospital != null:
		director._hospital.queue_free()
		director._hospital = null
		await get_tree().process_frame
	GameState.set_flag(&"ch4_ending", String(kind))
	director._ending_kind = kind
	director._show_hospital()
	EventBus.ch4_ending.emit(kind)
	for frame in range(2):
		await get_tree().process_frame
	return director._hospital


func _dress_ward(ward: Node3D, config: Dictionary, kind: StringName, empty: String) -> void:
	for item: Node in ward.find_children("*", "MeshInstance3D", true, false):
		var path := String(ward.get_path_to(item))
		if "/Card/" in path:
			continue
		(item as Node3D).visible = false
	_glb("ward_shell.glb", ward)
	_glb("footwall_door.glb" if config.door else "footwall.glb", ward)
	if config.curtain:
		_glb("curtain_y1.glb", ward)
	for bed in ["Bed_Trung", "Bed_Nhat", "Bed_Ngu"]:
		var node := ward.get_node(bed) as Node3D
		var frame := _glb("ward_bed.glb", node)
		var patient := node.get_node("Patient") as Node3D
		if bed == "Bed_Trung":
			_glb("patient_%s.glb" % config.t, patient)
		else:
			_glb("patient_side.glb", patient)
			if kind == &"alone":
				if empty == "rolled":
					for part_name in ["Mattress", "Sheet", "Pillow"]:
						var found := frame.find_child(part_name, true, false) as Node3D
						if found != null:
							found.visible = false
					_glb("bed_rolled.glb", node)
				else:
					_glb("bed_empty.glb", node)
	for iv in ["IV_Trung", "IV_Nhat", "IV_Ngu"]:
		_glb("iv.glb", ward.get_node(iv))
