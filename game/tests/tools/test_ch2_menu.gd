extends TestCase
## Short headless scene-jump smoke; never runs the full chapter or renderer.

func test_f9_opens_closes_and_jumps_to_real_rounds() -> void:
	var root := OS.get_environment("QA_EXPECTED_USER_ROOT")
	assert_false(root.is_empty(), "requires isolated tools/test.ps1 userdata")
	if root.is_empty(): return
	var old_root := OS.get_environment("QA_PLAYTHROUGH_ROOT")
	OS.set_environment("QA_PLAYTHROUGH_ROOT", root)
	var old_scene := tree.current_scene
	var old_mouse := Input.mouse_mode
	var old_paused := tree.paused
	tree.current_scene = null
	var menu := preload("res://scripts/debug/ch2_menu.gd").new()
	tree.root.add_child(menu)
	var previous_id := 0
	for destination in ["r3", "r4"]:
		assert_true(menu.available(destination))
		await menu.jump(destination)
		await wait_frames(2)
		var current := tree.current_scene
		assert_not_null(current)
		if current == null: break
		assert_true(current.get_instance_id() != previous_id, "new scene for each jump")
		previous_id = current.get_instance_id()
		assert_eq(GameState.chapter, 2)
		assert_eq(str(GameState.segment), destination)
		assert_not_null(current.get_node_or_null("Chapter2Director"))
		var key := InputEventKey.new()
		key.keycode = KEY_F9
		key.pressed = true
		menu._input(key)
		assert_true(menu.panel.visible)
		assert_true(tree.paused)
		menu._input(key)
		assert_false(menu.panel.visible)
		assert_false(tree.paused)
		# Independent answers use the new typed-word observer, including raw text.
		EventBus.chain_word_spoken.emit(&"dat", "văn học")
		EventBus.chain_input_requested.emit(15.0)
		menu.set_open(true)
		menu.answers.show()
		menu._process(0.0)
		assert_true(menu.answers.text.contains(menu.observer.recommendation().word))
		menu.set_open(false)
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
	GameState.reset()
