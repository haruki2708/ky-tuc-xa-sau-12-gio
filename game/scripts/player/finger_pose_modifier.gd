class_name FingerPoseModifier
extends SkeletonModifier3D
## T-239: the player's own fingers, all five, thumb included, set to a whole hand shape (HandShapes):
## each joint takes its rest rotation turned by the shape's local rotation, whatever the clip does
## with the fingers (HandGripModifier, which the manager keeps, only adds a curl on top of the clip).
## The pose moves from `from_shape` to `to_shape` by `blend`; the modifier's influence blends the
## whole hand with the clip's own fingers (0 = the clip's hand).

const JOINTS: Array[String] = ["ThumbMetacarpal", "ThumbProximal", "ThumbDistal",
	"IndexProximal", "IndexIntermediate", "IndexDistal", "MiddleProximal", "MiddleIntermediate", "MiddleDistal",
	"RingProximal", "RingIntermediate", "RingDistal", "LittleProximal", "LittleIntermediate", "LittleDistal"]

## &"Right" or &"Left": the hand whose joints this sets.
@export var side: StringName = &"Right"
var from_shape: Dictionary = {}
var to_shape: Dictionary = {}
var blend: float = 1.0

var _indices: PackedInt32Array = PackedInt32Array()
var _rests: Array[Quaternion] = []


func _ready() -> void:
	var skeleton := get_skeleton()
	if skeleton == null:
		return
	for joint: String in JOINTS:
		var index := skeleton.find_bone(String(side) + joint)
		_indices.append(index)
		_rests.append(skeleton.get_bone_rest(index).basis.get_rotation_quaternion() if index >= 0 else Quaternion.IDENTITY)


## Hold one shape.
func hold(shape: Dictionary) -> void:
	from_shape = shape
	to_shape = shape
	blend = 1.0


## On the way from `from` to `to` (0..1).
func morph(from: Dictionary, to: Dictionary, amount: float) -> void:
	from_shape = from
	to_shape = to
	blend = clampf(amount, 0.0, 1.0)


func _process_modification() -> void:
	var skeleton := get_skeleton()
	if skeleton == null or _indices.is_empty():
		return
	for i: int in JOINTS.size():
		var index: int = _indices[i]
		if index < 0:
			continue
		var joint: String = JOINTS[i]
		var a: Quaternion = from_shape.get(joint, Quaternion.IDENTITY)
		var b: Quaternion = to_shape.get(joint, Quaternion.IDENTITY)
		skeleton.set_bone_pose_rotation(index, _rests[i] * a.slerp(b, blend))
