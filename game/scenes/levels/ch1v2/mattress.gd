extends Marker3D
## Lift mattress and existing body/blanket together, preserving public node paths.
var lifted: bool = false
var _followers: Array[Node3D] = []
var _rest: Array[Transform3D] = []
var _hinge_rest: Transform3D
var _net: Node3D
var _net_was_visible: bool = true


func _ready() -> void:
	_hinge_rest = $Pivot.global_transform
	_net = get_node_or_null("../../BunkA/Net_Phuc") as Node3D
	if _net:
		_net_was_visible = _net.visible
	for path in ["../Corpse1/Body", "../../BunkA/UpperPillow", "../../Details/Blanket1", "../../Details/BloodSeep/BlanketStain1", "../../Details/BloodSeep/HangingStain1"]:
		var item := get_node_or_null(path) as Node3D
		if item:
			_followers.append(item)
			_rest.append(item.global_transform)
	set_lifted(lifted)


func set_lifted(value: bool) -> void:
	lifted = value
	if not is_node_ready():
		return
	$Pivot.rotation.z = .90 if value else 0.0
	if _net:
		_net.visible = _net_was_visible and not value
	var change: Transform3D = $Pivot.global_transform * _hinge_rest.affine_inverse()
	for i in range(_followers.size()):
		_followers[i].global_transform = change * _rest[i]
