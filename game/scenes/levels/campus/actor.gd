extends Node3D
## Visual rig only. Core owns movement, collision, damage and narrative state.
@export var shirt_color: Color = Color.WHITE
@export var hair_color: Color = Color.WHITE
@export var zombie: bool = false
@export_enum("student", "nhat", "ngu", "guard") var role: String = "student"
@export var initial_pose: StringName = &"idle"
var pose: StringName = &"idle"
var _time: float = 0.0
var _joints: Dictionary = {}
var _rig: Node3D
var _hips: Node3D
var _chest: Node3D
var _head: Node3D
const POSES: Array[StringName] = [&"idle", &"walk", &"stunned", &"grab", &"sit", &"lie", &"wake"]


func _ready() -> void:
	var model := $Model
	model.set_process(false)
	model.set_script(null)
	for child in model.get_children():
		if child is AnimationPlayer or child.name == &"BladeTip":
			child.free()
	_rig = model.get_node("Rig")
	_hips = _rig.get_node("Hips")
	_chest = _hips.get_node("Chest")
	_head = _chest.get_node("Head")
	for item: Node3D in _rig.find_children("*", "Node3D", true, false):
		if not item is VisualInstance3D and not item is CollisionObject3D:
			item.rotation = Vector3.ZERO
			_joints[item] = item.position
	for mesh: MeshInstance3D in model.find_children("*", "MeshInstance3D", true, false):
		var label := String(mesh.name)
		if label in ["LongCleaver", "BladeEdge", "Guard", "Grip", "FaceShadow", "Gag"] or label.begins_with("Gag"):
			mesh.hide()
		if label in ["Shirt", "Hem", "Sleeve", "Pocket-1", "Pocket1", "Collar-1", "Collar1", "Cap", "Forearm"]:
			if label != "Forearm" or role == "guard":
				_tint(mesh, shirt_color)
		if label in ["Hair", "CapBrim"]:
			_tint(mesh, hair_color)
		if role == "guard" and label in ["Face", "Nose", "Ear-1", "Ear1", "Neck"]:
			var skin := StandardMaterial3D.new()
			skin.albedo_color = Color(.48, .43, .34)
			mesh.material_override = skin
	var eyes := _head.get_node_or_null("Eyes") as Node3D
	if eyes:
		eyes.show()
		if zombie:
			for eye: MeshInstance3D in eyes.get_children():
				var red := StandardMaterial3D.new()
				red.albedo_color = Color(.4, .015, .008)
				red.emission_enabled = true
				red.emission = Color(.25, .002, .001)
				red.emission_energy_multiplier = .5
				eye.material_override = red
	var blood := _chest.get_node_or_null("Blood") as Node3D
	if blood:
		blood.visible = zombie
	if zombie:
		_box(_chest, "CampusBlood", Vector3(.10, .23, -.145), Vector3(.12, .20, .008), Color(.24, .025, .025))
	if role == "nhat":
		_box(_chest, "WhiteCollar", Vector3(0, .49, -.08), Vector3(.23, .045, .13), Color(.79, .8, .72))
	if role == "ngu":
		_box(_head, "Ponytail", Vector3(0, -.01, .16), Vector3(.12, .38, .14), Color(.06, .045, .035))
	if role in ["ngu", "guard"]:
		var hand := _chest.get_node("RightArm/Elbow/Hand") as Node3D
		_box(hand, "MetalBar" if role == "ngu" else "Baton", Vector3(0, -.19, 0), Vector3(.035, .95 if role == "ngu" else .55, .035), Color(.31, .35, .34))
		if role == "guard":
			_box(hand, "BatonGrip", Vector3(0, -.045, 0), Vector3(.06, .16, .06), Color(.05, .06, .065))
	set_pose(initial_pose)


func _tint(mesh: MeshInstance3D, color: Color) -> void:
	var material := mesh.get_active_material(0)
	if material is ShaderMaterial:
		var tinted := material.duplicate() as ShaderMaterial
		tinted.set_shader_parameter("albedo_color", color)
		if role == "nhat":
			tinted.set_shader_parameter("albedo_texture", preload("res://assets/textures/ch1_models/paper.png"))
		mesh.material_override = tinted
	elif material is StandardMaterial3D:
		var tinted := material.duplicate() as StandardMaterial3D
		tinted.albedo_color = color
		mesh.material_override = tinted


func _box(parent: Node3D, label: String, at: Vector3, size: Vector3, color: Color) -> void:
	var instance := MeshInstance3D.new()
	instance.name = label
	instance.position = at
	var mesh := BoxMesh.new()
	mesh.size = size
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST
	mesh.material = material
	instance.mesh = mesh
	parent.add_child(instance)


func set_pose(value: StringName) -> bool:
	if value not in POSES:
		return false
	pose = value
	_time = 0.0
	if is_node_ready():
		_apply_pose()
	return true


func _process(delta: float) -> void:
	_time += delta
	_apply_pose()


func _apply_pose() -> void:
	_rig.position = Vector3.ZERO
	_rig.rotation = Vector3.ZERO
	for joint: Node3D in _joints:
		joint.position = _joints[joint]
		joint.rotation = Vector3.ZERO
	var left_arm := _chest.get_node("LeftArm") as Node3D
	var right_arm := _chest.get_node("RightArm") as Node3D
	var left_leg := _hips.get_node("LeftLeg") as Node3D
	var right_leg := _hips.get_node("RightLeg") as Node3D
	match pose:
		&"walk":
			var swing := sin(_time * 6.5) * .38
			left_leg.rotation.x = swing
			right_leg.rotation.x = -swing
			left_arm.rotation.x = -swing * .7
			right_arm.rotation.x = swing * .7
			_rig.position.y += absf(sin(_time * 6.5)) * .025
		&"stunned":
			_chest.rotation.x = .8
			_head.rotation.x = .45
			_rig.position.y -= .14
		&"grab":
			_chest.rotation.x = .18
			left_arm.rotation.x = 1.7
			right_arm.rotation.x = 1.7
		&"sit":
			_rig.position.y -= .45
			left_leg.rotation.x = PI / 2.0
			right_leg.rotation.x = PI / 2.0
			left_leg.get_node("Knee").rotation.x = -PI / 2.0
			right_leg.get_node("Knee").rotation.x = -PI / 2.0
		&"lie", &"wake":
			var blend := clampf(_time / 1.5, 0.0, 1.0) if pose == &"wake" else 0.0
			_rig.rotation.x = lerpf(PI / 2.0, 0.0, blend)
			_rig.position = Vector3(0, lerpf(.18, 0.0, blend), lerpf(-.8, 0.0, blend))
		_:
			_chest.rotation.z = sin(_time * 1.3) * .012
