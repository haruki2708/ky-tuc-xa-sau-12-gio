extends TestCase
## T-239 (D-153): the four hand fixes from the owner's playtest, measured on the drawn skeleton
## (after every modifier): the phone in the left palm, a sheet read pinched by its right edge, a sheet
## picked up only once pinched, and a door taken by the grip on the player's side (owner, 09/11).

const WALKER := preload("res://tests/player/body_walker.gd")
const PLAYER: PackedScene = preload("res://scenes/player/player.tscn")
const DOOR := preload("res://scenes/levels/floor4/door407.gd")
const FINGERS: Array[String] = ["Index", "Middle", "Ring", "Little"]
## Past the distal joint to the fingertip (metres), a little short of the pad's end.
const TIP: float = 0.02

var world: Node3D
var interactions: Array[Object] = []
## Bone name -> world transform as last drawn (skeleton_updated).
var drawn: Dictionary = {}


func before_each() -> void:
	world = Node3D.new()
	tree.root.add_child(world)
	drawn.clear()
	interactions.clear()
	EventBus.interacted.connect(_on_interacted)


func after_each() -> void:
	EventBus.interacted.disconnect(_on_interacted)
	world.queue_free()
	await wait_frames(2)


func _on_interacted(target: Object) -> void:
	interactions.append(target)


func _seconds(seconds: float) -> void:
	var left: float = seconds
	while left > 0.0:
		await tree.physics_frame
		left -= 1.0 / Engine.physics_ticks_per_second


func _walker(at: Vector3 = Vector3.ZERO, facing: float = 0.0) -> CharacterBody3D:
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
	walker.global_position = at
	walker.global_rotation = Vector3(0.0, facing, 0.0)
	return walker


func _body(walker: CharacterBody3D) -> PlayerBody:
	var body := PlayerBody.new()
	walker.add_child(body)
	body.bind(walker)
	_watch(body)
	return body


## Keep the drawn pose of both hands' bones.
func _watch(body: PlayerBody) -> void:
	var skeleton: Skeleton3D = body.skeleton
	skeleton.skeleton_updated.connect(func() -> void:
		for index: int in skeleton.get_bone_count():
			var bone: String = skeleton.get_bone_name(index)
			if bone.contains("Hand") or bone.contains("Thumb") or bone.contains("Index") or bone.contains("Middle") \
					or bone.contains("Ring") or bone.contains("Little") or bone.contains("Arm"):
				drawn[bone] = skeleton.global_transform * skeleton.get_bone_global_pose(index))


func _origin(bone: String) -> Vector3:
	return (drawn[bone] as Transform3D).origin


func _tip(side: String, finger: String) -> Vector3:
	var distal: Transform3D = drawn[side + finger + "Distal"]
	return distal.origin + distal.basis.y.normalized() * TIP


## Each finger's joints out to its tip (the thumb's from its metacarpal).
func _chains(side: String) -> Array:
	var chains: Array = []
	chains.append([_origin(side + "ThumbMetacarpal"), _origin(side + "ThumbProximal"), _origin(side + "ThumbDistal"), _tip(side, "Thumb")])
	for finger: String in FINGERS:
		chains.append([_origin(side + finger + "Proximal"), _origin(side + finger + "Intermediate"),
				_origin(side + finger + "Distal"), _tip(side, finger)])
	return chains


## The meshes under `root`, as one box in `root`'s space.
func _box(root: Node3D) -> AABB:
	var box := AABB()
	var first := true
	for mesh: MeshInstance3D in root.find_children("*", "MeshInstance3D", true, false):
		if mesh.mesh == null:
			continue
		var to_root: Transform3D = root.global_transform.affine_inverse() * mesh.global_transform
		var aabb: AABB = mesh.get_aabb()
		for corner: int in 8:
			var point: Vector3 = to_root * aabb.get_endpoint(corner)
			box = AABB(point, Vector3.ZERO) if first else box.expand(point)
			first = false
	return box


func _floor() -> void:
	var floor_body := StaticBody3D.new()
	var shape := CollisionShape3D.new()
	shape.shape = BoxShape3D.new()
	(shape.shape as BoxShape3D).size = Vector3(20, 0.2, 20)
	floor_body.add_child(shape)
	floor_body.position.y = -0.1
	world.add_child(floor_body)


## A sheet lying face up on a desk in front of the walker (as Dat's note), turned `turn` degrees.
func _paper(walker: CharacterBody3D, turn: float = 0.0) -> Interactable:
	var paper := (load("res://scenes/interaction/readable.tscn") as PackedScene).instantiate() as Interactable
	paper.set("document_id", &"ch1_dat_note")
	paper.set("size", Vector2(0.15, 0.21))
	world.add_child(paper)
	paper.global_position = walker.global_position + Vector3(0.1, 0.85, -0.45)
	paper.rotation_degrees = Vector3(-90, turn, 0)
	return paper


## Lỗi 1: the phone lies in the left palm, its back on the palm; no joint or fingertip inside it, none
## over its screen (+Z), held low with the light on, raised to read, and on the way between.
func test_phone_lies_in_the_left_palm_without_cutting_it_or_the_screen() -> void:
	_floor()
	var player := PLAYER.instantiate() as CharacterBody3D
	world.add_child(player)
	player.set_body(PlayerBody.new())
	var body: PlayerBody = player.get("body")
	_watch(body)
	var phone := player.get_node("Head/Camera3D/PhoneItem") as Node3D
	var model := phone.get_node("Model") as Node3D
	phone.call("set_flashlight", true)
	await _seconds(0.6)
	_check_phone(body, model, "low")
	phone.call("set_raised", true)
	await _seconds(PlayerBody.PHONE_FADE * 0.5)
	_check_phone(body, model, "on the way up")
	await _seconds(0.6)
	_check_phone(body, model, "raised")
	phone.call("set_raised", false)
	phone.call("set_flashlight", false)


func _check_phone(body: PlayerBody, model: Node3D, pose: String) -> void:
	var box: AABB = _box(model)
	var to_phone: Transform3D = model.global_transform.affine_inverse()
	var inside: Array[String] = []
	var over_screen: Array[String] = []
	var inner: AABB = box.grow(-0.001)
	for chain: Array in _chains("Left"):
		for point: Vector3 in chain:
			var local: Vector3 = to_phone * point
			if inner.has_point(local):
				inside.append(str(local.snapped(Vector3.ONE * 0.001)))
		var tip: Vector3 = to_phone * (chain[-1] as Vector3)
		if tip.z > box.end.z - 0.001 and tip.x > box.position.x + 0.004 and tip.x < box.end.x - 0.004 \
				and tip.y > box.position.y + 0.004 and tip.y < box.end.y - 0.004:
			over_screen.append(str(tip.snapped(Vector3.ONE * 0.001)))
	assert_true(inside.is_empty(), "%s: hand points inside the phone %s" % [pose, inside])
	assert_true(over_screen.is_empty(), "%s: fingertips over the screen %s" % [pose, over_screen])
	# The palm's middle (along the hand from the wrist) sits behind the phone's back, over it.
	var hand: Transform3D = drawn["LeftHand"]
	var palm: Vector3 = to_phone * (hand.origin + hand.basis.y.normalized() * PlayerBody.PALM * body._scale())
	# The bone runs about 4 cm inside the palm (HandShapes.PHONE_IN_HAND, fitted to the hand's mesh).
	assert_true(palm.z < box.position.z - 0.02 and palm.z > box.position.z - 0.055, "%s: the back on the palm (%.3f behind it)" % [pose, box.position.z - palm.z])
	assert_true(palm.x > box.position.x - 0.01 and palm.x < box.end.x + 0.01 and palm.y > box.position.y - 0.01 and palm.y < box.end.y + 0.01,
			"%s: the palm under the phone %s" % [pose, palm.snapped(Vector3.ONE * 0.001)])


## Lỗi 3: read, the sheet is pinched by its right edge: the thumb on the face toward the eyes, the other
## fingers behind, the edge in the web between thumb and index, no finger through the sheet.
func test_read_sheet_is_pinched_by_its_right_edge_thumb_in_front() -> void:
	var walker := _walker()
	var body := _body(walker)
	await _seconds(0.3)
	var paper := _paper(walker)
	body.perform(paper)
	await _seconds(PlayerBody.HAND_SECONDS + 0.3)
	assert_true(body._reading, "reading")
	var sheet := body.get_node("Carried") as Node3D
	var rect: AABB = _box(sheet)
	var to_sheet: Transform3D = sheet.global_transform.affine_inverse()
	var camera := walker.get_node("Head/Camera3D") as Camera3D
	assert_true((to_sheet * camera.global_position).z > 0.0, "the face (+Z) toward the eyes")
	var thumb: Vector3 = to_sheet * _tip("Right", "Thumb")
	assert_true(thumb.z > 0.002, "the thumb on the face toward the eyes (z %.3f)" % thumb.z)
	for finger: String in FINGERS:
		var tip: Vector3 = to_sheet * _tip("Right", finger)
		assert_true(tip.z < -0.002, "%s behind the sheet (z %.3f)" % [finger, tip.z])
	# Held by its right edge (+X): the web outside it, the thumb's and index's tips over the sheet.
	var web: Vector3 = to_sheet * _origin("RightThumbProximal").lerp(_origin("RightIndexProximal"), 0.5)
	assert_true(web.x > rect.end.x, "the edge deep in the web (web %.3f, edge %.3f)" % [web.x, rect.end.x])
	assert_true(thumb.x < rect.end.x, "the thumb's tip on the sheet")
	_check_no_cut(to_sheet, rect, "reading")
	EventBus.document_closed.emit(&"ch1_dat_note")
	await _seconds(1.0)


## No finger's bone runs through the sheet (z = 0 in its frame) inside its outline.
func _check_no_cut(to_sheet: Transform3D, rect: AABB, when: String) -> void:
	var cuts: Array[String] = []
	var names: Array = ["Thumb"] + FINGERS
	var chains: Array = _chains("Right")
	for finger: int in chains.size():
		var chain: Array = chains[finger]
		for index: int in chain.size() - 1:
			var a: Vector3 = to_sheet * (chain[index] as Vector3)
			var b: Vector3 = to_sheet * (chain[index + 1] as Vector3)
			if signf(a.z) == signf(b.z):
				continue
			var cross: Vector3 = a.lerp(b, a.z / (a.z - b.z))
			if cross.x > rect.position.x + 0.002 and cross.x < rect.end.x - 0.002 and cross.y > rect.position.y and cross.y < rect.end.y:
				cuts.append("%s %d %s" % [names[finger], index, cross.snapped(Vector3.ONE * 0.001)])
	assert_true(cuts.is_empty(), "%s: fingers through the sheet at %s" % [when, cuts])


## Lỗi 4: the sheet stays where it lies (its taken edge lifted at most a little) until the thumb and
## index close on it; then it goes up with the hand.
func test_sheet_leaves_the_desk_only_once_pinched() -> void:
	var walker := _walker()
	var body := _body(walker)
	await _seconds(0.3)
	var paper := _paper(walker)
	var lying: Vector3 = (paper.get_node("Mesh") as Node3D).global_position
	body.perform(paper)
	var moved_early: float = 0.0
	var short: Array[String] = []
	while body._time < PlayerBody.PAPER_PINCH - 0.02:
		await tree.physics_frame
		short.append("%.2f:%.3f" % [body._time, body._wrist_off_goal])
		var sheet := body.get_node_or_null("Carried") as Node3D
		if sheet != null:
			moved_early = maxf(moved_early, (sheet.get_child(0) as Node3D).global_position.distance_to(lying))
	print("T239_REACH kind=%s off=%s" % [body._reach, " ".join(short)])
	assert_true(moved_early < HandShapes.PICK_LIFT_RISE * 0.6 + 0.003, "still lying before the pinch (moved %.3f m)" % moved_early)
	while body._time < PlayerBody.PAPER_PINCH + 0.02:
		await tree.physics_frame
	var held := body.get_node("Carried") as Node3D
	var to_sheet: Transform3D = held.global_transform.affine_inverse()
	var thumb: Vector3 = to_sheet * _tip("Right", "Thumb")
	var index: Vector3 = to_sheet * _tip("Right", "Index")
	print("T239_PINCH wrist_off=%.3f thumb=%s index=%s hand=%s planned=%s" % [body._wrist_off_goal, thumb, index,
		to_sheet * _origin("RightHand"), to_sheet * body._pick_hand(1.0).origin])
	assert_true(thumb.z > 0.0 and index.z < 0.003, "pinched: thumb on top (%.3f), index at or under it (%.3f)" % [thumb.z, index.z])
	assert_true(Vector2(thumb.x, thumb.y).distance_to(Vector2(index.x, index.y)) < 0.035, "thumb and index close on the same spot")
	_check_no_cut(to_sheet, _box(held), "pinching")
	await _seconds(0.25)
	assert_true((held.get_child(0) as Node3D).global_position.distance_to(lying) > 0.05, "then it goes up with the hand")
	EventBus.document_closed.emit(&"ch1_dat_note")
	await _seconds(1.2)


## The owner saw the wrist bent when the sheet's top faced him (09/11): the edge taken is the one whose
## pinch points along the reach, not the sheet's own right-hand edge.
func test_the_edge_taken_suits_the_reach() -> void:
	var walker := _walker()
	var body := _body(walker)
	await _seconds(0.3)
	var paper := _paper(walker, 180.0)
	body.perform(paper)
	assert_true(body.acting, "taking it")
	var marker: HandTarget = body._marker
	assert_true(marker != paper.get_node("HandTarget"), "not its own right-hand edge (that one points back at him)")
	assert_true(marker.preference(body._reach_from()) > 0.5, "the pinch points along the reach (%.2f)" % marker.preference(body._reach_from()))
	await _seconds(PlayerBody.HAND_SECONDS + 0.2)
	EventBus.document_closed.emit(&"ch1_dat_note")
	await _seconds(1.2)


## A door like 407: hinge at the origin, the leaf 0.88 m along -X, levers on both faces near its free
## edge (front +Z = the corridor), opening -90 degrees into the back (-Z, the room).
func _door() -> Interactable:
	var door := Interactable.new()
	door.set_script(DOOR)
	world.add_child(door)
	var pivot := Node3D.new()
	pivot.name = "Pivot"
	door.add_child(pivot)
	var leaf := MeshInstance3D.new()
	var box := BoxMesh.new()
	box.size = Vector3(0.88, 2.0, 0.04)
	leaf.mesh = box
	pivot.add_child(leaf)
	leaf.position = Vector3(-0.44, 1.0, 0.0)
	var levers: Array[HandTarget] = DoorHandles.fit(pivot, Vector3(-0.8, 1.05, 0.0), Vector3.BACK, Vector3.RIGHT, 0.02)
	DoorHandles.sides(pivot, levers)
	return door


## The owner (09/11, "b"): from inside the room never the corridor lever; the leaf open, its inner face
## toward the body: the inner lever; turned away: the free edge; from the corridor: the corridor lever.
func test_door_grip_follows_the_side_of_the_doorway() -> void:
	var door := _door()
	await wait_frames(2)
	var front: HandTarget = null
	var back: HandTarget = null
	var edge: HandTarget = null
	for node: Node in door.find_children("*", "Marker3D", true, false):
		var marker := node as HandTarget
		if marker == null:
			continue
		if not is_instance_valid(marker.lever):
			edge = marker
		elif marker.lever.global_basis.z.z > 0.0:
			front = marker
		else:
			back = marker
	assert_true(front != null and back != null and edge != null, "two levers and the free edge")
	assert_eq(door.hand_target(Vector3(-0.7, 1.4, 0.6)), front, "shut, from the corridor: its lever")
	assert_eq(door.hand_target(Vector3(-0.7, 1.4, -0.6)), back, "shut, from the room: its lever")
	door.call("set_open", true)
	await wait_frames(2)
	assert_eq(door.hand_target(Vector3(0.45, 1.4, -0.8)), back, "open, inner face toward him: the inner lever")
	assert_eq(door.hand_target(Vector3(-0.4, 1.4, -1.1)), edge, "open, inner face turned away: the free edge")
	assert_eq(door.hand_target(Vector3(-0.3, 1.4, 0.3)), front, "open, from the corridor: the corridor lever")
	for x: float in [-0.9, -0.5, -0.1, 0.3, 0.7]:
		for z: float in [-0.2, -0.6, -1.0, -1.4]:
			assert_true(door.hand_target(Vector3(x, 1.4, z)) != front, "in the room (%.1f, %.1f): never the corridor lever" % [x, z])


## Closing: no press on the lever; the hand holds the grip as the leaf starts to swing, lets go within
## the second and the door shuts.
func test_closing_a_door_holds_the_grip_without_pressing_the_lever() -> void:
	var door := _door()
	door.call("set_open", true)
	var walker := _walker(Vector3(0.5, 0.0, -0.85), deg_to_rad(90.0))
	var body := _body(walker)
	await _seconds(0.4)
	assert_true(body.can_reach(door), "the inner lever within reach")
	body.perform(door)
	var marker: HandTarget = body._marker
	# Open, the inner face (the room's) is turned east (+X), toward him.
	assert_true(is_instance_valid(marker.lever) and marker.lever.global_basis.z.normalized().x > 0.5, "the inner lever")
	var rest: Quaternion = marker.lever.quaternion
	var pressed := false
	var offs: Array[float] = []
	while body.acting:
		await tree.physics_frame
		pressed = pressed or not marker.lever.quaternion.is_equal_approx(rest)
		if body._phase == PlayerBody.Phase.HOLD and body._used:
			offs.append(body._wrist_off_goal)
	assert_false(pressed, "closing does not press the lever")
	assert_eq(interactions, [door] as Array[Object], "used once")
	assert_true(offs.size() >= 3, "the grip held as the leaf starts to swing (%d frames)" % offs.size())
	# The frame it slips off is the one the hand lets go on (the body sees it a frame later).
	offs.pop_back()
	assert_true(offs.max() <= PlayerBody.ARM_SHORT + 0.002 if not offs.is_empty() else true, "the hand on the grip while it holds (%s m off)" % str(offs))
	assert_true(body._released_at <= PlayerBody.DOOR_LET_GO + 0.001, "let go by %.2f s" % body._released_at)
	await _seconds(0.3)
	assert_false(bool(door.get("is_open")), "shut")
