class_name HandAlignModifier
extends SkeletonModifier3D
## Turns one bone (a hand) to a world-space basis after the arm IK, so the wrist meets what it
## holds the way a hand does (T-220): palm down on a door lever, fingers up behind a paper.

@export var bone: StringName = &"RightHand"
## World-space basis the bone should take; blended in by this modifier's influence.
var target_basis: Basis = Basis.IDENTITY

var _index: int = -1


func _ready() -> void:
	var skeleton: Skeleton3D = get_skeleton()
	if skeleton != null:
		_index = skeleton.find_bone(bone)


func _process_modification() -> void:
	var skeleton: Skeleton3D = get_skeleton()
	if skeleton == null or _index < 0:
		return
	var desired: Quaternion = (skeleton.global_basis.orthonormalized().inverse() * target_basis.orthonormalized()).get_rotation_quaternion()
	var parent: int = skeleton.get_bone_parent(_index)
	var parent_rotation: Quaternion = Quaternion.IDENTITY
	if parent >= 0:
		parent_rotation = skeleton.get_bone_global_pose(parent).basis.get_rotation_quaternion()
	skeleton.set_bone_pose_rotation(_index, (parent_rotation.inverse() * desired).normalized())
