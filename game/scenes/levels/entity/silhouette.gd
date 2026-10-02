extends Node3D
## Visual only. Lane A owns pursuit, movement, collision and scare triggers.

const SHADER := preload("res://rendering/silhouette.gdshader")
var visible_amount: float = 1.0
var _material: ShaderMaterial
var _phase: float = 0.0


func _ready() -> void:
	_material = ShaderMaterial.new()
	_material.shader = SHADER
	for node in $Sway.find_children("*", "MeshInstance3D", true, false):
		(node as MeshInstance3D).material_override = _material
		(node as MeshInstance3D).cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	set_visible_amount(visible_amount)


func set_visible_amount(value: float) -> void:
	visible_amount = clampf(value, 0.0, 1.0) if is_finite(value) else 0.0
	if _material:
		_material.set_shader_parameter("visible_amount", visible_amount)
	visible = visible_amount > 0.0


func _process(delta: float) -> void:
	_phase += delta
	$Sway.rotation.z = sin(_phase * 1.1) * 0.012
	$Sway.rotation.x = sin(_phase * 0.73) * 0.008
