extends TestCase
## Short headless scene-jump smoke; never runs the full chapter or renderer.

func test_f9_opens_closes_and_jumps_to_five_real_stages() -> void:
	var root := OS.get_environment("QA_EXPECTED_USER_ROOT")
	assert_false(root.is_empty(), "requires isolated tools/test.ps1 userdata")
	if root.is_empty(): return
	var old_root := OS.get_environment("QA_PLAYTHROUGH_ROOT")
	OS.set_environment("QA_PLAYTHROUGH_ROOT", root)
	var saved_state := GameState.to_dict()
	var old_scene := tree.current_scene
	var old_mouse := Input.mouse_mode
	var old_paused := tree.paused
	tree.current_scene = null
	var menu := preload("res://scripts/debug/ch4_menu.gd").new()
	tree.root.add_child(menu)
	assert_false(menu.available("missing"))
	assert_false(menu.profile.has("routes"), "chapter 4 has no bot routes")
	var previous_id := 0
	for destination in ["split", "library", "return", "room407", "end4"]:
		assert_true(menu.available(destination))
		await menu.jump(destination)
		await wait_frames(2)
		var current := tree.current_scene
		assert_not_null(current)
		if current == null: break
		assert_true(current.get_instance_id() != previous_id, "new scene for each jump")
		previous_id = current.get_instance_id()
		assert_eq(GameState.chapter, 4)
		assert_eq(str(GameState.segment), destination)
		assert_not_null(current.get_node_or_null("Chapter4Director"))
		var key := InputEventKey.new()
		key.keycode = KEY_F9
		key.pressed = true
		menu._input(key)
		assert_true(menu.panel.visible)
		assert_true(tree.paused)
		menu._input(key)
		assert_false(menu.panel.visible)
		assert_false(tree.paused)
	if tree.current_scene != null:
		tree.current_scene.queue_free()
		tree.current_scene = null
	await wait_frames(2)
	menu.free()
	tree.current_scene = old_scene
	tree.paused = old_paused
	Input.mouse_mode = old_mouse
	OS.set_environment("QA_PLAYTHROUGH_ROOT", old_root)
	RuleSystem.reset()
	# reset() preserves the chapter; restore it so later UI tests keep their mode.
	GameState.from_dict(saved_state)


class LaunchProbe extends "res://scripts/debug/ch4_menu.gd":
	var launched: String = ""
	func _launch(destination: String) -> void:
		launched = destination


func test_unisolated_jump_requests_child_without_mutating_story() -> void:
	var old_root := OS.get_environment("QA_PLAYTHROUGH_ROOT")
	OS.set_environment("QA_PLAYTHROUGH_ROOT", "")
	var state := GameState.to_dict()
	var current := tree.current_scene
	var menu := LaunchProbe.new()
	tree.root.add_child(menu)
	await menu.jump("library")
	assert_eq(menu.launched, "library")
	assert_eq(GameState.to_dict(), state)
	assert_eq(tree.current_scene, current)
	menu.launched = ""
	menu.profile.jumps.library = "invalid"
	await menu.jump("library")
	assert_eq(menu.launched, "")
	menu.free()
	OS.set_environment("QA_PLAYTHROUGH_ROOT", old_root)
