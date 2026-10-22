class_name BoneLockModifier
extends SkeletonModifier3D
## Holds one bone at a fixed local rotation on top of the animation (T-224, D-134). The manager's
## Tripo clips turn the right wrist as if the hand were empty, so the cleaver flipped over and the
## wrist looked twisted; held at its grip in "stand", the blade follows the forearm.

@export var bone: StringName = &"mixamorig_RightHand"
@export var locked_rotation: Quaternion = Quaternion.IDENTITY

var _index: int = -1


func _ready() -> void:
	var skeleton: Skeleton3D = get_skeleton()
	if skeleton != null:
		_index = skeleton.find_bone(bone)


## The bone's rotation in clip at time (its first rotation track for the bone), or false.
static func clip_rotation(clip: Animation, bone_name: StringName, time: float = 0.0) -> Variant:
	for track: int in clip.get_track_count():
		if clip.track_get_type(track) == Animation.TYPE_ROTATION_3D and String(clip.track_get_path(track)).ends_with(":" + bone_name):
			return clip.rotation_track_interpolate(track, time)
	return false


func _process_modification() -> void:
	var skeleton: Skeleton3D = get_skeleton()
	if skeleton == null or _index < 0:
		return
	skeleton.set_bone_pose_rotation(_index, locked_rotation)
