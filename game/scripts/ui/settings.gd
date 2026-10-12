extends Node
## Settings contract: docs/SETTINGS.md. Register as Settings after EventBus.
## Read from disk so all consumers observe the same committed configuration.

const SETTINGS_PATH := "user://settings.cfg"
const AUDIO_BUSES := {
	"master_db": "Master", "ambience_db": "Ambience", "sfx_db": "SFX",
	"footsteps_db": "Footsteps", "voice_db": "Voice", "music_db": "Music",
}
const SCHEMA := {
	"ui": {
		"locale": {"default": "vi", "choices": ["vi", "en"]},
		"content_warning_seen": {"default": false},
	},
	"audio": {
		"master_db": {"default": 0.0, "min": -40.0, "max": 6.0},
		"ambience_db": {"default": 0.0, "min": -40.0, "max": 6.0},
		"sfx_db": {"default": 0.0, "min": -40.0, "max": 6.0},
		"footsteps_db": {"default": 0.0, "min": -40.0, "max": 6.0},
		"voice_db": {"default": 0.0, "min": -40.0, "max": 6.0},
		"music_db": {"default": 0.0, "min": -40.0, "max": 6.0},
	},
	"input": {"mouse_sensitivity": {"default": 0.002, "min": 0.0005, "max": 0.006}},
	"accessibility": {"reduce_scares": {"default": false}},
	"video": {
		"head_bob": {"default": true},
		"brightness": {"default": 1.0, "min": 0.5, "max": 1.5},
		"ps1_strength": {"default": 1.0, "min": 0.0, "max": 1.0},
	},
}


func _ready() -> void:
	apply_startup()
	AudioServer.bus_layout_changed.connect(_apply_audio)
	AudioServer.bus_renamed.connect(_apply_audio.unbind(3))


func get_value(section: String, key: String) -> Variant:
	if not _known_key(section, key):
		return null
	var rule: Dictionary = SCHEMA[section][key]
	var fallback: Variant = rule["default"]
	var config := ConfigFile.new()
	if config.load(SETTINGS_PATH) != OK:
		return fallback
	var value: Variant = config.get_value(section, key, fallback)
	if typeof(value) != typeof(fallback):
		return fallback
	if value is float:
		if not is_finite(value) or value < rule["min"] or value > rule["max"]:
			return fallback
	elif rule.has("choices") and not rule["choices"].has(value):
		return fallback
	return value


func set_value(section: String, key: String, value: Variant) -> Error:
	if not _known_key(section, key):
		return ERR_INVALID_PARAMETER
	var rule: Dictionary = SCHEMA[section][key]
	if rule["default"] is float:
		if not (value is float or value is int) or not is_finite(float(value)):
			return ERR_INVALID_PARAMETER
		value = clampf(float(value), rule["min"], rule["max"])
	elif typeof(value) != typeof(rule["default"]):
		return ERR_INVALID_PARAMETER
	elif rule.has("choices") and not rule["choices"].has(value):
		return ERR_INVALID_PARAMETER
	var config := ConfigFile.new()
	var error := config.load(SETTINGS_PATH)
	if error != OK and error != ERR_FILE_NOT_FOUND:
		return error
	config.set_value(section, key, value)
	error = config.save(SETTINGS_PATH)
	if error != OK:
		return error
	_apply_value(section, key, value)
	EventBus.settings_changed.emit(section, key)
	return OK


func reset_defaults() -> Error:
	return _reset_sections(SCHEMA.keys())


func reset_section(section: String) -> Error:
	if not SCHEMA.has(section):
		return ERR_INVALID_PARAMETER
	return _reset_sections([section])


func _reset_sections(sections: Array) -> Error:
	# Save once before notifying readers; preserve all unrelated existing entries.
	var config := ConfigFile.new()
	var error := config.load(SETTINGS_PATH)
	if error != OK and error != ERR_FILE_NOT_FOUND:
		return error
	for section: String in sections:
		for key: String in SCHEMA[section]:
			# Acknowledgement is not a preference: reset must not repeat first-run UI.
			if section == "ui" and key == "content_warning_seen":
				config.set_value(section, key, get_value(section, key))
				continue
			config.set_value(section, key, SCHEMA[section][key]["default"])
	error = _save_reset_config(config)
	if error != OK:
		return error
	for section: String in sections:
		for key: String in SCHEMA[section]:
			_apply_value(section, key, config.get_value(section, key))
	for section: String in sections:
		for key: String in SCHEMA[section]:
			EventBus.settings_changed.emit(section, key)
	return OK


func _save_reset_config(config: ConfigFile) -> Error:
	# One persistence boundary also permits deterministic I/O-failure tests.
	return config.save(SETTINGS_PATH)


func apply_startup() -> void:
	TranslationServer.set_locale(get_value("ui", "locale"))
	_apply_audio()


func _apply_audio() -> void:
	for key: String in AUDIO_BUSES:
		_apply_value("audio", key, get_value("audio", key))


func _apply_value(section: String, key: String, value: Variant) -> void:
	if section == "ui" and key == "locale":
		TranslationServer.set_locale(value)
	elif section == "audio":
		var bus_index := AudioServer.get_bus_index(AUDIO_BUSES[key])
		if bus_index >= 0:
			AudioServer.set_bus_volume_db(bus_index, value)
			AudioServer.set_bus_mute(bus_index, value <= -40.0)


func _known_key(section: String, key: String) -> bool:
	return SCHEMA.has(section) and SCHEMA[section].has(key)
