extends TestCase
## T-249 (D-165): Tran Trung's body in chapter 3, measured in chapter 3 as it plays (the drawn
## skeleton, after every modifier).
## - The right fist holds the iron bar standing, running and through a swing; no bar before the camera.
## - A swing takes the weapon's 0.55 s and never stops the feet; a blow hits or misses as before; the
##   last blow breaks the bar and its pieces fall from the hand to the ground.
## - Every bar on the ground is picked up by bending down (1.4 s, D-157), B05 and B06 too.
## - Ngư's bar comes straight into the fist.
## - Running with the view turned back the legs run on the way he goes, the chest turns back.
## - Out of breath the shoulders rise and fall; the camera does not move.

const CHAPTER := "res://scenes/main/chapter3.tscn"
## The stadium's track: its ground is drawn where it collides.
const TRACK := Vector3(115.0, -9.9, 165.45)
## The hand bone to the middle of the fist holding the bar (measured: 0.096 m).
const FIST_REACH: float = 0.13
## No spine bone this close to the bar's line (it would run through the chest).
const CLEAR_OF_BODY: float = 0.1

var world: Node3D
var chapter: Node3D
var director: Chapter3Director
var player: CharacterBody3D
var body: PlayerBody
var camera: Camera3D
## Bone name -> world transform as last drawn.
var drawn: Dictionary = {}
var swung: Array = []
var broken: Array = []


func before_each() -> void:
	world = Node3D.new()
	tree.root.add_child(world)
	drawn.clear()
	swung.clear()
	broken.clear()


func after_each() -> void:
	for action: String in ["move_forward", "move_back", "sprint", "interact"]:
		Input.action_release(action)
	tree.paused = false
	world.queue_free()
	await wait_frames(2)
	GameState.reset()
	RuleSystem.reset()


func _open_chapter3() -> void:
	AudioServer.set_bus_mute(0, true)
	Chapter1Director.resume_checkpoint = &""
	chapter = (load(CHAPTER) as PackedScene).instantiate() as Node3D
	director = chapter.get_node("Chapter3Director") as Chapter3Director
	director.auto_start = false
	world.add_child(chapter)
	await wait_frames(3)
	player = chapter.get_node("Player") as CharacterBody3D
	body = player.get("body") as PlayerBody
	camera = player.get_node("Head/Camera3D") as Camera3D
	if body != null:
		var skeleton: Skeleton3D = body.skeleton
		skeleton.skeleton_updated.connect(func() -> void:
			for bone: String in ["RightHand", "Hips", "Spine", "Chest", "UpperChest", "Neck", "RightUpperArm"]:
				drawn[bone] = skeleton.global_transform * skeleton.get_bone_global_pose(skeleton.find_bone(bone)))
	EventBus.bar_swung.connect(func(hit: bool, hits: int) -> void: swung.append([hit, hits]))
	EventBus.bar_broken.connect(func() -> void: broken.append(true))
	# Let the director lay the bars on the ground (deferred, then a physics frame).
	for frame: int in 3:
		await tree.physics_frame


func _seconds(seconds: float) -> void:
	var left: float = seconds
	while left > 0.0:
		await tree.physics_frame
		left -= 1.0 / Engine.physics_ticks_per_second


## On the stadium's track, looking down it (-Z), the game running.
func _on_track() -> void:
	player.velocity = Vector3.ZERO
	player.global_position = TRACK
	player.global_rotation = Vector3.ZERO
	(player.get_node("Head") as Node3D).rotation = Vector3.ZERO
	body._face_view()
	player.set_physics_process(true)
	await _seconds(0.3)


func _at(bone: String) -> Vector3:
	return (drawn[bone] as Transform3D).origin


func _weapon() -> IronBarWeapon:
	return player.get("bar_weapon") as IronBarWeapon


## The bar is in the right fist as drawn, clear of the chest, and none hangs before the camera.
func _check_in_fist(when: String) -> void:
	var bar: Node3D = body.get("_bar")
	assert_true(bar != null and is_instance_valid(bar) and bar.visible, when + ": the hand has a bar")
	if bar == null or not is_instance_valid(bar):
		return
	var along: Vector3 = bar.global_basis.z.normalized()
	var grip: Vector3 = bar.global_position + along * IronBarWeapon.GRIP_Z
	var reach: float = grip.distance_to(_at("RightHand"))
	assert_true(reach < FIST_REACH, "%s: the bar's grip in the fist (%.3f m from the hand bone)" % [when, reach])
	var a: Vector3 = bar.global_position - along * IronBarWeapon.LENGTH * 0.5
	var b: Vector3 = bar.global_position + along * IronBarWeapon.LENGTH * 0.5
	for bone: String in ["Hips", "Spine", "Chest", "UpperChest", "Neck"]:
		var p: Vector3 = _at(bone)
		var t: float = clampf((p - a).dot(b - a) / (b - a).length_squared(), 0.0, 1.0)
		var off: float = (a + (b - a) * t).distance_to(p)
		assert_true(off > CLEAR_OF_BODY, "%s: the bar clear of the %s (%.3f m)" % [when, bone, off])
	var weapon := _weapon()
	if weapon != null:
		assert_false(weapon._model.visible, when + ": no bar before the camera")


func test_chapter_3_has_the_body() -> void:
	await _open_chapter3()
	assert_not_null(body, "chapter 3's player has the body")
	assert_true(body != null and body.get_parent() == player, "the body rides the player")


## D-165 row 1, 2: standing, running and through a swing the bar is in the right fist. A swing takes
## the weapon's 0.55 s and the feet run on through it.
func test_the_bar_is_in_the_fist_standing_running_and_swinging() -> void:
	await _open_chapter3()
	await _on_track()
	player.give_bar(8)
	await _seconds(PlayerBody.BAR_FADE + 0.2)
	_check_in_fist("standing")
	Input.action_press("move_forward")
	Input.action_press("sprint")
	await _seconds(0.8)
	assert_true(Vector2(player.velocity.x, player.velocity.z).length() > PlayerBody.RUN_FROM, "running")
	_check_in_fist("running")
	var weapon := _weapon()
	assert_true(weapon.swing(), "the bar swings while running")
	assert_true(absf(float(body.get("_bar_swing_len")) - weapon.swing_seconds) < 0.001, "over the weapon's swing_seconds")
	var slowest: float = INF
	var elapsed: float = 0.0
	while elapsed < weapon.swing_seconds - 0.05:
		await tree.physics_frame
		elapsed += 1.0 / Engine.physics_ticks_per_second
		slowest = minf(slowest, Vector2(player.velocity.x, player.velocity.z).length())
		if absf(elapsed - 0.25) < 0.01:
			_check_in_fist("mid-swing")
	assert_true(slowest > PlayerBody.RUN_FROM, "the feet run on through the swing (slowest %.2f m/s)" % slowest)
	await _seconds(0.15)
	assert_eq(float(body.get("_bar_swing_len")), 0.0, "the swing is over after %.2f s" % weapon.swing_seconds)
	_check_in_fist("after the swing")


func _aim_at(point: Vector3) -> void:
	var to: Vector3 = point - camera.global_position
	player.global_rotation = Vector3(0.0, atan2(-to.x, -to.z), 0.0)
	(player.get_node("Head") as Node3D).rotation.x = atan2(to.y, Vector2(to.x, to.z).length())
	body._face_view()


## D-165 row 2: a blow on the head stuns as before and a blow at the sky misses; the last blow breaks
## the bar and its two pieces fall from the hand to the ground.
func test_a_blow_hits_or_misses_as_before_and_the_last_one_breaks_the_bar() -> void:
	await _open_chapter3()
	await _on_track()
	player.give_bar(8)
	await _seconds(0.4)
	(player.get_node("Head") as Node3D).rotation.x = deg_to_rad(60.0)
	await _seconds(0.1)
	_weapon().swing()
	await _seconds(0.7)
	assert_eq(swung, [[false, 8]], "a blow at the sky misses")
	(player.get_node("Head") as Node3D).rotation.x = 0.0
	var zombie := director._make_zombie("zombie_02")
	director.add_child(zombie)
	zombie.global_position = player.global_position - player.global_basis.z * 1.15
	zombie.face(player.global_position)
	zombie.sleep_pose(&"idle")
	await _seconds(0.4)
	player.give_bar(1)
	await _seconds(0.3)
	_aim_at((zombie.get_node("HeadHitbox") as Node3D).global_position)
	await _seconds(0.1)
	_weapon().swing()
	assert_eq(swung[-1], [true, 0], "the blow on the head lands")
	assert_true(zombie.is_stunned(), "and stuns")
	assert_eq(broken.size(), 1, "the last blow breaks the bar")
	await _seconds(0.4)
	# The pieces are RigidBody3D carrying a copy of the bar's halves (IronBarWeapon.drop).
	var pieces: Array[RigidBody3D] = []
	for node: Node in chapter.find_children("*", "RigidBody3D", true, false):
		if node.get_node_or_null("HalfGrip") != null or node.get_node_or_null("HalfTip") != null:
			pieces.append(node as RigidBody3D)
	assert_eq(pieces.size(), 2, "two pieces fall")
	var bar: Node3D = body.get("_bar")
	assert_false(bar != null and is_instance_valid(bar) and bar.visible, "the hand has no bar left")
	await _seconds(1.5)
	for piece: RigidBody3D in pieces:
		assert_true(piece.global_position.y < player.global_position.y + 0.15, "a piece lies on the ground (%.2f m up)" % (piece.global_position.y - player.global_position.y))


## The world's floor right under `at`, or INF.
func _floor_under(at: Vector3) -> float:
	var query := PhysicsRayQueryParameters3D.create(at + Vector3.UP * 1.2, at + Vector3.DOWN * 1.0, 1)
	query.exclude = [player.get_rid()]
	var hit: Dictionary = player.get_world_3d().direct_space_state.intersect_ray(query)
	return (hit["position"] as Vector3).y if not hit.is_empty() else INF


## The spots round `bar` the player can stand on and reach it from (world, standing on its floor).
func _spots(bar: IronBar) -> Array[Vector3]:
	var shape := player.get("body_shape") as CollisionShape3D
	var space := player.get_world_3d().direct_space_state
	var found: Array[Vector3] = []
	var floor_y: float = _floor_under(bar.global_position + Vector3.UP * 0.05)
	for radius: float in [0.4, 0.55, 0.7, 0.85]:
		for step: int in 16:
			var heading: float = TAU * step / 16.0
			var spot := Vector3(bar.global_position.x + radius * sin(heading), floor_y + 0.02, bar.global_position.z + radius * cos(heading))
			var query := PhysicsShapeQueryParameters3D.new()
			query.shape = shape.shape
			query.transform = Transform3D(Basis.IDENTITY, spot + shape.position + Vector3.UP * 0.04)
			query.collision_mask = player.collision_mask
			query.exclude = [player.get_rid()]
			if not space.intersect_shape(query, 1).is_empty():
				continue
			player.global_position = spot
			var toward: Vector3 = bar.global_position - spot
			player.global_rotation = Vector3(0.0, atan2(-toward.x, -toward.z), 0.0)
			body._face_view()
			if body.can_reach(bar):
				found.append(spot)
	return found


func _stand_at(spot: Vector3, bar: IronBar) -> void:
	player.global_position = spot
	var toward: Vector3 = bar.global_position - spot
	player.global_rotation = Vector3(0.0, atan2(-toward.x, -toward.z), 0.0)
	body._face_view()


## D-165 row 3: every bar lying about is reached by bending down (B05 at the gate and B06 by the
## canteen lay 4 cm below a palm's reach before the fingertip hook); one is picked up: a 1.4 s stoop,
## no crouch, and he stands up with it in the fist.
func test_every_bar_is_picked_up_bending_down() -> void:
	await _open_chapter3()
	player.set_physics_process(false)
	var bars: Array[IronBar] = []
	for node: Node in chapter.find_children("*", "Area3D", true, false):
		if node is IronBar and (node as IronBar).is_visible_in_tree():
			bars.append(node as IronBar)
	assert_eq(bars.size(), 7, "chapter 3's seven bars")
	var gate: IronBar = null
	var lines: PackedStringArray = []
	for bar: IronBar in bars:
		var spots: Array[Vector3] = _spots(bar)
		lines.append("%s %d" % [bar.global_position.snapped(Vector3.ONE * 0.1), spots.size()])
		assert_true(spots.size() >= 4, "bar at %s within reach from %d spots" % [bar.global_position, spots.size()])
		if not spots.is_empty():
			_stand_at(spots[0], bar)
			assert_eq(body._reach_kind(bar.hand_target(body._reach_from(), body._reach_rank)), &"stoop", "bar at %s: bent down to" % bar.global_position)
		if Vector2(bar.global_position.x, bar.global_position.z).distance_to(Vector2(228.0, -29.0)) < 0.5:
			gate = bar
	print("T249_BARS ", " | ".join(lines))
	assert_not_null(gate, "B05 at the gate")
	if gate == null:
		return
	var spots: Array[Vector3] = _spots(gate)
	_stand_at(spots[spots.size() / 2], gate)
	assert_true(body.can_reach(gate), "B05 within reach")
	player.set_physics_process(true)
	body.perform(gate)
	assert_eq(body._reach, &"stoop", "bending down for it")
	var frames: int = 0
	var crouched: bool = false
	while body.acting and frames < 300:
		await tree.physics_frame
		frames += 1
		crouched = crouched or bool(player.get("crouched"))
	var took: float = frames / float(Engine.physics_ticks_per_second)
	assert_false(crouched, "no crouch")
	assert_true(absf(took - PlayerBody.stoop_seconds) < 0.1, "a %.1f s stoop (took %.2f s)" % [PlayerBody.stoop_seconds, took])
	assert_eq(_weapon().hits_left, 8, "a fresh bar")
	assert_false(gate.visible, "it has left the ground")
	await _seconds(0.3)
	_check_in_fist("stood up with it")


## D-165 row 4: when Ngư has spoken in the garden the bar comes straight into the fist.
func test_ngu_hands_the_bar_into_the_fist() -> void:
	await _open_chapter3()
	director.run_from(&"garden")
	await _seconds(0.5)
	director.debug_zombies_off()
	var bench := director._anchor("NguBench")
	var stand: Vector3 = bench.global_position + Vector3(0.0, 0.0, -2.0)
	stand.y = _floor_under(stand) + 0.02
	player.global_position = stand
	player.set_physics_process(true)
	var waited: float = 0.0
	while (_weapon() == null or _weapon().hits_left <= 0) and waited < 40.0:
		await tree.physics_frame
		waited += 1.0 / Engine.physics_ticks_per_second
	assert_true(_weapon() != null and _weapon().hits_left == 8, "Ngư gives a bar (after %.1f s)" % waited)
	await _seconds(PlayerBody.BAR_FADE + 0.1)
	_check_in_fist("from Ngư")


## D-165 row 11: running with the view turned back, the legs run on the way he goes (no run played
## backwards) and the chest and head turn back; walking backwards is as before.
func test_running_with_the_view_back_the_legs_run_on() -> void:
	await _open_chapter3()
	await _on_track()
	Input.action_press("sprint")
	Input.action_press("move_forward")
	await _seconds(1.2)
	Input.action_release("move_forward")
	Input.action_press("move_back")
	await _seconds(1.3)
	var going: Vector3 = Vector3(player.velocity.x, 0.0, player.velocity.z)
	assert_true(going.length() > PlayerBody.RUN_FROM, "running the other way from the view (%.2f m/s)" % going.length())
	assert_eq(body._clip, PlayerBody.CLIPS[&"run"], "the run")
	assert_true(body.animator.speed_scale > 0.0, "played forwards (%.2f)" % body.animator.speed_scale)
	var facing: Vector3 = body.model.global_basis.z
	facing.y = 0.0
	assert_true(rad_to_deg(facing.angle_to(going)) < 15.0, "the body faces the way he runs (%.0f degrees off)" % rad_to_deg(facing.angle_to(going)))
	assert_true(body._torso.chest_degrees > 20.0, "the chest turns back (%.0f degrees)" % body._torso.chest_degrees)
	assert_true(absf(body._torso.head_degrees) > 10.0, "the head further (%.0f degrees)" % body._torso.head_degrees)
	Input.action_release("sprint")
	await _seconds(0.8)
	assert_eq(body._clip, PlayerBody.CLIPS[&"walk"], "walking backwards")
	assert_true(body.animator.speed_scale < 0.0, "the stride played backwards, as before")


## D-165 row 12: out of breath the shoulders rise and fall; the camera stays where it is.
func test_out_of_breath_the_shoulders_heave_not_the_camera() -> void:
	await _open_chapter3()
	await _on_track()
	player.call("_set_stamina", 0.0)
	assert_true(bool(player.get("exhausted")), "spent")
	await _seconds(0.8)
	var camera_low: float = INF
	var camera_high: float = -INF
	var shoulder_low: float = INF
	var shoulder_high: float = -INF
	var elapsed: float = 0.0
	while elapsed < 1.6:
		await tree.physics_frame
		elapsed += 1.0 / Engine.physics_ticks_per_second
		camera_low = minf(camera_low, camera.global_position.y)
		camera_high = maxf(camera_high, camera.global_position.y)
		shoulder_low = minf(shoulder_low, _at("RightUpperArm").y)
		shoulder_high = maxf(shoulder_high, _at("RightUpperArm").y)
	assert_true(camera_high - camera_low < 0.001, "the camera still (%.4f m)" % (camera_high - camera_low))
	assert_true(shoulder_high - shoulder_low > 0.008, "the shoulders heave (%.3f m)" % (shoulder_high - shoulder_low))
	player.call("_set_stamina", 1.0)
	await _seconds(PlayerBody.BREATH_OFF + 0.3)
	assert_eq(body._breath.lift, 0.0, "breathing easy again")
