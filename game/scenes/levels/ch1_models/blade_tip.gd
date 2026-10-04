extends Marker3D
## Stable root-level audio anchor follows the animated knife joint.
@export var source: NodePath


func _ready() -> void:
	process_priority = 10
	_process(0.0)


func _process(_delta: float) -> void:
	var tip := get_node_or_null(source) as Node3D
	if tip:
		global_transform = tip.global_transform
