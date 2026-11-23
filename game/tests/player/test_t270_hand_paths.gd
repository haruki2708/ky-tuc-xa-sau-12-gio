extends TestCase
## T-270 (plan step 4 pilot): the right hand's way to a thing and back, measured on a Mixamo clip
## (ReachPaths). The touch and the end are where and when they were; in between the hand bows over
## the straight line. Off by default.

const WALKER := preload("res://tests/player/body_walker.gd")

var world: Node3D
var interactions: Array[Object] = []


func before_each() -> void:
	world = Node3D.new()
	tree.root.add_child(world)
	interactions.clear()
	EventBus.interacted.connect(_on_interacted)


func after_each() -> void:
	PlayerBody.reach_style = &""
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


func _target(position: Vector3) -> Interactable:
	var target := Interactable.new()
	world.add_child(target)
	target.global_position = position
	var marker := HandTarget.new()
	target.add_child(marker)
	return target


func test_the_measured_ways_start_and_end_on_the_line() -> void:
	assert_eq(PlayerBody.reach_style, &"", "the pilot waits for the owner")
	var from := Vector3(0.2, 0.9, 0.1)
	var to := Vector3(0.3, 1.2, -0.4)
	for leg: StringName in [&"reach", &"back"]:
		var path: Array = ReachPaths.PATHS[&"press"][leg]
		assert_true(path.size() >= 10, "%s has its points" % leg)
		assert_true(ReachPaths.point(path, from, to, 0.0).is_equal_approx(from), "%s starts at the start" % leg)
		assert_true(ReachPaths.point(path, from, to, 1.0).is_equal_approx(to), "%s ends at the end" % leg)
		var highest: float = 0.0
		for step: int in 21:
			var point: Vector3 = ReachPaths.point(path, from, to, step / 20.0)
			var along: float = (point - from).dot((to - from).normalized()) / from.distance_to(to)
			assert_true(along > -0.1 and along < 1.1, "%s stays between its ends (%.2f)" % [leg, along])
			var off: Vector3 = point - from.lerp(to, clampf(along, 0.0, 1.0))
			assert_true(off.length() < 0.25 * from.distance_to(to), "%s keeps near its line (%.3f m)" % [leg, off.length()])
			highest = maxf(highest, off.y)
		assert_true(highest > 0.02 * from.distance_to(to), "%s bows over the line (%.3f m)" % [leg, highest])
	# Straight up there is no bow to speak of: the way is the line.
	var up: Vector3 = ReachPaths.point(ReachPaths.PATHS[&"press"][&"reach"], from, from + Vector3.UP * 0.5, 0.5)
	assert_true(absf(up.x - from.x) < 0.001 and absf(up.z - from.z) < 0.001, "straight up stays on the line")


func test_with_the_measured_way_the_hand_still_touches_in_time() -> void:
	PlayerBody.reach_style = PlayerBody.MX_MOTION
	var walker := _walker()
	var body := _body(walker)
	await _seconds(0.3)
	var target := _target(walker.global_position + Vector3(0.18, 1.15, -0.45))
	var finished: Array[Object] = []
	body.hand_action_finished.connect(func(done: Interactable) -> void: finished.append(done))
	var from: Vector3 = body._contact_point()
	var goal: Vector3 = target.hand_target().global_position
	body.perform(target)
	var elapsed: float = 0.0
	var delta: float = 1.0 / Engine.physics_ticks_per_second
	var reach: float = INF
	var over: float = -INF
	while interactions.is_empty() and elapsed < 2.0:
		await tree.physics_frame
		elapsed += delta
		var hand: Vector3 = body._contact_point()
		reach = hand.distance_to(goal)
		# How far the hand is over the straight line from where it hung to the thing.
		var along: float = clampf((hand - from).dot((goal - from).normalized()) / from.distance_to(goal), 0.0, 1.0)
		over = maxf(over, hand.y - from.lerp(goal, along).y)
	assert_true(absf(elapsed - PlayerBody.CONTACT) <= delta * 1.5, "used at contact, %.3f s" % elapsed)
	assert_true(reach < 0.03, "the hand holds the target, %.3f m off" % reach)
	assert_true(over > 0.01, "on the way the hand rose %.3f m over the straight line" % over)
	while finished.is_empty() and elapsed < 2.0:
		await tree.physics_frame
		elapsed += delta
	assert_true(absf(elapsed - PlayerBody.HAND_SECONDS) <= delta * 1.5, "done after one second, %.3f s" % elapsed)
	assert_eq(interactions.size(), 1, "used exactly once")


func test_the_bar_swings_through_its_poses_without_stopping() -> void:
	var walker := _walker()
	var body := _body(walker)
	await _seconds(0.2)
	var keys: Array = PlayerBody.BAR_SWING
	# The same poses at the same shares of the swing, either way.
	var poses: Array = []
	for key: Array in keys:
		poses.append((body._swing_pose(float(key[0]))[0] as Transform3D).origin)
	var blow: float = PlayerBody.BAR_BLOW
	var before_blow: float = ((body._swing_pose(blow + 0.02)[0] as Transform3D).origin - (body._swing_pose(blow - 0.02)[0] as Transform3D).origin).length()
	PlayerBody.reach_style = PlayerBody.MX_MOTION
	for index: int in keys.size():
		var smooth: Vector3 = (body._swing_pose(float(keys[index][0]))[0] as Transform3D).origin
		assert_true(smooth.distance_to(poses[index]) < 0.002, "key %d is where it was (%.4f m)" % [index, smooth.distance_to(poses[index])])
	var through: float = ((body._swing_pose(blow + 0.02)[0] as Transform3D).origin - (body._swing_pose(blow - 0.02)[0] as Transform3D).origin).length()
	assert_true(through > before_blow * 3.0 and through > 0.02, "the fist goes through the blow (%.3f m in 4%% of the swing; it was %.3f)" % [through, before_blow])
	var hold: float = ((body._swing_pose(0.70)[0] as Transform3D).origin - (body._swing_pose(0.64)[0] as Transform3D).origin).length()
	assert_true(hold < 0.01, "the held pose is still held (%.3f m)" % hold)
