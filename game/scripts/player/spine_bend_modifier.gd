class_name SpineBendModifier
extends SkeletonModifier3D
## Bends the listed spine bones (shared equally) about a skeleton-space axis, on top of the
## animation: a body leans in to reach what its arm alone cannot (T-220).

@export var bones: PackedStringArray = PackedStringArray(["Spine", "Chest", "UpperChest"])
## Skeleton-space axis; positive angles tip the chest toward axis x up.
@export var axis: Vector3 = Vector3.RIGHT
@export_range(0.0, 90.0) var degrees: float = 0.0

var _indices: PackedInt32Array = PackedInt32Array()


func _ready() -> void:
	var skeleton: Skeleton3D = get_skeleton()
	if skeleton == null:
		return
	for bone: String in bones:
		var index: int = skeleton.find_bone(bone)
		if index >= 0:
			_indices.append(index)


func _process_modification() -> void:
	var skeleton: Skeleton3D = get_skeleton()
	if skeleton == null or _indices.is_empty() or is_zero_approx(degrees) or axis.is_zero_approx():
		return
	var swing: Quaternion = Quaternion(axis.normalized(), deg_to_rad(degrees) / _indices.size())
	for index: int in _indices:
		# local' = parent^-1 * swing * parent * local, in the parent's current (bent) pose.
		var parent: int = skeleton.get_bone_parent(index)
		var parent_rotation: Quaternion = Quaternion.IDENTITY
		if parent >= 0:
			parent_rotation = skeleton.get_bone_global_pose(parent).basis.get_rotation_quaternion()
		var local: Quaternion = skeleton.get_bone_pose_rotation(index)
		skeleton.set_bone_pose_rotation(index, (parent_rotation.inverse() * swing * parent_rotation * local).normalized())
