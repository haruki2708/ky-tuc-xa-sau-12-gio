extends Node3D
## Visual body for DormManager.body_scene (T-219): the Tripo model, its clips and props.
## manager.gd finds the AnimationPlayer, BladeTip and (optional) LeftArm by name.

## Clips that repeat while their state lasts; slash and kill restart per call, ask plays once.
const LOOPING: Array[StringName] = [&"stand", &"walk", &"wait", &"lunge"]


func _ready() -> void:
	for node: Node in find_children("*", "AnimationPlayer", true, false):
		var player: AnimationPlayer = node as AnimationPlayer
		for clip: StringName in LOOPING:
			if player.has_animation(clip):
				player.get_animation(clip).loop_mode = Animation.LOOP_LINEAR
