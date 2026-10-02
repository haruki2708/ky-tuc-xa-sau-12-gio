class_name AudioZone
extends Area3D
## Shared layer-2 occupancy tracking, including bodies removed inside a zone.

signal occupancy_changed(occupied: bool)

var occupied: bool = false
var _bodies: Dictionary[int, Node3D] = {}


func _ready() -> void:
	collision_layer = 0
	collision_mask = 2
	monitorable = false
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)


func _on_body_entered(body: Node3D) -> void:
	if not body is PhysicsBody3D or (body.collision_layer & 2) == 0:
		return
	var id := body.get_instance_id()
	if _bodies.has(id):
		return
	_bodies[id] = body
	body.tree_exiting.connect(_remove_body.bind(id), CONNECT_ONE_SHOT)
	_update_occupied()


func _on_body_exited(body: Node3D) -> void:
	var id := body.get_instance_id()
	if body.tree_exiting.is_connected(_remove_body.bind(id)):
		body.tree_exiting.disconnect(_remove_body.bind(id))
	_remove_body(id)


func _remove_body(id: int) -> void:
	_bodies.erase(id)
	_update_occupied()


func _update_occupied() -> void:
	var next := not _bodies.is_empty()
	if next != occupied:
		occupied = next
		occupancy_changed.emit(occupied)


func _exit_tree() -> void:
	for id: int in _bodies:
		var body := _bodies[id]
		if is_instance_valid(body) and body.tree_exiting.is_connected(_remove_body.bind(id)):
			body.tree_exiting.disconnect(_remove_body.bind(id))
	_bodies.clear()
