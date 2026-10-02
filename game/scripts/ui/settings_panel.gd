extends VBoxContainer
## Shared by the pause menu and the standalone F6 scene.

signal back_requested

const SettingsStore = preload("res://scripts/ui/settings.gd")
const AUDIO_LABELS := {
	"master_db": "UI_AUDIO_MASTER", "ambience_db": "UI_AUDIO_AMBIENCE",
	"sfx_db": "UI_AUDIO_SFX", "footsteps_db": "UI_AUDIO_FOOTSTEPS",
	"voice_db": "UI_AUDIO_VOICE", "music_db": "UI_AUDIO_MUSIC",
}

var _settings: SettingsStore
var _sliders: Dictionary = {}
var _values: Dictionary = {}
var _audio_rows: Dictionary = {}
var _head_bob: CheckButton
var _reduce_scares: CheckButton
var _locale: OptionButton


func _ready() -> void:
	for key: String in AUDIO_LABELS:
		var row := _add_slider($Scroll/Columns/Audio, "audio", key, AUDIO_LABELS[key], 0.5)
		_audio_rows[key] = row
	_add_heading($Scroll/Columns/Other, "UI_SETTINGS_CONTROLS")
	_add_slider($Scroll/Columns/Other, "input", "mouse_sensitivity", "UI_MOUSE_SENSITIVITY", 0.0001)
	_add_heading($Scroll/Columns/Other, "UI_SETTINGS_VIDEO")
	_head_bob = CheckButton.new()
	_head_bob.name = "HeadBob"
	_head_bob.text = "UI_HEAD_BOB"
	_head_bob.toggled.connect(_on_head_bob_changed)
	$Scroll/Columns/Other.add_child(_head_bob)
	_add_slider($Scroll/Columns/Other, "video", "brightness", "UI_BRIGHTNESS", 0.05)
	_add_slider($Scroll/Columns/Other, "video", "ps1_strength", "UI_PS1_STRENGTH", 0.05)
	_add_heading($Scroll/Columns/Other, "UI_SETTINGS_LANGUAGE")
	_locale = OptionButton.new()
	_locale.name = "Locale"
	_locale.item_selected.connect(_on_locale_selected)
	$Scroll/Columns/Other.add_child(_locale)
	var accessibility := VBoxContainer.new()
	accessibility.name = "Accessibility"
	accessibility.add_theme_constant_override("separation", 4)
	$Scroll/Columns/Other.add_child(accessibility)
	_add_heading(accessibility, "UI_SETTINGS_ACCESSIBILITY")
	_reduce_scares = CheckButton.new()
	_reduce_scares.name = "ReduceScares"
	_reduce_scares.text = "UI_REDUCE_SCARES"
	_reduce_scares.toggled.connect(_on_reduce_scares_changed)
	accessibility.add_child(_reduce_scares)
	var description := Label.new()
	description.name = "Description"
	description.text = "UI_REDUCE_SCARES_DESCRIPTION"
	description.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	description.add_theme_font_size_override("font_size", 22)
	accessibility.add_child(description)
	$Footer/Reset.pressed.connect(_on_reset_pressed)
	$Footer/Back.pressed.connect(func() -> void: back_requested.emit())
	EventBus.settings_changed.connect(_on_settings_changed)
	AudioServer.bus_layout_changed.connect(refresh)
	AudioServer.bus_renamed.connect(refresh.unbind(3))


func configure(settings: SettingsStore) -> void:
	_settings = settings
	refresh()


func refresh() -> void:
	if _settings == null or not is_node_ready():
		return
	for id: String in _sliders:
		var parts := id.split("/")
		var value: float = _settings.get_value(parts[0], parts[1])
		var slider: HSlider = _sliders[id]
		slider.set_value_no_signal(value)
		var label: Label = _values[id]
		if parts[0] == "audio":
			label.text = tr("UI_AUDIO_MUTED") if value <= -40.0 else tr("UI_AUDIO_DB_VALUE") % value
		elif parts[0] == "input":
			label.text = "%.4f" % value
		else:
			label.text = "%.2f" % value
	for key: String in _audio_rows:
		var row: Control = _audio_rows[key]
		row.visible = AudioServer.get_bus_index(SettingsStore.AUDIO_BUSES[key]) >= 0
	_head_bob.set_pressed_no_signal(_settings.get_value("video", "head_bob"))
	_reduce_scares.set_pressed_no_signal(_settings.get_value("accessibility", "reduce_scares"))
	_locale.clear()
	_locale.add_item(tr("UI_LANGUAGE_VI"))
	_locale.add_item(tr("UI_LANGUAGE_EN"))
	_locale.select(0 if _settings.get_value("ui", "locale") == "vi" else 1)


func _notification(what: int) -> void:
	if what == NOTIFICATION_TRANSLATION_CHANGED and is_node_ready():
		refresh()


func _add_heading(parent: Control, text_key: String) -> void:
	var label := Label.new()
	label.text = text_key
	label.add_theme_font_size_override("font_size", 30)
	parent.add_child(label)


func _add_slider(parent: Control, section: String, key: String, text_key: String, step: float) -> VBoxContainer:
	var row := VBoxContainer.new()
	row.name = key
	row.add_theme_constant_override("separation", 4)
	parent.add_child(row)
	var header := HBoxContainer.new()
	row.add_child(header)
	var label := Label.new()
	label.text = text_key
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(label)
	var value_label := Label.new()
	value_label.custom_minimum_size.x = 125.0
	value_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	header.add_child(value_label)
	var slider := HSlider.new()
	slider.name = "Slider"
	slider.min_value = SettingsStore.SCHEMA[section][key]["min"]
	slider.max_value = SettingsStore.SCHEMA[section][key]["max"]
	slider.step = step
	slider.custom_minimum_size.y = 28.0
	slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	slider.value_changed.connect(_on_slider_changed.bind(section, key))
	row.add_child(slider)
	_sliders[section + "/" + key] = slider
	_values[section + "/" + key] = value_label
	return row


func _on_slider_changed(value: float, section: String, key: String) -> void:
	if _settings != null:
		_show_save_result(_settings.set_value(section, key, value))


func _on_head_bob_changed(enabled: bool) -> void:
	if _settings != null:
		_show_save_result(_settings.set_value("video", "head_bob", enabled))


func _on_locale_selected(index: int) -> void:
	if _settings != null:
		_show_save_result(_settings.set_value("ui", "locale", "vi" if index == 0 else "en"))


func _on_reduce_scares_changed(enabled: bool) -> void:
	if _settings != null:
		_show_save_result(_settings.set_value("accessibility", "reduce_scares", enabled))


func _on_reset_pressed() -> void:
	if _settings != null:
		_show_save_result(_settings.reset_defaults())


func _on_settings_changed(_section: String, _key: String) -> void:
	refresh()


func _show_save_result(error: Error) -> void:
	$SaveError.visible = error != OK
	refresh()
