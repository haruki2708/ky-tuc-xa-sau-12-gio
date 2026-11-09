class_name PlayerBody
extends Node3D
## T-220 (D-121): the player's own body in first person.
## - The view mesh hides the head (its skin folds the head bone to a point) and casts no
##   shadow; a copy on the mirror layer casts the shadow and shows in mirrors.
## - The body stands so its eyes are under the camera in every clip (crouching leans the head
##   forward), and walk, run and crouch clips play at the speed the feet need: no sliding.
## - A hand action takes HAND_SECONDS: the hand travels to the target's HandTarget (IK, leaning
##   in when the arm alone is short), uses it at CONTACT, and from RELEASE travels back to where
##   the clip holds it before IK lets go, so the arm never swings through the body. A picked-up
##   paper rides to the eyes, and after reading is carried back to its place before the hand
##   lets go. The camera follows the head while leaning. Movement is locked meanwhile; looking
##   around is not.
## - D-124 (owner): what is used by hand must be within reach (can_reach; the player hides the
##   prompt otherwise); the camera turns toward the working hand and back; a lever (door handle)
##   is taken, pressed down, and only then does the thing move; the left hand holds the phone
##   while it is raised or its light is on.
## - T-227 (D-137): the body is Tran Trung from Tripo (pack_tripo_protagonist.py), about 1.74 m
##   once his eyes meet the camera.

signal hand_action_finished(target: Interactable)

enum Phase { REACH, HOLD, RETURN, READ, PUT_DOWN, LET_GO }

const HAND_SECONDS: float = 1.0
const CONTACT: float = 0.45
const RELEASE: float = 0.8
## After reading: carry the paper back to its place, then the empty hand back to the side.
const PUT_DOWN_SECONDS: float = 0.5
const LET_GO_SECONDS: float = 0.35
## IK fades in and out over this, while the goal sits on the clip's own hand.
const IK_FADE: float = 0.08
const MIRROR_LAYER: int = 20
const BLEND_SECONDS: float = 0.2
const MOVING: float = 0.15
## Between the player's walk (2.2 m/s) and sprint (3.6 m/s) speeds.
const RUN_FROM: float = 2.9
const MAX_YAW: float = deg_to_rad(60.0)
## T-227 round 2: standing still the feet keep their heading while the view turns (the chest
## TWIST_SHARE of the way with it); past TURN_START the body steps round at TURN_SPEED (rad/s) until
## it faces the view again. A jump past TURN_SNAP (a teleport, a respawn) is not stepped.
const TURN_START: float = deg_to_rad(50.0)
const TURN_SPEED: float = 3.0
const TURN_DONE: float = deg_to_rad(2.0)
const TURN_SNAP: float = deg_to_rad(135.0)
const TWIST_SHARE: float = 0.6
## The walk clip's pace while stepping round on the spot.
const TURN_STEP_PACE: float = 0.7
## T-227 round 2 (D-147): in bed the body lies along the bed (the bed's view looks down it to the
## feet), held at the moment of getting up where the chest is BED_RECLINE degrees up (the view sits
## 0.43 m over the mattress, propped on the pillow), its eyes on the camera. Getting in and out of
## bed stay as they were (no motion of their own).
const BED_RECLINE: float = 30.0
## Eyes from the head bone, model space (the model faces +Z), metres before scaling. Tran Trung's
## head bone sits 1.7 cm left of his face's middle (measured on the Tripo mesh, T-227).
const EYES_FROM_HEAD_BONE: Vector3 = Vector3(-0.017, 0.08, 0.09)
## The palm centre beyond the wrist bone: IK puts the wrist here short of the HandTarget, along
## the fingers of the turned hand, so the palm lands on it.
const PALM: float = 0.08
## Finger curl while holding a paper up to read: closed round its edge.
const READ_CURL: float = 30.0
## Half the palm's thickness (model metres before scaling). What a hand holds sits on the palm
## side, never inside the palm: a lever HOLD_GAP out, a paper's marked point (1.5 cm inside its
## edge) PAPER_GAP out, so the sheet's edge stops just short of the palm, between the thumb and
## the fingers (the owner: in the grip a little, not through the palm, by a side edge, 19/10).
const HAND_HALF: float = 0.02
const HOLD_GAP: float = 0.012
const PAPER_GAP: float = 0.018
## Reading, the sheet sits this much toward the eyes from the palm's middle: the thumb in front.
const THUMB_DEPTH: float = 0.01
## Share of the arm's full length a hand reaches without straining (T-227: measured on the
## skeleton, Tran Trung's arms are shorter than the stand-in's).
const ARM_STRAIGHT: float = 0.95
const MAX_BEND: float = 45.0
## D-152 (owner: lean and crouch): a desk or a bed keeps the player's capsule (0.3 m) about half a
## metre off what lies on it. What a straight-backed reach (MAX_BEND, palm) misses is taken leaning
## over it as far as LEAN_BEND, a pinch or hook out to the fingertips; what that misses, crouched
## down (the player crouches for it) and leaning as far as KNEEL_BEND.
const LEAN_BEND: float = 75.0
const KNEEL_BEND: float = 85.0
## D-152: what is high and behind something low (a shelf over a locker) is taken up on the toes
## with the chest leaning over the low thing, as far as HIGH_LEAN.
const HIGH_LEAN: float = 45.0
## T-227 round 2: what is above the reach of a straight arm is taken up on the toes, the ankles
## rising at most this far (metres), the elbow out to the side.
const TIPTOE: float = 0.08
## Reaching up the collarbone lifts the shoulder joint this far (degrees toward up), and a pinch
## or hook takes the thing at the fingertips, not the palm: every centimetre overhead counts.
const SHOULDER_RAISE: float = 25.0
## The distal finger bone's own length past its joint (model metres), to the fingertip.
const FINGERTIP: float = 0.025
## Looking down bends the neck: the eyes move this far forward at a straight-down look, so
## the chest no longer hides the legs and feet.
const NECK_FORWARD: float = 0.14
## Share of the head's lean the camera follows: enough to feel the reach, not so much that the
## view presses into the door being opened.
const LEAN_FOLLOW: float = 0.6
## The camera turns toward the working hand this share of the way, at most LOOK_LIMIT off the
## player's own aim (D-124).
const LOOK_FOLLOW: float = 0.85
const LOOK_LIMIT: float = deg_to_rad(40.0)
## A lever is pressed over this long once the hand has it, and springs back as long after release.
const LEVER_SECONDS: float = 0.15
## The left hand takes the phone over this long when it is raised or its light goes on (D-124).
const PHONE_FADE: float = 0.25
## The phone in the left hand, camera space: raised to read (screen to the eyes), or held low
## with its light ahead and the screen tipped up.
const PHONE_RAISED_AT: Vector3 = Vector3(-0.12, -0.11, -0.3)
const PHONE_RAISED_TILT: Vector3 = Vector3(-0.15, 0.2, 0.08)
const PHONE_LOW_AT: Vector3 = Vector3(-0.14, -0.17, -0.3)
const PHONE_LOW_TILT: Vector3 = Vector3(-0.9, 0.25, 0.0)
## The light leaves the phone this far ahead of it (clear of the hand holding it).
const PHONE_LIGHT_AHEAD: float = 0.06
const PHONE_CURL: float = 50.0
const LEFT_GRIP_BONES: PackedStringArray = [
	"LeftIndexProximal", "LeftIndexIntermediate", "LeftIndexDistal",
	"LeftMiddleProximal", "LeftMiddleIntermediate", "LeftMiddleDistal",
	"LeftRingProximal", "LeftRingIntermediate", "LeftRingDistal",
	"LeftLittleProximal", "LeftLittleIntermediate", "LeftLittleDistal",
]
## Where a picked-up paper's centre is held to read, in camera space (the hand is at its edge,
## and the arm must reach it: about 30 cm out, a little below the eyes).
const READ_POINT: Vector3 = Vector3(0.0, -0.09, -0.27)
const SAMPLES: int = 48
## A foot whose ankle and toes are both this close to their lowest points is planted flat.
const STANCE_HEIGHT: float = 0.02
## T-227: Tran Trung's own Tripo clips where Tripo has them; the rest from the CC0 Quaternius
## library (FILL_LIBRARY), retargeted onto his skeleton through the shared humanoid bone names.
const CLIPS := {
	&"idle": &"idle", &"walk": &"walk", &"run": &"run",
	&"crouch_idle": &"ual/Crouch_Idle", &"crouch_walk": &"ual/Crouch_Fwd",
	&"reach": &"ual/Interact", &"reach_low": &"ual/PickUp_Table",
	&"get_up": &"ual2/LayToIdle", &"climb_up": &"ual2/ClimbUp_1m",
	&"knockback": &"ual2/Hit_Knockback", &"carry_walk": &"ual2/Walk_Carry",
}
const FILL_LIBRARY: StringName = &"ual"
const FILL_SCENE: PackedScene = preload("res://assets/models/characters/standin/quaternius_ual.glb")
## T-227 round 2 (D-143): the CC0 Quaternius UAL2 Standard pack, only the clips the game uses.
const FILL2_LIBRARY: StringName = &"ual2"
const FILL2_SCENE: PackedScene = preload("res://assets/models/characters/standin/quaternius_ual2.glb")
const FILL2_IDLE: StringName = &"Idle_FoldArms"
const FILL2_CLIPS: Array[StringName] = [&"LayToIdle", &"ClimbUp_1m", &"Hit_Knockback", &"Walk_Carry", &"Idle_FoldArms"]
const LOCOMOTION: Array[StringName] = [&"idle", &"walk", &"run", &"crouch_idle", &"crouch_walk"]
## A HandTarget lower than this above the feet uses the low reach.
const LOW_REACH: float = 0.95
const GRIP_BONES: PackedStringArray = [
	"RightIndexProximal", "RightIndexIntermediate", "RightIndexDistal",
	"RightMiddleProximal", "RightMiddleIntermediate", "RightMiddleDistal",
	"RightRingProximal", "RightRingIntermediate", "RightRingDistal",
	"RightLittleProximal", "RightLittleIntermediate", "RightLittleDistal",
]
const GRIP_DEGREES := {HandTarget.Grip.GRIP: 75.0, HandTarget.Grip.PINCH: 35.0, HandTarget.Grip.HOOK: 55.0}

@export var model_scene: PackedScene = preload("res://assets/models/characters/protagonist/trung_tripo.glb")
## Standing eye height; the player's Head sits at 1.6 m.
@export var eye_height: float = 1.6

var player: CharacterBody3D
var model: Node3D
var skeleton: Skeleton3D
var animator: AnimationPlayer
var view_meshes: Array[MeshInstance3D] = []
var mirror_meshes: Array[MeshInstance3D] = []
## Stride speed (m/s) of each moving clip at this body's scale.
var stride_speeds: Dictionary = {}
## Mean eye point (model space, unscaled) of each locomotion clip.
var eye_points: Dictionary = {}
var acting: bool = false
## Shoulder to palm a hand reaches without straining, metres before scaling.
var arm_reach: float = 0.6
## Palm centre to the middle fingertip, metres before scaling.
var finger_reach: float = 0.08

var _key: StringName = &""
var _clip: StringName = &""
var _yaw: float = 0.0
var _eye: Vector3 = Vector3.ZERO
var _ik: TwoBoneIK3D
var _grip: HandGripModifier
var _align: HandAlignModifier
var _bend: SpineBendModifier
var _tiptoe: TiptoeModifier
var _raise: ShoulderRaiseModifier
var _twist: SpineBendModifier
## The world heading the feet keep while standing, and whether the body is stepping round.
var _stand_yaw: float = 0.0
var _turning: bool = false
## In bed (D-147), and the world yaw of the model lying along it.
var _in_bed: bool = false
## D-151: once the player starts dying the body is put away (the death camera stays as it was, T-227);
## the chapter reloads on restart, so it never comes back.
var _dead: bool = false
## D-152: the bend bones then the right shoulder joint, model space, of the standing and crouched
## poses (measured once), and each pose's right collarbone joint. Every reach is judged on the
## pose it is done in, square to the view, whatever the clip, the feet or the chest twist are doing
## at that frame: the prompt (can_reach) and the action (perform) agree.
var _reach_joints: Dictionary = {}
var _reach_collars: Dictionary = {}
## How this reach is done: &"near" (as before D-152), &"up" (toes and a lean), &"lean" or &"kneel".
var _reach: StringName = &"near"
var _bed_yaw: float = 0.0
## The get-up clip's time at BED_RECLINE, and the head-to-hips direction there (model space).
var _recline: float = -1.0
var _recline_lie: Vector3 = Vector3.BACK
## The eyes in the head bone's own space (they turn with the head when it lies back).
var _eye_in_head: Vector3 = Vector3.INF
## How far up on the toes this reach goes (metres), and how far it is now.
var _rise_target: float = 0.0
var _rise: float = 0.0
## This reach is above a straight arm (up on the toes, shoulder lifted, fingers along the arm).
var _high: bool = false
## Beyond the palm centre to where the hand takes the thing (metres before scaling): the
## fingertips for a high pinch or hook, else 0.
var _tip_extra: float = 0.0
## The share of this reach's lean, rise and shoulder lift last given to _weigh.
var _rise_weight: float = 0.0
var _pole_rest: Vector3
## The hand bone's local axis that faces out of the palm (the side the fingers curl to).
var _palm_axis: Vector3 = Vector3.FORWARD
var _start_basis: Basis
var _head_attach: BoneAttachment3D
var _hand_attach: BoneAttachment3D
var _goal: Node3D
var _pole: Node3D
var _head: Node3D
var _eye_start: Vector3
## Our offset on the player's Head (neck bend and lean); the rest is the player's own.
var _head_offset: Vector3 = Vector3.ZERO
var _head_written: Vector3 = Vector3.INF
var _lean: Vector3 = Vector3.ZERO
var _bend_degrees: float = 0.0
var _target: Interactable
var _marker: HandTarget
var _time: float = 0.0
var _contacted: bool = false
var _carried: Node3D
var _carried_from: Transform3D
## The carried sheet's centre in the HandTarget's space (the hand holds it by that point).
var _carried_centre: Vector3 = Vector3.ZERO
var _hidden_meshes: Array[MeshInstance3D] = []
## True while the picked-up document is open.
var _reading: bool = false
var _phase: Phase = Phase.REACH
var _phase_time: float = 0.0
## Where the goal's current leg starts.
var _from: Vector3
## The thing has been used (for a lever, once it is pressed down).
var _used: bool = false
var _lever_rest: Quaternion = Quaternion.IDENTITY
var _left_ik: TwoBoneIK3D
var _left_align: HandAlignModifier
var _left_grip: HandGripModifier
var _left_goal: Node3D
var _left_pole: Node3D
var _left_attach: BoneAttachment3D
var _left_palm_axis: Vector3 = Vector3.FORWARD
var _phone: Node3D
var _phone_weight: float = 0.0
var _phone_raise: float = 0.0
var _phone_half: float = 0.006


func _ready() -> void:
	model = model_scene.instantiate() as Node3D
	model.name = "Model"
	add_child(model)
	model.rotation.y = PI
	skeleton = model.find_children("*", "Skeleton3D", true, false)[0] as Skeleton3D
	animator = model.find_children("*", "AnimationPlayer", true, false)[0] as AnimationPlayer
	# The player moves on physics frames: stepping the clips anywhere else lets a planted foot
	# skip with the body whenever a render frame holds two physics frames.
	animator.callback_mode_process = AnimationMixer.ANIMATION_CALLBACK_MODE_PROCESS_PHYSICS
	_add_fill_clips()
	_fit_height()
	_measure_arm()
	_split_meshes()
	_build_modifiers()
	for key: StringName in LOCOMOTION:
		_measure(key)
		# Tran Trung's idle is a short window of Tripo's (pack_tripo_protagonist.py): back and forth
		# hides the seam.
		animator.get_animation(CLIPS[key]).loop_mode = Animation.LOOP_PINGPONG if key == &"idle" else Animation.LOOP_LINEAR
	_measure_reach_joints()
	_eye = eye_points[&"idle"]
	_play(&"idle")
	_place_model(0.0)
	EventBus.document_closed.connect(_on_document_closed)
	EventBus.player_death_started.connect(_on_death_started)


## Attach to a player (player.gd calls this from set_body): the camera stops drawing the
## mirror layer, so only the headless view mesh is seen from inside.
func bind(owner_player: CharacterBody3D) -> void:
	player = owner_player
	if player.is_inside_tree():
		_stand_yaw = player.global_rotation.y
	_head = player.get_node_or_null("Head") as Node3D
	var camera := player.get_node_or_null("Head/Camera3D") as Camera3D
	if camera != null:
		camera.set_cull_mask_value(MIRROR_LAYER, false)
	_phone = player.get_node_or_null("Head/Camera3D/PhoneItem") as Node3D
	var phone_body := _phone.get_node_or_null("Model/Body") if _phone != null else null
	if phone_body != null:
		# T-227: the Tripo phone (a GLB scene) or a plain mesh.
		var meshes: Array[Node] = phone_body.find_children("*", "MeshInstance3D", true, false)
		if phone_body is MeshInstance3D:
			meshes.append(phone_body)
		for mesh: MeshInstance3D in meshes:
			if mesh.mesh != null:
				_phone_half = mesh.mesh.get_aabb().size.z * 0.5


func can_handle(target: Interactable) -> bool:
	return not acting and not _in_bed and not _dead and is_instance_valid(target) and target.enabled \
			and target.hand_target(_reach_from()) != null


## D-124: the HandTarget is within reach, leaning in at most MAX_BEND.
func can_reach(target: Interactable) -> bool:
	if not is_instance_valid(target):
		return false
	# Judged for a body square to the view, as perform() turns it (standing, the feet may lag).
	var drawn: float = _yaw
	if not acting:
		_place_model(0.0)
	var marker: HandTarget = target.hand_target(_reach_from())
	var reachable: bool = marker != null and _reach_kind(marker) != &""
	if not acting:
		_place_model(drawn)
	return reachable


func _reach_from() -> Vector3:
	return _bone_world("RightUpperArm")


func perform(target: Interactable) -> void:
	if not can_handle(target):
		return
	_face_view()
	acting = true
	_target = target
	_marker = target.hand_target(_reach_from())
	_time = 0.0
	_contacted = false
	_used = false
	if is_instance_valid(_marker.lever):
		_lever_rest = _marker.lever.quaternion
	_reading = false
	_set_phase(Phase.REACH)
	_from = _hand_tip()
	_start_basis = _natural_basis()
	if is_instance_valid(player) and player.has_method("acquire_movement_lock"):
		player.acquire_movement_lock(self)
	_eye_start = _eye_world()
	var low: bool = _marker.global_position.y - global_position.y < LOW_REACH
	# Above a straight arm: no lean, up on the toes. The body stands still (the reach clip steps
	# and lifts a heel) and the arm and the toes do it.
	_reach = _reach_kind(_marker)
	var high: bool = _reach == &"up" or (_reach == &"near" and _marker.global_position.y > _bone_world("RightUpperArm").y \
			and is_inf(_bend_for(_marker.global_position)))
	_high = high
	_tip_extra = finger_reach if (high or _reach != &"near") and _marker.grip != HandTarget.Grip.GRIP else 0.0
	# D-152: crouched down for it; the player stands back up by itself once the hand is back.
	if _reach == &"kneel" and is_instance_valid(player) and not bool(player.get("crouched")) \
			and player.has_method("_set_crouched"):
		player.call("_set_crouched", true)
		# The camera drops with the player's crouch; only the lean from there on moves it further.
		_eye_start.y -= (eye_points[&"idle"].y - eye_points[&"crouch_idle"].y) * _scale()
	_clip = CLIPS[&"crouch_idle" if _reach == &"kneel" else (&"idle" if high else (&"reach_low" if low else &"reach"))]
	_key = &""
	animator.speed_scale = 1.0
	animator.play(_clip, BLEND_SECONDS, animator.get_animation(_clip).length / HAND_SECONDS)
	_grip.curl_degrees = GRIP_DEGREES[_marker.grip]
	_aim(_from, _start_basis, 0.0)
	_plan_bend(_marker.global_position)
	if _reach == &"lean" or _reach == &"kneel":
		_bend_degrees = _posed_bend(_marker.global_position, &"crouch_idle" if _reach == &"kneel" else &"idle",
				_tip_extra, KNEEL_BEND if _reach == &"kneel" else LEAN_BEND)
	_rise_target = 0.0
	_pole.position = _pole_rest
	if high:
		# The elbow out to the side and up; over something low the chest leans in first (D-152).
		_bend_degrees = _up_lean(_marker.global_position, _marker.grip) if _reach == &"up" else 0.0
		_rise_target = minf(_rise_from(_leaned_shoulder(_marker.global_position, _bend_degrees),
				_marker.global_position, _marker.grip), TIPTOE)
		_pole.position = Vector3(_pole_rest.x * 1.5, _shoulder_model_height(), -_pole_rest.z * 0.5)


func _physics_process(delta: float) -> void:
	if not is_instance_valid(player) or _dead:
		return
	visible = _in_bed or not (player.has_method("is_hidden") and player.call("is_hidden"))
	if _in_bed:
		_tick_bed()
	elif acting:
		_tick_action(delta)
	else:
		_lean = Vector3.ZERO
		_tick_locomotion(delta)
	_tick_phone(delta)
	_move_head()


## Head = the player's own position (stand/crouch height) + neck bend + lean. A write by the
## player (crouching, hiding) since our last one becomes the new base.
func _move_head() -> void:
	if not is_instance_valid(_head):
		return
	var base: Vector3 = _head.position if _head.position != _head_written else _head.position - _head_offset
	var offset: Vector3 = _lean
	if visible:
		var down: float = maxf(0.0, -_head.rotation.x)
		offset += Vector3(0.0, 0.0, -NECK_FORWARD * sin(down))
	_head_offset = offset
	_head.position = base + offset
	_head_written = _head.position


func _tick_locomotion(delta: float) -> void:
	var local: Vector3 = player.global_basis.inverse() * player.velocity
	local.y = 0.0
	var speed: float = local.length()
	var crouched: bool = bool(player.get("crouched"))
	var target_yaw: float = 0.0
	var follow: float = 1.0 - exp(-10.0 * delta)
	var view_yaw: float = player.global_rotation.y
	if speed > MOVING:
		_turning = false
		var heading: float = atan2(-local.x, -local.z)
		var direction: float = 1.0
		if absf(heading) > deg_to_rad(100.0):
			# Walking backwards: face forward-ish and play the stride in reverse.
			direction = -1.0
			heading = wrapf(heading + PI, -PI, PI)
		target_yaw = clampf(heading, -MAX_YAW, MAX_YAW)
		var key: StringName = &"crouch_walk" if crouched else (&"run" if speed > RUN_FROM else &"walk")
		_play(key)
		# Sideways, only the share of the motion along the body is in the stride.
		var along: float = speed * cos(absf(heading) - absf(target_yaw))
		animator.speed_scale = direction * maxf(along, 0.2) / maxf(stride_speeds[key], 0.05)
		_yaw = lerp_angle(_yaw, target_yaw, follow)
	else:
		_yaw = _stand_turn(wrapf(_stand_yaw - view_yaw, -PI, PI), delta)
		if _turning:
			_play(&"crouch_walk" if crouched else &"walk")
			animator.speed_scale = TURN_STEP_PACE
		else:
			_play(&"crouch_idle" if crouched else &"idle")
			animator.speed_scale = 1.0
	_stand_yaw = view_yaw + _yaw
	_set_twist(-_yaw * TWIST_SHARE)
	_eye = _eye.lerp(eye_points[_key], follow)
	_place_model(_yaw)


## Standing, the body's heading off the view (`lag`, radians) this frame: kept while small,
## stepped round toward 0 once past TURN_START, dropped at once past TURN_SNAP.
func _stand_turn(lag: float, delta: float) -> float:
	if absf(lag) > TURN_SNAP:
		_turning = false
		return 0.0
	if absf(lag) > TURN_START:
		_turning = true
	if _turning:
		lag -= signf(lag) * minf(TURN_SPEED * delta, absf(lag))
		if absf(lag) <= TURN_DONE:
			_turning = false
	return lag


## Turn the chest about the vertical by `angle` (radians, world sense), shared by the spine.
func _set_twist(angle: float) -> void:
	_twist.axis = _tiptoe.up * signf(angle) if not is_zero_approx(angle) else _tiptoe.up
	_twist.degrees = rad_to_deg(absf(angle))


## D-147: in the bed `spot` (a HideSpot whose View looks down the bed), lying propped on the
## pillow at once; the camera gets in as it always has.
func enter_bed(spot: Node3D) -> void:
	var view := spot.get_node_or_null(NodePath(str(spot.get("view")))) as Node3D if spot != null else null
	var feet: Vector3 = -((view if view != null else spot).global_basis.z) if spot != null else -global_basis.z
	feet.y = 0.0
	_measure_recline()
	_bed_yaw = _yaw_of(feet) - _yaw_of(_recline_lie)
	_in_bed = true
	_turning = false
	_set_twist(0.0)
	_key = &""
	_hold_recline()


## Out of bed: standing again, at once.
func leave_bed() -> void:
	if not _in_bed:
		return
	_in_bed = false
	animator.speed_scale = 1.0
	if not is_inside_tree():
		return
	_key = &""
	_clip = &""
	_play(&"idle")
	_yaw = 0.0
	_turning = false
	if is_instance_valid(player):
		_stand_yaw = player.global_rotation.y
	_place_model(0.0)


func in_bed() -> bool:
	return _in_bed


## In bed the body lies along it with its eyes on the camera (which may still be sliding up to an
## upper bunk's pillow).
func _tick_bed() -> void:
	_hang_from_camera(_bed_yaw)


## The get-up clip held at the propped moment.
func _hold_recline() -> void:
	var clip: StringName = CLIPS[&"get_up"]
	_clip = clip
	animator.speed_scale = 1.0
	animator.play(clip, 0.0, 1.0)
	animator.seek(_recline, true)
	animator.speed_scale = 0.0


## Find the get-up clip's moment where the chest is BED_RECLINE degrees up (first on the way up),
## and which way the head-to-hips line runs there.
func _measure_recline() -> void:
	if _recline >= 0.0:
		return
	var clip: StringName = CLIPS[&"get_up"]
	var length: float = animator.get_animation(clip).length
	var hips: int = skeleton.find_bone("Hips")
	var head: int = skeleton.find_bone("Head")
	var to_model: Transform3D = model.global_transform.affine_inverse() * skeleton.global_transform
	animator.play(clip)
	_recline = 0.0
	for index: int in 61:
		var time: float = length * index / 60.0
		animator.seek(time, true)
		var torso: Vector3 = to_model * skeleton.get_bone_global_pose(head).origin - to_model * skeleton.get_bone_global_pose(hips).origin
		_recline = time
		_recline_lie = Vector3(-torso.x, 0.0, -torso.z)
		if torso.normalized().y >= sin(deg_to_rad(BED_RECLINE)):
			break
	if _recline_lie.length() < 0.01:
		_recline_lie = Vector3.BACK
	animator.stop()


## Place the model, turned to world yaw `yaw`, with its eyes (as the clip holds the head now) on
## the player's camera.
func _hang_from_camera(yaw: float) -> void:
	var camera := player.get_node_or_null("Head/Camera3D") as Node3D if is_instance_valid(player) else null
	if camera == null:
		return
	var basis := Basis(Vector3.UP, yaw).scaled(Vector3.ONE * _scale())
	model.global_transform = Transform3D(basis, camera.global_position - basis * _eye_in_model())


## The eyes in the model's space as the clip holds the head now (they turn with the head).
func _eye_in_model() -> Vector3:
	var head: int = skeleton.find_bone("Head")
	var to_model: Transform3D = model.global_transform.affine_inverse() * skeleton.global_transform
	if not _eye_in_head.is_finite():
		var rest: Transform3D = to_model * skeleton.get_bone_global_rest(head)
		_eye_in_head = rest.affine_inverse() * (rest.origin + EYES_FROM_HEAD_BONE)
	return (to_model * skeleton.get_bone_global_pose(head)) * _eye_in_head


static func _yaw_of(direction: Vector3) -> float:
	return atan2(direction.x, direction.z)


## Face the view at once (a hand action starts from a body square to it).
func _face_view() -> void:
	_turning = false
	_yaw = 0.0
	_set_twist(0.0)
	if is_instance_valid(player):
		_stand_yaw = player.global_rotation.y
	_place_model(0.0)


func _tick_action(delta: float) -> void:
	if not is_instance_valid(_target) or not is_instance_valid(_marker):
		_finish()
		return
	_time += delta
	_phase_time += delta
	var look_at: Vector3 = _marker.global_position
	var look: float = 0.0
	match _phase:
		Phase.REACH:
			var reach: float = smoothstep(0.0, CONTACT, _time)
			look = reach
			_aim(_from.lerp(_marker.global_position, reach), _start_basis.slerp(_grip_basis(), reach), reach)
			_ik.influence = smoothstep(0.0, IK_FADE, _time)
			_grip.influence = smoothstep(CONTACT * 0.6, CONTACT, _time)
			_weigh(reach)
			if _time >= CONTACT:
				_contacted = true
				_contact()
				_set_phase(Phase.HOLD)
		Phase.HOLD:
			if _marker.pick_up:
				var lift: float = smoothstep(CONTACT, HAND_SECONDS, _time)
				_aim(_carried_from.origin.lerp(_read_point(), lift), _grip_basis().slerp(_read_basis(), lift), 1.0)
				_grip.curl_degrees = lerpf(GRIP_DEGREES[_marker.grip], READ_CURL, lift)
				_update_carried(lift)
				# Straighten up while the paper rises to the eyes (and the look comes back up).
				_weigh(1.0 - lift)
				look_at = _contact_point()
				look = 1.0 - lift
				if _time >= HAND_SECONDS:
					_read()
			else:
				look = 1.0
				_press_lever(smoothstep(CONTACT, CONTACT + LEVER_SECONDS, _time))
				if not _used and _time >= CONTACT + (LEVER_SECONDS if is_instance_valid(_marker.lever) else 0.0):
					_use()
				_aim(_marker.global_position, _grip_basis(), 1.0)
				if _time >= RELEASE:
					_from = _marker.global_position
					_set_phase(Phase.RETURN)
		Phase.RETURN:
			var back: float = smoothstep(RELEASE, HAND_SECONDS, _time)
			look = 1.0 - back
			_press_lever(1.0 - smoothstep(RELEASE, RELEASE + LEVER_SECONDS, _time))
			if not _used:
				_use()
			_aim(_from.lerp(_natural_tip(), back), _grip_basis().slerp(_natural_basis(), back), 1.0 - back)
			_grip.influence = 1.0 - back
			_weigh(1.0 - back)
			_ik.influence = 1.0 - smoothstep(HAND_SECONDS - IK_FADE, HAND_SECONDS, _time)
			if _time >= HAND_SECONDS:
				_finish()
				return
		Phase.READ:
			_aim(_read_point(), _read_basis(), 1.0)
			_update_carried(1.0)
		Phase.PUT_DOWN:
			var down: float = smoothstep(0.0, PUT_DOWN_SECONDS, _phase_time)
			look_at = _carried_from.origin
			look = down
			_aim(_read_point().lerp(_carried_from.origin, down), _read_basis().slerp(_grip_basis(), down), 1.0)
			_grip.curl_degrees = lerpf(READ_CURL, GRIP_DEGREES[_marker.grip], down)
			_update_carried(1.0 - down)
			_weigh(down)
			if _phase_time >= PUT_DOWN_SECONDS:
				_restore_carried()
				_from = _carried_from.origin
				_set_phase(Phase.LET_GO)
		Phase.LET_GO:
			var away: float = smoothstep(0.0, LET_GO_SECONDS, _phase_time)
			look_at = _from
			look = 1.0 - away
			_aim(_from.lerp(_natural_tip(), away), _grip_basis().slerp(_natural_basis(), away), 1.0 - away)
			_grip.influence = 1.0 - away
			_weigh(1.0 - away)
			_ik.influence = 1.0 - smoothstep(LET_GO_SECONDS - IK_FADE, LET_GO_SECONDS, _phase_time)
			if _phase_time >= LET_GO_SECONDS:
				_finish()
				return
	_align.influence = _ik.influence
	_follow_head(LEAN_FOLLOW)
	_look(look_at, look)


## D-124: the eyes go to the working hand. The camera turns from the player's own aim toward
## `point`, LOOK_FOLLOW of the way (at most LOOK_LIMIT), scaled by `weight`; the mouse still
## turns the player and head underneath.
func _look(point: Vector3, weight: float) -> void:
	var camera := _camera()
	if camera == null or not is_instance_valid(_head) or camera.get_parent() != _head:
		return
	var local: Vector3 = _head.global_basis.orthonormalized().inverse() * (point - camera.global_position)
	var yaw: float = clampf(atan2(-local.x, -local.z), -LOOK_LIMIT, LOOK_LIMIT)
	var pitch: float = clampf(atan2(local.y, Vector2(local.x, local.z).length()), -LOOK_LIMIT, LOOK_LIMIT)
	camera.rotation = Vector3(pitch, yaw, 0.0) * LOOK_FOLLOW * clampf(weight, 0.0, 1.0)


## Turn the target's lever `amount` of its way down (0 = at rest).
func _press_lever(amount: float) -> void:
	if not is_instance_valid(_marker.lever) or is_zero_approx(_marker.lever_degrees):
		return
	var turn := Quaternion(_marker.lever_axis.normalized(), deg_to_rad(_marker.lever_degrees) * clampf(amount, 0.0, 1.0))
	_marker.lever.quaternion = _lever_rest * turn


## Use the thing (a door swings over the rest of the hold).
func _use() -> void:
	_used = true
	_target.interact_by_hand(player, maxf(0.0, HAND_SECONDS - _time))


## Hold `point` with the hand turned to `hand`: the palm's middle sits back from the point on the
## palm side by the hold gap (scaled by `hold`, 0 while the hand is still free), and the wrist
## goal back along the fingers from there.
func _aim(point: Vector3, hand: Basis, hold: float) -> void:
	_align.target_basis = hand
	var palm: Vector3 = (hand * _palm_axis).normalized()
	var middle: Vector3 = point - palm * _hold_gap() * hold
	_goal.global_position = middle - hand.y.normalized() * (PALM + _tip()) * _scale()


## How far past the palm's middle the hand takes the thing now (model metres): the fingertips on
## a high pinch or hook, as far as the reach has come.
func _tip() -> float:
	return _tip_extra * clampf(_rise_weight, 0.0, 1.0)


## From the palm's middle to what the hand holds, along the palm's facing.
func _hold_gap() -> float:
	var gap: float = PAPER_GAP if is_instance_valid(_marker) and _marker.pick_up else HOLD_GAP
	return (HAND_HALF + gap) * _scale()


## The point the hand holds, as drawn: palm's middle (or the fingertips, _tip) plus the hold gap
## out of the palm.
func _contact_point() -> Vector3:
	var hand: Basis = _hand_attach.global_basis.orthonormalized()
	var palm: Vector3 = (hand * _palm_axis).normalized()
	return _hand_tip() + hand.y * _tip() * _scale() + palm * _hold_gap()


## How the hand meets the target (world space): a lever palm down with the fingers over it, an
## edge with the palm turned in, a paper with the fingers down onto its near edge.
func _grip_basis() -> Basis:
	var flat: Vector3 = _marker.global_position - global_position
	flat.y = 0.0
	flat = flat.normalized() if flat.length() > 0.01 else -player.global_basis.z
	if _high:
		# Reaching up, the fingers carry on the arm's line and the palm faces the thing: every
		# centimetre of the hand counts (fingers over a lever would put the wrist above it).
		return _hand_basis((_marker.global_position - _lifted_shoulder()).normalized(), flat)
	match _marker.grip:
		HandTarget.Grip.HOOK:
			return _hand_basis(flat, Vector3.UP.cross(flat))
		HandTarget.Grip.PINCH:
			return _hand_basis(flat * 0.8 + Vector3.DOWN * 0.6, Vector3.DOWN)
	return _hand_basis(flat * 0.9 + Vector3.DOWN * 0.3, Vector3.DOWN)


## Holding a paper up by its right-hand edge to read: fingers up, the palm facing in across the
## sheet; the sheet runs between the thumb (in front) and the fingers (behind).
func _read_basis() -> Basis:
	var camera := _camera()
	if camera == null:
		return _grip_basis()
	var view: Basis = camera.global_basis.orthonormalized()
	var across: Vector3 = (view * _carried_centre).normalized() if _carried_centre.length() > 0.01 else -view.x
	return _hand_basis(view.y, across)


## A hand basis with its fingers (bone +Y) along `fingers` and the palm facing `palm`; the right
## hand unless another palm axis is given.
func _hand_basis(fingers: Vector3, palm: Vector3, palm_axis: Vector3 = Vector3.ZERO) -> Basis:
	var axis: Vector3 = _palm_axis if palm_axis.is_zero_approx() else palm_axis
	var y: Vector3 = fingers.normalized()
	var facing: Vector3 = (palm - y * palm.dot(y)).normalized()
	if absf(axis.x) > 0.5:
		var x: Vector3 = facing * signf(axis.x)
		return Basis(x, y, x.cross(y))
	var z: Vector3 = facing * signf(axis.z)
	return Basis(y.cross(z), y, z)


## D-124: the left hand holds the phone while it is raised or its light is on. The phone (its
## model and light) is moved to the hand: raised before the eyes to read, or low with the light
## ahead; the light still aims where the player looks.
func _tick_phone(delta: float) -> void:
	if not is_instance_valid(_phone):
		return
	var model := _phone.get_node_or_null("Model") as Node3D
	var light := _phone.get_node_or_null("Flashlight") as Node3D
	var camera := _camera()
	if model == null or light == null or camera == null:
		return
	var raised: bool = bool(_phone.get("raised"))
	var holding: bool = visible and not bool(_phone.get("away")) and (raised or light.visible)
	_phone_weight = move_toward(_phone_weight, 1.0 if holding else 0.0, delta / PHONE_FADE)
	_phone_raise = move_toward(_phone_raise, 1.0 if raised else 0.0, delta / PHONE_FADE)
	var low: Transform3D = camera.global_transform * Transform3D(Basis.from_euler(PHONE_LOW_TILT), PHONE_LOW_AT)
	var high: Transform3D = camera.global_transform * Transform3D(Basis.from_euler(PHONE_RAISED_TILT), PHONE_RAISED_AT)
	var pose: Transform3D = low.interpolate_with(high, _phone_raise)
	model.global_transform = pose
	model.visible = raised or _phone_weight > 0.01
	light.global_transform = Transform3D(camera.global_basis, pose.origin + (-camera.global_basis.z.normalized()) * PHONE_LIGHT_AHEAD)
	# Palm on the back of the phone, fingers round its far edge.
	var back: Vector3 = -pose.basis.z.normalized()
	var fingers: Vector3 = (pose.basis.x.normalized() * 0.8 + pose.basis.y.normalized() * 0.6)
	var hand: Basis = _hand_basis(fingers, -back, _left_palm_axis)
	var middle: Vector3 = pose.origin + back * (_phone_half + HAND_HALF * _scale())
	_left_goal.global_position = middle - hand.y.normalized() * PALM * _scale()
	_left_align.target_basis = hand
	_left_ik.influence = _phone_weight
	_left_align.influence = _phone_weight
	_left_grip.influence = _phone_weight


## The hand as the clip holds it this frame (before IK), world space.
func _natural_basis() -> Basis:
	var pose: Transform3D = skeleton.global_transform * skeleton.get_bone_global_pose(skeleton.find_bone("RightHand"))
	return pose.basis.orthonormalized()


## The player's own eyes (a capture or cutscene camera may be the current one).
func _camera() -> Camera3D:
	var camera: Camera3D = null
	if is_instance_valid(player):
		camera = player.get_node_or_null("Head/Camera3D") as Camera3D
	return camera if camera != null else get_viewport().get_camera_3d()


func _set_phase(phase: Phase) -> void:
	_phase = phase
	_phase_time = 0.0


## At the eyes: use the paper (open the document). The body settles to its idle under the
## held paper; if nothing opens, the paper goes straight back.
func _read() -> void:
	_reading = true
	_set_phase(Phase.READ)
	_play(&"idle")
	var opened: Array[bool] = [false]
	var probe := func(_id: StringName) -> void: opened[0] = true
	EventBus.document_opened.connect(probe)
	_target.interact(player)
	EventBus.document_opened.disconnect(probe)
	if not opened[0]:
		_put_back()


## The camera rides with the head as the body leans in (the player itself stays put).
func _follow_head(weight: float) -> void:
	_lean = player.global_basis.inverse() * (_eye_world() - _eye_start) * weight


## Lean the chest toward the goal until the shoulder is within reach of it.
func _plan_bend(goal: Vector3) -> void:
	var flat: Vector3 = goal - _bone_world(_bend.bones[0])
	flat.y = 0.0
	var forward: Vector3 = flat.normalized() if flat.length() > 0.01 else -global_basis.z
	_bend.axis = (skeleton.global_basis.inverse() * Vector3.UP.cross(forward).normalized()).normalized()
	_bend_degrees = minf(_bend_for(goal), MAX_BEND)


## The lean (degrees, in 5 degree steps) that brings the shoulder within reach of `goal`, or INF
## if even MAX_BEND does not. The bend is shared by the spine bones as SpineBendModifier does,
## each turning about its own joint (the pose before any lean).
func _bend_for(goal: Vector3) -> float:
	return _posed_bend(goal, _stance(), 0.0, MAX_BEND)


## D-152: the measured pose the player's stance reaches from.
func _stance() -> StringName:
	return &"crouch_idle" if is_instance_valid(player) and bool(player.get("crouched")) else &"idle"


## The joints `points` (the bend bones, then the shoulder last) turned together toward `goal` in 5
## degree steps up to `limit`: the first lean whose shoulder is within `reach` of it, else INF.
func _bend_chain(points: Array[Vector3], goal: Vector3, reach: float, limit: float) -> float:
	var joints: int = points.size() - 1
	var flat: Vector3 = goal - points[0]
	flat.y = 0.0
	var forward: Vector3 = flat.normalized() if flat.length() > 0.01 else -global_basis.z
	var axis: Vector3 = Vector3.UP.cross(forward).normalized()
	for step: int in range(0, int(limit) + 1, 5):
		var turn: Basis = Basis(axis, deg_to_rad(step) / joints)
		var moved: Array[Vector3] = points.duplicate()
		for joint: int in joints:
			for index: int in range(joint + 1, moved.size()):
				moved[index] = moved[joint] + turn * (moved[index] - moved[joint])
		if moved[-1].distance_to(goal) <= reach:
			return float(step)
	return INF


## D-152: the lean (degrees) the measured `pose` (&"idle" or &"crouch_idle") needs, square to the
## view, for the hand reaching `extra` past the palm to touch `goal`; INF past `limit`.
func _posed_bend(goal: Vector3, pose: StringName, extra: float, limit: float) -> float:
	var points: Array[Vector3] = []
	for point: Vector3 in _reach_joints.get(pose, []):
		points.append(model.global_transform * point)
	if points.size() < 2:
		return INF
	return _bend_chain(points, goal, (arm_reach + extra) * _scale(), limit)


## D-152: how `marker` is reached: &"near" as before (straight back, or up on the toes), &"up" on
## the toes leaning over something low, &"lean"
## over what is in the way, &"kneel" crouched and leaning, or &"" out of reach.
func _reach_kind(marker: HandTarget) -> StringName:
	var drawn: float = _yaw
	if not acting:
		_place_model(0.0)
	var kind: StringName = _judge_reach(marker)
	if not acting:
		_place_model(drawn)
	return kind


func _judge_reach(marker: HandTarget) -> StringName:
	var goal: Vector3 = marker.global_position
	if _bend_for(goal) <= MAX_BEND or _rise_for(goal, marker.grip) <= TIPTOE:
		return &"near"
	if _up_lean(goal, marker.grip) <= HIGH_LEAN:
		return &"up"
	var extra: float = finger_reach if marker.grip != HandTarget.Grip.GRIP else 0.0
	if _posed_bend(goal, &"idle", extra, LEAN_BEND) <= LEAN_BEND:
		return &"lean"
	if _posed_bend(goal, &"crouch_idle", extra, KNEEL_BEND) <= KNEEL_BEND:
		return &"kneel"
	return &""


## D-152: the bend bones and the right shoulder joint of the standing and crouched poses, model space.
func _measure_reach_joints() -> void:
	var to_model: Transform3D = model.global_transform.affine_inverse() * skeleton.global_transform
	var bones: Array[String] = []
	for bone: String in _bend.bones:
		bones.append(bone)
	bones.append("RightUpperArm")
	for pose: StringName in [&"idle", &"crouch_idle"]:
		animator.play(CLIPS[pose])
		animator.seek(0.0, true)
		var points: Array[Vector3] = []
		for bone: String in bones:
			points.append((to_model * skeleton.get_bone_global_pose(skeleton.find_bone(bone))).origin)
		_reach_joints[pose] = points
		_reach_collars[pose] = (to_model * skeleton.get_bone_global_pose(skeleton.find_bone("RightShoulder"))).origin
	animator.stop()


## How far up on the toes (metres) brings the lifted shoulder, straight up, within reach of
## `goal` for this grip (a pinch or hook to the fingertips): 0 if it already is, INF if no rise
## does (the goal is too far off to the side).
func _rise_for(goal: Vector3, grip: HandTarget.Grip = HandTarget.Grip.GRIP) -> float:
	return _rise_from(_lifted_shoulder(), goal, grip)


## _rise_for from a given (lifted) shoulder joint.
func _rise_from(shoulder: Vector3, goal: Vector3, grip: HandTarget.Grip) -> float:
	var reach: float = (arm_reach + (finger_reach if grip != HandTarget.Grip.GRIP else 0.0)) * _scale()
	var side: float = Vector2(goal.x - shoulder.x, goal.z - shoulder.z).length()
	if side > reach:
		return INF
	var up: float = sqrt(reach * reach - side * side)
	# D-152: below the reach of the arm from here no rise helps (a lean or a crouch may).
	if goal.y < shoulder.y - up:
		return INF
	return maxf(0.0, goal.y - shoulder.y - up)


## D-152: the lifted shoulder with the chest leaned `degrees` toward `goal` (as SpineBendModifier
## shares a lean over the bend bones).
func _leaned_shoulder(goal: Vector3, degrees: float) -> Vector3:
	var points: Array[Vector3] = []
	var posed: Array = _reach_joints.get(_stance(), [])
	for index: int in range(posed.size() - 1):
		points.append(model.global_transform * (posed[index] as Vector3))
	points.append(_lifted_shoulder())
	var joints: int = points.size() - 1
	var flat: Vector3 = goal - points[0]
	flat.y = 0.0
	var forward: Vector3 = flat.normalized() if flat.length() > 0.01 else -global_basis.z
	var turn: Basis = Basis(Vector3.UP.cross(forward).normalized(), deg_to_rad(degrees) / joints)
	for joint: int in joints:
		for index: int in range(joint + 1, points.size()):
			points[index] = points[joint] + turn * (points[index] - points[joint])
	return points[-1]


## D-152: the least lean (5 degree steps, up to HIGH_LEAN) that brings `goal` within a rise on the
## toes (TIPTOE), else INF.
func _up_lean(goal: Vector3, grip: HandTarget.Grip) -> float:
	for step: int in range(0, int(HIGH_LEAN) + 1, 5):
		if _rise_from(_leaned_shoulder(goal, step), goal, grip) <= TIPTOE:
			return float(step)
	return INF


## The right shoulder joint (world) with the collarbone lifted SHOULDER_RAISE, as for a reach up.
func _lifted_shoulder() -> Vector3:
	var pose: StringName = _stance()
	var joints: Array = _reach_joints.get(pose, [])
	if joints.is_empty():
		return _bone_world("RightUpperArm")
	var collar: Vector3 = model.global_transform * (_reach_collars[pose] as Vector3)
	var joint: Vector3 = model.global_transform * (joints[-1] as Vector3)
	return collar + ShoulderRaiseModifier.lift(joint - collar, Vector3.UP, SHOULDER_RAISE) * (joint - collar)


## Share `weight` (0..1) of this reach's lean and rise. The rise lifts the model and tips the feet
## so the toes stay on the floor; the eyes, and so the camera, come up with it. A high reach also
## lifts the shoulder and reaches to the fingertips.
func _weigh(weight: float) -> void:
	_rise_weight = weight
	_bend.degrees = _bend_degrees * weight
	_rise = _rise_target * weight
	model.position.y = _rise
	_tiptoe.rise = (skeleton.global_basis.inverse() * Vector3(0.0, _rise, 0.0)).length()
	_raise.degrees = SHOULDER_RAISE * weight if _high else 0.0


## The right shoulder's height in the model's own space (where the elbow pole lives).
func _shoulder_model_height() -> float:
	var rest: Transform3D = skeleton.get_bone_global_rest(skeleton.find_bone("RightUpperArm"))
	return (model.global_transform.affine_inverse() * skeleton.global_transform * rest).origin.y


func _contact() -> void:
	if _marker.pick_up:
		_carried_from = _marker.global_transform
		_carry(_target)
	elif not is_instance_valid(_marker.lever):
		_use()


## Where the held point goes to read: the sheet's centre at READ_POINT.
func _read_point() -> Vector3:
	var camera := _camera()
	if camera == null:
		return global_position + Vector3.UP * eye_height
	return camera.global_transform * READ_POINT - camera.global_basis.orthonormalized() * _carried_centre


## The paper leaves its place and rides in the hand, turning to face the eyes.
func _carry(target: Node3D) -> void:
	_hidden_meshes.clear()
	_carried = Node3D.new()
	_carried.name = "Carried"
	_carried.top_level = true
	add_child(_carried)
	for mesh: MeshInstance3D in target.find_children("*", "MeshInstance3D", true, false):
		if not mesh.visible:
			continue
		var copy := mesh.duplicate(0) as MeshInstance3D
		_carried.add_child(copy)
		copy.transform = _marker.global_transform.affine_inverse() * mesh.global_transform
		mesh.visible = false
		_hidden_meshes.append(mesh)
	_carried.global_transform = _marker.global_transform
	_carried_centre = Vector3.ZERO
	for copy: Node in _carried.get_children():
		_carried_centre += (copy as Node3D).position / _carried.get_child_count()


## The paper is held at the point its HandTarget marks (the hand's contact point), and turns its
## face (+Z) to the eyes, upright, as it is lifted, the thumb side in front of it.
func _update_carried(lift: float) -> void:
	if not is_instance_valid(_carried):
		return
	var facing: Basis = _carried_from.basis
	var point: Vector3 = _contact_point()
	var camera := _camera()
	if camera != null:
		facing = camera.global_basis.orthonormalized()
		point += (camera.global_position - point).normalized() * THUMB_DEPTH * _scale() * lift
	_carried.global_transform = Transform3D(_carried_from.basis.slerp(facing, lift).orthonormalized(), point)


## D-151: a hand action stops where it is (a carried paper goes back to its place) and the body
## hides, so the death camera (PlayerDeath) moves alone; the head keeps no lean or neck offset of ours.
func _on_death_started(_kind: StringName) -> void:
	if _dead or not is_instance_valid(player):
		return
	if acting:
		_finish()
	_dead = true
	visible = false
	if is_instance_valid(_head) and _head.position == _head_written:
		_head.position -= _head_offset
	_head_offset = Vector3.ZERO
	_head_written = Vector3.INF


func is_dead() -> bool:
	return _dead


func _on_document_closed(_id: StringName) -> void:
	if acting and _reading:
		_put_back()


func _put_back() -> void:
	_reading = false
	_set_phase(Phase.PUT_DOWN)


func _restore_carried() -> void:
	for mesh: MeshInstance3D in _hidden_meshes:
		if is_instance_valid(mesh):
			mesh.visible = true
	_hidden_meshes.clear()
	if is_instance_valid(_carried):
		_carried.queue_free()
	_carried = null


func _finish() -> void:
	var target: Interactable = _target if is_instance_valid(_target) else null
	_restore_carried()
	acting = false
	_reading = false
	_ik.influence = 0.0
	_align.influence = 0.0
	_grip.influence = 0.0
	_bend_degrees = 0.0
	_rise_target = 0.0
	_high = false
	_tip_extra = 0.0
	_weigh(0.0)
	_pole.position = _pole_rest
	_lean = Vector3.ZERO
	var camera := _camera()
	if camera != null and camera.get_parent() == _head:
		camera.rotation = Vector3.ZERO
	if is_instance_valid(_marker) and is_instance_valid(_marker.lever):
		_marker.lever.quaternion = _lever_rest
	_target = null
	_marker = null
	if is_instance_valid(player) and player.has_method("release_movement_lock"):
		player.release_movement_lock(self)
	_clip = &""
	_play(&"idle")
	hand_action_finished.emit(target)


## Wrist plus the palm along the hand bone, in world space, as drawn (after IK).
func _hand_tip() -> Vector3:
	var pose: Transform3D = _hand_attach.global_transform
	return pose.origin + pose.basis.y.normalized() * PALM * _scale()


## Where the clip itself holds the palm this frame (the pose before IK and the lean).
func _natural_tip() -> Vector3:
	var pose: Transform3D = skeleton.global_transform * skeleton.get_bone_global_pose(skeleton.find_bone("RightHand"))
	return pose.origin + pose.basis.y.normalized() * PALM * _scale()


## The eyes as drawn this frame (the head attachment follows modifiers too).
func _eye_world() -> Vector3:
	return _head_attach.global_position + model.global_basis * EYES_FROM_HEAD_BONE


func _bone_world(bone: String) -> Vector3:
	return (skeleton.global_transform * skeleton.get_bone_global_pose(skeleton.find_bone(bone))).origin


func _play(key: StringName) -> void:
	_key = key
	var clip: StringName = CLIPS[key]
	if clip == _clip and animator.is_playing():
		return
	_clip = clip
	animator.play(clip, BLEND_SECONDS)


## Turn the model by yaw and stand it so its eyes are over the player's origin (the camera).
func _place_model(yaw: float) -> void:
	model.rotation = Vector3(0.0, PI + yaw, 0.0)
	var eye: Vector3 = Basis(Vector3.UP, PI + yaw) * (_eye * _scale())
	model.position = Vector3(-eye.x, 0.0, -eye.z)


func _scale() -> float:
	return model.scale.x


## The Quaternius clips, as libraries FILL_LIBRARY (UAL1, every clip) and FILL2_LIBRARY (UAL2,
## FILL2_CLIPS only; the model's own clips stay in the default one). Quaternius stands with its
## hips further back than Tran Trung's own clips do (UAL1 about 8 cm): each copy is shifted so its
## idle hips meet his, or the body jumps back when such a clip starts.
func _add_fill_clips() -> void:
	var own: Vector3 = Vector3.INF
	for fill: Array in [[FILL_LIBRARY, FILL_SCENE, &"Idle", []], [FILL2_LIBRARY, FILL2_SCENE, FILL2_IDLE, FILL2_CLIPS]]:
		var library_name: StringName = fill[0]
		if animator.has_animation_library(library_name):
			continue
		var source := (fill[1] as PackedScene).instantiate()
		var original := (source.find_children("*", "AnimationPlayer", true, false)[0] as AnimationPlayer).get_animation_library(&"")
		var library := AnimationLibrary.new()
		var keep: Array = fill[3]
		for clip: StringName in original.get_animation_list():
			if keep.is_empty() or clip in keep:
				library.add_animation(clip, original.get_animation(clip).duplicate() as Animation)
		source.free()
		animator.add_animation_library(library_name, library)
		if not own.is_finite():
			own = _hips_at(CLIPS[&"idle"])
		var hips: Vector3 = _hips_at(StringName(String(library_name) + "/" + String(fill[2])))
		var shift := Vector3(own.x - hips.x, 0.0, own.z - hips.z) / skeleton.motion_scale
		for clip: StringName in library.get_animation_list():
			var animation := library.get_animation(clip)
			var track: int = animation.find_track(^"%GeneralSkeleton:Hips", Animation.TYPE_POSITION_3D)
			for key: int in (animation.track_get_key_count(track) if track >= 0 else 0):
				animation.track_set_key_value(track, key, (animation.track_get_key_value(track, key) as Vector3) + shift)


## The hips (skeleton space) at the start of a clip.
func _hips_at(clip: StringName) -> Vector3:
	animator.play(clip)
	animator.seek(0.0, true)
	var hips: Vector3 = skeleton.get_bone_pose_position(skeleton.find_bone("Hips"))
	animator.stop()
	return hips


## The right arm's two bones, nearly straight, plus the palm.
func _measure_arm() -> void:
	var upper: Vector3 = skeleton.get_bone_global_rest(skeleton.find_bone("RightUpperArm")).origin
	var lower: Vector3 = skeleton.get_bone_global_rest(skeleton.find_bone("RightLowerArm")).origin
	var hand: Vector3 = skeleton.get_bone_global_rest(skeleton.find_bone("RightHand")).origin
	arm_reach = (upper.distance_to(lower) + lower.distance_to(hand)) * ARM_STRAIGHT + PALM
	var finger: int = skeleton.find_bone("RightMiddleDistal")
	if finger >= 0:
		finger_reach = maxf(0.0, hand.distance_to(skeleton.get_bone_global_rest(finger).origin) + FINGERTIP - PALM)


## Scale the model so its eyes, in the rest pose, are at eye_height.
func _fit_height() -> void:
	var head: int = skeleton.find_bone("Head")
	var head_y: float = skeleton.get_bone_global_rest(head).origin.y
	model.scale = Vector3.ONE * (eye_height / (head_y + EYES_FROM_HEAD_BONE.y))


## Two meshes on one skeleton: the view mesh (layer 1, no shadow, head folded away) and the
## mirror mesh (mirror layer only, casts the shadow).
func _split_meshes() -> void:
	var head: int = skeleton.find_bone("Head")
	for mesh: MeshInstance3D in skeleton.find_children("*", "MeshInstance3D", true, false):
		# T-227: cloth and skin wrap the light a little past the side facing it. With the room's
		# ceiling light behind him, plain Lambert left the chest below the eyes black (the room
		# has no bounced light).
		for surface: int in mesh.get_surface_override_material_count():
			var material := mesh.get_active_material(surface)
			if material is BaseMaterial3D:
				var wrapped := material.duplicate() as BaseMaterial3D
				wrapped.diffuse_mode = BaseMaterial3D.DIFFUSE_LAMBERT_WRAP
				mesh.set_surface_override_material(surface, wrapped)
		var mirror := mesh.duplicate(0) as MeshInstance3D
		mirror.name = mesh.name + "Mirror"
		mesh.get_parent().add_child(mirror)
		mirror.layers = 1 << (MIRROR_LAYER - 1)
		mirror.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
		mirror_meshes.append(mirror)
		mesh.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		if mesh.skin != null:
			var skin := mesh.skin.duplicate() as Skin
			for bind: int in skin.get_bind_count():
				var bone: int = skin.get_bind_bone(bind)
				if bone < 0:
					bone = skeleton.find_bone(skin.get_bind_name(bind))
				if bone == head:
					skin.set_bind_pose(bind, Transform3D(Basis.from_scale(Vector3.ONE * 0.0001), Vector3.ZERO))
			mesh.skin = skin
		view_meshes.append(mesh)


## Modifiers run in child order: lean the chest, then the arm IK, then close the fingers.
func _build_modifiers() -> void:
	_goal = Node3D.new()
	_goal.name = "HandGoal"
	_goal.top_level = true
	add_child(_goal)
	_pole = Node3D.new()
	_pole.name = "ElbowPole"
	model.add_child(_pole)
	# Model space faces +Z: the right elbow points down, out to the right (-X) and back.
	_pole.position = Vector3(-0.6, 0.8, -0.4)
	_pole_rest = _pole.position
	# World up in the skeleton's own space (the walker only turns about it).
	_tiptoe = TiptoeModifier.new()
	_tiptoe.name = "Tiptoe"
	_tiptoe.up = (skeleton.global_basis.inverse() * Vector3.UP).normalized()
	skeleton.add_child(_tiptoe)
	_bend = SpineBendModifier.new()
	_bend.name = "SpineBend"
	skeleton.add_child(_bend)
	# Standing with the view turned past the feet, the chest turns part of the way (about up).
	_twist = SpineBendModifier.new()
	_twist.name = "SpineTwist"
	_twist.axis = _tiptoe.up
	skeleton.add_child(_twist)
	# After the lean, before the arm's IK (which starts from the lifted shoulder joint).
	_raise = ShoulderRaiseModifier.new()
	_raise.name = "ShoulderRaise"
	_raise.up = _tiptoe.up
	skeleton.add_child(_raise)
	_ik = TwoBoneIK3D.new()
	_ik.name = "RightArmIK"
	skeleton.add_child(_ik)
	_ik.setting_count = 1
	_ik.set_root_bone_name(0, "RightUpperArm")
	_ik.set_middle_bone_name(0, "RightLowerArm")
	_ik.set_end_bone_name(0, "RightHand")
	_ik.set_target_node(0, _ik.get_path_to(_goal))
	_ik.set_pole_node(0, _ik.get_path_to(_pole))
	_ik.influence = 0.0
	_align = HandAlignModifier.new()
	_align.name = "RightHandAlign"
	skeleton.add_child(_align)
	_align.influence = 0.0
	_palm_axis = _find_palm_axis("RightHand", GRIP_BONES[3])
	_grip = HandGripModifier.new()
	_grip.name = "RightGrip"
	_grip.bones = GRIP_BONES
	skeleton.add_child(_grip)
	_grip.influence = 0.0
	_head_attach = BoneAttachment3D.new()
	_head_attach.name = "HeadAttach"
	_head_attach.bone_name = "Head"
	skeleton.add_child(_head_attach)
	_hand_attach = BoneAttachment3D.new()
	_hand_attach.name = "HandAttach"
	_hand_attach.bone_name = "RightHand"
	skeleton.add_child(_hand_attach)
	# The left arm holds the phone (D-124): the same chain on the other side.
	_left_goal = Node3D.new()
	_left_goal.name = "LeftHandGoal"
	_left_goal.top_level = true
	add_child(_left_goal)
	_left_pole = Node3D.new()
	_left_pole.name = "LeftElbowPole"
	model.add_child(_left_pole)
	_left_pole.position = Vector3(0.6, 0.8, -0.4)
	_left_ik = TwoBoneIK3D.new()
	_left_ik.name = "LeftArmIK"
	skeleton.add_child(_left_ik)
	_left_ik.setting_count = 1
	_left_ik.set_root_bone_name(0, "LeftUpperArm")
	_left_ik.set_middle_bone_name(0, "LeftLowerArm")
	_left_ik.set_end_bone_name(0, "LeftHand")
	_left_ik.set_target_node(0, _left_ik.get_path_to(_left_goal))
	_left_ik.set_pole_node(0, _left_ik.get_path_to(_left_pole))
	_left_ik.influence = 0.0
	_left_align = HandAlignModifier.new()
	_left_align.name = "LeftHandAlign"
	_left_align.bone = &"LeftHand"
	skeleton.add_child(_left_align)
	_left_align.influence = 0.0
	_left_palm_axis = _find_palm_axis("LeftHand", LEFT_GRIP_BONES[3])
	_left_grip = HandGripModifier.new()
	_left_grip.name = "LeftGrip"
	_left_grip.bones = LEFT_GRIP_BONES
	_left_grip.curl_degrees = PHONE_CURL
	skeleton.add_child(_left_grip)
	_left_grip.influence = 0.0
	_left_attach = BoneAttachment3D.new()
	_left_attach.name = "LeftHandAttach"
	_left_attach.bone_name = "LeftHand"
	skeleton.add_child(_left_attach)


## The hand's local axis out of the palm: where a finger's tip goes when HandGripModifier
## curls it (about the finger's +X, so toward the finger's +Z), seen from the hand, snapped
## to the nearest of +-X and +-Z.
func _find_palm_axis(bone: String, finger_bone: String) -> Vector3:
	var hand: Basis = skeleton.get_bone_global_rest(skeleton.find_bone(bone)).basis.orthonormalized()
	var finger: Basis = skeleton.get_bone_global_rest(skeleton.find_bone(finger_bone)).basis.orthonormalized()
	var palm: Vector3 = hand.inverse() * (finger * Vector3.BACK)
	if absf(palm.x) > absf(palm.z):
		return Vector3(signf(palm.x), 0.0, 0.0)
	return Vector3(0.0, 0.0, signf(palm.z))


## For a locomotion clip: the mean eye point, and for moving clips the stride speed (how fast
## a planted foot slides back), over every run of grounded samples in two cycles.
func _measure(key: StringName) -> void:
	var clip: StringName = CLIPS[key]
	var animation: Animation = animator.get_animation(clip)
	var foot: int = skeleton.find_bone("LeftFoot")
	var toe: int = skeleton.find_bone("LeftToes")
	var head: int = skeleton.find_bone("Head")
	var to_model: Transform3D = model.global_transform.affine_inverse() * skeleton.global_transform
	var step: float = animation.length / SAMPLES
	var points: Array[Vector3] = []
	var toes: Array[float] = []
	var eye_sum: Vector3 = Vector3.ZERO
	for index: int in SAMPLES * 2 + 1:
		animator.play(clip)
		animator.seek(fmod(step * index, animation.length), true)
		points.append(skeleton.get_bone_global_pose(foot).origin)
		toes.append(skeleton.get_bone_global_pose(toe).origin.y)
		if index < SAMPLES:
			eye_sum += (to_model * skeleton.get_bone_global_pose(head)).origin + EYES_FROM_HEAD_BONE
	animator.stop()
	eye_points[key] = eye_sum / SAMPLES
	if key in [&"idle", &"crouch_idle"]:
		return
	var low: float = INF
	var low_toe: float = INF
	for index: int in points.size():
		low = minf(low, points[index].y)
		low_toe = minf(low_toe, toes[index])
	# Every grounded run counts: Tripo's walk takes two unequal steps per cycle (T-227).
	var distance: float = 0.0
	var time: float = 0.0
	var run_start: int = -1
	for index: int in points.size() + 1:
		var grounded: bool = index < points.size() and points[index].y < low + STANCE_HEIGHT \
			and toes[index] < low_toe + STANCE_HEIGHT
		if grounded and run_start < 0:
			run_start = index
		elif not grounded and run_start >= 0:
			var samples: int = index - run_start
			if samples >= 3:
				var first: Vector3 = points[run_start]
				var last: Vector3 = points[index - 1]
				distance += Vector2(last.x - first.x, last.z - first.z).length()
				time += step * (samples - 1)
			run_start = -1
	stride_speeds[key] = (distance / time if time > 0.0 else 1.0) * _scale()
