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
## - T-239 (owner's playtest, 09/11): the fingers of a hand that holds something take a whole hand
##   shape (FingerPoseModifier, HandShapes: thumb included), made against the thing so nothing goes
##   through it; a held phone or paper rides on the hand as drawn (placed once the skeleton has its
##   final pose), so neither lags behind the hand nor slips into it. A paper is pinched by its right
##   edge before it leaves its place (thumb on its face, the index under the edge), and held up to
##   read the same way round (thumb in front, fingers behind).
## - T-241 (owner's playtest, 10/11; replaces D-152's lean and kneel): the body stands still for
##   every hand action (no reach clip steps or lifts a heel, the free arm hangs) and folds at the
##   hips (BodyLeanModifier). What stands at desk height or higher is taken standing, the trunk
##   leaning at most MAX_BEND; what is lower, bending down with the knees giving a little (a
##   stoop), never a crouch of the body's own. The prompt and the action judge the reach the same
##   way and the action never does more than the prompt judged. The camera stays on the eyes as
##   planned (no frame behind), so the player never sees the back of his own head.
## - T-243 (D-161, D-162): chapter 2. The right hand carries the rag, towel or shirt between actions
##   (held in the fist in front of the hip, other things are still done with that fist); round 4's
##   swollen door gets a shoulder shove instead of a reach; the shower screen is wiped with the palm
##   rubbing round for as long as E is held.
## - T-249 (D-165): chapter 3. The right hand holds the iron bar (IronBarWeapon keeps the rules): at
##   the ready before the hip, swung down across from the right shoulder without stopping the feet,
##   its pieces falling from the hand when it breaks; a bar on the ground is bent down to, hooked by
##   the fingertips and rolled into the fist. Running with the view turned back, the legs keep
##   running the way he goes and the chest and head turn back (no run played backwards). Out of
##   breath the chest heaves and the shoulders rise.

signal hand_action_finished(target: Interactable)

enum Phase { REACH, HOLD, RETURN, READ, PUT_DOWN, LET_GO }

const HAND_SECONDS: float = 1.0
const CONTACT: float = 0.45
const RELEASE: float = 0.8
## After reading: carry the paper back to its place, then the empty hand back to the side.
const PUT_DOWN_SECONDS: float = 0.5
const LET_GO_SECONDS: float = 0.35
## T-239: a paper. The pinch comes down over its right edge and the fingertips reach it at PAPER_TOUCH;
## the edge rises onto the index (pick_style &"lift") and the thumb closes on the face; from PAPER_PINCH
## the sheet rides on the hand and turns to the eyes as the grip becomes the reading one.
const PAPER_TOUCH: float = 0.36
const PAPER_PINCH: float = 0.52
## How a paper comes off what it lies on (card section 4, the owner chooses): &"lift" (the index slides
## under the edge as it rises, then the thumb closes) or &"straight" (the thumb and the index close on
## the edge where it lies).
static var pick_style: StringName = &"lift"
## The pinch comes down onto the sheet from this high over it (metres, along its face), and with
## &"lift" the index arrives this far outside the edge, sliding under it as it rises.
const PICK_ABOVE: float = 0.03
const PICK_SLIDE: float = 0.012
## IK fades in and out over this, while the goal sits on the clip's own hand.
const IK_FADE: float = 0.08
const MIRROR_LAYER: int = 20
## T-245 (D-163): only the player's own camera draws this layer: the view mesh and the phone held
## before the eyes. Every other camera (mirrors, CCTV, a third-person view) draws the mirror mesh.
const VIEW_LAYER: int = 18
## T-245 (D-163): before the eyes the phone has to sit 0.3 m ahead of the camera to be seen at all,
## which a body's arm only reaches stretched out straight with the wrist bent back (the owner in the
## bathroom mirror: "the arm looks broken"). So a mirror shows the left arm in a pose of its own
## while it holds the phone: the elbow down by the ribs, the phone before the chest. Its bones are
## copies of the left arm's (MirrorArmModifier), named with this in front.
const MIRROR_BONE := "Mirror"
const MIRROR_ARM_ROOT := "LeftUpperArm"
## The phone a mirror shows, from the left shoulder (x right, y up, z back; the frame turns with the
## view and takes MIRROR_PITCH_SHARE of its pitch): lit low before the chest, or raised to read.
const MIRROR_PHONE_LOW_AT: Vector3 = Vector3(0.11, -0.09, -0.34)
const MIRROR_PHONE_LOW_TILT: Vector3 = Vector3(-1.05, 0.25, 0.0)
const MIRROR_PHONE_RAISED_AT: Vector3 = Vector3(0.16, 0.03, -0.29)
const MIRROR_PHONE_RAISED_TILT: Vector3 = Vector3(-0.5, 0.2, 0.08)
const MIRROR_PITCH_SHARE: float = 0.3
## Where that arm's elbow points (the same frame): down, a little out and back.
const MIRROR_ELBOW: Vector3 = Vector3(-0.6, -0.75, 0.3)
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
## Half the palm's thickness (model metres before scaling). What a hand holds sits on the palm
## side, never inside the palm: a lever HOLD_GAP out. (A paper and the phone have their own hold,
## HandShapes, T-239.)
const HAND_HALF: float = 0.02
const HOLD_GAP: float = 0.012
## Share of the arm's full length a hand reaches without straining (T-227: measured on the
## skeleton, Tran Trung's arms are shorter than the stand-in's).
const ARM_STRAIGHT: float = 0.95
## T-241 (owner, 10/11): standing, the hips and the back together lean in at most this far (the
## line from the hips to the chest then leans about 35 degrees: "a light fold at the hips"), the
## arm does the rest; a pinch or hook goes out to the fingertips. What that misses is out of reach
## from there: the player steps closer (D-124), nothing leans further or crouches for it.
const MAX_BEND: float = 40.0
## The lean is searched in steps of this many degrees.
const LEAN_STEP: int = 5
## Standing: the hips' share of the lean (the back bends the rest), how far the reaching shoulder
## leads at MAX_BEND (degrees about the back's own line), how far the seat goes back to keep the
## weight over the feet (metres at MAX_BEND), and the share of the lean the neck gives back.
const STAND_HIP_SHARE: float = 0.8
const STAND_TWIST: float = 25.0
const STAND_BACK: float = 0.02
const STAND_NECK: float = 0.6
## T-241: a hand target lower than this over the feet is taken bending down (a stoop): below it a
## standing lean of MAX_BEND no longer brings the hand down to it.
const STOOP_BELOW: float = 0.6
## Bending down: how far the trunk folds at the most (hips and back together), the hips' share,
## the reaching shoulder's dip (degrees about the back's line), how far the seat goes back and
## down (metres; the drop is what bends the knees: about 35 degrees more than standing at the
## deepest, "the knees give a little", not a crouch), and what the neck gives back (share, at most
## STOOP_NECK_MAX). The free arm swings back with the trunk STOOP_ARM of the lean past STOOP_ARM_FROM.
const STOOP_BEND: float = 130.0
const STOOP_HIP_SHARE: float = 0.75
const STOOP_TWIST: float = 30.0
const STOOP_BACK: float = 0.16
const STOOP_DROP: float = 0.12
const STOOP_NECK: float = 0.5
const STOOP_NECK_MAX: float = 55.0
const STOOP_ARM: float = 0.45
const STOOP_ARM_FROM: float = 45.0
## While the player itself crouches, a reach leans in the back as far as this (D-152's kneel, now
## only ever the player's own crouch).
const KNEEL_BEND: float = 85.0
## How long bending down to something low and coming back up takes (D-157: the owner chose 1.4 s
## over D-121's one second, T-241 section 4). The other actions take HAND_SECONDS.
const STOOP_SECONDS: float = 1.4
static var stoop_seconds: float = STOOP_SECONDS
## Bent down, the hand lets go this early (not at RELEASE), so that coming back up from the floor
## has as long as going down had: held until RELEASE the body stood up in a fifth of a second.
const STOOP_RELEASE: float = 0.62
## The camera stays this far short of what the head would lean into (metres).
const CAMERA_CLEAR: float = 0.12
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
var _bend: BodyLeanModifier
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
## T-241: the same two poses' joints the lean is planned on (model space): "pivot" (between the hip
## joints), "spine" (the bend bones), "neck", "head", "eye", "shoulder" and "left_shoulder".
var _lean_joints: Dictionary = {}
## How this reach is done: &"near" (standing, folding at the hips at most MAX_BEND, or straight up
## on the toes), &"up" (toes and a lean over something low), &"stoop" (bending down to something
## low) or &"kneel" (the player is crouched and leans from there).
var _reach: StringName = &"near"
## T-241: which way this action leans (flat, the body's own space), how far it leans now
## (degrees), and how fast its clock runs (1 for HAND_SECONDS; slower for a longer stoop).
var _lean_forward: Vector3 = Vector3.FORWARD
var _lean_now: float = 0.0
var _pace: float = 1.0
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
## T-239: where this action's elbow points by default (model space; _place_pole turns it toward the
## hand's little finger), and the shoulder joints as drawn last frame (after the lean), world space.
var _pole_base: Vector3
var _drawn_shoulder: Vector3 = Vector3.INF
var _drawn_left_shoulder: Vector3 = Vector3.INF
## The hand bone's local axis that faces out of the palm (the side the fingers curl to).
var _palm_axis: Vector3 = Vector3.FORWARD
var _start_basis: Basis
var _head_attach: BoneAttachment3D
var _hand_attach: BoneAttachment3D
var _goal: Node3D
var _pole: Node3D
var _head: Node3D
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
var _left_goal: Node3D
var _left_pole: Node3D
var _left_attach: BoneAttachment3D
var _mirror_ik: TwoBoneIK3D
var _mirror_align: HandAlignModifier
var _mirror_goal: Node3D
var _mirror_pole: Node3D
## T-245: the phone a mirror shows, in the mirror arm's hand.
var _mirror_phone: Node3D
var _phone: Node3D
var _phone_weight: float = 0.0
var _phone_raise: float = 0.0
var _phone_half: float = 0.006
## T-239: whole hand shapes for the right hand (a paper) and the left (the phone).
var _fingers: FingerPoseModifier
var _left_fingers: FingerPoseModifier
## Where the phone wants to be this frame (world); it is put in the hand as drawn once the skeleton
## has its final pose (_on_skeleton_updated).
var _phone_pose: Transform3D = Transform3D.IDENTITY
## A paper from its pinch on: the HandTarget's frame in the hand bone's frame (skeleton units) moves
## from _held_from to _held_to by _held_blend; the sheet is put there on the hand as drawn. _land
## (weight _land_weight) is where it must end up exactly when it is put back.
var _attach_pending: bool = false
var _held_paper: bool = false
var _held_from: Transform3D = Transform3D.IDENTITY
var _held_to: Transform3D = Transform3D.IDENTITY
var _held_blend: float = 0.0
var _land: Transform3D = Transform3D.IDENTITY
var _land_weight: float = 0.0
## Where the wrist was when the hand set off (a paper's reach goes wrist to wrist).
var _from_wrist: Vector3 = Vector3.ZERO
var _sheet_width: float = 0.21
## The wrist and the hand's turn when the sheet was put down (the empty hand lets go from there).
var _down_hand: Transform3D = Transform3D.IDENTITY


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
	_measure_reach_hands()
	_eye = eye_points[&"idle"]
	_play(&"idle")
	_place_model(0.0)
	EventBus.document_closed.connect(_on_document_closed)
	EventBus.player_death_started.connect(_on_death_started)
	EventBus.bar_picked.connect(_on_bar_picked)


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
		camera.set_cull_mask_value(VIEW_LAYER, true)
	_phone = player.get_node_or_null("Head/Camera3D/PhoneItem") as Node3D
	_build_mirror_phone()
	var phone_body := _phone.get_node_or_null("Model/Body") if _phone != null else null
	if phone_body != null:
		# T-227: the Tripo phone (a GLB scene) or a plain mesh.
		var meshes: Array[Node] = phone_body.find_children("*", "MeshInstance3D", true, false)
		if phone_body is MeshInstance3D:
			meshes.append(phone_body)
		for mesh: MeshInstance3D in meshes:
			if mesh.mesh != null:
				_phone_half = mesh.mesh.get_aabb().size.z * 0.5


func _enter_tree() -> void:
	if not get_tree().node_added.is_connected(_on_node_added):
		get_tree().node_added.connect(_on_node_added)
	for camera: Node in get_tree().root.find_children("*", "Camera3D", true, false):
		_on_node_added(camera)


func _exit_tree() -> void:
	if get_tree().node_added.is_connected(_on_node_added):
		get_tree().node_added.disconnect(_on_node_added)


## T-245: no camera but the player's own draws the view layer.
func _on_node_added(node: Node) -> void:
	var camera := node as Camera3D
	if camera == null:
		return
	if is_instance_valid(player) and camera == player.get_node_or_null("Head/Camera3D"):
		return
	camera.set_cull_mask_value(VIEW_LAYER, false)


## T-245: the phone before the eyes is the player's own view of it; a copy on the mirror layer sits
## in the hand a mirror shows.
func _build_mirror_phone() -> void:
	if is_instance_valid(_mirror_phone):
		_mirror_phone.queue_free()
	_mirror_phone = null
	var source := _phone.get_node_or_null("Model") as Node3D if is_instance_valid(_phone) else null
	if source == null or _mirror_ik == null:
		return
	_mirror_phone = Node3D.new()
	_mirror_phone.name = "MirrorPhone"
	_mirror_phone.top_level = true
	_mirror_phone.visible = false
	add_child(_mirror_phone)
	for mesh: MeshInstance3D in source.find_children("*", "MeshInstance3D", true, false):
		if mesh.mesh == null:
			continue
		var copy := mesh.duplicate(0) as MeshInstance3D
		var place: Transform3D = Transform3D.IDENTITY
		var step: Node = mesh
		while step != source and step is Node3D:
			place = (step as Node3D).transform * place
			step = step.get_parent()
		_mirror_phone.add_child(copy)
		copy.transform = place
		copy.layers = 1 << (MIRROR_LAYER - 1)
		mesh.layers = 1 << (VIEW_LAYER - 1)


func can_handle(target: Interactable) -> bool:
	if acting or _in_bed or _dead or not is_instance_valid(target) or not target.enabled:
		return false
	var marker: HandTarget = target.hand_target(_reach_from())
	# T-249: a fist that holds the bar pinches up no paper (it is read where it lies, as without a body).
	return marker != null and not (marker.pick_up and _has_bar())


## D-124: the HandTarget is within reach of a body standing here (T-241: standing and folding at
## the hips at most MAX_BEND, up on the toes, or bending down to something low).
func can_reach(target: Interactable) -> bool:
	if not is_instance_valid(target):
		return false
	# Judged for a body square to the view, as perform() turns it (standing, the feet may lag).
	var drawn: float = _yaw
	if not acting:
		_place_model(0.0)
	var marker: HandTarget = target.hand_target(_reach_from(), _reach_rank)
	var reachable: bool = marker != null and _reach_kind(marker) != &""
	if not acting:
		_place_model(drawn)
	return reachable


## T-242 (D-159): a door's leaf must not swing through the body. Round where the player stands,
## this far out (metres) on a grid this fine, a spot is looked for that the leaf will miss.
const CLEAR_REACH: float = 1.2
const CLEAR_GRID: float = 0.06
## The leaf passes at least this far from the body (metres).
const SWING_MARGIN: float = 0.04
## A spot must still reach the grip from this much nearer it (his idle sways).
const CLEAR_SWAY: float = 0.03
## Only spots this far from the grip (flat, metres) can reach it at all; and at most this many of
## them are tried for their reach, the nearest first.
const CLEAR_ARM: Vector2 = Vector2(0.2, 0.95)
const CLEAR_TRIES: int = 30
## A grip this near (flat, metres) is taken standing straight; further off costs a lean, weighed
## against the walk at this many metres of walk a metre.
const CLEAR_COMFORT: float = 0.45
const CLEAR_LEAN_COST: float = 1.5
## The grid's steps from where the player stands (made once).
static var _clear_steps: Array[Vector3] = []


## Where the player should stand to use `target`, a door (swing_angle(), pivot()) whose leaf would
## swing through the body where it stands now: {"spot", "aim", "turn"}, the best spot the leaf
## misses (a short walk, the grip within easy reach) that the body fits on, can walk straight to
## and reaches the grip from. "aim" is the grip
## and "turn" how far the view is turned off it now, for the player to keep looking at it the same
## way as it walks. Empty when the body is clear as it stands, the thing is no such door, or there
## is no such spot.
func clear_spot(target: Interactable) -> Dictionary:
	if not can_handle(target) or not target.has_method("swing_angle") or not target.has_method("pivot"):
		return {}
	var here: Vector3 = player.global_position
	var leaf: Node3D = target.call("pivot")
	var to: float = target.call("swing_angle")
	var radius: float = _body_radius()
	if not DoorSwing.hits(leaf, to, here, radius):
		return {}
	var marker: HandTarget = target.hand_target(_reach_from(), _reach_rank)
	if marker == null:
		return {}
	var aim: Vector3 = marker.global_position
	var view: float = player.global_rotation.y
	var turn: float = wrapf(view - _yaw_to(here, aim), -PI, PI)
	# The grid's spots the leaf misses, the best first: a short walk, and the grip near enough to be
	# taken without leaning far (a metre of walk for CLEAR_LEAN_COST metres of reach past CLEAR_COMFORT).
	if _clear_steps.is_empty():
		var cells: int = int(CLEAR_REACH / CLEAR_GRID)
		for column: int in range(-cells, cells + 1):
			for row: int in range(-cells, cells + 1):
				var step := Vector3(column, 0.0, row) * CLEAR_GRID
				if step.length() <= CLEAR_REACH and (column != 0 or row != 0):
					_clear_steps.append(step)
	var scored: Array = []
	for step: Vector3 in _clear_steps:
		var spot: Vector3 = here + step
		var arm: float = Vector2(aim.x - spot.x, aim.z - spot.z).length()
		if arm < CLEAR_ARM.x or arm > CLEAR_ARM.y or DoorSwing.hits(leaf, to, spot, radius, SWING_MARGIN):
			continue
		scored.append([step.length() + maxf(0.0, arm - CLEAR_COMFORT) * CLEAR_LEAN_COST, spot])
	scored.sort_custom(func(a: Array, b: Array) -> bool: return a[0] < b[0])
	var kept: Array = [_yaw, _stand_yaw, _turning, _twist.axis, _twist.degrees]
	var found: Dictionary = {}
	var tries: int = 0
	for entry: Array in scored:
		var spot: Vector3 = entry[1]
		var toward := Vector3(aim.x - spot.x, 0.0, aim.z - spot.z)
		if not _fits(spot) or not _free_way(here, spot):
			continue
		tries += 1
		if tries > CLEAR_TRIES:
			break
		# From there, and from a little nearer the grip (his idle sways): within reach.
		_stand_at(spot + toward.normalized() * CLEAR_SWAY, _yaw_to(spot, aim) + turn)
		if not can_reach(target):
			continue
		_stand_at(spot, _yaw_to(spot, aim) + turn)
		if can_reach(target):
			found = {"spot": spot, "aim": aim, "turn": turn}
			break
	player.global_position = here
	player.global_rotation.y = view
	_yaw = kept[0]
	_stand_yaw = kept[1]
	_turning = kept[2]
	_twist.axis = kept[3]
	_twist.degrees = kept[4]
	_place_model(_yaw)
	return found


## The radius of the player's body (its capsule), metres.
func _body_radius() -> float:
	var shape := player.get("body_shape") as CollisionShape3D
	return (shape.shape as CapsuleShape3D).radius if shape != null and shape.shape is CapsuleShape3D else 0.3


## The player's body fits standing on `spot` (world).
func _fits(spot: Vector3) -> bool:
	var shape := player.get("body_shape") as CollisionShape3D
	if shape == null:
		return true
	var query := PhysicsShapeQueryParameters3D.new()
	query.shape = shape.shape
	query.transform = Transform3D(Basis.IDENTITY, spot + shape.position + Vector3.UP * FIT_LIFT)
	query.collision_mask = player.collision_mask
	query.exclude = [player.get_rid()]
	return get_world_3d().direct_space_state.intersect_shape(query, 1).is_empty()


## The player's body gets from `from` straight to `to` (world) without meeting anything.
func _free_way(from: Vector3, to: Vector3) -> bool:
	var shape := player.get("body_shape") as CollisionShape3D
	if shape == null:
		return true
	var query := PhysicsShapeQueryParameters3D.new()
	query.shape = shape.shape
	if shape.shape is CapsuleShape3D:
		# A little slimmer: a body standing against a wall can still leave along it.
		var slim := (shape.shape as CapsuleShape3D).duplicate() as CapsuleShape3D
		slim.radius -= WAY_SLIM
		query.shape = slim
	query.transform = Transform3D(Basis.IDENTITY, from + shape.position + Vector3.UP * FIT_LIFT)
	query.motion = to - from
	query.collision_mask = player.collision_mask
	query.exclude = [player.get_rid()]
	return get_world_3d().direct_space_state.cast_motion(query)[0] >= 0.999


## The body's shape is tried this far over the floor it stands on (metres).
const FIT_LIFT: float = 0.04
## A way is tried with the body this much slimmer (metres).
const WAY_SLIM: float = 0.03


## Stand the player on `spot`, the view turned to `yaw`, the body square to it (to judge a reach
## from there; clear_spot puts everything back).
func _stand_at(spot: Vector3, yaw: float) -> void:
	player.global_position = spot
	player.global_rotation.y = yaw
	_face_view()


## The view yaw that looks from `from` toward `to` (world, flat).
static func _yaw_to(from: Vector3, to: Vector3) -> float:
	return atan2(from.x - to.x, from.z - to.z)


func _reach_from() -> Vector3:
	return _bone_world("RightUpperArm")


## T-239: how much body a reach for `marker` takes (HandTarget.best): standing (0), up on the toes
## over something (1), bending down (2), from the player's crouch (3), or out of reach. Of a
## paper's edges the one reached with least is taken, never one out of reach while another is not.
func _reach_rank(marker: HandTarget) -> int:
	match _reach_kind(marker):
		&"near":
			return 0
		&"up":
			return 1
		&"stoop":
			return 2
		&"kneel":
			return 3
	return HandTarget.OUT_OF_REACH


func perform(target: Interactable) -> void:
	if not can_handle(target):
		return
	_face_view()
	# T-241: the pose this action is done in, as the clip holds it now (see _joints).
	var stance: StringName = _stance()
	_action_joints = {stance: _joints(stance)}
	acting = true
	_target = target
	_marker = target.hand_target(_reach_from(), _reach_rank)
	_time = 0.0
	_shove = false
	_rub = target is ShowerScreen
	_rub_time = 0.0
	if target is StuckDoor:
		# T-243 (D-162): a shoulder into the swollen door, not a hand on its handle.
		_start_shove(target)
		return
	if _rub:
		# T-243: the screen counts the wipe from the press, as without the body (WIPE_SECONDS): the
		# hand gets there and rubs for the rest of it.
		target.interact(player)
	_contacted = false
	_used = false
	if is_instance_valid(_marker.lever):
		_lever_rest = _marker.lever.quaternion
	_reading = false
	_set_phase(Phase.REACH)
	_from = _hand_tip()
	_start_basis = _carry_basis() if _carry_weight > 0.5 else _natural_basis()
	if _bar_weight > 0.5:
		# T-249: from where the fist holds the bar (a swing stops here).
		_start_basis = _hand_attach.global_basis.orthonormalized()
	_end_swing()
	_from_wrist = _hand_attach.global_position
	_attach_pending = false
	_held_paper = false
	_land_weight = 0.0
	if _marker.pick_up:
		# T-239: the sheet's HandTarget frame where it lies (its right edge, +Z its face).
		_carried_from = _marker.global_transform.orthonormalized()
		# How far the sheet runs across from the edge taken (readable.gd puts it on each edge's marker).
		var size: Variant = target.get("size")
		_sheet_width = float(_marker.get_meta(&"sheet_across", (size as Vector2).x if size is Vector2 else 0.21))
		_fingers.hold(_pick_shape())
	if is_instance_valid(player) and player.has_method("acquire_movement_lock"):
		player.acquire_movement_lock(self)
	# T-241: done the way the prompt judged it (can_reach), never a deeper one.
	_reach = _reach_kind(_marker)
	var goal: Vector3 = _marker.global_position
	var grip: HandTarget.Grip = _marker.grip
	_pull = Vector3.ZERO
	if _marker.pick_up:
		# T-239: a paper is reached for where the pinch puts the palm, when this way of reaching gets
		# it there; else as the prompt judged (to the fingertips) and the sheet is drawn in (_pull).
		var palm: Vector3 = _pinch_palm(_marker)
		if _reaches(_kind(), palm, HandTarget.Grip.GRIP):
			goal = palm
			grip = HandTarget.Grip.GRIP
	# T-239: a pinch leans a little past the bare reach, so the arm is not at full stretch on the sheet.
	_plan(goal, grip, PICK_SLACK if _marker.pick_up else 0.0)
	# The body stands still under every reach (T-241: a reach clip stepped, lifted a heel and raised
	# the other fist to the chest); the lean, the legs, the toes and the arm are posed on top.
	_clip = CLIPS[&"crouch_idle" if _reach == &"kneel" else &"idle"]
	_key = &""
	_pace = HAND_SECONDS / maxf(stoop_seconds, 0.1) if _reach == &"stoop" else 1.0
	animator.speed_scale = 1.0
	# Held still where it is: his idle shifts its feet about, and the reach was planned on this pose.
	animator.play(_clip, BLEND_SECONDS, 0.0)
	_reach_fingers.hold(_reach_hands.get(&"reach_low" if _marker.global_position.y - global_position.y < LOW_REACH else &"reach", {}))
	_grip.curl_degrees = float(_marker.get_meta(&"curl", GRIP_DEGREES[_marker.grip]))
	_aim(_from, _start_basis, 0.0)
	_pole_base = _pole.position
	_door = _marker.has_meta(&"door_levers")
	_closing = _door and bool(target.get("is_open"))
	_released_at = RELEASE
	_shape_arm(_marker.pick_up or _door)
	# T-249: an empty hand taking a bar off the ground hooks it with the fingertips.
	_bar_reach = target is IronBar and not _has_bar()
	_bar_taking = false
	if _bar_reach:
		_bar_goal = (target as IronBar).grip_frame()
		_fingers.hold(BarHand.HOOK)


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
	_tick_carry(delta)
	_tick_bar(delta)
	_tick_breath(delta)
	_tick_phone(delta)
	_move_head()


## Head = the player's own position (stand/crouch height) + neck bend + lean. A write by the
## player (crouching, hiding) since our last one becomes the new base.
func _move_head() -> void:
	if not is_instance_valid(_head):
		return
	var base: Vector3 = _head.position if _head.position != _head_written else _head.position - _head_offset
	var offset: Vector3 = _clear(base, _lean) if acting else _lean
	if visible:
		var down: float = maxf(0.0, -_head.rotation.x)
		offset += Vector3(0.0, 0.0, -NECK_FORWARD * sin(down))
	_head_offset = offset
	_head.position = base + offset
	_head_written = _head.position


## T-241: the camera does not follow the eyes into what the head leans toward: `lean` (the head's
## parent's space, from `base`) is cut short CAMERA_CLEAR before the world's collision.
func _clear(base: Vector3, lean: Vector3) -> Vector3:
	var frame := _head.get_parent() as Node3D
	if frame == null or lean.length() < 0.01 or not is_inside_tree():
		return lean
	var from: Vector3 = frame.global_transform * base
	var to: Vector3 = frame.global_transform * (base + lean)
	var query := PhysicsRayQueryParameters3D.create(from, to + (to - from).normalized() * CAMERA_CLEAR, 1)
	if player is CollisionObject3D:
		query.exclude = [(player as CollisionObject3D).get_rid()]
	var hit: Dictionary = get_world_3d().direct_space_state.intersect_ray(query)
	if hit.is_empty():
		return lean
	var free: float = maxf(0.0, from.distance_to(hit["position"]) - CAMERA_CLEAR)
	return lean.normalized() * minf(lean.length(), free / maxf(frame.global_basis.get_scale().x, 0.001))


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
		var back: bool = absf(heading) > deg_to_rad(100.0)
		if back and speed > RUN_FROM and not crouched:
			# T-249: running with the view turned back. The legs keep running the way he goes and the
			# body faces that way, round by the side it turned (the chest and head turn back, below).
			if _back_side == 0.0:
				_back_side = signf(_yaw) if absf(_yaw) > 0.05 else (signf(heading) if heading != 0.0 else 1.0)
			target_yaw = heading if signf(heading) == _back_side else heading + TAU * _back_side
			if absf(target_yaw) > BACK_ROUND:
				# The view has come round the other side: the body turns back the short way.
				_back_side = -_back_side
				target_yaw = heading
			_yaw += (target_yaw - _yaw) * follow
		else:
			if _back_side != 0.0:
				_back_side = 0.0
				_yaw = wrapf(_yaw, -PI, PI)
			if back:
				# Walking backwards: face forward-ish and play the stride in reverse.
				direction = -1.0
				heading = wrapf(heading + PI, -PI, PI)
			target_yaw = clampf(heading, -MAX_YAW, MAX_YAW)
			_yaw = lerp_angle(_yaw, target_yaw, follow)
		var key: StringName = &"crouch_walk" if crouched else (&"run" if speed > RUN_FROM else &"walk")
		_play(key)
		# Sideways, only the share of the motion along the body is in the stride.
		var along: float = speed * cos(absf(heading) - absf(target_yaw)) if _back_side == 0.0 else speed
		animator.speed_scale = direction * maxf(along, 0.2) / maxf(stride_speeds[key], 0.05)
	else:
		if _back_side != 0.0:
			_back_side = 0.0
			_yaw = wrapf(_yaw, -PI, PI)
		_yaw = _stand_turn(wrapf(_stand_yaw - view_yaw, -PI, PI), delta)
		if _turning:
			_play(&"crouch_walk" if crouched else &"walk")
			animator.speed_scale = TURN_STEP_PACE
		else:
			_play(&"crouch_idle" if crouched else &"idle")
			animator.speed_scale = 1.0
	_stand_yaw = view_yaw + _yaw
	# The chest turns back toward the view: about up as far as MAX_YAW of heading; past it (T-249,
	# looking back on the run) about the back's own line, the head further still.
	var square: float = clampf(_yaw, -MAX_YAW, MAX_YAW)
	_set_twist(-square * TWIST_SHARE)
	var past: float = rad_to_deg(_yaw - square)
	_look_chest = -clampf(past * BACK_CHEST_SHARE, -BACK_CHEST, BACK_CHEST)
	_look_head = -clampf(past * BACK_HEAD_SHARE, -BACK_HEAD, BACK_HEAD)
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
	_back_side = 0.0
	_look_chest = 0.0
	_look_head = 0.0
	_set_twist(0.0)
	if is_instance_valid(player):
		_stand_yaw = player.global_rotation.y
	_place_model(0.0)


func _tick_action(delta: float) -> void:
	if not is_instance_valid(_target) or not is_instance_valid(_marker):
		_finish()
		return
	if _shove:
		_tick_shove(delta)
		return
	_time += delta * _pace
	_phase_time += delta * _pace
	if _marker.pick_up:
		_tick_paper()
		return
	var look_at: Vector3 = _marker.global_position
	var look: float = 0.0
	match _phase:
		Phase.REACH:
			var reach: float = smoothstep(0.0, CONTACT, _time)
			look = reach
			if _bar_reach:
				# T-249: the hand comes down onto the bar as the hook that takes it.
				_aim_hand(Transform3D(_start_basis, _from_wrist).interpolate_with(_bar_hook(), reach))
				_fingers.influence = smoothstep(CONTACT * 0.3, CONTACT, _time)
			else:
				_aim(_from.lerp(_marker.global_position, reach), _start_basis.slerp(_grip_basis(), reach), reach)
			_ik.influence = maxf(smoothstep(0.0, IK_FADE, _time), maxf(_carry_weight, _bar_weight))
			_grip.influence = 0.0 if _bar_reach else maxf(smoothstep(CONTACT * 0.6, CONTACT, _time), _carry_weight)
			if _carry_weight > 0.0:
				_grip.curl_degrees = CARRY_CURL
			elif _rub:
				_grip.curl_degrees = RUB_CURL
			_weigh(reach)
			if _time >= CONTACT:
				_contacted = true
				# The hand keeps its hold on the grip as it moves (a door's leaf turns it).
				_grip_at_contact = _marker.global_basis.orthonormalized()
				_grip_in_marker = _grip_at_contact.inverse() * _grip_basis()
				_contact()
				_set_phase(Phase.HOLD)
		Phase.HOLD:
			look = 1.0
			if _rub:
				# T-243: rubbing round while E is held (the screen counts it); then the hand goes back.
				_used = true
				_rub_time += delta
				if _rubbing():
					_time = minf(_time, CONTACT + 0.01)
				_aim(_rub_goal(), _rub_basis(), 1.0)
				if _time >= RELEASE:
					_from = _rub_goal()
					_released_at = _time
					_release_basis = _rub_basis()
					_set_phase(Phase.RETURN)
				_align.influence = _ik.influence
				_follow_head()
				_look(look_at, look)
				return
			var pressing: bool = is_instance_valid(_marker.lever) and not _closing
			if pressing:
				_press_lever(smoothstep(CONTACT, CONTACT + LEVER_SECONDS, _time))
			if not _used and _time >= CONTACT + (LEVER_SECONDS if pressing else 0.0):
				_use()
			if _bar_reach:
				_aim_hand(_bar_hook())
			else:
				_aim(_marker.global_position, _held_basis(), 1.0)
			# T-239: a door's grip is followed as the leaf swings, until the time comes or it leaves the
			# arm's reach; then the hand lets go and the leaf swings on.
			var hold_until: float = DOOR_LET_GO if _door else (STOOP_RELEASE if _reach == &"stoop" else RELEASE)
			if _time >= hold_until or (_door and _used and _beyond_arm()):
				_from = _marker.global_position
				_released_at = _time
				_release_basis = _held_basis()
				_set_phase(Phase.RETURN)
		Phase.RETURN:
			var back: float = smoothstep(_released_at, HAND_SECONDS, _time)
			look = 1.0 - back
			if not _closing:
				_press_lever(1.0 - smoothstep(_released_at, _released_at + LEVER_SECONDS, _time))
			if not _used:
				_use()
			# Let go of a door's grip, the hand turns back to the arm's line first (no bent wrist hangs on).
			var unwind: float = smoothstep(_released_at, _released_at + DOOR_UNWIND, _time) if _door else back
			# T-243: with something in the fist the hand goes back to carrying it, not to the side.
			var carrying: bool = _still_held()
			var rest_tip: Vector3 = _carry_palm() if carrying else _natural_tip()
			var rest_basis: Basis = _carry_basis() if carrying else _natural_basis()
			if _has_bar():
				# T-249: ... or to holding the bar at the ready.
				var ready: Transform3D = _bar_ready()
				carrying = true
				rest_basis = ready.basis
				rest_tip = ready.origin + ready.basis.y * PALM * _scale()
			if _bar_reach and carrying:
				# The hook that took the bar comes up with it, the fist closing (_tick_bar).
				_aim_hand(_bar_hook().interpolate_with(Transform3D(rest_basis, rest_tip - rest_basis.y * PALM * _scale()), back))
			else:
				_aim(_from.lerp(rest_tip, back), _release_basis.slerp(rest_basis, unwind), 0.0 if carrying else 1.0 - back)
			_grip.influence = 0.0 if _has_bar() else (1.0 if carrying else 1.0 - back)
			_weigh(1.0 - back)
			_ik.influence = 1.0 if carrying else 1.0 - smoothstep(HAND_SECONDS - IK_FADE, HAND_SECONDS, _time)
			if _time >= HAND_SECONDS:
				_finish()
				return
	_align.influence = _ik.influence
	_follow_head()
	_look(look_at, look)


## T-239: a paper, from the reach to letting go of it again (see PAPER_TOUCH, PAPER_PINCH).
func _tick_paper() -> void:
	var look_at: Vector3 = _carried_from.origin
	var look: float = 0.0
	match _phase:
		Phase.REACH:
			# Wrist to wrist: from where the clip held it to over the edge, the pinch already shaped.
			var reach: float = smoothstep(0.0, PAPER_TOUCH, _time)
			look = reach
			var above: Transform3D = _pick_hand(0.0)
			_aim_hand(Transform3D(_start_basis.slerp(above.basis, reach), _reach_path(_from_wrist, above.origin, _time / PAPER_TOUCH)))
			_ik.influence = smoothstep(0.0, IK_FADE, _time)
			_fingers.influence = smoothstep(PAPER_TOUCH * 0.3, PAPER_TOUCH, _time)
			_weigh(reach)
			if _time >= PAPER_TOUCH:
				_contacted = true
				_carry(_target)
				_set_phase(Phase.HOLD)
		Phase.HOLD:
			if _time < PAPER_PINCH:
				# Down onto the edge (sliding the index under it as it rises), the thumb closes on the face.
				var take: float = smoothstep(PAPER_TOUCH, PAPER_PINCH, _time)
				look = 1.0
				_draw_in()
				_aim_hand(_pick_hand(take))
				_carried.global_transform = _lifted_sheet(take)
				_weigh(1.0)
			else:
				if not _held_paper and not _attach_pending:
					# The sheet comes away now, held as the hand has it: as planned until the skeleton's
					# final pose this frame gives the exact hold (_on_skeleton_updated).
					_carried.global_transform = _lifted_sheet(1.0)
					_held_from = _relation(_pick_hand(1.0), _carried.global_transform)
					_attach_pending = true
					_held_to = _ortho(HandShapes.SHEET_IN_HAND_READ)
				var lift: float = smoothstep(PAPER_PINCH, HAND_SECONDS, _time)
				var held: Transform3D = _held_from.interpolate_with(_held_to, lift)
				_held_blend = lift
				_aim_hand(_hand_for(_sheet_path(_lifted_sheet(1.0), _read_pose(), lift), held))
				_fingers.morph(_pick_shape(), HandShapes.READ, lift)
				# Straighten up while the paper rises to the eyes (and the look comes back up).
				_weigh(1.0 - lift)
				look_at = _carried.global_position if is_instance_valid(_carried) else look_at
				look = 1.0 - lift
				if _time >= HAND_SECONDS:
					_read()
		Phase.READ:
			_held_blend = 1.0
			_aim_hand(_hand_for(_read_pose(), _held_to))
			_fingers.hold(HandShapes.READ)
		Phase.PUT_DOWN:
			# Back where it lay, flat, held as when it is set down with a straight pinch.
			var down: float = smoothstep(0.0, PUT_DOWN_SECONDS, _phase_time)
			var placed: Transform3D = _set_down_hold()
			_held_blend = down
			_land = _carried_from
			_land_weight = smoothstep(0.75, 1.0, down)
			look = down
			_aim_hand(_hand_for(_sheet_path(_read_pose(), _carried_from, down), _held_from.interpolate_with(placed, down)))
			_fingers.morph(HandShapes.READ, HandShapes.PICK_STRAIGHT if _flat(_carried_from) else HandShapes.READ, down)
			_weigh(down)
			if _phase_time >= PUT_DOWN_SECONDS:
				_down_hand = _hand_for(_carried_from, placed)
				_restore_carried()
				_held_paper = false
				_land_weight = 0.0
				_set_phase(Phase.LET_GO)
		Phase.LET_GO:
			# Up off the sheet, then back to the side; the fingers go back to the clip's.
			var away: float = smoothstep(0.0, LET_GO_SECONDS, _phase_time)
			var off: Vector3 = _down_hand.origin + _carried_from.basis.z * PICK_ABOVE
			look = 1.0 - away
			var wrist: Vector3 = _down_hand.origin.lerp(off, smoothstep(0.0, 0.3, away))
			if away > 0.3:
				wrist = _reach_path(off, _natural_wrist(), (away - 0.3) / 0.7)
			_aim_hand(Transform3D(_down_hand.basis.slerp(_natural_basis(), away), wrist))
			_fingers.influence = 1.0 - away
			_weigh(1.0 - away)
			_ik.influence = 1.0 - smoothstep(LET_GO_SECONDS - IK_FADE, LET_GO_SECONDS, _phase_time)
			if _phase_time >= LET_GO_SECONDS:
				_finish()
				return
	_align.influence = _ik.influence
	_follow_head()
	_look(look_at, look)


## T-239: the wrist's way from `from` to `to` at `t` (0..1). Going up to a desk the hand rises first,
## then comes over (it does not cut through the desk's edge); going down it comes over first, then
## drops onto the sheet.
static func _reach_path(from: Vector3, to: Vector3, t: float) -> Vector3:
	var up: bool = to.y > from.y
	var level: float = smoothstep(0.0, 0.65, t) if up else smoothstep(0.35, 1.0, t)
	var over: float = smoothstep(0.25, 1.0, t) if up else smoothstep(0.0, 0.7, t)
	var flat: Vector3 = Vector3(from.x, 0.0, from.z).lerp(Vector3(to.x, 0.0, to.z), over)
	return Vector3(flat.x, lerpf(from.y, to.y, level), flat.z)


## The sheet on its way between `from` and `to` (turning on the way), along _reach_path.
static func _sheet_path(from: Transform3D, to: Transform3D, t: float) -> Transform3D:
	return Transform3D(from.basis.orthonormalized().slerp(to.basis.orthonormalized(), t), _reach_path(from.origin, to.origin, t))


## The pinch for picking the sheet up (pick_style); a standing sheet (a photo in its frame) is taken
## as it is read, the thumb in front and the fingers behind it.
func _pick_shape() -> Dictionary:
	if not _flat(_carried_from):
		return HandShapes.READ
	return HandShapes.PICK_LIFT if pick_style == &"lift" else HandShapes.PICK_STRAIGHT


## A sheet lying (its face up or down), not standing.
static func _flat(sheet: Transform3D) -> bool:
	return absf(sheet.basis.z.normalized().y) > 0.7


## How the hand holds the sheet's HandTarget frame when it sets it down (and picked a standing one).
func _set_down_hold() -> Transform3D:
	if not _flat(_carried_from):
		return _ortho(HandShapes.SHEET_IN_HAND_READ)
	return _ortho(HandShapes.HAND_IN_SHEET_PICK_STRAIGHT.affine_inverse())


## The hand for the pinch on the sheet where it lies: `take` 0 hovers PICK_ABOVE over it (and with
## &"lift" PICK_SLIDE outside its edge), 1 is the pinch. The edge taken already suits the reach
## (HandTarget.preference), so the pinch is the one designed for the sheet, not turned about it
## (turned, the index went through the sheet).
func _pick_hand(take: float) -> Transform3D:
	var hand: Transform3D = _pinch_hand(_carried_from.translated(_pull * take))
	var away: float = 1.0 - take
	var slide: float = PICK_SLIDE if pick_style == &"lift" else 0.0
	hand.origin += _carried_from.basis.z * PICK_ABOVE * away + _carried_from.basis.x * slide * away
	return hand


## How much further than the bare reach a pinch is planned to lean (metres).
const PICK_SLACK: float = 0.03
## T-239: a sheet the arm cannot bring the pinch to (the prompt's reach is to its edge with the
## fingertips) is drawn in by the fingertips along what it lies on, toward where the hand gets to,
## at most this far (metres), before it is pinched.
const PULL_LIMIT: float = 0.12
var _pull: Vector3 = Vector3.ZERO
var _wrist_short: Vector3 = Vector3.ZERO


## While the wrist falls short of the pinch, draw the sheet in along its face (never up off its desk)
## by part of the shortfall each frame: the goal comes back within the arm's reach.
func _draw_in() -> void:
	if _wrist_short.length() < 0.005:
		return
	var face: Vector3 = _carried_from.basis.z.normalized()
	var along: Vector3 = _wrist_short - face * _wrist_short.dot(face)
	along.y = 0.0
	_pull = (_pull + along * 0.5).limit_length(PULL_LIMIT)
## The width of sheet HandShapes' lift was designed on, and how far in from the edge the index's pad
## goes under it (metres): a narrower sheet tilts more for the same rise, so it rises a little more to
## clear the pad as much.
const PICK_DESIGN_WIDTH: float = 0.15
const PICK_PAD_IN: float = 0.012


## The hand at the pinch on a sheet whose HandTarget frame is `sheet` (pick_style).
func _pinch_hand(sheet: Transform3D) -> Transform3D:
	if not _flat(sheet):
		return _hand_for(sheet, _ortho(HandShapes.SHEET_IN_HAND_READ))
	var in_sheet: Transform3D = HandShapes.HAND_IN_SHEET_PICK_LIFT if pick_style == &"lift" else HandShapes.HAND_IN_SHEET_PICK_STRAIGHT
	return _hand_for(sheet, _ortho(in_sheet.affine_inverse()))


## The sheet where it lies, its right edge risen `rise` of the way onto the index (&"lift": turned
## about its left edge), before the pinch takes it.
func _lifted_sheet(rise: float) -> Transform3D:
	if pick_style != &"lift" or is_zero_approx(rise) or not _flat(_carried_from):
		return _carried_from.translated(_pull * rise)
	var width: float = maxf(_sheet_width, PICK_PAD_IN + 0.02)
	var height: float = HandShapes.PICK_LIFT_RISE * rise * (1.0 - PICK_PAD_IN / PICK_DESIGN_WIDTH) / (1.0 - PICK_PAD_IN / width)
	var tilt: float = asin(clampf(height / width, 0.0, 1.0))
	var left: Vector3 = _carried_from * Vector3(-(_sheet_width - 0.015), 0.0, 0.0)
	var axis: Vector3 = -_carried_from.basis.y
	var turn := Basis(axis, tilt)
	return Transform3D(turn * _carried_from.basis, left + turn * (_carried_from.origin - left) + _pull * rise)


## Held up to read: the sheet's face to the eyes, upright, its centre at READ_POINT.
func _read_pose() -> Transform3D:
	var camera := _camera()
	if camera == null:
		return _carried_from
	return Transform3D(camera.global_basis.orthonormalized(), _read_point())


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
	_target.interact_by_hand(player, maxf(0.0, HAND_SECONDS - _time) / _pace)


## T-239 (owner, 09/11): a door (DoorHandles.sides) is closed without pressing its lever; its grip is
## held as the leaf swings until DOOR_LET_GO (or until it leaves the arm's reach), then let go.
const DOOR_LET_GO: float = 0.86
const DOOR_UNWIND: float = 0.12
var _door: bool = false
var _closing: bool = false
var _released_at: float = RELEASE
var _release_basis: Basis = Basis.IDENTITY
var _grip_in_marker: Basis = Basis.IDENTITY


## The hand on the grip: as it took hold (turning with a door's leaf), else as _grip_basis.
func _held_basis() -> Basis:
	if _door:
		return (_marker.global_basis.orthonormalized() * _grip_in_marker).orthonormalized()
	return _grip_basis()


## The arm, as drawn last frame, no longer brings the wrist to its goal (the grip has gone past
## the arm's reach): further off it than this (metres).
const ARM_SHORT: float = 0.015
## ... or would bend the wrist further than this off the forearm (degrees): the grip has come round
## too close (a leaf swinging in toward the body).
const WRIST_BEND_LIMIT: float = 90.0
## ... or the grip has turned this far since the hand took it (a leaf swung on past what the arm
## follows without twisting round; radians).
const FOLLOW_TURN: float = deg_to_rad(45.0)
var _wrist_off_goal: float = 0.0
var _wrist_bend: float = 0.0
var _grip_at_contact: Basis = Basis.IDENTITY


func _beyond_arm() -> bool:
	var turned: float = (_grip_at_contact.inverse() * _marker.global_basis.orthonormalized()).get_rotation_quaternion().get_angle()
	return _wrist_off_goal > ARM_SHORT or _wrist_bend > WRIST_BEND_LIMIT or turned > FOLLOW_TURN


## Hold `point` with the hand turned to `hand`: the palm's middle sits back from the point on the
## palm side by the hold gap (scaled by `hold`, 0 while the hand is still free), and the wrist
## goal back along the fingers from there.
func _aim(point: Vector3, hand: Basis, hold: float) -> void:
	_align.target_basis = hand
	var palm: Vector3 = (hand * _palm_axis).normalized()
	var middle: Vector3 = point - palm * _hold_gap() * hold
	_goal.global_position = middle - hand.y.normalized() * (PALM + _tip()) * _scale()
	if _arm_shaped:
		_place_pole(_pole, _pole_base, _drawn_shoulder, _goal.global_position, -hand.x.normalized())


## T-239: the wrist (the IK goal) at `hand`'s origin and the hand turned to its basis.
func _aim_hand(hand: Transform3D) -> void:
	_align.target_basis = hand.basis
	_goal.global_position = hand.origin
	if _arm_shaped:
		_place_pole(_pole, _pole_base, _drawn_shoulder, hand.origin, -hand.basis.x.normalized())


## T-239 (wrist): the IK turns the arm about its line so the elbow's point (the forearm's back, -Z)
## faces the pole. With the pole on the side of the hand's little finger (square to the arm), the
## forearm is already turned the way the hand is and the wrist keeps its shape: a hand twisted half
## round against its forearm pinched the skin at the wrist (owner's playtest, 09/11). From where the
## elbow points by default (`rest`, model space) it swings at most ELBOW_SWING; what twist is left
## the forearm shares with the wrist (HandAlignModifier.forearm_share).
const ELBOW_SWING: float = deg_to_rad(110.0)
const LEFT_POLE_REST := Vector3(0.6, 0.8, -0.4)
const FOREARM_SHARE: float = 0.5
var _arm_shaped: bool = false


var _pole_angles: Dictionary = {}


func _shape_arm(on: bool) -> void:
	_arm_shaped = on
	_pole_angles.erase(_pole)
	_ik.set_pole_direction(0, SkeletonModifier3D.SECONDARY_DIRECTION_MINUS_Z if on else SkeletonModifier3D.SECONDARY_DIRECTION_NONE)
	_align.forearm_share = FOREARM_SHARE if on else 0.0


## Put `pole` beside the arm from `shoulder` to `goal` (world), toward `little` (the hand's
## little-finger side) as far as ELBOW_SWING from the default side `rest` (model space).
func _place_pole(pole: Node3D, rest: Vector3, shoulder: Vector3, goal: Vector3, little: Vector3) -> void:
	if not shoulder.is_finite():
		return
	var line: Vector3 = goal - shoulder
	if line.length() < 0.01:
		return
	line = line.normalized()
	var base: Vector3 = model.global_transform * rest - shoulder
	base -= line * base.dot(line)
	if base.length() < 0.001:
		return
	base = base.normalized()
	var side: Vector3 = little - line * little.dot(line)
	var angle: float = float(_pole_angles.get(pole, 0.0))
	if side.length() > 0.2:
		# The way round nearest last frame's (the elbow does not flip as the hand turns past behind it).
		var wanted: float = base.signed_angle_to(side.normalized(), line)
		wanted += TAU * roundf((angle - wanted) / TAU)
		angle = clampf(wanted, -ELBOW_SWING, ELBOW_SWING)
	_pole_angles[pole] = angle
	pole.global_position = shoulder.lerp(goal, 0.5) + base.rotated(line, angle) * 0.4


## The skeleton's world scale: hand-space transforms (HandShapes) are in skeleton units.
func _sk_scale() -> float:
	return skeleton.global_basis.get_scale().x


## A bone as the skeleton finally poses it (IK and fingers included). Only meaningful while the
## skeleton updates (_on_skeleton_updated): elsewhere the pose is the clip's.
func _posed_bone(bone: String) -> Transform3D:
	return skeleton.global_transform * skeleton.get_bone_global_pose(skeleton.find_bone(bone))


## Where a thing held at `held` (in the hand bone's frame, skeleton units) is, for the hand bone at
## `hand` (world, the skeleton's scale in its basis).
func _held_world(hand: Transform3D, held: Transform3D) -> Transform3D:
	return Transform3D((hand.basis.orthonormalized() * held.basis).orthonormalized(), hand * held.origin)


## The hand bone (world; unscaled basis) that has a thing at `world` held at `held`.
func _hand_for(world: Transform3D, held: Transform3D) -> Transform3D:
	var basis: Basis = (world.basis.orthonormalized() * held.basis.orthonormalized().inverse()).orthonormalized()
	return Transform3D(basis, world.origin - basis * (held.origin * _sk_scale()))


## How a thing at `world` sits in the hand bone at `hand` (unscaled basis): the inverse of _hand_for.
func _relation(hand: Transform3D, world: Transform3D) -> Transform3D:
	var inverse: Basis = hand.basis.orthonormalized().inverse()
	return Transform3D((inverse * world.basis.orthonormalized()).orthonormalized(), inverse * (world.origin - hand.origin) / _sk_scale())


## A hand-space transform (HandShapes) with its basis made exactly orthonormal, for interpolation.
static func _ortho(transform: Transform3D) -> Transform3D:
	return Transform3D(transform.basis.orthonormalized(), transform.origin)


## The wrist where the clip itself holds it this frame (before IK).
func _natural_wrist() -> Vector3:
	return (skeleton.global_transform * skeleton.get_bone_global_pose(skeleton.find_bone("RightHand"))).origin


## T-239: once the skeleton has its final pose this frame (IK, fingers), what the hands hold is put on
## them as drawn: the phone in the left hand, a pinched paper in the right.
func _on_skeleton_updated() -> void:
	_drawn_shoulder = _posed_bone("RightUpperArm").origin
	_drawn_left_shoulder = _posed_bone("LeftUpperArm").origin
	var hand_drawn: Transform3D = _posed_bone("RightHand")
	_wrist_short = hand_drawn.origin - _goal.global_position if _ik.influence >= 1.0 else Vector3.ZERO
	_wrist_off_goal = _wrist_short.length()
	var forearm: Vector3 = hand_drawn.origin - _posed_bone("RightLowerArm").origin
	_wrist_bend = rad_to_deg(forearm.angle_to(hand_drawn.basis.y)) if forearm.length() > 0.001 else 0.0
	if _phone_weight > 0.0 and is_instance_valid(_phone):
		var model := _phone.get_node_or_null("Model") as Node3D
		if model != null:
			var placed: Transform3D = _phone_pose.interpolate_with(_held_world(_posed_bone("LeftHand"), HandShapes.PHONE_IN_HAND), _phone_weight)
			model.global_transform = placed
			var light := _phone.get_node_or_null("Flashlight") as Node3D
			var camera := _camera()
			if light != null and camera != null:
				light.global_transform = Transform3D(camera.global_basis, placed.origin + (-camera.global_basis.z.normalized()) * PHONE_LIGHT_AHEAD)
	if is_instance_valid(_mirror_phone):
		# T-245: the phone a mirror shows rides the hand a mirror shows.
		var shown: bool = _phone_weight > 0.01 and is_visible_in_tree() and is_instance_valid(_phone) \
				and (_phone.get_node("Model") as Node3D).is_visible_in_tree()
		_mirror_phone.visible = shown
		if shown:
			_mirror_phone.global_transform = _held_world(_posed_bone(MIRROR_BONE + "LeftHand"), HandShapes.PHONE_IN_HAND)
	_place_held()
	_place_bar()
	if not acting or not is_instance_valid(_carried):
		return
	var hand: Transform3D = _posed_bone("RightHand")
	if _attach_pending:
		_held_from = _relation(Transform3D(hand.basis.orthonormalized(), hand.origin), _carried.global_transform)
		_attach_pending = false
		_held_paper = true
	elif _held_paper:
		var on_hand: Transform3D = _held_world(hand, _held_from.interpolate_with(_held_to, _held_blend))
		_carried.global_transform = on_hand.interpolate_with(_land, _land_weight) if _land_weight > 0.0 else on_hand


## How far past the palm's middle the hand takes the thing now (model metres): the fingertips on
## a high pinch or hook, as far as the reach has come.
func _tip() -> float:
	return _tip_extra * clampf(_rise_weight, 0.0, 1.0)


## From the palm's middle to what the hand holds, along the palm's facing.
func _hold_gap() -> float:
	return (HAND_HALF + HOLD_GAP) * _scale()


## The point the hand holds, as drawn: palm's middle (or the fingertips, _tip) plus the hold gap
## out of the palm.
func _contact_point() -> Vector3:
	var hand: Basis = _hand_attach.global_basis.orthonormalized()
	var palm: Vector3 = (hand * _palm_axis).normalized()
	return _hand_tip() + hand.y * _tip() * _scale() + palm * _hold_gap()


## How the hand meets the target (world space): a lever palm down with the fingers over it, an
## edge with the palm turned in, a paper with the fingers down onto its near edge.
func _grip_basis() -> Basis:
	if _rub:
		return _rub_basis()
	if _marker.has_meta(&"hand_basis"):
		# T-239: a grip that says how the hand lies on it (a door's free edge, DoorHandles.sides).
		return (_marker.global_basis.orthonormalized() * (_marker.get_meta(&"hand_basis") as Basis)).orthonormalized()
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
	# T-239: the left hand that holds the phone there (HandShapes.PHONE_IN_HAND: its back on the palm,
	# the fingers round its far edge, the thumb up its near edge); once the skeleton has its final pose
	# the phone is put in that hand as drawn (_on_skeleton_updated).
	_phone_pose = pose
	var hand: Transform3D = _hand_for(pose, HandShapes.PHONE_IN_HAND)
	_left_goal.global_position = hand.origin
	_left_align.target_basis = hand.basis
	# The left hand's +X is its little-finger side (the right hand's is the thumb's).
	_place_pole(_left_pole, LEFT_POLE_REST, _drawn_left_shoulder, hand.origin, hand.basis.x.normalized())
	_left_ik.influence = _phone_weight
	_left_align.influence = _phone_weight
	_left_fingers.influence = _phone_weight
	_tick_mirror_arm(camera)


## T-245 (D-163): the arm a mirror shows holds the phone by the body (MIRROR_PHONE_*): the same hand
## shape on the phone, the elbow down by the ribs.
func _tick_mirror_arm(camera: Camera3D) -> void:
	if _mirror_ik == null:
		return
	_mirror_ik.influence = _phone_weight
	_mirror_align.influence = _phone_weight
	if _phone_weight <= 0.0 or not _drawn_left_shoulder.is_finite():
		return
	var forward: Vector3 = -camera.global_basis.z.normalized()
	var flat := Vector3(forward.x, 0.0, forward.z)
	if flat.length() < 0.05:
		# Looking straight down or up: the top of the view is ahead.
		flat = camera.global_basis.y * (-signf(forward.y))
		flat.y = 0.0
	var turn := Basis.looking_at(flat.normalized(), Vector3.UP)
	var pitch: float = asin(clampf(forward.y, -1.0, 1.0)) * MIRROR_PITCH_SHARE
	var frame := Transform3D(turn * Basis(Vector3.RIGHT, pitch), _drawn_left_shoulder)
	var low: Transform3D = frame * Transform3D(Basis.from_euler(MIRROR_PHONE_LOW_TILT), MIRROR_PHONE_LOW_AT)
	var high: Transform3D = frame * Transform3D(Basis.from_euler(MIRROR_PHONE_RAISED_TILT), MIRROR_PHONE_RAISED_AT)
	var hand: Transform3D = _hand_for(low.interpolate_with(high, _phone_raise), HandShapes.PHONE_IN_HAND)
	_mirror_goal.global_position = hand.origin
	_mirror_align.target_basis = hand.basis
	_mirror_pole.global_position = _drawn_left_shoulder.lerp(hand.origin, 0.5) + (frame.basis * MIRROR_ELBOW).normalized() * 0.4


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
	var opened: Array[bool] = [false]
	var probe := func(_id: StringName) -> void: opened[0] = true
	EventBus.document_opened.connect(probe)
	_target.interact(player)
	EventBus.document_opened.disconnect(probe)
	if not opened[0]:
		_put_back()


## The camera rides with the eyes as the body leans in (the player itself stays put). T-241: on
## the eyes as this frame's lean is planned to put them, not as the head was drawn a frame ago and
## not part of the way: a camera left behind the head showed the player his own nape and hair.
func _follow_head() -> void:
	var forward: Vector3 = (global_basis * _lean_forward).normalized()
	var kind: StringName = _kind()
	var eyes: Vector3 = _leaned(kind, forward, _lean_now)["eye"]
	var standing: Vector3 = _leaned(kind, forward, 0.0)["eye"]
	_lean = player.global_basis.inverse() * (eyes - standing + Vector3.UP * _rise)


## This action's way of reaching (a thing out of reach, only ever asked for by a test, as standing).
func _kind() -> StringName:
	return _reach if _reach != &"" else &"near"


## The measured pose a reach of `kind` is done in.
func _pose_of(kind: StringName) -> StringName:
	return &"crouch_idle" if kind == &"kneel" else &"idle"


func _lean_limit(kind: StringName) -> float:
	match kind:
		&"stoop":
			return STOOP_BEND
		&"kneel":
			return KNEEL_BEND
		&"up":
			return HIGH_LEAN
	return MAX_BEND


## T-241: how a lean of `degrees` is done for a reach of `kind`: the hips' turn, the back's bend,
## the twist and what the neck gives back (degrees); how far the seat goes back and down (metres);
## how far the free arm swings with the trunk (degrees). Standing and bending down fold at the
## hips; on the toes and from the player's crouch the back leans alone, as before.
func _lean_parts(kind: StringName, degrees: float) -> PackedFloat32Array:
	match kind:
		&"near":
			var share: float = degrees / MAX_BEND
			return PackedFloat32Array([degrees * STAND_HIP_SHARE, degrees * (1.0 - STAND_HIP_SHARE), STAND_TWIST * share,
					degrees * STAND_NECK, STAND_BACK * share, 0.0, 0.0])
		&"stoop":
			return PackedFloat32Array([degrees * STOOP_HIP_SHARE, degrees * (1.0 - STOOP_HIP_SHARE),
					STOOP_TWIST * smoothstep(20.0, 90.0, degrees), minf(degrees * STOOP_NECK, STOOP_NECK_MAX),
					STOOP_BACK * smoothstep(0.0, 100.0, degrees), STOOP_DROP * smoothstep(20.0, 110.0, degrees),
					maxf(0.0, degrees - STOOP_ARM_FROM) * STOOP_ARM])
	return PackedFloat32Array([0.0, degrees, 0.0, 0.0, 0.0, 0.0, 0.0])


## T-241: the joints a lean in `pose` is planned on (model space). Tran Trung's idle shifts his
## weight (his ankles wander 10 cm, his shoulders with them), so a body standing still in that
## pose is taken as the clip holds it now, not as its first frame: the prompt judges the pose the
## action will be done in (perform holds the clip still), and the hand gets where it was planned.
## During an action: the joints it started with.
func _joints(pose: StringName) -> Dictionary:
	if acting and _action_joints.has(pose):
		return _action_joints[pose]
	if _key == pose and _clip == CLIPS[pose] and animator.current_animation == String(CLIPS[pose]):
		var frame: int = Engine.get_physics_frames()
		if _live_frame != frame or _live_pose != pose:
			_live_frame = frame
			_live_pose = pose
			_live_joints = _read_joints()
		return _live_joints
	return _lean_joints.get(pose, {})


## T-241: the right hand's fingers as the clip under a reach held them when the hand touched (a
## FingerPoseModifier shape each): &"reach" the standing reach clip (ual/Interact) for what is
## LOW_REACH or more over the feet; &"reach_low" the crouch's open hand for what is lower (before
## T-241 the body crouched for nearly all of that: desks and the floor). Those clips no longer
## play under a reach (one stepped, lifted a heel and raised the other fist; the other was the
## crouch), but what the hand looked like on a switch, a handle or a mattress stays (T-239).
const REACH_HANDS := {&"reach": &"ual/Interact", &"reach_low": &"ual/Crouch_Idle"}
const LOW_REACH: float = 0.95
var _reach_hands: Dictionary = {}
var _reach_fingers: FingerPoseModifier


func _measure_reach_hands() -> void:
	for key: StringName in REACH_HANDS:
		var clip: StringName = REACH_HANDS[key]
		if not animator.has_animation(clip):
			continue
		animator.play(clip)
		animator.seek(animator.get_animation(clip).length * CONTACT / HAND_SECONDS, true)
		var shape: Dictionary = {}
		for joint: String in FingerPoseModifier.JOINTS:
			var index: int = skeleton.find_bone("Right" + joint)
			if index >= 0:
				shape[joint] = skeleton.get_bone_rest(index).basis.get_rotation_quaternion().inverse() * skeleton.get_bone_pose_rotation(index)
		_reach_hands[key] = shape
	animator.stop()


var _action_joints: Dictionary = {}
var _live_joints: Dictionary = {}
var _live_frame: int = -1
var _live_pose: StringName = &""


## The lean's joints as the clip holds the skeleton now, model space.
func _read_joints() -> Dictionary:
	var to_model: Transform3D = model.global_transform.affine_inverse() * skeleton.global_transform
	var at := func(bone: String) -> Vector3: return (to_model * skeleton.get_bone_global_pose(skeleton.find_bone(bone))).origin
	var spine: Array[Vector3] = []
	for bone: String in _bend.bones:
		spine.append(at.call(bone))
	var head: Vector3 = at.call("Head")
	return {"pivot": ((at.call("LeftUpperLeg") as Vector3) + (at.call("RightUpperLeg") as Vector3)) * 0.5,
			"spine": spine, "neck": at.call("Neck"), "head": head, "eye": head + EYES_FROM_HEAD_BONE,
			"shoulder": at.call("RightUpperArm"), "left_shoulder": at.call("LeftUpperArm")}


## Flat, from between the hips toward `goal` (world): the way a reach for it leans.
func _toward(goal: Vector3) -> Vector3:
	var joints: Dictionary = _joints(_stance())
	var from: Vector3 = model.global_transform * (joints["pivot"] as Vector3) if not joints.is_empty() else global_position
	var flat: Vector3 = goal - from
	flat.y = 0.0
	return flat.normalized() if flat.length() > 0.01 else -global_basis.z


## T-241: where a lean of `degrees` toward `forward` (world, flat), done the `kind` way, puts the
## right shoulder joint, the left one and the eyes (world): the measured pose's joints posed step
## by step as BodyLeanModifier poses the bones.
func _leaned(kind: StringName, forward: Vector3, degrees: float) -> Dictionary:
	var joints: Dictionary = _joints(_pose_of(kind))
	if joints.is_empty():
		var shoulder: Vector3 = _bone_world("RightUpperArm")
		return {"shoulder": shoulder, "left_shoulder": _bone_world("LeftUpperArm"), "eye": _eye_world()}
	var to_world: Transform3D = model.global_transform
	var spine: Array[Vector3] = []
	for point: Vector3 in joints["spine"]:
		spine.append(to_world * point)
	var parts: PackedFloat32Array = _lean_parts(kind, degrees)
	var posed: Dictionary = BodyLeanModifier.pose_points(to_world * (joints["pivot"] as Vector3), spine,
			to_world * (joints["neck"] as Vector3), to_world * (joints["head"] as Vector3), [to_world * (joints["eye"] as Vector3)],
			[to_world * (joints["shoulder"] as Vector3), to_world * (joints["left_shoulder"] as Vector3)],
			Vector3.UP.cross(forward).normalized(), parts[0], parts[1], parts[2], parts[3], -forward * parts[4] + Vector3.DOWN * parts[5])
	return {"shoulder": posed["chest"][0], "left_shoulder": posed["chest"][1], "eye": posed["top"][2]}


## T-241: the least lean (degrees, in LEAN_STEP steps up to `limit`) of a `kind` reach that brings
## the shoulder within the arm's reach of `goal` (`extra` metres more, or less when negative: some
## slack), or INF if none does.
func _lean_for(kind: StringName, goal: Vector3, extra: float, limit: float) -> float:
	var joints: Dictionary = _joints(_pose_of(kind))
	if joints.is_empty():
		return INF
	var reach: float = (arm_reach + extra) * _scale()
	# Further than the whole trunk and arm laid out toward it: no lean gets there.
	var pivot: Vector3 = model.global_transform * (joints["pivot"] as Vector3)
	var trunk: float = (joints["pivot"] as Vector3).distance_to(joints["shoulder"] as Vector3) * _scale()
	if goal.distance_to(pivot) > trunk + reach + STOOP_BACK + STOOP_DROP:
		return INF
	var forward: Vector3 = _toward(goal)
	for step: int in range(0, int(limit) + 1, LEAN_STEP):
		if (_leaned(kind, forward, float(step))["shoulder"] as Vector3).distance_to(goal) <= reach:
			# Not with the head through a wall, a locker or a bed frame: from here it is out of reach.
			return float(step) if _head_free(kind, forward, float(step)) else INF
	return INF


## The eyes' way from standing to a lean of `degrees` (and CAMERA_CLEAR beyond) is free of the
## world's collision.
func _head_free(kind: StringName, forward: Vector3, degrees: float) -> bool:
	if degrees <= 0.0 or not is_inside_tree():
		return true
	# The eyes swing out and down on an arc: every HEAD_STEP degrees of it, as the camera will follow.
	var space := get_world_3d().direct_space_state
	var start: Vector3 = _leaned(kind, forward, 0.0)["eye"]
	var steps: int = maxi(1, ceili(degrees / HEAD_STEP))
	for step: int in range(1, steps + 1):
		var to: Vector3 = _leaned(kind, forward, degrees * step / steps)["eye"]
		if start.distance_to(to) < 0.01:
			continue
		var query := PhysicsRayQueryParameters3D.create(start, to + (to - start).normalized() * CAMERA_CLEAR, 1)
		if player is CollisionObject3D:
			query.exclude = [(player as CollisionObject3D).get_rid()]
		if not space.intersect_ray(query).is_empty():
			return false
	return true


const HEAD_STEP: float = 20.0


## The first lean found for `goal` with each of `extras` in turn, else INF.
func _first_lean(kind: StringName, goal: Vector3, extras: Array[float]) -> float:
	for extra: float in extras:
		var lean: float = _lean_for(kind, goal, extra, _lean_limit(kind))
		if is_finite(lean):
			return lean
	return INF


## T-241: plan this action's reach for `goal` with `grip`, the way _reach says (`slack` metres less
## than the bare reach where it can): how far the body leans, whether it goes up on its toes, and
## whether the hand takes the thing at the palm or the fingertips.
func _plan(goal: Vector3, grip: HandTarget.Grip, slack: float) -> void:
	var kind: StringName = _kind()
	var tips: float = finger_reach if grip != HandTarget.Grip.GRIP else 0.0
	var forward: Vector3 = _toward(goal)
	_lean_forward = (global_basis.inverse() * forward).normalized()
	_bend.axis = (skeleton.global_basis.inverse() * Vector3.UP.cross(forward).normalized()).normalized()
	_high = kind == &"up"
	_tip_extra = 0.0
	_rise_target = 0.0
	_pole.position = _pole_rest
	var lean: float = INF
	if kind == &"near":
		# The palm on it when a lean brings it there. Above the arm: up on the toes, no lean (T-227).
		# Else a pinch or hook takes it out at the fingertips.
		if not _overhead(goal):
			lean = _first_lean(kind, goal, [-slack, 0.0])
		if is_inf(lean):
			if goal.y > _standing_shoulder().y and _rise_for(goal, grip) <= TIPTOE:
				_high = true
			elif tips > 0.0:
				_tip_extra = tips
				lean = _first_lean(kind, goal, [tips - slack, tips])
	elif not _high:
		# Bending down, or from the player's crouch: a pinch or hook out at the fingertips.
		_tip_extra = tips
		lean = _first_lean(kind, goal, [tips - slack, tips])
	if _high:
		# The elbow out to the side and up; over something low the chest leans in first (D-152).
		_tip_extra = tips
		_bend_degrees = _up_lean(goal, grip) if kind == &"up" else 0.0
		_rise_target = minf(_rise_from(_leaned_shoulder(goal, _bend_degrees), goal, grip), TIPTOE)
		_pole.position = Vector3(_pole_rest.x * 1.5, _shoulder_model_height(), -_pole_rest.z * 0.5)
	else:
		_bend_degrees = lean if is_finite(lean) else _lean_limit(kind)


## The standing lean (degrees) that brings the shoulder within the palm's reach of `goal`, or INF
## if even MAX_BEND does not.
func _bend_for(goal: Vector3) -> float:
	return _lean_for(&"near", goal, 0.0, MAX_BEND)


## D-152: the measured pose the player's stance reaches from.
func _stance() -> StringName:
	return &"crouch_idle" if is_instance_valid(player) and bool(player.get("crouched")) else &"idle"


## What is this far over the shoulder is reached up for (the arm and the toes, T-227; D-152's lean
## on the toes): folding at the hips takes the shoulder down and away from it. Unchanged by T-241.
const OVERHEAD: float = 0.2


func _overhead(goal: Vector3) -> bool:
	return goal.y > _standing_shoulder().y + OVERHEAD


## The right shoulder joint of the standing pose, world space.
func _standing_shoulder() -> Vector3:
	var joints: Dictionary = _lean_joints.get(&"idle", {})
	return model.global_transform * (joints["shoulder"] as Vector3) if not joints.is_empty() else _bone_world("RightUpperArm")


## How `marker` is reached (T-241): &"near" standing (folding at the hips, or straight up on the
## toes), &"up" on the toes leaning over something low, &"stoop" bending down to something low,
## &"kneel" from the player's own crouch, or &"" out of reach.
func _reach_kind(marker: HandTarget) -> StringName:
	var drawn: float = _yaw
	if not acting:
		_place_model(0.0)
	var kind: StringName = _judge_reach(marker)
	if not acting:
		_place_model(drawn)
	return kind


func _judge_reach(marker: HandTarget) -> StringName:
	# T-241: a sheet standing in its frame cannot be drawn in by the fingertips as one lying on a
	# desk is (_pull): the pinch itself has to get to it. (What is reached up for: as before.)
	if marker.pick_up and not _flat(marker.global_transform.orthonormalized()) and not _overhead(marker.global_position):
		return _judge_goal(_pinch_palm(marker), HandTarget.Grip.GRIP)
	return _judge_goal(marker.global_position, marker.grip)


## T-241: by how high the goal is over the feet, not by what the thing is. Crouched (the player's
## own doing) every reach leans from the crouch; standing, what is lower than STOOP_BELOW is bent
## down to, the rest is taken standing or up on the toes. The body never crouches by itself.
func _judge_goal(goal: Vector3, grip: HandTarget.Grip) -> StringName:
	var kinds: Array[StringName] = [&"near", &"up"]
	if _stance() == &"crouch_idle":
		kinds = [&"kneel"]
	elif goal.y - global_position.y < STOOP_BELOW:
		kinds = [&"stoop"]
	for kind: StringName in kinds:
		if _reaches(kind, goal, grip):
			return kind
	return &""


## A reach of `kind` gets the hand (the palm for a grip, the fingertips for a pinch or hook) to `goal`.
func _reaches(kind: StringName, goal: Vector3, grip: HandTarget.Grip) -> bool:
	var extra: float = finger_reach if grip != HandTarget.Grip.GRIP else 0.0
	match kind:
		&"near":
			if _overhead(goal):
				return _rise_for(goal, grip) <= TIPTOE
			return is_finite(_lean_for(kind, goal, extra, MAX_BEND)) or _rise_for(goal, grip) <= TIPTOE
		&"up":
			# Only what is above the shoulder: lower down a standing lean already reaches further.
			return goal.y > _standing_shoulder().y and _up_lean(goal, grip) <= HIGH_LEAN
		&"stoop", &"kneel":
			return is_finite(_lean_for(kind, goal, extra, _lean_limit(kind)))
	return false


## T-239: the palm's middle in the pinch on a paper's HandTarget (HandShapes: over a flat sheet, or
## below the edge of a standing one, as it is read). The body plans its lean for it when it can get
## the palm there (perform); the prompt still judges the reach by the marker (D-152).
func _pinch_palm(marker: HandTarget) -> Vector3:
	var hand: Transform3D = _pinch_hand(marker.global_transform.orthonormalized())
	return hand.origin + hand.basis.y.normalized() * PALM * _scale()


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
		# T-241: what the lean from the hips is planned on.
		_lean_joints[pose] = _read_joints()
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
	_lean_now = _bend_degrees * weight
	var kind: StringName = _kind()
	var parts: PackedFloat32Array = _lean_parts(kind, _lean_now)
	var forward: Vector3 = (global_basis * _lean_forward).normalized()
	_bend.degrees = _lean_now
	_bend.hip_degrees = parts[0]
	_bend.spine_degrees = parts[1]
	_bend.twist_degrees = parts[2]
	_bend.neck_degrees = parts[3]
	_bend.shift = skeleton.global_basis.inverse() * (-forward * parts[4] + Vector3.DOWN * parts[5])
	# Standing and bending down the free arm hangs from its shoulder; it does not tip up behind.
	_bend.arm_hangs = kind == &"near" or kind == &"stoop"
	_bend.arm_degrees = parts[6]
	# The working hand opens as the reach clips had it (not up on the toes or from a crouch: those
	# always stood on a clip of their own).
	_reach_fingers.influence = weight if _bend.arm_hangs and not _high and not _reach_fingers.to_shape.is_empty() and _carry_weight <= 0.0 else 0.0
	_rise = _rise_target * weight
	model.position.y = _rise
	_tiptoe.rise = (skeleton.global_basis.inverse() * Vector3(0.0, _rise, 0.0)).length()
	_raise.degrees = SHOULDER_RAISE * weight if _high else 0.0


## The right shoulder's height in the model's own space (where the elbow pole lives).
func _shoulder_model_height() -> float:
	var rest: Transform3D = skeleton.get_bone_global_rest(skeleton.find_bone("RightUpperArm"))
	return (model.global_transform.affine_inverse() * skeleton.global_transform * rest).origin.y


func _contact() -> void:
	if not is_instance_valid(_marker.lever):
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


## D-151: a hand action stops where it is (a carried paper goes back to its place) and the body
## hides, so the death camera (PlayerDeath) moves alone; the head keeps no lean or neck offset of ours.
func _on_death_started(_kind: StringName) -> void:
	if _dead or not is_instance_valid(player):
		return
	if acting:
		_finish()
	release_item()
	_end_swing()
	if is_instance_valid(_bar):
		_bar.visible = false
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
	if is_instance_valid(_marker) and _marker.pick_up:
		# T-239: from the reading hold to the pinch it is set down with.
		_held_from = _ortho(HandShapes.SHEET_IN_HAND_READ)
		_held_to = _set_down_hold()
		_held_blend = 0.0


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
	_fingers.influence = 0.0
	_attach_pending = false
	_held_paper = false
	_land_weight = 0.0
	_bend_degrees = 0.0
	_rise_target = 0.0
	_high = false
	_tip_extra = 0.0
	_weigh(0.0)
	_pace = 1.0
	_pole.position = _pole_rest
	_shape_arm(false)
	_door = false
	_closing = false
	_shove = false
	_rub = false
	_bar_reach = false
	_bar_taking = false
	_set_twist(0.0)
	_bend.shift = Vector3.ZERO
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
	# T-243: the fist that carries something stays up this frame too (no drop to the side and back).
	_tick_carry(0.0)
	_tick_bar(0.0)
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
		# T-245: the view mesh is the player's own camera's alone.
		mesh.layers = 1 << (VIEW_LAYER - 1)
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
	# T-241: the lean folds at the hips and keeps the feet planted (after the toes, before the arm).
	_bend = BodyLeanModifier.new()
	_bend.name = "BodyLean"
	_bend.up = _tiptoe.up
	skeleton.add_child(_bend)
	# Standing with the view turned past the feet, the chest turns part of the way (about up).
	_twist = SpineBendModifier.new()
	_twist.name = "SpineTwist"
	_twist.axis = _tiptoe.up
	skeleton.add_child(_twist)
	# T-249: the chest about the back's own line (looking back on the run, the bar's swing), and the
	# breath of a runner who is spent.
	_torso = TorsoTurnModifier.new()
	_torso.name = "TorsoTurn"
	skeleton.add_child(_torso)
	_breath = BreathModifier.new()
	_breath.name = "Breath"
	_breath.up = _tiptoe.up
	skeleton.add_child(_breath)
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
	# T-241: under the curl, the fingers the reach clips held (the body now stands on its idle,
	# whose hands are closed: curled on top of that the hand pressed a switch as a fist).
	_reach_fingers = FingerPoseModifier.new()
	_reach_fingers.name = "RightReachFingers"
	_reach_fingers.side = &"Right"
	skeleton.add_child(_reach_fingers)
	_reach_fingers.influence = 0.0
	_grip = HandGripModifier.new()
	_grip.name = "RightGrip"
	_grip.bones = GRIP_BONES
	skeleton.add_child(_grip)
	_grip.influence = 0.0
	# T-239: after the curl, a whole hand shape (thumb included) for what is held by a shaped grip.
	_fingers = FingerPoseModifier.new()
	_fingers.name = "RightFingers"
	_fingers.side = &"Right"
	skeleton.add_child(_fingers)
	_fingers.influence = 0.0
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
	_left_pole.position = LEFT_POLE_REST
	_left_ik = TwoBoneIK3D.new()
	_left_ik.name = "LeftArmIK"
	skeleton.add_child(_left_ik)
	_left_ik.setting_count = 1
	_left_ik.set_root_bone_name(0, "LeftUpperArm")
	_left_ik.set_middle_bone_name(0, "LeftLowerArm")
	_left_ik.set_end_bone_name(0, "LeftHand")
	_left_ik.set_target_node(0, _left_ik.get_path_to(_left_goal))
	_left_ik.set_pole_node(0, _left_ik.get_path_to(_left_pole))
	# T-239: only the phone uses this arm; it is always turned to face its pole (see _place_pole).
	_left_ik.set_pole_direction(0, SkeletonModifier3D.SECONDARY_DIRECTION_MINUS_Z)
	_left_ik.influence = 0.0
	_left_align = HandAlignModifier.new()
	_left_align.name = "LeftHandAlign"
	_left_align.bone = &"LeftHand"
	_left_align.forearm_share = FOREARM_SHARE
	skeleton.add_child(_left_align)
	_left_align.influence = 0.0
	# T-239: the phone's own hand shape (HandShapes.PHONE), not a curl on top of the clip.
	_left_fingers = FingerPoseModifier.new()
	_left_fingers.name = "LeftFingers"
	_left_fingers.side = &"Left"
	skeleton.add_child(_left_fingers)
	_left_fingers.hold(HandShapes.PHONE)
	_left_fingers.influence = 0.0
	_left_attach = BoneAttachment3D.new()
	_left_attach.name = "LeftHandAttach"
	_left_attach.bone_name = "LeftHand"
	skeleton.add_child(_left_attach)
	_build_mirror_arm()
	skeleton.skeleton_updated.connect(_on_skeleton_updated)


## T-245 (D-163): the left arm a mirror shows. Copies of the arm's bones (shoulder joint to
## fingertips) carry the mirror mesh's left arm; they follow the originals (MirrorArmModifier), and
## while the phone is held an IK of their own holds it by the body (_tick_mirror_arm).
func _build_mirror_arm() -> void:
	var root: int = skeleton.find_bone(MIRROR_ARM_ROOT)
	if root < 0:
		return
	var copies: Dictionary = {}
	var pairs := PackedInt32Array()
	var queue: Array[int] = [root]
	while not queue.is_empty():
		var bone: int = queue.pop_front()
		var copy: int = skeleton.add_bone(MIRROR_BONE + skeleton.get_bone_name(bone))
		var parent: int = skeleton.get_bone_parent(bone)
		skeleton.set_bone_parent(copy, copies.get(parent, parent))
		skeleton.set_bone_rest(copy, skeleton.get_bone_rest(bone))
		skeleton.set_bone_pose(copy, skeleton.get_bone_pose(bone))
		copies[bone] = copy
		pairs.append(bone)
		pairs.append(copy)
		for child: int in skeleton.get_bone_children(bone):
			queue.append(child)
	for mirror: MeshInstance3D in mirror_meshes:
		if mirror.skin == null:
			continue
		var skin := mirror.skin.duplicate() as Skin
		for bind: int in skin.get_bind_count():
			var bind_name: StringName = skin.get_bind_name(bind)
			var bone: int = skeleton.find_bone(bind_name) if bind_name != &"" else skin.get_bind_bone(bind)
			if not copies.has(bone):
				continue
			if bind_name != &"":
				skin.set_bind_name(bind, MIRROR_BONE + String(bind_name))
			else:
				skin.set_bind_bone(bind, copies[bone])
		mirror.skin = skin
	var follow := MirrorArmModifier.new()
	follow.name = "MirrorArmFollow"
	follow.pairs = pairs
	skeleton.add_child(follow)
	_mirror_goal = Node3D.new()
	_mirror_goal.name = "MirrorHandGoal"
	_mirror_goal.top_level = true
	add_child(_mirror_goal)
	_mirror_pole = Node3D.new()
	_mirror_pole.name = "MirrorElbowPole"
	_mirror_pole.top_level = true
	add_child(_mirror_pole)
	_mirror_ik = TwoBoneIK3D.new()
	_mirror_ik.name = "MirrorArmIK"
	skeleton.add_child(_mirror_ik)
	_mirror_ik.setting_count = 1
	_mirror_ik.set_root_bone_name(0, MIRROR_BONE + "LeftUpperArm")
	_mirror_ik.set_middle_bone_name(0, MIRROR_BONE + "LeftLowerArm")
	_mirror_ik.set_end_bone_name(0, MIRROR_BONE + "LeftHand")
	_mirror_ik.set_target_node(0, _mirror_ik.get_path_to(_mirror_goal))
	_mirror_ik.set_pole_node(0, _mirror_ik.get_path_to(_mirror_pole))
	_mirror_ik.set_pole_direction(0, SkeletonModifier3D.SECONDARY_DIRECTION_MINUS_Z)
	_mirror_ik.influence = 0.0
	_mirror_align = HandAlignModifier.new()
	_mirror_align.name = "MirrorHandAlign"
	_mirror_align.bone = StringName(MIRROR_BONE + "LeftHand")
	_mirror_align.forearm_share = FOREARM_SHARE
	skeleton.add_child(_mirror_align)
	_mirror_align.influence = 0.0


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


# --- T-243 (D-161, D-162): chapter 2's hand things ---------------------------------------------

## What the right hand carries between actions (a CarryItem: the rag, towel or shirt), its look in
## the hand (a copy of the thing's model, hanging from the fist) and how far the hand has come to
## the carrying pose.
var _held_item: Node3D = null
var _held_visual: Node3D = null
var _carry_weight: float = 0.0
## The carrying hand: the palm's middle this far in front of the hips, to the right and up (model
## space, metres at the model's scale: the model faces +Z, its right is -X).
const CARRY_PALM: Vector3 = Vector3(-0.17, 1.06, 0.36)
## The fist's curl on what it carries, and how fast the hand comes to (and leaves) the pose.
const CARRY_CURL: float = 80.0
const CARRY_FADE: float = 0.25
## The copy of what is carried hangs this far under the fist's middle (metres).
const CARRY_HANG: float = 0.03

## Round 4's swollen door (StuckDoor): a shove of the right shoulder into the leaf. The body winds
## back, drives in until SHOVE_HIT (the door counts the shove there), holds and comes back.
const SHOVE_SECONDS: float = 0.8
const SHOVE_HIT: float = 0.34
const SHOVE_LEAN: float = 22.0
## The chest turns this far so the right shoulder leads (degrees); the hips go this far ahead of the
## feet; and the whole body lunges at most this far toward the door (metres): as far as brings the
## shoulder to the leaf, the body never into it.
const SHOVE_TWIST: float = 42.0
const SHOVE_HIPS: float = 0.08
const SHOVE_LUNGE: float = 0.4
## The body's middle stays this far off the door's plane (its radius and a little).
const SHOVE_CLEAR: float = 0.33
## The shoulder stops this far short of the door's plane (half the arm's thickness).
const SHOVE_SHORT: float = 0.06
var _shove: bool = false
var _shove_hit: bool = false
var _shove_drive: float = 0.0
var _shove_from: Vector3 = Vector3.ZERO

## Wiping the steamed shower screen (ShowerScreen): the palm flat on it, rubbing round while E is
## held, until the screen is wiped or E is let go.
const RUB_RADIUS: float = 0.05
const RUB_TURNS_PER_SECOND: float = 1.6
const RUB_CURL: float = 8.0
var _rub: bool = false
var _rub_time: float = 0.0


## T-243: true while the right hand carries `item` (CarryItem asks before it follows the camera).
func holds(item: Node3D) -> bool:
	return is_instance_valid(_held_item) and _held_item == item


## T-243: the hand has taken `item` (CarryItem.interact, at the touch of a hand action). `look`: the
## model the item shows as (its own placeholder is hidden while the hand has it).
func take_item(item: Node3D, look: Node3D = null) -> void:
	release_item()
	_held_item = item
	_held_visual = Node3D.new()
	_held_visual.name = "HeldItem"
	_held_visual.top_level = true
	add_child(_held_visual)
	var source: Node3D = look if is_instance_valid(look) else item
	var copies: Array[MeshInstance3D] = []
	for mesh: MeshInstance3D in source.find_children("*", "MeshInstance3D", true, false):
		# Not what the shell hid for good (a PS1 stand-in under the model).
		if mesh.mesh == null or not mesh.visible:
			continue
		var copy := mesh.duplicate(0) as MeshInstance3D
		copy.visible = true
		_held_visual.add_child(copy)
		copy.transform = source.global_transform.affine_inverse() * mesh.global_transform
		copies.append(copy)
	if source is MeshInstance3D and (source as MeshInstance3D).mesh != null:
		var copy := (source as MeshInstance3D).duplicate(0) as MeshInstance3D
		_held_visual.add_child(copy)
		copy.transform = Transform3D.IDENTITY
		copies.append(copy)
	# Hung from the fist: the top middle of what it looks like at the hand.
	var box := _bounds(copies)
	var first: bool = copies.is_empty()
	# A cloth lying folded flat (a rag over a bar, a shirt on a shelf) hangs down from the fist,
	# not held out flat like a tray.
	if not first and box.size.y < 0.35 * maxf(box.size.x, box.size.z):
		var down := Basis(Vector3.RIGHT, -PI / 2.0) if box.size.z >= box.size.x else Basis(Vector3.BACK, PI / 2.0)
		for copy: MeshInstance3D in copies:
			copy.transform = Transform3D(down, Vector3.ZERO) * copy.transform
		box = _bounds(copies)
	_held_hang = Vector3(box.get_center().x, box.end.y, box.get_center().z) if not first else Vector3.ZERO
	_held_turn = Basis.from_euler(Vector3(0.0, source.global_rotation.y - model.global_rotation.y, 0.0))
	_hide_placeholder(item)


var _held_hang: Vector3 = Vector3.ZERO


static func _bounds(meshes: Array[MeshInstance3D]) -> AABB:
	var box := AABB()
	var first: bool = true
	for mesh: MeshInstance3D in meshes:
		var bounds: AABB = mesh.transform * mesh.get_aabb()
		box = bounds if first else box.merge(bounds)
		first = false
	return box
var _held_turn: Basis = Basis.IDENTITY


## The hand lets go of what it carries (dropped, swapped for another, or pressed into a mouth).
func release_item() -> void:
	if is_instance_valid(_held_visual):
		_held_visual.queue_free()
	_held_visual = null
	_held_item = null


## The carried item is still the player's (not consumed, not dropped).
func _still_held() -> bool:
	if not is_instance_valid(_held_item) or not _held_item.is_visible_in_tree():
		return false
	if bool(_held_item.get("consumed")):
		return false
	return _held_item.get("holder") == player


static func _hide_placeholder(item: Node3D) -> void:
	var placeholder := item.get_node_or_null("Placeholder") as Node3D
	if placeholder != null:
		placeholder.visible = false


## Where the carrying hand's palm goes (world) and how it lies: the fingers down and forward, the
## palm turned in, in front of the right hip.
func _carry_palm() -> Vector3:
	return model.global_transform * CARRY_PALM


func _carry_basis() -> Basis:
	var forward: Vector3 = model.global_basis.z.normalized()
	var inward: Vector3 = model.global_basis.x.normalized()
	return _hand_basis(forward * 0.55 + Vector3.DOWN * 0.85, inward)


## Between actions: the right hand comes up to the carrying pose and holds it while he walks.
func _tick_carry(delta: float) -> void:
	if is_instance_valid(_held_item) and not _still_held():
		release_item()
	var holding: bool = is_instance_valid(_held_item) and visible
	_carry_weight = move_toward(_carry_weight, 1.0 if holding else 0.0, delta / CARRY_FADE)
	if acting:
		return
	if _carry_weight <= 0.0:
		_ik.influence = 0.0
		_align.influence = 0.0
		_grip.influence = 0.0
		return
	var basis: Basis = _natural_basis().slerp(_carry_basis(), _carry_weight)
	_aim(_natural_tip().lerp(_carry_palm(), _carry_weight), basis, 0.0)
	_ik.influence = _carry_weight
	_align.influence = _carry_weight
	_grip.curl_degrees = CARRY_CURL
	_grip.influence = _carry_weight


## The carried item in the fist as drawn this frame.
func _place_held() -> void:
	if not is_instance_valid(_held_visual) or not is_instance_valid(_held_item):
		return
	_hide_placeholder(_held_item)
	var hand: Transform3D = _ortho(_posed_bone("RightHand"))
	var palm: Vector3 = hand.origin + hand.basis.y.normalized() * PALM * _scale()
	var turn: Basis = (model.global_basis.orthonormalized() * _held_turn).orthonormalized()
	_held_visual.global_transform = Transform3D(turn, palm + Vector3.DOWN * CARRY_HANG - turn * _held_hang)


## A shove into round 4's swollen door, instead of a reach for its handle.
func _start_shove(target: Interactable) -> void:
	_shove = true
	_shove_hit = false
	_reach = &"near"
	# The leaf where its handle is (the StuckDoor box sits on the hinge's node).
	var door: Vector3 = _marker.global_position if is_instance_valid(_marker) else target.global_position
	var toward: Vector3 = _toward(door)
	_lean_forward = (global_basis.inverse() * toward).normalized()
	_bend.axis = (skeleton.global_basis.inverse() * Vector3.UP.cross(toward).normalized()).normalized()
	_bend_degrees = SHOVE_LEAN
	# How far the hips go: as far as brings the leaned right shoulder to the door's face.
	var shoulder: Vector3 = _leaned(&"near", toward, SHOVE_LEAN)["shoulder"]
	var face: Vector3 = (target.get_parent() as Node3D).global_basis.z.normalized() if target.get_parent() is Node3D else target.global_basis.z.normalized()
	face.y = 0.0
	face = face.normalized() if face.length() > 0.01 else -toward
	var short: float = absf((door - shoulder).dot(face)) - SHOVE_SHORT - SHOVE_HIPS
	var room: float = absf((door - player.global_position).dot(face)) - SHOVE_CLEAR
	_shove_drive = clampf(minf(short, room), 0.0, SHOVE_LUNGE)
	_shove_from = player.global_position
	_clip = CLIPS[&"idle"]
	_key = &""
	animator.play(_clip, BLEND_SECONDS, 0.0)
	if is_instance_valid(player) and player.has_method("acquire_movement_lock"):
		player.acquire_movement_lock(self)


func _tick_shove(delta: float) -> void:
	_time += delta
	# Wind back a little, drive in to the hit, lean on it, come back.
	var drive: float
	if _time < 0.12:
		drive = -0.25 * smoothstep(0.0, 0.12, _time)
	elif _time < SHOVE_HIT:
		drive = lerpf(-0.25, 1.0, smoothstep(0.12, SHOVE_HIT, _time))
	elif _time < SHOVE_HIT + 0.08:
		drive = 1.0
	else:
		drive = 1.0 - smoothstep(SHOVE_HIT + 0.08, SHOVE_SECONDS, _time)
	_weigh(maxf(drive, 0.0))
	var forward: Vector3 = (global_basis * _lean_forward).normalized()
	_bend.shift = skeleton.global_basis.inverse() * (forward * SHOVE_HIPS * drive)
	_set_twist(deg_to_rad(SHOVE_TWIST) * maxf(drive, 0.0))
	# The whole body lunges in and back (a step's worth), the camera with it.
	player.global_position = _shove_from + forward * _shove_drive * drive
	if not _shove_hit and _time >= SHOVE_HIT:
		_shove_hit = true
		if is_instance_valid(_target):
			_target.interact(player)
	_follow_head()
	if _time >= SHOVE_SECONDS:
		player.global_position = _shove_from
		_finish()


## The palm flat on the screen, the fingers up.
func _rub_basis() -> Basis:
	var normal: Vector3 = _marker.global_basis.z.normalized()
	return _hand_basis(Vector3.UP - normal * normal.y, -normal)


## While E is held the palm rubs round on the screen; it stops (the hand goes back) once the screen
## is wiped or E is let go.
func _rub_goal() -> Vector3:
	var basis: Basis = _marker.global_basis.orthonormalized()
	var angle: float = TAU * RUB_TURNS_PER_SECOND * _rub_time
	return _marker.global_position + (basis.x * cos(angle) + basis.y * sin(angle)) * RUB_RADIUS


func _rubbing() -> bool:
	if not is_instance_valid(_target) or bool(_target.get("_completed")):
		return false
	return Input.is_action_pressed("interact")


# --- T-249 (D-165): chapter 3. The iron bar, looking back on the run, out of breath -------------

## Running with the view turned back: past this far round (radians) the body turns back the other,
## shorter way; of what the heading is past MAX_YAW the chest turns back this share, at most
## BACK_CHEST degrees (about the back's own line), and the neck and head this much more.
const BACK_ROUND: float = deg_to_rad(215.0)
const BACK_CHEST_SHARE: float = 0.4
const BACK_CHEST: float = 38.0
const BACK_HEAD_SHARE: float = 0.3
const BACK_HEAD: float = 25.0
var _back_side: float = 0.0
var _look_chest: float = 0.0
var _look_head: float = 0.0
var _torso: TorsoTurnModifier
var _breath: BreathModifier

## Out of breath (the player's `exhausted`): breaths a second, how fast the heaving comes on and how
## slowly it dies away (seconds).
const BREATH_RATE: float = 1.25
const BREATH_ON: float = 0.5
const BREATH_OFF: float = 3.0
var _breath_amount: float = 0.0
var _breath_phase: float = 0.0

## The bar in the right fist. At the ready: the fist's middle here (model space, metres at the
## model's scale: the model faces +Z, its right is -X), the bar rising BAR_READY[1] degrees ahead and
## turned BAR_READY[2] degrees in toward the body's middle. The hand comes to it over BAR_FADE.
const BAR_READY: Array = [Vector3(-0.2, 1.0, 0.3), 26.0, 12.0]
const BAR_FADE: float = 0.2
## The swing, over the weapon's swing_seconds (shares of it): [share, fist, degrees up, degrees in,
## chest turn (degrees, + to the left)]. Wound up over the right shoulder, across at head height
## ahead (the blow lands at BAR_BLOW: the bar crosses where the view aims, as the hit is judged), on
## down to the left, held a moment, back to the ready.
const BAR_SWING: Array = [
	[0.0, Vector3(-0.2, 1.0, 0.3), 26.0, 12.0, 0.0],
	[0.22, Vector3(-0.25, 1.45, 0.08), 112.0, -8.0, -22.0],
	[0.46, Vector3(-0.04, 1.36, 0.4), 22.0, 24.0, 16.0],
	[0.62, Vector3(0.1, 0.98, 0.38), -20.0, 46.0, 30.0],
	[0.72, Vector3(0.1, 0.98, 0.37), -20.0, 46.0, 30.0],
	[1.0, Vector3(-0.2, 1.0, 0.3), 26.0, 12.0, 0.0],
]
const BAR_BLOW: float = 0.46
## A bar taken off the ground rolls from the fingertips into the fist over this long (seconds).
const BAR_CLOSE: float = 0.25
var _bar: Node3D
var _bar_weight: float = 0.0
var _bar_hits: int = -1
var _bar_swing_time: float = 0.0
var _bar_swing_len: float = 0.0
var _bar_break: bool = false
var _swing_chest: float = 0.0
## Taking a bar off the ground: the reach is for one (an empty hand), where its grip lies (the bar's
## frame at the fist, world), the fist is closing on it, and how it lay in the hand at the touch.
var _bar_reach: bool = false
var _bar_goal: Transform3D = Transform3D.IDENTITY
var _bar_taking: bool = false
var _bar_take_time: float = 0.0
var _bar_attach: bool = false
var _bar_take_rel: Transform3D = Transform3D.IDENTITY


func _bar_weapon() -> IronBarWeapon:
	var weapon: Variant = player.get("bar_weapon") if is_instance_valid(player) else null
	return weapon as IronBarWeapon if weapon is IronBarWeapon and is_instance_valid(weapon) else null


## The right hand has a bar (one with hits left).
func _has_bar() -> bool:
	var weapon := _bar_weapon()
	return weapon != null and weapon.hits_left > 0


func _ensure_bar() -> void:
	if is_instance_valid(_bar):
		return
	_bar = IronBarWeapon.make_model()
	_bar.name = "BarInHand"
	_bar.top_level = true
	_bar.visible = false
	add_child(_bar)
	_bar_hits = -1


## The hand bone (world, unscaled basis) that holds the bar with the fist's middle at `at` (model
## space), the bar rising `up` degrees ahead and turned `inward` degrees toward the body's middle.
func _bar_hand(at: Vector3, up: float, inward: float) -> Transform3D:
	var forward: Vector3 = model.global_basis.z.normalized()
	var left: Vector3 = model.global_basis.x.normalized()
	var rise: float = deg_to_rad(up)
	var turn: float = deg_to_rad(inward)
	var along: Vector3 = ((forward * cos(turn) + left * sin(turn)) * cos(rise) + Vector3.UP * sin(rise)).normalized()
	# The palm faces in: out of it is to the left of the bar's line.
	var out: Vector3 = left * cos(turn) - forward * sin(turn)
	out = (out - along * out.dot(along)).normalized()
	var fist := Transform3D(Basis(out, along.cross(out), along), model.global_transform * at)
	return _hand_for(fist, _ortho(BarHand.BAR_IN_FIST))


func _bar_ready() -> Transform3D:
	return _bar_hand(BAR_READY[0], BAR_READY[1], BAR_READY[2])


## The hook on the bar being taken (the hand bone, world).
func _bar_hook() -> Transform3D:
	return _hand_for(_bar_goal, _ortho(BarHand.BAR_IN_HOOK))


## T-249: the weapon swung (IronBarWeapon.swing, which has already judged the blow): the arm swings
## the bar over `seconds`; `broke`: that was its last blow, the pieces fall when it lands.
func swing_bar(seconds: float, broke: bool = false) -> void:
	if _dead or acting:
		return
	_ensure_bar()
	_bar_swing_len = maxf(seconds, 0.05)
	_bar_swing_time = 0.0
	_bar_break = broke


## A swing stops where it is (a hand action begins, death): a bar that broke falls now.
func _end_swing() -> void:
	if _bar_break:
		_break_bar()
	_bar_swing_len = 0.0
	_bar_swing_time = 0.0
	_swing_chest = 0.0


## The swing's pose `share` of the way through: [hand bone (world), chest turn (degrees)].
func _swing_pose(share: float) -> Array:
	var before: Array = BAR_SWING[0]
	var after: Array = BAR_SWING[BAR_SWING.size() - 1]
	for index: int in range(1, BAR_SWING.size()):
		if share <= float(BAR_SWING[index][0]):
			before = BAR_SWING[index - 1]
			after = BAR_SWING[index]
			break
	var span: float = float(after[0]) - float(before[0])
	var t: float = smoothstep(0.0, 1.0, (share - float(before[0])) / span) if span > 0.0 else 1.0
	return [_bar_hand((before[1] as Vector3).lerp(after[1], t), lerpf(before[2], after[2], t), lerpf(before[3], after[3], t)),
			lerpf(before[4], after[4], t)]


## The last blow broke the bar: its two pieces fall from the hand and lie where they land.
func _break_bar() -> void:
	_bar_break = false
	if not is_instance_valid(_bar) or not is_instance_valid(player) or player.get_parent() == null:
		return
	IronBarWeapon.bend(_bar, IronBarWeapon.BEND_MAX)
	var ahead: Vector3 = -player.global_basis.z.normalized()
	var side: Vector3 = player.global_basis.x.normalized()
	var index: int = 0
	for half: Node3D in IronBarWeapon.halves(_bar):
		var piece := half.duplicate() as Node3D
		var length: float = 0.4
		var mesh := piece as MeshInstance3D
		if mesh != null and mesh.mesh != null:
			length = mesh.mesh.get_aabb().get_longest_axis_size()
		# The piece in the fist drops, the far one flies on ahead.
		var velocity: Vector3 = ahead * (0.6 if index == 0 else 2.6) + Vector3.UP * (0.2 if index == 0 else 1.2) - side * 0.5 * index
		IronBarWeapon.drop(piece, half.global_transform, player.get_parent(), velocity + player.velocity,
				side * (3.0 if index == 0 else -9.0), length)
		index += 1
	_bar.visible = false
	_bar_hits = -1


## The weapon has a (fresh) bar: at the touch of a reach for one it comes into the hook that took it.
func _on_bar_picked(_hits: int) -> void:
	if _dead or not is_instance_valid(player) or not _has_bar():
		return
	_ensure_bar()
	if acting and _bar_reach and not _bar_taking:
		_bar_taking = true
		_bar_take_time = 0.0
		_bar_attach = true
		_bar.global_transform = _bar_goal * Transform3D(Basis.IDENTITY, Vector3(0.0, 0.0, -IronBarWeapon.GRIP_Z))
		_bar.visible = visible


## Every frame: the bar the hand holds (shown, worn), the hand at the ready or swinging it, the fist.
func _tick_bar(delta: float) -> void:
	var weapon := _bar_weapon()
	var hits: int = weapon.hits_left if weapon != null else 0
	var has: bool = (hits > 0 or _bar_break) and visible and not _dead
	if has:
		_ensure_bar()
	if is_instance_valid(_bar):
		_bar.visible = has
		if hits > 0 and hits != _bar_hits:
			IronBarWeapon.bend(_bar, IronBarWeapon.wear(hits, weapon.max_hits))
			_bar_hits = hits
	_bar_weight = move_toward(_bar_weight, 1.0 if has else 0.0, delta / BAR_FADE)
	if _bar_taking:
		_bar_take_time += delta
	# The swing's clock runs with the weapon's.
	var swinging: bool = _bar_swing_len > 0.0
	var share: float = 0.0
	if swinging:
		_bar_swing_time += delta
		share = _bar_swing_time / _bar_swing_len
		if _bar_break and share >= BAR_BLOW:
			_break_bar()
		if share >= 1.0:
			swinging = false
			_bar_swing_len = 0.0
	var pose: Array = _swing_pose(share) if swinging else [Transform3D.IDENTITY, 0.0]
	_swing_chest = float(pose[1]) * _bar_weight
	_torso.chest_degrees = _look_chest + _swing_chest
	# The head stays where it looked while the chest swings under it.
	_torso.head_degrees = _look_head - _swing_chest
	if _bar_weight <= 0.0:
		return
	# The fist round the bar (closing on one just taken), whatever else the hand does.
	if _bar_taking:
		_fingers.morph(BarHand.HOOK, BarHand.FIST, smoothstep(0.0, BAR_CLOSE, _bar_take_time))
		_fingers.influence = 1.0
	elif not (acting and _bar_reach):
		_fingers.hold(BarHand.FIST)
		_fingers.influence = _bar_weight
	if acting:
		return
	var hand: Transform3D = pose[0] if swinging else _bar_ready()
	_align.target_basis = _natural_basis().slerp(hand.basis, _bar_weight)
	_goal.global_position = _natural_wrist().lerp(hand.origin, _bar_weight)
	_ik.influence = _bar_weight
	_align.influence = _bar_weight
	_grip.influence = 0.0


## The bar in the fist as drawn this frame.
func _place_bar() -> void:
	if not is_instance_valid(_bar) or not _bar.visible:
		return
	var hand: Transform3D = _posed_bone("RightHand")
	var held: Transform3D = _ortho(BarHand.BAR_IN_FIST)
	if _bar_taking:
		if _bar_attach:
			# As it lay in the hand at the touch.
			_bar_take_rel = _relation(Transform3D(hand.basis.orthonormalized(), hand.origin), _bar_goal)
			_bar_attach = false
		held = _bar_take_rel.interpolate_with(held, smoothstep(0.0, BAR_CLOSE, _bar_take_time))
	var fist: Transform3D = _held_world(hand, held)
	_bar.global_transform = fist * Transform3D(Basis.IDENTITY, Vector3(0.0, 0.0, -IronBarWeapon.GRIP_Z))


func _tick_breath(delta: float) -> void:
	# A stand-in player (tests) may have no stamina at all.
	var spent: bool = visible and not _in_bed and player.get("exhausted") == true
	_breath_amount = move_toward(_breath_amount, 1.0 if spent else 0.0, delta / (BREATH_ON if spent else BREATH_OFF))
	if _breath_amount <= 0.0:
		_breath_phase = 0.0
		_breath.lift = 0.0
		return
	_breath_phase = fmod(_breath_phase + delta * BREATH_RATE * TAU, TAU)
	_breath.lift = _breath_amount * (0.5 - 0.5 * cos(_breath_phase))
