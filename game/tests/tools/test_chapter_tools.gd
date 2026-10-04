extends TestCase

const ACTIONS := preload("res://scripts/debug/chapter_actions.gd")
const PERFORMANCE := preload("res://scripts/debug/performance_bot.gd")
const BOT := preload("res://scripts/debug/chapter_bot.gd")


func test_action_schema_rejects_invalid_durations_positions_and_choices() -> void:
	for command: Dictionary in [{"op": "bed", "number": 0}, {"op": "bed", "number": 1.5}, {"op": "breath", "seconds": -1}, {"op": "still", "seconds": INF}, {"op": "goto", "position": [0, 1]}, {"op": "goto", "position": [0, "bad", 1]}, {"op": "choice", "id": "x", "index": 0.5}, {"op": "not_an_action"}]:
		assert_false(ACTIONS.valid(command), str(command))
	assert_true(ACTIONS.valid({"op": "bed", "number": 3}))
	assert_true(ACTIONS.valid({"op": "breath", "seconds": 2.5}))
	assert_true(ACTIONS.valid({"op": "goto", "position": [1, 2, 3]}))


func test_missing_mechanic_skips_but_malformed_action_fails() -> void:
	var world := Node3D.new()
	var player := CharacterBody3D.new()
	player.name = "Player"
	world.add_child(player)
	var actions := ACTIONS.new()
	actions.world = world
	tree.root.add_child(world)
	tree.root.add_child(actions)
	var missing: Dictionary = await actions.execute({"op": "bed", "number": 1})
	assert_eq(missing.status, "SKIP")
	var invalid: Dictionary = await actions.execute({"op": "bed", "number": 9})
	assert_eq(invalid.status, "FAIL")
	var moved: Dictionary = await actions.execute({"op": "goto", "position": [4, 2, -3]})
	assert_eq(moved.status, "PASS")
	assert_eq(player.global_position, Vector3(4, 2, -3))
	var still: Dictionary = await actions.execute({"op": "still", "seconds": 0.03})
	assert_eq(still.status, "PASS")
	actions.free()
	world.free()


func test_frame_statistics_use_wall_time_and_nearest_rank_p95() -> void:
	var samples: Array[float] = []
	for i in range(1, 101):
		samples.append(float(i))
	var summary := PERFORMANCE.statistics(samples)
	assert_eq(summary.p95_frame_ms, 95.0)
	assert_true(absf(summary.mean_fps - 1000.0 / 50.5) < 0.00001)
	assert_eq(summary.max_frame_ms, 100.0)
	assert_true(PERFORMANCE.statistics([]).is_empty())
	assert_true(PERFORMANCE.statistics([0.0]).is_empty())


func test_checkpoint_chapter_and_progress_files_are_independent() -> void:
	var state := GameState.to_dict()
	var rules := RuleSystem.to_dict()
	var default_unlocked := Progress.unlocked_chapter()
	var checkpoint_path := "user://qa_chapter_test_checkpoint.json"
	var progress_path := "user://qa_chapter_test_progress.json"
	Progress.clear(progress_path)
	assert_eq(Progress.unlocked_chapter(progress_path), 1)
	GameState.chapter = 1
	assert_eq(Checkpoint.save(&"qa_mid_chapter", checkpoint_path), OK)
	Progress.unlock(2, progress_path)
	GameState.chapter = 4
	assert_eq(Checkpoint.restore(checkpoint_path), &"qa_mid_chapter")
	assert_eq(GameState.chapter, 1)
	assert_eq(Progress.unlocked_chapter(progress_path), 2)
	assert_eq(Progress.unlocked_chapter(), default_unlocked)
	Checkpoint.clear(checkpoint_path)
	Progress.clear(progress_path)
	GameState.from_dict(state)
	RuleSystem.from_dict(rules)


func test_chapter_templates_require_explicit_bindings_and_preserve_zero_index() -> void:
	var templates: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://scripts/debug/ch1_scenarios.json"))
	assert_eq(templates.size(), 4)
	var missing: Array[String] = []
	var bound: Dictionary = BOT.bind_template(templates.ch1_good, {"solution_index": 0}, missing)
	assert_true("opening_segment" in missing)
	assert_false("solution_index" in missing)
	assert_eq(bound.steps[-2].index, 0)
	assert_eq(templates.ch1_good.steps[-2].index, "$solution_index", "template stays immutable")
