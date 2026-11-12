class_name BreathModifier
extends SkeletonModifier3D
## T-249: out of breath. The chest heaves and the shoulders rise with each breath, on top of the
## animation: the upper chest tips back, both collarbones lift their shoulder joints, and the neck
## gives the tip back so the head stays level. `lift` is how full the chest is (0 breathed out, 1
## breathed in); PlayerBody drives it while the player is exhausted.

@export var lift: float = 0.0
## At a full breath: how far the upper chest tips back and each shoulder rises (degrees).
@export var chest_degrees: float = 4.5
@export var shoulder_degrees: float = 7.0
## Skeleton-space up.
@export var up: Vector3 = Vector3.UP

var _chest: int = -1
var _neck: int = -1
var _collars: PackedInt32Array = PackedInt32Array()
var _arms: PackedInt32Array = PackedInt32Array()


func _ready() -> void:
	var skeleton: Skeleton3D = get_skeleton()
	if skeleton == null:
		return
	_chest = skeleton.find_bone("UpperChest")
	_neck = skeleton.find_bone("Neck")
	for side: String in ["Left", "Right"]:
		_collars.append(skeleton.find_bone(side + "Shoulder"))
		_arms.append(skeleton.find_bone(side + "UpperArm"))


func _process_modification() -> void:
	var skeleton: Skeleton3D = get_skeleton()
	if skeleton == null or _chest < 0 or is_zero_approx(lift) or _arms.has(-1) or _collars.has(-1):
		return
	# From the left shoulder joint to the right one: about this line a positive turn tips the chest back.
	var across: Vector3 = skeleton.get_bone_global_pose(_arms[1]).origin - skeleton.get_bone_global_pose(_arms[0]).origin
	if across.length() < 0.001 or up.is_zero_approx():
		return
	across = across.normalized()
	var ahead: Vector3 = up.normalized().cross(across).normalized()
	var tip := Quaternion(across, deg_to_rad(chest_degrees) * lift)
	TiptoeModifier.turn(skeleton, _chest, tip)
	# About the line ahead a positive turn lifts what is out to the left and lowers what is to the right.
	var rise: float = deg_to_rad(shoulder_degrees) * lift
	TiptoeModifier.turn(skeleton, _collars[0], Quaternion(ahead, rise))
	TiptoeModifier.turn(skeleton, _collars[1], Quaternion(ahead, -rise))
	if _neck >= 0:
		TiptoeModifier.turn(skeleton, _neck, tip.inverse())
