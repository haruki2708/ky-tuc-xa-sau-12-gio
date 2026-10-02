extends Node3D
## A shirt or towel on the clothesline (T-138): tinted, swaying a little in
## the night breeze around the line. Origin is on the line.

@export var color: Color = Color(1, 1, 1):
	set(value):
		color = value
		if is_node_ready():
			PropTint.apply(self, color)
## Swing amplitude in radians around the line.
@export var sway: float = 0.045

var _phase: float = 0.0


func _ready() -> void:
	PropTint.apply(self, color)
	# Neighbouring cloths must not swing in step.
	_phase = fposmod(global_position.x * 1.7, TAU)


func _process(delta: float) -> void:
	_phase += delta
	rotation.x = sin(_phase * 0.9) * sway + sin(_phase * 2.3) * sway * 0.25
