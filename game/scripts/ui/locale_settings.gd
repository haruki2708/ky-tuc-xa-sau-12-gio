extends RefCounted
## Compatibility API for T-104 scenes; all writes follow the shared contract.

const SettingsStore = preload("res://scripts/ui/settings.gd")

const SETTINGS_PATH := "user://settings.cfg"
const DEFAULT_LOCALE := "vi"
const SUPPORTED_LOCALES: PackedStringArray = ["vi", "en"]


static func set_locale(code: String) -> Error:
	var settings := SettingsStore.new()
	var error := settings.set_value("ui", "locale", code)
	settings.free()
	return error


static func get_locale() -> String:
	var settings := SettingsStore.new()
	var code: String = settings.get_value("ui", "locale")
	settings.free()
	return code
