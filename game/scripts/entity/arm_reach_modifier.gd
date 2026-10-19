class_name ArmReachModifier
extends SkeletonModifier3D
## Swings one arm forward by this node's own rotation.x. Named LeftArm in a body scene, it is
## what DormManager.open_door tweens, so a skinned body reaches for the door handle (D-120).

@export var bone: StringName = &"mixamorig_LeftArm"
## Skeleton-space axis across the shoulders; the arm swings forward about it.
@export var axis: Vector3 = Vector3.RIGHT
## Share of rotation.x applied: open_door tweens 0.45 pi (81 degrees), 0.7 of it ends near a handle.
@export_range(0.0, 1.5) var lift: float = 0.7

var _index: int = -1


func _ready() -> void:
	var skeleton: Skeleton3D = get_skeleton()
	if skeleton != null:
		_index = skeleton.find_bone(bone)


func _process_modification() -> void:
	var skeleton: Skeleton3D = get_skeleton()
	if skeleton == null or _index < 0 or is_zero_approx(rotation.x):
		return
	# Rotate the bone's global pose about the shoulder axis: local' = parent^-1 * swing * parent * local.
	var swing: Quaternion = Quaternion(axis.normalized(), -rotation.x * lift)
	var parent: int = skeleton.get_bone_parent(_index)
	var parent_rotation: Quaternion = Quaternion.IDENTITY
	if parent >= 0:
		parent_rotation = skeleton.get_bone_global_pose(parent).basis.get_rotation_quaternion()
	var local: Quaternion = skeleton.get_bone_pose_rotation(_index)
	skeleton.set_bone_pose_rotation(_index, (parent_rotation.inverse() * swing * parent_rotation * local).normalized())
