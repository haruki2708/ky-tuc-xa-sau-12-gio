extends Node3D
## The reused GLB is visual only; RoomDoor/Blocker owns closed-door collision.


func _ready() -> void:
	for child: Node in find_children("*", "CollisionObject3D", true, false):
		(child as CollisionObject3D).collision_layer = 0
		(child as CollisionObject3D).collision_mask = 0
		child.queue_free()
