extends TestCase
## Preserve the user's file byte-for-byte, audio layout, locale and input state.

const SettingsStore = preload("res://scripts/ui/settings.gd")

var settings: SettingsStore
var _had_settings: bool
var _settings_backup: PackedByteArray
var _audio_backup: AudioBusLayout
var _previous_locale: String
var _previous_mouse_mode: Input.MouseMode
var _previous_paused: bool


func before_each() -> void:
	_previous_locale = TranslationServer.get_locale()
	_previous_mouse_mode = Input.mouse_mode
	_previous_paused = tree.paused
	_audio_backup = AudioServer.generate_bus_layout()
	_had_settings = FileAccess.file_exists(SettingsStore.SETTINGS_PATH)
	if _had_settings:
		_settings_backup = FileAccess.get_file_as_bytes(SettingsStore.SETTINGS_PATH)
		assert_eq(DirAccess.remove_absolute(SettingsStore.SETTINGS_PATH), OK)
	settings = SettingsStore.new()
	settings.name = "TestSettings"
	tree.root.add_child(settings)


func after_each() -> void:
	settings.free()
	if _had_settings:
		var file := FileAccess.open(SettingsStore.SETTINGS_PATH, FileAccess.WRITE)
		file.store_buffer(_settings_backup)
		file.close()
	elif FileAccess.file_exists(SettingsStore.SETTINGS_PATH):
		DirAccess.remove_absolute(SettingsStore.SETTINGS_PATH)
	AudioServer.set_bus_layout(_audio_backup)
	TranslationServer.set_locale(_previous_locale)
	Input.mouse_mode = _previous_mouse_mode
	tree.paused = _previous_paused
