class_name HandGripModifier
extends SkeletonModifier3D
## Curls listed finger bones on top of the animation so a hand closes on what it holds.
## Tripo clips leave the hands open; the manager's right hand must grip the cleaver.

@export var bones: PackedStringArray = PackedStringArray()
## Local axis each finger bone bends around (measured on the Tripo/Mixamo rig: +X curls to the palm).
@export var axis: Vector3 = Vector3.RIGHT
@export_range(0.0, 120.0) var curl_degrees: float = 70.0

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
	if skeleton == null:
		return
	var curl: Quaternion = Quaternion(axis.normalized(), deg_to_rad(curl_degrees))
	for index: int in _indices:
		skeleton.set_bone_pose_rotation(index, skeleton.get_bone_pose_rotation(index) * curl)
