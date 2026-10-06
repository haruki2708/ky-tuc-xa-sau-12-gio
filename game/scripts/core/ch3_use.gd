class_name Ch3Use
extends Interactable
## A thing core places on a lane B anchor in chapter 3 (the fire key, the fire
## door, the extinguisher): E emits `used`; the director decides what happens.

signal used

@export var size: Vector3 = Vector3(0.6, 0.6, 0.6)
## Disable after the first use (the key is taken, the extinguisher banged).
@export var once: bool = true


func _ready() -> void:
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = size
	shape.shape = box
	add_child(shape)


func _on_interact(_player: Node) -> void:
	if once:
		enabled = false
	used.emit()
