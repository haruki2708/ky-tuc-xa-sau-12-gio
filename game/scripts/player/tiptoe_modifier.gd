class_name TiptoeModifier
extends SkeletonModifier3D
## T-227 round 2: up on the toes. The body is lifted by `rise` (PlayerBody moves the model up);
## each foot tips down about its ankle until its toe joint is back where it was, and the toes
## tip back up so they stay flat. Without it a raised body would float its whole feet.

@export var feet: PackedStringArray = PackedStringArray(["LeftFoot", "RightFoot"])
@export var toes: PackedStringArray = PackedStringArray(["LeftToes", "RightToes"])
## Skeleton-space up (PlayerBody sets it from the world up).
@export var up: Vector3 = Vector3.UP
## How far the ankles rise, in skeleton units (PlayerBody divides world metres by the model scale).
@export var rise: float = 0.0

var _feet: PackedInt32Array = PackedInt32Array()
var _toes: PackedInt32Array = PackedInt32Array()


func _ready() -> void:
	var skeleton: Skeleton3D = get_skeleton()
	if skeleton == null:
		return
	for index: int in mini(feet.size(), toes.size()):
		var foot: int = skeleton.find_bone(feet[index])
		var toe: int = skeleton.find_bone(toes[index])
		if foot >= 0 and toe >= 0:
			_feet.append(foot)
			_toes.append(toe)


## The extra angle (radians) that tips an ankle-to-toe segment of `length`, whose toe joint is
## already `drop` below the ankle, so the toe joint ends `lift` lower still.
static func tip_angle(length: float, drop: float, lift: float) -> float:
	if length <= 0.0 or lift <= 0.0:
		return 0.0
	var before: float = asin(clampf(drop / length, -1.0, 1.0))
	var after: float = asin(clampf((drop + lift) / length, -1.0, 0.95))
	return maxf(0.0, after - before)


func _process_modification() -> void:
	var skeleton: Skeleton3D = get_skeleton()
	if skeleton == null or _feet.is_empty() or rise <= 0.0 or up.is_zero_approx():
		return
	var lift_up: Vector3 = up.normalized()
	for index: int in _feet.size():
		var foot: int = _feet[index]
		var toe: int = _toes[index]
		var segment: Vector3 = skeleton.get_bone_global_pose(toe).origin - skeleton.get_bone_global_pose(foot).origin
		var across: Vector3 = lift_up.cross(segment)
		if across.is_zero_approx():
			continue
		# A turn about up x segment takes the segment toward down.
		var angle: float = tip_angle(segment.length(), -segment.dot(lift_up), rise)
		if is_zero_approx(angle):
			continue
		var swing := Quaternion(across.normalized(), angle)
		_turn(skeleton, foot, swing)
		_turn(skeleton, toe, swing.inverse())


## Turn a bone by `swing` (skeleton space) in its parent's current pose.
func _turn(skeleton: Skeleton3D, bone: int, swing: Quaternion) -> void:
	var parent: int = skeleton.get_bone_parent(bone)
	var parent_rotation: Quaternion = Quaternion.IDENTITY
	if parent >= 0:
		parent_rotation = skeleton.get_bone_global_pose(parent).basis.get_rotation_quaternion()
	var local: Quaternion = skeleton.get_bone_pose_rotation(bone)
	skeleton.set_bone_pose_rotation(bone, (parent_rotation.inverse() * swing * parent_rotation * local).normalized())
