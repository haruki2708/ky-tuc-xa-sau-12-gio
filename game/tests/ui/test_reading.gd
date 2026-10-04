extends TestCase

const DOCUMENT = preload("res://ui/document/document_view.tscn")
const NOTEBOOK = preload("res://ui/notebook/notebook.tscn")
const PAUSE = preload("res://ui/pause/pause_menu.tscn")

var _host: Node
var _document: CanvasLayer
var _notebook: CanvasLayer
var _menu: CanvasLayer
var _locale: String
var _mouse_mode: Input.MouseMode
var _paused: bool


func before_each() -> void:
	_locale = TranslationServer.get_locale()
	_mouse_mode = Input.mouse_mode
	_paused = tree.paused
	TranslationServer.set_locale("vi")
	assert_true(RuleSystem.load_rule_set(load("res://data/rules/demo.tres")).is_empty())
	_host = Node.new()
	tree.root.add_child(_host)
	_document = DOCUMENT.instantiate()
	_notebook = NOTEBOOK.instantiate()
	_menu = PAUSE.instantiate()
	for node in [_document, _notebook, _menu]:
		_host.add_child(node)


func after_each() -> void:
	_host.queue_free()
	await wait_frames(2)
	RuleSystem.reset()
	TranslationServer.set_locale(_locale)
	Input.mouse_mode = _mouse_mode
	tree.paused = _paused


func test_documents_render_data_and_close_with_signals() -> void:
	var closed: Array = []
	var paused: Array = []
	var on_closed := func(id: StringName) -> void: closed.append(id)
	var on_pause := func(value: bool) -> void: paused.append(value)
	EventBus.document_closed.connect(on_closed)
	EventBus.game_paused.connect(on_pause)
	for id: StringName in [&"hall_board", &"room_paper_407", &"hall_board_note", &"washroom_notice"]:
		var data := DocumentData.load_by_id(id)
		EventBus.document_opened.emit(id)
		assert_true(_document.is_open())
		assert_true(tree.paused)
		assert_eq(Input.mouse_mode, Input.MOUSE_MODE_VISIBLE)
		assert_eq(_document.layer, 15)
		assert_eq(_document.get_node("Root/Paper").paper_style, data.style)
		var title: Label = _document.get_node("Root/Paper/Content/Title")
		assert_eq(title.visible, not data.title_key.is_empty())
		if title.visible:
			assert_eq(title.text, tr(data.title_key))
		var lines := _lines()
		assert_eq(lines.get_child_count(), data.rule_ids.size())
		for index in data.rule_ids.size():
			assert_eq(lines.get_child(index).text, "%d. %s" % [index + 1, tr(RuleSystem.get_rule(data.rule_ids[index]).text_key)])
		assert_eq(_document.get_node("Root/Paper/Content/Stamp").visible, data.style == &"stamped")
		_document.close_view()
		assert_false(tree.paused)
	EventBus.document_closed.disconnect(on_closed)
	EventBus.game_paused.disconnect(on_pause)
	assert_eq(closed, [&"hall_board", &"room_paper_407", &"hall_board_note", &"washroom_notice"])
	assert_eq(paused, [true, false, true, false, true, false, true, false])


func test_escape_closes_document_without_pause_menu_in_both_orders() -> void:
	for menu_first in [true, false]:
		_host.move_child(_menu, 0 if menu_first else _host.get_child_count() - 1)
		EventBus.document_opened.emit(&"hall_board")
		_press(KEY_ESCAPE)
		assert_false(_document.is_open())
		assert_false(_menu.get_node("Root").visible)
		assert_false(tree.paused)


func test_document_closes_with_interact_mouse_and_tab_without_opening_notebook() -> void:
	for key: Key in [KEY_E, KEY_TAB]:
		EventBus.document_opened.emit(&"room_paper_407")
		_press(key)
		assert_false(_document.is_open())
		assert_false(_notebook.is_open())
		assert_false(tree.paused)
	EventBus.document_opened.emit(&"room_paper_407")
	var click := InputEventMouseButton.new()
	click.button_index = MOUSE_BUTTON_LEFT
	click.pressed = true
	tree.root.push_input(click, true)
	click.pressed = false
	tree.root.push_input(click, true)
	assert_false(_document.is_open())
	assert_false(tree.paused)


func test_modal_conflicts_invalid_document_and_removal_cleanup() -> void:
	EventBus.document_opened.emit(&"missing_document_for_test")
	assert_false(tree.paused)
	_menu.open_menu()
	_press(KEY_TAB)
	_notebook.open_notebook()
	EventBus.document_opened.emit(&"hall_board")
	assert_false(_notebook.is_open())
	assert_false(_document.is_open())
	_menu.close_menu()
	_notebook.open_notebook()
	_menu.open_menu()
	EventBus.document_opened.emit(&"hall_board")
	assert_false(_menu.get_node("Root").visible)
	assert_false(_document.is_open())
	_notebook.close_view()
	EventBus.document_opened.emit(&"hall_board")
	_notebook.open_notebook()
	assert_false(_notebook.is_open())
	_host.remove_child(_document)
	assert_false(tree.paused)
	_document.free()


func test_opening_interact_release_does_not_close_paper_and_next_tap_does() -> void:
	# Player opens the paper during physics after the opening press was dispatched.
	Input.action_press("interact")
	EventBus.document_opened.emit(&"room_paper_407")
	var release := InputEventKey.new()
	release.physical_keycode = KEY_E
	release.pressed = false
	tree.root.push_input(release, true)
	assert_true(_document.is_open(), "opening release leaves the paper readable")
	Input.action_press("interact")
	_press(KEY_E)
	assert_false(_document.is_open())
	assert_false(tree.paused)
	assert_false(Input.is_action_pressed("interact"), "closing input cannot reopen the world paper")


func test_document_locale_and_log_paragraphs_update() -> void:
	EventBus.document_opened.emit(&"hall_board")
	TranslationServer.set_locale("en")
	await wait_frames(1)
	assert_eq(_document.get_node("Root/Paper/Content/Title").text, "Holiday night rules — 5 articles")
	assert_eq(_lines().get_child(0).text, "1. After midnight, turn off the main light in your room.")
	_document.close_view()
	var sample := DocumentData.new()
	sample.id = &"ui_log_preview"
	sample.style = &"log"
	sample.text_keys = ["UI_LOG_PREVIEW_TEXT"]
	_document.show_document(sample)
	assert_eq(_document.get_node("Root/Paper").paper_style, &"log")
	assert_eq(_lines().get_child_count(), 1)
	assert_eq(_lines().get_child(0).text, tr("UI_LOG_PREVIEW_TEXT"))
	TranslationServer.set_locale("vi")
	await wait_frames(1)
	assert_eq(_lines().get_child(0).text, "Đây là trang thử hiển thị chữ và dòng kẻ.")


func test_notebook_empty_tab_and_escape() -> void:
	_press(KEY_TAB)
	assert_true(_notebook.is_open())
	assert_true(tree.paused)
	assert_true(_notebook.get_node("Root/Book/Content/Empty").visible)
	_press(KEY_TAB)
	assert_false(tree.paused)
	_press(KEY_TAB)
	_press(KEY_ESCAPE)
	assert_false(tree.paused)
	assert_false(_menu.get_node("Root").visible)


func test_notebook_groups_sources_in_first_seen_order_and_uses_entry_text() -> void:
	RuleSystem.mark_read(&"slippers_genuine", &"speaker", "RULE_3_GARBLED")
	DocumentData.load_by_id(&"room_paper_407").mark_rules_read()
	RuleSystem.mark_read(&"lights_genuine", &"speaker")
	RuleSystem.mark_read(&"lights_genuine", &"unknown_source")
	_notebook.open_notebook()
	var groups := _groups()
	assert_eq(groups.get_child_count(), 3)
	assert_eq(groups.get_child(0).get_meta("source"), &"speaker")
	assert_eq(groups.get_child(1).get_meta("source"), &"room_paper")
	assert_eq(groups.get_child(2).get_child(0).text, "unknown_source")
	assert_eq(groups.get_child(0).get_child_count(), 3, "heading and two speaker entries;")
	assert_eq(groups.get_child(0).get_child(1).get_node("Text").text, tr("RULE_3_GARBLED"))
	assert_false(groups.get_child(0).get_child(1).get_node("Text").text.contains("không quay lại"))
	assert_eq(groups.get_child(1).get_child(3).get_node("Text").text, tr("RULE_3_FAKE"))
	assert_false(_notebook.get_node("Root/Book/Content/Empty").visible)


func test_notebook_suspicion_live_entries_and_locale() -> void:
	RuleSystem.mark_read(&"lights_genuine", &"speaker")
	RuleSystem.mark_read(&"lights_genuine", &"hall_board")
	_notebook.open_notebook()
	await wait_frames(2)
	var row := _groups().get_child(0).get_child(1)
	var button: CheckButton = row.get_node("Suspect")
	var position := button.get_global_rect().get_center()
	var motion := InputEventMouseMotion.new()
	motion.position = position
	tree.root.push_input(motion, true)
	var click := InputEventMouseButton.new()
	click.position = position
	click.button_index = MOUSE_BUTTON_LEFT
	click.pressed = true
	tree.root.push_input(click, true)
	click.pressed = false
	tree.root.push_input(click, true)
	await wait_frames(2)
	assert_true(_notebook.is_open(), "clicking suspicion does not close the notebook")
	assert_true(RuleSystem.is_suspected(&"lights_genuine"))
	for group in _groups().get_children():
		assert_true(group.get_child(1).get_node("Suspect").button_pressed)
		assert_eq(group.get_child(1).get_child_count(), 3, "suspected marker visible;")
	RuleSystem.set_suspected(&"lights_genuine", false)
	RuleSystem.mark_read(&"slippers_genuine", &"speaker", "RULE_3_GARBLED")
	TranslationServer.set_locale("en")
	await wait_frames(2)
	assert_eq(_groups().get_child(0).get_child(0).text, "Loudspeaker")
	assert_false(_groups().get_child(0).get_child(1).get_node("Suspect").button_pressed)
	assert_eq(_groups().get_child(0).get_child(2).get_node("Text").text, tr("RULE_3_GARBLED"))
	RuleSystem.mark_read(&"slippers_genuine", &"speaker", "RULE_3")
	await wait_frames(2)
	assert_eq(_groups().get_child(0).get_child_count(), 3, "updated entry is not duplicated;")
	assert_eq(_groups().get_child(0).get_child(2).get_node("Text").text, tr("RULE_3"))


func test_hint_is_sent_only_on_first_read() -> void:
	var hints: Array = []
	var callback := func(key: String, duration: float) -> void: hints.append([key, duration])
	EventBus.subtitle_requested.connect(callback)
	DocumentData.load_by_id(&"room_paper_407").mark_rules_read()
	DocumentData.load_by_id(&"hall_board").mark_rules_read()
	EventBus.subtitle_requested.disconnect(callback)
	assert_eq(hints, [["SUB_NOTEBOOK_HINT", 3.0]])


func test_f6_scene_loads_and_speaker_records_five_entries() -> void:
	# Avoid two listeners owning the same document overlay in the test harness.
	_host.free()
	_host = load("res://ui/notebook/notebook_test.tscn").instantiate()
	tree.root.add_child(_host)
	_host._read_speaker()
	assert_eq(RuleSystem.read_entries().size(), 5)
	assert_eq(RuleSystem.read_entries()[2]["text_key"], "RULE_3_GARBLED")
	_host._open_document(&"room_paper_407")
	assert_true(_host.get_node("DocumentView").is_open())
	assert_eq(RuleSystem.read_entries().size(), 9)


func _lines() -> VBoxContainer:
	return _document.get_node("Root/Paper/Content/Scroll/Lines")


func _groups() -> VBoxContainer:
	return _notebook.get_node("Root/Book/Content/Scroll/Groups")


func _press(key: Key) -> void:
	var event := InputEventKey.new()
	event.physical_keycode = key
	event.pressed = true
	tree.root.push_input(event, true)
	event.pressed = false
	tree.root.push_input(event, true)
