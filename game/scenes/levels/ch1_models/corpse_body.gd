extends Node3D
## Visual poses only. Unseen poser and chapter rules remain with Lane A/core.
const POSES: Array[StringName] = [&"dead_a", &"dead_b", &"head_turn", &"eyes_open", &"sit_up"]
var current_pose: StringName = &"dead_a"
var blood_visible: bool = false


func _ready() -> void:
	set_pose(current_pose)
	set_blood_visible(blood_visible)


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


func set_blood_visible(value: bool) -> void:
	blood_visible = value
	if is_node_ready():
		$Rig/Hips/Chest/Blood.visible = value
