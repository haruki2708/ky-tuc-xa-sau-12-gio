class_name DormManager
extends CharacterBody3D
## Scripted actor. Hearing reports evidence; only the director decides consequences.

signal arrived
signal answered(heard: bool)
signal slashed(target: Node3D)
signal slash_finished

enum State { IDLE, WALKING, SPEAKING, LISTENING, SLASHING, LUNGING, KILLING }

@export var body_scene: PackedScene
@export var player: Node3D
@export var look_target: Node3D
@export var audio_rig: Node3D
@export var speed: float = 0.9
@export var route: PackedVector3Array = PackedVector3Array()
@export var listen_seconds: float = 6.0
@export var subtitle_seconds: float = 2.5
@export_range(1, 20, 1) var slash_count: int = 6
@export var slash_interval: float = 0.45
@export var lunge_speed: float = 5.0
@export var lunge_seconds: float = 0.65

@onready var visual: Node3D = $Visual
@onready var navigation: NavigationAgent3D = $NavigationAgent3D
@onready var blade: Node3D = $Visual/Fallback/BladePivot

var state: State = State.IDLE
var _path: PackedVector3Array = PackedVector3Array()
var _point: int = 0
var _remaining: float = 0.0
var _heard: bool = false
var _slash_target: Node3D
var _cuts: int = 0
var _elapsed: float = 0.0
var _step_distance: float = 0.0
var _reduced: bool = false
var _model_animation: AnimationPlayer
var _blade_tip: Node3D
var _stand_marker: Node3D
var _serial: int = 0


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_PAUSABLE
	_read_settings()
	EventBus.settings_changed.connect(_on_settings_changed)
	EventBus.noise_emitted.connect(_on_noise)
	if body_scene != null:
		var model: Node = body_scene.instantiate()
		if model is Node3D:
			visual.add_child(model)
			$Visual/Fallback.hide()
			var animations: Array[Node] = model.find_children("*", "AnimationPlayer", true, false)
			if not animations.is_empty():
				_model_animation = animations[0] as AnimationPlayer
			_blade_tip = model.find_child("BladeTip", true, false) as Node3D
		else:
			model.free()
			push_warning("Manager body_scene needs a Node3D root; using fallback.")
	if audio_rig == null:
		audio_rig = get_tree().get_first_node_in_group(&"manager_audio") as Node3D
	if audio_rig == null and ResourceLoader.exists("res://audio/entities/manager_audio.tscn"):
		audio_rig = load("res://audio/entities/manager_audio.tscn").instantiate() as Node3D
		add_child(audio_rig)
	_play_animation(&"stand")


func walk_to(position: Vector3, via: PackedVector3Array = PackedVector3Array()) -> void:
	var points: PackedVector3Array = via.duplicate() if not via.is_empty() else route.duplicate()
	points.append(position)
	enter_room(points)


func enter_room(points: PackedVector3Array) -> void:
	stop()
	for point: Vector3 in points:
		if not point.is_finite():
			push_warning("Manager route contains a non-finite point.")
			return
	_path = points.duplicate()
	_point = 0
	state = State.WALKING
	if not _path.is_empty():
		navigation.target_position = _path[0]
	_play_animation(&"walk")


func stand_at(marker: Node3D) -> void:
	if not is_instance_valid(marker):
		return
	walk_to(marker.global_position)
	_stand_marker = marker


func open_door(door: Node) -> void:
	if is_instance_valid(door) and door.has_method("set_open"):
		door.call("set_open", true)


func ask(line_key: String) -> void:
	stop()
	if is_instance_valid(look_target):
		_face(look_target.global_position)
	_heard = false
	state = State.SPEAKING
	_remaining = maxf(0.0, subtitle_seconds)
	_sync_audio()
	if is_instance_valid(audio_rig) and audio_rig.has_method("say"):
		_remaining = maxf(0.0, float(audio_rig.call("say", line_key)))
	else:
		EventBus.subtitle_requested.emit(line_key, _remaining)
	_play_animation(&"ask")


func hear() -> void:
	if state == State.LISTENING and not get_tree().paused:
		_heard = true


func _on_noise(position: Vector3, _radius: float, _source: StringName) -> void:
	# The card defines a fixed four-metre listening radius, measured at head height.
	if state == State.LISTENING and position.distance_to(global_position + Vector3.UP * 1.6) <= 4.0:
		hear()


func slash(target: Node3D) -> void:
	stop()
	if not is_instance_valid(target):
		return
	_slash_target = target
	_face(target.global_position)
	state = State.SLASHING
	_play_animation(&"slash", maxf(0.05, slash_interval))


func kill_player() -> void:
	if state in [State.LUNGING, State.KILLING]:
		return
	stop()
	if not is_instance_valid(player):
		var camera: Camera3D = get_viewport().get_camera_3d()
		var ancestor: Node = camera
		while ancestor != null and not ancestor is CharacterBody3D:
			ancestor = ancestor.get_parent()
		player = ancestor as Node3D if ancestor != null else camera
	if not is_instance_valid(player):
		push_warning("Manager kill_player needs a player or active camera.")
		return
	state = State.LUNGING
	_remaining = maxf(0.0, lunge_seconds)
	_play_animation(&"lunge")


func stop() -> void:
	_serial += 1
	state = State.IDLE
	velocity = Vector3.ZERO
	_path.clear()
	_point = 0
	_cuts = 0
	_elapsed = 0.0
	_step_distance = 0.0
	_slash_target = null
	_stand_marker = null
	if is_instance_valid(blade):
		blade.rotation.x = 0.0
	_stop_audio()
	_play_animation(&"stand")


func _physics_process(delta: float) -> void:
	_sync_audio()
	match state:
		State.WALKING:
			_walk(delta)
		State.SPEAKING:
			_remaining -= delta
			if _remaining <= 0.0:
				state = State.LISTENING
				_remaining = maxf(0.0, listen_seconds)
				_play_animation(&"stand")
		State.LISTENING:
			_remaining -= delta
			if _remaining <= 0.0:
				state = State.IDLE
				answered.emit(_heard)
		State.SLASHING:
			_tick_slash(delta)
		State.LUNGING:
			if not is_instance_valid(player):
				stop()
				return
			_remaining -= delta
			var offset: Vector3 = _flat_offset(player.global_position)
			_move(offset, lunge_speed if offset.length() > 0.65 else 0.0, delta)
			if _remaining <= 0.0 or offset.length() <= 0.65:
				velocity = Vector3.ZERO
				_audio(&"play_drag", [false])
				state = State.KILLING
				_remaining = 0.15 if _reduced else 0.65
				if not _reduced:
					_play_animation(&"kill", 0.65)
				else:
					_play_animation(&"stand")
		State.KILLING:
			if not is_instance_valid(player):
				stop()
				return
			_remaining -= delta
			if not _reduced:
				blade.rotation.x = lerpf(-1.5, 0.6, clampf(1.0 - _remaining / 0.65, 0.0, 1.0))
			if _remaining <= 0.0:
				stop()
				# Core/death overlay owns the blackout; player audio already handles this event.
				EventBus.player_caught.emit(&"manager")


func _walk(delta: float) -> void:
	while _point < _path.size() and _flat_offset(_path[_point]).length() <= 0.08:
		_point += 1
		if _point < _path.size():
			navigation.target_position = _path[_point]
	if _point >= _path.size():
		state = State.IDLE
		velocity = Vector3.ZERO
		_audio(&"play_drag", [false])
		if is_instance_valid(_stand_marker):
			_face(global_position - _stand_marker.global_basis.z)
		_play_animation(&"stand")
		arrived.emit()
		return
	var destination: Vector3 = _path[_point]
	var map: RID = navigation.get_navigation_map()
	if map.is_valid() and NavigationServer3D.map_get_iteration_id(map) > 0 and not NavigationServer3D.map_get_regions(map).is_empty():
		destination = navigation.get_next_path_position()
	_move(_flat_offset(destination), speed, delta)


func _move(offset: Vector3, move_speed: float, delta: float) -> void:
	var direction: Vector3 = offset.normalized()
	var distance: float = minf(maxf(0.0, move_speed) * delta, offset.length())
	velocity.x = direction.x * distance / maxf(delta, 0.000001)
	velocity.z = direction.z * distance / maxf(delta, 0.000001)
	velocity.y = 0.0 if is_on_floor() else velocity.y - 9.8 * delta
	var before: Vector3 = global_position
	move_and_slide()
	var moved: float = Vector2(global_position.x - before.x, global_position.z - before.z).length()
	_audio(&"play_drag", [moved > 0.0001 and is_on_floor()])
	if is_on_floor():
		_step_distance += moved
		if _step_distance >= 0.7:
			_step_distance = fmod(_step_distance, 0.7)
			_audio(&"play_step")
	if not direction.is_zero_approx():
		_face(global_position + direction)


func _tick_slash(delta: float) -> void:
	if not is_instance_valid(_slash_target):
		stop()
		return
	_elapsed += delta
	var interval: float = maxf(0.05, slash_interval)
	blade.rotation.x = lerpf(-1.7, 0.6, clampf(_elapsed / interval, 0.0, 1.0))
	while _elapsed >= interval:
		_elapsed -= interval
		_cuts += 1
		_audio(&"play_slash", [&"wood" if _cuts % 3 == 0 else &"mattress"])
		var serial: int = _serial
		slashed.emit(_slash_target)
		if serial != _serial or state != State.SLASHING:
			return
		if not is_instance_valid(_slash_target):
			stop()
			return
		if _cuts >= maxi(1, slash_count):
			state = State.IDLE
			blade.rotation.x = 0.0
			_play_animation(&"stand")
			slash_finished.emit()
			return
		_play_animation(&"slash", interval)


func _flat_offset(point: Vector3) -> Vector3:
	var offset: Vector3 = point - global_position
	offset.y = 0.0
	return offset


func _face(point: Vector3) -> void:
	var offset: Vector3 = _flat_offset(point)
	if not offset.is_zero_approx():
		visual.global_rotation.y = atan2(-offset.x, -offset.z)


func _play_animation(name: StringName, seconds: float = 0.0) -> void:
	if is_instance_valid(_model_animation):
		_model_animation.stop()
		if _model_animation.has_animation(name):
			var animation: Animation = _model_animation.get_animation(name)
			_model_animation.speed_scale = animation.length / seconds if seconds > 0.0 else 1.0
			_model_animation.play(name)


func _audio(method: StringName, arguments: Array = []) -> void:
	if is_instance_valid(audio_rig) and audio_rig.has_method(method):
		audio_rig.callv(method, arguments)


func _sync_audio() -> void:
	if is_instance_valid(audio_rig) and audio_rig.is_inside_tree():
		audio_rig.global_position = global_position
		# Only drag follows the knife tip; speech stays with the body.
		var drag: Node3D = audio_rig.get_node_or_null("Drag") as Node3D
		if drag != null:
			drag.global_position = _blade_tip.global_position if is_instance_valid(_blade_tip) else blade.get_node("BladeTip").global_position


func _stop_audio() -> void:
	_audio(&"play_drag", [false])
	if is_instance_valid(audio_rig):
		for node: Node in audio_rig.find_children("*", "AudioStreamPlayer3D", true, false):
			(node as AudioStreamPlayer3D).stop()


func _read_settings() -> void:
	var config: ConfigFile = ConfigFile.new()
	_reduced = false
	if config.load("user://settings.cfg") == OK:
		var value: Variant = config.get_value("accessibility", "reduce_scares", false)
		_reduced = value if value is bool else false
	if _reduced and state == State.KILLING:
		blade.rotation.x = 0.0
		_play_animation(&"stand")
		_remaining = minf(_remaining, 0.15)


func _on_settings_changed(section: String, key: String) -> void:
	if section == "accessibility" and key == "reduce_scares":
		_read_settings()


func _exit_tree() -> void:
	_stop_audio()
