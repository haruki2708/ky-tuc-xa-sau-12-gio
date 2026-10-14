extends CanvasLayer
## PS1 filter for the 3D view (T-118, D-005). Sits below the HUD (layer 10) and
## menus (layer 20) so text and paper close-ups stay sharp.
## Reads [video] ps1_strength and brightness (docs/SETTINGS.md); read only.
## Debug: `-- --ps1-strength=0..1` overrides the strength without saving.

const SETTINGS_PATH := "user://settings.cfg"
## Off by default since G3 brought the furnished room 407 in (D-102); still a player setting.
const DEFAULT_STRENGTH: float = 0.0
const DEFAULT_BRIGHTNESS: float = 1.0
const STRENGTH_ARG := "--ps1-strength="

var strength: float = DEFAULT_STRENGTH
var brightness: float = DEFAULT_BRIGHTNESS
## Last value sent to the `ps1_strength` shader global (vertex snapping).
var snap_strength: float = DEFAULT_STRENGTH
var _strength_override: float = -1.0

@onready var _screen: ColorRect = $Screen


func _ready() -> void:
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with(STRENGTH_ARG):
			_strength_override = clampf(float(arg.trim_prefix(STRENGTH_ARG)), 0.0, 1.0)
	EventBus.settings_changed.connect(_on_settings_changed)
	reload()


func _on_settings_changed(section: String, key: String) -> void:
	if section == "video" and (key == "ps1_strength" or key == "brightness"):
		reload()


func reload() -> void:
	var config := ConfigFile.new()
	if config.load(SETTINGS_PATH) != OK:
		config.clear()
	strength = _read_float(config, "ps1_strength", 0.0, 1.0, DEFAULT_STRENGTH)
	if _strength_override >= 0.0:
		strength = _strength_override
	brightness = _read_float(config, "brightness", 0.5, 1.5, DEFAULT_BRIGHTNESS)
	var material := _screen.material as ShaderMaterial
	material.set_shader_parameter("strength", strength)
	material.set_shader_parameter("brightness", brightness)
	# Neutral settings skip the full-screen copy entirely.
	_screen.visible = strength > 0.001 or not is_equal_approx(brightness, 1.0)
	snap_strength = strength
	RenderingServer.global_shader_parameter_set(&"ps1_strength", snap_strength)


static func _read_float(config: ConfigFile, key: String, low: float, high: float, fallback: float) -> float:
	var value: Variant = config.get_value("video", key, fallback)
	if typeof(value) != TYPE_FLOAT or not is_finite(value) or value < low or value > high:
		return fallback
	return value
