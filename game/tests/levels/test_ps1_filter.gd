extends TestCase
## T-118 PS1 screen filter: layering under the HUD and the settings contract.

const FILTER := preload("res://rendering/ps1_filter.tscn")
const SETTINGS_PATH := "user://settings.cfg"

var filter: CanvasLayer
var _had_settings: bool
var _settings_backup: PackedByteArray


func before_each() -> void:
	_had_settings = FileAccess.file_exists(SETTINGS_PATH)
	if _had_settings:
		_settings_backup = FileAccess.get_file_as_bytes(SETTINGS_PATH)
	assert_eq(ConfigFile.new().save(SETTINGS_PATH), OK, "isolate settings fixture")
	filter = FILTER.instantiate()
	tree.root.add_child(filter)


func after_each() -> void:
	filter.free()
	if _had_settings:
		var file := FileAccess.open(SETTINGS_PATH, FileAccess.WRITE)
		file.store_buffer(_settings_backup)
		file.close()
	elif FileAccess.file_exists(SETTINGS_PATH):
		DirAccess.remove_absolute(SETTINGS_PATH)
	RenderingServer.global_shader_parameter_set(&"ps1_strength", 0.0)


func _save(strength: Variant, brightness: Variant) -> void:
	var config := ConfigFile.new()
	config.set_value("video", "ps1_strength", strength)
	config.set_value("video", "brightness", brightness)
	assert_eq(config.save(SETTINGS_PATH), OK, "write settings fixture")


func _param(name: String) -> Variant:
	return (filter.get_node("Screen").material as ShaderMaterial).get_shader_parameter(name)


func test_filter_sits_below_hud_and_menus() -> void:
	assert_true(filter.layer < 10, "below HUD (10) and pause menu (20)")
	var screen := filter.get_node("Screen") as ColorRect
	assert_eq(screen.mouse_filter, Control.MOUSE_FILTER_IGNORE, "never blocks the mouse")
	assert_eq(screen.anchor_right, 1.0, "covers the full width")
	assert_eq(screen.anchor_bottom, 1.0, "covers the full height")


func test_defaults_without_settings_leave_filter_off() -> void:
	# D-102: the PS1 look is opt-in once G3 brought the furnished room 407 in.
	assert_eq(filter.strength, 0.0, "default strength;")
	assert_eq(filter.brightness, 1.0, "default brightness;")
	assert_eq(_param("strength"), 0.0, "shader strength;")
	assert_false(filter.get_node("Screen").visible, "no full-screen pass by default")
	assert_eq(filter.snap_strength, 0.0, "vertex snap global sent;")
	assert_true(ProjectSettings.has_setting("shader_globals/ps1_strength"), "shader global declared in project")


func test_zero_strength_turns_filter_off_but_brightness_still_applies() -> void:
	_save(0.0, 1.0)
	filter.reload()
	assert_eq(_param("strength"), 0.0, "neutral shader strength;")
	assert_false(filter.get_node("Screen").visible, "no full-screen copy when neutral")
	assert_eq(filter.snap_strength, 0.0, "vertex snapping off;")
	_save(0.0, 1.3)
	filter.reload()
	assert_true(filter.get_node("Screen").visible, "brightness needs the pass even without PS1")
	assert_eq(_param("brightness"), 1.3, "brightness applied with filter off;")


func test_settings_changed_reloads_only_video_keys() -> void:
	_save(0.4, 0.8)
	EventBus.settings_changed.emit("audio", "sfx_db")
	assert_eq(filter.strength, 0.0, "unrelated key ignored;")
	EventBus.settings_changed.emit("video", "ps1_strength")
	assert_eq(filter.strength, 0.4, "strength reloaded;")
	assert_eq(_param("brightness"), 0.8, "brightness read in the same pass;")
	_save(0.4, 1.2)
	EventBus.settings_changed.emit("video", "brightness")
	assert_eq(_param("brightness"), 1.2, "brightness reloaded;")


func test_invalid_values_fall_back_to_defaults() -> void:
	for pair: Array in [["0.5", "1.1"], [2.0, 0.2], [-0.1, 1.6], [NAN, INF], [1, 1]]:
		_save(pair[0], pair[1])
		filter.reload()
		assert_eq(filter.strength, 0.0, "invalid strength %s defaults;" % str(pair[0]))
		assert_eq(filter.brightness, 1.0, "invalid brightness %s defaults;" % str(pair[1]))
