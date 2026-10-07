extends TestCase

const POLICY := preload("res://scripts/debug/ch3_policy.gd")
const ACTIONS := preload("res://scripts/debug/ch3_actions.gd")
const MENU := preload("res://scripts/debug/ch3_menu.gd")
const FIXTURE := preload("res://tests/tools/fixtures/ch3_qa_director.gd")


func test_route_policy_rejects_unreachable_and_guard_crossings() -> void:
	var route := PackedVector3Array([Vector3.ZERO, Vector3(10, 0, 0), Vector3(10, 0, 10)])
	assert_true(POLICY.path_reaches(route, Vector3(10, 0, 10)))
	assert_false(POLICY.path_reaches(route, Vector3(20, 0, 10)))
	assert_false(POLICY.path_reaches(PackedVector3Array(), Vector3.ZERO))
	var guards: Array[Vector3] = [Vector3(5, 0, 1)]
	assert_false(POLICY.avoids_guards(route, guards), "segment crosses radius even though endpoints are clear")
	guards = [Vector3(5, 0, 5)]
	assert_true(POLICY.avoids_guards(route, guards))
	assert_eq(POLICY.path_point(route, 0.25), Vector3(5, 0, 0))
	assert_eq(POLICY.path_point(route, 0.75), Vector3(10, 0, 5))
	assert_eq(POLICY.path_point(route, 1.0), route[-1])


func test_bar_policy_saves_hits_and_never_targets_guards() -> void:
	assert_true(POLICY.should_strike(1.4, 0.9, false, false, 8, 0.5))
	assert_false(POLICY.should_strike(1.6, 0.9, false, false, 8, 0.5))
	assert_false(POLICY.should_strike(1.4, -0.9, false, false, 8, 0.5))
	assert_false(POLICY.should_strike(1.4, 0.9, true, false, 8, 0.5))
	assert_false(POLICY.should_strike(1.4, 0.9, false, true, 8, 0.5))
	assert_false(POLICY.should_strike(1.4, 0.9, false, false, 0, 0.5))
	assert_false(POLICY.should_strike(1.4, 0.9, false, false, 8, 0.0))


func test_preflight_never_claims_unbound_profile_is_complete() -> void:
	var profile: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://../tools/ch3-profile.json"))
	assert_true(POLICY.preflight(profile).is_empty(), "T-193 real profile is bound")
	for count in [0, 20, 40]: assert_true(POLICY.preflight(profile, true, count).is_empty(), "performance bound for %d" % count)
	# A profile with the performance block left empty is never complete.
	var unbound := profile.duplicate(true)
	unbound.routes.b = null
	assert_false(POLICY.preflight(unbound).is_empty())
	unbound.performance = {"route": null, "spawn_paths": null, "active_property": null, "active_value": null}
	for count in [0, 20, 40]: assert_false(POLICY.preflight(unbound, true, count).is_empty())
	assert_false(POLICY.valid_route(null))
	assert_false(POLICY.valid_route([]))
	assert_false(POLICY.valid_route([{"anchor": "", "zone": "b"}]))
	assert_true(POLICY.valid_route([{"anchor": "Campus/Anchors/FireKey", "zone": "b"}]))
	assert_true(POLICY.valid_route([{"position": [35.75, -6.6, -4.5], "zone": "b"}]))
	assert_false(POLICY.valid_route([{"position": [1, "bad", 3], "zone": "b"}]))
	assert_false(POLICY.valid_route([{"zone": "stadium", "loop": [], "until": {"equals": true}, "timeout": 360}]))
	var bot := preload("res://scripts/debug/ch3_bot.gd").new()
	assert_eq(bot.valid_scenarios(), ["ch3_good", "ch3_grabbed", "ch3_guard"])
	bot.free()


func test_fps_summary_reports_worst_frame_and_both_thresholds() -> void:
	var fast: Array[float] = [10.0, 10.0, 20.0]
	var result := POLICY.summary(fast)
	assert_eq(result.mean_fps, 75.0)
	assert_eq(result.min_fps, 50.0)
	assert_true(result.target_met)
	var spike: Array[float] = [1.0, 1.0, 40.0]
	assert_false(POLICY.summary(spike).target_met, "mean above 60 cannot hide a frame below 30")
	var invalid: Array[float] = [0.0]
	assert_true(POLICY.summary(invalid).is_empty())


func test_actions_observe_real_events_and_release_held_input() -> void:
	var helper := ACTIONS.new()
	tree.root.add_child(helper)
	EventBus.bar_picked.emit(8)
	EventBus.bar_swung.emit(true, 7)
	EventBus.stamina_changed.emit(0.1, true)
	EventBus.companion_state_changed.emit(&"ngu", &"joined")
	assert_eq(helper.hits, 7)
	assert_true(helper.exhausted)
	assert_true(helper.companions.has(&"ngu"))
	Input.action_press("move_forward")
	Input.action_press("sprint")
	helper.cancel()
	assert_false(Input.is_action_pressed("move_forward"))
	assert_false(Input.is_action_pressed("sprint"))
	var result: Dictionary = await helper.perform("missing")
	assert_eq(result.status, "SKIP")
	helper.free()


func test_menu_four_jumps_and_debug_controls_with_isolated_fixture() -> void:
	var root := OS.get_environment("QA_EXPECTED_USER_ROOT")
	assert_false(root.is_empty())
	if root.is_empty(): return
	var previous_root := OS.get_environment("QA_PLAYTHROUGH_ROOT")
	OS.set_environment("QA_PLAYTHROUGH_ROOT", root)
	var old_scene := tree.current_scene
	var state := GameState.to_dict()
	var old_mouse := Input.mouse_mode
	var scene := Node3D.new()
	var director := FIXTURE.new()
	director.name = "Chapter3Director"
	scene.add_child(director)
	director.owner = scene
	var packed := PackedScene.new()
	assert_eq(packed.pack(scene), OK)
	assert_eq(ResourceSaver.save(packed, "user://qa_ch3_fixture.tscn"), OK)
	scene.free()
	var menu := MENU.new()
	tree.root.add_child(menu)
	# Availability is explicit, never inferred from the stage name.
	for stage: String in POLICY.STAGES:
		assert_eq(menu.panel.get_child(0).get_node(stage).disabled, not menu.available(stage))
	menu.profile.scene = "user://qa_ch3_fixture.tscn"
	menu.profile.rule_set = null
	menu.profile.menu_actions = {
		"zombies_off": {"path": "Chapter3Director", "method": "set_zombies", "args": [false], "verify": {"property": "enabled", "equals": false}},
		"zombies_on": {"path": "Chapter3Director", "method": "set_zombies", "args": [true], "verify": {"property": "enabled", "equals": true}},
		"give_bar": {"path": "Chapter3Director", "method": "give_bar", "args": [8], "verify": {"property": "hits", "equals": 8}},
		"refill": {"path": "Chapter3Director", "method": "refill", "verify": {"property": "stamina", "equals": 1.0}}}
	tree.current_scene = null
	for stage: String in POLICY.STAGES:
		await menu.jump(stage)
		assert_eq(GameState.chapter, 3)
		assert_eq(str(GameState.segment), stage)
		var key := InputEventKey.new()
		key.keycode = KEY_F9
		key.pressed = true
		menu._input(key)
		assert_true(menu.panel.visible)
		assert_true(tree.paused)
		menu._input(key)
		assert_false(menu.panel.visible)
		assert_false(tree.paused)
	for action: String in menu.profile.menu_actions: await menu.apply_action(action)
	var live := tree.current_scene.get_node("Chapter3Director")
	assert_true(live.enabled)
	assert_eq(live.hits, 8)
	assert_eq(live.stamina, 1.0)
	tree.current_scene.queue_free()
	tree.current_scene = old_scene
	await wait_frames(2)
	menu.free()
	GameState.from_dict(state)
	Input.mouse_mode = old_mouse
	OS.set_environment("QA_PLAYTHROUGH_ROOT", previous_root)
	DirAccess.remove_absolute("user://qa_ch3_fixture.tscn")
