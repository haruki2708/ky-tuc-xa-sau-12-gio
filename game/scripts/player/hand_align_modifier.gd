class_name HandAlignModifier
extends SkeletonModifier3D
## Turns one bone (a hand) to a world-space basis after the arm IK, so the wrist meets what it
## holds the way a hand does (T-220): palm down on a door lever, fingers up behind a paper.

@export var bone: StringName = &"RightHand"
## T-239: the rig has no twist bones, so a hand turned far about its forearm pinches the skin at
## the wrist. This share of the hand's turn about the forearm (from the rest pose) is taken by the
## forearm instead, rolling about its own line (the wrist stays where it is): the turn is split
## between the elbow and the wrist, as a forearm turns along its length.
@export_range(0.0, 1.0) var forearm_share: float = 0.0
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
	var local: Quaternion = (parent_rotation.inverse() * desired).normalized()
	if forearm_share > 0.0 and parent >= 0:
		local = _share_twist(skeleton, parent, local)
	skeleton.set_bone_pose_rotation(_index, local)


## Roll the forearm `forearm_share` of the hand's twist about it; the hand's own turn, against the
## rolled forearm, keeps it on `local`'s world basis.
func _share_twist(skeleton: Skeleton3D, parent: int, local: Quaternion) -> Quaternion:
	var axis: Vector3 = skeleton.get_bone_pose_position(_index)
	if axis.length() < 0.0001:
		return local
	axis = axis.normalized()
	var rest: Quaternion = skeleton.get_bone_rest(_index).basis.get_rotation_quaternion()
	var turn: Quaternion = (local * rest.inverse()).normalized()
	var twist: float = wrapf(2.0 * atan2(Vector3(turn.x, turn.y, turn.z).dot(axis), turn.w), -PI, PI)
	var roll := Quaternion(axis, twist * forearm_share)
	skeleton.set_bone_pose_rotation(parent, (skeleton.get_bone_pose_rotation(parent) * roll).normalized())
	return (roll.inverse() * local).normalized()
