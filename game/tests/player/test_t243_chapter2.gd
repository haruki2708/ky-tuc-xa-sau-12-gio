extends TestCase
## T-243 (D-161, D-162): Tran Trung's body in chapter 2, measured in chapter 2 as it plays.
## - The player has the body; the balcony door is used by hand as in chapter 1 (T-242).
## - The bathroom door stays round 4's swollen door: no hand swings it, three shoulder shoves open it.
## - The rag, towel and shirt are carried in the right fist; pressed into a sitting corpse's mouth.
## - The shower button is pressed by hand in time; the screen is wiped by a palm rubbing round.

const CHAPTER := "res://scenes/main/chapter2.tscn"

var world: Node3D
var chapter: Node3D
var director: Chapter2Director
var room: Node3D
var player: CharacterBody3D
var body: PlayerBody
## The right hand as last drawn (world).
var drawn_hand: Transform3D = Transform3D.IDENTITY


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
	if body != null:
		var skeleton: Skeleton3D = body.skeleton
		skeleton.skeleton_updated.connect(func() -> void:
			drawn_hand = PlayerBody._ortho(skeleton.global_transform * skeleton.get_bone_global_pose(skeleton.find_bone("RightHand"))))


func test_chapter_2_has_the_body() -> void:
	await _open_chapter2()
	assert_not_null(body, "chapter 2's player has the body")
	assert_true(body != null and body.get_parent() == player, "the body rides the player")
	assert_not_null(HingedDoor.of(room.get_node("Extension/BalconyDoor")), "the balcony door is used by hand")


## D-162: round 4's swollen bathroom door is never opened by hand; three shoves open it, as before.
func test_the_bathroom_door_stays_the_stuck_one() -> void:
	await _open_chapter2()
	var door := room.get_node("Extension/BathroomDoor") as Node3D
	assert_true(HingedDoor.of(door) == null, "no HingedDoor on the bathroom door")
	var stuck := door.get_node_or_null("StuckDoor") as StuckDoor
	assert_not_null(stuck, "round 4's stuck door is there")
	if stuck == null:
		return
	director._bathroom_door(false)
	assert_false(door.get("is_open"), "round 4: shut")
	assert_true(stuck.enabled, "and stuck")
	var opened := [false]
	stuck.opened.connect(func() -> void: opened[0] = true)
	for shove: int in 3:
		assert_false(opened[0], "not open before shove %d" % (shove + 1))
		stuck.interact(player)
		await tree.physics_frame
	assert_true(opened[0] and door.get("is_open"), "the third shove opens it")
	assert_eq(stuck.bash_count, 3, "three shoves")



## Stand on `spot` (room space) looking at `look` (world), press E, let the game run until the hand
## is done. `hold`: seconds E stays down. What happened.
func _use(thing: Interactable, spot: Vector3, look: Vector3, hold: float = 0.0) -> Dictionary:
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
	var seen: Dictionary = {"focus": player.get("_target") == thing, "acted": false, "frames": 0, "moved": 0.0, "into_door": INF}
	if not seen["focus"]:
		player.set_physics_process(false)
		return seen
	var from: Vector3 = player.global_position
	await tree.process_frame
	Input.action_press("interact")
	player._physics_process(1.0 / 60.0)
	if hold <= 0.0:
		Input.action_release("interact")
	var frames: int = 0
	while frames < 300:
		await tree.physics_frame
		frames += 1
		if hold > 0.0 and frames >= int(hold * 60.0):
			Input.action_release("interact")
		seen["acted"] = seen["acted"] or body.acting
		seen["moved"] = maxf(seen["moved"], player.global_position.distance_to(from))
		if not body.acting and frames > 3 and (hold <= 0.0 or frames >= int(hold * 60.0)):
			break
	Input.action_release("interact")
	seen["frames"] = frames
	seen["back"] = player.global_position.distance_to(from)
	player.set_physics_process(false)
	return seen


## How far what the hand carries is from the palm's middle (the nearest of its world box), metres.
func _off_hand(visual: Node3D) -> float:
	if visual == null:
		return INF
	# As drawn (after IK): the skeleton's modified pose is only there as it updates.
	var hand: Transform3D = drawn_hand
	var palm: Vector3 = hand.origin + hand.basis.y.normalized() * PlayerBody.PALM * body._scale()
	var nearest: float = INF
	for mesh: MeshInstance3D in visual.find_children("*", "MeshInstance3D", true, false):
		var box: AABB = mesh.get_aabb()
		var local: Vector3 = mesh.global_transform.affine_inverse() * palm
		var on_box: Vector3 = mesh.global_transform * local.clamp(box.position, box.end)
		nearest = minf(nearest, on_box.distance_to(palm))
	return nearest


func _r3() -> void:
	GameState.segment = &"r3"
	for bed: int in [1, 2, 4]:
		director._gagged[bed] = false
		director._corpse_state(bed, &"talk")
	director._bathroom_door(true)
	for frame: int in 20:
		await tree.process_frame


## D-162: the rag, the towel (by its hanging part, D-162) and Viet's shirt (his locker stands open)
## are taken by hand and carried in the right fist, not in front of the camera; walking keeps them
## there; a second one swaps for the first.
func test_the_rag_towel_and_shirt_are_carried_in_the_right_hand() -> void:
	await _open_chapter2()
	await _r3()
	var anchors := room.get_node("Anchors")
	assert_true(bool(anchors.get_node("VietLocker").get("is_open")), "Viet's locker stands open in chapter 2")
	var rag := anchors.get_node("RagSpot/Carry_rag") as CarryItem
	var towel := anchors.get_node("TowelSpot/Carry_towel") as CarryItem
	var shirt := anchors.get_node("ShirtSpot/Carry_shirt") as CarryItem
	for entry: Array in [[rag, Vector3(7.5, 0.02, -5.7)], [towel, Vector3(2.8, 0.02, -7.45)], [shirt, Vector3(0.91, 0.02, -0.9)]]:
		var item: CarryItem = entry[0]
		var seen: Dictionary = await _use(item, entry[1], item.hand_target().global_position)
		var name: String = String(item.item_id)
		assert_true(seen["focus"], name + ": the prompt shows")
		assert_true(seen["acted"], name + ": taken by hand")
		assert_true(item.holder == player, name + ": held")
		assert_true(body.holds(item), name + ": in the right hand")
		var placeholder := item.get_node("Placeholder") as Node3D
		assert_false(placeholder.visible, name + ": its placeholder box is not shown")
		var visual := body.get("_held_visual") as Node3D
		assert_true(visual != null and visual.get_child_count() > 0, name + ": its own model is in the fist")
		var off: float = _off_hand(visual)
		assert_true(off < 0.06, "%s: hanging from the fist (%.3f m off)" % [name, off])
		var camera := player.get_node("Head/Camera3D") as Camera3D
		var in_view: Vector3 = camera.global_transform.affine_inverse() * item.global_position
		assert_false(in_view.distance_to(Vector3(0.24, -0.22, -0.55)) < 0.05, name + ": not hung before the camera")
	assert_false(rag.holder == player or towel.holder == player, "taking another swaps: one at a time")
	# Walking with it: the fist keeps it.
	player.set_physics_process(true)
	Input.action_press("move_forward")
	for frame: int in 30:
		await tree.physics_frame
	Input.action_release("move_forward")
	var visual := body.get("_held_visual") as Node3D
	assert_true(body.holds(shirt) and _off_hand(visual) < 0.06, "walking, it stays in the fist (%.3f m off)" % _off_hand(visual))
	assert_true(float(body.get("_carry_weight")) > 0.99, "the carrying pose is held")
	shirt.drop()
	assert_false(body.holds(shirt), "dropped: the hand lets go")


## D-162: pressed into a sitting corpse's mouth by the hand that carries it, by the mouth's height
## (an upper bunk on the toes, the lower one standing); a lying corpse's mouth is out of reach.
func test_a_gag_is_pressed_into_a_sitting_corpse_by_hand() -> void:
	await _open_chapter2()
	await _r3()
	var anchors := room.get_node("Anchors")
	var rag := anchors.get_node("RagSpot/Carry_rag") as CarryItem
	var towel := anchors.get_node("TowelSpot/Carry_towel") as CarryItem
	await _use(rag, Vector3(7.5, 0.02, -5.7), rag.hand_target().global_position)
	assert_true(body.holds(rag), "the rag is in the hand")
	var viet := anchors.get_node("Gag2/GagSpot") as GagSpot
	assert_eq(viet.hand_target().grip, HandTarget.Grip.PINCH, "the fingertips press it in")
	var seen: Dictionary = await _use(viet, Vector3(1.44, 0.02, -2.31), viet.hand_target().global_position)
	assert_true(seen["focus"] and seen["acted"], "Viet (lower bunk): pressed in by hand")
	assert_true(bool(director._gagged[2]) and rag.consumed, "Viet is gagged, the rag is gone")
	assert_false(body.holds(rag), "the hand is empty")
	assert_eq(body.get("_reach"), &"near", "a lower bunk: standing")
	await _use(towel, Vector3(2.8, 0.02, -7.45), towel.hand_target().global_position)
	var phuc := anchors.get_node("Gag1/GagSpot") as GagSpot
	seen = await _use(phuc, Vector3(1.44, 0.02, -3.25), phuc.hand_target().global_position)
	assert_true(seen["focus"] and seen["acted"], "Phuc (upper bunk): pressed in by hand")
	assert_true(bool(director._gagged[1]) and towel.consumed, "Phuc is gagged")
	# Lying down, the mouths are out of reach: no prompt.
	var shirt := anchors.get_node("ShirtSpot/Carry_shirt") as CarryItem
	await _use(shirt, Vector3(0.91, 0.02, -0.9), shirt.hand_target().global_position)
	director._corpse_state(4, &"slump")
	for frame: int in 60:
		await tree.process_frame
	var dat := anchors.get_node("Gag4/GagSpot") as GagSpot
	var reached: int = 0
	var z: float = -0.8
	while z <= 0.81:
		var x: float = -0.8
		while x <= 0.81:
			var at: Vector3 = dat.hand_target().global_position + Vector3(x, 0.0, z)
			at.y = 0.02
			x += 0.1
			if not body._fits(at):
				continue
			body._stand_at(at, PlayerBody._yaw_to(at, dat.hand_target().global_position))
			if body.can_reach(dat):
				reached += 1
		z += 0.1
	assert_eq(reached, 0, "Dat lying down: his mouth is out of reach from everywhere")
	assert_false(bool(director._gagged[4]), "not gagged")


## D-162: round 4's swollen door takes a shoulder: each press is one shove, counted at the hit;
## the third opens it; the body lunges in and comes back, never into the leaf.
func test_the_stuck_door_takes_three_shoulder_shoves() -> void:
	await _open_chapter2()
	director._bathroom_door(false)
	var stuck := room.get_node("Extension/BathroomDoor/StuckDoor") as StuckDoor
	var look: Vector3 = (stuck.get_node("CollisionShape3D") as Node3D).global_position
	var plane_z: float = (room.get_node("Extension/BathroomDoor") as Node3D).global_position.z
	for shove: int in 3:
		var counted: Array[int] = []
		var on_bash := func(count: int) -> void: counted.append(count)
		stuck.bashed.connect(on_bash)
		player.set_physics_process(false)
		player.global_position = room.to_global(Vector3(5.75, 0.02, -3.45))
		player.global_rotation.y = PlayerBody._yaw_to(player.global_position, look)
		var to: Vector3 = look - (player.global_position + Vector3.UP * 1.6)
		(player.get_node("Head") as Node3D).rotation.x = atan2(to.y, Vector2(to.x, to.z).length())
		body._face_view()
		player.set_physics_process(true)
		for frame: int in 6:
			await tree.physics_frame
		assert_true(player.get("_target") == stuck, "shove %d: the prompt shows" % (shove + 1))
		var from: Vector3 = player.global_position
		await tree.process_frame
		Input.action_press("interact")
		player._physics_process(1.0 / 60.0)
		Input.action_release("interact")
		assert_true(body.acting and body.get("_shove"), "a shove, not a reach for the handle")
		var nearest: float = INF
		var lunge: float = 0.0
		var frames: int = 0
		var pressed_again: bool = false
		while body.acting and frames < 120:
			await tree.physics_frame
			frames += 1
			if frames == 5 and not pressed_again:
				# Pressing again mid-shove counts nothing.
				pressed_again = true
				await tree.process_frame
				Input.action_press("interact")
				player._physics_process(1.0 / 60.0)
				Input.action_release("interact")
			lunge = maxf(lunge, player.global_position.distance_to(from))
			nearest = minf(nearest, absf(player.global_position.z - plane_z))
		stuck.bashed.disconnect(on_bash)
		assert_eq(counted, [shove + 1], "shove %d counted once, at the hit" % (shove + 1))
		assert_true(lunge > 0.1, "the body lunges in (%.2f m)" % lunge)
		assert_true(nearest >= PlayerBody.SHOVE_CLEAR - 0.01, "never into the leaf (%.2f m off its plane)" % nearest)
		assert_true(player.global_position.distance_to(from) < 0.01, "and comes back")
		assert_true(frames * 1.0 / 60.0 <= PlayerBody.SHOVE_SECONDS + 0.1, "a shove takes %.2f s" % (frames / 60.0))
	assert_eq(stuck.bash_count, 3, "three shoves")
	assert_true(bool(room.get_node("Extension/BathroomDoor").get("is_open")), "the third opens it")


## The shower's Có button is pressed by hand; there is still time to step into the stall before the
## water decides (SHOWER_GRACE_SECONDS after the choice).
func test_the_shower_button_is_pressed_by_hand_in_time() -> void:
	await _open_chapter2()
	director._bathroom_door(true)
	director._set_shower_buttons(true)
	var yes := room.get_node("Anchors/ShowerYes/Choice") as Interactable
	var chosen: Array = []
	var at_ms: Array = []
	var listener := func(run: bool) -> void:
		chosen.append(run)
		at_ms.append(Time.get_ticks_msec())
	EventBus.shower_choice_made.connect(listener)
	var started: int = Time.get_ticks_msec()
	var seen: Dictionary = await _use(yes, Vector3(5.85, 0.02, -5.3), yes.hand_target().global_position)
	EventBus.shower_choice_made.disconnect(listener)
	assert_true(seen["acted"], "pressed by hand")
	assert_eq(chosen, [true], "the choice is made")
	# From the touch to the end of the hand's second, then a walk into the stall at walking speed.
	var stall := room.get_node("Anchors/ShowerStall") as Node3D
	var walk: float = Vector2(stall.global_position.x - player.global_position.x, stall.global_position.z - player.global_position.z).length() - 0.4
	var spare: float = Chapter2Director.SHOWER_GRACE_SECONDS - (PlayerBody.HAND_SECONDS - PlayerBody.CONTACT) - maxf(walk, 0.0) / 2.2
	assert_true(spare > 0.3, "time left to step into the stall: %.2f s" % spare)


## The steamed screen is wiped with the palm rubbing round while E is held: the screen counts it
## and the hand stays on it until wiped; let go early, the hand goes back and nothing is wiped.
func test_the_screen_is_wiped_by_a_rubbing_palm_while_e_is_held() -> void:
	await _open_chapter2()
	director._bathroom_door(true)
	var wipe := room.get_node("Anchors/ShowerScreen/Wipe") as ShowerScreen
	var wiped: Array = []
	wipe.wiped.connect(func() -> void: wiped.append(true))
	var seen: Dictionary = await _use(wipe, Vector3(5.85, 0.02, -5.45), wipe.hand_target().global_position, 0.6)
	assert_true(seen["acted"], "the hand goes to the screen")
	assert_true(wiped.is_empty(), "let go early: not wiped")
	seen = await _use(wipe, Vector3(5.85, 0.02, -5.45), wipe.hand_target().global_position, 1.8)
	assert_eq(wiped.size(), 1, "held long enough: wiped once")
	assert_false(body.acting, "then the hand goes back")
