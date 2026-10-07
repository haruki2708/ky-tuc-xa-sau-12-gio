extends CharacterBody3D
## First-person locomotion; the root origin is at the player's feet.

signal footstep(surface: StringName, intensity: float)
signal death_animation_finished

const WALK_SPEED: float = 2.2
const SPRINT_SPEED: float = 3.6
const CROUCH_SPEED: float = 1.2
const SETTINGS_PATH: String = "user://settings.cfg"
const DEFAULT_MOUSE_SENSITIVITY: float = 0.002
const MIN_MOUSE_SENSITIVITY: float = 0.0005
const MAX_MOUSE_SENSITIVITY: float = 0.006
const DEFAULT_HEAD_BOB: bool = true
const GAMEPLAY_ACTIONS: Array[StringName] = [
	&"move_forward", &"move_back", &"move_left", &"move_right", &"sprint",
	&"crouch", &"hold_breath", &"interact", &"phone", &"flashlight",
]

@export var mouse_sensitivity: float = DEFAULT_MOUSE_SENSITIVITY
@export var acceleration: float = 12.0
@export var deceleration: float = 16.0
@export var head_bob_enabled: bool = DEFAULT_HEAD_BOB
@export var head_bob_amplitude: float = 0.018
@export var stamina_enabled: bool = false:
	set(value):
		var changed: bool = stamina_enabled != value
		stamina_enabled = value
		if value and changed and is_node_ready():
			EventBus.stamina_changed.emit(stamina, exhausted)
@export var sprint_drain: float = 1.0 / 12.0
@export var walk_recovery: float = 0.05
@export var idle_recovery: float = 0.12
var stamina: float = 1.0
var exhausted: bool = false
var bar_weapon: IronBarWeapon
var _pant_elapsed: float = 0.0
@export_range(0.1, 3.0, 0.01) var walk_step_length: float = 1.1
@export_range(0.1, 3.0, 0.01) var sprint_step_length: float = 1.4
@export_range(0.0, 0.06, 0.001) var step_length_variation: float = 0.06
@export var restless_degrees_per_second: float = 180.0
@export_range(0.1, 60.0, 0.1) var max_breath_seconds: float = 8.0

@onready var head: Node3D = $Head
@onready var camera: Camera3D = $Head/Camera3D
@onready var interact_ray: RayCast3D = $Head/Camera3D/InteractRay
@onready var body_shape: CollisionShape3D = $CollisionShape3D

var _target: Interactable
var _focus_id: int = 0
var _focus_key: String = ""
var _step_progress: float = 0.0
var _step_scale: float = 1.0
var _step_rng: RandomNumberGenerator = RandomNumberGenerator.new()
var _mouse_captured: bool = false
var crouched: bool = false
var holding_breath: bool = false
var _hide_spot: HideSpot
var _exit_transform: Transform3D
var _climb: Tween
var _look_distance: float = 0.0
var _restless_cooldown: float = 0.0
var _breath_elapsed: float = 0.0
var _hold_elapsed: float = 0.0
var _breath_cooldown: float = 0.0
var _control_locks: Array[Node] = []
var _movement_locks: Array[Node] = []
var death_animation: PlayerDeath
var _bash_elapsed: float = 0.22
var _text_entry_active: bool = false


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_PAUSABLE
	body_shape.shape = body_shape.shape.duplicate()
	GameState.set_flag(&"player_bed", 0)
	EventBus.game_paused.connect(_on_game_paused)
	EventBus.settings_changed.connect(_on_settings_changed)
	EventBus.text_entry_changed.connect(_on_text_entry_changed)
	_read_settings(true, true)
	_set_mouse_captured(true)
	_step_scale = _next_step_scale()
	death_animation = PlayerDeath.new()
	death_animation.name = "DeathAnimation"
	add_child(death_animation)
	EventBus.player_death_started.connect(_on_death_started)
	if stamina_enabled:
		EventBus.stamina_changed.emit(stamina, exhausted)


func _on_death_started(kind: StringName) -> void:
	if death_animation.active or kind not in [&"fall_back", &"manager_kill", &"bed_burst", &"corpse_lunge", &"scald", &"zombie_grab", &"guard_shock", &"door_burst"]:
		return
	if _bash_elapsed < 0.22:
		camera.rotation = Vector3.ZERO
		_bash_elapsed = 0.22
	if _climb != null and _climb.is_valid():
		_climb.kill()
	_set_holding_breath(false)
	acquire_control_lock(death_animation)
	death_animation.start(self, camera, kind)


func _on_game_paused(paused: bool) -> void:
	_set_mouse_captured(not paused and not controls_locked())


func _on_text_entry_changed(active: bool) -> void:
	if _text_entry_active == active:
		return
	_text_entry_active = active
	# Clear polled gameplay state at both boundaries, without swallowing text events.
	# A new gameplay press is required after closing; Esc/Enter belong to the UI.
	for action: StringName in GAMEPLAY_ACTIONS:
		Input.action_release(action)
	if InputMap.has_action("throw_phone"):
		Input.action_release("throw_phone")
	if active:
		velocity = Vector3.ZERO
		_set_holding_breath(false)


func keyboard_input_blocked() -> bool:
	# Typing owns the keyboard only; modal locks still own keyboard AND mouse.
	return _text_entry_active or controls_locked()


func _on_settings_changed(section: String, key: String) -> void:
	if section == "input" and key == "mouse_sensitivity":
		_read_settings(true, false)
	elif section == "video" and key == "head_bob":
		_read_settings(false, true)
	elif section == "accessibility" and key == "reduce_scares" and death_animation != null:
		death_animation.refresh_settings()


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
		if not head_bob_enabled and (death_animation == null or not death_animation.active):
			# Signals still arrive while the tree is paused; reset without a physics tick.
			camera.position.y = 0.0


func _set_mouse_captured(captured: bool) -> void:
	# Keep the requested state available on headless display servers as well.
	_mouse_captured = captured
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED if captured else Input.MOUSE_MODE_VISIBLE


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed \
			and is_instance_valid(bar_weapon) and bar_weapon.hits_left > 0 \
			and _mouse_captured and not keyboard_input_blocked() and not is_hidden():
		Input.action_release("interact")
		bar_weapon.swing()
		get_viewport().set_input_as_handled()
		return
	if event is InputEventMouseMotion and _mouse_captured and not controls_locked():
		if is_hidden():
			var previous: Vector2 = Vector2(head.rotation.x, head.rotation.y)
			head.rotation.y = clampf(head.rotation.y - event.relative.x * mouse_sensitivity,
				deg_to_rad(-70.0), deg_to_rad(70.0))
			head.rotation.x = clampf(head.rotation.x - event.relative.y * mouse_sensitivity,
				deg_to_rad(-10.0), deg_to_rad(40.0))
			_look_distance += previous.distance_to(Vector2(head.rotation.x, head.rotation.y))
			return
		rotate_y(-event.relative.x * mouse_sensitivity)
		head.rotation.x = clampf(head.rotation.x - event.relative.y * mouse_sensitivity,
			deg_to_rad(-85.0), deg_to_rad(85.0))


func _physics_process(delta: float) -> void:
	if death_animation != null and death_animation.active:
		velocity = Vector3.ZERO
		return
	_update_door_bash(delta)
	_breath_cooldown = maxf(0.0, _breath_cooldown - delta)
	if is_hidden():
		_update_stamina(delta, false, false)
		_update_breath(delta)
		_restless_cooldown = maxf(0.0, _restless_cooldown - delta)
		if rad_to_deg(_look_distance) / maxf(delta, 0.000001) > restless_degrees_per_second and _restless_cooldown <= 0.0:
			make_noise(2.0, &"move")
			_restless_cooldown = 0.4
		_look_distance = 0.0
		_update_focus()
		if not keyboard_input_blocked() and Input.is_action_pressed("interact") and Input.is_action_just_pressed("interact"):
			leave_hide_spot()
		return
	if controls_locked():
		_update_stamina(delta, false, false)
		velocity = Vector3.ZERO
		return
	if _text_entry_active:
		_update_stamina(delta, false, false)
		velocity = Vector3.ZERO
		# Settle the existing bob without taking another locomotion step.
		camera.position.y = move_toward(camera.position.y, 0.0, delta * 0.1)
		_update_focus()
		return
	if movement_locked():
		velocity = Vector3.ZERO
		_update_stamina(delta, false, false)
		_update_focus()
		return
	_update_crouch()
	var input_vector: Vector2 = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var direction: Vector3 = global_basis * Vector3(input_vector.x, 0.0, input_vector.y)
	direction.y = 0.0
	var sprinting: bool = Input.is_action_pressed("sprint") and not (stamina_enabled and exhausted)
	var speed: float = SPRINT_SPEED if sprinting else WALK_SPEED
	if crouched:
		speed = CROUCH_SPEED
	var rate: float = acceleration if not input_vector.is_zero_approx() else deceleration
	var horizontal: Vector3 = Vector3(velocity.x, 0.0, velocity.z).move_toward(direction * speed, rate * delta)
	if crouched:
		horizontal = horizontal.limit_length(CROUCH_SPEED)
	elif stamina_enabled and exhausted:
		horizontal = horizontal.limit_length(WALK_SPEED)
	velocity.x = horizontal.x
	velocity.z = horizontal.z
	if not is_on_floor():
		velocity += get_gravity() * delta
	else:
		velocity.y = 0.0
	var was_grounded: bool = is_on_floor()
	var previous_position: Vector3 = global_position
	move_and_slide()
	var moved: bool = Vector2(global_position.x - previous_position.x, global_position.z - previous_position.z).length() > 0.0001
	_update_stamina(delta, sprinting and not crouched, moved)
	_update_steps_and_bob(previous_position, was_grounded, delta)
	_update_focus()
	if Input.is_action_pressed("interact") and Input.is_action_just_pressed("interact") and is_instance_valid(_target):
		_target.interact(self)


func give_bar(hits: int = 8) -> void:
	if not is_instance_valid(bar_weapon):
		bar_weapon = IronBarWeapon.new()
		bar_weapon.name = "IronBar"
		bar_weapon.player = self
		camera.add_child(bar_weapon)
	bar_weapon.give_bar(hits)


func spend_stamina(amount: float) -> void:
	if stamina_enabled and is_finite(amount):
		_set_stamina(stamina - maxf(0, amount))


func _set_stamina(value: float) -> void:
	var before: float = stamina
	var was_exhausted: bool = exhausted
	stamina = clampf(value, 0, 1)
	if stamina <= 0.000001:
		stamina = 0.0
		exhausted = true
		if not was_exhausted:
			_pant_elapsed = 1.5
	elif stamina >= 0.3:
		exhausted = false
	if before != stamina or was_exhausted != exhausted:
		EventBus.stamina_changed.emit(stamina, exhausted)


func _update_stamina(delta: float, sprinting: bool, moving: bool) -> void:
	if not stamina_enabled:
		return
	_set_stamina(stamina + (-sprint_drain if sprinting and moving and not exhausted else (walk_recovery if moving else idle_recovery)) * delta)
	if exhausted:
		_pant_elapsed += delta
		if _pant_elapsed >= 1.5:
			_pant_elapsed = fmod(_pant_elapsed, 1.5)
			make_noise(8.0, &"pant")
	else:
		_pant_elapsed = 0.0


func _update_focus() -> void:
	interact_ray.force_raycast_update()
	var collider: Object = interact_ray.get_collider()
	var candidate: Interactable = _hide_spot if is_hidden() else collider as Interactable
	if candidate != null and not candidate.enabled:
		candidate = null
	if candidate != null and candidate.has_method("can_interact") and not candidate.call("can_interact", self):
		candidate = null
	var next_id: int = candidate.get_instance_id() if candidate != null else 0
	var next_key: String = candidate.prompt_key if candidate != null else ""
	_target = candidate
	if next_id != _focus_id or next_key != _focus_key:
		_focus_id = next_id
		_focus_key = next_key
		EventBus.interaction_focus_changed.emit(next_key)


func play_door_bash() -> void:
	if not controls_locked():
		_bash_elapsed = 0.0


func _update_door_bash(delta: float) -> void:
	if _bash_elapsed >= 0.22:
		return
	_bash_elapsed = minf(0.22, _bash_elapsed + delta)
	var impulse: float = sin(PI * _bash_elapsed / 0.22)
	camera.rotation = Vector3(-0.035 * impulse, 0, 0.01 * impulse)
	if _bash_elapsed >= 0.22:
		camera.rotation = Vector3.ZERO


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
		make_noise(1.5 if crouched else (12.0 if horizontal_speed > WALK_SPEED + 0.1 else 5.0), &"step")
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
	if is_hidden():
		leave_hide_spot(false)
	if _focus_id != 0:
		EventBus.interaction_focus_changed.emit("")
	_set_mouse_captured(false)


func make_noise(radius: float, source: StringName) -> void:
	EventBus.noise_emitted.emit(global_position, maxf(0.0, radius), source)


func movement_locked() -> bool:
	_movement_locks = _movement_locks.filter(func(owner: Node) -> bool: return is_instance_valid(owner))
	return not _movement_locks.is_empty()


func acquire_movement_lock(owner: Node) -> void:
	if not _movement_locks.has(owner):
		_movement_locks.append(owner)
	velocity = Vector3.ZERO


func release_movement_lock(owner: Node) -> void:
	_movement_locks.erase(owner)


func controls_locked() -> bool:
	_control_locks = _control_locks.filter(func(owner: Node) -> bool: return is_instance_valid(owner))
	return not _control_locks.is_empty()


func acquire_control_lock(owner: Node) -> void:
	if not _control_locks.has(owner):
		_control_locks.append(owner)
	velocity = Vector3.ZERO
	_set_mouse_captured(false)
	_target = null
	_focus_id = 0
	_focus_key = ""
	EventBus.interaction_focus_changed.emit("")


func release_control_lock(owner: Node) -> void:
	_control_locks.erase(owner)
	_set_mouse_captured(not get_tree().paused and not controls_locked())


func is_hidden() -> bool:
	return is_instance_valid(_hide_spot)


func lie_on(spot: HideSpot) -> bool:
	return spot.enter(self) if is_instance_valid(spot) and spot.bed_id() != 0 else false


func enter_hide_spot(spot: HideSpot) -> bool:
	if is_hidden() or controls_locked() or spot.is_occupied():
		return false
	var anchor: Node3D = spot.get_node_or_null(spot.view) as Node3D
	var exit_anchor: Node3D = spot.get_node_or_null(spot.exit) as Node3D
	if anchor == null or exit_anchor == null:
		return false
	_hide_spot = spot
	_exit_transform = exit_anchor.global_transform
	velocity = Vector3.ZERO
	body_shape.set_deferred("disabled", true)
	_step_progress = 0.0
	_look_distance = 0.0
	_breath_elapsed = 0.0
	_hold_elapsed = 0.0
	_restless_cooldown = 0.0
	head.rotation = Vector3.ZERO
	camera.position = Vector3.ZERO
	if spot.entry_seconds() > 0.0:
		_climb = create_tween().set_parallel(true).set_trans(Tween.TRANS_SINE)
		_climb.tween_property(self, "global_transform", anchor.global_transform, spot.entry_seconds())
		_climb.tween_property(head, "position", Vector3.ZERO, spot.entry_seconds())
	else:
		global_transform = anchor.global_transform
		head.position = Vector3.ZERO
	GameState.set_flag(&"player_bed", spot.bed_id())
	spot.occupy(self)
	EventBus.player_hidden.emit(true, spot.kind)
	return true


func leave_hide_spot(noisy: bool = true) -> void:
	if not is_hidden():
		return
	var spot: HideSpot = _hide_spot
	_hide_spot = null
	if _climb != null and _climb.is_valid():
		_climb.kill()
	if noisy:
		make_noise(2.0, &"move")
	_set_holding_breath(false)
	_breath_elapsed = 0.0
	global_transform = _exit_transform
	head.rotation = Vector3.ZERO
	camera.position = Vector3.ZERO
	_set_crouched(not _can_stand())
	body_shape.set_deferred("disabled", false)
	velocity = Vector3.ZERO
	GameState.set_flag(&"player_bed", 0)
	spot.release()
	EventBus.player_hidden.emit(false, spot.kind)


func _update_breath(delta: float) -> void:
	var wants_hold: bool = not keyboard_input_blocked() and Input.is_action_pressed("hold_breath") and _breath_cooldown <= 0.0
	if wants_hold:
		_set_holding_breath(true)
		_hold_elapsed += delta
		var limit: float = maxf(0.1, max_breath_seconds) if is_finite(max_breath_seconds) else 8.0
		if _hold_elapsed >= limit - 0.000001:
			_set_holding_breath(false)
			_breath_cooldown = limit * 0.5
			_breath_elapsed = 0.0
			make_noise(4.0, &"breath")
	else:
		_set_holding_breath(false)
		_breath_elapsed += delta
		if _breath_elapsed >= 3.0:
			_breath_elapsed = fmod(_breath_elapsed, 3.0)
			make_noise(1.5, &"breath")


func _set_holding_breath(value: bool) -> void:
	if holding_breath == value:
		return
	holding_breath = value
	_hold_elapsed = 0.0
	_breath_elapsed = 0.0
	EventBus.breath_held.emit(value)


func _update_crouch() -> void:
	if Input.is_action_pressed("crouch"):
		_set_crouched(true)
	elif crouched and _can_stand():
		_set_crouched(false)


func _set_crouched(value: bool) -> void:
	crouched = value
	var capsule: CapsuleShape3D = body_shape.shape as CapsuleShape3D
	capsule.height = 1.15 if crouched else 1.75
	body_shape.position.y = capsule.height * 0.5
	head.position = Vector3(0, 1.0 if crouched else 1.6, 0)


func _can_stand() -> bool:
	var capsule: CapsuleShape3D = CapsuleShape3D.new()
	capsule.radius = 0.3
	capsule.height = 1.73
	var query: PhysicsShapeQueryParameters3D = PhysicsShapeQueryParameters3D.new()
	query.shape = capsule
	query.transform = Transform3D(Basis.IDENTITY, global_position + Vector3.UP * 0.885)
	query.collision_mask = collision_mask
	query.exclude = [get_rid()]
	return get_world_3d().direct_space_state.intersect_shape(query, 1).is_empty()
