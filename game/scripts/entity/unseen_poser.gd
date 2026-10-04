class_name UnseenPoser
extends Node
## Poses are snapshots, so no animation continues after the camera turns back.

signal pose_changed(name: StringName)

@export var subject: Node3D
@export var camera: Camera3D
@export var animation_player: AnimationPlayer
@export var poses: Array[StringName] = [&"dead_a", &"dead_b", &"head_turn", &"eyes_open"]
@export var min_unseen_seconds: float = 4.0
@export_range(0.0, 1.0) var chance: float = 0.35
@export var max_distance: float = 15.0
@export var rng_seed: int = 0
@export var enabled: bool = true:
	set(value):
		enabled = value
		_unseen = 0.0

var current_pose: StringName = &""
var _index: int = 0
var _unseen: float = 0.0
var _rng: RandomNumberGenerator = RandomNumberGenerator.new()


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_PAUSABLE
	if subject == null:
		subject = get_parent() as Node3D
	if camera == null:
		camera = get_viewport().get_camera_3d()
	if rng_seed != 0:
		_rng.seed = rng_seed
	if animation_player == null and is_instance_valid(subject):
		var players: Array[Node] = subject.find_children("*", "AnimationPlayer", true, false)
		if not players.is_empty():
			animation_player = players[0] as AnimationPlayer
	if not poses.is_empty():
		_apply_pose(0)


func _physics_process(delta: float) -> void:
	if not enabled or not is_instance_valid(subject) or not is_instance_valid(camera) or poses.size() < 2:
		_unseen = 0.0
		return
	if not subject.is_inside_tree() or not camera.is_inside_tree():
		_unseen = 0.0
		return
	if EntityVisibility.is_seen_by(camera, subject, max_distance):
		_unseen = 0.0
		return
	_unseen += delta
	if _unseen + 0.000001 < maxf(0.01, min_unseen_seconds):
		return
	# One chance per complete unseen interval, not one roll per physics frame.
	_unseen = 0.0
	if _rng.randf() >= clampf(chance, 0.0, 1.0):
		return
	var next: int = (_index + 1) % poses.size()
	if _apply_pose(next):
		pose_changed.emit(current_pose)


func _apply_pose(index: int) -> bool:
	if not is_instance_valid(subject) or index < 0 or index >= poses.size():
		return false
	var name: StringName = poses[index]
	if is_instance_valid(animation_player):
		if not animation_player.has_animation(name):
			return false
		animation_player.play(name)
		animation_player.seek(animation_player.get_animation(name).length, true, true)
		animation_player.pause()
	else:
		var selected: Node3D = subject.get_node_or_null(NodePath(name)) as Node3D
		if selected == null:
			return false
		for pose: StringName in poses:
			var child: Node3D = subject.get_node_or_null(NodePath(pose)) as Node3D
			if child != null:
				child.visible = child == selected
	_index = index
	current_pose = name
	return true


static func is_seen_by(view_camera: Camera3D, node: Node3D, distance: float = 15.0) -> bool:
	return EntityVisibility.is_seen_by(view_camera, node, distance)
