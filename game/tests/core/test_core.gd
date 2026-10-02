extends TestCase
## Smoke tests for the project skeleton.


func test_input_actions_registered() -> void:
	for action in ["move_forward", "move_back", "move_left", "move_right", "interact", "pause"]:
		assert_true(InputMap.has_action(action), "missing input action " + action)


func test_autoloads_present() -> void:
	assert_not_null(tree.root.get_node_or_null("GameInput"), "GameInput autoload")
	assert_not_null(tree.root.get_node_or_null("EventBus"), "EventBus autoload")
	for autoload in ["Settings", "GameState", "RuleSystem"]:
		assert_not_null(tree.root.get_node_or_null(autoload), autoload + " autoload")
	for sig in ["interaction_focus_changed", "interacted", "subtitle_requested", "game_paused", "settings_changed"]:
		assert_true(EventBus.has_signal(sig), "EventBus signal " + sig)


func test_main_scene_loads() -> void:
	var path: String = ProjectSettings.get_setting("application/run/main_scene")
	var scene: PackedScene = load(path)
	assert_not_null(scene, "main scene loads")
	var inst := scene.instantiate()
	tree.root.add_child(inst)
	await wait_frames(2)
	assert_true(inst.is_inside_tree(), "main scene enters tree")
	inst.queue_free()
	await wait_frames(1)


func test_interactable_emits_signal() -> void:
	var item := Interactable.new()
	tree.root.add_child(item)
	var got: Array = []
	var cb := func(target: Node) -> void: got.append(target)
	EventBus.interacted.connect(cb)
	item.interact(null)
	item.enabled = false
	item.interact(null)
	EventBus.interacted.disconnect(cb)
	assert_eq(got.size(), 1, "disabled interactable must not fire;")
	assert_eq(item.collision_layer, Interactable.LAYER_INTERACTABLE, "layer;")
	item.free()


func test_translations_registered() -> void:
	TranslationServer.set_locale("vi")
	assert_eq(tr("PROMPT_INTERACT"), "Tương tác", "vi;")
	TranslationServer.set_locale("en")
	assert_eq(tr("PROMPT_INTERACT"), "Interact", "en;")
	TranslationServer.set_locale("vi")


func test_main_scene_footsteps_and_ambience_wired() -> void:
	var main: Node = load("res://scenes/main/main.tscn").instantiate()
	tree.root.add_child(main)
	var steps: AudioStreamPlayer3D = main.get_node("Player/Footsteps")
	assert_not_null(main.get_node_or_null("PauseMenu"), "pause menu in main scene")
	assert_not_null(main.get_node_or_null("Floor4"), "floor 4 in main scene")
	var player: Node3D = main.get_node("Player")
	var spawn: Node3D = main.get_node("Floor4/Anchors/seg1_start")
	assert_true(player.global_position.is_equal_approx(spawn.global_position), "player starts at seg1_start;")
	for i in 30:
		await tree.physics_frame
	# seg1_start faces the closed door of 407; turn west along the corridor.
	player.rotation.y = PI / 2.0
	Input.action_press("move_forward")
	for i in 60:
		await tree.physics_frame
	assert_not_null(steps.stream, "walking on tile floor plays a footstep;")
	assert_true(steps.tile_variants.has(steps.stream), "walking uses the walk bank;")
	Input.action_press("sprint")
	for i in 60:
		await tree.physics_frame
	Input.action_release("sprint")
	Input.action_release("move_forward")
	assert_true(steps.tile_run_variants.has(steps.stream), "sprinting uses the run bank;")
	var light: Light3D = main.get_node("Floor4/Corridor/CorridorLight_407")
	var hum: AudioStreamPlayer3D = light.get_node("LightHum")
	assert_true(hum.playing, "corridor tube hums;")
	assert_eq(hum.bus, &"Ambience", "hum bus;")
	light.visible = false
	assert_false(hum.playing, "hum stops when its tube light turns off;")
	light.visible = true
	assert_true(hum.playing, "hum resumes when its tube light turns on;")
	# Stop audio first: the audio thread releases playbacks a little later.
	for node in main.find_children("*", "AudioStreamPlayer3D", true, false):
		if node.has_method("stop_emitting"):
			node.stop_emitting()
		(node as AudioStreamPlayer3D).stop()
	main.queue_free()
	await tree.create_timer(0.5).timeout


func test_main_scene_escape_pauses_and_resumes_player() -> void:
	var main: Node = load("res://scenes/main/main.tscn").instantiate()
	tree.root.add_child(main)
	await wait_frames(2)
	var player: Node = main.get_node("Player")
	var escape := InputEventAction.new()
	escape.action = &"pause"
	escape.pressed = true
	Input.parse_input_event(escape)
	await wait_frames(2)
	assert_true(tree.paused, "Esc pauses the game")
	assert_false(player._mouse_captured, "Player releases the mouse while paused")
	Input.parse_input_event(escape)
	await wait_frames(2)
	assert_false(tree.paused, "second Esc resumes")
	assert_true(player._mouse_captured, "Player captures the mouse again")
	tree.paused = false
	for node in main.find_children("*", "AudioStreamPlayer3D", true, false):
		if node.has_method("stop_emitting"):
			node.stop_emitting()
		(node as AudioStreamPlayer3D).stop()
	main.queue_free()
	await tree.create_timer(0.5).timeout
