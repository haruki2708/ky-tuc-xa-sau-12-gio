class_name StoryTrigger
extends Interactable
## A plain story object the StoryDirector watches (e.g. the running washroom
## tap in segment 5). Not a lane A gameplay object: it has no behaviour of its
## own beyond telling the story it was used. Owner: integrator.

signal triggered

@export var size: Vector3 = Vector3(0.2, 0.2, 0.2)


func _ready() -> void:
	var shape := BoxShape3D.new()
	shape.size = size
	var collision := CollisionShape3D.new()
	collision.shape = shape
	add_child(collision)


func _on_interact(_player: Node) -> void:
	triggered.emit()
