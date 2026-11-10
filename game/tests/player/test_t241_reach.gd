extends TestCase
## T-241 (D-156, the owner's playtest of 10/11): how the body goes with the hand, measured on the
## drawn skeleton (after every modifier) in chapter 1 as it plays.
## - What stands at desk height or higher is taken standing still: no crouch, heels down, feet
##   where they stood, the trunk leaning at most 45 degrees.
## - What is low (the floor, the bin, a socket by the skirting) is bent down to, the knees giving a
##   little: no crouch either.
## - The action reaches the way the prompt judged, from every standing spot.
## - The camera is never behind the body's own head; the free hand is not raised to the chest.

const CHAPTER := "res://scenes/main/chapter1.tscn"
const WALKER := preload("res://tests/player/body_walker.gd")
## Standing spots tried around a thing, the furthest first (where the prompt first shows as the
## player walks up: the deepest reach the rule allows).
const RINGS: Array[float] = [1.0, 0.9, 0.8, 0.75, 0.7, 0.65, 0.6, 0.55, 0.5, 0.45, 0.4, 0.35, 0.3, 0.25]
const RING_STEPS := 48
const BONES: Array[String] = ["Hips", "UpperChest", "Head", "RightUpperArm", "RightHand", "LeftHand",
	"LeftUpperLeg", "LeftLowerLeg", "LeftFoot", "LeftToes", "RightUpperLeg", "RightLowerLeg", "RightFoot", "RightToes"]
## The trunk (the line from the hips to the chest) off the vertical, standing reaches (card: 45).
const TRUNK_MAX: float = 45.0
## A planted foot: its ankle rises and its ankle and toes wander at most this far (metres).
const HEEL_MAX: float = 0.015
const SLIDE_MAX: float = 0.02
## Bending down, the knee's angle (thigh to shin, 36 degrees as his idle starts, 125 crouched) at
## the deepest: 15 to 45 degrees more than standing, "the knees give a little".
const KNEE_FROM: float = 50.0
const KNEE_TO: float = 80.0
## The camera stays at least this far in front of the head bone, along the face (standing: 0.06 to
## 0.10 m as the idle sways; before T-241 a lean left it 0.2 to 0.35 m behind).
const CAMERA_AHEAD: float = 0.03
## The free hand's wrist rises at most this far over where it hung (the reach clip took it 0.43 m
## up, a fist at the chest); up on the toes the whole body rises 8 cm more.
const LEFT_RISE: float = 0.1
## At the touch the hand is this close to where it takes the thing (metres): the point it holds on a
## switch or a handle, the wrist of the pinch on a sheet.
const HAND_OFF: float = 0.05

var world: Node3D
var chapter: Node3D
var director: Chapter1Director
var player: CharacterBody3D
var body: PlayerBody
## Bone name -> world transform as last drawn.
var drawn: Dictionary = {}
var head_forward: Vector3 = Vector3.BACK


func before_each() -> void:
	world = Node3D.new()
	tree.root.add_child(world)
	drawn.clear()


func after_each() -> void:
	PlayerBody.stoop_seconds = PlayerBody.STOOP_SECONDS
	tree.paused = false
	world.queue_free()
	await wait_frames(2)
	GameState.reset()
	RuleSystem.reset()


func _open_chapter1() -> void:
	AudioServer.set_bus_mute(0, true)
	Chapter1Director.resume_checkpoint = &""
	chapter = (load(CHAPTER) as PackedScene).instantiate() as Node3D
	director = chapter.get_node("Chapter1Director") as Chapter1Director
	director.auto_start = false
	world.add_child(chapter)
	await wait_frames(3)
	player = chapter.get_node("Player") as CharacterBody3D
	body = player.get("body") as PlayerBody
	director._place_khoa_note(chapter.get_node("Floor4/Room407/Anchors/WallKnock406"))
	await wait_frames(2)
	player.set_physics_process(false)
	player.set_process_input(false)
	player.set_process_unhandled_input(false)
	_watch(body)


func _watch(watched: PlayerBody) -> void:
	var skeleton: Skeleton3D = watched.skeleton
	skeleton.skeleton_updated.connect(func() -> void:
		for bone: String in BONES:
			drawn[bone] = skeleton.global_transform * skeleton.get_bone_global_pose(skeleton.find_bone(bone)))
	# Which way the face looks, in the head bone's own axes (the model faces +Z).
	var to_model: Transform3D = watched.model.global_transform.affine_inverse() * skeleton.global_transform
	var rest: Transform3D = to_model * skeleton.get_bone_global_rest(skeleton.find_bone("Head"))
	head_forward = (rest.basis.orthonormalized().inverse() * Vector3(0, 0, 1)).normalized()


func _at(bone: String) -> Vector3:
	return (drawn[bone] as Transform3D).origin


## Every thing chapter 1 uses by hand (as test_protagonist_chapter1), by how high its grip is:
## "low" (bent down to), "standing", "high" (reached up for).
func _things() -> Dictionary:
	var groups: Dictionary = {"low": [], "standing": [], "high": []}
	for node: Node in chapter.find_children("*", "", true, false):
		var thing := node as Interactable
		if thing == null or not thing.is_visible_in_tree() or thing is HideSpot or thing.hand_target() == null:
			continue
		var height: float = thing.hand_target().global_position.y - player.global_position.y
		if height < PlayerBody.STOOP_BELOW:
			groups["low"].append(thing)
		elif body._overhead(thing.hand_target().global_position):
			groups["high"].append(thing)
		else:
			groups["standing"].append(thing)
	return groups


func _fits(spot: Vector3) -> bool:
	var shape := player.get("body_shape") as CollisionShape3D
	var query := PhysicsShapeQueryParameters3D.new()
	query.shape = shape.shape
	query.transform = Transform3D(Basis.IDENTITY, spot + shape.position + Vector3.UP * 0.04)
	query.collision_mask = player.collision_mask
	query.exclude = [player.get_rid()]
	return player.get_world_3d().direct_space_state.intersect_shape(query, 1).is_empty()


## No wall between the eyes of a player on `spot` and `goal` (what the thing lies on does not count).
func _sees(spot: Vector3, goal: Vector3) -> bool:
	var query := PhysicsRayQueryParameters3D.create(Vector3(spot.x, 1.6, spot.z), goal, 1)
	query.exclude = [player.get_rid()]
	var hit: Dictionary = player.get_world_3d().direct_space_state.intersect_ray(query)
	return hit.is_empty() or (hit["position"] as Vector3).distance_to(goal) < 0.16


func _stand(spot: Vector3, goal: Vector3) -> void:
	player.global_position = spot
	var toward := goal - spot
	player.global_rotation = Vector3(0.0, atan2(-toward.x, -toward.z), 0.0)
	body._face_view()


## Puts the player on the furthest spot round `thing` from which the prompt shows (and holds as
## his idle sways: a step in from the very edge). False if there is none.
func _stand_far(thing: Interactable) -> bool:
	var goal: Vector3 = thing.hand_target().global_position
	for radius: float in RINGS:
		for step: int in RING_STEPS:
			var heading: float = TAU * step / RING_STEPS
			var spot := Vector3(goal.x + radius * sin(heading), 0.02, goal.z + radius * cos(heading))
			if not _fits(spot) or not _sees(spot, goal):
				continue
			_stand(spot, goal)
			if not body.can_reach(thing):
				continue
			var closer: Vector3 = spot + Vector3(goal.x - spot.x, 0.0, goal.z - spot.z).normalized() * 0.04
			if _fits(closer):
				_stand(closer, goal)
			await tree.physics_frame
			await tree.physics_frame
			if body.can_reach(thing):
				return true
	return false


## The whole hand action on `thing` from where the player stands, measured each frame. The thing
## itself is not used (no game logic runs; a paper goes up and straight back down).
func _act(thing: Interactable) -> Dictionary:
	var camera := player.get_node("Head/Camera3D") as Camera3D
	await tree.physics_frame
	var start: Dictionary = drawn.duplicate()
	var was_enabled: bool = thing.enabled
	thing.enabled = true
	body.perform(thing)
	thing.enabled = false
	var result: Dictionary = {"kind": body._reach, "lean": body._bend_degrees, "crouched": false, "heel": 0.0, "slide": 0.0, "trunk": 0.0,
			"knee": 0.0, "ahead": INF, "left": -INF, "hand": INF, "eye_low": INF, "acting": body.acting}
	var frames: int = 0
	while body.acting and frames < 400:
		await tree.physics_frame
		frames += 1
		result["crouched"] = result["crouched"] or bool(player.get("crouched"))
		var head: Transform3D = drawn["Head"]
		var face: Vector3 = (head.basis.orthonormalized() * head_forward).normalized()
		result["ahead"] = minf(result["ahead"], (camera.global_position - head.origin).dot(face))
		result["eye_low"] = minf(result["eye_low"], camera.global_position.y)
		result["trunk"] = maxf(result["trunk"], rad_to_deg((_at("UpperChest") - _at("Hips")).angle_to(Vector3.UP)))
		result["left"] = maxf(result["left"], _at("LeftHand").y - (start["LeftHand"] as Transform3D).origin.y)
		if is_instance_valid(body._marker) and body._marker.pick_up:
			# A sheet: at the pinch the wrist is where the pinch was planned (the sheet itself may have
			# been drawn in a little by the fingertips first, T-239).
			if absf(body._time - PlayerBody.PAPER_PINCH) <= 0.03:
				result["hand"] = minf(result["hand"], body._wrist_off_goal)
			result["pull"] = maxf(float(result.get("pull", 0.0)), body._pull.length())
		elif is_instance_valid(body._marker) and body._phase == PlayerBody.Phase.HOLD and body._time <= PlayerBody.CONTACT + 0.1:
			result["hand"] = minf(result["hand"], body._contact_point().distance_to(body._marker.global_position))
		for side: String in ["Left", "Right"]:
			var thigh: Vector3 = _at(side + "LowerLeg") - _at(side + "UpperLeg")
			var shin: Vector3 = _at(side + "Foot") - _at(side + "LowerLeg")
			result["knee"] = maxf(result["knee"], rad_to_deg(thigh.angle_to(shin)))
			var ankle: Vector3 = _at(side + "Foot") - (start[side + "Foot"] as Transform3D).origin
			var toes: Vector3 = _at(side + "Toes") - (start[side + "Toes"] as Transform3D).origin
			result["heel"] = maxf(result["heel"], ankle.y)
			result["slide"] = maxf(result["slide"], maxf(Vector2(ankle.x, ankle.z).length(), Vector2(toes.x, toes.z).length()))
	result["done"] = not body.acting
	thing.enabled = was_enabled
	return result


func test_what_stands_at_desk_height_or_higher_is_taken_standing_still() -> void:
	await _open_chapter1()
	var things: Array = _things()["standing"]
	assert_true(things.size() >= 10, "chapter 1 has its desk and standing things (%d)" % things.size())
	var lines: PackedStringArray = []
	for thing: Interactable in things:
		var name: String = thing.name
		if not await _stand_far(thing):
			assert_true(false, name + ": out of reach from every standing spot")
			continue
		var seen: Dictionary = await _act(thing)
		lines.append("%s lean %.0f trunk %.0f heel %.3f slide %.3f ahead %.3f left %.3f" % [name, seen["lean"], seen["trunk"],
			seen["heel"], seen["slide"], seen["ahead"], seen["left"]])
		assert_true(seen["done"], name + ": the action ends")
		assert_eq(seen["kind"], &"near", name + ": taken standing")
		assert_false(seen["crouched"], name + ": the body does not crouch")
		assert_true(seen["lean"] <= PlayerBody.MAX_BEND + 0.01, "%s: planned lean %.0f" % [name, seen["lean"]])
		assert_true(seen["trunk"] <= TRUNK_MAX, "%s: the trunk leans %.0f degrees" % [name, seen["trunk"]])
		assert_true(seen["heel"] <= HEEL_MAX, "%s: a heel rises %.3f m" % [name, seen["heel"]])
		assert_true(seen["slide"] <= SLIDE_MAX, "%s: a foot slides %.3f m" % [name, seen["slide"]])
		assert_true(seen["ahead"] >= CAMERA_AHEAD, "%s: the camera %.3f m in front of the head" % [name, seen["ahead"]])
		assert_true(seen["left"] <= LEFT_RISE, "%s: the free hand rises %.3f m" % [name, seen["left"]])
		assert_true(seen["hand"] <= HAND_OFF, "%s: the hand gets to it (%.3f m off)" % [name, seen["hand"]])
		assert_true(float(seen.get("pull", 0.0)) <= PlayerBody.PULL_LIMIT + 0.001, "%s: the sheet is drawn in %.3f m" % [name, float(seen.get("pull", 0.0))])
	print("T241_STANDING %d things at the furthest spot: %s" % [things.size(), " | ".join(lines)])


func test_what_is_low_is_bent_down_to_without_a_crouch() -> void:
	await _open_chapter1()
	var things: Array = _things()["low"]
	assert_true(things.size() >= 6, "chapter 1 has its low things (%d)" % things.size())
	var names: PackedStringArray = []
	var lines: PackedStringArray = []
	for thing: Interactable in things:
		var name: String = thing.name
		names.append(name)
		if not await _stand_far(thing):
			assert_true(false, name + ": out of reach from every standing spot")
			continue
		var seen: Dictionary = await _act(thing)
		lines.append("%s lean %.0f knee %.0f heel %.3f slide %.3f ahead %.3f eyes %.2f" % [name, seen["lean"], seen["knee"],
			seen["heel"], seen["slide"], seen["ahead"], seen["eye_low"]])
		assert_true(seen["done"], name + ": the action ends")
		assert_eq(seen["kind"], &"stoop", name + ": bent down to")
		assert_false(seen["crouched"], name + ": the body does not crouch")
		assert_true(seen["knee"] >= KNEE_FROM and seen["knee"] <= KNEE_TO, "%s: the knees give a little (%.0f degrees)" % [name, seen["knee"]])
		assert_true(seen["heel"] <= HEEL_MAX, "%s: a heel rises %.3f m" % [name, seen["heel"]])
		assert_true(seen["slide"] <= SLIDE_MAX, "%s: a foot slides %.3f m" % [name, seen["slide"]])
		assert_true(seen["ahead"] >= CAMERA_AHEAD, "%s: the camera %.3f m in front of the head" % [name, seen["ahead"]])
		assert_true(seen["left"] <= LEFT_RISE, "%s: the free hand rises %.3f m" % [name, seen["left"]])
		assert_true(seen["hand"] <= HAND_OFF, "%s: the hand gets to it (%.3f m off)" % [name, seen["hand"]])
		assert_true(float(seen.get("pull", 0.0)) <= PlayerBody.PULL_LIMIT + 0.001, "%s: the sheet is drawn in %.3f m" % [name, float(seen.get("pull", 0.0))])
	assert_true(names.has("Ch1KhoaNote") and names.has("SearchTrashBin"), "Khoa's note and the bin are among them: %s" % [names])
	print("T241_LOW %d things at the furthest spot: %s" % [things.size(), " | ".join(lines)])


## What is reached up for (the toes, D-152's lean on the toes) is as it was; the camera is not
## behind the head there either.
func test_reaching_up_keeps_the_camera_in_front_of_the_head() -> void:
	await _open_chapter1()
	var things: Array = _things()["high"]
	assert_true(things.size() >= 3, "chapter 1 has its high things (%d)" % things.size())
	for thing: Interactable in things:
		var name: String = thing.name
		if not await _stand_far(thing):
			assert_true(false, name + ": out of reach from every standing spot")
			continue
		var seen: Dictionary = await _act(thing)
		assert_true(seen["kind"] == &"up" or seen["kind"] == &"near", "%s: reached up (%s)" % [name, seen["kind"]])
		assert_false(seen["crouched"], name + ": no crouch")
		assert_true(seen["ahead"] >= CAMERA_AHEAD, "%s: the camera %.3f m in front of the head" % [name, seen["ahead"]])
		assert_true(seen["left"] <= LEFT_RISE + PlayerBody.TIPTOE + 0.03, "%s: the free hand rises %.3f m" % [name, seen["left"]])


## The prompt and the action are one rule: wherever the prompt shows, the action reaches the way
## the prompt judged, that way is the one for the thing's height, and the lean stays in its limit.
func test_the_action_reaches_the_way_the_prompt_judged_from_every_spot() -> void:
	await _open_chapter1()
	var groups: Dictionary = _things()
	var allowed: Dictionary = {"low": [&"stoop"], "standing": [&"near"], "high": [&"near", &"up"]}
	var checked: int = 0
	var wrong: PackedStringArray = []
	for group: String in groups:
		for thing: Interactable in groups[group]:
			var goal: Vector3 = thing.hand_target().global_position
			var was_enabled: bool = thing.enabled
			thing.enabled = true
			for radius: float in RINGS:
				for step: int in range(0, RING_STEPS, 2):
					var heading: float = TAU * step / RING_STEPS
					var spot := Vector3(goal.x + radius * sin(heading), 0.02, goal.z + radius * cos(heading))
					if not _fits(spot):
						continue
					_stand(spot, goal)
					if not body.can_reach(thing):
						continue
					var judged: StringName = body._reach_kind(thing.hand_target(body._reach_from(), body._reach_rank))
					body.perform(thing)
					checked += 1
					var limit: float = body._lean_limit(body._reach)
					if body._reach != judged or not (body._reach in allowed[group]) or bool(player.get("crouched")) \
							or body._bend_degrees > limit + 0.01:
						wrong.append("%s at %s: prompt %s, action %s, lean %.0f of %.0f" % [thing.name, spot.snapped(Vector3.ONE * 0.01),
							judged, body._reach, body._bend_degrees, limit])
					body._finish()
			thing.enabled = was_enabled
	assert_true(checked > 300, "standing spots checked: %d" % checked)
	assert_true(wrong.is_empty(), "the action differs from the prompt: " + ", ".join(wrong.slice(0, 8)))
	print("T241_AGREE %d standing spots: the action is the prompt's reach at every one" % checked)


func _walker() -> CharacterBody3D:
	var walker := CharacterBody3D.new()
	walker.set_script(WALKER)
	var head := Node3D.new()
	head.name = "Head"
	head.position = Vector3(0, 1.6, 0)
	walker.add_child(head)
	var camera := Camera3D.new()
	camera.name = "Camera3D"
	head.add_child(camera)
	world.add_child(walker)
	return walker


func _body(walker: CharacterBody3D) -> PlayerBody:
	var made := PlayerBody.new()
	walker.add_child(made)
	made.bind(walker)
	_watch(made)
	return made


func _target(position: Vector3, grip: HandTarget.Grip = HandTarget.Grip.PINCH) -> Interactable:
	var target := Interactable.new()
	world.add_child(target)
	target.global_position = position
	var marker := HandTarget.new()
	marker.grip = grip
	target.add_child(marker)
	return target


func _seconds(seconds: float) -> void:
	var left: float = seconds
	while left > 0.0:
		await tree.physics_frame
		left -= 1.0 / Engine.physics_ticks_per_second


## The lean is planned on bare joints with the steps the modifier poses the bones with: the
## shoulder and the eyes are drawn where they were planned, standing and bending down, and the
## camera sits on those eyes.
func test_the_body_is_drawn_where_the_lean_was_planned() -> void:
	var walker := _walker()
	var made := _body(walker)
	var camera := walker.get_node("Head/Camera3D") as Camera3D
	await _seconds(0.3)
	for case: Array in [[Vector3(0.1, 0.8, -0.62), &"near"], [Vector3(0.12, 0.05, -0.4), &"stoop"]]:
		var target := _target(walker.global_position + (case[0] as Vector3))
		assert_true(made.can_reach(target), "%s target within reach" % case[1])
		made.perform(target)
		assert_eq(made._reach, case[1], "reached the %s way" % case[1])
		assert_true(made._bend_degrees >= 20.0, "%s: it takes a lean (%.0f)" % [case[1], made._bend_degrees])
		# A stoop runs on its own length (D-157); the action's clock reaches CONTACT that much later.
		var length: float = (PlayerBody.stoop_seconds if case[1] == &"stoop" else PlayerBody.HAND_SECONDS) / PlayerBody.HAND_SECONDS
		await _seconds((PlayerBody.CONTACT + 0.05) * length)
		var planned: Dictionary = made._leaned(made._kind(), (made.global_basis * made._lean_forward).normalized(), made._lean_now)
		var shoulder: float = _at("RightUpperArm").distance_to(planned["shoulder"])
		var head: Transform3D = drawn["Head"]
		assert_true(shoulder < 0.015, "%s: the shoulder %.3f m from where it was planned" % [case[1], shoulder])
		assert_true(camera.global_position.distance_to(planned["eye"]) < 0.03,
			"%s: the camera %.3f m from the planned eyes" % [case[1], camera.global_position.distance_to(planned["eye"])])
		assert_true((camera.global_position - head.origin).dot((head.basis.orthonormalized() * head_forward).normalized()) >= CAMERA_AHEAD,
			"%s: the camera in front of the head" % case[1])
		var off: float = made._contact_point().distance_to(target.hand_target().global_position)
		assert_true(off < 0.05 + made.finger_reach * made._scale(), "%s: the hand gets there (%.3f m)" % [case[1], off])
		await _seconds(0.8 * length)
		assert_false(made.acting, "%s: done" % case[1])
		assert_true((walker.get_node("Head") as Node3D).position.is_equal_approx(Vector3(0, 1.6, 0)), "the head is back")
		target.queue_free()
		await _seconds(0.2)


## The body never crouches for a reach; when the player has crouched, it reaches from there.
func test_only_the_player_crouches() -> void:
	var walker := _walker()
	var made := _body(walker)
	await _seconds(0.3)
	var low := _target(walker.global_position + Vector3(0.12, 0.05, -0.4))
	var desk := _target(walker.global_position + Vector3(0.1, 0.8, -0.5))
	var deep := _target(walker.global_position + Vector3(0.1, 0.8, -0.95))
	assert_eq(made._reach_kind(low.hand_target()), &"stoop", "standing: bent down to")
	assert_eq(made._reach_kind(desk.hand_target()), &"near", "standing: taken standing")
	assert_false(made.can_reach(deep), "too deep on the desk: out of reach, nothing leans further for it")
	made.perform(low)
	await _seconds(PlayerBody.stoop_seconds + 0.1)
	assert_false(walker.crouched, "bending down did not crouch the player")
	walker.crouched = true
	await _seconds(0.4)
	# Crouched the shoulders sit lower and further back: nearer things.
	var by_desk := _target(walker.global_position + Vector3(0.1, 0.8, -0.3))
	var by_feet := _target(walker.global_position + Vector3(0.12, 0.05, -0.1))
	assert_eq(made._reach_kind(by_desk.hand_target()), &"kneel", "crouched: from the crouch")
	assert_eq(made._reach_kind(by_feet.hand_target()), &"kneel", "crouched: low things too")
	made.perform(by_desk)
	assert_eq(made._clip, PlayerBody.CLIPS[&"crouch_idle"], "the reach stays in the crouch")
	await _seconds(PlayerBody.HAND_SECONDS + 0.1)
	assert_false(made.acting, "done")


## Card section 4: how long a stoop takes is the owner's to set; the other reaches keep their second.
func test_a_stoop_takes_as_long_as_it_is_set_to() -> void:
	var walker := _walker()
	var made := _body(walker)
	await _seconds(0.3)
	var low := _target(walker.global_position + Vector3(0.12, 0.05, -0.4))
	var desk := _target(walker.global_position + Vector3(0.1, 0.8, -0.5))
	PlayerBody.stoop_seconds = 1.4
	for case: Array in [[low, 1.4], [desk, PlayerBody.HAND_SECONDS]]:
		made.perform(case[0])
		var elapsed: float = 0.0
		while made.acting and elapsed < 3.0:
			await tree.physics_frame
			elapsed += 1.0 / Engine.physics_ticks_per_second
		assert_true(absf(elapsed - float(case[1])) < 0.05, "took %.2f s, set to %.2f" % [elapsed, case[1]])
		await _seconds(0.2)
