extends RefCounted
## Read on HUD startup; save only when the player explicitly selects a language.

const SETTINGS_PATH := "user://settings.cfg"
const DEFAULT_LOCALE := "vi"
const SUPPORTED_LOCALES: PackedStringArray = ["vi", "en"]


static func set_locale(code: String) -> Error:
	if not SUPPORTED_LOCALES.has(code):
		return ERR_INVALID_PARAMETER
	var config := ConfigFile.new()
	var load_error := config.load(SETTINGS_PATH)
	if load_error != OK and load_error != ERR_FILE_NOT_FOUND:
		return load_error
	config.set_value("ui", "locale", code)
	var save_error := config.save(SETTINGS_PATH)
	if save_error == OK:
		TranslationServer.set_locale(code)
	return save_error


static func get_locale() -> String:
	var config := ConfigFile.new()
	if config.load(SETTINGS_PATH) != OK:
		return DEFAULT_LOCALE
	var code: Variant = config.get_value("ui", "locale", DEFAULT_LOCALE)
	if code is String and SUPPORTED_LOCALES.has(code):
		return code
	return DEFAULT_LOCALE
