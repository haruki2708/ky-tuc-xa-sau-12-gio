extends TestCase

const LocaleSettings = preload("res://scripts/ui/locale_settings.gd")
const SettingsStore = preload("res://scripts/ui/settings.gd")
const HUD_SCENE = preload("res://ui/hud/hud.tscn")
const FONT = preload("res://assets/fonts/be_vietnam_pro_regular.ttf")

var _hud: CanvasLayer
var _previous_locale: String
var _had_settings: bool
var _settings_backup: PackedByteArray
var _audio_backup: AudioBusLayout


func before_each() -> void:
	_previous_locale = TranslationServer.get_locale()
	_audio_backup = AudioServer.generate_bus_layout()
	_had_settings = FileAccess.file_exists(LocaleSettings.SETTINGS_PATH)
	if _had_settings:
		_settings_backup = FileAccess.get_file_as_bytes(LocaleSettings.SETTINGS_PATH)
	# Isolate settings tests and restore the user's exact file after each test.
	var config := ConfigFile.new()
	config.set_value("ui", "locale", "vi")
	assert_eq(config.save(LocaleSettings.SETTINGS_PATH), OK, "prepare settings;")
	_apply_startup_settings()
	_hud = HUD_SCENE.instantiate()
	tree.root.add_child(_hud)


func after_each() -> void:
	_hud.queue_free()
	await wait_frames(2)
	if _had_settings:
		var file := FileAccess.open(LocaleSettings.SETTINGS_PATH, FileAccess.WRITE)
		file.store_buffer(_settings_backup)
		file.close()
	else:
		DirAccess.remove_absolute(LocaleSettings.SETTINGS_PATH)
	TranslationServer.set_locale(_previous_locale)
	AudioServer.set_bus_layout(_audio_backup)


func _apply_startup_settings() -> void:
	# Startup moved from HUD to Settings in T-116; retain the T-104 guarantees.
	var settings := SettingsStore.new()
	settings.apply_startup()
	settings.free()


func test_font_has_vietnamese_glyphs() -> void:
	# Include the complete precomposed Vietnamese alphabet and required samples.
	var characters := "ạằẵữỹđĐơưăâêôĂÂÊÔƠƯáàảãạấầẩẫậắằẳẵặéèẻẽẹếềểễệíìỉĩịóòỏõọốồổỗộớờởỡợúùủũụứừửữựýỳỷỹỵÁÀẢÃẠẤẦẨẪẬẮẰẲẴẶÉÈẺẼẸẾỀỂỄỆÍÌỈĨỊÓÒỎÕỌỐỒỔỖỘỚỜỞỠỢÚÙỦŨỤỨỪỬỮỰÝỲỶỸỴ"
	for index in characters.length():
		assert_true(FONT.has_char(characters.unicode_at(index)), "missing glyph " + characters[index])
	var theme: Theme = load("res://ui/theme/main_theme.tres")
	assert_eq(theme.default_font, FONT, "theme uses bundled font;")


func test_focus_signal_updates_prompt_and_crosshair() -> void:
	var prompt: Label = _hud.get_node("Root/Prompt")
	var crosshair: ColorRect = _hud.get_node("Root/Crosshair")
	var idle_color := crosshair.color
	assert_false(prompt.visible, "prompt starts hidden")
	EventBus.interaction_focus_changed.emit("PROMPT_INTERACT")
	assert_true(prompt.visible, "focused prompt visible")
	assert_eq(prompt.text, "[E] Tương tác")
	assert_true(crosshair.color.r > idle_color.r, "focus brightens crosshair")
	EventBus.interaction_focus_changed.emit("")
	assert_false(prompt.visible, "empty focus hides prompt")
	assert_eq(prompt.text, "")
	assert_eq(crosshair.color, idle_color, "focus resets crosshair;")


func test_subtitle_expires() -> void:
	var panel: PanelContainer = _hud.get_node("Root/SubtitleMargin/SubtitlePanel")
	var subtitle: Label = panel.get_node("Subtitle")
	assert_false(panel.visible)
	EventBus.subtitle_requested.emit("SUB_TEST_1", 0.15)
	assert_true(panel.visible)
	assert_eq(subtitle.text, "Phụ đề thử: Kỷ luật · Điểm danh")
	await tree.create_timer(0.3).timeout
	assert_false(panel.visible, "subtitle hides after duration")
	assert_eq(subtitle.text, "")


func test_subtitles_wait_in_fifo_order() -> void:
	var panel: PanelContainer = _hud.get_node("Root/SubtitleMargin/SubtitlePanel")
	var subtitle: Label = panel.get_node("Subtitle")
	var timer: Timer = _hud.get_node("SubtitleTimer")
	EventBus.subtitle_requested.emit("SUB_TEST_1", 0.1)
	EventBus.subtitle_requested.emit("SUB_TEST_2", 0.1)
	EventBus.subtitle_requested.emit("SUB_TEST_1", 0.1)
	assert_eq(subtitle.text, tr("SUB_TEST_1"), "new caption does not replace active one;")
	await timer.timeout
	assert_eq(subtitle.text, tr("SUB_TEST_2"), "second caption;")
	assert_true(panel.visible)
	await timer.timeout
	assert_eq(subtitle.text, tr("SUB_TEST_1"), "third caption;")
	await timer.timeout
	assert_false(panel.visible, "queue drained")


func test_live_locale_updates_prompt_and_queued_subtitles() -> void:
	var prompt: Label = _hud.get_node("Root/Prompt")
	var subtitle: Label = _hud.get_node("Root/SubtitleMargin/SubtitlePanel/Subtitle")
	var timer: Timer = _hud.get_node("SubtitleTimer")
	EventBus.interaction_focus_changed.emit("PROMPT_INTERACT")
	EventBus.subtitle_requested.emit("SUB_TEST_1", 0.5)
	EventBus.subtitle_requested.emit("SUB_TEST_2", 0.5)
	assert_eq(LocaleSettings.set_locale("en"), OK)
	await wait_frames(1)
	assert_eq(prompt.text, "[E] Interact")
	assert_eq(subtitle.text, "Sample subtitle: Discipline · Roll call")
	await timer.timeout
	assert_eq(subtitle.text, "Second sample: Vietnamese text with full diacritics.")
	assert_eq(LocaleSettings.set_locale("vi"), OK)
	await wait_frames(1)
	assert_eq(prompt.text, "[E] Tương tác")
	assert_eq(subtitle.text, "Dòng thử thứ hai: Tiếng Việt có dấu đầy đủ.")


func test_invalid_subtitles_do_not_stall_queue() -> void:
	var panel: PanelContainer = _hud.get_node("Root/SubtitleMargin/SubtitlePanel")
	EventBus.subtitle_requested.emit("", 1.0)
	for duration in [0.0, -1.0, INF, NAN]:
		EventBus.subtitle_requested.emit("SUB_TEST_1", duration)
	assert_false(panel.visible)
	EventBus.subtitle_requested.emit("SUB_TEST_2", 0.1)
	assert_true(panel.visible)
	await tree.create_timer(0.25).timeout
	assert_false(panel.visible)


func test_locale_defaults_to_vi_without_settings() -> void:
	assert_eq(DirAccess.remove_absolute(LocaleSettings.SETTINGS_PATH), OK)
	assert_eq(LocaleSettings.get_locale(), "vi")
	TranslationServer.set_locale("en")
	_apply_startup_settings()
	_hud.free()
	_hud = HUD_SCENE.instantiate()
	tree.root.add_child(_hud)
	assert_eq(TranslationServer.get_locale(), "vi", "Settings applies default on startup;")


func test_locale_persists_and_preserves_other_settings() -> void:
	var config := ConfigFile.new()
	config.set_value("audio", "volume", 0.4)
	assert_eq(config.save(LocaleSettings.SETTINGS_PATH), OK)
	assert_eq(LocaleSettings.set_locale("en"), OK)
	assert_eq(LocaleSettings.get_locale(), "en")
	assert_eq(config.load(LocaleSettings.SETTINGS_PATH), OK)
	assert_eq(config.get_value("ui", "locale"), "en")
	assert_eq(config.get_value("audio", "volume"), 0.4)
	TranslationServer.set_locale("vi")
	_apply_startup_settings()
	_hud.free()
	_hud = HUD_SCENE.instantiate()
	tree.root.add_child(_hud)
	assert_eq(TranslationServer.get_locale(), "en", "Settings restores saved language before HUD;")


func test_hud_does_not_override_locale_and_has_outlined_crosshair() -> void:
	TranslationServer.set_locale("en")
	_hud.free()
	_hud = HUD_SCENE.instantiate()
	tree.root.add_child(_hud)
	assert_eq(TranslationServer.get_locale(), "en", "HUD leaves startup locale to Settings;")
	var crosshair: ColorRect = _hud.get_node("Root/Crosshair")
	var outline: ColorRect = _hud.get_node("Root/CrosshairOutline")
	assert_eq(crosshair.size, Vector2(6, 6))
	assert_eq(outline.size, Vector2(8, 8))
	assert_true(outline.color.r < crosshair.color.r)


func test_invalid_locale_is_rejected_or_defaults_to_vi() -> void:
	assert_eq(LocaleSettings.set_locale("fr"), ERR_INVALID_PARAMETER)
	assert_eq(LocaleSettings.get_locale(), "vi")
	assert_eq(TranslationServer.get_locale(), "vi")
	for invalid_value in ["fr", 123]:
		var config := ConfigFile.new()
		config.set_value("ui", "locale", invalid_value)
		assert_eq(config.save(LocaleSettings.SETTINGS_PATH), OK)
		assert_eq(LocaleSettings.get_locale(), "vi", "invalid stored locale defaults;")


func test_csv_has_unique_keys_and_nonempty_vi_en() -> void:
	var csv := FileAccess.open("res://localization/strings.csv", FileAccess.READ)
	assert_not_null(csv)
	if csv == null:
		return
	assert_eq(csv.get_csv_line(), PackedStringArray(["keys", "vi", "en"]))
	var seen: Dictionary = {}
	while not csv.eof_reached():
		var row := csv.get_csv_line()
		if row.size() == 1 and row[0].is_empty() and csv.eof_reached():
			continue
		assert_eq(row.size(), 3, "CSV column count;")
		if row.size() != 3:
			continue
		for value in row:
			assert_false(value.strip_edges().is_empty(), "empty CSV field: " + row[0])
		assert_false(seen.has(row[0]), "duplicate key " + row[0])
		seen[row[0]] = true


func test_playground_buttons_and_translations() -> void:
	var scene: PackedScene = load("res://ui/hud/hud_test.tscn")
	var playground: Control = scene.instantiate()
	tree.root.add_child(playground)
	var hud: CanvasLayer = playground.get_node("HUD")
	var prompt: Label = hud.get_node("Root/Prompt")
	playground.get_node("Controls/Buttons/Focus").pressed.emit()
	assert_eq(prompt.text, "[E] Tương tác")
	playground.get_node("Controls/Buttons/Subtitles").pressed.emit()
	assert_true(hud.get_node("Root/SubtitleMargin/SubtitlePanel").visible)
	playground.get_node("Controls/Buttons/Language").pressed.emit()
	await wait_frames(1)
	assert_eq(prompt.text, "[E] Interact")
	var button: Button = playground.get_node("Controls/Buttons/Language")
	assert_eq(button.tr(button.text), "Language: VI / EN")
	assert_false(playground.get_node("Controls/SaveError").visible)
	playground.get_node("Controls/Buttons/Focus").pressed.emit()
	assert_false(prompt.visible)
	playground.free()
