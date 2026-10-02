extends CharacterBody3D
## First-person locomotion; the root origin is at the player's feet.

signal footstep(surface: StringName)

const WALK_SPEED: float = 2.2
const SPRINT_SPEED: float = 3.6
const STEP_DISTANCE: float = 0.7

@export var mouse_sensitivity: float = 0.002
@export var acceleration: float = 12.0
@export var deceleration: float = 16.0
@export var head_bob_enabled: bool = true
@export var head_bob_amplitude: float = 0.018

@onready var head: Node3D = $Head
@onready var camera: Camera3D = $Head/Camera3D
@onready var interact_ray: RayCast3D = $Head/Camera3D/InteractRay

var _target: Interactable
var _focus_id: int = 0
var _focus_key: String = ""
var _step_distance: float = 0.0
var _bob_phase: float = 0.0
var _mouse_captured: bool = false


func _ready() -> void:
	_set_mouse_captured(true)


func _set_mouse_captured(captured: bool) -> void:
	# Keep the requested state available on headless display servers as well.
	_mouse_captured = captured
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED if captured else Input.MOUSE_MODE_VISIBLE


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause") and not event.is_echo():
		_set_mouse_captured(not _mouse_captured)
		get_viewport().set_input_as_handled()
	elif event is InputEventMouseMotion and _mouse_captured:
		rotate_y(-event.relative.x * mouse_sensitivity)
		head.rotation.x = clampf(head.rotation.x - event.relative.y * mouse_sensitivity,
			deg_to_rad(-85.0), deg_to_rad(85.0))


func _physics_process(delta: float) -> void:
	var input_vector: Vector2 = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var direction: Vector3 = global_basis * Vector3(input_vector.x, 0.0, input_vector.y)
	direction.y = 0.0
	var speed: float = SPRINT_SPEED if Input.is_action_pressed("sprint") else WALK_SPEED
	var rate: float = acceleration if not input_vector.is_zero_approx() else deceleration
	var horizontal: Vector3 = Vector3(velocity.x, 0.0, velocity.z).move_toward(direction * speed, rate * delta)
	velocity.x = horizontal.x
	velocity.z = horizontal.z
	if not is_on_floor():
		velocity += get_gravity() * delta
	else:
		velocity.y = 0.0
	var was_grounded: bool = is_on_floor()
	var previous_position: Vector3 = global_position
	move_and_slide()
	_update_steps_and_bob(previous_position, was_grounded, delta)
	_update_focus()
	if Input.is_action_just_pressed("interact") and is_instance_valid(_target):
		_target.interact(self)


func _update_focus() -> void:
	interact_ray.force_raycast_update()
	var collider: Object = interact_ray.get_collider()
	var candidate: Interactable = collider as Interactable
	if candidate != null and not candidate.enabled:
		candidate = null
	var next_id: int = candidate.get_instance_id() if candidate != null else 0
	var next_key: String = candidate.prompt_key if candidate != null else ""
	_target = candidate
	if next_id != _focus_id or next_key != _focus_key:
		_focus_id = next_id
		_focus_key = next_key
		EventBus.interaction_focus_changed.emit(next_key)


func _update_steps_and_bob(previous_position: Vector3, was_grounded: bool, delta: float) -> void:
	var displacement: Vector3 = global_position - previous_position
	displacement.y = 0.0
	var distance: float = displacement.length() if was_grounded and is_on_floor() else 0.0
	if not is_on_floor():
		_step_distance = 0.0
	_step_distance += distance
	while _step_distance >= STEP_DISTANCE:
		_step_distance -= STEP_DISTANCE
		footstep.emit(_floor_surface())
	if head_bob_enabled and distance > 0.0001:
		_bob_phase += distance * TAU / STEP_DISTANCE
		camera.position.y = sin(_bob_phase) * head_bob_amplitude
	elif head_bob_enabled:
		camera.position.y = move_toward(camera.position.y, 0.0, delta * 0.1)
	else:
		camera.position.y = 0.0


func _floor_surface() -> StringName:
	var query: PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.create(
		global_position + Vector3.UP * 0.15, global_position + Vector3.DOWN * 0.25, 1)
	var hit: Dictionary = get_world_3d().direct_space_state.intersect_ray(query)
	if not hit.is_empty():
		var collider: Object = hit["collider"]
		return StringName(str(collider.get_meta("surface", &"concrete")))
	return &"concrete"


func _exit_tree() -> void:
	if _focus_id != 0:
		EventBus.interaction_focus_changed.emit("")
	_set_mouse_captured(false)
