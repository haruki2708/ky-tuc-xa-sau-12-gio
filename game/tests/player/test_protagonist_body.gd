extends TestCase
## T-220 step 1 (D-121): the player's full body. Feet do not slide, a hand action takes one
## second and reaches its HandTarget, the head is hidden from the player's camera but shows in
## mirrors, a picked-up paper rides to the eyes and goes back.

const WALKER := preload("res://tests/player/body_walker.gd")
const PLAYER: PackedScene = preload("res://scenes/player/player.tscn")

var world: Node3D
var interactions: Array[Object] = []


func before_each() -> void:
	world = Node3D.new()
	tree.root.add_child(world)
	interactions.clear()
	EventBus.interacted.connect(_on_interacted)


func after_each() -> void:
	EventBus.interacted.disconnect(_on_interacted)
	world.queue_free()
	await wait_frames(2)


func _on_interacted(target: Object) -> void:
	interactions.append(target)


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
	var body := PlayerBody.new()
	walker.add_child(body)
	body.bind(walker)
	return body


func _attach(body: PlayerBody, bone: String) -> BoneAttachment3D:
	var attachment := BoneAttachment3D.new()
	attachment.bone_name = bone
	body.skeleton.add_child(attachment)
	return attachment


## A press target with a HandTarget at a comfortable reach in front of the walker.
func _target(position: Vector3) -> Interactable:
	var target := Interactable.new()
	world.add_child(target)
	target.global_position = position
	var marker := HandTarget.new()
	target.add_child(marker)
	return target


## Dat's note lying face up on a desk in front of the walker, taken by its right-hand edge.
func _paper(walker: CharacterBody3D) -> Interactable:
	var paper := (load("res://scenes/interaction/readable.tscn") as PackedScene).instantiate() as Interactable
	paper.set("document_id", &"ch1_dat_note")
	world.add_child(paper)
	paper.global_position = walker.global_position + Vector3(0.1, 0.85, -0.45)
	paper.rotation_degrees = Vector3(-90, 0, 0)
	var pinch := HandTarget.new()
	pinch.pick_up = true
	pinch.grip = HandTarget.Grip.PINCH
	paper.add_child(pinch)
	pinch.position = Vector3((paper.get("size") as Vector2).x * 0.5 - 0.015, 0.0, 0.002)
	return paper


func _seconds(seconds: float) -> void:
	var left: float = seconds
	while left > 0.0:
		await tree.physics_frame
		left -= 1.0 / Engine.physics_ticks_per_second


func test_view_mesh_hides_the_head_and_the_mirror_mesh_casts_the_shadow() -> void:
	var walker := _walker()
	var body := _body(walker)
	assert_false(body.view_meshes.is_empty())
	assert_eq(body.view_meshes.size(), body.mirror_meshes.size())
	var head: int = body.skeleton.find_bone("Head")
	for index: int in body.view_meshes.size():
		var view: MeshInstance3D = body.view_meshes[index]
		var mirror: MeshInstance3D = body.mirror_meshes[index]
		assert_eq(view.layers, 1)
		assert_eq(view.cast_shadow, GeometryInstance3D.SHADOW_CASTING_SETTING_OFF)
		assert_eq(mirror.layers, 1 << (PlayerBody.MIRROR_LAYER - 1))
		assert_eq(mirror.cast_shadow, GeometryInstance3D.SHADOW_CASTING_SETTING_ON)
		var folded: bool = false
		for bind: int in view.skin.get_bind_count():
			if view.skin.get_bind_name(bind) == "Head" or view.skin.get_bind_bone(bind) == head:
				folded = view.skin.get_bind_pose(bind).basis.get_scale().x < 0.001
				assert_true(mirror.skin.get_bind_pose(bind).basis.get_scale().x > 0.5, "the mirror keeps the head")
		assert_true(folded, "the view mesh folds the head away")
	var camera := walker.get_node("Head/Camera3D") as Camera3D
	assert_false(camera.get_cull_mask_value(PlayerBody.MIRROR_LAYER), "the player's camera skips the mirror mesh")


func test_eyes_stand_under_the_camera_and_the_head_stays_put() -> void:
	var walker := _walker()
	var body := _body(walker)
	await _seconds(0.3)
	var eye: Vector3 = body._eye_world()
	var camera := walker.get_node("Head/Camera3D") as Camera3D
	assert_true(Vector2(eye.x - camera.global_position.x, eye.z - camera.global_position.z).length() < 0.04,
		"eyes over the camera, off by %.3f m" % Vector2(eye.x - camera.global_position.x, eye.z - camera.global_position.z).length())
	assert_true(absf(eye.y - 1.6) < 0.08, "eyes near 1.6 m, got %.2f" % eye.y)
	assert_eq((walker.get_node("Head") as Node3D).position, Vector3(0, 1.6, 0), "looking ahead, the head is where the player put it")
	(walker.get_node("Head") as Node3D).rotation.x = deg_to_rad(-75.0)
	await _seconds(0.1)
	var head: Vector3 = (walker.get_node("Head") as Node3D).position
	assert_true(head.z < -0.1 and absf(head.y - 1.6) < 0.001, "looking down bends the neck forward, got %s" % head)


func test_planted_feet_do_not_slide_at_walking_speed() -> void:
	var walker := _walker()
	var body := _body(walker)
	var foot := _attach(body, "LeftFoot")
	var toes := _attach(body, "LeftToes")
	await _seconds(0.2)
	var delta: float = 1.0 / Engine.physics_ticks_per_second
	var points: Array[Vector3] = []
	var toe_heights: Array[float] = []
	walker.velocity = Vector3(0, 0, -2.2)
	for frame: int in int(3.0 / delta):
		walker.position += walker.velocity * delta
		await tree.physics_frame
		if frame * delta > 0.6:
			points.append(foot.global_position)
			toe_heights.append(toes.global_position.y)
	var low: float = INF
	var low_toe: float = INF
	for index: int in points.size():
		low = minf(low, points[index].y)
		low_toe = minf(low_toe, toe_heights[index])
	var worst: float = 0.0
	var runs: int = 0
	var start: int = -1
	for index: int in points.size() + 1:
		var planted: bool = index < points.size() and points[index].y < low + PlayerBody.STANCE_HEIGHT \
			and toe_heights[index] < low_toe + PlayerBody.STANCE_HEIGHT
		if planted and start < 0:
			start = index
		elif not planted and start >= 0:
			if index - start >= 3:
				runs += 1
				var first: Vector3 = points[start]
				var last: Vector3 = points[index - 1]
				worst = maxf(worst, Vector2(last.x - first.x, last.z - first.z).length())
			start = -1
	assert_true(runs >= 2, "saw %d planted steps" % runs)
	assert_true(worst < 0.03, "a planted foot slid %.3f m" % worst)


func test_hand_action_takes_one_second_and_reaches_the_target() -> void:
	var walker := _walker()
	var body := _body(walker)
	await _seconds(0.3)
	var target := _target(walker.global_position + Vector3(0.18, 1.15, -0.45))
	var finished: Array[Object] = []
	body.hand_action_finished.connect(func(done: Interactable) -> void: finished.append(done))
	assert_true(body.can_handle(target))
	body.perform(target)
	assert_true(body.acting)
	assert_true(walker.locks.has(body), "no walking during the action")
	var elapsed: float = 0.0
	var delta: float = 1.0 / Engine.physics_ticks_per_second
	var reach: float = INF
	while interactions.is_empty() and elapsed < 2.0:
		await tree.physics_frame
		elapsed += delta
		reach = body._contact_point().distance_to(target.hand_target().global_position)
	assert_true(absf(elapsed - PlayerBody.CONTACT) <= delta * 1.5, "used at contact, %.3f s" % elapsed)
	assert_eq(interactions, [target] as Array[Object])
	assert_true(reach < 0.03, "the hand holds the target, %.3f m off" % reach)
	while finished.is_empty() and elapsed < 2.0:
		await tree.physics_frame
		elapsed += delta
	assert_true(absf(elapsed - PlayerBody.HAND_SECONDS) <= delta * 1.5, "done after one second, %.3f s" % elapsed)
	assert_eq(interactions.size(), 1, "used exactly once")
	assert_false(walker.locks.has(body))
	assert_false(body.acting)


func test_a_target_out_of_arm_reach_is_reached_by_leaning_in() -> void:
	var walker := _walker()
	var body := _body(walker)
	await _seconds(0.3)
	# A door handle at 1.05 m, 0.45 m ahead of the eyes: the arm alone falls short. (Further
	# than a lean can reach, a person steps in; that is for step 3, T-220.)
	var target := _target(walker.global_position + Vector3(0.1, 1.05, -0.45))
	body.perform(target)
	await _seconds(PlayerBody.CONTACT)
	assert_true(body._bend.degrees > 5.0, "the chest leans in")
	var off: float = body._contact_point().distance_to(target.hand_target().global_position)
	assert_true(off < 0.04, "and the hand gets there: %.3f m off at %.0f degrees" % [off, body._bend.degrees])
	assert_true((walker.get_node("Head") as Node3D).position.z < -0.02, "the camera rides with the head")
	await _seconds(0.7)
	assert_false(body.acting)
	assert_true((walker.get_node("Head") as Node3D).position.is_equal_approx(Vector3(0, 1.6, 0)), "the head is back")


func test_a_thing_without_a_hand_target_is_left_to_a_plain_press() -> void:
	var walker := _walker()
	var body := _body(walker)
	var plain := Interactable.new()
	world.add_child(plain)
	assert_false(body.can_handle(plain))
	var player := PLAYER.instantiate() as CharacterBody3D
	world.add_child(player)
	player.set_body(PlayerBody.new())
	assert_true(is_instance_valid(player.body))
	assert_eq(player.body.player, player)
	var ray := player.get_node("Head/Camera3D/InteractRay") as RayCast3D
	assert_eq(ray.target_position, Vector3(0, 0, -2), "interaction reach unchanged")


func test_door_swings_with_the_hand_but_snaps_on_a_press() -> void:
	var floor4 := (load("res://scenes/levels/floor4/floor4.tscn") as PackedScene).instantiate()
	var door := floor4.get_node("Door407").duplicate() as Interactable
	floor4.free()
	world.add_child(door)
	door.interact(null)
	assert_true(is_equal_approx((door.get_node("Pivot") as Node3D).rotation.y, -PI / 2.0), "a press snaps open")
	door.interact(null)
	assert_true(is_zero_approx((door.get_node("Pivot") as Node3D).rotation.y))
	door.interact_by_hand(null, 0.55)
	await _seconds(0.2)
	var angle: float = (door.get_node("Pivot") as Node3D).rotation.y
	assert_true(angle < -0.05 and angle > -PI / 2.0 + 0.05, "by hand it is still swinging, %.2f" % angle)
	assert_eq(door.hand_seconds, 0.0)
	await _seconds(0.5)
	assert_true(absf((door.get_node("Pivot") as Node3D).rotation.y + PI / 2.0) < 0.01)


func test_paper_rides_to_the_eyes_and_goes_back_after_reading() -> void:
	var walker := _walker()
	var body := _body(walker)
	await _seconds(0.3)
	var paper := _paper(walker)
	var opened: Array[StringName] = []
	var on_open := func(id: StringName) -> void: opened.append(id)
	EventBus.document_opened.connect(on_open)
	var sheet := paper.get_node("Mesh") as MeshInstance3D
	body.perform(paper)
	await _seconds(PlayerBody.CONTACT + 0.05)
	assert_false(sheet.visible, "the paper left its place")
	assert_true(opened.is_empty(), "not read before it reaches the eyes")
	await _seconds(PlayerBody.HAND_SECONDS - PlayerBody.CONTACT - 0.05 + 0.05)
	EventBus.document_opened.disconnect(on_open)
	assert_eq(opened, [&"ch1_dat_note"] as Array[StringName])
	var camera := walker.get_node("Head/Camera3D") as Camera3D
	var held := body.get_node("Carried") as Node3D
	var off: Vector3 = camera.global_transform.affine_inverse() * (held.get_child(0) as Node3D).global_position - PlayerBody.READ_POINT
	assert_true(off.length() < 0.06, "the sheet is held before the eyes, off by %s (camera space)" % off)
	assert_true(body.acting, "held while reading")
	EventBus.document_closed.emit(&"ch1_dat_note")
	await _seconds(PlayerBody.PUT_DOWN_SECONDS * 0.5)
	assert_false(sheet.visible, "carried back by hand, not snapped back")
	await _seconds(PlayerBody.PUT_DOWN_SECONDS * 0.5 + 0.03)
	assert_true(sheet.visible, "the paper is back in its place")
	await _seconds(PlayerBody.LET_GO_SECONDS + 0.03)
	assert_false(body.acting)
	assert_false(walker.locks.has(body))


## The owner saw the arm swing back behind the body after reading (19/10): the hand must stay
## in front of the body, and never far from its own goal, through the whole put-back.
func test_hand_never_swings_behind_the_body_when_putting_the_paper_back() -> void:
	var walker := _walker()
	var body := _body(walker)
	await _seconds(0.3)
	var paper := _paper(walker)
	# Where the hanging hand rests (body-local, forward is -Z) before the action.
	var rest: float = (walker.global_transform.affine_inverse() * body._hand_tip()).z
	body.perform(paper)
	await _seconds(PlayerBody.HAND_SECONDS + 0.3)
	EventBus.document_closed.emit(&"ch1_dat_note")
	var behind: float = -INF
	while body.acting:
		await tree.physics_frame
		var local: Vector3 = walker.global_transform.affine_inverse() * body._hand_tip()
		behind = maxf(behind, local.z)
	assert_true(behind < rest + 0.05, "the hand went %.2f m back, resting at %.2f" % [behind, rest])


## The owner (19/10): the sheet sits a little inside the grip, by a side edge, but never through
## the palm. Held up to read, it faces the eyes, upright, reaches across to the left of the hand;
## its right-hand edge stops just short of the palm, between the thumb and the fingers.
func test_held_paper_is_pinched_by_its_side_edge_not_through_the_palm() -> void:
	var walker := _walker()
	var body := _body(walker)
	await _seconds(0.3)
	var paper := _paper(walker)
	var edge: float = (paper.get("size") as Vector2).x * 0.5
	body.perform(paper)
	await _seconds(PlayerBody.HAND_SECONDS + 0.2)
	var camera := walker.get_node("Head/Camera3D") as Camera3D
	var sheet := body.get_node("Carried") as Node3D
	var middle: Vector3 = body._hand_tip()
	var centre: Vector3 = (sheet.get_child(0) as Node3D).global_position
	var right: Vector3 = sheet.global_basis.x.normalized()
	var half: float = PlayerBody.HAND_HALF * body._scale()
	assert_true(sheet.global_basis.y.normalized().dot(Vector3.UP) > 0.9, "upright")
	assert_true(sheet.global_basis.z.normalized().dot((camera.global_position - centre).normalized()) > 0.9, "the face turns to the eyes")
	var palm: Vector3 = (body._hand_attach.global_basis.orthonormalized() * body._palm_axis).normalized()
	assert_true(palm.dot(-right) > 0.8, "the palm faces in across the sheet")
	assert_true((centre - middle).dot(right) < -0.04, "the sheet reaches across, left of the hand")
	# The right-hand edge, from the palm's middle along the sheet's right: past the palm's surface
	# (not in the palm), within a centimetre and a half of it.
	var reach_in: float = -(centre + right * edge - middle).dot(right)
	assert_true(reach_in > half and reach_in < half + 0.015, "the edge is %.3f m from the palm's middle (palm surface at %.3f)" % [reach_in, half])
	assert_true(absf((middle - sheet.global_position).dot(sheet.global_basis.z.normalized())) < 0.02, "the sheet runs through the grip")
	EventBus.document_closed.emit(&"ch1_dat_note")
