extends "res://tests/ui/settings_test_case.gd"


func test_defaults_without_file_and_missing_keys() -> void:
	assert_false(FileAccess.file_exists(SettingsStore.SETTINGS_PATH), "startup must not write settings")
	_assert_defaults()
	var config := ConfigFile.new()
	config.set_value("ui", "unrelated", "keep")
	assert_eq(config.save(SettingsStore.SETTINGS_PATH), OK)
	_assert_defaults()
	assert_eq(settings.get_value("unknown", "unknown"), null)


func test_invalid_types_ranges_and_nonfinite_values_use_defaults() -> void:
	for section: String in SettingsStore.SCHEMA:
		for key: String in SettingsStore.SCHEMA[section]:
			var rule: Dictionary = SettingsStore.SCHEMA[section][key]
			var invalid: Array = ["invalid", 42, null]
			if rule["default"] is float:
				invalid.append_array([true, rule["min"] - 0.1, rule["max"] + 0.1, INF, NAN])
			elif rule["default"] is bool:
				invalid.append(1.0)
			for value: Variant in invalid:
				var config := ConfigFile.new()
				config.set_value(section, key, value)
				assert_eq(config.save(SettingsStore.SETTINGS_PATH), OK)
				assert_eq(settings.get_value(section, key), rule["default"], section + "/" + key)


func test_valid_boundaries_remain_unchanged() -> void:
	for section: String in SettingsStore.SCHEMA:
		for key: String in SettingsStore.SCHEMA[section]:
			var rule: Dictionary = SettingsStore.SCHEMA[section][key]
			if not rule.has("min"):
				continue
			for boundary: float in [rule["min"], rule["max"]]:
				assert_eq(settings.set_value(section, key, boundary), OK)
				assert_eq(settings.get_value(section, key), boundary, section + "/" + key)


func test_clamping_saves_before_signal_and_preserves_other_sections() -> void:
	var config := ConfigFile.new()
	config.set_value("ui", "locale", "en")
	config.set_value("other", "sentinel", "untouched")
	assert_eq(config.save(SettingsStore.SETTINGS_PATH), OK)
	var observed: Array = []
	var callback := func(section: String, key: String) -> void:
		var saved := ConfigFile.new()
		saved.load(SettingsStore.SETTINGS_PATH)
		observed.append([section, key, saved.get_value(section, key)])
	EventBus.settings_changed.connect(callback)
	assert_eq(settings.set_value("audio", "sfx_db", 80), OK)
	assert_eq(settings.set_value("input", "mouse_sensitivity", -2.0), OK)
	assert_eq(settings.set_value("video", "brightness", 5.0), OK)
	assert_eq(settings.set_value("video", "ps1_strength", -5.0), OK)
	EventBus.settings_changed.disconnect(callback)
	assert_eq(observed, [["audio", "sfx_db", 6.0], ["input", "mouse_sensitivity", 0.0005],
		["video", "brightness", 1.5], ["video", "ps1_strength", 0.0]])
	assert_eq(config.load(SettingsStore.SETTINGS_PATH), OK)
	assert_eq(config.get_value("ui", "locale"), "en")
	assert_eq(config.get_value("other", "sentinel"), "untouched")
	assert_eq(typeof(config.get_value("audio", "sfx_db")), TYPE_FLOAT)
	var fresh := SettingsStore.new()
	assert_eq(fresh.get_value("video", "brightness"), 1.5, "new instance reads persisted value;")
	fresh.free()


func test_invalid_writes_do_not_save_or_emit() -> void:
	var observed: Array = []
	var callback := func(section: String, key: String) -> void: observed.append([section, key])
	EventBus.settings_changed.connect(callback)
	for request in [["audio", "sfx_db", "loud"], ["audio", "sfx_db", true],
		["audio", "sfx_db", INF], ["audio", "sfx_db", NAN], ["ui", "locale", "fr"],
		["video", "head_bob", 1], ["accessibility", "reduce_scares", "true"],
		["accessibility", "reduce_scares", 1], ["unknown", "value", 0.5], ["audio", "new_bus", 0.0]]:
		assert_eq(settings.set_value(request[0], request[1], request[2]), ERR_INVALID_PARAMETER)
	EventBus.settings_changed.disconnect(callback)
	assert_true(observed.is_empty())
	assert_false(FileAccess.file_exists(SettingsStore.SETTINGS_PATH))


func test_sfx_applies_volume_mute_and_unmute_before_notification() -> void:
	var index := AudioServer.get_bus_index("SFX")
	assert_true(index >= 0)
	var observed: Array = []
	var callback := func(_section: String, _key: String) -> void:
		observed.append([AudioServer.get_bus_volume_db(index), AudioServer.is_bus_mute(index)])
	EventBus.settings_changed.connect(callback)
	assert_eq(settings.set_value("audio", "sfx_db", -8.0), OK)
	assert_eq(settings.set_value("audio", "sfx_db", -70.0), OK)
	assert_eq(settings.set_value("audio", "sfx_db", -40.0), OK)
	assert_eq(settings.set_value("audio", "sfx_db", 0.0), OK)
	EventBus.settings_changed.disconnect(callback)
	assert_eq(observed, [[-8.0, false], [-40.0, true], [-40.0, true], [0.0, false]])


func test_ready_applies_saved_locale_and_all_present_audio_buses() -> void:
	var config := ConfigFile.new()
	config.set_value("ui", "locale", "en")
	for key: String in SettingsStore.AUDIO_BUSES:
		config.set_value("audio", key, -40.0 if key == "sfx_db" else -7.5)
	assert_eq(config.save(SettingsStore.SETTINGS_PATH), OK)
	settings.free()
	settings = SettingsStore.new()
	tree.root.add_child(settings)
	assert_eq(TranslationServer.get_locale(), "en")
	for key: String in SettingsStore.AUDIO_BUSES:
		var index := AudioServer.get_bus_index(SettingsStore.AUDIO_BUSES[key])
		if index >= 0:
			assert_eq(AudioServer.get_bus_volume_db(index), -40.0 if key == "sfx_db" else -7.5)
			assert_eq(AudioServer.is_bus_mute(index), key == "sfx_db")


func test_reset_defaults_preserves_unrelated_entries_and_notifies_every_key() -> void:
	var config := ConfigFile.new()
	config.set_value("other", "sentinel", "keep")
	config.set_value("video", "head_bob", false)
	config.set_value("ui", "locale", "en")
	config.set_value("audio", "sfx_db", -40.0)
	assert_eq(config.save(SettingsStore.SETTINGS_PATH), OK)
	settings.apply_startup()
	var observed: Array = []
	var callback := func(section: String, key: String) -> void:
		observed.append(section + "/" + key)
		_assert_defaults()
	EventBus.settings_changed.connect(callback)
	assert_eq(settings.reset_defaults(), OK)
	EventBus.settings_changed.disconnect(callback)
	var expected: Array = []
	for section: String in SettingsStore.SCHEMA:
		for key: String in SettingsStore.SCHEMA[section]:
			expected.append(section + "/" + key)
	assert_eq(observed, expected)
	assert_eq(config.load(SettingsStore.SETTINGS_PATH), OK)
	assert_eq(config.get_value("other", "sentinel"), "keep")
	assert_eq(TranslationServer.get_locale(), "vi")
	assert_false(AudioServer.is_bus_mute(AudioServer.get_bus_index("SFX")))


func _assert_defaults() -> void:
	# Pin the public contract independently of the implementation's schema.
	var expected := {
		"ui": {"locale": "vi", "content_warning_seen": false},
		"audio": {"master_db": 0.0, "ambience_db": 0.0, "sfx_db": 0.0,
			"footsteps_db": 0.0, "voice_db": 0.0, "music_db": 0.0},
		"input": {"mouse_sensitivity": 0.002},
		"accessibility": {"reduce_scares": false},
		"video": {"head_bob": true, "brightness": 1.0, "ps1_strength": 1.0},
	}
	for section: String in expected:
		for key: String in expected[section]:
			assert_eq(settings.get_value(section, key), expected[section][key], section + "/" + key)
