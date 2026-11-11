class_name CarryItem
extends Interactable
## Core consumes accepted items; rejected gag requests leave the hand untouched.

signal picked(item_id: StringName)
signal dropped(item_id: StringName)

@export var item_id: StringName = &"rag"

var holder: Node3D
var consumed: bool = false
var _home: Transform3D


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_PAUSABLE
	add_to_group(&"carry_item")
	_home = global_transform


static func held_by(player: Node) -> CarryItem:
	if not is_instance_valid(player) or not player.is_inside_tree():
		return null
	for node: Node in player.get_tree().get_nodes_in_group(&"carry_item"):
		if node is CarryItem and node.holder == player and not node.consumed:
			return node
	return null


static func player_can_use(player: Node) -> bool:
	return is_instance_valid(player) and player.is_inside_tree() \
		and not player.get_tree().paused \
		and (not player.has_method("keyboard_input_blocked") or not player.call("keyboard_input_blocked")) \
		and (not player.has_method("controls_locked") or not player.call("controls_locked"))


func interact(player: Node) -> void:
	if not enabled or consumed or is_instance_valid(holder) or not player_can_use(player):
		return
	if player is not Node3D or player.get_node_or_null("Head/Camera3D") is not Camera3D:
		return
	var previous: CarryItem = held_by(player)
	if previous != null:
		previous.drop()
	_home = global_transform
	holder = player
	collision_layer = 0
	# T-243 (D-162): with Tran Trung's body the right hand carries it (a copy of its model in the
	# fist; the item itself stays where it was taken from, hidden by the chapter's `picked`).
	var hand := _body()
	if hand != null:
		hand.call("take_item", self, get_meta(&"look") if has_meta(&"look") else null)
	else:
		_follow_camera()
	picked.emit(StringName(item_id))
	EventBus.interacted.emit(self)


func _physics_process(_delta: float) -> void:
	if consumed:
		return
	if is_instance_valid(holder) and holder.is_inside_tree():
		_follow_camera()
	elif collision_layer == 0:
		drop()


## T-243: a hand carries it (its placeholder box is not shown in front of the camera).
func carried_by_hand() -> bool:
	var hand := _body()
	return hand != null and bool(hand.call("holds", self))


## T-243: the full body of the holder whose hand carries this, else null.
func _body() -> Node:
	var body: Variant = holder.get("body") if is_instance_valid(holder) else null
	if body is Node and is_instance_valid(body) and (body as Node).has_method("take_item") and (body as Node3D).visible:
		return body as Node
	return null


func _follow_camera() -> void:
	var hand := _body()
	if hand != null and hand.call("holds", self):
		# The hand carries it (PlayerBody places its look in the fist): the item itself stays here.
		return
	var camera: Camera3D = holder.get_node_or_null("Head/Camera3D") as Camera3D
	if camera == null:
		drop()
		return
	global_transform = camera.global_transform.translated_local(Vector3(0.24, -0.22, -0.55))


func drop() -> void:
	if consumed or collision_layer != 0:
		return
	var hand := _body()
	if hand != null and hand.call("holds", self):
		hand.call("release_item")
	holder = null
	global_transform = _home
	collision_layer = LAYER_INTERACTABLE
	dropped.emit(StringName(item_id))


func consume() -> void:
	if consumed or not is_instance_valid(holder):
		return
	consumed = true
	holder = null
	enabled = false
	collision_layer = 0
	hide()
