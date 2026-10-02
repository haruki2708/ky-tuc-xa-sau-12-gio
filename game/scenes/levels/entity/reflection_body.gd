extends Node3D
## Render layer 20 is reserved for mirror bodies. The mirror excludes it from
## its source camera; no collision, shadow, UI or gameplay is added here.

const RENDER_LAYER: int = 1 << 19
var head: Node3D


func _ready() -> void:
	head = find_child("HeadPivot", true, false) as Node3D
