extends Node3D
## Visual body for DormManager.body_scene (T-219): the Tripo model, its clips and props.
## manager.gd finds the AnimationPlayer, BladeTip and LeftArm (door reach) by name. On its own
## (chapter 2's mirror flash) the body stands breathing instead of in its bind pose.

## Clips that repeat while their state lasts (ask is Tripo "wait", hand on hip, D-120);
## slash and kill restart per call.
const LOOPING: Array[StringName] = [&"stand", &"walk", &"ask", &"lunge"]


func _ready() -> void:
	for node: Node in find_children("*", "AnimationPlayer", true, false):
		var player: AnimationPlayer = node as AnimationPlayer
		for clip: StringName in LOOPING:
			if player.has_animation(clip):
				player.get_animation(clip).loop_mode = Animation.LOOP_LINEAR
		if not player.is_playing() and player.has_animation(&"stand"):
			player.play(&"stand")
