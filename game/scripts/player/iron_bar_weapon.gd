class_name IronBarWeapon
extends Node3D
## Chapter 3's iron bar: the rules (hits, reach, stamina, the swing's length) and, for a player
## without a body, the bar held up before the camera as it always was.
## T-249 (D-165): the bar is a real length of rusted pipe (iron_bar.glb) that bends at six joints as
## it wears. With Tran Trung's body the right hand holds it (PlayerBody draws a bar of its own in the
## fist, swings it and lets the pieces fall when it breaks); this node then shows nothing.

const MODEL: PackedScene = preload("res://assets/models/graphics_pilot/protagonist/iron_bar.glb")
const LENGTH: float = 0.85
const RADIUS: float = 0.0135
## Where a hand holds it: this far along the bar (its +Z) from its middle; the grip end is at -LENGTH / 2.
const GRIP_Z: float = -0.32
## How far a worn-out bar is bent in all (radians), shared by its JOINTS joints.
const BEND_MAX: float = 0.8
const JOINTS: int = 6
## The pieces of a broken or dropped bar lie about this long before they are cleared away (seconds).
const DEBRIS_SECONDS: float = 45.0

@export var max_hits: int = 8
@export var reach: float = 1.5
@export var stamina_cost: float = 0.08
@export var swing_seconds: float = 0.55
var hits_left: int = 0
var player: CharacterBody3D
var _remaining: float = 0.0
var _model: Node3D


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_PAUSABLE
	position = Vector3(0.28, -0.3, -0.6)
	# Held upright by its grip end (its +Z up), bending toward the left of the view as the boxes did.
	_model = make_model()
	_model.transform = Transform3D(Basis(Vector3(0.0, 0.0, -1.0), Vector3(-1.0, 0.0, 0.0), Vector3(0.0, 1.0, 0.0)),
			Vector3(0.0, LENGTH * 0.5, 0.0))
	add_child(_model)
	hide()


## A bar of its own: the whole one shown, straight; its two broken halves hidden.
static func make_model() -> Node3D:
	var model := MODEL.instantiate() as Node3D
	model.name = "Model"
	for half: Node3D in halves(model):
		half.visible = false
	return model


static func halves(model: Node3D) -> Array[Node3D]:
	var found: Array[Node3D] = []
	for half_name: String in ["HalfGrip", "HalfTip"]:
		var half := model.find_child(half_name, true, false) as Node3D
		if half != null:
			found.append(half)
	return found


## How far a bar with `hits` of `of` left is bent (radians), as the PS1 bar was.
static func wear(hits: int, of: int) -> float:
	return (1.0 - float(hits) / maxf(of, 1)) * BEND_MAX


## Bend `model` `amount` radians in all toward its +Y, each joint a share.
static func bend(model: Node3D, amount: float) -> void:
	var found: Array[Node] = model.find_children("*", "Skeleton3D", true, false)
	if found.is_empty():
		return
	var skeleton := found[0] as Skeleton3D
	skeleton.reset_bone_poses()
	if is_zero_approx(amount):
		return
	var turn := Quaternion(Vector3.RIGHT, -amount / JOINTS)
	for joint: int in range(1, JOINTS + 1):
		var bone: int = skeleton.find_bone("Bar%d" % joint)
		if bone >= 0:
			TiptoeModifier.turn(skeleton, bone, turn)


## A piece of bar let go of: `visual` (a bar model, or a copy of one of its halves; its +Z along its
## length) falls from `at` (world), with `velocity` and `spin`, onto the world's floor, lies there a
## while and is cleared away. It blocks nobody.
static func drop(visual: Node3D, at: Transform3D, into: Node, velocity: Vector3, spin: Vector3, length: float) -> RigidBody3D:
	var piece := RigidBody3D.new()
	piece.name = "BarPiece"
	piece.collision_layer = 0
	piece.collision_mask = 1
	piece.mass = 1.2
	piece.angular_damp = 1.5
	piece.linear_damp = 0.2
	piece.continuous_cd = true
	var material := PhysicsMaterial.new()
	material.friction = 0.9
	material.bounce = 0.15
	piece.physics_material_override = material
	into.add_child(piece)
	piece.global_transform = at.orthonormalized()
	var shape := CollisionShape3D.new()
	var capsule := CapsuleShape3D.new()
	capsule.radius = RADIUS
	capsule.height = maxf(length, RADIUS * 2.0)
	shape.shape = capsule
	# The capsule runs along its Y: the bar along its Z.
	shape.rotation.x = PI / 2.0
	piece.add_child(shape)
	if visual.get_parent() != null:
		visual.get_parent().remove_child(visual)
	visual.top_level = false
	piece.add_child(visual)
	visual.transform = Transform3D.IDENTITY
	visual.visible = true
	piece.linear_velocity = velocity
	piece.angular_velocity = spin
	piece.get_tree().create_timer(DEBRIS_SECONDS, false).timeout.connect(piece.queue_free)
	return piece


## The player's body, when its right hand holds the bar (T-249).
func _hand() -> PlayerBody:
	var body: Variant = player.get("body") if is_instance_valid(player) else null
	return body as PlayerBody if body is PlayerBody and is_instance_valid(body) else null


func give_bar(hits: int = 8) -> void:
	hits_left = clampi(hits, 0, max_hits)
	_remaining = 0.0
	rotation = Vector3.ZERO
	visible = hits_left > 0
	bend(_model, wear(hits_left, max_hits))
	EventBus.bar_picked.emit(hits_left)


func swing() -> bool:
	if hits_left <= 0 or _remaining > 0 or not CarryItem.player_can_use(player) or player.call("is_hidden"):
		return false
	# T-249: a hand that is busy with something else (a hand action of the body's) does not swing.
	var hand := _hand()
	if hand != null and hand.acting:
		return false
	_remaining = swing_seconds
	player.call("spend_stamina", stamina_cost)
	var camera: Camera3D = get_parent() as Camera3D
	var query: PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.create(
		camera.global_position, camera.global_position - camera.global_basis.z * reach, 5, [player.get_rid()])
	query.collide_with_areas = true
	var result: Dictionary = camera.get_world_3d().direct_space_state.intersect_ray(query)
	var hit: bool = false
	if not result.is_empty():
		var collider: Node = result.get("collider") as Node
		var zombie: Zombie = collider.get_meta(&"zombie") as Zombie if collider.has_meta(&"zombie") else null
		if zombie != null:
			hit = true
			hits_left -= 1
			zombie.stun(5.0)
		else:
			var ancestor: Node = collider
			while ancestor != null:
				if ancestor is CampusGuard:
					ancestor.struck()
					break
				ancestor = ancestor.get_parent()
	bend(_model, wear(hits_left, max_hits))
	EventBus.noise_emitted.emit(player.global_position, 10.0, &"bar_swing")
	EventBus.bar_swung.emit(hit, hits_left)
	if hand != null:
		hand.swing_bar(swing_seconds, hits_left == 0)
	if hits_left == 0:
		hide()
		EventBus.bar_broken.emit()
	return true


func _physics_process(delta: float) -> void:
	_remaining = maxf(0, _remaining - delta)
	rotation.x = -sin((1.0 - _remaining / swing_seconds) * PI) * 1.2 if _remaining > 0 else 0.0
	# With a body the hand has the bar (or, hidden or dead, nothing shows): never one before the camera.
	_model.visible = _hand() == null
