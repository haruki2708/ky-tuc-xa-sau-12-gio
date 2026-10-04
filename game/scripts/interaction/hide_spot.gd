class_name HideSpot
extends Interactable
## Shared occupancy and camera anchors for bunks, lockers and stalls.

signal entered
signal exited

@export var kind: StringName = &"locker"
@export var view: NodePath = ^"View"
@export var exit: NodePath = ^"Exit"

var _occupant: CharacterBody3D


func _ready() -> void:
	prompt_key = "PROMPT_HIDE_ENTER"


func is_occupied() -> bool:
	return is_instance_valid(_occupant)


func bed_id() -> int:
	return 0


func entry_seconds() -> float:
	return 0.0


func enter(player: CharacterBody3D) -> bool:
	if not enabled or is_occupied() or not is_instance_valid(player):
		return false
	if not player.has_method("enter_hide_spot"):
		return false
	if get_node_or_null(view) is not Node3D or get_node_or_null(exit) is not Node3D:
		push_warning("Hiding spot needs valid view and exit Node3D anchors.")
		return false
	return bool(player.call("enter_hide_spot", self))


func occupy(player: CharacterBody3D) -> void:
	_occupant = player
	prompt_key = "PROMPT_HIDE_EXIT"
	entered.emit()


func release() -> void:
	_occupant = null
	prompt_key = "PROMPT_LIE_DOWN" if bed_id() != 0 else "PROMPT_HIDE_ENTER"
	exited.emit()


func pull_out() -> void:
	if is_occupied():
		_occupant.call("leave_hide_spot")


func interact(player: Node) -> void:
	if not enabled:
		return
	if is_occupied():
		if player != _occupant:
			return
		pull_out()
	elif not enter(player as CharacterBody3D):
		return
	EventBus.interacted.emit(self)


func _exit_tree() -> void:
	pull_out()
