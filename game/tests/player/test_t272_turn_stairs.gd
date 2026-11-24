extends TestCase
## T-272 (D-196): the Mixamo pack's turns on the spot and stairs gait. The turn clips come with
## the turn itself taken out (the model is turned as ever); the body steps round with them, the
## right one for the way it turns. The stairs clips come without their net rise.

const WALKER := preload("res://tests/player/body_walker.gd")

var world: Node3D


func before_each() -> void:
	world = Node3D.new()
	tree.root.add_child(world)


func after_each() -> void:
	world.queue_free()
	await wait_frames(2)


func _seconds(seconds: float) -> void:
	var left: float = seconds
	while left > 0.0:
		await tree.physics_frame
		left -= 1.0 / Engine.physics_ticks_per_second


func _body() -> Array:
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
	var body := PlayerBody.new()
	walker.add_child(body)
	body.bind(walker)
	return [walker, body]


func test_the_pack_holds_turns_without_their_turn_and_stairs_without_their_rise() -> void:
	var library := load(PlayerBody.MX_PATH) as AnimationLibrary
	for clip: StringName in [&"turn_left", &"turn_right"]:
		assert_true(library.has_animation(clip), "missing %s" % clip)
		var animation := library.get_animation(clip)
		assert_eq(animation.loop_mode, Animation.LOOP_LINEAR, "%s loops" % clip)
		var degrees: float = float(animation.get_meta(&"turn_degrees", 0.0))
		assert_true(absf(absf(degrees) - 90.0) < 15.0, "%s was a quarter turn (%.0f degrees)" % [clip, degrees])
		assert_true((degrees > 0.0) == (clip == &"turn_left"), "%s turned its own way" % clip)
		# The hips keep their heading through the clip.
		var hips := animation.find_track(^"%GeneralSkeleton:Hips", Animation.TYPE_ROTATION_3D)
		var widest: float = 0.0
		var first: Vector3 = Basis(animation.rotation_track_interpolate(hips, 0.0)).z
		for step: int in 21:
			var ahead: Vector3 = Basis(animation.rotation_track_interpolate(hips, animation.length * step / 20.0)).z
			widest = maxf(widest, absf(angle_difference(atan2(ahead.x, ahead.z), atan2(first.x, first.z))))
		assert_true(widest < deg_to_rad(4.0), "%s keeps its heading (%.1f degrees)" % [clip, rad_to_deg(widest)])
	for clip: StringName in [&"stairs_up", &"stairs_down"]:
		assert_true(library.has_animation(clip), "missing %s" % clip)
		var animation := library.get_animation(clip)
		var hips := animation.find_track(^"%GeneralSkeleton:Hips", Animation.TYPE_POSITION_3D)
		var rise: float = animation.position_track_interpolate(hips, animation.length).y - animation.position_track_interpolate(hips, 0.0).y
		assert_true(absf(rise) < 0.01, "%s ends at the height it starts at (%.3f)" % [clip, rise])


func test_the_body_steps_round_with_the_turn_of_its_way() -> void:
	assert_true(PlayerBody.mx_turn and PlayerBody.mx_stairs, "on by default (D-196)")
	var made := _body()
	var walker: CharacterBody3D = made[0]
	var body: PlayerBody = made[1]
	await _seconds(0.4)
	for key: StringName in [&"turn_left", &"turn_right", &"stairs_up", &"stairs_down"]:
		assert_true(body.clips.has(key), "the body has %s" % key)
		assert_true(body.eye_points.has(key), "%s is measured" % key)
	var start: float = body.model.global_rotation.y
	walker.rotate_y(deg_to_rad(80.0))
	await _seconds(0.1)
	assert_true(body._turning, "the body steps round")
	assert_eq(body._key, &"turn_left", "to the left: the left turn's steps")
	assert_true(body.animator.speed_scale > 1.0 and body.animator.speed_scale < 2.2, "at the pace of the turn (x%.2f)" % body.animator.speed_scale)
	await _seconds(0.9)
	assert_false(body._turning)
	assert_eq(body._key, &"idle")
	assert_true(absf(angle_difference(body.model.global_rotation.y, start + deg_to_rad(80.0))) < deg_to_rad(3.0), "facing the view again")
	walker.rotate_y(deg_to_rad(-80.0))
	await _seconds(0.1)
	assert_eq(body._key, &"turn_right", "to the right: the right turn's steps")
	# On level ground a walk is a walk (the stand-in walker is never on a slope).
	walker.velocity = walker.global_basis * Vector3(0, 0, -2.2)
	await _seconds(0.5)
	assert_eq(body._key, &"walk")
