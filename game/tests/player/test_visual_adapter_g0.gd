extends TestCase
## Exercise the existing actor boundary without wiring a prototype into gameplay.

const ACTOR: PackedScene = preload("res://scenes/entity/companion.tscn")
const VISUAL: PackedScene = preload("res://scenes/entity/visual_adapter_g0.tscn")
const AdapterScript = preload("res://scripts/entity/visual_adapter_g0.gd")

var actor: Ch3Actor


func before_each() -> void:
	actor = ACTOR.instantiate() as Ch3Actor
	actor.position = Vector3(4, 2, -3)
	actor.rotation.y = 0.7
	tree.root.add_child(actor)
	actor.set_physics_process(false)
	actor.set_body(VISUAL)


func after_each() -> void:
	tree.paused = false
	actor.queue_free()
	await wait_frames(2)


func test_existing_poses_move_head_without_moving_gameplay_root() -> void:
	var start: Transform3D = actor.global_transform
	var collider: CollisionShape3D = actor.get_node("CollisionShape3D")
	var collider_start: Transform3D = collider.global_transform
	var shape: Shape3D = collider.shape
	var navigation: NavigationAgent3D = actor.navigation
	var navigation_start: Array = [navigation.radius, navigation.height,
		navigation.path_desired_distance, navigation.target_desired_distance,
		navigation.target_position, navigation.avoidance_enabled]
	var adapter: AdapterScript = actor.model as AdapterScript
	var body: Node3D = adapter.get_node("Body")
	var head: Node3D = adapter.get_node(adapter.head_path)
	var standing: Vector3 = actor.head_position()
	for value: StringName in [&"idle", &"walk", &"sit", &"lie", &"wake", &"stunned", &"grab"]:
		actor.play_pose(value)
		body.call("_process", 0.25)
		assert_eq(adapter.last_issue, "", "existing campus pose must be accepted")
		assert_eq(actor.global_transform, start, "visual cannot drive world movement")
		assert_eq(collider.global_transform, collider_start)
		assert_eq(collider.shape, shape)
		assert_eq(actor.navigation, navigation)
		assert_eq([navigation.radius, navigation.height,
			navigation.path_desired_distance, navigation.target_desired_distance,
			navigation.target_position, navigation.avoidance_enabled], navigation_start)
		assert_eq(actor.collision_layer, 1)
		assert_eq(actor.collision_mask, 1)
		assert_true(actor.head_position().is_equal_approx(head.global_position))
		if value in [&"sit", &"lie"]:
			assert_true(actor.head_position().distance_to(standing) > 0.2)
		print("T208_G0_HEAD %s actor_local=%s" % [value, actor.to_local(head.global_position)])


func test_visual_offsets_and_head_motion_follow_rotated_actor() -> void:
	var start: Transform3D = actor.global_transform
	var adapter: AdapterScript = actor.model as AdapterScript
	adapter.position = Vector3(0.1, 0.2, -0.15)
	adapter.rotation.y = -0.3
	var head: Node3D = adapter.get_node(adapter.head_path)
	var before: Vector3 = actor.head_position()
	head.position += Vector3(0.07, 0.03, -0.02)
	assert_true(actor.head_position().is_equal_approx(head.global_position))
	assert_true(actor.head_position().distance_to(before) > 0.01)
	assert_eq(actor.global_transform, start)


func test_missing_marker_pose_and_visual_collision_are_reported() -> void:
	var adapter: AdapterScript = actor.model as AdapterScript
	assert_true(adapter.binding_issues().is_empty())
	actor.play_pose(&"warn")
	assert_eq(adapter.last_issue, "pose_unsupported:warn", "known guard/campus mismatch must be visible")
	assert_eq(adapter.get_node("Body").get("pose"), &"idle", "missing pose must not silently alias")
	adapter.head_path = ^"Body/MissingHead"
	assert_false(adapter.set_pose(&"walk"))
	assert_true(adapter.binding_issues().has("head_missing_or_outside_body"))
	adapter.head_path = ^"Body/Model/Rig/Hips/Chest/Head"
	var unwanted: Area3D = Area3D.new()
	adapter.add_child(unwanted)
	assert_false(adapter.set_pose(&"walk"))
	assert_true(adapter.binding_issues().has("visual_contains_collision"))


func test_actor_replacement_and_null_restore_fallback_after_deferred_free() -> void:
	var start: Transform3D = actor.global_transform
	actor.play_pose(&"sit")
	var old_model: WeakRef = weakref(actor.model)
	actor.set_body(VISUAL)
	actor.set_body(VISUAL)
	await wait_frames(2)
	assert_eq(old_model.get_ref(), null)
	assert_eq(actor.visual.get_child_count(), 2, "one fallback plus one model after queued frees")
	assert_eq(actor.model.get_node("Body").get("pose"), &"sit")
	assert_false(actor.get_node("Visual/Fallback").visible)
	actor.set_body(null)
	await wait_frames(2)
	assert_eq(actor.visual.get_child_count(), 1)
	assert_eq(actor.model, null)
	assert_true(actor.get_node("Visual/Fallback").visible)
	var fallback: Node3D = actor.get_node("Visual/Fallback/Head")
	assert_eq(actor.head_position(), fallback.global_position)
	assert_eq(actor.global_transform, start)


func test_pause_and_fresh_scene_reset_existing_visual() -> void:
	actor.play_pose(&"walk")
	await wait_frames(3)
	var body: Node3D = actor.model.get_node("Body")
	var elapsed: float = float(body.get("_time"))
	tree.paused = true
	await wait_frames(3)
	assert_eq(float(body.get("_time")), elapsed, "visual inherits gameplay pause")
	tree.paused = false
	await wait_frames(3)
	assert_true(float(body.get("_time")) > elapsed)
	actor.free()
	actor = ACTOR.instantiate() as Ch3Actor
	actor.body_scene = VISUAL
	tree.root.add_child(actor)
	actor.set_physics_process(false)
	assert_eq(actor.pose, &"idle")
	assert_eq(actor.model.get_node("Body").get("pose"), &"idle")
	assert_eq(float(actor.model.get_node("Body").get("_time")), 0.0)
	assert_eq(actor.visual.get_child_count(), 2)
