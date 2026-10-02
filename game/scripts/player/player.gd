extends CharacterBody3D
## First-person locomotion; the root origin is at the player's feet.

signal footstep(surface: StringName, intensity: float)

const WALK_SPEED: float = 2.2
const SPRINT_SPEED: float = 3.6
const SETTINGS_PATH: String = "user://settings.cfg"
const DEFAULT_MOUSE_SENSITIVITY: float = 0.002
const MIN_MOUSE_SENSITIVITY: float = 0.0005
const MAX_MOUSE_SENSITIVITY: float = 0.006
const DEFAULT_HEAD_BOB: bool = true

@export var mouse_sensitivity: float = DEFAULT_MOUSE_SENSITIVITY
@export var acceleration: float = 12.0
@export var deceleration: float = 16.0
@export var head_bob_enabled: bool = DEFAULT_HEAD_BOB
@export var head_bob_amplitude: float = 0.018
@export_range(0.1, 3.0, 0.01) var walk_step_length: float = 1.1
@export_range(0.1, 3.0, 0.01) var sprint_step_length: float = 1.4
@export_range(0.0, 0.06, 0.001) var step_length_variation: float = 0.06

@onready var head: Node3D = $Head
@onready var camera: Camera3D = $Head/Camera3D
@onready var interact_ray: RayCast3D = $Head/Camera3D/InteractRay

var _target: Interactable
var _focus_id: int = 0
var _focus_key: String = ""
var _step_progress: float = 0.0
var _step_scale: float = 1.0
var _step_rng: RandomNumberGenerator = RandomNumberGenerator.new()
var _mouse_captured: bool = false


func _ready() -> void:
	EventBus.game_paused.connect(_on_game_paused)
	EventBus.settings_changed.connect(_on_settings_changed)
	_read_settings(true, true)
	_set_mouse_captured(true)
	_step_scale = _next_step_scale()


func _on_game_paused(paused: bool) -> void:
	_set_mouse_captured(not paused)


func _on_settings_changed(section: String, key: String) -> void:
	if section == "input" and key == "mouse_sensitivity":
		_read_settings(true, false)
	elif section == "video" and key == "head_bob":
		_read_settings(false, true)


func _read_settings(update_mouse: bool, update_bob: bool) -> void:
	var config: ConfigFile = ConfigFile.new()
	if config.load(SETTINGS_PATH) != OK:
		config.clear()
	if update_mouse:
		var sensitivity: Variant = config.get_value("input", "mouse_sensitivity", DEFAULT_MOUSE_SENSITIVITY)
		mouse_sensitivity = DEFAULT_MOUSE_SENSITIVITY
		if typeof(sensitivity) == TYPE_FLOAT:
			if is_finite(sensitivity) and sensitivity >= MIN_MOUSE_SENSITIVITY and sensitivity <= MAX_MOUSE_SENSITIVITY:
				mouse_sensitivity = sensitivity
	if update_bob:
		var bob: Variant = config.get_value("video", "head_bob", DEFAULT_HEAD_BOB)
		head_bob_enabled = bob if typeof(bob) == TYPE_BOOL else DEFAULT_HEAD_BOB
		if not head_bob_enabled:
			# Signals still arrive while the tree is paused; reset without a physics tick.
			camera.position.y = 0.0


func _set_mouse_captured(captured: bool) -> void:
	# Keep the requested state available on headless display servers as well.
	_mouse_captured = captured
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED if captured else Input.MOUSE_MODE_VISIBLE


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and _mouse_captured:
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
		_step_progress = 0.0
	var horizontal_speed: float = Vector2(velocity.x, velocity.z).length()
	var base_length: float = _step_length_at_speed(horizontal_speed)
	var remaining_distance: float = distance
	# Progress is shared by sound and bob, including speed changes and per-step jitter.
	while remaining_distance > 0.0:
		var step_length: float = base_length * _step_scale
		var distance_to_step: float = (1.0 - _step_progress) * step_length
		if remaining_distance < distance_to_step:
			_step_progress += remaining_distance / step_length
			break
		remaining_distance -= distance_to_step
		_step_progress = 0.0
		_step_scale = _next_step_scale()
		footstep.emit(_floor_surface(), clampf(horizontal_speed / SPRINT_SPEED, 0.0, 1.0))
	if head_bob_enabled and distance > 0.0001:
		camera.position.y = sin(_step_progress * TAU) * head_bob_amplitude
	elif head_bob_enabled:
		camera.position.y = move_toward(camera.position.y, 0.0, delta * 0.1)
	else:
		camera.position.y = 0.0


func _step_length_at_speed(speed: float) -> float:
	var blend: float = clampf((speed - WALK_SPEED) / (SPRINT_SPEED - WALK_SPEED), 0.0, 1.0)
	return maxf(0.1, lerpf(walk_step_length, sprint_step_length, blend))


func _next_step_scale() -> float:
	var variation: float = clampf(step_length_variation, 0.0, 0.06)
	return _step_rng.randf_range(1.0 - variation, 1.0 + variation)


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
