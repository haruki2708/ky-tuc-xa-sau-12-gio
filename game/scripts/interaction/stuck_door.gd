class_name StuckDoor
extends Interactable
## Assign Room407 explicitly, or mount below a parent exposing its door API.

signal bashed(count: int)
signal opened

@export var room: Node
var bash_count: int = 0
var is_open: bool = false
var _revision: int = 0
var _dispatching: bool = false


func _room_controller() -> Node:
	if is_instance_valid(room) and room.has_method("set_bathroom_door_open"):
		return room
	var ancestor: Node = get_parent()
	while ancestor != null:
		if ancestor.has_method("set_bathroom_door_open"):
			return ancestor
		ancestor = ancestor.get_parent()
	return null


func interact(player: Node) -> void:
	if not enabled or is_open or _dispatching or not CarryItem.player_can_use(player):
		return
	var controller: Node = _room_controller()
	if controller == null:
		return
	_dispatching = true
	bash_count += 1
	var revision: int = _revision
	if bash_count == 3:
		is_open = true
		enabled = false
	if player.has_method("play_door_bash"):
		player.call("play_door_bash")
	EventBus.noise_emitted.emit(global_position, 6.0, &"door_bash")
	bashed.emit(bash_count)
	if revision != _revision:
		_dispatching = false
		return
	if is_open:
		controller.call("set_bathroom_door_open", true)
		opened.emit()
	EventBus.interacted.emit(self)
	_dispatching = false


func reset() -> void:
	_revision += 1
	bash_count = 0
	is_open = false
	enabled = true
	var controller: Node = _room_controller()
	if controller != null:
		controller.call("set_bathroom_door_open", false)
