extends TestCase
## T-242 (D-154, D-159): room 407's bathroom and balcony doors are opened and closed by hand in
## chapter 1, as Door 407 is, and a body standing where a leaf would swing through it steps clear
## first (all three doors), measured in chapter 1 as it plays.
## - The bathroom door starts shut, the balcony door open (D-127); each takes the hand by Door 407's
##   rule (T-239): its own side's lever when that face is turned to the body, else the free edge.
## - A leaf's sweep is known (DoorSwing); from every spot the prompt shows on, a body in the way
##   finds a spot to step to.
## - Pressing E there walks it clear, then the hand takes the door: the leaf never touches the body.

const CHAPTER := "res://scenes/main/chapter1.tscn"
const BONES: Array[String] = ["Hips", "UpperChest", "Head", "LeftUpperArm", "LeftLowerArm", "LeftHand", "RightUpperArm",
	"LeftUpperLeg", "LeftLowerLeg", "LeftFoot", "RightUpperLeg", "RightLowerLeg", "RightFoot"]
## Standing spots are tried on a grid this fine round each hinge (metres).
const GRID: float = 0.1
const AROUND := Vector2(1.6, 1.5)
## The leaf, as it moves, stays at least this far off the body's capsule and off its bones (metres;
## the hand that works the door is not among them).
const CAPSULE_CLEAR: float = 0.0
const BONES_CLEAR: float = 0.0

var world: Node3D
var chapter: Node3D
var room: Node3D
var player: CharacterBody3D
var body: PlayerBody
var doors: Dictionary = {}
var drawn: Dictionary = {}
var old_mouse: Input.MouseMode


func before_each() -> void:
	old_mouse = Input.mouse_mode
	world = Node3D.new()
	tree.root.add_child(world)
	drawn.clear()
	doors.clear()


func after_each() -> void:
	Input.action_release("interact")
	tree.paused = false
	world.queue_free()
	await wait_frames(2)
	GameState.reset()
	RuleSystem.reset()
	Input.mouse_mode = old_mouse


func _open_chapter1() -> void:
	AudioServer.set_bus_mute(0, true)
	Chapter1Director.resume_checkpoint = &""
	chapter = (load(CHAPTER) as PackedScene).instantiate() as Node3D
	(chapter.get_node("Chapter1Director") as Chapter1Director).auto_start = false
	world.add_child(chapter)
	await wait_frames(3)
	room = chapter.get_node("Floor4/Room407") as Node3D
	player = chapter.get_node("Player") as CharacterBody3D
	body = player.get("body") as PlayerBody
	player.set_physics_process(false)
	var door407 := chapter.get_node("Floor4/Door407") as Interactable
	# The latch on Door 407 is a thing of its own (T-228); here only the leaves are used.
	for latch: Node in door407.find_children("*", "Area3D", true, false):
		if latch is Interactable:
			(latch as Interactable).enabled = false
	doors = {"door407": door407, "bathroom": HingedDoor.of(room.get_node("Extension/BathroomDoor")),
		"balcony": HingedDoor.of(room.get_node("Extension/BalconyDoor"))}
	var skeleton: Skeleton3D = body.skeleton
	skeleton.skeleton_updated.connect(func() -> void:
		for bone: String in BONES:
			drawn[bone] = (skeleton.global_transform * skeleton.get_bone_global_pose(skeleton.find_bone(bone))).origin)


func _grips(door: Interactable) -> Array[HandTarget]:
	var grips: Array[HandTarget] = []
	if door is HingedDoor:
		grips.append_array((door as HingedDoor).grips)
	else:
		for node: Node in door.find_children("*", "Marker3D", true, false):
			if node is HandTarget and node.has_meta(&"door_levers"):
				grips.append(node as HandTarget)
	return grips


func _set_open(door: Interactable, open: bool) -> void:
	if door is HingedDoor:
		(door as HingedDoor).swing(open, 0.0)
	else:
		door.call("set_open", open)
	player.set_physics_process(false)
	if body.acting:
		body._finish()
	player.global_position = room.to_global(Vector3(2.0, 0.02, -3.0))
	await tree.physics_frame
	await tree.physics_frame


## Every spot of the grid round `door`'s hinge the prompt shows on (the body fits, a grip is within
## reach of a body looking at it): [spot, the grip the hand takes from there, in the leaf's way].
func _spots(door: Interactable) -> Array:
	var found: Array = []
	var pivot: Node3D = door.call("pivot")
	var centre: Vector3 = room.to_local(pivot.global_position)
	var z: float = centre.z - AROUND.y
	while z <= centre.z + AROUND.y + 0.001:
		var x: float = centre.x - AROUND.x
		while x <= centre.x + AROUND.x + 0.001:
			var spot: Vector3 = room.to_global(Vector3(x, 0.02, z))
			x += GRID
			if not body._fits(spot):
				continue
			for grip: HandTarget in _grips(door):
				body._stand_at(spot, PlayerBody._yaw_to(spot, grip.global_position))
				if body.can_reach(door):
					var taken: HandTarget = door.hand_target(body._reach_from(), body._reach_rank)
					found.append([spot, taken, DoorSwing.hits(pivot, door.call("swing_angle"), spot, body._body_radius())])
					break
		z += GRID
	return found


## Stands the player on `spot` looking at `door` as the game needs it looked at (Door 407 in its
## doorway, where its InteractShape stays; the others on the leaf, at `grip`), presses E and lets
## the game run until the door has stopped. What happened, and how near the moving leaf came.
func _use(door: Interactable, spot: Vector3, grip: HandTarget) -> Dictionary:
	var look: Vector3 = grip.global_position
	if door.has_node("InteractShape"):
		look = (door.get_node("InteractShape") as Node3D).global_position
	body._stand_at(spot, PlayerBody._yaw_to(spot, look))
	var from_eye: Vector3 = look - (spot + Vector3.UP * 1.6)
	(player.get_node("Head") as Node3D).rotation.x = atan2(from_eye.y, Vector2(from_eye.x, from_eye.z).length())
	player.velocity = Vector3.ZERO
	player.set_physics_process(true)
	await tree.physics_frame
	await tree.physics_frame
	var result: Dictionary = {"focus": player.get("_target") == door, "stepped": false, "acted": false, "walk": 0.0, "capsule": INF, "bones": INF,
		"bone": "", "turned": 0.0}
	if not result["focus"]:
		player.set_physics_process(false)
		return result
	var was_open: bool = bool(door.get("is_open"))
	# just_pressed is told by the frame: pressed and handled outside the physics step, as a key is.
	await tree.process_frame
	Input.action_press("interact")
	player._physics_process(1.0 / 60.0)
	Input.action_release("interact")
	result["stepped"] = player.get("_clear_target") != null
	var pivot: Node3D = door.call("pivot")
	var last: float = pivot.rotation.y
	var still: int = 0
	var frames: int = 0
	# Walking clear, the view stays as it was on the grip the hand is going to take.
	var aim: Vector3 = player.get("_clear_aim")
	var view: float = wrapf(player.global_rotation.y - PlayerBody._yaw_to(player.global_position, aim), -PI, PI)
	while frames < 420:
		await tree.physics_frame
		frames += 1
		result["acted"] = result["acted"] or body.acting
		result["walk"] = maxf(result["walk"], Vector2(player.global_position.x - spot.x, player.global_position.z - spot.z).length())
		if player.get("_clear_target") != null:
			var now: float = wrapf(player.global_rotation.y - PlayerBody._yaw_to(player.global_position, aim), -PI, PI)
			result["turned"] = maxf(result["turned"], absf(wrapf(now - view, -PI, PI)))
		if not is_equal_approx(pivot.rotation.y, last):
			still = 0
			result["capsule"] = minf(result["capsule"], DoorSwing.nearest(pivot, pivot.rotation.y, player.global_position) - body._body_radius())
			for bone: String in drawn:
				var off: float = DoorSwing.nearest(pivot, pivot.rotation.y, drawn[bone])
				if off < result["bones"]:
					result["bones"] = off
					result["bone"] = bone
		else:
			still += 1
		last = pivot.rotation.y
		if player.get("_clear_target") == null and not body.acting and still > 20 and frames > 30:
			break
	player.set_physics_process(false)
	result["toggled"] = bool(door.get("is_open")) != was_open
	return result


func test_the_bathroom_and_balcony_doors_take_the_hand_in_chapter_1() -> void:
	await _open_chapter1()
	var bathroom: HingedDoor = doors["bathroom"]
	var balcony: HingedDoor = doors["balcony"]
	assert_not_null(bathroom, "the bathroom door is used by hand")
	assert_not_null(balcony, "the balcony door is used by hand")
	if bathroom == null or balcony == null:
		return
	assert_false(bathroom.is_open, "D-159: the bathroom door starts the chapter shut")
	assert_true(balcony.is_open, "D-127: the balcony door starts the chapter open")
	assert_eq(bathroom.prompt_key, "PROMPT_OPEN_DOOR", "shut: open door")
	assert_eq(balcony.prompt_key, "PROMPT_CLOSE_DOOR", "open: close door")
	for key: String in ["bathroom", "balcony"]:
		var door: HingedDoor = doors[key]
		assert_eq(door.grips.size(), 3, key + ": a lever on each face and the free edge")
		assert_true(door.get_parent() == door.pivot(), key + ": it rides the leaf")
		var pivot: Node3D = door.pivot()
		assert_true(pivot.has_meta(&"leaf_length") and float(pivot.get_meta(&"leaf_length")) > 0.85 and float(pivot.get_meta(&"leaf_length")) < 1.05,
			"%s: the leaf is measured (%s m)" % [key, pivot.get_meta(&"leaf_length", 0.0)])
		assert_true(float(pivot.get_meta(&"leaf_half", 1.0)) < 0.06, key + ": a leaf's thickness, not what hangs on it")
	# The chapter's own switches still work: the hinge is whoever set it last.
	room.call("set_bathroom_door_open", true)
	await tree.physics_frame
	await tree.physics_frame
	assert_true(bathroom.is_open, "opened by the chapter")
	assert_eq(bathroom.prompt_key, "PROMPT_CLOSE_DOOR", "the prompt follows")


## Chapters 2 to 4 have no body: nothing is fitted on their doors, which stay as they were.
func test_without_the_body_the_doors_are_as_they_were() -> void:
	var floor4 := (load("res://scenes/levels/floor4/floor4.tscn") as PackedScene).instantiate() as Node3D
	world.add_child(floor4)
	await wait_frames(2)
	for path: String in Protagonist.HINGED_DOORS:
		var door := floor4.get_node("Room407/" + path)
		assert_true(HingedDoor.of(door) == null, path + ": no HingedDoor")
		assert_eq(door.find_children("*", "Marker3D", true, false).filter(func(node: Node) -> bool: return node is HandTarget).size(), 0, path + ": no grips")
	assert_false(floor4.get_node("Room407/Extension/BathroomDoor").get("is_open"), "the bathroom door shut")
	assert_true(floor4.get_node("Room407/Extension/BalconyDoor").get("is_open"), "the balcony door open")


## T-239's rule on the two new doors: from one side of the doorway that side's lever, when its face
## is turned to the body; with the leaf open and that face turned away, the free edge.
func test_each_side_takes_its_own_lever_or_the_free_edge() -> void:
	await _open_chapter1()
	for key: String in ["bathroom", "balcony"]:
		var door: HingedDoor = doors[key]
		var frame := door.hinged
		for open: bool in [false, true]:
			await _set_open(door, open)
			var spots: Array = _spots(door)
			assert_true(spots.size() >= 10, "%s %s: the prompt shows somewhere (%d spots)" % [key, "open" if open else "shut", spots.size()])
			var sides: Dictionary = {}
			for entry: Array in spots:
				var spot: Vector3 = entry[0]
				var grip: HandTarget = entry[1]
				var side: float = signf((frame.global_transform.affine_inverse() * spot).z)
				sides[side] = int(sides.get(side, 0)) + 1
				if is_instance_valid(grip.lever):
					assert_eq(signf(float(grip.get_meta(&"door_side"))), signf(side * float((grip.get_meta(&"door_normal") as Vector3).z)),
						"%s %s at %s: its own side's lever" % [key, "open" if open else "shut", room.to_local(spot).snapped(Vector3.ONE * 0.01)])
					assert_true((spot - grip.global_position).dot(grip.lever.global_basis.z) > 0.0, key + ": that lever's face is turned to the body")
				else:
					assert_true(open, key + ": the free edge only of an open leaf")
			if open:
				# D-159: the open leaf lies where only one side reaches it (the balcony door: out on the balcony).
				assert_eq(sides.size(), 1, "%s open: reached from one side only (%s)" % [key, sides])
			else:
				assert_eq(sides.size(), 2, "%s shut: reached from both sides (%s)" % [key, sides])
	# D-159: the balcony door is closed from out on the balcony, never from inside the room.
	var balcony: HingedDoor = doors["balcony"]
	await _set_open(balcony, true)
	for entry: Array in _spots(balcony):
		assert_true((balcony.hinged.global_transform.affine_inverse() * (entry[0] as Vector3)).z < 0.0, "the open balcony door is reached from the balcony")


func test_the_sweep_of_a_leaf() -> void:
	var frame := Node3D.new()
	world.add_child(frame)
	frame.global_position = Vector3(10.0, 0.0, 5.0)
	frame.rotation.y = 0.7
	var pivot := Node3D.new()
	frame.add_child(pivot)
	pivot.set_meta(&"leaf_along", Vector3.RIGHT)
	pivot.set_meta(&"leaf_length", 1.0)
	pivot.set_meta(&"leaf_half", 0.02)
	pivot.set_meta(&"leaf_offset", 0.0)
	var at := func(local: Vector3) -> Vector3: return frame.to_global(local)
	# Turning +90 degrees takes +X round to -Z.
	var quarter: float = PI / 2.0
	assert_true(DoorSwing.nearest(pivot, quarter, at.call(Vector3(0.5, 0.0, -0.5))) < 0.0, "inside the quarter it sweeps")
	assert_true(absf(DoorSwing.nearest(pivot, quarter, at.call(Vector3(1.0, 0.0, -1.0))) - (sqrt(2.0) - 1.0 - 0.02)) < 0.001, "beyond its free end: that far off")
	assert_true(absf(DoorSwing.nearest(pivot, quarter, at.call(Vector3(0.5, 0.0, 0.4))) - 0.38) < 0.001, "behind where it starts: as far as it is now")
	assert_true(absf(DoorSwing.nearest(pivot, quarter, at.call(Vector3(-0.4, 0.0, -0.5))) - 0.38) < 0.001, "past where it ends: as near as it ends")
	assert_true(DoorSwing.hits(pivot, quarter, at.call(Vector3(0.5, 0.0, 0.3)), 0.3), "a body that near is in the way")
	assert_false(DoorSwing.hits(pivot, quarter, at.call(Vector3(0.5, 0.0, 0.4)), 0.3), "a little further it is not")
	# The other way round, from where it stands now (a balcony door's 172 degrees back to shut).
	pivot.rotation.y = deg_to_rad(-172.0)
	assert_true(DoorSwing.nearest(pivot, 0.0, at.call(Vector3(-0.5, 0.0, 0.5))) < 0.0, "swept on the way back")
	assert_true(DoorSwing.nearest(pivot, 0.0, at.call(Vector3(0.0, 0.0, -0.5))) > 0.4, "the other side of the wall is not")
	assert_true(is_inf(DoorSwing.nearest(frame, 0.0, Vector3.ZERO)), "a leaf nobody measured sweeps nothing")


## From every spot the prompt shows on, at all three doors, open and shut: a body the leaf would
## swing through has a spot to step to, no further than CLEAR_REACH, that the leaf misses.
func test_a_body_in_the_way_always_has_a_spot_to_step_to() -> void:
	await _open_chapter1()
	var lines: PackedStringArray = []
	for key: String in doors:
		var door: Interactable = doors[key]
		var pivot: Node3D = door.call("pivot")
		for open: bool in [false, true]:
			await _set_open(door, open)
			var in_the_way: int = 0
			var clear: int = 0
			var slowest: float = 0.0
			var furthest: float = 0.0
			for entry: Array in _spots(door):
				var spot: Vector3 = entry[0]
				body._stand_at(spot, PlayerBody._yaw_to(spot, (entry[1] as HandTarget).global_position))
				var before: int = Time.get_ticks_usec()
				var step: Dictionary = body.clear_spot(door)
				slowest = maxf(slowest, (Time.get_ticks_usec() - before) / 1000.0)
				assert_true(player.global_position.is_equal_approx(spot), "looking for a spot leaves the player where it stood")
				if not entry[2]:
					clear += 1
					assert_true(step.is_empty(), "%s: clear of the leaf, no step" % key)
					continue
				in_the_way += 1
				var name: String = "%s %s from %s" % [key, "open" if open else "shut", room.to_local(spot).snapped(Vector3.ONE * 0.01)]
				assert_false(step.is_empty(), name + ": a spot to step to")
				if step.is_empty():
					continue
				var to: Vector3 = step["spot"]
				furthest = maxf(furthest, to.distance_to(spot))
				assert_true(to.distance_to(spot) <= PlayerBody.CLEAR_REACH + 0.001, "%s: %.2f m away" % [name, to.distance_to(spot)])
				assert_false(DoorSwing.hits(pivot, door.call("swing_angle"), to, body._body_radius(), PlayerBody.SWING_MARGIN - 0.001), name + ": the leaf misses it")
				assert_true(body._fits(to), name + ": the body fits there")
			lines.append("%s %s: %d in the way, %d clear, furthest step %.2f m, slowest search %.1f ms" % [key, "open" if open else "shut", in_the_way, clear, furthest, slowest])
			assert_true(in_the_way >= 10, "%s %s: spots in the leaf's way were tried (%d)" % [key, "open" if open else "shut", in_the_way])
	print("T242_SPOTS " + " | ".join(lines))


## E at a door whose leaf would swing through the body: it walks clear, its eyes on the grip, then
## the hand takes the door; the leaf, as it moves, touches neither the body's capsule nor a bone.
func test_pressing_e_in_the_way_steps_clear_then_uses_the_door() -> void:
	await _open_chapter1()
	var lines: PackedStringArray = []
	for key: String in doors:
		var door: Interactable = doors[key]
		for open: bool in [false, true]:
			await _set_open(door, open)
			var in_the_way: Array = _spots(door).filter(func(entry: Array) -> bool: return entry[2])
			var used: int = 0
			var index: int = 0
			# A few of them, spread over the grid (the nearest the hinge and the furthest among them).
			var every: int = maxi(1, in_the_way.size() / 3)
			while index < in_the_way.size() and used < 3:
				var entry: Array = in_the_way[index]
				index += every
				await _set_open(door, open)
				var seen: Dictionary = await _use(door, entry[0], entry[1])
				if not seen["focus"]:
					# Not looked at from there (Door 407's own prompt box is in the doorway): the next.
					index -= every - 1
					continue
				used += 1
				var name: String = "%s %s from %s" % [key, "open" if open else "shut", room.to_local(entry[0]).snapped(Vector3.ONE * 0.01)]
				lines.append("%s walk %.2f capsule %.3f bones %.3f (%s)" % [name, seen["walk"], seen["capsule"], seen["bones"], seen["bone"]])
				assert_true(seen["stepped"], name + ": it steps clear first")
				assert_true(seen["acted"], name + ": then the hand takes the door")
				assert_true(seen["toggled"], name + ": the door is " + ("shut" if open else "open"))
				assert_true(seen["walk"] <= PlayerBody.CLEAR_REACH + 0.05, "%s: walked %.2f m" % [name, seen["walk"]])
				assert_true(seen["turned"] <= deg_to_rad(3.0), "%s: the view stays on the grip (%.1f degrees off)" % [name, rad_to_deg(seen["turned"])])
				assert_true(seen["capsule"] >= CAPSULE_CLEAR, "%s: the leaf %.3f m from the body" % [name, seen["capsule"]])
				assert_true(seen["bones"] >= BONES_CLEAR, "%s: the leaf %.3f m from %s" % [name, seen["bones"], seen["bone"]])
			assert_true(used >= 2, "%s %s: used from in the way (%d)" % [key, "open" if open else "shut", used])
	print("T242_STEPS " + " | ".join(lines))


## Clear of the leaf nothing changes: E uses the door at once, without a step.
func test_pressing_e_clear_of_the_leaf_uses_the_door_at_once() -> void:
	await _open_chapter1()
	for key: String in doors:
		var door: Interactable = doors[key]
		await _set_open(door, false)
		var done: bool = false
		for entry: Array in _spots(door):
			if entry[2] or done:
				continue
			await _set_open(door, false)
			var seen: Dictionary = await _use(door, entry[0], entry[1])
			if not seen["focus"]:
				continue
			done = true
			assert_false(seen["stepped"], key + ": no step")
			assert_true(seen["walk"] < 0.02, "%s: it stands where it stood (%.3f m)" % [key, seen["walk"]])
			assert_true(seen["acted"] and seen["toggled"], key + ": the door is open")
		assert_true(done, key + ": used from clear of the leaf")


## A plain press (no body: the other chapters' players) and the chapter's own set_open still work
## on a HingedDoor; a swing under way gives in to a set_open.
func test_a_hinged_door_without_a_hand() -> void:
	await _open_chapter1()
	var bathroom: HingedDoor = doors["bathroom"]
	var pivot: Node3D = bathroom.pivot()
	bathroom.interact(player)
	assert_true(bathroom.is_open, "a plain press opens it at once")
	assert_true(is_equal_approx(pivot.rotation.y, bathroom.hinged.call("open_angle")), "to where the hinge opens (82 degrees, D-125)")
	bathroom.swing(false, 0.5)
	assert_false(bathroom.is_open, "closing")
	await tree.physics_frame
	await tree.physics_frame
	assert_true(pivot.rotation.y > 0.01, "the leaf is on its way")
	room.call("set_bathroom_door_open", true)
	await tree.physics_frame
	await tree.physics_frame
	await tree.physics_frame
	assert_true(bathroom.is_open and is_equal_approx(pivot.rotation.y, bathroom.hinged.call("open_angle")), "the chapter's set_open stands")
	var balcony: HingedDoor = doors["balcony"]
	balcony.swing(false, 0.3)
	var frames: int = 0
	while frames < 120 and not is_zero_approx(balcony.pivot().rotation.y):
		await tree.physics_frame
		frames += 1
	assert_true(is_zero_approx(balcony.pivot().rotation.y), "the balcony door swings shut")
	assert_true(frames > 0.8 * 60.0 * deg_to_rad(172.0) / HingedDoor.SWING_SPEED, "no faster than a hand swings it (%d frames)" % frames)


## T-244: a door tells when its leaf starts to swing and when it gets there (for its sounds), by
## hand and when the chapter sets it.
func test_a_hinged_door_tells_its_swings() -> void:
	await _open_chapter1()
	var bathroom: HingedDoor = doors["bathroom"]
	var swings: Array = []
	var settles: Array = []
	bathroom.swung.connect(func(open: bool, seconds: float) -> void: swings.append([open, seconds]))
	bathroom.settled.connect(func(open: bool) -> void: settles.append(open))
	bathroom.swing(true, 0.4)
	assert_eq(swings.size(), 1, "the swing starts")
	assert_true(swings[0][0] and float(swings[0][1]) >= 0.4, "opening, over the hand's hold or longer")
	assert_true(settles.is_empty(), "not there yet")
	for frame: int in 60:
		await tree.physics_frame
	assert_eq(settles, [true], "open")
	room.call("set_bathroom_door_open", false)
	await tree.physics_frame
	await tree.physics_frame
	assert_eq(swings.size(), 2, "the chapter shutting it is told too")
	assert_eq(swings[1], [false, 0.0], "shut at once")
	assert_eq(settles, [true, false], "and settled shut")
