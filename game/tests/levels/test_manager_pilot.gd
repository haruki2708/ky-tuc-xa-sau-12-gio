extends TestCase
## T-219: candidate bodies are tested through the unchanged production manager.

const C: PackedScene = preload("res://scenes/entity/manager_body_c.tscn")
const MANAGER: PackedScene = preload("res://scenes/entity/manager.tscn")
const CLIPS: Array[StringName] = [&"stand", &"walk", &"ask", &"slash", &"lunge", &"kill"]
var world: Node3D

class AudioStub extends Node3D:
	func say(_key: String) -> float:
		return 2.5
	func play_drag(_active: bool) -> void:
		pass
	func play_step() -> void:
		pass
	func play_slash(_material: StringName) -> void:
		pass


func _bodies() -> Array[PackedScene]:
	var result: Array[PackedScene] = [C]
	if ResourceLoader.exists("res://scenes/entity/manager_body_a.tscn"):
		result.append(load("res://scenes/entity/manager_body_a.tscn") as PackedScene)
	return result


func before_each() -> void:
	world = Node3D.new()
	tree.root.add_child(world)


func after_each() -> void:
	world.queue_free()
	await wait_frames(2)


func test_manager_pilot_clips_and_shared_humanoid_paths() -> void:
	var shared: AnimationLibrary = load("res://assets/models/characters/manager/manager_shared.tres")
	for scene: PackedScene in _bodies():
		var body: Node3D = scene.instantiate() as Node3D
		world.add_child(body)
		var player: AnimationPlayer = body.get_node("AnimationPlayer") as AnimationPlayer
		var skeleton: Skeleton3D = body.find_child("GeneralSkeleton", true, false) as Skeleton3D
		assert_not_null(skeleton)
		assert_true(skeleton.motion_scale > 0.5 and skeleton.motion_scale < 1.3)
		assert_eq(player.get_animation_library(&""), shared, "both variants use one library")
		for clip: StringName in CLIPS:
			assert_true(player.has_animation(clip), str(clip))
			var animation: Animation = player.get_animation(clip)
			assert_true(animation.length > 0.0)
			assert_true(animation.get_track_count() > 20, "not a placeholder clip")
			for index: int in animation.get_track_count():
				var path: NodePath = animation.track_get_path(index)
				assert_eq(str(path.get_concatenated_names()), "%GeneralSkeleton")
				assert_true(skeleton.find_bone(path.get_subname(0)) >= 0, str(path))
				assert_true(animation.track_get_type(index) != Animation.TYPE_METHOD, "visual must not drive gameplay")
				if animation.track_get_type(index) == Animation.TYPE_POSITION_3D:
					assert_eq(path.get_subname(0), &"Hips")
					for key: int in animation.track_get_key_count(index):
						var position: Vector3 = animation.track_get_key_value(index, key)
						assert_true(absf(position.x) < 0.0001 and absf(position.z) < 0.0001, "no locomotion root motion")
		assert_true(body.find_children("*", "CollisionObject3D", true, false).is_empty())


func test_manager_pilot_blade_follows_right_hand_during_slash() -> void:
	for scene: PackedScene in _bodies():
		var body: Node3D = scene.instantiate() as Node3D
		world.add_child(body)
		var skeleton: Skeleton3D = body.find_child("GeneralSkeleton", true, false) as Skeleton3D
		var tip: Node3D = body.find_child("BladeTip", true, false) as Node3D
		var attachment: BoneAttachment3D = body.find_child("KnifeAttachment", true, false) as BoneAttachment3D
		var player: AnimationPlayer = body.get_node("AnimationPlayer") as AnimationPlayer
		assert_not_null(tip)
		assert_eq(attachment.bone_name, "RightHand")
		assert_true(attachment.is_ancestor_of(tip))
		var points: Array[Vector3] = []
		for time: float in [0.0, 0.1125, 0.225, 0.3375, 0.4499]:
			player.play(&"slash")
			player.seek(time, true)
			player.pause()
			await wait_frames(2)
			var hand: Transform3D = skeleton.global_transform * skeleton.get_bone_global_pose(skeleton.find_bone("RightHand"))
			assert_true(attachment.global_position.distance_to(hand.origin) < 0.001, "attachment follows the animated bone")
			points.append(tip.global_position)
		var travel: float = 0.0
		for point: Vector3 in points:
			travel = maxf(travel, point.distance_to(points[0]))
		assert_true(travel > 0.25, "slash must actually move the knife")
		assert_true(points[0].distance_to(points[-1]) < 0.02, "repeated slash returns to its starting pose")


func test_manager_pilot_visible_asset_budget() -> void:
	for scene: PackedScene in _bodies():
		var body: Node3D = scene.instantiate() as Node3D
		world.add_child(body)
		var total: int = 0
		var materials: Dictionary = {}
		for mesh: MeshInstance3D in body.find_children("*", "MeshInstance3D", true, false):
			for surface: int in mesh.mesh.get_surface_count():
				var arrays: Array = mesh.mesh.surface_get_arrays(surface)
				var indices: PackedInt32Array = arrays[Mesh.ARRAY_INDEX]
				total += indices.size() / 3 if not indices.is_empty() else (arrays[Mesh.ARRAY_VERTEX] as PackedVector3Array).size() / 3
				var material: Material = mesh.get_active_material(surface)
				materials[material] = true
				if material is BaseMaterial3D:
					for slot: int in BaseMaterial3D.TEXTURE_MAX:
						var texture: Texture2D = material.get_texture(slot)
						if texture:
							assert_true(texture.get_width() <= 2048 and texture.get_height() <= 2048, texture.resource_path)
		assert_true(total <= 25000, "triangles: %d" % total)
		assert_true(materials.size() <= 4, "materials: %d" % materials.size())


func _bone_point(body: Node3D, skeleton: Skeleton3D, bone: StringName, rest: bool = false) -> Vector3:
	var index: int = skeleton.find_bone(bone)
	var transform: Transform3D = skeleton.get_bone_global_rest(index) if rest else skeleton.get_bone_global_pose(index)
	return body.to_local(skeleton.to_global(transform.origin))


func test_manager_pilot_stand_has_upright_knees_and_narrow_stance() -> void:
	for scene: PackedScene in _bodies():
		var body: Node3D = scene.instantiate() as Node3D
		world.add_child(body)
		var skeleton: Skeleton3D = body.find_child("GeneralSkeleton", true, false) as Skeleton3D
		var player: AnimationPlayer = body.get_node("AnimationPlayer") as AnimationPlayer
		var rest_head: float = _bone_point(body, skeleton, &"Head", true).y
		for fraction: float in [0.0, 0.25, 0.5, 0.75, 0.999]:
			player.play(&"stand")
			player.seek(player.get_animation(&"stand").length * fraction, true)
			player.pause()
			await wait_frames(2)
			for side: String in ["Left", "Right"]:
				var hip: Vector3 = _bone_point(body, skeleton, side + "UpperLeg")
				var knee: Vector3 = _bone_point(body, skeleton, side + "LowerLeg")
				var foot: Vector3 = _bone_point(body, skeleton, side + "Foot")
				var angle: float = rad_to_deg((knee - hip).angle_to(foot - knee))
				assert_true(angle <= 10.0, "%s knee %.3f degrees at %.3f" % [side, angle, fraction])
			var spread: float = _bone_point(body, skeleton, &"LeftFoot").distance_to(_bone_point(body, skeleton, &"RightFoot"))
			assert_true(spread <= 0.28, "ankle distance in 3D %.4f m" % spread)
			var drop: float = rest_head - _bone_point(body, skeleton, &"Head").y
			assert_true(drop <= 0.05, "head drop %.4f m" % drop)


func test_manager_pilot_slash_starts_above_shoulder_and_cuts_down_forward() -> void:
	for scene: PackedScene in _bodies():
		var body: Node3D = scene.instantiate() as Node3D
		world.add_child(body)
		var skeleton: Skeleton3D = body.find_child("GeneralSkeleton", true, false) as Skeleton3D
		var player: AnimationPlayer = body.get_node("AnimationPlayer") as AnimationPlayer
		var tip: Node3D = body.find_child("BladeTip", true, false) as Node3D
		for time: float in [0.10, 0.25]:
			player.play(&"slash")
			player.seek(time, true)
			player.pause()
			await wait_frames(2)
			var point: Vector3 = body.to_local(tip.global_position)
			var shoulder: Vector3 = _bone_point(body, skeleton, &"RightUpperArm")
			var chest: Vector3 = _bone_point(body, skeleton, &"Chest")
			print("T219_SLASH phase=%.2f tip=%s shoulder=%s chest=%s" % [time, point, shoulder, chest])
			if time < 0.2:
				assert_true(point.y > shoulder.y, "windup tip must be above right shoulder")
			else:
				assert_true(point.y < chest.y, "contact tip must be below chest")
				assert_true(point.z < chest.z - 0.1, "contact tip must be in front of body (-Z)")


func test_manager_pilot_production_walk_ask_slash_lunge_kill() -> void:
	for scene: PackedScene in _bodies():
		var manager: DormManager = MANAGER.instantiate() as DormManager
		var audio: AudioStub = AudioStub.new()
		world.add_child(audio)
		var target: Node3D = Node3D.new()
		target.position = Vector3(0, 0, -2)
		world.add_child(target)
		manager.body_scene = scene
		manager.audio_rig = audio
		manager.player = target
		world.add_child(manager)
		manager.set_physics_process(false)
		# Test deterministic state timing without reading a user's accessibility settings.
		manager._reduced = false
		var player: AnimationPlayer = manager._model_animation
		assert_not_null(player)
		assert_true(not manager.get_node("Visual/Fallback").visible)
		manager.walk_to(target.position)
		assert_eq(player.current_animation, "walk")
		for frame: int in 5:
			await tree.physics_frame
			manager._physics_process(1.0 / 60.0)
		assert_true(manager.position.z < -0.01, "production root moves with the new body")
		manager.ask("MGR_CH1_ASK_BED_3")
		assert_eq(player.current_animation, "ask")
		var cuts: Array[int] = [0]
		manager.slashed.connect(func(_node: Node3D) -> void: cuts[0] += 1)
		manager.slash(target)
		assert_eq(player.current_animation, "slash")
		assert_true(is_equal_approx(player.get_animation(&"slash").length / player.speed_scale, 0.45))
		for index: int in 6:
			manager._physics_process(0.45)
		assert_eq(cuts[0], 6)
		assert_eq(manager.state, DormManager.State.IDLE)
		manager.kill_player()
		assert_eq(player.current_animation, "lunge")
		manager._physics_process(manager.lunge_seconds)
		assert_eq(manager.state, DormManager.State.KILLING)
		assert_eq(player.current_animation, "kill")
		assert_true(is_equal_approx(player.get_animation(&"kill").length / player.speed_scale, 0.65))
		var caught: Array[StringName] = []
		var on_caught: Callable = func(id: StringName) -> void: caught.append(id)
		EventBus.player_caught.connect(on_caught)
		manager._physics_process(0.65)
		EventBus.player_caught.disconnect(on_caught)
		assert_eq(caught, [&"manager"], "production kill still emits its gameplay outcome")
		assert_eq(manager.state, DormManager.State.IDLE)
		manager.queue_free()
		await wait_frames(2)
