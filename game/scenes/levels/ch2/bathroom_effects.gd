extends Node3D
## Bounded, reversible visual effects. No temperature puzzle or death logic.
var water_on: bool = false
var temperature: int = 0
var steam_level: float = 0.0
var _requested_steam: float = 0.0


func _ready() -> void:
	set_water(water_on, temperature)


func set_water(on: bool, degrees: int) -> void:
	water_on = on
	temperature = degrees
	if is_node_ready():
		$Water.emitting = on
		$Water.visible = on
		if on:
			$Water.restart()
		_apply_steam()


func set_steam(level: float) -> void:
	_requested_steam = clampf(level, 0.0, 1.0) if is_finite(level) else 0.0
	if is_node_ready():
		_apply_steam()


func _apply_steam() -> void:
	# >=40 C produces a local plume; core independently sets room condensation.
	steam_level = maxf(_requested_steam, .35 if water_on and temperature >= 40 else 0.0)
	$Steam.visible = steam_level > 0.0
	for sheet: MeshInstance3D in $Steam.get_children():
		(sheet.material_override as ShaderMaterial).set_shader_parameter("level", steam_level)
	$MirrorFog.visible = steam_level > 0.0
	var frost := $MirrorFog.material_override as StandardMaterial3D
	frost.albedo_color.a = steam_level * .78


func flash_reflection() -> void:
	if not is_node_ready():
		return
	$Reflection.visible = true
	if not RenderingServer.frame_post_draw.is_connected(_clear_reflection):
		RenderingServer.frame_post_draw.connect(_clear_reflection, CONNECT_ONE_SHOT)


func _clear_reflection() -> void:
	$Reflection.visible = false
