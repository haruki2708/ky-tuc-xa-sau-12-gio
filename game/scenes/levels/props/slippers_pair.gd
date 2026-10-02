extends Node3D
## A pair of "dép lê" outside a room (T-138). The foam is tinted per pair.

@export var color: Color = Color(0.16, 0.3, 0.45):
	set(value):
		color = value
		if is_node_ready():
			_apply_color()


func _ready() -> void:
	_apply_color()


func _apply_color() -> void:
	PropTint.apply(self, color)
