extends TestCase
## T-245 (D-163): what the owner found playing chapter 2 with the body.
## - A mirror shows the phone held by the body (elbow down by the ribs, wrist near straight), not the
##   first-person arm stretched out to the camera; the first-person view keeps its own arm and phone.
## - The rag is the green cloth on the bathroom rack: taken, it is gone from the rack.
## - Viet's shirt and Dat's combination lock are real models, not PS1 blocks.

const CHAPTER := "res://scenes/main/chapter2.tscn"
const VIEW: int = 1 << (PlayerBody.VIEW_LAYER - 1)
const MIRROR: int = 1 << (PlayerBody.MIRROR_LAYER - 1)
## Where a player stands to take the shirt off its shelf (room space): before the locker's open half.
const SHIRT_FROM := Vector3(1.0, 0.02, -1.25)
const RAG_FROM := Vector3(7.5, 0.02, -5.7)
## locker_closed.glb: its door panels, from the locker's middle (metres).
const DOOR_FACE := 0.25

var world: Node3D
var chapter: Node3D
var director: Chapter2Director
var room: Node3D
var player: CharacterBody3D
var body: PlayerBody
## Bones as last drawn (world), by name.
var drawn: Dictionary = {}
const WATCHED: Array[String] = ["LeftUpperArm", "LeftLowerArm", "LeftHand", "MirrorLeftUpperArm",
	"MirrorLeftLowerArm", "MirrorLeftHand", "MirrorLeftIndexDistal", "LeftIndexDistal"]


func before_each() -> void:
	world = Node3D.new()
	tree.root.add_child(world)


func after_each() -> void:
	Input.action_release("interact")
	tree.paused = false
	world.queue_free()
	await wait_frames(2)
	GameState.reset()
	RuleSystem.reset()


func _open_chapter2() -> void:
	AudioServer.set_bus_mute(0, true)
	Chapter1Director.resume_checkpoint = &""
	chapter = (load(CHAPTER) as PackedScene).instantiate() as Node3D
	director = chapter.get_node("Chapter2Director") as Chapter2Director
	director.auto_start = false
	world.add_child(chapter)
	await wait_frames(3)
	room = chapter.get_node("Floor4/Room407") as Node3D
	player = chapter.get_node("Player") as CharacterBody3D
	body = player.get("body") as PlayerBody
	player.set_physics_process(false)
	var skeleton: Skeleton3D = body.skeleton
	skeleton.skeleton_updated.connect(func() -> void:
		for bone: String in WATCHED:
			drawn[bone] = PlayerBody._ortho(skeleton.global_transform * skeleton.get_bone_global_pose(skeleton.find_bone(bone))))


func _settle(frames: int = 40) -> void:
	for frame: int in frames:
		await tree.physics_frame
	await tree.process_frame
	await tree.process_frame


func _angle(a: Vector3, corner: Vector3, b: Vector3) -> float:
	return rad_to_deg((a - corner).angle_to(b - corner))


## The arm a mirror shows: its elbow's angle, the wrist's bend off the forearm, how far the elbow
## hangs under the shoulder (metres).
func _mirror_arm() -> Dictionary:
	var shoulder: Vector3 = (drawn["MirrorLeftUpperArm"] as Transform3D).origin
	var elbow: Vector3 = (drawn["MirrorLeftLowerArm"] as Transform3D).origin
	var hand: Transform3D = drawn["MirrorLeftHand"]
	return {"elbow": _angle(shoulder, elbow, hand.origin),
		"wrist": rad_to_deg((hand.origin - elbow).angle_to(hand.basis.y)),
		"hang": shoulder.y - elbow.y, "hand_under_shoulder": shoulder.y - hand.origin.y}


func test_a_mirror_shows_the_phone_held_by_the_body() -> void:
	await _open_chapter2()
	var skeleton: Skeleton3D = body.skeleton
	var phone := player.get_node("Head/Camera3D/PhoneItem") as Node3D
	player.global_position = room.to_global(Vector3(3.0, 0.02, -3.0))
	(player.get_node("Head") as Node3D).rotation.x = 0.0
	player.set_physics_process(true)
	# Who draws what: the view mesh and the phone before the eyes are the player's camera's alone.
	var camera := player.get_node("Head/Camera3D") as Camera3D
	assert_true(camera.cull_mask & VIEW != 0 and camera.cull_mask & MIRROR == 0, "the player's camera: view layer, no mirror layer")
	for mesh: MeshInstance3D in body.view_meshes:
		assert_eq(mesh.layers, VIEW, "view mesh " + mesh.name)
	for mesh: MeshInstance3D in body.mirror_meshes:
		assert_eq(mesh.layers, MIRROR, "mirror mesh " + mesh.name)
	var others: int = 0
	for other: Camera3D in tree.root.find_children("*", "Camera3D", true, false):
		if other == camera:
			continue
		others += 1
		assert_eq(other.cull_mask & VIEW, 0, "no other camera draws the view layer: " + String(other.get_path()))
	assert_true(others >= 2, "the room's mirrors have cameras (%d others)" % others)
	var late := Camera3D.new()
	world.add_child(late)
	assert_eq(late.cull_mask & VIEW, 0, "nor a camera made later")
	for mesh: MeshInstance3D in phone.get_node("Model").find_children("*", "MeshInstance3D", true, false):
		assert_eq(mesh.layers, VIEW, "the phone before the eyes is the view's")
	var shown := body.get_node_or_null("MirrorPhone") as Node3D
	assert_not_null(shown, "a mirror has its own phone")
	if shown == null:
		return
	# No phone: the mirror's arm is the arm.
	await _settle(10)
	assert_false(shown.visible, "no phone held: none shown")
	assert_true((drawn["MirrorLeftHand"] as Transform3D).origin.distance_to((drawn["LeftHand"] as Transform3D).origin) < 0.001,
			"no phone held: the mirror's arm is the arm itself")
	assert_true((drawn["MirrorLeftIndexDistal"] as Transform3D).origin.distance_to((drawn["LeftIndexDistal"] as Transform3D).origin) < 0.001,
			"fingers too")
	# The torch on, then the phone raised; standing, looking down and up.
	for hold: String in ["torch", "raised"]:
		for pitch: float in [0.0, -35.0, 25.0]:
			phone.call("set_raised", false)
			phone.call("set_flashlight", hold == "torch")
			(player.get_node("Head") as Node3D).rotation.x = deg_to_rad(pitch)
			await _settle(10)
			if hold == "raised":
				phone.call("set_raised", true)
			await _settle(40)
			var label := "%s, pitch %d" % [hold, pitch]
			var arm: Dictionary = _mirror_arm()
			assert_true(arm["elbow"] > 55.0 and arm["elbow"] < 125.0, "%s: the elbow is bent (%.0f deg)" % [label, arm["elbow"]])
			assert_true(arm["wrist"] < 35.0, "%s: the wrist is near straight (%.0f deg)" % [label, arm["wrist"]])
			assert_true(arm["hang"] > 0.08, "%s: the elbow hangs under the shoulder (%.2f m)" % [label, arm["hang"]])
			var goal := body.get("_mirror_goal") as Node3D
			var hand: Transform3D = drawn["MirrorLeftHand"]
			assert_true(hand.origin.distance_to(goal.global_position) < 0.01, label + ": the hand is where it holds the phone")
			# Before the chest, by the body: not out at arm's length.
			var from_player: Vector3 = hand.origin - player.global_position
			assert_true(Vector2(from_player.x, from_player.z).length() < 0.42, "%s: the hand stays by the body (%.2f m out)" % [label, Vector2(from_player.x, from_player.z).length()])
			assert_true(shown.visible, label + ": the mirror shows the phone")
			var held: Transform3D = body._held_world(hand, HandShapes.PHONE_IN_HAND)
			assert_true(shown.global_position.distance_to(held.origin) < 0.01, label + ": in that hand")
			for mesh: MeshInstance3D in shown.find_children("*", "MeshInstance3D", true, false):
				assert_eq(mesh.layers, MIRROR, label + ": on the mirror layer")
			# The first-person arm is its own: out before the camera, where the eyes see the phone.
			var view_hand: Vector3 = (drawn["LeftHand"] as Transform3D).origin
			assert_true(view_hand.distance_to(hand.origin) > 0.05, label + ": the view keeps its own arm")
			var in_view: Vector3 = camera.global_transform.affine_inverse() * (phone.get_node("Model") as Node3D).global_position
			assert_true(in_view.z < -0.2 and absf(in_view.x) < 0.3 and absf(in_view.y) < 0.3, label + ": the phone is before the eyes as before")
	phone.call("set_raised", false)
	phone.call("set_flashlight", false)
	await _settle(30)
	assert_false(shown.visible, "put away: none shown")
	assert_true((drawn["MirrorLeftHand"] as Transform3D).origin.distance_to((drawn["LeftHand"] as Transform3D).origin) < 0.001,
			"put away: one arm again")
	player.set_physics_process(false)


## Stand on `spot` (room space) looking at the thing's hand target, press E, let the hand finish.
func _take(thing: Interactable, spot: Vector3) -> Dictionary:
	var look: Vector3 = thing.hand_target().global_position
	player.set_physics_process(false)
	if body.acting:
		body._finish()
	player.global_position = room.to_global(spot)
	player.velocity = Vector3.ZERO
	player.global_rotation.y = PlayerBody._yaw_to(player.global_position, look)
	var to: Vector3 = look - (player.global_position + Vector3.UP * 1.6)
	(player.get_node("Head") as Node3D).rotation.x = atan2(to.y, Vector2(to.x, to.z).length())
	body._face_view()
	player.set_physics_process(true)
	for frame: int in 6:
		await tree.physics_frame
	var seen: Dictionary = {"focus": player.get("_target") == thing, "acted": false}
	if not seen["focus"]:
		player.set_physics_process(false)
		return seen
	await tree.process_frame
	Input.action_press("interact")
	player._physics_process(1.0 / 60.0)
	Input.action_release("interact")
	var frames: int = 0
	while frames < 300:
		await tree.physics_frame
		frames += 1
		seen["acted"] = seen["acted"] or body.acting
		if not body.acting and frames > 3:
			break
	player.set_physics_process(false)
	return seen


func _r3() -> void:
	GameState.segment = &"r3"
	for bed: int in [1, 2, 4]:
		director._gagged[bed] = false
		director._corpse_state(bed, &"talk")
	director._bathroom_door(true)
	for frame: int in 20:
		await tree.process_frame


func _shown(node: Node) -> Array[MeshInstance3D]:
	var meshes: Array[MeshInstance3D] = []
	for mesh: MeshInstance3D in node.find_children("*", "MeshInstance3D", true, false):
		if mesh.is_visible_in_tree() and mesh.mesh != null:
			meshes.append(mesh)
	return meshes


func _room_box(node: Node3D) -> AABB:
	var box := AABB()
	var first := true
	var meshes: Array[Node] = node.find_children("*", "MeshInstance3D", true, false)
	if node is MeshInstance3D:
		meshes.append(node)
	for mesh: MeshInstance3D in meshes:
		var bounds: AABB = (room.global_transform.affine_inverse() * mesh.global_transform) * mesh.get_aabb()
		box = bounds if first else box.merge(bounds)
		first = false
	return box


## The owner took the rag and "it was still there": the green cloth on the rack is the rag.
func test_the_rag_is_the_racks_cloth_and_is_gone_once_taken() -> void:
	await _open_chapter2()
	await _r3()
	var anchor := room.get_node("Anchors/RagSpot") as Node3D
	var rag := anchor.get_node("Carry_rag") as CarryItem
	var cloth := anchor.get_node_or_null("Model/RackRag") as Node3D
	assert_not_null(cloth, "the rack's cloth is the rag's model")
	if cloth == null:
		return
	assert_eq(_shown(anchor.get_node("Model")).size(), _shown(cloth).size(), "nothing else is drawn as the rag")
	assert_true(_shown(cloth).size() > 0, "the cloth hangs on the rack")
	# The rack itself has no cloth of its own left on it (only the shorts on their hook).
	var rack := room.get_node("Furnished/TripoProps/TowelRack") as Node3D
	assert_not_null(rack.find_child("Shorts", true, false), "the shorts stay on the rack")
	var cloth_box := _room_box(cloth)
	var rack_box := _room_box(rack.find_child("TowelRack", true, false) as Node3D)
	assert_true(cloth_box.end.y <= rack_box.end.y + 0.005 and cloth_box.end.y > rack_box.end.y - 0.09, "over the bar")
	assert_true(cloth_box.grow(0.03).has_point(anchor.position), "it is taken by the cloth itself")
	assert_true(cloth_box.grow(0.03).has_point(room.to_local(rag.hand_target().global_position)), "the hand goes to the cloth")
	var seen: Dictionary = await _take(rag, RAG_FROM)
	assert_true(seen["focus"], "the prompt shows on the cloth")
	assert_true(seen["acted"] and body.holds(rag), "taken by hand")
	assert_eq(_shown(anchor.get_node("Model")).size(), 0, "taken: the cloth is gone from the rack")
	assert_false((rag.get_node("Placeholder") as Node3D).visible, "no placeholder box either")
	var visual := body.get("_held_visual") as Node3D
	assert_true(visual != null and visual.get_child_count() > 0, "the hand carries it")
	if visual != null and visual.get_child_count() > 0:
		assert_eq((visual.get_child(0) as MeshInstance3D).mesh, (_all(cloth)[0] as MeshInstance3D).mesh, "the same cloth")
	rag.drop()
	assert_true(_shown(cloth).size() > 0, "put back: on the rack again")
	# Pressed into a mouth, it never comes back.
	await _take(rag, RAG_FROM)
	rag.consume()
	await wait_frames(2)
	assert_eq(_shown(anchor.get_node("Model")).size(), 0, "used: gone for good")


func _all(node: Node) -> Array[Node]:
	return node.find_children("*", "MeshInstance3D", true, false)


func test_viets_shirt_and_dats_lock_are_real_things() -> void:
	await _open_chapter2()
	await _r3()
	var anchors := room.get_node("Anchors") as Node3D
	# The shirt: a folded shirt on the locker's own shelf.
	var spot := anchors.get_node("ShirtSpot") as Node3D
	var shirt := spot.get_node_or_null("Model/ShirtViet") as Node3D
	assert_not_null(shirt, "Viet's shirt is a model")
	if shirt == null:
		return
	assert_eq(_shown(spot.get_node("Model")).size(), _shown(shirt).size(), "the PS1 shirt is not drawn")
	var triangles: int = 0
	for mesh: MeshInstance3D in _shown(shirt):
		triangles += mesh.mesh.get_faces().size() / 3
	assert_true(triangles > 1000 and triangles <= 5000, "a real model within the small prop budget (%d triangles)" % triangles)
	var box := _room_box(shirt)
	assert_true(absf(box.position.y - room.VIET_SHIRT_SHELF) < 0.01, "it lies on the shelf (%.3f)" % box.position.y)
	var locker := _room_box(room.get_node("Furnished/TripoProps/LockerViet").find_child("LockerBody", true, false) as Node3D)
	assert_true(locker.encloses(box), "inside the locker")
	assert_true(box.grow(0.03).has_point(spot.position), "it is taken where it lies")
	var item := spot.get_node("Carry_shirt") as CarryItem
	# A fair patch of floor before the open locker reaches it.
	var patch: int = 0
	for x: float in [0.85, 0.95, 1.05, 1.15]:
		for z: float in [-1.25, -1.15, -1.05, -0.95, -0.85, -0.75]:
			var at: Vector3 = room.to_global(Vector3(x, 0.02, z))
			if not body._fits(at):
				continue
			body._stand_at(at, PlayerBody._yaw_to(at, item.hand_target().global_position))
			if body.can_reach(item):
				patch += 1
	assert_true(patch >= 6, "reached from %d of 24 spots before the locker" % patch)
	var seen: Dictionary = await _take(item, SHIRT_FROM)
	assert_true(seen["focus"], "the prompt shows on the shirt")
	assert_true(seen["acted"] and body.holds(item), "taken by hand")
	assert_eq(_shown(spot.get_node("Model")).size(), 0, "taken: gone from the shelf")
	item.drop()
	# The lock: a combination padlock through a hasp on the doors.
	var dat := anchors.get_node("DatLocker") as Node3D
	for path: String in ["CombinationLock", "Wheel0", "Wheel1", "Wheel2", "Shackle/Top", "Shackle/Leg-0.04", "Shackle/Leg0.04"]:
		assert_eq(_shown(dat.get_node(path)).size(), 0, "the PS1 lock is not drawn: " + path)
	var lock := room.get_node_or_null("Furnished/TripoProps/LockDat") as Node3D
	assert_not_null(lock, "Dat's lock is a model")
	var swing := dat.get_node_or_null("Shackle/Swing") as Node3D
	assert_not_null(swing, "its shackle swings on the locker's own node")
	if lock == null or swing == null:
		return
	var lock_box := _room_box(lock)
	assert_true(lock_box.grow(0.02).has_point(dat.position), "where the old lock was")
	# The east lockers face west, their doors DOOR_FACE before the middle (the handles stand
	# further out): the hasp lies on the door, not in the air before it.
	var face: float = (room.get_node("Furnished/TripoProps/LockerDat") as Node3D).position.x - DOOR_FACE
	assert_true(absf(lock_box.end.x - face) < 0.015, "on the door (%.3f off)" % absf(lock_box.end.x - face))
	var shut: Vector3 = _room_box(swing).get_center()
	dat.call("set_unlocked", true)
	var open: Vector3 = _room_box(swing).get_center()
	assert_true(open.y > shut.y + 0.005 and open.distance_to(shut) > 0.012, "unlocked: the shackle lifts and swings aside")
	dat.call("set_unlocked", false)
	assert_true(_room_box(swing).get_center().distance_to(shut) < 0.0005, "locked: home again")
