class_name IronBarWeapon
extends Node3D

@export var max_hits: int = 8
@export var reach: float = 1.5
@export var stamina_cost: float = 0.08
@export var swing_seconds: float = 0.55
var hits_left: int = 0
var player: CharacterBody3D
var _remaining: float = 0.0
var _bend: Node3D


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_PAUSABLE
	position = Vector3(0.28, -0.3, -0.6)
	var lower: MeshInstance3D = _segment(0.35)
	lower.position.y = 0.175
	add_child(lower)
	_bend = Node3D.new()
	_bend.position.y = 0.35
	add_child(_bend)
	var upper: MeshInstance3D = _segment(0.5)
	upper.position.y = 0.25
	_bend.add_child(upper)
	hide()


func _segment(length: float) -> MeshInstance3D:
	var node: MeshInstance3D = MeshInstance3D.new()
	var mesh: BoxMesh = BoxMesh.new()
	mesh.size = Vector3(0.035, length, 0.035)
	var material: StandardMaterial3D = StandardMaterial3D.new()
	material.albedo_color = Color(0.3, 0.32, 0.34)
	mesh.material = material
	node.mesh = mesh
	return node


func give_bar(hits: int = 8) -> void:
	hits_left = clampi(hits, 0, max_hits)
	_remaining = 0.0
	rotation = Vector3.ZERO
	visible = hits_left > 0
	_bend.rotation.z = (1.0 - float(hits_left) / max_hits) * 0.8
	EventBus.bar_picked.emit(hits_left)


func swing() -> bool:
	if hits_left <= 0 or _remaining > 0 or not CarryItem.player_can_use(player) or player.call("is_hidden"):
		return false
	_remaining = swing_seconds
	player.call("spend_stamina", stamina_cost)
	var camera: Camera3D = get_parent() as Camera3D
	var query: PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.create(
		camera.global_position, camera.global_position - camera.global_basis.z * reach, 5, [player.get_rid()])
	query.collide_with_areas = true
	var result: Dictionary = camera.get_world_3d().direct_space_state.intersect_ray(query)
	var hit: bool = false
	if not result.is_empty():
		var collider: Node = result.get("collider") as Node
		var zombie: Zombie = collider.get_meta(&"zombie") as Zombie if collider.has_meta(&"zombie") else null
		if zombie != null:
			hit = true
			hits_left -= 1
			zombie.stun(5.0)
		else:
			var ancestor: Node = collider
			while ancestor != null:
				if ancestor is CampusGuard:
					ancestor.struck()
					break
				ancestor = ancestor.get_parent()
	_bend.rotation.z = (1.0 - float(hits_left) / max_hits) * 0.8
	EventBus.noise_emitted.emit(player.global_position, 10.0, &"bar_swing")
	EventBus.bar_swung.emit(hit, hits_left)
	if hits_left == 0:
		hide()
		EventBus.bar_broken.emit()
	return true


func _physics_process(delta: float) -> void:
	_remaining = maxf(0, _remaining - delta)
	rotation.x = -sin((1.0 - _remaining / swing_seconds) * PI) * 1.2 if _remaining > 0 else 0.0
