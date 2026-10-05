extends Marker3D
## Keeps the interaction mount on the animated mouth without owning interactions.
@export var body_path: NodePath


func _ready() -> void:
	process_priority = 10
	_process(0.0)


func _process(_delta: float) -> void:
	var body := get_node_or_null(body_path) as Node3D
	if body == null:
		return
	var head := body.get_node_or_null("Rig/Hips/Chest/Head") as Node3D
	if head:
		global_transform = head.global_transform.translated_local(Vector3(0, .005, -.14))
