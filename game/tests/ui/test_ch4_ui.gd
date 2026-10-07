extends TestCase

const BOOK = preload("res://ui/notebook/notebook.tscn")
const PHONE = preload("res://ui/phone/phone_screen.tscn")
const BED = preload("res://ui/ch4/bed_card.tscn")
const END = preload("res://ui/ch4/ch4_end_card.tscn")
var host: Node
var saved: Dictionary
var locale: String
var mouse: Input.MouseMode
var events: Array = []
var ownership: Array[bool] = []

class ReaderPlayer:
	extends Node
	var locked := false
	func acquire_control_lock(_owner: Node) -> void:
		locked = true
	func release_control_lock(_owner: Node) -> void:
		locked = false


func before_each() -> void:
	saved = GameState.to_dict()
	locale = TranslationServer.get_locale()
	mouse = Input.mouse_mode
	GameState.reset()
	GameState.chapter = 4
	TranslationServer.set_locale("vi")
	tree.paused = false
	host = Node.new()
	tree.root.add_child(host)
	events.clear()
	ownership.clear()
	EventBus.text_entry_changed.connect(_owned)


func after_each() -> void:
	host.queue_free()
	await wait_frames(2)
	EventBus.text_entry_changed.disconnect(_owned)
	GameState.from_dict(saved)
	TranslationServer.set_locale(locale)
	Input.mouse_mode = mouse
	tree.paused = false


func _owned(active: bool) -> void:
	ownership.append(active)


func _mount(scene: PackedScene) -> Node:
	var node := scene.instantiate()
	host.add_child(node)
	node.set_process(false)
	return node


func test_compare_gate_all_rounds_and_verdicts_without_penalty() -> void:
	var book := _mount(BOOK)
	assert_false(book.ch4.tabs.get_node("Compare").visible)
	GameState.set_flag(&"ch4_compare_enabled", true)
	GameState.chapter = 3
	book.ch4.refresh()
	assert_false(book.ch4.visible)
	GameState.chapter = 4
	book.open_notebook()
	var opened: Callable = func() -> void: events.append("opened")
	var marked: Callable = func(id: StringName) -> void: events.append(id)
	EventBus.ch4_compare_opened.connect(opened)
	EventBus.ch4_sentence_marked.connect(marked)
	book.ch4.select_tab(1)
	assert_eq(events, ["opened"])
	assert_eq(book.ch4.compare.get_child_count(), 5)
	for row in book.ch4.compare.get_children():
		assert_true(row.get_child(0).get_child_count() >= 2, "Each round includes original wording")
	book.ch4._select(&"ch3_r5_1")
	book.ch4.mark_selected()
	assert_eq(events.back(), &"ch3_r5_1")
	EventBus.ch4_compare_result.emit(&"ch3_r5_1", false)
	assert_eq(book.ch4.pending, &"")
	assert_eq(book.ch4.matched, &"")
	assert_eq(book.ch4.feedback, "UI_CH4_NOT_YET")
	assert_eq(GameState.deviation, 0)
	book.ch4._select(&"ch3_r5_2")
	book.ch4.mark_selected()
	EventBus.ch4_compare_result.emit(&"ch3_r5_2", true)
	assert_eq(book.ch4.matched, &"ch3_r5_2")
	book.close_view()
	book.open_notebook()
	assert_eq(book.ch4.matched, &"ch3_r5_2")
	assert_false(tree.paused, "Door deadlines continue while chapter-four book is open")
	EventBus.ch4_compare_opened.disconnect(opened)
	EventBus.ch4_sentence_marked.disconnect(marked)


func test_scraps_are_distinct_collected_and_restored_without_invented_profile() -> void:
	var book := _mount(BOOK)
	var form: Node = book.ch4.forms
	EventBus.bed_slat_flipped.emit(3)
	assert_true(form.scraps.is_empty())
	for bed in [1, 2, 4, 1]:
		EventBus.bed_slat_flipped.emit(bed)
	assert_eq(form.scraps, [1, 2, 4])
	assert_eq(form.choices.get_child_count(), 3)
	EventBus.survivor_form_assembled.emit()
	assert_eq(form.choices.get_child_count(), 4)
	assert_eq(form.name_label.text, "")
	assert_true(form.bite.visible)
	assert_true(form.fields.get_node("AGE").text.ends_with(":  "))
	GameState.set_flag(&"ch4_form_ready", true)
	book.close_view()
	EventBus.checkpoint_loaded.emit(&"ch4_407")
	assert_true(form.assembled)
	assert_eq(form.scraps, [1, 2, 4])
	assert_false(book.is_open())


func test_blood_ime_wrong_retry_accept_literal_and_damage_clock() -> void:
	var book := _mount(BOOK)
	var form: Node = book.ch4.forms
	form.set_process(false)
	EventBus.survivor_form_assembled.emit()
	EventBus.door_damage_changed.emit(&"407", 0.5)
	var typed: Callable = func(text: String) -> void: events.append(text)
	EventBus.blood_name_typed.connect(typed)
	form._bite()
	assert_eq(form.editor.remaining, 45.0)
	assert_eq(form.editor.clock.max_value, 90.0)
	assert_true(form.editor.entry.has_focus())
	form.editor.entry.text = "  [b]Trần Trung[/b]  "
	form.editor._submit(form.editor.entry.text)
	assert_eq(events, ["  [b]Trần Trung[/b]  "])
	EventBus.blood_name_closed.emit(&"wrong")
	assert_true(form.editor.entry.has_focus())
	assert_eq(form.editor.entry.text, "  [b]Trần Trung[/b]  ")
	form.editor._submit("Trần Trung")
	EventBus.blood_name_closed.emit(&"accepted")
	assert_eq(form.signature, "Trần Trung")
	assert_false(form.editor.active)
	assert_eq(ownership, [true, false, true, false])
	form._process(1.3)
	assert_eq(form.name_label.visible_ratio, 1.0)
	assert_false(form.bite.visible)
	EventBus.blood_name_typed.disconnect(typed)


func test_blood_timeout_and_lifecycle_release_keyboard() -> void:
	var book := _mount(BOOK)
	var form: Node = book.ch4.forms
	EventBus.survivor_form_assembled.emit()
	EventBus.blood_name_requested.emit(2.0)
	form.editor.advance(2.1)
	assert_false(form.editor.active)
	assert_false(form.editor.entry.has_focus())
	assert_eq(form.signature, "")
	EventBus.blood_name_requested.emit(2.0)
	EventBus.door_damage_changed.emit(&"library_back", 1.0)
	assert_true(form.editor.active)
	EventBus.door_damage_changed.emit(&"407", 1.0)
	assert_false(form.editor.active)
	EventBus.blood_name_requested.emit(2.0)
	EventBus.player_death_started.emit(&"door_burst")
	assert_false(book.is_open())
	assert_false(form.editor.entry.has_focus())


func test_last_message_native_submit_waits_for_core_and_preserves_literal_text() -> void:
	var phone := _mount(PHONE)
	var sent: Callable = func(text: String) -> void: events.append(text)
	EventBus.fade_message_typed.connect(sent)
	EventBus.fade_message_requested.emit(12.0)
	assert_true(phone.ch4.editor.entry.has_focus())
	assert_true(phone.state.raised)
	phone.ch4.editor._submit("[b]Vạt giường[/b]")
	assert_eq(events, ["[b]Vạt giường[/b]"])
	assert_true(phone.state.history.is_empty())
	EventBus.fade_message_closed.emit(&"sent")
	assert_eq(phone.state.history.back().text_key, "[b]Vạt giường[/b]")
	assert_true(phone.state.history.back().raw_text)
	assert_eq(ownership, [true, false])
	assert_true(phone.ch4.fading)
	EventBus.ch4_ending.emit(&"all")
	assert_false(phone.ch4.effect.get_node("Root").visible)
	EventBus.fade_message_typed.disconnect(sent)


func test_message_timeout_pause_and_charges() -> void:
	GameState.set_flag(&"ch4_phone_charges", 3)
	var phone := _mount(PHONE)
	assert_true(phone.ch4.badge.visible)
	assert_true(phone.ch4.badge.text.ends_with("3"))
	EventBus.phone_decoy_thrown.emit(Vector3.ZERO, 2)
	assert_true(phone.ch4.badge.text.ends_with("2"))
	EventBus.fade_message_requested.emit(12.0)
	tree.paused = true
	phone.ch4.advance(4.0)
	assert_eq(phone.ch4.editor.remaining, 12.0)
	tree.paused = false
	phone.ch4.advance(12.1)
	assert_false(phone.ch4.editor.active)
	assert_true(phone.state.history.is_empty())
	GameState.chapter = 2
	EventBus.chapter_started.emit(2)
	assert_false(phone.ch4.badge.visible)


func test_hospital_cards_infer_anchor_and_ending() -> void:
	for character in ["Trung", "Nhat", "Ngu"]:
		var bed := Node3D.new()
		bed.name = "Bed_" + character
		host.add_child(bed)
		var anchor := Marker3D.new()
		anchor.name = "Card"
		bed.add_child(anchor)
		var card := BED.instantiate()
		anchor.add_child(card)
		EventBus.ch4_ending.emit(&"alone")
		assert_eq(card.visible, character == "Trung")
		EventBus.ch4_ending.emit(&"all")
		assert_true(card.visible)
		assert_eq(card.get_node("Name").text, tr("UI_CH4_PATIENT_" + character.to_upper()))


func test_end_card_only_chapter_four_then_thanks_and_credits() -> void:
	var card := _mount(END)
	EventBus.chapter_finished.emit(3)
	assert_false(card.active)
	EventBus.chapter_finished.emit(4)
	card._process(2.1)
	assert_true(card.get_node("Root/Card").visible)
	assert_false(card.get_node("Root/Card/Content/Credits").visible)
	EventBus.chapter_finished.emit(4)
	assert_eq(card.elapsed, 2.1)
	card._process(3.0)
	assert_true(card.get_node("Root/Card/Content/Credits").visible)
	assert_true(card.get_node("Root/Card/Content/Thanks").visible)
	assert_false(tree.paused)


func test_door_burst_reuses_blood_and_reduced_scares() -> void:
	var blood := _mount(preload("res://ui/death/blood_overlay.tscn"))
	EventBus.player_death_started.emit(&"door_burst")
	assert_true(blood.get_node("Root").visible)
	assert_true(blood.get_node("Root").material.get_shader_parameter("handprints"))
	EventBus.checkpoint_loaded.emit(&"ch4_407")
	assert_false(blood.get_node("Root").visible)


func test_all_new_ui_translations_have_both_languages() -> void:
	var file := FileAccess.open("res://localization/strings.csv", FileAccess.READ)
	var count := 0
	while not file.eof_reached():
		var row := file.get_csv_line()
		if row.size() >= 1 and row[0].begins_with("UI_CH4_"):
			count += 1
			assert_eq(row.size(), 3, row[0])
			if row.size() == 3:
				assert_false(row[1].is_empty(), row[0] + " vi")
				assert_false(row[2].is_empty(), row[0] + " en")
	assert_true(count >= 26)


func _key(code: Key) -> void:
	var event := InputEventKey.new()
	event.keycode = code
	event.physical_keycode = code
	event.pressed = true
	tree.root.push_input(event, true)
	event.pressed = false
	tree.root.push_input(event, true)


func test_native_enter_escape_reader_lock_and_resume_draft() -> void:
	var player := ReaderPlayer.new()
	player.name = "Player"
	host.add_child(player)
	var pause := _mount(preload("res://ui/pause/pause_menu.tscn"))
	var book := _mount(BOOK)
	EventBus.survivor_form_assembled.emit()
	assert_true(player.locked)
	var form: Node = book.ch4.forms
	form._bite()
	form.editor.entry.text = "Trần Trung"
	_key(KEY_ESCAPE)
	assert_false(tree.paused)
	assert_false(pause._open)
	assert_true(book.is_open())
	assert_false(form.editor.entry.has_focus())
	_key(KEY_ENTER)
	assert_true(form.editor.entry.has_focus())
	_key(KEY_ENTER)
	assert_true(form.editor.waiting)
	assert_eq(form.editor.last_text, "Trần Trung")
	EventBus.blood_name_closed.emit(&"wrong")
	assert_true(form.editor.entry.has_focus())
	EventBus.blood_name_closed.emit(&"timeout")
	_key(KEY_ESCAPE)
	assert_false(book.is_open())
	assert_false(player.locked)
	assert_eq(ownership, [true, false, true, false, true, false])


func test_saved_underline_and_papers_survive_remount_and_locale_change() -> void:
	GameState.set_flag(&"ch4_compare_enabled", true)
	GameState.set_flag(&"ch4_ui_marked_rule", "ch3_r5_2")
	GameState.set_flag(&"ch4_ui_scrap_2", true)
	var book := _mount(BOOK)
	assert_eq(book.ch4.matched, &"ch3_r5_2")
	assert_eq(book.ch4.forms.scraps, [2])
	assert_eq(book.ch4.feedback, "UI_CH4_NOTE_REDUNDANT")
	book.open_notebook()
	book.ch4.select_tab(1)
	TranslationServer.set_locale("en")
	await wait_frames(2)
	assert_eq(book.ch4.matched, &"ch3_r5_2")
	assert_true(book.ch4.compare.get_node("Round5").get_child(0).get_node("ch3_r5_2").text.begins_with("Hurry"))
