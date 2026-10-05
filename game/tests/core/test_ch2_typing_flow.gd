extends TestCase
## Integration (T-176…T-180): a typed word and a texted prediction go through
## lane D's real text boxes in the chapter-2 scene, lane A's player stands
## still while typing, and core judges the result.

var scene: Node
var director: Chapter2Director
var failed: Array[StringName] = []
var typing: Array[bool] = []


func before_each() -> void:
	scene = load("res://scenes/main/chapter2.tscn").instantiate()
	director = scene.get_node("Chapter2Director")
	director.auto_start = false
	director.time_scale = 0.05
	Chapter1Director.resume_checkpoint = &""
	tree.root.add_child(scene)
	scene.get_node("FloorSpeaker").voice_directory = ""
	failed.clear()
	typing.clear()
	EventBus.player_failed.connect(_on_failed)
	EventBus.text_entry_changed.connect(_on_typing)
	RuleSystem.load_rule_set(load(Chapter2Director.CH2_RULE_SET))
	await wait_frames(2)


func after_each() -> void:
	EventBus.player_failed.disconnect(_on_failed)
	EventBus.text_entry_changed.disconnect(_on_typing)
	scene.queue_free()
	await wait_frames(2)


func _on_failed(reason: StringName) -> void:
	failed.append(reason)


func _on_typing(active: bool) -> void:
	typing.append(active)


func _until(condition: Callable, seconds: float = 20.0) -> void:
	var deadline := Time.get_ticks_msec() + int(seconds * 1000.0)
	while not condition.call() and Time.get_ticks_msec() < deadline:
		await wait_frames(1)


func test_a_word_typed_in_the_chain_panel_is_accepted() -> void:
	var requested := [false]
	var on_request := func(_s: float) -> void: requested[0] = true
	EventBus.chain_input_requested.connect(on_request)
	var closed: Array[StringName] = []
	var on_closed := func(result: StringName) -> void: closed.append(result)
	EventBus.chain_input_closed.connect(on_closed)
	director.run_from(&"r3")
	await _until(func() -> bool: return requested[0] or not failed.is_empty(), 30.0)
	EventBus.chain_input_requested.disconnect(on_request)
	assert_true(requested[0], "Trung's turn came")
	var panel := director.get_node("ChainPanel")
	panel.open_entry()
	var entry := panel.get_node("Root/Card/Content/Entry") as LineEdit
	assert_true(entry.has_focus(), "the box has the keyboard")
	var player := scene.find_children("*", "", true, false).filter(func(n: Node) -> bool: return n.has_method("keyboard_input_blocked"))
	assert_true(not player.is_empty() and player[0].keyboard_input_blocked(), "the player stands still while typing")
	# Combining tone marks, as a system IME may send them.
	var text := "Vở kịch"
	entry.text = text
	entry.text_submitted.emit(text)
	await _until(func() -> bool: return not closed.is_empty(), 5.0)
	EventBus.chain_input_closed.disconnect(on_closed)
	assert_eq(closed, [&"accepted"] as Array[StringName], "core accepted 'vở kịch';")
	assert_eq(failed, [] as Array[StringName], "alive;")
	assert_true(typing.size() >= 2 and typing[0] and not typing[-1], "keyboard taken then given back: %s" % [typing])
	assert_false(player[0].keyboard_input_blocked(), "the player moves again")


func test_predictions_texted_from_the_phone_are_judged() -> void:
	var results: Dictionary = {}
	var on_result := func(member: StringName, correct: bool) -> void: results[member] = correct
	EventBus.prediction_result.connect(on_result)
	var answers := {&"minh_nhat": "2x", &"ngu": "Không"}
	var phone := scene.get_node("PhoneScreen")
	var on_request := func(member: StringName, _h: PackedInt32Array, _s: float) -> void:
		await wait_frames(2)
		var entry: LineEdit = phone.prediction.entry
		assert_true(entry.has_focus(), "%s: the phone box has the keyboard" % member)
		entry.text = answers[member]
		entry.text_submitted.emit(answers[member])
	EventBus.prediction_requested.connect(on_request)
	GameState.set_segment(&"r4")
	var done := [false]
	var run := func() -> void: done[0] = await director._predictions()
	run.call()
	await _until(func() -> bool: return results.size() == 2 or not failed.is_empty(), 30.0)
	EventBus.prediction_requested.disconnect(on_request)
	EventBus.prediction_result.disconnect(on_result)
	assert_eq(results, {&"minh_nhat": true, &"ngu": true}, "both right;")
	assert_eq(failed, [] as Array[StringName], "alive;")
	assert_true(not typing.is_empty() and not typing[-1], "keyboard given back")
