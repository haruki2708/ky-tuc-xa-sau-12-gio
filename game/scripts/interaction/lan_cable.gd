class_name LanCable
extends Interactable
## A held connector follows the camera. No network success/failure is decided here.

signal plugged(cable_id: StringName)
signal unplugged(cable_id: StringName)

enum State { LOOSE, HELD, PLUGGED }

@export var cable_id: StringName = &"blue"
var state: State = State.LOOSE
var holder: Node3D
var socket: Node3D
var _loose_transform: Transform3D


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_PAUSABLE
	add_to_group(&"lan_cable")
	_loose_transform = global_transform
	prompt_key = "PROMPT_CABLE_PICK_UP"


func _physics_process(_delta: float) -> void:
	if state == State.HELD:
		if not is_instance_valid(holder) or not holder.is_inside_tree():
			drop()
			return
		var anchor: Node3D = holder.get_node_or_null("Head/Camera3D") as Node3D
		if anchor == null:
			anchor = holder
		global_transform = anchor.global_transform.translated_local(Vector3(0.24, -0.22, -0.55))
	elif state == State.PLUGGED:
		if not is_instance_valid(socket) or not socket.is_inside_tree():
			drop()
		else:
			global_transform = socket.global_transform.translated_local(Vector3(0, 0, 0.08))


func interact(player: Node) -> void:
	if not enabled or state == State.HELD or not player is Node3D or get_tree().paused:
		return
	if player.has_method("controls_locked") and player.call("controls_locked"):
		return
	for other: Node in get_tree().get_nodes_in_group(&"lan_cable"):
		if other != self and other is LanCable and other.holder == player:
			other.drop()
	var was_plugged: bool = state == State.PLUGGED
	if state == State.LOOSE:
		_loose_transform = global_transform
	_release_socket()
	holder = player as Node3D
	state = State.HELD
	collision_layer = 0
	if was_plugged:
		unplugged.emit(cable_id)
	EventBus.interacted.emit(self)


func plug_into(port: Node3D, player: Node) -> bool:
	if not enabled or state != State.HELD or holder != player or not is_instance_valid(port):
		return false
	if get_tree().paused or (player.has_method("controls_locked") and player.call("controls_locked")):
		return false
	socket = port
	holder = null
	state = State.PLUGGED
	collision_layer = LAYER_INTERACTABLE
	prompt_key = "PROMPT_CABLE_UNPLUG"
	global_transform = port.global_transform.translated_local(Vector3(0, 0, 0.08))
	plugged.emit(cable_id)
	return true


func drop() -> void:
	var was_plugged: bool = state == State.PLUGGED
	_release_socket()
	holder = null
	state = State.LOOSE
	collision_layer = LAYER_INTERACTABLE
	prompt_key = "PROMPT_CABLE_PICK_UP"
	global_transform = _loose_transform
	if was_plugged:
		unplugged.emit(cable_id)


func _release_socket() -> void:
	if is_instance_valid(socket) and socket.get("cable") == self:
		socket.set("cable", null)
	socket = null


func _exit_tree() -> void:
	_release_socket()
