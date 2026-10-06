class_name RoomDoor
extends Node3D
## Geometry only. Core attaches ZombieDoor and decides when to open the room.

@export var room: StringName
var is_open: bool = false
@onready var blocker: StaticBody3D = $Blocker
@onready var _hinge: Node3D = $Hinge
var _swing: Tween


func _ready() -> void:
	add_to_group(&"room_doors")
	blocker.collision_layer = 1
	blocker.collision_mask = 0


func set_open(open: bool) -> void:
	is_open = open
	if not is_node_ready():
		await ready
	blocker.set_deferred("collision_layer", 0 if open else 1)
	if _swing != null and _swing.is_valid():
		_swing.kill()
	_swing = create_tween()
	_swing.tween_property(_hinge, "rotation:y", PI / 2.0 if open else 0.0, 0.3).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
