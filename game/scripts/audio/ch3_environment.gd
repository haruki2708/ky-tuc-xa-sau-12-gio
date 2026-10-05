class_name Ch3Environment
extends Node
## Core supplies chapter zones, authored distant scream positions and old insect emitters.
## No guesses about scare IDs or campus coordinates.

@export var insect_emitters: Array[AmbientEmitter] = []
@export var scream_points: Array[Node3D] = []
@export_dir var sound_directory: String = Ch3AudioBank.DIRECTORY
var area: StringName = &""
var _bed: AudioStreamPlayer
var _scream: AudioStreamPlayer3D
var _until_scream: float = 35.0
var _previous_point: int = -1
var _insect_states: Dictionary[int, bool] = {}
var _rng := RandomNumberGenerator.new()
var _stopped: bool = false
var _chapter_active: bool = false


func _ready() -> void:
	_rng.randomize()
	_bed = AudioStreamPlayer.new()
	_bed.bus = &"Ambience"
	add_child(_bed)
	_scream = AudioStreamPlayer3D.new()
	_scream.bus = &"Ambience"
	_scream.max_distance = 120.0
	_scream.unit_size = 12.0
	add_child(_scream)
	EventBus.checkpoint_loaded.connect(_reset)
	EventBus.chapter_started.connect(_on_chapter)
	EventBus.chapter_finished.connect(_on_finished)
	EventBus.player_death_started.connect(_reset)


func set_area(value: StringName) -> void:
	if _stopped or value not in [&"stairs", &"stadium", &"canteen", &"garden", &"road", &"gate", &""]:
		return
	if value.is_empty():
		_reset(null)
		_chapter_active = false
		_restore_insects()
		return
	area = value
	_chapter_active = true
	for emitter in insect_emitters:
		if is_instance_valid(emitter):
			if not _insect_states.has(emitter.get_instance_id()):
				_insect_states[emitter.get_instance_id()] = emitter._active
			emitter.stop_emitting()
	Ch3AudioBank.play(_bed, String(area) if area in [&"stairs", &"stadium", &"canteen"] else "wind", sound_directory)
	if area in [&"stairs", &"canteen"]:
		_scream.stop()
		_until_scream = 35.0


func _process(delta: float) -> void:
	if _stopped or not _chapter_active:
		return
	# Prevent old zone callbacks from restarting the chapter 1 insect loop.
	for emitter in insect_emitters:
		if is_instance_valid(emitter):
			if not _insect_states.has(emitter.get_instance_id()):
				_insect_states[emitter.get_instance_id()] = emitter._active
			emitter.stop_emitting()
	if area.is_empty() or area in [&"stairs", &"canteen"]:
		return
	_until_scream -= delta
	if _until_scream <= 0:
		_until_scream = _rng.randf_range(30.0, 55.0)
		play_far_scream()


func play_far_scream() -> void:
	if _stopped or area not in [&"garden", &"road", &"gate", &"stadium"]:
		return
	var candidates: Array[Node3D] = []
	var valid_points: Array[Node3D] = []
	for point in scream_points:
		if is_instance_valid(point) and point.is_inside_tree():
			valid_points.append(point)
			if point.get_instance_id() != _previous_point:
				candidates.append(point)
	if candidates.is_empty():
		candidates = valid_points
	if candidates.is_empty():
		return
	var selected := candidates[_rng.randi_range(0, candidates.size() - 1)]
	_previous_point = selected.get_instance_id()
	_scream.global_position = selected.global_position
	_scream.volume_db = -6.0 if Ch1AudioBank.reduced() else 0.0
	Ch3AudioBank.play(_scream, "far_scream", sound_directory)


func _reset(_reason: Variant) -> void:
	area = &""
	_until_scream = 35.0
	_previous_point = -1
	if _bed != null:
		_bed.stop()
	if _scream != null:
		_scream.stop()
	# Death/checkpoint remain within chapter 3: insects must stay off.


func _on_chapter(chapter: int) -> void:
	_reset(null)
	_chapter_active = chapter == 3
	if not _chapter_active:
		_restore_insects()


func _on_finished(chapter: int) -> void:
	if chapter == 3:
		_reset(null)
		_chapter_active = false
		_restore_insects()


func _restore_insects() -> void:
	for emitter in insect_emitters:
		if is_instance_valid(emitter) and emitter.is_inside_tree() and _insect_states.get(emitter.get_instance_id(), false):
			emitter.start_emitting()
	_insect_states.clear()


func stop_emitting() -> void:
	_stopped = true
	_reset(null)
	_restore_insects()


func _exit_tree() -> void:
	_restore_insects()
