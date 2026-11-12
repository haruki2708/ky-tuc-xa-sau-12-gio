class_name MirrorArmModifier
extends SkeletonModifier3D
## T-245: the arm a mirror shows. Its bones are copies of the left arm's (the mirror mesh is skinned
## to them); each takes the pose its original has this frame, so the two arms are one arm until the
## IK after this modifier gives the copy its own pose (PlayerBody: the hand holding the phone).

## Source bone, copy bone, source, copy, ...
var pairs: PackedInt32Array = PackedInt32Array()


func _process_modification() -> void:
	var skeleton := get_skeleton()
	if skeleton == null:
		return
	for i: int in range(0, pairs.size(), 2):
		skeleton.set_bone_pose(pairs[i + 1], skeleton.get_bone_pose(pairs[i]))
