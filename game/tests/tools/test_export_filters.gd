extends TestCase


func test_windows_release_excludes_qa_content() -> void:
	var config := ConfigFile.new()
	assert_eq(config.load("res://export_presets.cfg"), OK, "export preset loads")
	var section: String = ""
	for candidate: String in config.get_sections():
		if config.get_value(candidate, "name", "") == "Windows Desktop":
			section = candidate
	assert_false(section.is_empty(), "Windows Desktop preset exists")
	if section.is_empty():
		return
	var exclusions := String(config.get_value(section, "exclude_filter", "")).split(",", false)
	for index in exclusions.size():
		exclusions[index] = exclusions[index].strip_edges()
	for pattern: String in ["tests/*", "audio/test/*", "ui/hud/hud_test*", "ui/hud/previews/*", "scenes/player/player_test*", "scenes/levels/kit_showcase*", "assets/models/kit/kit_import.gd"]:
		assert_true(pattern in exclusions, "missing exclusion: " + pattern)
	# Autoplay is a mandatory autoload in the current project. T-124 permits
	# retaining debug scripts when excluding them breaks release startup.
	var autoplay: String = ProjectSettings.get_setting("autoload/Autoplay", "")
	if autoplay.trim_prefix("*") == "res://scripts/debug/autoplay.gd":
		for pattern: String in exclusions:
			assert_false("scripts/debug/autoplay.gd".match(pattern), "autoload must remain available: " + pattern)
	else:
		assert_true("scripts/debug/*" in exclusions, "exclude debug when no longer required by Autoplay")
	assert_true(config.get_value(section + ".options", "binary_format/embed_pck", false), "package expects embedded PCK")
