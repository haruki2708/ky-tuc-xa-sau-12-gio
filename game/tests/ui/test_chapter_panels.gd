extends TestCase

const BOOK = preload("res://ui/notebook/notebook.tscn")
const PUZZLE = preload("res://ui/puzzle/puzzle_panel.tscn")
const DEATH = preload("res://ui/death/death_screen.tscn")
const NOTICE = preload("res://ui/survivors/survivor_notice.tscn")
var host: Node
var _locale: String
var _mouse: Input.MouseMode
var _paused: bool
var _state: Dictionary
var _rules: RuleSet
var _rule_state: Dictionary
var _solved: Array = []
var _closed: Array = []

class LockedPlayer:
	extends Node
	var locks: Array = []
	func acquire_control_lock(owner: Node) -> void:
		locks.append(owner)
	func release_control_lock(owner: Node) -> void:
		locks.erase(owner)


func before_each() -> void:
	_locale = TranslationServer.get_locale()
	_mouse = Input.mouse_mode
	_paused = tree.paused
	_state = GameState.to_dict()
	_rules = RuleSet.new()
	for id in RuleSystem.all_rule_ids():
		_rules.rules.append(RuleSystem.get_rule(id))
	_rule_state = RuleSystem.to_dict()
	RuleSystem.load_rule_set(load("res://data/rules/ch1.tres"))
	TranslationServer.set_locale("vi")
	tree.paused = false
	host = Node.new()
	tree.root.add_child(host)
	_solved.clear()
	_closed.clear()
	EventBus.puzzle_solved.connect(_on_solved)
	EventBus.puzzle_closed.connect(_on_closed)


func after_each() -> void:
	host.queue_free()
	await wait_frames(3)
	EventBus.puzzle_solved.disconnect(_on_solved)
	EventBus.puzzle_closed.disconnect(_on_closed)
	RuleSystem.load_rule_set(_rules, false)
	RuleSystem.from_dict(_rule_state)
	GameState.from_dict(_state)
	TranslationServer.set_locale(_locale)
	Input.mouse_mode = _mouse
	tree.paused = _paused


func _on_solved(id: StringName) -> void:
	_solved.append(id)


func _on_closed(id: StringName) -> void:
	_closed.append(id)


func _mount(scene: PackedScene) -> CanvasLayer:
	var node: CanvasLayer = scene.instantiate()
	host.add_child(node)
	node.get_node("Root").set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT)
	node.get_node("Root").size = Vector2(1920, 1080)
	return node


func test_rulebook_rounds_expiry_verbatim_attention_and_evidence() -> void:
	var book := _mount(BOOK)
	RuleSystem.mark_read(&"ch1_general_3")
	book.open_notebook()
	var groups := book.get_node("Root/Book/Content/Scroll/Groups")
	assert_eq(groups.get_child(0).get_child(0).text, "Tổng tắc")
	# A round-1 line (source round_1) to show an older round expiring.
	RuleSystem.mark_read(&"ch1_general_2", &"round_1", "RULE_1")
	RuleSystem.mark_read(&"ch1_r2")
	RuleSystem.set_suspected(&"ch1_r2", true)
	RuleSystem.set_evidence(&"ch1_r2", &"ch1_dat_card", true)
	EventBus.segment_changed.emit(&"r2_manager")
	await wait_frames(2)
	assert_eq(groups.get_child_count(), 3)
	# The General Rules stay in force in every round (integrator, T-156 review).
	assert_eq(groups.get_child(0).get_child(0).text, "Tổng tắc")
	assert_true(groups.get_child(0).modulate.r > 0.9)
	assert_true(groups.get_child(1).get_child(0).text.contains("Hết hiệu lực"))
	assert_true(groups.get_child(1).modulate.r < 0.8)
	assert_eq(groups.get_child(2).get_child(0).text, "Vòng 2")
	var row := groups.get_child(2).get_child(1)
	assert_eq(row.get_node("Text").text, tr("RULE_CH1_R2"))
	assert_true(row.get_node("Suspect").button_pressed)
	assert_eq(row.get_node("Suspect").tr(row.get_node("Suspect").text), "Đáng chú ý")
	assert_true(groups.get_child(2).get_child(2).text.contains(tr("DOC_CH1_DAT_CARD_TITLE")))
	TranslationServer.set_locale("en")
	await wait_frames(2)
	assert_eq(groups.get_child(2).get_child(0).text, "Round 2")
	assert_true(groups.get_child(1).get_child(0).text.contains("Expired"))
	assert_false(groups.get_child(0).get_child(0).text.contains("Expired"))
	assert_eq(book._round_for({"text_key": "RULE_CH2_R3", "source": &"speaker"}), 3)
	assert_eq(book._round_for({"text_key": "RULE_1", "source": &"round_1"}), 1)


func test_survivors_fade_replace_and_preserve_controls() -> void:
	var notice := _mount(NOTICE)
	notice.set_process(false)
	var mode := Input.mouse_mode
	EventBus.survivor_count_changed.emit(352)
	assert_true(notice.get_node("Root").visible)
	assert_eq(notice.get_node("Root/Card/Content/Count").text, "Số người sống sót: 352")
	assert_false(tree.paused)
	assert_eq(Input.mouse_mode, mode)
	notice._process(3.5)
	assert_true(notice.get_node("Root").modulate.a < 1.0)
	EventBus.survivor_count_changed.emit(28)
	assert_eq(notice.get_node("Root").modulate.a, 1.0)
	TranslationServer.set_locale("en")
	await wait_frames(1)
	assert_eq(notice.get_node("Root/Card/Content/Count").text, "Survivors: 28")
	notice._process(4.0)
	assert_false(notice.get_node("Root").visible)


func test_death_reason_count_once_no_pause_and_checkpoint_clears() -> void:
	var player := LockedPlayer.new()
	player.name = "Player"
	host.add_child(player)
	var death := _mount(DEATH)
	var book := _mount(BOOK)
	var menu := _mount(load("res://ui/pause/pause_menu.tscn"))
	menu.name = "PauseMenu"
	GameState.set_flag(&"survivors", 352)
	book.open_notebook()
	EventBus.player_failed.emit(&"DEATH_OWN_BED")
	assert_true(death.is_in_group("death_screen"))
	assert_true(death.is_open())
	assert_false(book.is_open())
	assert_false(tree.paused, "core reload timer remains running")
	assert_eq(death.get_node("Root/Card/Content/Reason").text, tr("DEATH_OWN_BED"))
	assert_eq(death.get_node("Root/Card/Content/Count").text, "Số người sống sót: 351")
	EventBus.player_failed.emit(&"DEATH_HEARD")
	assert_eq(player.locks.size(), 1)
	assert_eq(GameState.get_flag(&"survivors"), 352, "UI does not mutate the authoritative count")
	book.open_notebook()
	menu.open_menu()
	assert_false(book.is_open())
	assert_false(menu._open)
	TranslationServer.set_locale("en")
	await wait_frames(1)
	assert_eq(death.get_node("Root/Card/Content/Reason").text, tr("DEATH_OWN_BED"))
	EventBus.checkpoint_loaded.emit(&"ch1_manager")
	assert_false(death.is_open())
	assert_true(player.locks.is_empty())


func test_puzzle_variable_dials_wrong_then_correct_signal_and_delay() -> void:
	var panel := _mount(PUZZLE)
	panel.set_process(false)
	EventBus.puzzle_opened.emit(&"locker_combo_dat")
	assert_true(panel.is_open())
	assert_true(tree.paused)
	assert_eq(Input.mouse_mode, Input.MOUSE_MODE_VISIBLE)
	assert_eq(panel.get_node("Root/Card/Content/DialScroll/Dials").get_child_count(), 4)
	for index in 4:
		panel._turn(index, 1)
	assert_true(_solved.is_empty())
	assert_eq(panel.get_node("Root/Card/Content/Feedback").text, tr("UI_PUZZLE_WRONG"))
	assert_not_null(panel.get_node("WrongSound").stream)
	# 0000 -> 2109 (Phúc's birthday, D-039).
	panel._turn(0, 1)
	panel._turn(0, 1)
	panel._turn(1, 1)
	panel._turn(3, -1)
	assert_eq(_solved, [&"locker_combo_dat"])
	panel._turn(3, 1)
	assert_eq(_solved.size(), 1)
	panel._process(0.79)
	assert_true(panel.is_open())
	panel._process(0.02)
	assert_false(panel.is_open())
	assert_false(tree.paused)
	assert_eq(_closed, [&"locker_combo_dat"])


func test_puzzle_hint_missing_data_escape_and_pause_ownership() -> void:
	var panel := _mount(PUZZLE)
	var menu := _mount(load("res://ui/pause/pause_menu.tscn"))
	EventBus.puzzle_opened.emit(&"missing")
	assert_false(tree.paused)
	assert_eq(_closed, [&"missing"])
	var sample := PuzzleData.new()
	sample.id = &"test_three"
	sample.title_key = "PUZZLE_LOCKER_DAT_TITLE"
	sample.solution = "507"
	sample.hint_document = &"missing_hint"
	assert_true(panel.open_puzzle(sample))
	assert_eq(panel._digits.size(), 3)
	assert_false(panel.get_node("Root/Card/Content/Hint").visible)
	_key(KEY_ESCAPE)
	assert_false(panel.is_open())
	assert_false(menu._open)
	# The real locker has no hint under Insane (D-039); test the hint view with sample data.
	var hinted := PuzzleData.new()
	hinted.id = &"test_hint"
	hinted.title_key = "PUZZLE_LOCKER_DAT_TITLE"
	hinted.solution = "2109"
	hinted.hint_document = &"ch1_dat_card"
	assert_true(panel.open_puzzle(hinted))
	panel._show_hint()
	assert_true(panel.get_node("Root/Card/Content/HintScroll").visible)
	assert_true(panel.get_node("Root/Card/Content/HintScroll/Text").text.contains(tr("DOC_CH1_DAT_CARD_1")))
	_key(KEY_ESCAPE)
	assert_false(panel.is_open(), "Esc also closes the puzzle while the hint is visible")
	assert_false(tree.paused)
	menu.open_menu()
	EventBus.puzzle_opened.emit(&"locker_combo_dat")
	assert_false(panel.is_open())
	assert_true(tree.paused, "refused puzzle does not unpause someone else's modal")
	menu.close_menu()


func test_puzzle_mouse_wheel_and_cleanup() -> void:
	var panel := _mount(PUZZLE)
	EventBus.puzzle_opened.emit(&"locker_combo_dat")
	await wait_frames(3)
	var value: Label = panel.get_node("Root/Card/Content/DialScroll/Dials/Dial0/Value")
	var wheel := InputEventMouseButton.new()
	wheel.position = value.get_global_rect().get_center()
	wheel.button_index = MOUSE_BUTTON_WHEEL_DOWN
	wheel.pressed = true
	tree.root.push_input(wheel, true)
	assert_eq(panel._digits[0], 9)
	host.remove_child(panel)
	panel.free()
	assert_false(tree.paused)
	assert_eq(_closed, [&"locker_combo_dat"])


func _key(code: Key) -> void:
	var event := InputEventKey.new()
	event.physical_keycode = code
	event.pressed = true
	tree.root.push_input(event, true)
	event.pressed = false
	tree.root.push_input(event, true)
