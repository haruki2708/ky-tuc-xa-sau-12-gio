extends TestCase

const PHONE = preload("res://ui/phone/phone_screen.tscn")
const PREVIEW = preload("res://scripts/ui/phone_preview.gd")
var host: Node
var phone: CanvasLayer
var _saved: Dictionary
var _mouse: Input.MouseMode
var _locale: String
var _reduce: bool
var _subtitles: Array = []
var _noise: Array = []

class Feed:
	extends Node
	var camera_id: StringName = &"102"
	var label_key := "UI_CCTV_PREVIEW_LABEL"
	var texture: Texture2D = GradientTexture2D.new()
	func _ready() -> void:
		add_to_group("cctv_feed")
	func get_texture() -> Texture2D:
		return texture


func before_each() -> void:
	_saved = GameState.to_dict()
	_mouse = Input.mouse_mode
	_locale = TranslationServer.get_locale()
	_reduce = Settings.get_value("accessibility", "reduce_scares")
	GameState.reset()
	tree.paused = false
	host = Node.new()
	tree.root.add_child(host)
	phone = PHONE.instantiate()
	phone.set_script(PREVIEW)
	host.add_child(phone)
	phone.set_process(false)
	phone.get_node("Root").set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT)
	phone.get_node("Root").size = Vector2(1920, 1080)
	_subtitles.clear()
	_noise.clear()
	EventBus.subtitle_requested.connect(_subtitle)
	EventBus.noise_emitted.connect(_on_noise)


func after_each() -> void:
	host.queue_free()
	await wait_frames(2)
	EventBus.subtitle_requested.disconnect(_subtitle)
	EventBus.noise_emitted.disconnect(_on_noise)
	GameState.from_dict(_saved)
	Input.mouse_mode = _mouse
	TranslationServer.set_locale(_locale)
	Settings.set_value("accessibility", "reduce_scares", _reduce)
	Input.action_release("move_forward")
	tree.paused = false


func _subtitle(key: String, _duration: float) -> void:
	_subtitles.append(key)


func _on_noise(position: Vector3, radius: float, source: StringName) -> void:
	_noise.append([position, radius, source])


func _connect_call() -> void:
	EventBus.phone_call_incoming.emit(&"test_call")
	EventBus.phone_call_answered.emit(&"test_call")


func test_lost_call_drops_spoken_lines_and_reconnects_once_with_live_translation() -> void:
	_connect_call()
	EventBus.phone_message_received.emit(&"preview_a")
	EventBus.phone_call_lost.emit(&"other")
	assert_false(phone.state.connection_lost)
	EventBus.phone_call_lost.emit(&"test_call")
	EventBus.phone_message_received.emit(&"preview_b")
	assert_eq(phone.state.history.size(), 1)
	assert_eq(_subtitles.size(), 1)
	assert_true(is_equal_approx(phone.get_node("Root/Phone/Content/MembersScroll").modulate.a, 0.35))
	var saved: Dictionary = JSON.parse_string(JSON.stringify(phone.snapshot()))
	phone.restore(saved)
	assert_true(phone.state.connection_lost)
	EventBus.phone_message_received.emit(&"preview_b")
	assert_eq(_subtitles.size(), 1)
	EventBus.phone_call_restored.emit(&"other")
	assert_true(phone.state.connection_lost)
	EventBus.phone_call_restored.emit(&"test_call")
	EventBus.phone_call_restored.emit(&"test_call")
	assert_eq(phone.state.history.size(), 2)
	assert_eq(phone.state.history[1].text_key, "UI_PHONE_RECONNECTED")
	assert_eq(phone.get_node("Root/Phone/Content/MembersScroll").modulate.a, 1.0)
	EventBus.phone_message_received.emit(&"preview_b")
	assert_eq(_subtitles.size(), 2)
	TranslationServer.set_locale("en")
	await wait_frames(2)
	assert_true(phone.get_node("Root/Phone/Content/Transcript").get_parsed_text().contains("Reconnected"))
	assert_eq(_subtitles.size(), 2)


func test_map_keyboard_mouse_toggle_snapshot_and_choices_keep_movement() -> void:
	EventBus.phone_raised.emit(true)
	Input.action_press("move_forward")
	_key(KEY_BRACKETRIGHT)
	assert_eq(phone.state.tab, 1)
	assert_eq(phone.tools_view._grid.get_child_count(), 48)
	await wait_frames(3)
	assert_true(phone.get_node("Root/Phone").get_global_rect().end.y < 968.0)
	_key(KEY_ENTER) # Initial cursor is room 407.
	assert_eq(phone.state.marked_rooms, [407])
	phone.tools_view._grid.get_child(0).pressed.emit()
	assert_true(phone.state.marked_rooms.has(101))
	var saved: Dictionary = JSON.parse_string(JSON.stringify(phone.snapshot()))
	phone.tools_view.toggle_room(407)
	phone.restore(saved)
	assert_eq(phone.state.marked_rooms, [407, 101])
	assert_eq(phone.state.tab, 1)
	EventBus.chat_choice_requested.emit(&"choice", PackedStringArray(["UI_PHONE_PREVIEW_OPTION_1", "UI_PHONE_PREVIEW_OPTION_2"]))
	_key(KEY_2)
	assert_eq(phone.state.choice, "")
	assert_true(Input.is_action_pressed("move_forward"))
	assert_false(tree.paused)
	assert_eq(Input.mouse_mode, _mouse)
	phone.restore({"version": 1})
	assert_false(phone.state.connection_lost)
	assert_true(phone.state.marked_rooms.is_empty())
	assert_eq(phone.state.tab, 0)


func test_camera_unlock_focus_feeds_snapshot_and_reduced_scare() -> void:
	var a := Feed.new()
	var b := Feed.new()
	b.camera_id = &"306"
	host.add_child(a)
	host.add_child(b)
	phone.tools_view.select_tab(2)
	assert_eq(phone.state.tab, 0)
	EventBus.cctv_unlocked.emit()
	EventBus.phone_raised.emit(true)
	phone.tools_view.select_tab(2)
	assert_eq(phone.tools_view._feed.texture, a.texture)
	_key(KEY_PERIOD)
	assert_eq(phone.state.camera_id, "306")
	EventBus.cctv_focus_requested.emit(&"102")
	assert_eq(phone.state.camera_id, "102")
	assert_true(phone.tools_view._notice.visible)
	EventBus.phone_raised.emit(false)
	EventBus.cctv_focus_requested.emit(&"306")
	assert_false(phone.state.raised)
	assert_eq(phone.state.camera_id, "102")
	phone.restore(JSON.parse_string(JSON.stringify(phone.snapshot())))
	assert_true(phone.state.camera_unlocked)
	assert_eq(phone.state.camera_id, "102")
	Settings.set_value("accessibility", "reduce_scares", true)
	EventBus.scare_triggered.emit(&"cctv_kill")
	assert_true(phone.tools_view._feed.material.get_shader_parameter("obscured"))
	phone._process(1.49)
	assert_true(phone.tools_view._feed.material.get_shader_parameter("obscured"))
	phone._process(0.02)
	assert_false(phone.tools_view._feed.material.get_shader_parameter("obscured"))
	host.remove_child(a)
	a.free()
	phone.tools_view.refresh()
	assert_eq(phone.tools_view._feed.texture, null)


func test_limited_lock_three_submissions_noise_position_checkpoint_and_countdown() -> void:
	var player := Node3D.new()
	player.name = "Player"
	player.position = Vector3(12, 4, -3)
	host.add_child(player)
	var panel: CanvasLayer = load("res://ui/puzzle/puzzle_panel.tscn").instantiate()
	host.add_child(panel)
	panel.set_process(false)
	var data := PuzzleData.new()
	data.id = &"ui_limited"
	data.solution = "2109"
	data.title_key = "PUZZLE_LOCKER_DAT_TITLE"
	data.max_attempts = 3
	data.lockout_seconds = 60.0
	assert_true(panel.open_puzzle(data))
	assert_false(panel.get_node("Root/Card/Content/Hint").visible)
	for index in 4:
		panel._turn(index, 1)
	assert_eq(GameState.get_flag(&"puzzle_attempts_ui_limited", 0), 0)
	panel._submit()
	panel._submit()
	assert_eq(GameState.get_flag(&"puzzle_attempts_ui_limited"), 2)
	panel.close_view()
	var saved: Dictionary = JSON.parse_string(JSON.stringify(GameState.to_dict()))
	GameState.reset()
	GameState.from_dict(saved)
	EventBus.checkpoint_loaded.emit(&"test")
	panel.open_puzzle(data)
	for index in 4:
		panel._turn(index, 1)
	panel._submit()
	assert_true(panel._locked())
	assert_eq(_noise, [[Vector3(12, 4, -3), 12.0, &"alarm"]])
	panel._submit()
	panel._turn(0, 1)
	assert_eq(panel._digits[0], 0)
	assert_eq(_noise.size(), 1)
	panel._process(1.1)
	assert_true(panel.get_node("Root/Card/Content/Feedback").text.contains("59"))
	panel.close_view()
	saved = JSON.parse_string(JSON.stringify(GameState.to_dict()))
	GameState.from_dict(saved)
	EventBus.checkpoint_loaded.emit(&"test")
	panel.open_puzzle(data)
	assert_true(panel._locked())
	assert_eq(_noise.size(), 1, "restoring a jam does not replay the alarm")
	panel.close_view()
	panel._process(59.0)
	panel.open_puzzle(data)
	assert_false(panel._locked())
	assert_eq(GameState.get_flag(&"puzzle_attempts_ui_limited"), 0)
	for index in 4:
		for step in int(data.solution[index]) + 1:
			panel._turn(index, 1)
	panel._submit()
	assert_true(panel._solved)


func test_blood_death_kinds_reduced_mode_and_lifecycle() -> void:
	var blood: CanvasLayer = load("res://ui/death/blood_overlay.tscn").instantiate()
	host.add_child(blood)
	blood.set_process(false)
	Settings.set_value("accessibility", "reduce_scares", false)
	EventBus.player_death_started.emit(&"manager_kill")
	assert_true(blood.get_node("Root").visible)
	assert_eq(blood.layer, 29)
	assert_true(blood.get_node("Root").material.get_shader_parameter("splash"))
	assert_eq(blood.get_node("Root").material.get_shader_parameter("elapsed"), 0.0)
	blood._process(0.5)
	Settings.set_value("accessibility", "reduce_scares", true)
	assert_true(blood.get_node("Root").material.get_shader_parameter("reduced"))
	EventBus.checkpoint_loaded.emit(&"test")
	assert_false(blood.get_node("Root").visible)
	for kind: StringName in [&"fall_back", &"bed_burst"]:
		EventBus.player_death_started.emit(kind)
		assert_true(blood.get_node("Root").visible)
		assert_false(blood.get_node("Root").material.get_shader_parameter("splash"))
	EventBus.chapter_started.emit(1)
	assert_false(blood.get_node("Root").visible)
	EventBus.player_death_started.emit(&"none")
	assert_false(blood.get_node("Root").visible)
	assert_false(tree.paused)


func _key(code: Key) -> void:
	var event := InputEventKey.new()
	event.physical_keycode = code
	event.pressed = true
	tree.root.push_input(event, true)
	event.pressed = false
	tree.root.push_input(event, true)
