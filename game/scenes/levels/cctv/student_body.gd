extends Node3D
## T-165: a living student on the security cameras. Visual poses only; core
## (T-160) stages them and the manager (lane A) does the killing.
const POSES: Array[StringName] = [&"lie_awake", &"sit_up", &"answer", &"phone_lit", &"cower", &"dead"]
var current_pose: StringName = &"lie_awake"


func _ready() -> void:
	set_pose(current_pose)


func set_pose(pose: StringName) -> bool:
	if pose not in POSES:
		return false
	current_pose = pose
	if is_node_ready():
		var player := $AnimationPlayer as AnimationPlayer
		player.play(pose)
		player.advance(0.0)
		player.pause()
	return true
