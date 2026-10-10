extends TestCase
## T-207 G0: the visual-to-logic bindings that docs/design/graphics/ASSET_BINDINGS.md
## records, checked on the real chapter scenes. A realistic model that renames a
## node, drops a marker or loops the fire bell stream must fail here before it
## reaches a playtest. Numbers are the ones measured on origin/main (D-078).

const CHAPTERS := {1: "res://scenes/main/chapter1.tscn", 2: "res://scenes/main/chapter2.tscn",
	3: "res://scenes/main/chapter3.tscn", 4: "res://scenes/main/chapter4.tscn"}
const CORPSE_STATES: Array[StringName] = [&"sit_play", &"talk", &"gagged", &"mumble", &"fall", &"revive", &"lunge", &"slump"]
const CORPSE_POSES: Array[StringName] = [&"dead_a", &"dead_b", &"head_turn", &"eyes_open", &"sit_up"]
const CORPSE_PATHS: Array[String] = ["Rig/Hips/Chest/Head", "Rig/Hips/Chest/Head/Mouth", "Rig/Hips/Chest/Head/Eyes",
	"Rig/Hips/Chest/Blood", "Rig/Hips/Chest/LeftArm", "Rig/Hips/Chest/RightArm", "Rig/Hips/LeftLeg/Knee",
	"Rig/Hips/RightLeg/Knee", "AnimationPlayer"]
## Bed number -> [bunk marker, bed height].
const BUNKS := {1: Vector3(30.65, 1.20, -3.00), 2: Vector3(30.65, 0.43, -3.00), 3: Vector3(37.35, 0.43, -2.70),
	4: Vector3(37.35, 1.20, -2.70)}

var scene: Node


func _open(chapter: int) -> Node:
	scene = load(CHAPTERS[chapter]).instantiate()
	scene.get_node("Chapter%dDirector" % chapter).set("auto_start", false)
	Chapter1Director.resume_checkpoint = &""
	tree.root.add_child(scene)
	scene.get_node("FloorSpeaker").voice_directory = ""
	await wait_frames(4)
	return scene


func _close() -> void:
	if scene != null:
		scene.queue_free()
		scene = null
	await wait_frames(3)


func _box(node: Node) -> Vector3:
	var shape := (node as CollisionShape3D).shape as BoxShape3D
	return shape.size if shape != null else Vector3.ZERO


func _near(actual: Vector3, expected: Vector3, tolerance: float = 0.011) -> bool:
	return actual.distance_to(expected) <= tolerance


func after_each() -> void:
	await _close()


## Door 407, the bunks and the three corpses are shared by all four chapters.
func test_room_407_bindings_hold_in_every_chapter() -> void:
	for chapter: int in CHAPTERS:
		var root := await _open(chapter)
		var label := "chapter %d: " % chapter
		var floor4 := root.get_node("Floor4")
		assert_true(_near(floor4.get_node("Room407").global_position, Vector3(30, 0, 0)), label + "Room407 at (30, 0, 0);")
		var door := floor4.get_node_or_null("Door407")
		assert_not_null(door, label + "Door407;")
		if door != null:
			assert_true(_near(door.get_node("Pivot").global_position, Vector3(32.44, 0.01, 0.0)), label + "hinge at (32.44, 0.01, 0);")
			for path in ["Pivot/Leaf", "Pivot/Leaf/WorldCollision/Bounds", "Pivot/DoorLatch407", "Pivot/RulesPaper",
					"Pivot/HandlePivot", "InteractShape"]:
				assert_not_null(door.get_node_or_null(path), label + "door node " + path)
			assert_true(_near(_box(door.get_node("Pivot/Leaf/WorldCollision/Bounds")), Vector3(0.88, 2.08, 0.10)), label + "leaf collider 0.88 x 2.08;")
			assert_true(_near(_box(door.get_node("InteractShape")), Vector3(1.10, 2.20, 0.25)), label + "interact shape;")
			assert_eq(int(door.get("collision_layer")), 4, label + "door is on the interactable layer;")
			var accepts_seconds := false
			for method: Dictionary in door.get_method_list():
				if method.name == "set_open":
					accepts_seconds = method.args.size() >= 2
			assert_true(accepts_seconds, label + "set_open(open, seconds);")
			for method_name in ["rattle", "stop_rattle"]:
				assert_true(door.has_method(method_name), label + method_name)
		for bed: int in BUNKS:
			var bunk := floor4.get_node_or_null("Room407/Anchors/Bunks/Bunk%d" % bed) as Node3D
			assert_not_null(bunk, label + "Bunk%d" % bed)
			if bunk != null:
				assert_true(_near(bunk.global_position, BUNKS[bed]), label + "Bunk%d at %s;" % [bed, BUNKS[bed]])
				assert_not_null(bunk.get_node_or_null("View"), label + "Bunk%d View" % bed)
			var anchor := floor4.get_node_or_null("Anchors/" + ["", "Bed_Phuc", "Bed_Viet", "Bed_Trung", "Bed_Dat"][bed]) as Node3D
			assert_true(anchor != null and _near(anchor.global_position, BUNKS[bed]), label + "bed anchor %d;" % bed)
		await _close()


func test_the_three_corpses_keep_their_api_and_node_paths() -> void:
	var root := await _open(2)
	var floor4 := root.get_node("Floor4")
	for bed in [1, 2, 4]:
		var marker := floor4.get_node_or_null("Room407/Anchors/Corpse%d" % bed) as Node3D
		assert_true(marker != null and _near(marker.global_position, BUNKS[bed]), "Corpse%d marker on its bunk;" % bed)
		var body := marker.get_node_or_null("Body") as Node3D if marker != null else null
		assert_not_null(body, "Corpse%d/Body;" % bed)
		if body == null:
			continue
		for path in CORPSE_PATHS:
			assert_not_null(body.get_node_or_null(path), "corpse %d node %s" % [bed, path])
		for method_name in ["set_pose", "set_state", "set_gagged", "set_blood_visible", "look_at_point"]:
			assert_true(body.has_method(method_name), "corpse %d %s" % [bed, method_name])
		for state in CORPSE_STATES:
			assert_true(body.call("set_state", state), "corpse %d accepts state %s" % [bed, state])
		for pose in CORPSE_POSES:
			assert_true(body.call("set_pose", pose), "corpse %d accepts pose %s" % [bed, pose])
		assert_false(body.call("set_state", &"not_a_state"), "unknown states are refused;")
		assert_true(body.is_in_group(&"ch2_corpse"), "corpse %d is in ch2_corpse" % bed)
		assert_not_null(body.get_node_or_null("UnseenPoser"), "corpse %d UnseenPoser (lane A)" % bed)


## The gag mount rides on the animated head: a model without
## Rig/Hips/Chest/Head would leave GagSpot hanging in mid air.
func test_gag_anchors_follow_the_corpse_head() -> void:
	var root := await _open(2)
	var room := root.get_node("Floor4/Room407")
	for bed in [1, 2, 4]:
		var body := room.get_node("Anchors/Corpse%d/Body" % bed)
		var gag := room.get_node_or_null("Anchors/Gag%d" % bed) as Node3D
		assert_not_null(gag, "Gag%d anchor;" % bed)
		if gag == null:
			continue
		var before := gag.global_position
		body.call("set_state", &"sit_play")
		await wait_frames(3)
		var head := body.get_node("Rig/Hips/Chest/Head") as Node3D
		var mouth := head.global_transform.translated_local(Vector3(0, 0.005, -0.14)).origin
		assert_true(gag.global_position.distance_to(mouth) < 0.02, "Gag%d sits on the mouth;" % bed)
		assert_true(gag.global_position.distance_to(before) > 0.2, "Gag%d moved with the sitting corpse;" % bed)


func test_manager_body_has_the_markers_and_clips_the_manager_looks_up() -> void:
	var manager := (load("res://scenes/entity/manager.tscn") as PackedScene).instantiate() as Node3D
	manager.set("body_scene", load("res://scenes/levels/ch1_models/manager_body.tscn"))
	tree.root.add_child(manager)
	await wait_frames(3)
	var blade := manager.get("_blade_tip") as Node3D
	assert_not_null(blade, "BladeTip found in the model;")
	var arm := manager.get("_reach_arm") as Node3D
	assert_true(arm != null and arm.name == &"LeftArm", "LeftArm found in the model;")
	var animation := manager.get("_model_animation") as AnimationPlayer
	assert_not_null(animation, "the model's AnimationPlayer;")
	if animation != null:
		for clip in ["stand", "walk", "slash", "lunge", "ask", "kill"]:
			assert_true(animation.has_animation(clip), "clip " + clip)
		assert_true(animation.get_animation("stand").loop_mode != Animation.LOOP_NONE, "stand loops;")
		assert_true(animation.get_animation("walk").loop_mode != Animation.LOOP_NONE, "walk loops;")
		assert_true(absf(animation.get_animation("slash").length - 1.2) < 0.01, "slash clip is 1.2 s;")
	if blade != null:
		assert_true(blade.name == &"BladeTip" and manager.is_ancestor_of(blade), "BladeTip lives under the manager;")
	manager.queue_free()
	await wait_frames(2)


## set_body twice must leave one model, the fallback hidden, and Head where the
## model's head is (A's head_position() is what the guards and bars aim at).
func test_actor_body_swap_leaves_one_model() -> void:
	var companion := (load("res://scenes/entity/companion.tscn") as PackedScene).instantiate() as Node3D
	tree.root.add_child(companion)
	await wait_frames(2)
	for model in ["nhat", "ngu", "nhat"]:
		companion.call("set_body", load("res://assets/models/campus/%s.tscn" % model))
		await wait_frames(2)
	var visual := companion.get_node("Visual")
	var models := 0
	for child in visual.get_children():
		if child.name != &"Fallback":
			models += 1
	assert_eq(models, 1, "one model under Visual;")
	assert_false((visual.get_node("Fallback") as Node3D).visible, "fallback hidden;")
	var head: Vector3 = companion.call("head_position")
	assert_true(absf(head.y - (companion.global_position.y + 1.48)) < 0.03, "head at the model's head (%.2f);" % head.y)
	companion.queue_free()
	await wait_frames(2)


func test_chapter_3_fire_pieces_stay_where_the_ledger_says() -> void:
	var root := await _open(3)
	var anchors := root.get_node("Campus/Anchors")
	var extinguisher := anchors.get_node("Extinguisher2F") as Node3D
	assert_true(_near(extinguisher.global_position, Vector3(48.83, -5.50, 2.40)), "extinguisher anchor;")
	var uses: Dictionary = root.get_node("Chapter3Director").get("_uses")
	var expected := {"Extinguisher2F": Vector3(0.5, 0.8, 0.5), "FireAlarm1F": Vector3(0.5, 0.6, 0.5),
		"FireDoor": Vector3(1.4, 2.2, 1.4), "FireKey": Vector3(0.4, 0.3, 0.4)}
	for key: String in expected:
		var use := uses.get(key) as Ch3Use
		assert_not_null(use, "use " + key)
		if use != null:
			assert_true(_near(use.size, expected[key], 0.001), "%s zone %s;" % [key, use.size])
			assert_eq(use.collision_layer, 4, key + " is interactable;")
	var alarm := anchors.get_node_or_null("FireAlarm1F") as Node3D
	assert_not_null(alarm, "FireAlarm1F marker;")
	if alarm != null:
		assert_true(_near(alarm.global_position, Vector3(0.9, -8.5, 0.12), 0.001), "alarm on the wall by the stairs;")
		assert_true(alarm.get_child_count() >= 2, "alarm has its visual and its use zone;")
		assert_eq(alarm.get_children().filter(func(n: Node) -> bool: return n is MeshInstance3D).size(), 1, "one greybox visual (core's own);")
	assert_true(_near(Chapter3Director.FIRE_BELL_AT, Vector3(42.0, -9.9, 2.0), 0.001), "bell position;")
	assert_eq(Chapter3Director.FIRE_BELL_SECONDS, 20.0, "20 s;")
	var stream := load(Chapter3Director.FIRE_BELL_STREAM) as AudioStreamOggVorbis
	assert_not_null(stream, "bell stream loads;")
	# _ring_bell replays the stream until 20 s are up by awaiting `finished`; a
	# looping stream never finishes, so the bell would not stop (W2 in the contract).
	assert_true(stream != null and not stream.loop, "the bell stream does not loop;")
	var extinguisher_visual := root.get_node_or_null("Campus/BuildingB/FireExtinguisher") as Node3D
	assert_true(extinguisher_visual != null and _near(extinguisher_visual.global_position, Vector3(48.86, -5.80, 2.40)), "extinguisher body (lane B);")


## D-075: the bell and the alarm button are chapter 3 only, though chapter 4
## inherits the director.
func test_chapter_4_has_no_fire_alarm_button() -> void:
	var root := await _open(4)
	assert_true(root.get_node("Campus/Anchors").get_node_or_null("FireAlarm1F") == null, "no FireAlarm1F anchor;")
	var uses: Dictionary = root.get_node("Chapter4Director").get("_uses")
	assert_false(uses.has("FireAlarm1F"), "no alarm use zone;")


## Chapters 3 and 4: the 407 door leaf's own colliders are switched off and lane
## B's proxy blocks the doorway instead. A new leaf must keep both ends.
func test_door_proxy_takes_over_the_leaf_collision_in_chapters_3_and_4() -> void:
	for chapter in [3, 4]:
		var root := await _open(chapter)
		var label := "chapter %d: " % chapter
		var proxy := root.get_node_or_null("Campus/Anchors/Ch4/Room407/Door") as Node3D
		assert_not_null(proxy, label + "door proxy;")
		var leaf_body := root.get_node("Floor4/Door407/Pivot/Leaf/WorldCollision") as CollisionObject3D
		assert_eq(leaf_body.collision_layer, 0, label + "leaf collider off;")
		if proxy != null:
			var blocker := proxy.get_node("Blocker") as CollisionObject3D
			assert_eq(blocker.collision_layer, 1, label + "proxy blocks the closed door;")
			assert_true(proxy.get("is_open") == root.get_node("Floor4/Door407").get("is_open"), label + "proxy mirrors the door;")
		await _close()
