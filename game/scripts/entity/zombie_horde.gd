class_name ZombieHorde
extends Node3D

@export var anchors: Node3D
@export var target: Node3D
@export var max_active: int = 40
@export var zombie_scene: PackedScene = preload("res://scenes/entity/zombie.tscn")
var _zones: Dictionary[StringName, Array] = {}
var _pending: Dictionary[StringName, int] = {}
var _spawn_elapsed: float = 0.0


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_PAUSABLE


func _physics_process(delta: float) -> void:
	if get_tree().paused or _pending.is_empty():
		return
	_spawn_elapsed += delta
	if _spawn_elapsed >= 0.3:
		_spawn_elapsed = 0.0
		_drain_spawns()


func active_count() -> int:
	var count: int = 0
	for actors: Array in _zones.values():
		for actor: Zombie in actors:
			if is_instance_valid(actor) and not actor.is_queued_for_deletion() and actor.state != &"asleep":
				count += 1
	return count


func request_activation(zombie: Zombie, prioritize_hit: bool = false) -> bool:
	if active_count() < max_active:
		return true
	# A direct head hit must still stun at capacity. Retire the farthest hunter.
	if prioritize_hit and max_active > 0:
		var farthest: Zombie
		var distance: float = -1.0
		for actors: Array in _zones.values():
			for actor: Zombie in actors:
				if not is_instance_valid(actor) or actor == zombie or actor.is_queued_for_deletion() or actor.state == &"asleep":
					continue
				var next: float = actor.global_position.distance_squared_to(zombie.global_position)
				if next > distance:
					distance = next
					farthest = actor
		if farthest != null:
			farthest.sleep_pose(&"idle")
			return true
	return false


func spawn(zone: StringName, count: int) -> void:
	var points: Array[Node] = _points("ZombieSpawns", zone)
	if points.is_empty():
		return
	var reserved: int = 0
	for value: int in _pending.values():
		reserved += value
	_pending[zone] = _pending.get(zone, 0) + clampi(count, 0, maxi(0, max_active - active_count() - reserved))
	_drain_spawns()


func _drain_spawns() -> void:
	for zone: StringName in _pending.keys():
		for point: Node in _points("ZombieSpawns", zone):
			if _pending[zone] <= 0 or active_count() >= max_active:
				break
			if not _spawn_clear(point as Node3D):
				continue
			var actor: Zombie = _create(zone, point as Node3D)
			actor.wake()
			_pending[zone] -= 1
		if _pending[zone] <= 0:
			_pending.erase(zone)


func _spawn_clear(point: Node3D) -> bool:
	# Scene changes reach PhysicsServer on the next tick; check new actors too.
	for node: Node in get_tree().get_nodes_in_group(&"ch3_zombie"):
		if node is Zombie and not node.is_queued_for_deletion() and node.get_world_3d() == get_world_3d() \
				and node.global_position.distance_to(point.global_position) < 0.65:
			return false
	var shape: CapsuleShape3D = CapsuleShape3D.new()
	shape.radius = 0.26
	shape.height = 1.6
	var query: PhysicsShapeQueryParameters3D = PhysicsShapeQueryParameters3D.new()
	query.shape = shape
	query.transform.origin = point.global_position + Vector3.UP * 0.85
	query.collision_mask = 3
	return get_world_3d().direct_space_state.intersect_shape(query, 1).is_empty()


func place_idle(zone: StringName) -> void:
	for point: Node in _points("ZombieIdle", zone):
		var duplicate: bool = false
		for actor: Zombie in _zones.get(zone, []):
			if is_instance_valid(actor) and actor.has_meta(&"idle_anchor") and actor.get_meta(&"idle_anchor") == point:
				duplicate = true
		if duplicate:
			continue
		var zombie: Zombie = _create(zone, point as Node3D)
		zombie.set_meta(&"idle_anchor", point)
		zombie.sleep_pose(StringName(point.get_meta(&"pose", &"idle")))


func _points(kind: String, zone: StringName) -> Array[Node]:
	if not is_instance_valid(anchors):
		return []
	var root: Node = anchors.get_node_or_null(NodePath(kind + "/" + String(zone)))
	return root.get_children().filter(func(node: Node) -> bool: return node is Node3D) if root != null else []


func _create(zone: StringName, point: Node3D) -> Zombie:
	var actor: Zombie = zombie_scene.instantiate()
	actor.horde = self
	if not _zones.has(zone):
		_zones[zone] = []
	_zones[zone].append(actor)
	add_child(actor)
	actor.global_transform = point.global_transform
	actor.set_target(target)
	return actor


func clear_zone(zone: StringName) -> void:
	_pending.erase(zone)
	var actors: Array = _zones.get(zone, [])
	_zones.erase(zone)
	for actor: Zombie in actors:
		if is_instance_valid(actor):
			actor.queue_free()


func clear_all() -> void:
	_pending.clear()
	for zone: StringName in _zones.keys():
		clear_zone(zone)
