class_name ShoulderRaiseModifier
extends SkeletonModifier3D
## T-227 round 2: reaching overhead a person shrugs into it, the collarbone lifting the shoulder
## joint. Turns `shoulder` so the joint of `arm` swings `degrees` toward `up`; the arm's IK runs
## after this, from the lifted joint.

@export var shoulder: String = "RightShoulder"
@export var arm: String = "RightUpperArm"
## Skeleton-space up (PlayerBody sets it from the world up).
@export var up: Vector3 = Vector3.UP
@export var degrees: float = 0.0

var _shoulder: int = -1
var _arm: int = -1


func _ready() -> void:
	var skeleton: Skeleton3D = get_skeleton()
	if skeleton != null:
		_shoulder = skeleton.find_bone(shoulder)
		_arm = skeleton.find_bone(arm)


## The turn that swings `segment` (collarbone to arm joint) `angle_degrees` toward `up_axis`, in
## the same space as both.
static func lift(segment: Vector3, up_axis: Vector3, angle_degrees: float) -> Quaternion:
	var across: Vector3 = segment.cross(up_axis)
	if across.is_zero_approx() or is_zero_approx(angle_degrees):
		return Quaternion.IDENTITY
	return Quaternion(across.normalized(), deg_to_rad(angle_degrees))


func _process_modification() -> void:
	var skeleton: Skeleton3D = get_skeleton()
	if skeleton == null or _shoulder < 0 or _arm < 0 or is_zero_approx(degrees) or up.is_zero_approx():
		return
	var segment: Vector3 = skeleton.get_bone_global_pose(_arm).origin - skeleton.get_bone_global_pose(_shoulder).origin
	TiptoeModifier.turn(skeleton, _shoulder, lift(segment, up.normalized(), degrees))
