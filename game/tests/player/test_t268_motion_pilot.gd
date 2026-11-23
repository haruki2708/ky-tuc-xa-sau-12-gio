extends TestCase
## T-268 (D-189, approved D-190), T-269: the Mixamo clips packed by art_source/graphics_upgrade/mixamo/,
## on by default. Tran Trung stands, walks and runs on them, walking back and sideways on clips of
## their own, facing ahead, with planted feet; the manager's walk keeps its feet's pace. With the
## flags at &"" both keep their Tripo clips.

const WALKER := preload("res://tests/player/body_walker.gd")
const MANAGER_BODY: PackedScene = preload("res://scenes/entity/manager_body.tscn")
const MANAGER: PackedScene = preload("res://scenes/entity/manager.tscn")
const TRUNG_CLIPS: Array[StringName] = [&"idle", &"idle_breathing", &"walk_fwd", &"walk_back", &"walk_left", &"walk_right"]

var world: Node3D


func before_each() -> void:
	world = Node3D.new()
	tree.root.add_child(world)


func after_each() -> void:
	PlayerBody.motion = PlayerBody.MX_MOTION
	PlayerBody.mx_idle = &"idle"
	PlayerBody.mx_run = &"run"
	PlayerBody.mx_crouch = false
	ManagerBody.motion = ManagerBody.MX_MOTION
	world.queue_free()
	await wait_frames(2)


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


func _attach(body: PlayerBody, bone: String) -> BoneAttachment3D:
	var attachment := BoneAttachment3D.new()
	attachment.bone_name = bone
	body.skeleton.add_child(attachment)
	return attachment


func test_mixamo_clips_are_on_by_default() -> void:
	assert_eq(PlayerBody.motion, PlayerBody.MX_MOTION, "D-190")
	assert_eq(ManagerBody.motion, ManagerBody.MX_MOTION, "D-190")
	var body := _body(_walker())
	await wait_frames(1)
	assert_eq(body.clips[&"idle"], &"mx/idle", "Neutral Idle (D-190)")
	assert_eq(body.clips[&"run"], &"mx/run", "Standard Run (T-269)")
	assert_eq(body.clips[&"crouch_walk"], PlayerBody.CLIPS[&"crouch_walk"], "crouching keeps its clips (too tall for the crouched camera)")
	var manager := MANAGER_BODY.instantiate() as Node3D
	world.add_child(manager)
	var player := manager.find_children("*", "AnimationPlayer", true, false)[0] as AnimationPlayer
	assert_true(player.get_animation(&"walk").has_meta(&"stride_speed"), "the manager walks on the packed walk")


func test_flags_off_keep_the_tripo_clips() -> void:
	PlayerBody.motion = &""
	ManagerBody.motion = &""
	var body := _body(_walker())
	await wait_frames(1)
	assert_eq(body.clips, PlayerBody.CLIPS, "Tran Trung keeps his clips")
	assert_false(body.animator.has_animation_library(PlayerBody.MX_MOTION), "no Mixamo library")
	var manager := MANAGER_BODY.instantiate() as Node3D
	world.add_child(manager)
	var player := manager.find_children("*", "AnimationPlayer", true, false)[0] as AnimationPlayer
	assert_false(player.get_animation(&"walk").has_meta(&"stride_speed"), "the manager keeps his Tripo walk")


func test_trung_library_holds_humanoid_tracks_only() -> void:
	var library := load(PlayerBody.MX_PATH) as AnimationLibrary
	assert_not_null(library, "packed library loads")
	for clip: StringName in TRUNG_CLIPS:
		assert_true(library.has_animation(clip), "missing %s" % clip)
		var animation := library.get_animation(clip)
		assert_eq(animation.loop_mode, Animation.LOOP_LINEAR, "%s loops" % clip)
		for track: int in animation.get_track_count():
			var path := String(animation.track_get_path(track))
			assert_true(path.begins_with("%GeneralSkeleton:"), "%s: %s is on the humanoid skeleton" % [clip, path])
			if animation.track_get_type(track) == Animation.TYPE_POSITION_3D:
				assert_eq(path, "%GeneralSkeleton:Hips", "%s: only the hips move" % clip)


func test_manager_library_drives_his_own_bones() -> void:
	var library := load(ManagerBody.MX_PATH) as AnimationLibrary
	assert_not_null(library, "packed library loads")
	var body := MANAGER_BODY.instantiate() as Node3D
	world.add_child(body)
	var skeleton := body.find_children("*", "Skeleton3D", true, false)[0] as Skeleton3D
	for clip: StringName in [&"walk", &"slash"]:
		assert_true(library.has_animation(clip), "missing %s" % clip)
		var animation := library.get_animation(clip)
		for track: int in animation.get_track_count():
			var path := animation.track_get_path(track)
			assert_eq(String(path).get_slice(":", 0), "Armature/Skeleton3D", "%s: %s is on his skeleton" % [clip, path])
			assert_true(skeleton.find_bone(String(path).get_slice(":", 1)) >= 0, "%s: bone of %s exists" % [clip, path])
	var stride: float = float(library.get_animation(&"walk").get_meta(&"stride_speed", 0.0))
	assert_true(stride > 0.5 and stride < 1.6, "the walk's feet go %.2f m/s" % stride)


func test_pilot_measures_its_own_back_and_sideways_strides() -> void:
	PlayerBody.motion = PlayerBody.MX_MOTION
	var body := _body(_walker())
	await wait_frames(1)
	assert_eq(body.clips[&"walk"], &"mx/walk_fwd")
	assert_eq(body.clips[&"idle"], &"mx/idle")
	assert_eq(body.clips[&"crouch_idle"], PlayerBody.CLIPS[&"crouch_idle"], "crouching keeps its clip")
	for key: StringName in [&"walk", &"walk_back", &"walk_left", &"walk_right", &"run"]:
		var stride: float = body.stride_speeds[key]
		# _measure falls back to 1.0 x the model's scale when it finds no planted step.
		assert_true(stride > 0.5 and stride < 4.5 and not is_equal_approx(stride, body._scale()), "%s stride %.3f m/s" % [key, stride])
		assert_true(body.eye_points.has(key), "%s has an eye point" % key)
	# The run plays close to its own pace at sprint speed (T-269).
	assert_true(absf(3.6 / body.stride_speeds[&"run"] - 1.0) < 0.15, "run x%.2f" % (3.6 / body.stride_speeds[&"run"]))
	assert_eq(PlayerBody.CLIPS[&"idle"], &"idle", "the shared table is untouched")
	assert_eq(body.animator.get_animation(&"idle").loop_mode, Animation.LOOP_PINGPONG, "the Tripo idle under hand actions still pingpongs")
	assert_eq(body.animator.get_animation(body.clips[&"idle"]).loop_mode, Animation.LOOP_LINEAR, "the pilot's idle keeps its packed loop")


func test_pilot_keeps_the_tripo_clips_when_the_idle_is_missing() -> void:
	PlayerBody.motion = PlayerBody.MX_MOTION
	PlayerBody.mx_idle = &"no_such_idle"
	var body := _body(_walker())
	await wait_frames(1)
	assert_eq(body.clips, PlayerBody.CLIPS, "a mistyped idle falls back to the Tripo clips")
	assert_true(body.eye_points.has(&"idle") and body.stride_speeds.has(&"walk"), "the body still measured its clips")


func _walk(walker: CharacterBody3D, velocity: Vector3, seconds: float) -> void:
	var delta: float = 1.0 / Engine.physics_ticks_per_second
	walker.velocity = velocity
	for frame: int in int(seconds / delta):
		walker.position += walker.velocity * delta
		await tree.physics_frame


func test_pilot_walks_back_and_sideways_facing_ahead() -> void:
	PlayerBody.motion = PlayerBody.MX_MOTION
	var walker := _walker()
	var body := _body(walker)
	await _seconds(0.2)
	# The walker looks down -Z: -X is his left.
	for case: Array in [[Vector3(-2.2, 0, 0), &"walk_left"], [Vector3(2.2, 0, 0), &"walk_right"], [Vector3(0, 0, 2.2), &"walk_back"]]:
		await _walk(walker, case[0], 0.8)
		assert_eq(body.get("_key"), case[1], "moving %s plays %s" % [case[0], case[1]])
		assert_true(absf(float(body.get("_yaw"))) < deg_to_rad(5.0), "%s faces ahead, yaw %.1f deg" % [case[1], rad_to_deg(float(body.get("_yaw")))])
		assert_true(body.animator.speed_scale > 0.0, "%s plays forwards" % case[1])
	# A keyboard diagonal stays a forward walk, turned toward it as before.
	await _walk(walker, Vector3(-1.556, 0, -1.556), 0.8)
	assert_eq(body.get("_key"), &"walk", "a diagonal walks forwards")
	assert_true(absf(float(body.get("_yaw")) - deg_to_rad(45.0)) < deg_to_rad(5.0), "turned toward the diagonal")


func test_pilot_planted_feet_do_not_slide() -> void:
	PlayerBody.motion = PlayerBody.MX_MOTION
	var walker := _walker()
	var body := _body(walker)
	var foot := _attach(body, "LeftFoot")
	var toes := _attach(body, "LeftToes")
	await _seconds(0.2)
	var delta: float = 1.0 / Engine.physics_ticks_per_second
	for velocity: Vector3 in [Vector3(0, 0, -2.2), Vector3(0, 0, 2.2), Vector3(-2.2, 0, 0), Vector3(2.2, 0, 0)]:
		var points: Array[Vector3] = []
		var toe_heights: Array[float] = []
		walker.velocity = velocity
		for frame: int in int(2.4 / delta):
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
		assert_true(runs >= 2, "%s: saw %d planted steps" % [velocity, runs])
		assert_true(worst < 0.04, "%s (%s): a planted foot slid %.3f m" % [velocity, body.get("_key"), worst])


func test_manager_pilot_walks_at_his_feet_pace() -> void:
	ManagerBody.motion = ManagerBody.MX_MOTION
	var target: Node3D = Node3D.new()
	world.add_child(target)
	var manager: DormManager = MANAGER.instantiate() as DormManager
	manager.body_scene = MANAGER_BODY
	manager.player = target
	manager.speed = 1.3
	world.add_child(manager)
	manager.walk_to(Vector3(0, 0, -3))
	await wait_frames(3)
	var animation := manager._model_animation
	assert_eq(animation.current_animation, &"walk")
	var stride: float = float(animation.get_animation(&"walk").get_meta(&"stride_speed"))
	assert_true(absf(animation.get_playing_speed() - 1.3 / stride) < 0.01,
		"the walk plays at 1.3 m/s over its %.3f m/s stride: x%.3f" % [stride, animation.get_playing_speed()])
	# A body never added to the tree has not run _ready: its library is the imported (Tripo) one.
	var plain := MANAGER_BODY.instantiate() as Node3D
	var tripo := plain.find_children("*", "AnimationPlayer", true, false)[0] as AnimationPlayer
	for clip: StringName in [&"stand", &"ask", &"lunge", &"kill"]:
		assert_true(animation.get_animation(clip) == tripo.get_animation(clip), "%s stays Tripo's" % clip)
	assert_false(animation.get_animation(&"slash") == tripo.get_animation(&"slash"), "slash is the pilot's")
	plain.free()
