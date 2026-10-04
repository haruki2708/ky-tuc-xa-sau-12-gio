extends Node3D
## Chapter 1 environment APIs only. No rules, damage, death or puzzle decisions.

const SURFACE := preload("res://rendering/room407_surface.gdshader")
var blood_stage: int = 0
var slashed_amount: float = 0.0
var _drip_time: float = 0.0


func _ready() -> void:
	_apply_surface($Floor/Mesh, preload("res://assets/textures/room407/room_tile.png"), Vector2(10, 8))
	for node in [$WestWall/Mesh, $EastWall/Mesh]:
		_apply_surface(node, preload("res://assets/textures/room407/room_wall.png"), Vector2(2, 1))
	for net in [$BunkA/Net_Phuc, $BunkA/Net_Viet, $BunkB/Net_Dat, $BunkB/Net_Trung]:
		PropTint.apply(net, Color(.58, .62, .58))
	set_blood_stage(blood_stage)
	set_slashed(slashed_amount)


func _apply_surface(mesh: MeshInstance3D, texture: Texture2D, uv_scale: Vector2) -> void:
	var material := ShaderMaterial.new()
	material.shader = SURFACE
	material.set_shader_parameter("albedo_texture", texture)
	material.set_shader_parameter("uv_scale", uv_scale)
	mesh.material_override = material


func set_blood_stage(stage: int) -> void:
	blood_stage = clampi(stage, 0, 2)
	if not is_node_ready():
		return
	$Details/BloodSeep.visible = blood_stage >= 1
	$Details/BloodPools.visible = blood_stage >= 2
	for number in [1, 2, 4]:
		var body := get_node_or_null("Anchors/Corpse%d/Body" % number)
		if body:
			body.set_blood_visible(blood_stage > 0)
	_drip_time = 0.0


func set_slashed(amount: float) -> void:
	slashed_amount = clampf(amount, 0.0, 1.0) if is_finite(amount) else 0.0
	if not is_node_ready():
		return
	var count := ceili(slashed_amount * 8.0)
	for i in range(8):
		var section := get_node("Details/TrungBedding/Section%d" % i) as Node3D
		section.visible = i >= count
		(get_node("Details/SlashRips/Rip%d" % i) as Node3D).visible = i < count
		(get_node("Details/Debris/Scrap%d" % i) as Node3D).visible = i < count
	$Details/SlashRips.visible = count > 0
	$Details/Debris.visible = count > 0
	$Details/TrungPillow.visible = slashed_amount < 1.0


func set_flicker(value: bool) -> void:
	$Room407MainLight.set_flicker(value)
	$Room407DeskLamp.set_flicker(value)


func _process(delta: float) -> void:
	if blood_stage == 0:
		return
	_drip_time += delta
	for number in [1, 2, 4]:
		var drop := get_node("Details/BloodSeep/Droplet%d" % number) as Node3D
		var top := 1.45 if number != 2 else .68
		drop.position.y = lerpf(top, .03, fmod(_drip_time * .7 + number * .27, 1.0))
