class_name GazeDetector
extends Node
## One-shot continuous gaze test. reset() arms the next observation.

signal gazed

@export var camera: Camera3D
@export var target: Node3D
@export var max_angle_degrees: float = 35.0
@export var hold_seconds: float = 0.5
@export var require_line_of_sight: bool = false

var _elapsed: float = 0.0
var _triggered: bool = false
var _observed_camera: Camera3D
var _observed_target: Node3D


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_PAUSABLE


func reset() -> void:
	_elapsed = 0.0
	_triggered = false
	_observed_camera = camera
	_observed_target = target


func _physics_process(delta: float) -> void:
	if _triggered:
		return
	if camera != _observed_camera or target != _observed_target:
		_elapsed = 0.0
		_observed_camera = camera
		_observed_target = target
	if not _is_looking():
		_elapsed = 0.0
		return
	_elapsed += delta
	if _elapsed + 0.000001 >= maxf(0.0, hold_seconds):
		_triggered = true
		gazed.emit()


func _is_looking() -> bool:
	if not is_instance_valid(camera) or not is_instance_valid(target):
		return false
	if not camera.is_inside_tree() or not target.is_inside_tree():
		return false
	var offset: Vector3 = target.global_position - camera.global_position
	if offset.is_zero_approx():
		return false
	var forward: Vector3 = -camera.global_basis.z.normalized()
	if forward.dot(offset.normalized()) < cos(deg_to_rad(clampf(max_angle_degrees, 0.0, 180.0))):
		return false
	if not require_line_of_sight:
		return true
	var query: PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.create(
		camera.global_position, target.global_position, 1)
	# Camera can live inside a world-layer body in a reusable fixture.
	var exclusions: Array[RID] = []
	var ancestor: Node = camera.get_parent()
	while ancestor != null:
		if ancestor is CollisionObject3D:
			exclusions.append(ancestor.get_rid())
		ancestor = ancestor.get_parent()
	query.exclude = exclusions
	var hit: Dictionary = camera.get_world_3d().direct_space_state.intersect_ray(query)
	if hit.is_empty():
		return true
	var collider: Node = hit.get("collider") as Node
	return collider == target or (collider != null and target.is_ancestor_of(collider))
