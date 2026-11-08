extends TestCase
## T-227 round 2 (D-146): with a body, into a bed in one second (lying down; climbing to an upper
## bunk), getting up in one and a half, the body propped along the bed with its eyes on the camera;
## the bed flag changes when each starts. Without a body, as before. Real room 407, story stopped.

const PlayerScript = preload("res://scripts/player/player.gd")
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


func after_each() -> void:
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
	await tree.create_timer(seconds, true, true).timeout


func _beside(spot: HideSpot) -> Node3D:
	var exit := spot.get_node(spot.exit) as Node3D
	player.global_transform = exit.global_transform
	player.head.position = PlayerScript.STAND_HEAD
	return exit


## The body lies along the bed toward the feet, propped up, on the mattress, its eyes on the camera.
func _check_lying(body: PlayerBody, spot: HideSpot, label: String) -> void:
	assert_true(body.visible, "%s: the body shows in bed" % label)
	assert_eq(body._bed_phase, &"rest", label)
	var camera: Vector3 = player.camera.global_position
	assert_true((body.model.global_transform * body._eye_in_model()).distance_to(camera) < 0.02, "%s: eyes on the camera" % label)
	assert_true(body._head_attach.global_position.distance_to(camera) < 0.2, "%s: the head at the camera" % label)
	var hips: Vector3 = body._bone_world("Hips")
	var down: Vector3 = -(spot.get_node(spot.view) as Node3D).global_basis.z
	var along: Vector2 = Vector2(hips.x - camera.x, hips.z - camera.z).normalized()
	assert_true(along.dot(Vector2(down.x, down.z).normalized()) > 0.8, "%s: hips down the bed" % label)
	assert_true(hips.y < camera.y - 0.2, "%s: propped, not standing: hips %.2f, eyes %.2f" % [label, hips.y, camera.y])
	assert_true(hips.y > spot.global_position.y - 0.15, "%s: on the mattress: hips %.2f, mattress %.2f" % [label, hips.y, spot.global_position.y])


func test_with_a_body_lying_down_takes_a_second_and_getting_up_one_and_a_half() -> void:
	player.set_body(PlayerBody.new())
	await _seconds(0.3)
	var body: PlayerBody = player.body
	var spot: HideSpot = director._bunks[2]
	var view := spot.get_node(spot.view) as Node3D
	var exit := _beside(spot)
	assert_true(player.enter_hide_spot(spot))
	assert_eq(GameState.get_flag(&"player_bed", 0), 2, "the bed flag at once")
	assert_true(body.in_bed())
	await _seconds(0.5)
	assert_true(player.global_position.distance_to(view.global_position) > 0.05, "still lying down at half a second")
	await _seconds(0.6)
	assert_true(player.global_position.distance_to(view.global_position) < 0.01, "in bed after a second")
	_check_lying(body, spot, "lower bunk")
	player.leave_hide_spot(true, true)
	assert_eq(GameState.get_flag(&"player_bed", 0), 0, "the flag clears at once")
	assert_false(player.is_hidden())
	assert_true(player.movement_locked(), "not walking while getting up")
	await _seconds(1.0)
	assert_eq(body._bed_phase, &"up", "still getting up at one second")
	await _seconds(0.7)
	assert_false(body.in_bed())
	assert_false(player.movement_locked(), "free once up")
	assert_true(player.global_position.distance_to(exit.global_position) < 0.01, "standing at the bed's exit")
	assert_true(player.head.position.is_equal_approx(PlayerScript.STAND_HEAD), "eyes at standing height")
	assert_true(body._bone_world("Hips").y - exit.global_position.y > 0.7, "the body stands")


func test_with_a_body_an_upper_bunk_is_climbed_into_over_a_second() -> void:
	player.set_body(PlayerBody.new())
	await _seconds(0.3)
	var body: PlayerBody = player.body
	var spot: HideSpot = director._bunks[1]
	var view := spot.get_node(spot.view) as Node3D
	_beside(spot)
	assert_true(player.enter_hide_spot(spot))
	assert_true(body._bed_climb, "an upper bunk is climbed")
	await _seconds(1.1)
	assert_true(player.global_position.distance_to(view.global_position) < 0.01, "up after a second")
	_check_lying(body, spot, "upper bunk")
	player.leave_hide_spot(false)
	assert_false(body.in_bed(), "pulled out: at once")
	assert_false(player.movement_locked())


func test_without_a_body_bed_timing_is_unchanged() -> void:
	var spot: HideSpot = director._bunks[2]
	var view := spot.get_node(spot.view) as Node3D
	var exit := _beside(spot)
	assert_true(player.enter_hide_spot(spot))
	assert_true(player.global_position.distance_to(view.global_position) < 0.01, "a lower bunk at once")
	player.leave_hide_spot(true, true)
	assert_true(player.global_position.distance_to(exit.global_position) < 0.01, "out at once")
	assert_false(player.movement_locked())
