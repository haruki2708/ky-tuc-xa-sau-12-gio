class_name BodyLeanModifier
extends SkeletonModifier3D
## T-241 (owner's playtest, 10/11): a body that leans in from the hips with its feet where they
## stand, on top of the animation. A person reaching over a desk, or bending down to the floor,
## folds at the hips (the pelvis turns, the seat goes back, for the floor the knees give a little)
## far more than in the back; bending the back alone (SpineBendModifier) looked folded at the belly.
## - The pelvis turns `hip_degrees` about `axis` through the hip joints and moves by `shift`.
## - The back bends `spine_degrees` more (shared by `bones`) and turns `twist_degrees` about its
##   own line, the reaching shoulder leading.
## - The neck and head turn back `neck_degrees` and undo the twist: the face stays toward the work.
## - Each leg is solved again so its foot stays exactly where the animation put it: planted, the
##   heel down, the knee bending the way it already bends.
## - The other arm keeps hanging from its shoulder as the animation held it, swung `arm_degrees`
##   about `axis` (with the lean), instead of sticking out behind with the chest.
## PlayerBody plans with the same steps on measured joints (posed), so the planned shoulder and
## eyes are where this puts them.

@export var bones: PackedStringArray = PackedStringArray(["Spine", "Chest", "UpperChest"])
## Skeleton-space axis; positive angles tip the chest toward axis x up.
@export var axis: Vector3 = Vector3.RIGHT
## The whole lean (hips and back together), for reference: the parts below are what is applied.
@export var degrees: float = 0.0
@export var hip_degrees: float = 0.0
@export var spine_degrees: float = 0.0
@export var twist_degrees: float = 0.0
@export var neck_degrees: float = 0.0
## How far the pelvis moves, skeleton space (back and down).
@export var shift: Vector3 = Vector3.ZERO
## The free arm hangs as the animation held it (true), turned `arm_degrees` about `axis`.
@export var arm_hangs: bool = false
@export var arm_degrees: float = 0.0
@export var arm: StringName = &"LeftUpperArm"
## Skeleton-space up, and the legs' bones: upper, lower, foot.
@export var up: Vector3 = Vector3.UP
@export var legs: Array[PackedStringArray] = [
	PackedStringArray(["LeftUpperLeg", "LeftLowerLeg", "LeftFoot"]),
	PackedStringArray(["RightUpperLeg", "RightLowerLeg", "RightFoot"]),
]

var _spine: PackedInt32Array = PackedInt32Array()
var _legs: Array[PackedInt32Array] = []
var _hips: int = -1
var _neck: int = -1
var _head: int = -1
var _arm: int = -1


func _ready() -> void:
	var skeleton: Skeleton3D = get_skeleton()
	if skeleton == null:
		return
	for bone: String in bones:
		var index: int = skeleton.find_bone(bone)
		if index >= 0:
			_spine.append(index)
	for leg: PackedStringArray in legs:
		var indices := PackedInt32Array()
		for bone: String in leg:
			indices.append(skeleton.find_bone(bone))
		if indices.size() == 3 and not indices.has(-1):
			_legs.append(indices)
	_hips = skeleton.find_bone("Hips")
	_neck = skeleton.find_bone("Neck")
	_head = skeleton.find_bone("Head")
	_arm = skeleton.find_bone(arm)


## A point `joint` and everything hanging from it posed by one step of the lean: `point` turned
## by `turn` about `joint`.
static func about(point: Vector3, joint: Vector3, turn: Basis) -> Vector3:
	return joint + turn * (point - joint)


## The pose's steps on bare points, for planning (PlayerBody._leaned): `points` are the hip
## pivot, the spine joints in order, then the neck, the head, and after them `riders` points that
## ride on the head (the eyes); `chest` are points that ride on the last spine joint (the shoulder
## joints). Everything in one space, `side` the lean's axis there (as `axis`), angles in degrees.
## Returns [spine..., neck, head, riders...] then the chest points, posed.
static func pose_points(pivot: Vector3, spine: Array[Vector3], neck: Vector3, head: Vector3, riders: Array[Vector3],
		chest: Array[Vector3], side: Vector3, hip: float, bend: float, twist: float, nod: float, move: Vector3) -> Dictionary:
	var joints: Array[Vector3] = spine.duplicate()
	var on_chest: Array[Vector3] = chest.duplicate()
	var top: Array[Vector3] = [neck, head]
	top.append_array(riders)
	# The pelvis: everything turns about the hip joints and moves with them.
	var hip_turn := Basis(side, deg_to_rad(hip))
	for index: int in joints.size():
		joints[index] = about(joints[index], pivot, hip_turn) + move
	for index: int in on_chest.size():
		on_chest[index] = about(on_chest[index], pivot, hip_turn) + move
	for index: int in top.size():
		top[index] = about(top[index], pivot, hip_turn) + move
	# The back: each spine joint a share of the bend, then of the twist about the back's own line.
	var count: int = maxi(joints.size(), 1)
	for pass_index: int in 2:
		var line: Vector3 = side
		var angle: float = deg_to_rad(bend) / count
		if pass_index == 1:
			line = (top[0] - joints[0]).normalized() if not joints.is_empty() else Vector3.UP
			angle = deg_to_rad(twist) / count
		if is_zero_approx(angle):
			continue
		var turn := Basis(line, angle)
		for joint: int in joints.size():
			var at: Vector3 = joints[joint]
			for index: int in range(joint + 1, joints.size()):
				joints[index] = about(joints[index], at, turn)
			for index: int in on_chest.size():
				on_chest[index] = about(on_chest[index], at, turn)
			for index: int in top.size():
				top[index] = about(top[index], at, turn)
	# The neck undoes the twist and, with the head, turns back.
	var back_line: Vector3 = (top[0] - joints[0]).normalized() if not joints.is_empty() else Vector3.UP
	var nod_turn := Basis(side, -deg_to_rad(nod) * 0.5)
	var neck_turn := nod_turn * Basis(back_line, -deg_to_rad(twist))
	for index: int in range(1, top.size()):
		top[index] = about(top[index], top[0], neck_turn)
	for index: int in range(2, top.size()):
		top[index] = about(top[index], top[1], nod_turn)
	return {"spine": joints, "top": top, "chest": on_chest}


func _process_modification() -> void:
	var skeleton: Skeleton3D = get_skeleton()
	if skeleton == null or _hips < 0 or axis.is_zero_approx():
		return
	var leaning: bool = not (is_zero_approx(hip_degrees) and is_zero_approx(spine_degrees) and is_zero_approx(twist_degrees) \
			and is_zero_approx(neck_degrees) and shift.is_zero_approx())
	if not leaning:
		return
	var side: Vector3 = axis.normalized()
	# Where the animation holds the feet, the knees and the free arm, before anything moves.
	var held: Array = []
	for leg: PackedInt32Array in _legs:
		held.append([skeleton.get_bone_global_pose(leg[0]).origin, skeleton.get_bone_global_pose(leg[1]).origin,
				skeleton.get_bone_global_pose(leg[2])])
	var arm_held: Quaternion = skeleton.get_bone_global_pose(_arm).basis.get_rotation_quaternion() if _arm >= 0 else Quaternion.IDENTITY
	var moves_legs: bool = not (is_zero_approx(hip_degrees) and shift.is_zero_approx()) and not _legs.is_empty()
	if moves_legs:
		var pivot := Vector3.ZERO
		for entry: Array in held:
			pivot += (entry[0] as Vector3) / held.size()
		var hips: Transform3D = skeleton.get_bone_global_pose(_hips)
		var turn := Quaternion(side, deg_to_rad(hip_degrees))
		_place(skeleton, _hips, turn * hips.basis.get_rotation_quaternion(), pivot + turn * (hips.origin - pivot) + shift)
	if not _spine.is_empty():
		var share: Quaternion = Quaternion(side, deg_to_rad(spine_degrees) / _spine.size())
		if not is_zero_approx(spine_degrees):
			for bone: int in _spine:
				TiptoeModifier.turn(skeleton, bone, share)
		if not is_zero_approx(twist_degrees) and _neck >= 0:
			var line: Vector3 = (skeleton.get_bone_global_pose(_neck).origin - skeleton.get_bone_global_pose(_spine[0]).origin).normalized()
			var twist := Quaternion(line, deg_to_rad(twist_degrees) / _spine.size())
			for bone: int in _spine:
				TiptoeModifier.turn(skeleton, bone, twist)
	if _neck >= 0 and _head >= 0 and not (is_zero_approx(neck_degrees) and is_zero_approx(twist_degrees)):
		var nod := Quaternion(side, -deg_to_rad(neck_degrees) * 0.5)
		var untwist := Quaternion.IDENTITY
		if not is_zero_approx(twist_degrees) and not _spine.is_empty():
			var line: Vector3 = (skeleton.get_bone_global_pose(_neck).origin - skeleton.get_bone_global_pose(_spine[0]).origin).normalized()
			untwist = Quaternion(line, -deg_to_rad(twist_degrees))
		TiptoeModifier.turn(skeleton, _neck, nod * untwist)
		TiptoeModifier.turn(skeleton, _head, nod)
	if moves_legs:
		for index: int in _legs.size():
			_plant(skeleton, _legs[index], held[index], side)
	if arm_hangs and _arm >= 0:
		var hanging: Quaternion = Quaternion(side, deg_to_rad(arm_degrees)) * arm_held
		var now: Quaternion = skeleton.get_bone_global_pose(_arm).basis.get_rotation_quaternion()
		TiptoeModifier.turn(skeleton, _arm, hanging * now.inverse())


## Give a bone a skeleton-space rotation and origin.
func _place(skeleton: Skeleton3D, bone: int, rotation: Quaternion, origin: Vector3) -> void:
	var parent: int = skeleton.get_bone_parent(bone)
	var parent_pose := Transform3D.IDENTITY
	if parent >= 0:
		parent_pose = skeleton.get_bone_global_pose(parent)
	var parent_rotation: Quaternion = parent_pose.basis.get_rotation_quaternion()
	skeleton.set_bone_pose_rotation(bone, (parent_rotation.inverse() * rotation).normalized())
	skeleton.set_bone_pose_position(bone, parent_pose.affine_inverse() * origin)


## One leg (upper, lower, foot) from where the pelvis has taken its hip joint back to the foot the
## animation held (`held`: its hip joint, knee and foot pose then): the knee bends in the plane it
## already bent in; the foot keeps its place and its turn.
func _plant(skeleton: Skeleton3D, leg: PackedInt32Array, held: Array, side: Vector3) -> void:
	var hip_then: Vector3 = held[0]
	var knee_then: Vector3 = held[1]
	var foot_then: Transform3D = held[2]
	var thigh: float = hip_then.distance_to(knee_then)
	var shin: float = knee_then.distance_to(foot_then.origin)
	var hip: Vector3 = skeleton.get_bone_global_pose(leg[0]).origin
	var to_foot: Vector3 = foot_then.origin - hip
	var reach: float = clampf(to_foot.length(), absf(thigh - shin) + 0.0001, thigh + shin - 0.0001)
	if reach < 0.001:
		return
	var line: Vector3 = to_foot.normalized()
	# Which way the knee points: off the hip-to-foot line as the animation had it, else forward.
	var line_then: Vector3 = (foot_then.origin - hip_then).normalized()
	var bend: Vector3 = (knee_then - hip_then) - line_then * (knee_then - hip_then).dot(line_then)
	if bend.length() < 0.005:
		bend = side.cross(up)
	bend -= line * bend.dot(line)
	if bend.length() < 0.0001:
		return
	bend = bend.normalized()
	var along: float = (thigh * thigh - shin * shin + reach * reach) / (2.0 * reach)
	var out: float = sqrt(maxf(thigh * thigh - along * along, 0.0))
	var knee: Vector3 = hip + line * along + bend * out
	var knee_now: Vector3 = skeleton.get_bone_global_pose(leg[1]).origin
	if (knee_now - hip).length() > 0.0001:
		TiptoeModifier.turn(skeleton, leg[0], Quaternion((knee_now - hip).normalized(), (knee - hip).normalized()))
	knee = skeleton.get_bone_global_pose(leg[1]).origin
	var foot_now: Vector3 = skeleton.get_bone_global_pose(leg[2]).origin
	if (foot_now - knee).length() > 0.0001 and (foot_then.origin - knee).length() > 0.0001:
		TiptoeModifier.turn(skeleton, leg[1], Quaternion((foot_now - knee).normalized(), (foot_then.origin - knee).normalized()))
	var turned: Quaternion = skeleton.get_bone_global_pose(leg[2]).basis.get_rotation_quaternion()
	TiptoeModifier.turn(skeleton, leg[2], foot_then.basis.get_rotation_quaternion() * turned.inverse())
