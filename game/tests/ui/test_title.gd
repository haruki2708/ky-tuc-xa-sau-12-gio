extends "res://tests/ui/settings_test_case.gd"

const TITLE = preload("res://ui/title/title_screen.tscn")
const PAUSE = preload("res://ui/pause/pause_menu.tscn")

class FakeApp:
	extends Node
	var saved := false
	var starts: Array[bool] = []
	var quits := 0

	func has_saved_game() -> bool:
		return saved

	func start_game(continue_saved: bool) -> void:
		starts.append(continue_saved)

	func quit() -> void:
		quits += 1

class ReturnSpy:
	extends "res://scripts/ui/pause_menu.gd"
	var title_requests := 0

	func _request_title() -> void:
		title_requests += 1

class FailingSettings:
	extends "res://scripts/ui/settings.gd"

	func set_value(_section: String, _key: String, _value: Variant) -> Error:
		return ERR_CANT_CREATE

var _app: FakeApp
var _title: Control
var _pause: ReturnSpy


func before_each() -> void:
	super.before_each()
	_app = FakeApp.new()
	tree.root.add_child(_app)
	_create_title()


func after_each() -> void:
	_title.get_node("Hum").stop()
	# Let the audio thread release the OGG playback before freeing scene resources.
	await tree.create_timer(0.3, true, false, true).timeout
	if is_instance_valid(_pause):
		_pause.close_menu()
		_pause.queue_free()
	_title.queue_free()
	_app.queue_free()
	await wait_frames(2)
	super.after_each()


func _create_title() -> void:
	_title = TITLE.instantiate()
	_title.settings_path = settings.get_path()
	_title.app_path = _app.get_path()
	tree.root.add_child(_title)
	# Headless uses a square 64x64 window; test the shipped 16:9 UI canvas.
	_title.set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT)
	_title.size = Vector2(1920, 1080)


func test_first_warning_saves_before_signal_and_does_not_repeat() -> void:
	assert_true(_title.get_node("Warning").visible)
	assert_false(_title.get_node("Menu").visible)
	assert_eq(Input.mouse_mode, Input.MOUSE_MODE_VISIBLE)
	assert_eq(settings.get_value("ui", "content_warning_seen"), false)
	var observed: Array = []
	var callback := func(section: String, key: String) -> void:
		var config := ConfigFile.new()
		assert_eq(config.load(SettingsStore.SETTINGS_PATH), OK)
		observed.append([section, key, config.get_value(section, key)])
	EventBus.settings_changed.connect(callback)
	_title.get_node("Warning/Content/Continue").pressed.emit()
	EventBus.settings_changed.disconnect(callback)
	assert_eq(observed, [["ui", "content_warning_seen", true]])
	assert_eq(settings.get_value("accessibility", "reduce_scares"), false)
	assert_true(_title.get_node("Menu").visible)
	_title.free()
	_create_title()
	assert_false(_title.get_node("Warning").visible)
	assert_true(_title.get_node("Menu").visible)
	assert_eq(settings.reset_defaults(), OK)
	assert_eq(settings.get_value("ui", "content_warning_seen"), true,
		"resetting preferences does not erase first-run acknowledgement")


func test_warning_reduce_scares_saves_both_values_and_stops_background_pulse() -> void:
	_title.get_node("Warning/Content/ReduceScares").pressed.emit()
	var config := ConfigFile.new()
	assert_eq(config.load(SettingsStore.SETTINGS_PATH), OK)
	assert_eq(config.get_value("accessibility", "reduce_scares"), true)
	assert_eq(config.get_value("ui", "content_warning_seen"), true)
	assert_true(_title.get_node("Menu").visible)
	assert_eq(_title.get_node("Background").material.get_shader_parameter("animate_light"), false)
	assert_eq(settings.set_value("accessibility", "reduce_scares", false), OK)
	assert_eq(_title.get_node("Background").material.get_shader_parameter("animate_light"), true)


func test_failed_warning_write_stays_visible_without_acknowledging() -> void:
	var failing := FailingSettings.new()
	_title._settings = failing
	_title.get_node("Warning/Content/ReduceScares").pressed.emit()
	assert_true(_title.get_node("Warning").visible)
	assert_true(_title.get_node("Warning/Content/SaveError").visible)
	assert_eq(settings.get_value("ui", "content_warning_seen"), false)
	_title._settings = settings
	failing.free()


func test_continue_visibility_and_new_game_without_save() -> void:
	_title.get_node("Warning/Content/Continue").pressed.emit()
	assert_false(_title.get_node("Menu/Buttons/Continue").visible)
	assert_true(_title.get_node("Menu/Buttons/NewGame").has_focus())
	_title.get_node("Menu/Buttons/NewGame").pressed.emit()
	_title.get_node("Menu/Buttons/NewGame").pressed.emit()
	assert_eq(_app.starts, [false], "transition is requested only once")
	assert_false(_title.get_node("Confirmation").visible)


func test_saved_continue_delegates_to_core_without_confirmation() -> void:
	_app.saved = true
	_title.get_node("Warning/Content/Continue").pressed.emit()
	assert_true(_title.get_node("Menu/Buttons/Continue").visible)
	assert_true(_title.get_node("Menu/Buttons/Continue").has_focus())
	_title.get_node("Menu/Buttons/Continue").pressed.emit()
	assert_eq(_app.starts, [true])


func test_new_game_requires_confirmation_and_escape_cancels() -> void:
	_app.saved = true
	_title.get_node("Warning/Content/Continue").pressed.emit()
	_title.get_node("Menu/Buttons/NewGame").pressed.emit()
	assert_true(_title.get_node("Confirmation").visible)
	assert_false(_title.get_node("Menu").visible)
	assert_true(_app.starts.is_empty())
	assert_true(_title.get_node("Confirmation/Content/Buttons/Cancel").has_focus())
	_key(KEY_ESCAPE)
	assert_true(_title.get_node("Menu").visible)
	assert_true(_app.starts.is_empty())
	_title.get_node("Menu/Buttons/NewGame").pressed.emit()
	_title.get_node("Confirmation/Content/Buttons/Confirm").pressed.emit()
	assert_eq(_app.starts, [false])


func test_keyboard_navigation_settings_live_locale_credits_and_quit() -> void:
	await wait_frames(2)
	_key(KEY_ESCAPE)
	assert_true(_title.get_node("Warning").visible, "Esc does not acknowledge warning")
	_key(KEY_ENTER)
	await wait_frames(2)
	assert_true(_title.get_node("Menu").visible)
	_key(KEY_DOWN)
	assert_true(_title.get_node("Menu/Buttons/Settings").has_focus())
	_key(KEY_ENTER)
	await wait_frames(2)
	assert_true(_title.get_node("SettingsCard").visible)
	_title.get_node("SettingsCard/SettingsPanel/Scroll/Columns/Other/Locale").item_selected.emit(1)
	await wait_frames(1)
	var heading: Label = _title.get_node("Menu/GameTitle")
	assert_eq(heading.tr(heading.text), "The Dorm After Midnight")
	_key(KEY_ESCAPE)
	await wait_frames(2)
	assert_true(_title.get_node("Menu/Buttons/Settings").has_focus())
	_key(KEY_DOWN)
	_key(KEY_ENTER)
	await wait_frames(2)
	assert_true(_title.get_node("Credits").visible)
	assert_eq(settings.set_value("ui", "locale", "vi"), OK)
	await wait_frames(2)
	var scroll: ScrollContainer = _title.get_node("Credits/Content/Scroll")
	_key(KEY_DOWN)
	assert_true(scroll.scroll_vertical > 0, "arrow key scrolls credits")
	_key(KEY_ESCAPE)
	await wait_frames(2)
	assert_true(_title.get_node("Menu/Buttons/Credits").has_focus())
	_key(KEY_ESCAPE)
	assert_true(_title.get_node("Menu/Buttons/Quit").has_focus())
	_key(KEY_ENTER)
	assert_eq(_app.quits, 1)
	assert_true(_app.starts.is_empty())


func test_pause_return_title_requires_confirmation_and_unpauses() -> void:
	_title.hide()
	var instance: CanvasLayer = PAUSE.instantiate()
	instance.set_script(ReturnSpy)
	_pause = instance as ReturnSpy
	_pause.settings_path = settings.get_path()
	tree.root.add_child(_pause)
	_pause.open_menu()
	_pause.get_node("Root/PauseCard/Buttons/ReturnTitle").pressed.emit()
	assert_true(_pause.get_node("Root/Confirmation").visible)
	assert_eq(_pause.title_requests, 0)
	_key(KEY_ESCAPE)
	assert_true(tree.paused, "cancel stays paused")
	assert_true(_pause.get_node("Root/PauseCard").visible)
	assert_eq(_pause.title_requests, 0)
	_pause.get_node("Root/PauseCard/Buttons/ReturnTitle").pressed.emit()
	_pause.get_node("Root/Confirmation/Content/Buttons/Cancel").pressed.emit()
	assert_eq(_pause.title_requests, 0)
	_pause.get_node("Root/PauseCard/Buttons/ReturnTitle").pressed.emit()
	_pause.get_node("Root/Confirmation/Content/Buttons/Confirm").pressed.emit()
	assert_eq(_pause.title_requests, 1)
	assert_false(tree.paused)
	assert_false(_pause.get_node("Root").visible)


func _key(code: Key) -> void:
	var event := InputEventKey.new()
	event.keycode = code
	event.physical_keycode = code
	event.pressed = true
	tree.root.push_input(event, true)
	event.pressed = false
	tree.root.push_input(event, true)
