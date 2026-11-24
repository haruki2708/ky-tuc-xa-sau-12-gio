extends TestCase
## T-271 (D-192): getting out of a lower bunk with the body's own motion (PlayerBody.bed_rise_seconds).
## The player is out at once, as ever; the body takes its seconds over it, the view on its eyes,
## ducking out from under the upper bunk; no walking meanwhile. An upper bunk, a silent leave and
## a player without a body are out at once, as before. Real room 407, story stopped.

const PlayerScript = preload("res://scripts/player/player.gd")
const SECONDS: float = 1.6
var scene: Node3D
var player: PlayerScript
var director: Chapter1Director
var old_mouse: Input.MouseMode


func before_each() -> void:
	old_mouse = Input.mouse_mode
	GameState.reset()
	Chapter1Director.resume_checkpoint = &""
	scene = load("res://scenes/main/chapter1.tscn").instantiate()
	director = scene.get_node("Chapter1Director")
	director.auto_start = false
	tree.root.add_child(scene)
	player = scene.get_node("Player")
	player.set_physics_process(false)
	await wait_frames(3)
	player.set_body(PlayerBody.new())
	await _seconds(0.3)


func after_each() -> void:
	PlayerBody.bed_rise_seconds = 0.0
	tree.paused = false
	for node: Node in scene.find_children("*", "AudioStreamPlayer3D", true, false):
		if node.has_method("stop_emitting"):
			node.call("stop_emitting")
		(node as AudioStreamPlayer3D).stop()
	scene.queue_free()
	await wait_frames(3)
	GameState.reset()
	RuleSystem.reset()
	Input.mouse_mode = old_mouse


func _seconds(seconds: float) -> void:
	var left: float = seconds
	while left > 0.0:
		await tree.physics_frame
		left -= 1.0 / Engine.physics_ticks_per_second


func _lie(bed: int) -> HideSpot:
	var spot: HideSpot = director._bunks[bed]
	var exit := spot.get_node(spot.exit) as Node3D
	player.global_transform = exit.global_transform
	player.head.position = Vector3(0, 1.6, 0)
	player.head.rotation = Vector3.ZERO
	assert_true(player.enter_hide_spot(spot), "into bed %d" % bed)
	await _seconds(0.2)
	return spot


func test_the_pilot_waits_for_the_owner() -> void:
	assert_eq(PlayerBody.bed_rise_seconds, 0.0, "out of bed at once until the owner approves")
	var spot := await _lie(3)
	player.leave_hide_spot()
	assert_false(player.body.getting_up(), "at once, as before")
	assert_false(player.movement_locked())
	assert_true(spot != null)


func test_out_of_both_lower_bunks_with_the_motion() -> void:
	PlayerBody.bed_rise_seconds = SECONDS
	var body: PlayerBody = player.body
	var delta: float = 1.0 / Engine.physics_ticks_per_second
	# 3 is Tran Trung's own (the way out on his left, the mirrored clip), 2 the one across the room.
	for bed: int in [3, 2]:
		var label: String = "bed %d" % bed
		var spot := await _lie(bed)
		var view := spot.get_node(spot.view) as Node3D
		var exit := spot.get_node(spot.exit) as Node3D
		var pillow: Vector3 = player.camera.global_position
		var looked: Basis = player.camera.global_basis
		var to_feet: Vector3 = -view.global_basis.z
		to_feet.y = 0.0
		to_feet = to_feet.normalized()
		var out: Vector3 = exit.global_position - view.global_position
		out.y = 0.0
		out = (out - to_feet * out.dot(to_feet)).normalized()
		var mattress: float = spot.global_position.y
		var floor_y: float = exit.global_position.y
		player.leave_hide_spot()
		# The player is out at once, as ever.
		assert_eq(GameState.get_flag(&"player_bed", 0), 0, "%s: the flag clears at once" % label)
		assert_false(player.is_hidden(), "%s: out at once" % label)
		assert_true(player.global_position.distance_to(exit.global_position) < 0.01, "%s: the player stands at the way out at once" % label)
		assert_false(body.in_bed(), label)
		assert_true(body.getting_up(), "%s: the body is getting up" % label)
		assert_true(player.movement_locked(), "%s: no walking while he gets up" % label)
		assert_false(body.can_handle(spot), "%s: no hand action while he gets up" % label)
		# The view starts where it was in bed.
		assert_true(player.camera.global_position.distance_to(pillow) < 0.03, "%s: the view starts at the pillow (%.3f m off)" % [label, player.camera.global_position.distance_to(pillow)])
		assert_true(player.camera.global_basis.z.dot(looked.z) > 0.99, "%s: looking where it looked" % label)
		var last: Vector3 = player.camera.global_position
		var elapsed: float = 0.0
		var step: float = 0.0
		var under: float = -INF
		var eyes_off: float = 0.0
		var feet_low: float = INF
		var hips_low: float = INF
		var planted: Dictionary = {}
		var slid: float = 0.0
		while body.getting_up() and elapsed < SECONDS + 1.0:
			await tree.physics_frame
			elapsed += delta
			var eye: Vector3 = player.camera.global_position
			step = maxf(step, eye.distance_to(last))
			last = eye
			var beside: float = (eye - pillow).dot(out)
			# Under the upper bunk (its side rail's underside is 0.64 m over the lower mattress).
			if beside < 0.47:
				under = maxf(under, eye.y - mattress)
			if elapsed < SECONDS * 0.8:
				eyes_off = maxf(eyes_off, (body.model.global_transform * body._eye_in_model()).distance_to(eye))
			for foot: String in ["LeftFoot", "RightFoot"]:
				var at: Vector3 = body._bone_world(foot)
				feet_low = minf(feet_low, at.y - floor_y)
				# Standing up (the second half), the feet stay about where they came down.
				if elapsed > SECONDS * 0.65:
					if not planted.has(foot):
						planted[foot] = at
					slid = maxf(slid, Vector2(at.x - planted[foot].x, at.z - planted[foot].z).length())
			var hips: Vector3 = body._bone_world("Hips")
			if (hips - pillow).dot(out) < 0.35:
				hips_low = minf(hips_low, hips.y - mattress)
		assert_true(absf(elapsed - SECONDS) <= delta * 3.0, "%s: up after %.2f s (%.2f)" % [label, SECONDS, elapsed])
		assert_true(step < 0.07, "%s: the view moves without a jump (%.3f m in a tick at most)" % [label, step])
		assert_true(under < 0.58, "%s: the view ducks out under the upper bunk (%.2f m over the mattress at most)" % [label, under])
		assert_true(eyes_off < 0.02, "%s: the view rides his eyes (%.3f m off at most)" % [label, eyes_off])
		assert_true(feet_low > -0.02, "%s: the feet stay over the floor (ankles %.3f m)" % [label, feet_low])
		assert_true(hips_low > -0.12, "%s: over the bed the hips stay on the mattress (%.3f m)" % [label, hips_low])
		# (They shuffle into the idle's stance at the end: it stands with one foot out.)
		assert_true(slid < 0.36, "%s: standing up, the feet stay about where they came down (%.3f m)" % [label, slid])
		# Standing, the player's own view and walking back.
		assert_false(player.movement_locked(), "%s: walking again" % label)
		assert_true(player.head.rotation.is_zero_approx(), "%s: the view level, as the player faces" % label)
		assert_true(player.camera.global_position.distance_to(exit.global_position + Vector3.UP * 1.6) < 0.03, "%s: the view at standing height at the way out" % label)
		await _seconds(0.3)
		assert_true(body._bone_world("Hips").y - floor_y > 0.7, "%s: the body stands" % label)
		assert_true(absf(body.model.rotation.x) < 0.001 and absf(body.model.rotation.z) < 0.001, "%s: upright" % label)
		assert_true((body.model.global_transform * body._eye_in_model()).distance_to(player.camera.global_position) < 0.25, "%s: under the view" % label)
		assert_true(absf(body._yaw) < PlayerBody.TURN_START and not body._turning, "%s: no stepping round after (%.0f degrees off the view)" % [label, rad_to_deg(body._yaw)])
		for foot: String in ["LeftFoot", "RightFoot"]:
			assert_true(absf(body._bone_world(foot).y - floor_y) < 0.2, "%s: %s on the floor" % [label, foot])


func test_an_upper_bunk_and_a_silent_leave_are_at_once() -> void:
	PlayerBody.bed_rise_seconds = SECONDS
	var body: PlayerBody = player.body
	await _lie(1)
	await _seconds(0.5)
	player.leave_hide_spot()
	assert_false(body.getting_up(), "an upper bunk: at once, as before")
	assert_false(player.movement_locked())
	var spot := await _lie(2)
	var exit := spot.get_node(spot.exit) as Node3D
	player.leave_hide_spot(false)
	assert_false(body.getting_up(), "pulled out without a sound: at once")
	assert_false(player.movement_locked())
	assert_true(player.global_position.distance_to(exit.global_position) < 0.01)
	await _seconds(0.2)
	assert_true(body._bone_world("Hips").y - exit.global_position.y > 0.7, "the body stands")


func test_back_into_bed_or_dying_cuts_it_short() -> void:
	PlayerBody.bed_rise_seconds = SECONDS
	var body: PlayerBody = player.body
	var spot := await _lie(3)
	var view := spot.get_node(spot.view) as Node3D
	player.leave_hide_spot()
	await _seconds(0.5)
	assert_true(body.getting_up())
	# Back into the bed (a script lays him down again).
	assert_true(player.enter_hide_spot(spot), "back into bed")
	assert_false(body.getting_up(), "the getting up is over")
	assert_false(player.movement_locked(), "its lock is given back")
	await _seconds(0.2)
	assert_true(body.in_bed())
	assert_true(player.camera.global_position.distance_to(view.global_position) < 0.02, "the view at the pillow again")
	assert_true((body.model.global_transform * body._eye_in_model()).distance_to(player.camera.global_position) < 0.02, "lying with his eyes on the view")
	# Dying on the way up: the view is the player's own again for the death camera.
	player.leave_hide_spot()
	await _seconds(0.5)
	assert_true(body.getting_up())
	EventBus.player_death_started.emit(&"manager")
	assert_false(body.getting_up(), "dying ends it")
	assert_false(player.movement_locked())
	assert_true(player.head.rotation.is_zero_approx(), "the head is the player's own again")
	assert_true(absf(player.head.position.x) < 0.001 and absf(player.head.position.z) < 0.001, "over the player")
