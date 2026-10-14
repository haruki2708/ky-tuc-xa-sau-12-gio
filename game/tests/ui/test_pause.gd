extends "res://tests/ui/settings_test_case.gd"

const PAUSE_SCENE = preload("res://ui/pause/pause_menu.tscn")
var _menu: CanvasLayer


func before_each() -> void:
	super.before_each()
	_menu = PAUSE_SCENE.instantiate()
	_menu.settings_path = settings.get_path()
	tree.root.add_child(_menu)


func after_each() -> void:
	_menu.close_menu()
	_menu.queue_free()
	await wait_frames(2)
	super.after_each()


func test_escape_pauses_and_resumes_with_signals() -> void:
	var observed: Array = []
	var callback := func(paused: bool) -> void: observed.append([paused, tree.paused])
	EventBus.game_paused.connect(callback)
	assert_eq(_menu.process_mode, Node.PROCESS_MODE_ALWAYS)
	_press_escape()
	assert_true(tree.paused)
	assert_true(_menu.get_node("Root").visible)
	assert_eq(Input.mouse_mode, Input.MOUSE_MODE_VISIBLE)
	_press_escape()
	assert_false(tree.paused)
	assert_false(_menu.get_node("Root").visible)
	EventBus.game_paused.disconnect(callback)
	assert_eq(observed, [[true, true], [false, false]])


func test_resume_button_and_repeated_calls_emit_once() -> void:
	var observed: Array = []
	var callback := func(paused: bool) -> void: observed.append(paused)
	EventBus.game_paused.connect(callback)
	_menu.open_menu()
	_menu.open_menu()
	_menu.get_node("Root/PauseCard/Buttons/Resume").pressed.emit()
	_menu.close_menu()
	EventBus.game_paused.disconnect(callback)
	assert_false(tree.paused)
	assert_eq(observed, [true, false])


func test_key_echo_does_not_toggle_and_escape_closes_settings() -> void:
	_press_escape()
	var echo := InputEventKey.new()
	echo.physical_keycode = KEY_ESCAPE
	echo.pressed = true
	echo.echo = true
	tree.root.push_input(echo, true)
	assert_true(tree.paused, "key repeat cannot close menu")
	_menu.get_node("Root/PauseCard/Buttons/Settings").pressed.emit()
	assert_true(_menu.get_node("Root/SettingsCard").visible)
	_press_escape()
	assert_false(tree.paused)


func test_back_returns_to_pause_without_resuming() -> void:
	_menu.open_menu()
	_menu.get_node("Root/PauseCard/Buttons/Settings").pressed.emit()
	_menu.get_node("Root/SettingsCard/SettingsPanel/Footer/Back").pressed.emit()
	assert_true(tree.paused)
	assert_true(_menu.get_node("Root/PauseCard").visible)
	assert_false(_menu.get_node("Root/SettingsCard").visible)


func test_missing_bus_slider_hidden_and_late_bus_applies_saved_volume() -> void:
	var existing := AudioServer.get_bus_index("Footsteps")
	if existing >= 0:
		AudioServer.set_bus_name(existing, "HiddenForUITest")
	_menu.open_menu()
	_menu.show_settings()
	var panel: VBoxContainer = _menu.get_node("Root/SettingsCard/SettingsPanel")
	var row: Control = panel.get_node("Scroll/Columns/Audio/footsteps_db")
	assert_false(row.visible, "missing Footsteps bus is hidden")
	assert_true(panel.get_node("Scroll/Columns/Audio/sfx_db").visible)
	assert_eq(settings.set_value("audio", "footsteps_db", -12.0), OK)
	AudioServer.add_bus()
	var added := AudioServer.bus_count - 1
	AudioServer.set_bus_name(added, "Footsteps")
	await wait_frames(1)
	assert_true(row.visible, "new bus slider becomes available")
	assert_eq(AudioServer.get_bus_volume_db(added), -12.0)


func test_controls_save_live_while_paused_and_reset_restores_defaults() -> void:
	_menu.open_menu()
	_menu.show_settings()
	var panel: VBoxContainer = _menu.get_node("Root/SettingsCard/SettingsPanel")
	panel.get_node("Scroll/Columns/Audio/sfx_db/Slider").value = -40.0
	panel.get_node("Scroll/Columns/Other/mouse_sensitivity/Slider").value = 0.004
	panel.get_node("Scroll/Columns/Other/HeadBob").button_pressed = false
	panel.get_node("Scroll/Columns/Other/brightness/Slider").value = 1.25
	panel.get_node("Scroll/Columns/Other/ps1_strength/Slider").value = 0.6
	panel.get_node("Scroll/Columns/Other/Locale").item_selected.emit(1)
	await wait_frames(1)
	assert_true(tree.paused)
	assert_eq(settings.get_value("input", "mouse_sensitivity"), 0.004)
	assert_eq(settings.get_value("video", "head_bob"), false)
	assert_eq(settings.get_value("video", "brightness"), 1.25)
	assert_eq(settings.get_value("video", "ps1_strength"), 0.6)
	assert_eq(TranslationServer.get_locale(), "en")
	assert_true(AudioServer.is_bus_mute(AudioServer.get_bus_index("SFX")))
	assert_eq(panel.get_node("Title").tr("UI_SETTINGS_TITLE"), "Settings")
	panel.get_node("Footer/Reset").pressed.emit()
	assert_eq(TranslationServer.get_locale(), "vi")
	assert_eq(settings.get_value("input", "mouse_sensitivity"), 0.002)
	assert_eq(settings.get_value("video", "head_bob"), true)
	assert_eq(panel.get_node("Scroll/Columns/Other/brightness/Slider").value, 1.0)
	assert_eq(panel.get_node("Scroll/Columns/Other/ps1_strength/Slider").value, 0.0)
	assert_false(AudioServer.is_bus_mute(AudioServer.get_bus_index("SFX")))
	assert_false(panel.get_node("SaveError").visible)


func test_gameplay_timer_stops_while_menu_remains_interactive() -> void:
	var timer := Timer.new()
	timer.one_shot = true
	timer.wait_time = 0.5
	tree.root.add_child(timer)
	timer.start()
	_menu.open_menu()
	var remaining := timer.time_left
	await tree.create_timer(0.1, true).timeout
	assert_eq(timer.time_left, remaining, "gameplay timer frozen;")
	_menu.get_node("Root/PauseCard/Buttons/Resume").pressed.emit()
	await tree.create_timer(0.1, true).timeout
	assert_true(timer.time_left < remaining, "gameplay resumes")
	timer.queue_free()


func test_mouse_can_open_settings_adjust_slider_and_resume() -> void:
	_menu.open_menu()
	await wait_frames(2)
	var settings_button: Button = _menu.get_node("Root/PauseCard/Buttons/Settings")
	_click(settings_button.get_global_rect().get_center())
	await wait_frames(2)
	assert_true(_menu.get_node("Root/SettingsCard").visible)
	var panel: VBoxContainer = _menu.get_node("Root/SettingsCard/SettingsPanel")
	var slider: HSlider = panel.get_node("Scroll/Columns/Audio/sfx_db/Slider")
	var slider_rect := slider.get_global_rect()
	_click(Vector2(slider_rect.position.x + slider_rect.size.x * 0.25, slider_rect.get_center().y))
	assert_true(settings.get_value("audio", "sfx_db") < -10.0, "mouse slider change is saved while paused")
	_click(panel.get_node("Footer/Back").get_global_rect().get_center())
	await wait_frames(1)
	_click(_menu.get_node("Root/PauseCard/Buttons/Resume").get_global_rect().get_center())
	assert_false(tree.paused, "mouse resumes gameplay")


func test_reduce_scares_toggle_persists_before_signal_and_reset_turns_it_off() -> void:
	_menu.open_menu()
	_menu.show_settings()
	var panel: VBoxContainer = _menu.get_node("Root/SettingsCard/SettingsPanel")
	var toggle: CheckButton = panel.get_node("Scroll/Columns/Other/Accessibility/ReduceScares")
	assert_false(toggle.button_pressed)
	assert_eq(settings.get_value("accessibility", "reduce_scares"), false)
	await wait_frames(2)
	panel.get_node("Scroll").ensure_control_visible(toggle)
	await wait_frames(2)
	var observed: Array = []
	var callback := func(section: String, key: String) -> void:
		var saved := ConfigFile.new()
		assert_eq(saved.load(SettingsStore.SETTINGS_PATH), OK)
		observed.append([section, key, saved.get_value(section, key)])
	EventBus.settings_changed.connect(callback)
	_click(toggle.get_global_rect().get_center())
	assert_eq(observed, [["accessibility", "reduce_scares", true]])
	assert_true(toggle.button_pressed)
	assert_true(tree.paused)
	var fresh := SettingsStore.new()
	assert_eq(fresh.get_value("accessibility", "reduce_scares"), true)
	fresh.free()
	_menu.close_menu()
	_menu.open_menu()
	_menu.show_settings()
	assert_true(toggle.button_pressed, "reopening retains the saved setting")
	observed.clear()
	toggle.button_pressed = false
	assert_eq(observed, [["accessibility", "reduce_scares", false]])
	toggle.button_pressed = true
	observed.clear()
	panel.get_node("Footer/Reset").pressed.emit()
	EventBus.settings_changed.disconnect(callback)
	assert_true(observed.has(["accessibility", "reduce_scares", false]))
	assert_eq(settings.get_value("accessibility", "reduce_scares"), false)
	assert_false(toggle.button_pressed)
	assert_false(panel.get_node("SaveError").visible)


func test_reduce_scares_labels_switch_between_vietnamese_and_english() -> void:
	_menu.open_menu()
	_menu.show_settings()
	var panel: VBoxContainer = _menu.get_node("Root/SettingsCard/SettingsPanel")
	var group: VBoxContainer = panel.get_node("Scroll/Columns/Other/Accessibility")
	var heading: Label = group.get_child(0)
	var toggle: CheckButton = group.get_node("ReduceScares")
	var description: Label = group.get_node("Description")
	assert_eq(heading.tr(heading.text), "Trợ năng")
	assert_eq(toggle.tr(toggle.text), "Giảm hù dọa")
	assert_eq(description.tr(description.text), "Bỏ hình ảnh và âm thanh giật mình đột ngột. Truy đuổi chậm hơn.")
	assert_eq(settings.set_value("ui", "locale", "en"), OK)
	await wait_frames(1)
	assert_eq(heading.tr(heading.text), "Accessibility")
	assert_eq(toggle.tr(toggle.text), "Reduce scares")
	assert_eq(description.tr(description.text), "Remove sudden startling visuals and sounds. Slower chases.")
	assert_false(toggle.button_pressed, "changing language must not enable the setting")


func test_removing_open_menu_resumes_tree() -> void:
	_menu.open_menu()
	tree.root.remove_child(_menu)
	assert_false(tree.paused)


func test_reset_video_requires_confirmation_and_keeps_nonvideo_preferences() -> void:
	settings.set_value("ui", "locale", "en")
	settings.set_value("audio", "sfx_db", -12.0)
	settings.set_value("input", "mouse_sensitivity", 0.004)
	settings.set_value("accessibility", "reduce_scares", true)
	settings.set_value("video", "brightness", 1.4)
	settings.set_value("video", "head_bob", false)
	settings.set_value("video", "ps1_strength", 0.6)
	_menu.open_menu()
	_menu.show_settings()
	var panel := _menu.get_node("Root/SettingsCard/SettingsPanel")
	var dialog: ConfirmationDialog = panel.get_node("ResetVideoConfirmation")
	panel.get_node("Footer/ResetVideo").pressed.emit()
	assert_true(dialog.visible)
	assert_eq(dialog.title, "Reset video")
	assert_eq(settings.get_value("video", "brightness"), 1.4)
	dialog.get_cancel_button().pressed.emit()
	await wait_frames(2)
	assert_false(dialog.visible, "cancel closes the confirmation without a reset")
	assert_true(panel.get_node("Footer/ResetVideo").has_focus(), "cancel returns keyboard focus")
	assert_eq(settings.get_value("video", "brightness"), 1.4)
	panel.get_node("Footer/ResetVideo").pressed.emit()
	dialog.get_ok_button().pressed.emit()
	assert_eq(settings.get_value("video", "brightness"), 1.0)
	assert_eq(settings.get_value("video", "head_bob"), true)
	assert_eq(settings.get_value("video", "ps1_strength"), 0.0)
	assert_eq(settings.get_value("ui", "locale"), "en")
	assert_eq(settings.get_value("audio", "sfx_db"), -12.0)
	assert_eq(settings.get_value("input", "mouse_sensitivity"), 0.004)
	assert_eq(settings.get_value("accessibility", "reduce_scares"), true)
	assert_true(tree.paused)
	assert_false(panel.get_node("SaveError").visible, "successful video reset hides the save error")


func _click(position: Vector2) -> void:
	var motion := InputEventMouseMotion.new()
	motion.position = position
	tree.root.push_input(motion, true)
	var event := InputEventMouseButton.new()
	event.position = position
	event.button_index = MOUSE_BUTTON_LEFT
	event.pressed = true
	tree.root.push_input(event, true)
	event.pressed = false
	tree.root.push_input(event, true)


func _press_escape() -> void:
	var event := InputEventKey.new()
	event.physical_keycode = KEY_ESCAPE
	event.pressed = true
	tree.root.push_input(event, true)
	event.pressed = false
	tree.root.push_input(event, true)
