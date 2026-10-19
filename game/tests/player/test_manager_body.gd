extends TestCase
## T-219 (D-118, D-120): the Tripo manager body meets DormManager's body_scene contract and the card budget.

const BODY: PackedScene = preload("res://scenes/entity/manager_body.tscn")
const MANAGER: PackedScene = preload("res://scenes/entity/manager.tscn")
const CLIPS: Array[StringName] = [&"stand", &"walk", &"ask", &"slash", &"lunge", &"kill"]

var world: Node3D
var caught: Array[StringName] = []


func before_each() -> void:
	world = Node3D.new()
	tree.root.add_child(world)
	caught.clear()
	EventBus.player_caught.connect(_on_caught)


func after_each() -> void:
	EventBus.player_caught.disconnect(_on_caught)
	world.queue_free()
	await wait_frames(2)


func _on_caught(id: StringName) -> void:
	caught.append(id)


func _body() -> Node3D:
	var body: Node3D = BODY.instantiate() as Node3D
	world.add_child(body)
	return body


func _pose(player: AnimationPlayer, clip: StringName, time: float) -> void:
	player.play(clip)
	player.seek(time, true)
	await tree.process_frame


func test_body_has_the_six_game_clips_and_loops_the_steady_ones() -> void:
	var player: AnimationPlayer = _body().find_children("*", "AnimationPlayer", true, false)[0] as AnimationPlayer
	for clip: StringName in CLIPS:
		assert_true(player.has_animation(clip), "missing clip %s" % clip)
	for clip: StringName in [&"stand", &"walk", &"ask", &"lunge"]:
		assert_eq(player.get_animation(clip).loop_mode, Animation.LOOP_LINEAR, "%s loops" % clip)
	for clip: StringName in [&"slash", &"kill"]:
		assert_eq(player.get_animation(clip).loop_mode, Animation.LOOP_NONE, "%s plays once per call" % clip)


func test_standing_manager_is_life_size_and_faces_minus_z() -> void:
	var body: Node3D = _body()
	var player: AnimationPlayer = body.find_children("*", "AnimationPlayer", true, false)[0] as AnimationPlayer
	var skeleton: Skeleton3D = body.find_children("*", "Skeleton3D", true, false)[0] as Skeleton3D
	await _pose(player, &"stand", 0.0)
	var top: Vector3 = (skeleton.global_transform * skeleton.get_bone_global_pose(skeleton.find_bone("mixamorig_HeadTop_End"))).origin
	var toe: Vector3 = (skeleton.global_transform * skeleton.get_bone_global_pose(skeleton.find_bone("mixamorig_LeftToe_End"))).origin
	assert_true(absf(top.y - 1.70) < 0.03, "crown at 1.70 m, got %.3f" % top.y)
	assert_true(absf(toe.y) < 0.05, "feet on the floor, got %.3f" % toe.y)
	assert_true(toe.z < -0.05, "toes point down -Z, got %.3f" % toe.z)


func test_blade_tip_rises_over_the_head_then_cuts_down_in_front() -> void:
	var body: Node3D = _body()
	var player: AnimationPlayer = body.find_children("*", "AnimationPlayer", true, false)[0] as AnimationPlayer
	var tip: Node3D = body.find_child("BladeTip", true, false) as Node3D
	assert_not_null(tip)
	await _pose(player, &"slash", 0.62)
	assert_true(tip.global_position.y > 1.5, "windup lifts the cleaver over the head, got %.2f" % tip.global_position.y)
	await _pose(player, &"slash", 1.0)
	assert_true(tip.global_position.y < 0.9, "the chop ends low, got %.2f" % tip.global_position.y)
	assert_true(tip.global_position.z < -0.3, "the chop lands in front, got %.2f" % tip.global_position.z)


func test_body_stays_within_the_card_budget() -> void:
	var triangles: int = 0
	var materials: Array[Material] = []
	for node: Node in _body().find_children("*", "MeshInstance3D", true, false):
		var mesh_instance: MeshInstance3D = node as MeshInstance3D
		for surface: int in mesh_instance.mesh.get_surface_count():
			triangles += mesh_instance.mesh.surface_get_array_index_len(surface) / 3
			var material: Material = mesh_instance.get_active_material(surface)
			if material != null and not materials.has(material):
				materials.append(material)
	assert_true(triangles <= 25000, "triangles %d" % triangles)
	assert_true(materials.size() <= 4, "materials %d" % materials.size())
	for material: Material in materials:
		var standard: BaseMaterial3D = material as BaseMaterial3D
		if standard == null:
			continue
		for texture: Texture2D in [standard.albedo_texture, standard.normal_texture, standard.roughness_texture, standard.metallic_texture]:
			if texture != null:
				assert_true(texture.get_width() <= 2048 and texture.get_height() <= 2048, "texture %dx%d" % [texture.get_width(), texture.get_height()])


func test_dorm_manager_walks_asks_slashes_and_kills_with_the_tripo_body() -> void:
	var floor_body: StaticBody3D = StaticBody3D.new()
	var shape: CollisionShape3D = CollisionShape3D.new()
	shape.shape = BoxShape3D.new()
	(shape.shape as BoxShape3D).size = Vector3(40, 0.2, 40)
	floor_body.add_child(shape)
	floor_body.position.y = -0.1
	world.add_child(floor_body)
	var target: Node3D = Node3D.new()
	target.position = Vector3(0, 0.02, -1)
	world.add_child(target)
	var manager: DormManager = MANAGER.instantiate() as DormManager
	manager.body_scene = BODY
	manager.player = target
	manager.position.y = 0.02
	manager.slash_interval = 0.05
	world.add_child(manager)
	assert_false(manager.get_node("Visual/Fallback").visible)
	# manager.tscn keeps its own hidden fallback BladeTip; the director must use the body's.
	assert_eq(manager._blade_tip, manager.find_child("ManagerBody", true, false).find_child("BladeTip", true, false))
	manager.walk_to(Vector3(0, 0, -2))
	await wait_frames(3)
	assert_eq(manager._model_animation.current_animation, &"walk")
	manager.ask("MGR_CH1_ASK_BED_3")
	assert_eq(manager._model_animation.current_animation, &"ask")
	var cuts: Array[Node3D] = []
	manager.slashed.connect(func(node: Node3D) -> void: cuts.append(node))
	manager.slash(target)
	assert_eq(manager._model_animation.current_animation, &"slash")
	for index: int in 30:
		await tree.physics_frame
	assert_eq(cuts.size(), 6)
	manager.kill_player()
	for index: int in 70:
		await tree.physics_frame
	assert_eq(caught, [&"manager"])


func test_left_arm_reaches_forward_for_the_door() -> void:
	var manager: DormManager = MANAGER.instantiate() as DormManager
	manager.body_scene = BODY
	world.add_child(manager)
	var body: Node3D = manager.find_child("ManagerBody", true, false) as Node3D
	var reach: Node3D = body.find_child("LeftArm", true, false) as Node3D
	assert_eq(manager._reach_arm, reach, "open_door drives the body's arm, not the hidden fallback")
	var skeleton: Skeleton3D = body.find_children("*", "Skeleton3D", true, false)[0] as Skeleton3D
	var hand: BoneAttachment3D = BoneAttachment3D.new()
	hand.bone_name = "mixamorig_LeftHand"
	skeleton.add_child(hand)
	manager._model_animation.pause()
	await wait_frames(2)
	var rest: Vector3 = hand.global_position
	reach.rotation.x = PI * 0.45
	await wait_frames(2)
	var lifted: Vector3 = hand.global_position
	assert_true(lifted.z < rest.z - 0.25, "hand reaches forward (-Z): %.2f -> %.2f" % [rest.z, lifted.z])
	assert_true(lifted.y > rest.y + 0.15, "hand rises toward a door handle: %.2f -> %.2f" % [rest.y, lifted.y])
	assert_true(lifted.y > 0.8 and lifted.y < 1.3, "hand at handle height, got %.2f" % lifted.y)


func test_dorm_manager_cross_fades_clips_but_restarts_each_chop() -> void:
	var manager: DormManager = MANAGER.instantiate() as DormManager
	manager.body_scene = BODY
	world.add_child(manager)
	var player: AnimationPlayer = manager._model_animation
	await wait_frames(3)
	var breath: float = player.current_animation_position
	assert_true(breath > 0.0)
	manager._play_animation(&"stand")
	assert_eq(player.current_animation_position, breath, "a looping clip already playing carries on")
	var skeleton: Skeleton3D = player.get_parent().find_children("*", "Skeleton3D", true, false)[0] as Skeleton3D
	var hand: int = skeleton.find_bone("mixamorig_RightHand")
	manager._play_animation(&"slash", 0.45)
	player.advance(0.05)
	var blended: Vector3 = skeleton.get_bone_global_pose(hand).origin
	var time: float = player.current_animation_position
	player.stop()
	player.play(&"slash")
	player.seek(time, true)
	var pure: Vector3 = skeleton.get_bone_global_pose(hand).origin
	assert_true(blended.distance_to(pure) > 0.03, "50 ms into a 0.2 s fade the knife hand is still between clips")
	player.advance(0.2)
	manager._play_animation(&"slash", 0.45)
	assert_eq(player.current_animation_position, 0.0, "the next chop starts over at once")
