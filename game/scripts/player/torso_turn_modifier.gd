class_name TorsoTurnModifier
extends SkeletonModifier3D
## T-249: turns the chest about the back's own line (from the first spine bone to the neck), shared by
## the spine bones, on top of the animation: a runner leaning forward looks back over his shoulder, or
## swings a bar, about the line of his back, so his head stays where it was (SpineBendModifier turns
## about one fixed axis: with the trunk leaning, the head would swing out to the side).
## The neck and head turn `head_degrees` more about the same line: further round to look back, or
## back again (negative) so the face stays where it looked while the chest turns under it.
## Positive angles turn to the body's left (counter-clockwise seen from above).

@export var bones: PackedStringArray = PackedStringArray(["Spine", "Chest", "UpperChest"])
@export var chest_degrees: float = 0.0
@export var head_degrees: float = 0.0

var _spine: PackedInt32Array = PackedInt32Array()
var _neck: int = -1
var _head: int = -1


func _ready() -> void:
	var skeleton: Skeleton3D = get_skeleton()
	if skeleton == null:
		return
	for bone: String in bones:
		var index: int = skeleton.find_bone(bone)
		if index >= 0:
			_spine.append(index)
	_neck = skeleton.find_bone("Neck")
	_head = skeleton.find_bone("Head")


func _process_modification() -> void:
	var skeleton: Skeleton3D = get_skeleton()
	if skeleton == null or _spine.is_empty() or _neck < 0:
		return
	if is_zero_approx(chest_degrees) and is_zero_approx(head_degrees):
		return
	var line: Vector3 = skeleton.get_bone_global_pose(_neck).origin - skeleton.get_bone_global_pose(_spine[0]).origin
	if line.length() < 0.001:
		return
	line = line.normalized()
	if not is_zero_approx(chest_degrees):
		var share := Quaternion(line, deg_to_rad(chest_degrees) / _spine.size())
		for bone: int in _spine:
			TiptoeModifier.turn(skeleton, bone, share)
	if not is_zero_approx(head_degrees) and _head >= 0:
		var half := Quaternion(line, deg_to_rad(head_degrees) * 0.5)
		TiptoeModifier.turn(skeleton, _neck, half)
		TiptoeModifier.turn(skeleton, _head, half)
