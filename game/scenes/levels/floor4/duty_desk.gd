extends Node3D
## T-250 (D-166): the floor-4 duty desk. Its centre drawer (Desk/Model/KeyDrawer, where the fire key lies) is a
## node of its own on steel runners and slides out along +Z; nothing opens it yet (CH3 "take the key" is T-247
## row 5's later card). Visual only: the desk's collision box does not move.
const DRAWER_TRAVEL := 0.34
## 0 shut, 1 fully out.
var drawer_open: float = 0.0: set = set_drawer_open
var _drawer: Node3D
var _shut_z := 0.0


func _ready() -> void:
	_drawer = get_node_or_null("Desk/Model/KeyDrawer") as Node3D
	if _drawer != null:
		_shut_z = _drawer.position.z
		set_drawer_open(drawer_open)


func set_drawer_open(amount: float) -> void:
	drawer_open = clampf(amount, 0.0, 1.0)
	if _drawer != null:
		_drawer.position.z = _shut_z + DRAWER_TRAVEL * drawer_open


func get_drawer() -> Node3D:
	return _drawer
