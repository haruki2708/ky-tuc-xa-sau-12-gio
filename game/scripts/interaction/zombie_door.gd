class_name ZombieDoor
extends Node
## Attach to a wooden door and assign its world collider. Stone/metal is untagged.

signal broken
@export var door: Node3D
@export var blocker: CollisionObject3D
## Zero preserves CH3's per-zombie duration. Core can pin CH4 to 75/90 seconds.
@export var durability_seconds: float = 0.0
var damage_seconds: float = 0.0
var is_broken: bool = false
var _contact_left: float = 0.0
var _required_seconds: float = 10.0
var _reported_fraction: float = -1.0


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_PAUSABLE
	if blocker != null:
		blocker.set_meta(&"zombie_door", self)
	_report_damage()


func is_closed() -> bool:
	return not is_broken and is_instance_valid(door) and door.get("is_open") == false


func bash(delta: float, required_seconds: float = 10.0) -> void:
	if get_tree().paused or not is_closed():
		return
	# Contact is renewed by near or sparse AI. Only this node counts elapsed time.
	_contact_left = maxf(_contact_left, maxf(0.04, delta + 0.04))
	_required_seconds = maxf(0.01, durability_seconds if durability_seconds > 0 else required_seconds)


func _physics_process(delta: float) -> void:
	if get_tree().paused:
		return
	if not is_closed():
		damage_seconds = 0.0
		_contact_left = 0.0
		_report_damage()
		return
	damage_seconds += minf(delta, _contact_left)
	_contact_left = maxf(0, _contact_left - delta)
	_report_damage()
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


func damage_id() -> StringName:
	if not is_instance_valid(door):
		return StringName(name)
	for property: Dictionary in door.get_property_list():
		if property.name == "room" and not str(door.get("room")).is_empty():
			return StringName(str(door.get("room")))
	return StringName(door.name)


func _report_damage() -> void:
	var fraction: float = 1.0 if is_broken else clampf(damage_seconds / _required_seconds, 0.0, 1.0)
	# Endpoints must reach the UI even when the last increment is smaller than 2%.
	if absf(fraction - _reported_fraction) > 0.02 or (fraction != _reported_fraction and fraction in [0.0, 1.0]):
		_reported_fraction = fraction
		EventBus.door_damage_changed.emit(damage_id(), fraction)
