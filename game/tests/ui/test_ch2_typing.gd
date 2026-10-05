extends TestCase

const CHAIN = preload("res://ui/chain/chain_panel.tscn")
const PHONE = preload("res://ui/phone/phone_screen.tscn")
var host: Node
var words: Array[String] = []
var predictions: Array[Dictionary] = []
var ownership: Array[bool] = []
var _locale: String
var _mouse: Input.MouseMode


func before_each() -> void:
	_locale = TranslationServer.get_locale()
	_mouse = Input.mouse_mode
	TranslationServer.set_locale("vi")
	tree.paused = false
	host = Node.new()
	tree.root.add_child(host)
	words.clear()
	predictions.clear()
	ownership.clear()
	EventBus.chain_word_typed.connect(_word)
	EventBus.prediction_sent.connect(_prediction)
	EventBus.text_entry_changed.connect(_ownership)


func after_each() -> void:
	host.queue_free()
	await wait_frames(2)
	EventBus.chain_word_typed.disconnect(_word)
	EventBus.prediction_sent.disconnect(_prediction)
	EventBus.text_entry_changed.disconnect(_ownership)
	tree.paused = false
	TranslationServer.set_locale(_locale)
	Input.mouse_mode = _mouse


func _word(text: String) -> void:
	words.append(text)


func _prediction(member: StringName, text: String) -> void:
	predictions.append({"member": member, "text": text})


func _ownership(active: bool) -> void:
	ownership.append(active)


func _mount(scene: PackedScene) -> Node:
	var node := scene.instantiate()
	host.add_child(node)
	node.set_process(false)
	return node


func _key(code: Key, unicode_value: int = 0) -> void:
	var event := InputEventKey.new()
	event.keycode = code
	event.physical_keycode = code
	event.unicode = unicode_value
	event.pressed = true
	tree.root.push_input(event, true)
	event.pressed = false
	tree.root.push_input(event, true)


func test_enter_opens_native_edit_and_submits_verbatim_once() -> void:
	var chain := _mount(CHAIN)
	EventBus.chain_input_requested.emit(15.0)
	var entry: LineEdit = chain.get_node("Root/Card/Content/Entry")
	assert_false(entry.visible)
	_key(KEY_ENTER)
	assert_true(entry.has_focus())
	assert_eq(ownership, [true])
	_key(KEY_ENTER)
	assert_true(entry.has_focus(), "empty Enter keeps the editor focused")
	entry.text = "   "
	_key(KEY_ENTER)
	assert_true(words.is_empty())
	entry.text = "  Vở kịch  "
	_key(KEY_ENTER)
	_key(KEY_ENTER)
	assert_eq(words, ["  Vở kịch  "])
	assert_eq(ownership, [true, false])
	assert_false(entry.visible)
	assert_false(tree.paused)
	assert_eq(Input.mouse_mode, _mouse)
	assert_true(chain.get_node_or_null("Root/Card/Content/Options") == null)


func test_escape_cancels_before_pause_in_both_node_orders() -> void:
	for pause_first in [true, false]:
		var pause: Node
		if pause_first:
			pause = _mount(load("res://ui/pause/pause_menu.tscn"))
		var chain := _mount(CHAIN)
		if not pause_first:
			pause = _mount(load("res://ui/pause/pause_menu.tscn"))
		EventBus.chain_input_requested.emit(15.0)
		_key(KEY_ENTER)
		_key(KEY_ESCAPE)
		assert_false(tree.paused)
		assert_true(chain.is_choosing())
		assert_false(chain.get_node("Root/Card/Content/Entry").visible)
		assert_true(words.is_empty())
		chain.free()
		pause.free()
	assert_eq(ownership, [true, false, true, false])


func test_blocked_can_type_but_not_send_and_clock_still_expires() -> void:
	var chain := _mount(CHAIN)
	EventBus.chain_input_requested.emit(15.0)
	EventBus.chain_choice_blocked.emit(true)
	_key(KEY_ENTER)
	var entry: LineEdit = chain.get_node("Root/Card/Content/Entry")
	entry.text = "khuất bóng"
	_key(KEY_ENTER)
	assert_true(entry.has_focus())
	assert_true(words.is_empty())
	assert_eq(chain.get_node("Root/Card/Content/Status").text, "Họ không nghe thấy bạn")
	chain._process(10.1)
	assert_eq(chain._last_tick, 5)
	chain._process(5.0)
	assert_eq(ownership, [true, false])
	assert_true(words.is_empty())
	EventBus.chain_input_requested.emit(15.0)
	EventBus.chain_choice_blocked.emit(false)
	_key(KEY_ENTER)
	entry.text = "khuất bóng"
	_key(KEY_ENTER)
	assert_eq(words, ["khuất bóng"])


func test_every_chain_close_releases_keyboard_without_correctness_feedback() -> void:
	var chain := _mount(CHAIN)
	for result: StringName in [&"accepted", &"wrong", &"timeout"]:
		EventBus.chain_input_requested.emit(15.0)
		_key(KEY_ENTER)
		EventBus.chain_input_closed.emit(result)
		assert_false(chain.is_choosing())
		assert_false(chain.get_node("Root/Card/Content/Entry").has_focus())
	for signal_name: StringName in [&"player_death_started", &"player_failed", &"checkpoint_loaded"]:
		EventBus.chain_input_requested.emit(15.0)
		_key(KEY_ENTER)
		EventBus.emit_signal(signal_name, &"test")
		assert_false(chain.get_node("Root").visible)
	EventBus.chain_input_requested.emit(15.0)
	_key(KEY_ENTER)
	chain.close_panel()
	assert_eq(ownership, [true, false, true, false, true, false, true, false, true, false, true, false, true, false])


func test_english_labels_keep_dictionary_words_vietnamese() -> void:
	var chain := _mount(CHAIN)
	TranslationServer.set_locale("en")
	EventBus.chain_word_spoken.emit(&"phuc", "WORD_CH2_DIEM_DANH")
	assert_eq(chain.get_node("Root/Card/Content/Word").text, "điểm danh")
	EventBus.chain_word_spoken.emit(&"trung", "khuất bóng")
	assert_eq(chain.get_node("Root/Card/Content/Word").text, "khuất bóng")


func test_prediction_routes_member_and_preserves_literal_history_after_restore() -> void:
	var phone := _mount(PHONE)
	for member: StringName in [&"minh_nhat", &"ngu"]:
		EventBus.prediction_requested.emit(member, PackedInt32Array([38, 16, 75]), 20.0)
		assert_true(phone.state.raised)
		assert_true(phone.prediction.entry.has_focus())
		_key(KEY_ENTER)
		assert_true(phone.prediction.entry.has_focus(), "empty prediction remains editable")
		assert_eq(predictions.size(), 0 if member == &"minh_nhat" else 1)
		phone.prediction.entry.text = " [b]Có[/b]  "
		_key(KEY_ENTER)
		assert_eq(predictions.back(), {"member": member, "text": " [b]Có[/b]  "})
		EventBus.prediction_result.emit(member, false)
		assert_false(phone.prediction.visible)
	assert_eq(ownership, [true, false, true, false])
	phone.restore(JSON.parse_string(JSON.stringify(phone.snapshot())))
	TranslationServer.set_locale("en")
	await wait_frames(2)
	assert_eq(phone.state.history.size(), 2)
	assert_eq(phone.state.history.back().recipient, "ngu")
	assert_true(phone.get_node("Root/Phone/Content/Transcript").get_parsed_text().contains("[b]Có[/b]"))
	assert_false(phone.state.history.back().spoken)


func test_prediction_cancel_timeout_death_checkpoint_and_removal_release_focus() -> void:
	var phone := _mount(PHONE)
	EventBus.prediction_requested.emit(&"ngu", PackedInt32Array([74, 15, 62]), 20.0)
	_key(KEY_ESCAPE)
	assert_eq(phone.prediction.member, &"ngu")
	_key(KEY_ENTER)
	phone.prediction.advance(20.0)
	assert_false(phone.prediction.visible)
	assert_true(predictions.is_empty())
	for signal_name: StringName in [&"player_death_started", &"player_failed", &"checkpoint_loaded"]:
		EventBus.prediction_requested.emit(&"ngu", PackedInt32Array([74, 15, 62]), 20.0)
		EventBus.emit_signal(signal_name, &"test")
		assert_false(phone.prediction.entry.has_focus())
	EventBus.prediction_requested.emit(&"ngu", PackedInt32Array([74, 15, 62]), 20.0)
	phone.free()
	assert_eq(ownership, [true, false, true, false, true, false, true, false, true, false, true, false])


func test_typing_does_not_answer_phone_or_change_tab_and_unicode_is_unfiltered() -> void:
	var chain := _mount(CHAIN)
	var phone := _mount(PHONE)
	EventBus.chat_choice_requested.emit(&"test", PackedStringArray(["UI_YES", "UI_NO"]))
	EventBus.chain_input_requested.emit(15.0)
	_key(KEY_ENTER)
	_key(KEY_1, 49)
	_key(KEY_BRACKETRIGHT, 93)
	_key(KEY_A, "ắ".unicode_at(0))
	assert_eq(chain.get_node("Root/Card/Content/Entry").text, "1]ắ")
	assert_eq(phone.state.choice, "test")
	assert_eq(phone.state.tab, 0)


func test_prediction_pause_hide_and_checkpoint_do_not_leave_keyboard_locked() -> void:
	var phone := _mount(PHONE)
	EventBus.prediction_requested.emit(&"ngu", PackedInt32Array([74, 15, 62]), 20.0)
	EventBus.phone_raised.emit(false)
	assert_eq(ownership, [true, false])
	phone.prediction.advance(2.0)
	assert_eq(phone.prediction.remaining, 18.0)
	EventBus.phone_raised.emit(true)
	_key(KEY_ENTER)
	tree.paused = true
	phone._process(5.0)
	assert_eq(phone.prediction.remaining, 18.0)
	assert_false(phone.prediction.entry.has_focus())
	tree.paused = false
	phone._process(0.0)
	_key(KEY_ENTER)
	EventBus.chapter_started.emit(2)
	assert_false(phone.prediction.visible)
	assert_eq(ownership, [true, false, true, false, true, false])
