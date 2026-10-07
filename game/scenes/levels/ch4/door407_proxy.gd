extends Node3D
## Adapt the existing chapter-1/2 leaf without replacing its interaction/latch.
var room: StringName = &"407"
var is_open: bool:
	get:
		return bool(_door.is_open) if is_instance_valid(_door) else false
@onready var blocker: StaticBody3D = $Blocker
var _door: Node3D
var _leaf: Node3D
var _colliders: Array[Dictionary] = []
var _original_visibility: bool = true
var damage_fraction: float = 0.0


func _ready() -> void:
	blocker.collision_layer = 0
	EventBus.door_damage_changed.connect(_on_damage)
	call_deferred("_bind")


func _bind() -> void:
	var campus := get_node_or_null("../../../..")
	# Subscene previews and the smoke loader may instantiate Ch4 without Campus.
	if campus == null or campus.get("floor4_path") == null:
		return
	var floor4 := campus.get_node_or_null(campus.floor4_path)
	if floor4 == null:
		return
	_door = floor4.get_node("Door407")
	_leaf = _door.get_node("Pivot/Leaf")
	_original_visibility = _leaf.visible
	for node in _leaf.find_children("*", "CollisionObject3D", true, false):
		_colliders.append({"node": weakref(node), "layer": node.collision_layer})
		node.collision_layer = 0
	add_to_group(&"room_doors")
	_sync()


func set_open(value: bool) -> void:
	if is_instance_valid(_door):
		_door.set_open(value)
		_sync()


func _process(_delta: float) -> void:
	_sync()


func _sync() -> void:
	if not is_instance_valid(_door):
		return
	global_transform = _door.global_transform
	$Damage.rotation = _door.get_node("Pivot").rotation
	blocker.collision_layer = 0 if is_open else 1


func _on_damage(id: StringName, fraction: float) -> void:
	if id != room:
		return
	set_damage_fraction(fraction)


func set_damage_fraction(fraction: float) -> void:
	damage_fraction = clampf(fraction, 0.0, 1.0) if is_finite(fraction) else 0.0
	$Damage/Cracks.visible = damage_fraction >= .3
	$Damage/Hole.visible = damage_fraction >= .6
	$Damage/Hand.visible = damage_fraction >= .8
	if is_instance_valid(_leaf):
		_leaf.visible = _original_visibility and damage_fraction < .6


func _exit_tree() -> void:
	for entry in _colliders:
		var node: Object = entry.node.get_ref()
		if is_instance_valid(node):
			node.collision_layer = entry.layer
	if is_instance_valid(_leaf):
		_leaf.visible = _original_visibility
