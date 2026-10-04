extends TestCase

const PHONE = preload("res://ui/phone/phone_screen.tscn")
const PREVIEW = preload("res://scripts/ui/phone_preview.gd")
var OPTIONS := PackedStringArray(["UI_PHONE_PREVIEW_OPTION_1", "UI_PHONE_PREVIEW_OPTION_2",
	"UI_PHONE_PREVIEW_OPTION_3", "UI_PHONE_PREVIEW_OPTION_4"])

var phone: CanvasLayer
var _locale: String
var _mouse: Input.MouseMode
var _paused: bool
var _answers: Array = []
var _choices: Array = []
var _subtitles: Array = []


func before_each() -> void:
	_locale = TranslationServer.get_locale()
	_mouse = Input.mouse_mode
	_paused = tree.paused
	TranslationServer.set_locale("vi")
	_answers.clear()
	_choices.clear()
	_subtitles.clear()
	phone = PHONE.instantiate()
	phone.set_script(PREVIEW)
	tree.root.add_child(phone)
	phone.set_process(false)
	phone.get_node("Root").set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT)
	phone.get_node("Root").size = Vector2(1920, 1080)
	EventBus.phone_call_answered.connect(_answer)
	EventBus.chat_choice_made.connect(_choice)
	EventBus.subtitle_requested.connect(_subtitle)


func after_each() -> void:
	EventBus.phone_call_answered.disconnect(_answer)
	EventBus.chat_choice_made.disconnect(_choice)
	EventBus.subtitle_requested.disconnect(_subtitle)
	phone.queue_free()
	await wait_frames(2)
	TranslationServer.set_locale(_locale)
	Input.mouse_mode = _mouse
	Input.action_release("move_forward")
	Input.action_release("interact")
	tree.paused = _paused


func _answer(id: StringName) -> void:
	_answers.append(id)


func _choice(id: StringName, index: int) -> void:
	_choices.append([id, index])


func _subtitle(key: String, _duration: float) -> void:
	_subtitles.append(key)


func test_phone_visibility_status_and_gameplay_ownership() -> void:
	assert_false(phone.get_node("Root/Phone").visible)
	var mode := Input.mouse_mode
	Input.action_press("move_forward")
	EventBus.phone_raised.emit(true)
	EventBus.time_changed.emit(247)
	EventBus.phone_battery_changed.emit(63.0)
	EventBus.flashlight_toggled.emit(true)
	assert_true(phone.get_node("Root/Phone").visible)
	assert_eq(Input.mouse_mode, mode)
	assert_true(Input.is_action_pressed("move_forward"))
	assert_false(tree.paused)
	assert_true(phone.get_node("Root/Phone/Content/Status").text.contains("04:07"))
	assert_true(phone.get_node("Root/Phone/Content/Status").text.contains("63%"))
	assert_true(phone.get_node("Root/Phone/Content/Status").text.contains("Không có sóng"))
	assert_true(phone.state.flashlight)
	await wait_frames(2)
	var rect: Rect2 = phone.get_node("Root/Phone").get_global_rect()
	assert_true(absf(rect.size.y - 1080.0 * 0.35) < 1.0)
	assert_true(rect.end.y < 968.0, "phone leaves the normal HUD subtitle strip clear")
	EventBus.phone_raised.emit(false)
	assert_false(phone.get_node("Root/Phone").visible)


func test_modal_panels_hide_phone_and_restore_it_without_raising_it() -> void:
	EventBus.phone_raised.emit(true)
	EventBus.game_paused.emit(true)
	assert_false(phone.get_node("Root/Phone").visible)
	EventBus.game_paused.emit(false)
	assert_true(phone.get_node("Root/Phone").visible)
	EventBus.document_opened.emit(&"hall_board")
	assert_false(phone.get_node("Root/Phone").visible)
	EventBus.document_closed.emit(&"hall_board")
	EventBus.puzzle_opened.emit(&"preview_lock")
	assert_false(phone.get_node("Root/Phone").visible)
	EventBus.puzzle_solved.emit(&"preview_lock")
	assert_true(phone.get_node("Root/Phone").visible)
	var notebook: CanvasLayer = load("res://ui/notebook/notebook.tscn").instantiate()
	tree.root.add_child(notebook)
	notebook.open_notebook()
	phone._process(0.0)
	assert_false(phone.get_node("Root/Phone").visible)
	notebook.close_view()
	notebook.queue_free()
	phone._process(0.0)
	assert_true(phone.get_node("Root/Phone").visible)
	EventBus.phone_raised.emit(false)
	EventBus.game_paused.emit(true)
	EventBus.game_paused.emit(false)
	assert_false(phone.get_node("Root/Phone").visible)


func test_incoming_banner_while_lowered_and_interact_answers_once() -> void:
	EventBus.phone_call_incoming.emit(&"test_call")
	assert_true(phone.get_node("Root/Incoming").visible)
	assert_false(phone.get_node("Root/Phone").visible)
	_key(KEY_E)
	assert_true(_answers.is_empty())
	EventBus.phone_raised.emit(true)
	Input.action_press("interact")
	_key(KEY_E)
	_key(KEY_E)
	assert_eq(_answers, [&"test_call"])
	assert_false(Input.is_action_pressed("interact"), "answer does not also interact with the world")
	assert_eq(phone.state.call, "test_call")
	assert_false(phone.get_node("Root/Incoming").visible)


func test_transcript_members_subtitles_and_live_locale() -> void:
	EventBus.chat_member_changed.emit(&"preview_a", &"joined")
	EventBus.phone_message_received.emit(&"missing")
	assert_true(phone.state.history.is_empty())
	EventBus.phone_message_received.emit(&"preview_a")
	EventBus.phone_message_received.emit(&"preview_b")
	EventBus.phone_message_received.emit(&"preview_text")
	assert_eq(phone.state.history.size(), 3)
	assert_eq(_subtitles, ["UI_PHONE_PREVIEW_LINE_A", "UI_PHONE_PREVIEW_LINE_B"])
	assert_false(phone.state.raised, "spoken subtitles still arrive while phone is lowered")
	var transcript: RichTextLabel = phone.get_node("Root/Phone/Content/Transcript")
	assert_true(transcript.get_parsed_text().contains("04:05  Người thử A:"))
	EventBus.chat_member_changed.emit(&"preview_a", &"dead")
	var member := phone.get_node("Root/Phone/Content/MembersScroll/Members").get_child(0)
	assert_eq(member.state, "dead")
	assert_true(member.get_node("Name").modulate.r < 0.6)
	assert_true(member.get_child(0).color.r < 0.2)
	TranslationServer.set_locale("en")
	await wait_frames(2)
	assert_true(transcript.get_parsed_text().contains("Test member A:"))
	assert_eq(_subtitles.size(), 2, "translation refresh does not replay subtitles")


func test_choices_raise_phone_number_keys_and_single_completion() -> void:
	EventBus.chat_choice_requested.emit(&"reply", OPTIONS)
	assert_true(phone.state.raised)
	assert_true(phone.get_node("Root/Choices").visible)
	assert_eq(phone.state.remaining, 10.0)
	_key(KEY_3)
	_key(KEY_3)
	assert_eq(_choices, [[&"reply", 2]])
	assert_false(phone.get_node("Root/Choices").visible)
	EventBus.chat_choice_requested.emit(&"short", PackedStringArray([OPTIONS[0], OPTIONS[1]]))
	_key(KEY_4)
	assert_eq(_choices.size(), 1, "out of range option is ignored")
	phone._process(10.0)
	phone._process(10.0)
	assert_eq(_choices, [[&"reply", 2], [&"short", -1]])


func test_choice_timer_waits_for_modal_and_mouse_click_selects() -> void:
	EventBus.chat_choice_requested.emit(&"reply", OPTIONS)
	EventBus.puzzle_opened.emit(&"preview_lock")
	phone._process(20.0)
	_key(KEY_1)
	assert_eq(phone.state.remaining, 10.0)
	assert_true(_choices.is_empty())
	EventBus.puzzle_closed.emit(&"preview_lock")
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	await wait_frames(3)
	var option: Button = phone.get_node("Root/Choices/Content/Options/Option2")
	_mouse_button(MOUSE_BUTTON_LEFT, option.get_global_rect().get_center())
	assert_eq(_choices, [[&"reply", 1]])


func test_wheel_selects_option_and_transcript_scrolls() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	EventBus.chat_choice_requested.emit(&"reply", OPTIONS)
	_mouse_button(MOUSE_BUTTON_WHEEL_DOWN)
	assert_eq(phone.state.selected, 1)
	if DisplayServer.get_name() == "headless":
		# Headless DisplayServer cannot capture a pointer; rendered runs cover this path.
		phone.get_node("Root/Choices/Content/Options/Option2").pressed.emit()
	else:
		assert_eq(Input.mouse_mode, Input.MOUSE_MODE_CAPTURED)
		_mouse_button(MOUSE_BUTTON_LEFT)
	assert_eq(_choices, [[&"reply", 1]])
	for index in 20:
		EventBus.phone_message_received.emit(&"preview_text")
	await wait_frames(3)
	var bar: VScrollBar = phone.get_node("Root/Phone/Content/Transcript").get_v_scroll_bar()
	bar.value = 0
	_mouse_button(MOUSE_BUTTON_WHEEL_DOWN)
	assert_true(bar.value > 0, "wheel scrolls transcript without unlocking mouse")
	for index in 10:
		EventBus.chat_member_changed.emit(StringName("test_member_%d" % index), &"joined")
	await wait_frames(3)
	_mouse_button(MOUSE_BUTTON_WHEEL_DOWN, Vector2(10, 10), true)
	assert_true(phone.get_node("Root/Phone/Content/MembersScroll").scroll_horizontal > 0)


func test_empty_battery_blacks_screen_disconnects_and_times_out_pending_reply() -> void:
	EventBus.phone_call_incoming.emit(&"test_call")
	EventBus.phone_raised.emit(true)
	_key(KEY_E)
	EventBus.chat_choice_requested.emit(&"reply", OPTIONS)
	EventBus.phone_battery_changed.emit(0.0)
	assert_true(phone.get_node("Root/Phone/BlackScreen").visible)
	assert_false(phone.get_node("Root/Choices").visible)
	assert_eq(phone.state.call, "")
	EventBus.phone_message_received.emit(&"preview_a")
	EventBus.phone_call_incoming.emit(&"new_call")
	_key(KEY_1)
	assert_true(phone.state.history.is_empty())
	assert_true(_choices.is_empty())
	phone._process(10.0)
	assert_eq(_choices, [[&"reply", -1]])
	EventBus.phone_battery_changed.emit(20.0)
	assert_false(phone.get_node("Root/Phone/BlackScreen").visible)
	assert_eq(phone.state.call, "", "charging does not resurrect a lost call")


func test_snapshot_json_round_trip_restores_history_members_and_pending_choice_without_signals() -> void:
	EventBus.phone_call_incoming.emit(&"test_call")
	EventBus.phone_raised.emit(true)
	_key(KEY_E)
	EventBus.phone_message_received.emit(&"preview_a")
	EventBus.chat_member_changed.emit(&"preview_a", &"dead")
	EventBus.chat_choice_requested.emit(&"reply", OPTIONS)
	phone._process(3.0)
	var saved: Dictionary = JSON.parse_string(JSON.stringify(phone.snapshot()))
	phone.state.history.clear()
	phone.state.members.clear()
	phone.restore(saved)
	assert_eq(phone.state.history.size(), 1)
	assert_eq(phone.state.members["preview_a"]["state"], "dead")
	assert_eq(phone.state.remaining, 7.0)
	assert_eq(phone.state.call, "test_call")
	assert_eq(_answers.size(), 1)
	assert_eq(_subtitles.size(), 1)
	assert_true(_choices.is_empty())
	phone._process(7.0)
	assert_eq(_choices, [[&"reply", -1]])
	assert_eq(saved["remaining"], 7.0, "snapshot does not alias live state")


func test_hidden_overlay_contracts_with_breath_and_resets_on_exit() -> void:
	EventBus.player_hidden.emit(true, &"bunk")
	assert_true(phone.get_node("Root/HiddenVignette").visible)
	assert_true(phone.get_node("Root/BreathHint").visible)
	EventBus.breath_held.emit(true)
	phone._process(0.5)
	assert_eq(phone.get_node("Root/HiddenVignette").material.get_shader_parameter("contraction"), 1.0)
	EventBus.player_hidden.emit(false, &"bunk")
	phone._process(0.5)
	assert_false(phone.get_node("Root/HiddenVignette").visible)
	assert_eq(phone.get_node("Root/HiddenVignette").material.get_shader_parameter("contraction"), 0.0)


func _key(code: Key) -> void:
	var event := InputEventKey.new()
	event.physical_keycode = code
	event.keycode = code
	event.pressed = true
	tree.root.push_input(event, true)
	event.pressed = false
	tree.root.push_input(event, true)


func _mouse_button(button: MouseButton, position := Vector2(10, 10), shift := false) -> void:
	var event := InputEventMouseButton.new()
	event.button_index = button
	event.position = position
	event.shift_pressed = shift
	event.pressed = true
	tree.root.push_input(event, true)
	event.pressed = false
	tree.root.push_input(event, true)
