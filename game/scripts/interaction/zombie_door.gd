class_name ZombieDoor
extends Node
## Attach to a wooden door and assign its world collider. Stone/metal is untagged.

signal broken
@export var door: Node3D
@export var blocker: CollisionObject3D
var damage_seconds: float = 0.0
var is_broken: bool = false
var _contact_left: float = 0.0
var _required_seconds: float = 10.0


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_PAUSABLE
	if blocker != null:
		blocker.set_meta(&"zombie_door", self)


func is_closed() -> bool:
	return not is_broken and is_instance_valid(door) and door.get("is_open") == false


func bash(delta: float, required_seconds: float = 10.0) -> void:
	if get_tree().paused or not is_closed():
		return
	# Contact is renewed by near or sparse AI. Only this node counts elapsed time.
	_contact_left = maxf(_contact_left, maxf(0.04, delta + 0.04))
	_required_seconds = maxf(0.01, required_seconds)


func _physics_process(delta: float) -> void:
	if get_tree().paused:
		return
	if not is_closed():
		damage_seconds = 0.0
		_contact_left = 0.0
		return
	damage_seconds += minf(delta, _contact_left)
	_contact_left = maxf(0, _contact_left - delta)
	if damage_seconds < _required_seconds:
		return
	is_broken = true
	if door.has_method("set_open"):
		door.call("set_open", true)
	if door is Interactable:
		door.enabled = false
		door.collision_layer = 0
	if is_instance_valid(blocker):
		blocker.set_deferred("collision_layer", 0)
		blocker.set_deferred("collision_mask", 0)
	broken.emit()
